'use strict';

const { test, describe, beforeEach, afterEach } = require('node:test');
const assert = require('node:assert/strict');
const request = require('supertest');
const app = require('../src/app');
const { geminiService } = require('../src/services/gemini.service');
const { googleSheetsService } = require('../src/services/googleSheets.service');
const { GeminiError } = require('../src/errors/AppError');

// Valid 1x1 JPEG buffer
const VALID_JPEG = Buffer.from([
  0xff, 0xd8, 0xff, 0xe0, 0x00, 0x10, 0x4a, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01, 0x01, 0x00, 0x48,
  0x00, 0x48, 0x00, 0x00, 0xff, 0xdb, 0x00, 0x43, 0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08,
  0x07, 0x07, 0x07, 0x09, 0x09, 0x08, 0x0a, 0x0c, 0x14, 0x0d, 0x0c, 0x0b, 0x0b, 0x0c, 0x19, 0x12,
  0x13, 0x0f, 0x14, 0x1d, 0x1a, 0x1f, 0x1e, 0x1d, 0x1a, 0x1c, 0x1c, 0x20, 0x24, 0x2e, 0x27, 0x20,
  0x22, 0x2c, 0x23, 0x1c, 0x1c, 0x28, 0x37, 0x29, 0x2c, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1f, 0x27,
  0x39, 0x3d, 0x38, 0x32, 0x3c, 0x2e, 0x33, 0x34, 0x32, 0xff, 0xc0, 0x00, 0x0b, 0x08, 0x00, 0x01,
  0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0xff, 0xc4, 0x00, 0x1f, 0x00, 0x00, 0x01, 0x05, 0x01, 0x01,
  0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04,
  0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0xff, 0xda, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, 0x3f,
  0x00, 0xbf, 0x00, 0xff, 0xd9,
]);

// Valid 1x1 PNG buffer
const VALID_PNG = Buffer.from([
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4,
  0x89, 0x00, 0x00, 0x00, 0x0a, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0d, 0x0a, 0x2d, 0xb4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae,
  0x42, 0x60, 0x82,
]);

describe('POST /api/scan-receipt', () => {
  let originalScan;
  let originalGASCreate;
  let gasCreateCalled = false;

  beforeEach(() => {
    originalScan = geminiService.scanReceipt;
    originalGASCreate = googleSheetsService.createTransaction;
    gasCreateCalled = false;
    googleSheetsService.createTransaction = async () => {
      gasCreateCalled = true;
      return { status: 'success' };
    };
  });

  afterEach(() => {
    geminiService.scanReceipt = originalScan;
    googleSheetsService.createTransaction = originalGASCreate;
  });

  test('should reject request when no file is uploaded', async () => {
    const res = await request(app)
      .post('/api/scan-receipt')
      .expect(400);

    assert.equal(res.body.success, false);
    assert.equal(res.body.error.code, 'MISSING_FILE');
    assert.equal(gasCreateCalled, false);
  });

  test('should reject unsupported MIME type (e.g., text/plain)', async () => {
    const res = await request(app)
      .post('/api/scan-receipt')
      .attach('receipt', Buffer.from('hello world'), {
        filename: 'test.txt',
        contentType: 'text/plain',
      })
      .expect(415);

    assert.equal(res.body.success, false);
    assert.equal(res.body.error.code, 'UNSUPPORTED_MEDIA_TYPE');
    assert.equal(gasCreateCalled, false);
  });

  test('should reject spoofed image with invalid magic bytes', async () => {
    // Declared as image/jpeg but contents are plaintext
    const res = await request(app)
      .post('/api/scan-receipt')
      .attach('receipt', Buffer.from('malicious payload disguised as jpeg'), {
        filename: 'fake.jpg',
        contentType: 'image/jpeg',
      })
      .expect(415);

    assert.equal(res.body.success, false);
    assert.equal(res.body.error.code, 'UNSUPPORTED_MEDIA_TYPE');
    assert.equal(gasCreateCalled, false);
  });

  test('should reject file exceeding 5 MB limit', async () => {
    const largeBuffer = Buffer.alloc(5 * 1024 * 1024 + 1024); // 5 MB + 1 KB

    const res = await request(app)
      .post('/api/scan-receipt')
      .attach('receipt', largeBuffer, {
        filename: 'large.jpg',
        contentType: 'image/jpeg',
      })
      .expect(413);

    assert.equal(res.body.success, false);
    assert.equal(res.body.error.code, 'FILE_TOO_LARGE');
    assert.equal(gasCreateCalled, false);
  });

  test('should handle Gemini invalid response cleanly', async () => {
    geminiService.scanReceipt = async () => {
      throw new GeminiError('Gemini response could not be parsed as JSON');
    };

    const res = await request(app)
      .post('/api/scan-receipt')
      .attach('receipt', VALID_JPEG, {
        filename: 'receipt.jpg',
        contentType: 'image/jpeg',
      })
      .expect(502);

    assert.equal(res.body.success, false);
    assert.equal(res.body.error.code, 'GEMINI_ERROR');
    assert.equal(gasCreateCalled, false);
  });

  test('should extract structured data from valid receipt and NOT save to Google Sheets', async () => {
    const mockExtracted = {
      tanggal: '2026-09-25',
      nominal: 45000,
      kategori: 'Needs',
      sub_kategori: 'Makan & Minum',
      deskripsi: 'Alfamart',
    };

    geminiService.scanReceipt = async () => mockExtracted;

    const res = await request(app)
      .post('/api/scan-receipt')
      .attach('receipt', VALID_PNG, {
        filename: 'receipt.png',
        contentType: 'image/png',
      })
      .expect(200);

    assert.equal(res.body.success, true);
    assert.equal(res.body.data.tanggal, mockExtracted.tanggal);
    assert.equal(res.body.data.nominal, mockExtracted.nominal);
    assert.equal(res.body.data.kategori, mockExtracted.kategori);
    assert.equal(res.body.data.sub_kategori, mockExtracted.sub_kategori);
    assert.equal(res.body.data.deskripsi, mockExtracted.deskripsi);
    assert.equal('image_url' in res.body.data, true);
    assert.equal('image_key' in res.body.data, true);
    // CRITICAL: Ensure scan receipt NEVER saves directly to Google Sheets!
    assert.equal(gasCreateCalled, false);
  });
});
