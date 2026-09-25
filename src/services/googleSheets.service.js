'use strict';

const { env } = require('../config/env');
const {
  GoogleAppsScriptError,
  GoogleAppsScriptTimeoutError,
  NetworkError,
} = require('../errors/AppError');
const logger = require('../utils/logger');

class GoogleSheetsService {
  constructor(gasUrl = env.GAS_URL, timeoutMs = env.GAS_TIMEOUT_MS) {
    this.gasUrl = gasUrl;
    this.timeoutMs = timeoutMs;
  }

  /**
   * Internal helper to make HTTP requests to Google Apps Script.
   * Handles timeouts, redirects, and network failures.
   */
  async _request(method = 'GET', body = null) {
    let response;
    try {
      const options = {
        method,
        signal: AbortSignal.timeout(this.timeoutMs),
        redirect: 'follow',
      };

      if (body !== null) {
        options.headers = {
          'Content-Type': 'text/plain;charset=utf-8',
        };
        options.body = JSON.stringify(body);
      }

      response = await fetch(this.gasUrl, options);
    } catch (err) {
      if (err.name === 'TimeoutError') {
        logger.error(`Google Apps Script request timed out after ${this.timeoutMs}ms`);
        throw new GoogleAppsScriptTimeoutError(
          `Google Apps Script request timed out after ${this.timeoutMs}ms`
        );
      }
      logger.error('Network error during Google Apps Script request', { error: err.message });
      throw new NetworkError('Unable to connect to Google Apps Script');
    }

    if (!response.ok) {
      logger.error('Google Apps Script returned non-2xx status', {
        status: response.status,
        statusText: response.statusText,
      });
      throw new GoogleAppsScriptError(
        `Google Apps Script responded with HTTP ${response.status}`
      );
    }

    let parsedData;
    try {
      const text = await response.text();
      parsedData = JSON.parse(text);
    } catch (err) {
      logger.error('Failed to parse Google Apps Script response as JSON', {
        error: err.message,
      });
      throw new GoogleAppsScriptError(
        'Invalid JSON received from Google Apps Script'
      );
    }

    // Handle Google Apps Script explicit application-level error
    if (parsedData && parsedData.status === 'error') {
      logger.error('Google Apps Script returned application error', {
        message: parsedData.message,
      });
      throw new GoogleAppsScriptError(
        `Google Apps Script error: ${parsedData.message || 'Unknown upstream script error'}`
      );
    }

    return parsedData;
  }

  /**
   * Fetch all transaction records from Google Apps Script.
   */
  async getAllTransactions() {
    const result = await this._request('GET');
    if (result && result.status === 'success' && Array.isArray(result.data)) {
      return result.data;
    }
    return result;
  }

  /**
   * Create a new transaction in Google Sheets.
   */
  async createTransaction({ tanggal, kategori, sub_kategori, deskripsi, nominal }) {
    const payload = {
      action: 'create',
      tanggal,
      kategori,
      sub_kategori,
      deskripsi,
      nominal,
    };
    return this._request('POST', payload);
  }

  /**
   * Update an existing transaction in Google Sheets by row index.
   */
  async updateTransaction(row, { tanggal, kategori, sub_kategori, deskripsi, nominal }) {
    const payload = {
      action: 'update',
      row,
      tanggal,
      kategori,
      sub_kategori,
      deskripsi,
      nominal,
    };
    return this._request('POST', payload);
  }

  /**
   * Delete a transaction from Google Sheets by row index.
   */
  async deleteTransaction(row) {
    const payload = {
      action: 'delete',
      row,
    };
    return this._request('POST', payload);
  }
}

const googleSheetsService = new GoogleSheetsService();

module.exports = {
  GoogleSheetsService,
  googleSheetsService,
};
