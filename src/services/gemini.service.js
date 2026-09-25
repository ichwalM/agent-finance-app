'use strict';

const { GoogleGenerativeAI, SchemaType } = require('@google/generative-ai');
const { env } = require('../config/env');
const { ALLOWED_CATEGORIES } = require('../constants/categories');
const { receiptResultSchema } = require('../schemas/receipt.schema');
const { GeminiError, GeminiTimeoutError } = require('../errors/AppError');
const logger = require('../utils/logger');

const SYSTEM_INSTRUCTION = `Anda adalah AI receipt parser untuk aplikasi personal finance.

Analisis gambar struk yang diberikan.

Ekstrak transaksi utama dari struk tersebut dan kembalikan HANYA structured JSON sesuai schema yang diberikan.

Jangan mengarang informasi yang tidak terlihat pada struk.

Kategori yang diperbolehkan:

Needs:
- Sewa Kost
- Makan & Minum
- Transport & Bensin
- Internet & Kuota
- Internet/Kuota

Wants:
- Kopi & Nongkrong
- Jajan & Hiburan
- Kopi & Jajan

Simpanan:
- Dana Darurat

Investasi:
- RDPU / Saham / Emas
- Portofolio Investasi

Aturan:

1. tanggal harus menggunakan format YYYY-MM-DD.
2. nominal adalah total pembayaran akhir pada struk.
3. nominal harus berupa number tanpa simbol mata uang dan separator ribuan.
4. kategori hanya boleh salah satu:
   - Needs
   - Wants
   - Simpanan
   - Investasi
5. sub_kategori harus sesuai daftar kategori yang diperbolehkan.
6. deskripsi sebaiknya berisi nama merchant/toko.
7. Jika nama toko tidak jelas, gunakan ringkasan isi transaksi.
8. Jangan menambahkan property selain schema yang ditentukan.
9. Jangan mengembalikan Markdown.
10. Jangan mengembalikan \`\`\`json.
11. Jangan memberikan penjelasan tambahan.`;

class GeminiService {
  constructor(
    apiKey = env.GEMINI_API_KEY,
    modelName = env.GEMINI_MODEL,
    timeoutMs = env.GEMINI_TIMEOUT_MS,
    aiProvider = env.AI_PROVIDER,
    router9BaseUrl = env.ROUTER9_BASE_URL,
    router9ApiKey = env.ROUTER9_API_KEY,
    router9Model = env.ROUTER9_MODEL,
    router9TimeoutMs = env.ROUTER9_TIMEOUT_MS
  ) {
    this.apiKey = apiKey;
    this.modelName = modelName;
    this.timeoutMs = timeoutMs;
    this.aiProvider = aiProvider;
    this.router9BaseUrl = router9BaseUrl;
    this.router9ApiKey = router9ApiKey;
    this.router9Model = router9Model;
    this.router9TimeoutMs = router9TimeoutMs;
    this._client = null;
  }

  _getClient() {
    if (!this._client) {
      this._client = new GoogleGenerativeAI(this.apiKey);
    }
    return this._client;
  }

  /**
   * Internal call using official Google Gemini SDK.
   */
  async _scanWithGemini(buffer, mimeType) {
    const client = this._getClient();
    const model = client.getGenerativeModel({
      model: this.modelName,
      systemInstruction: SYSTEM_INSTRUCTION,
      generationConfig: {
        responseMimeType: 'application/json',
        responseSchema: {
          type: SchemaType.OBJECT,
          properties: {
            tanggal: {
              type: SchemaType.STRING,
              description: 'Format YYYY-MM-DD',
            },
            nominal: {
              type: SchemaType.NUMBER,
              description: 'Total pembayaran akhir berupa angka',
            },
            kategori: {
              type: SchemaType.STRING,
              enum: ALLOWED_CATEGORIES,
              description: 'Kategori utama',
            },
            sub_kategori: {
              type: SchemaType.STRING,
              description: 'Sub kategori sesuai daftar yang diperbolehkan',
            },
            deskripsi: {
              type: SchemaType.STRING,
              description: 'Nama merchant/toko atau ringkasan transaksi',
            },
          },
          required: ['tanggal', 'nominal', 'kategori', 'sub_kategori', 'deskripsi'],
        },
      },
    });

    const promptPart = 'Ekstrak transaksi utama dari struk ini sesuai panduan sistem.';
    const imagePart = {
      inlineData: {
        data: buffer.toString('base64'),
        mimeType,
      },
    };

    let result;
    try {
      let timerId;
      const timeoutPromise = new Promise((_, reject) => {
        timerId = setTimeout(() => {
          reject(new GeminiTimeoutError(`Gemini request timed out after ${this.timeoutMs}ms`));
        }, this.timeoutMs);
      });

      const apiPromise = model.generateContent([imagePart, promptPart]);

      result = await Promise.race([apiPromise, timeoutPromise]).finally(() => {
        clearTimeout(timerId);
      });
    } catch (err) {
      if (err instanceof GeminiTimeoutError) {
        throw err;
      }
      logger.error('Gemini API call failed', { error: err.message });
      throw new GeminiError('Failed to analyze receipt image with Gemini Vision');
    }

    try {
      return result.response.text();
    } catch (err) {
      logger.error('Failed to retrieve text from Gemini response', { error: err.message });
      throw new GeminiError('Empty or unreadable response received from Gemini');
    }
  }

  /**
   * Internal call using 9Router / OpenAI-compatible endpoint.
   */
  async _scanWith9Router(buffer, mimeType) {
    const payload = {
      model: this.router9Model,
      messages: [
        {
          role: 'system',
          content: SYSTEM_INSTRUCTION,
        },
        {
          role: 'user',
          content: [
            {
              type: 'text',
              text: 'Ekstrak transaksi utama dari struk ini sesuai panduan sistem. Kembalikan HANYA JSON.',
            },
            {
              type: 'image_url',
              image_url: {
                url: `data:${mimeType};base64,${buffer.toString('base64')}`,
              },
            },
          ],
        },
      ],
      temperature: 0.1,
    };

    let response;
    try {
      response = await fetch(`${this.router9BaseUrl}/chat/completions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.router9ApiKey}`,
        },
        body: JSON.stringify(payload),
        signal: AbortSignal.timeout(this.router9TimeoutMs),
      });
    } catch (err) {
      if (err.name === 'TimeoutError') {
        throw new GeminiTimeoutError(`9Router request timed out after ${this.router9TimeoutMs}ms`);
      }
      logger.error('9Router communication error', { error: err.message });
      throw new GeminiError('Failed to communicate with 9Router API');
    }

    if (!response.ok) {
      const errBody = await response.text().catch(() => '');
      logger.error('9Router returned non-2xx status', {
        status: response.status,
        body: errBody.substring(0, 150),
      });
      throw new GeminiError(`9Router API responded with HTTP ${response.status}`);
    }

    let data;
    try {
      data = await response.json();
    } catch (err) {
      logger.error('Failed to parse 9Router response as JSON', { error: err.message });
      throw new GeminiError('Invalid JSON received from 9Router API');
    }

    const content = data?.choices?.[0]?.message?.content;
    if (!content || typeof content !== 'string') {
      logger.error('Empty content in 9Router response', { data });
      throw new GeminiError('Empty content received from 9Router');
    }

    return content;
  }

  /**
   * Scans a receipt image buffer and returns validated structured transaction data.
   * Supports both native Gemini SDK and 9Router proxy.
   *
   * @param {Object} params
   * @param {Buffer} params.buffer - The in-memory image buffer
   * @param {string} params.mimeType - The validated MIME type
   * @returns {Promise<Object>} Validated receipt transaction data
   */
  async scanReceipt({ buffer, mimeType }) {
    if (!buffer || !Buffer.isBuffer(buffer)) {
      throw new GeminiError('No image buffer provided for analysis');
    }

    let rawText;
    if (this.aiProvider === '9router') {
      rawText = await this._scanWith9Router(buffer, mimeType);
    } else {
      rawText = await this._scanWithGemini(buffer, mimeType);
    }

    if (!rawText || rawText.trim().length === 0) {
      logger.error('AI provider returned empty response');
      throw new GeminiError('AI provider returned an empty response');
    }

    let parsedJson;
    try {
      // Clean potential code block wrapping
      const cleaned = rawText
        .trim()
        .replace(/^```json\s*/i, '')
        .replace(/^```\s*/i, '')
        .replace(/\s*```$/i, '');
      parsedJson = JSON.parse(cleaned);
    } catch (err) {
      logger.error('Failed to parse AI output as JSON', {
        rawOutput: rawText.substring(0, 150),
      });
      throw new GeminiError('AI response could not be parsed as JSON');
    }

    // Strict schema & calendar validation of AI output
    const validation = receiptResultSchema.safeParse(parsedJson);
    if (!validation.success) {
      logger.error('AI structured output failed schema validation', {
        errors: validation.error.issues,
        parsedJson,
      });
      throw new GeminiError('AI returned data that did not satisfy validation rules');
    }

    return validation.data;
  }
}

const geminiService = new GeminiService();

module.exports = {
  GeminiService,
  geminiService,
};
