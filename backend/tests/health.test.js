'use strict';

const { test, describe } = require('node:test');
const assert = require('node:assert/strict');
const request = require('supertest');
const app = require('../src/app');

describe('GET /api/health', () => {
  test('should return 200 with status ok and ISO timestamp', async () => {
    const res = await request(app)
      .get('/api/health')
      .expect('Content-Type', /json/)
      .expect(200);

    assert.equal(res.body.success, true);
    assert.equal(res.body.status, 'ok');
    assert.ok(typeof res.body.timestamp === 'string');
    // Ensure timestamp is valid ISO string
    assert.ok(!isNaN(Date.parse(res.body.timestamp)));
  });
});
