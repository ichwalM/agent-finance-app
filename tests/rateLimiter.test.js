'use strict';

const { test, describe, beforeEach, afterEach } = require('node:test');
const assert = require('node:assert/strict');
const request = require('supertest');
const app = require('../src/app');
const { geminiService } = require('../src/services/gemini.service');

const VALID_PNG = Buffer.from([
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4,
  0x89, 0x00, 0x00, 0x00, 0x0a, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0d, 0x0a, 0x2d, 0xb4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae,
  0x42, 0x60, 0x82,
]);

describe('Rate Limiter for POST /api/scan-receipt', () => {
  let originalScan;

  beforeEach(() => {
    originalScan = geminiService.scanReceipt;
    geminiService.scanReceipt = async () => ({
      tanggal: '2026-09-25',
      nominal: 10000,
      kategori: 'Needs',
      sub_kategori: 'Makan & Minum',
      deskripsi: 'Test',
    });
  });

  afterEach(() => {
    geminiService.scanReceipt = originalScan;
  });

  test('should trigger 429 when scan requests exceed maximum rate limit', async () => {
    // Send 10 allowed requests (SCAN_RATE_LIMIT_MAX = 10)
    for (let i = 0; i < 10; i++) {
      const res = await request(app)
        .post('/api/scan-receipt')
        .set('X-Forwarded-For', '192.168.1.100')
        .attach('receipt', VALID_PNG, 'receipt.png');

      assert.ok(res.status === 200 || res.status === 429);
      if (res.status === 429) {
        break;
      }
    }

    // 11th request from same IP must be rate-limited with HTTP 429
    const blockedRes = await request(app)
      .post('/api/scan-receipt')
      .set('X-Forwarded-For', '192.168.1.100')
      .attach('receipt', VALID_PNG, 'receipt.png')
      .expect(429);

    assert.equal(blockedRes.body.success, false);
    assert.equal(blockedRes.body.error.code, 'TOO_MANY_REQUESTS');
  });
});
