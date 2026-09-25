'use strict';

const { test, describe, beforeEach, afterEach } = require('node:test');
const assert = require('node:assert/strict');
const request = require('supertest');
const app = require('../src/app');
const { googleSheetsService } = require('../src/services/googleSheets.service');
const { GoogleAppsScriptError } = require('../src/errors/AppError');

describe('Transactions API', () => {
  let originalGetAll;
  let originalCreate;
  let originalUpdate;
  let originalDelete;

  beforeEach(() => {
    originalGetAll = googleSheetsService.getAllTransactions;
    originalCreate = googleSheetsService.createTransaction;
    originalUpdate = googleSheetsService.updateTransaction;
    originalDelete = googleSheetsService.deleteTransaction;
  });

  afterEach(() => {
    googleSheetsService.getAllTransactions = originalGetAll;
    googleSheetsService.createTransaction = originalCreate;
    googleSheetsService.updateTransaction = originalUpdate;
    googleSheetsService.deleteTransaction = originalDelete;
  });

  describe('GET /api/transactions', () => {
    test('should proxy transactions from Google Apps Script successfully', async () => {
      const mockData = [
        {
          row: 2,
          tanggal: '2026-09-25',
          kategori: 'Needs',
          sub_kategori: 'Makan & Minum',
          deskripsi: 'Alfamart',
          nominal: 25000,
        },
      ];

      googleSheetsService.getAllTransactions = async () => mockData;

      const res = await request(app)
        .get('/api/transactions')
        .expect('Content-Type', /json/)
        .expect(200);

      assert.equal(res.body.success, true);
      assert.deepEqual(res.body.data, mockData);
    });

    test('should return 502 when Google Apps Script returns an error', async () => {
      googleSheetsService.getAllTransactions = async () => {
        throw new GoogleAppsScriptError('GAS is currently unavailable');
      };

      const res = await request(app)
        .get('/api/transactions')
        .expect('Content-Type', /json/)
        .expect(502);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'GOOGLE_APPS_SCRIPT_ERROR');
      assert.ok(!res.body.error.stack);
    });
  });

  describe('POST /api/transactions', () => {
    test('should create a transaction with valid payload', async () => {
      let passedPayload = null;
      googleSheetsService.createTransaction = async (payload) => {
        passedPayload = payload;
        return { status: 'success', message: 'Transaction created successfully' };
      };

      const validPayload = {
        tanggal: '2026-09-25',
        kategori: 'Needs',
        sub_kategori: 'Makan & Minum',
        deskripsi: 'Alfamart',
        nominal: 25000,
      };

      const res = await request(app)
        .post('/api/transactions')
        .send(validPayload)
        .expect('Content-Type', /json/)
        .expect(201);

      assert.equal(res.body.success, true);
      assert.deepEqual(passedPayload, validPayload);
    });

    test('should reject invalid kategori', async () => {
      const payload = {
        tanggal: '2026-09-25',
        kategori: 'InvalidCategory',
        sub_kategori: 'Makan & Minum',
        deskripsi: 'Alfamart',
        nominal: 25000,
      };

      const res = await request(app)
        .post('/api/transactions')
        .send(payload)
        .expect('Content-Type', /json/)
        .expect(400);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'VALIDATION_ERROR');
    });

    test('should reject mismatched sub_kategori for given kategori', async () => {
      const payload = {
        tanggal: '2026-09-25',
        kategori: 'Needs',
        sub_kategori: 'Kopi & Nongkrong', // Belongs to Wants, not Needs
        deskripsi: 'Coffee Shop',
        nominal: 35000,
      };

      const res = await request(app)
        .post('/api/transactions')
        .send(payload)
        .expect('Content-Type', /json/)
        .expect(400);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'VALIDATION_ERROR');
      assert.ok(
        res.body.error.details.some((d) => d.field === 'sub_kategori')
      );
    });

    test('should reject negative nominal', async () => {
      const payload = {
        tanggal: '2026-09-25',
        kategori: 'Needs',
        sub_kategori: 'Makan & Minum',
        deskripsi: 'Alfamart',
        nominal: -25000,
      };

      const res = await request(app)
        .post('/api/transactions')
        .send(payload)
        .expect('Content-Type', /json/)
        .expect(400);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'VALIDATION_ERROR');
    });

    test('should reject zero nominal', async () => {
      const payload = {
        tanggal: '2026-09-25',
        kategori: 'Needs',
        sub_kategori: 'Makan & Minum',
        deskripsi: 'Alfamart',
        nominal: 0,
      };

      const res = await request(app)
        .post('/api/transactions')
        .send(payload)
        .expect(400);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'VALIDATION_ERROR');
    });

    test('should reject invalid calendar date (e.g., February 30)', async () => {
      const payload = {
        tanggal: '2026-02-30',
        kategori: 'Needs',
        sub_kategori: 'Makan & Minum',
        deskripsi: 'Alfamart',
        nominal: 25000,
      };

      const res = await request(app)
        .post('/api/transactions')
        .send(payload)
        .expect(400);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'VALIDATION_ERROR');
    });

    test('should reject extra disallowed properties (strict schema)', async () => {
      const payload = {
        tanggal: '2026-09-25',
        kategori: 'Needs',
        sub_kategori: 'Makan & Minum',
        deskripsi: 'Alfamart',
        nominal: 25000,
        action: 'create', // Client cannot specify action
      };

      const res = await request(app)
        .post('/api/transactions')
        .send(payload)
        .expect(400);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'VALIDATION_ERROR');
    });
  });

  describe('PUT /api/transactions/:row', () => {
    test('should update transaction with valid row and payload', async () => {
      let passedRow = null;
      let passedPayload = null;

      googleSheetsService.updateTransaction = async (row, payload) => {
        passedRow = row;
        passedPayload = payload;
        return { status: 'success', message: 'Row updated' };
      };

      const updateData = {
        tanggal: '2026-09-25',
        kategori: 'Needs',
        sub_kategori: 'Makan & Minum',
        deskripsi: 'Indomaret',
        nominal: 30000,
      };

      const res = await request(app)
        .put('/api/transactions/4')
        .send(updateData)
        .expect(200);

      assert.equal(res.body.success, true);
      assert.equal(passedRow, 4);
      assert.deepEqual(passedPayload, updateData);
    });

    test('should reject non-numeric row parameter', async () => {
      const res = await request(app)
        .put('/api/transactions/abc')
        .send({
          tanggal: '2026-09-25',
          kategori: 'Needs',
          sub_kategori: 'Makan & Minum',
          deskripsi: 'Indomaret',
          nominal: 30000,
        })
        .expect(400);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'VALIDATION_ERROR');
    });

    test('should reject negative or zero row parameter', async () => {
      const resZero = await request(app)
        .put('/api/transactions/0')
        .send({
          tanggal: '2026-09-25',
          kategori: 'Needs',
          sub_kategori: 'Makan & Minum',
          deskripsi: 'Indomaret',
          nominal: 30000,
        })
        .expect(400);

      assert.equal(resZero.body.success, false);

      const resNeg = await request(app)
        .put('/api/transactions/-5')
        .send({
          tanggal: '2026-09-25',
          kategori: 'Needs',
          sub_kategori: 'Makan & Minum',
          deskripsi: 'Indomaret',
          nominal: 30000,
        })
        .expect(400);

      assert.equal(resNeg.body.success, false);
    });
  });

  describe('DELETE /api/transactions/:row', () => {
    test('should delete transaction with valid row parameter', async () => {
      let deletedRow = null;
      googleSheetsService.deleteTransaction = async (row) => {
        deletedRow = row;
        return { status: 'success', message: 'Row deleted' };
      };

      const res = await request(app)
        .delete('/api/transactions/4')
        .expect(200);

      assert.equal(res.body.success, true);
      assert.equal(deletedRow, 4);
    });

    test('should reject invalid row parameter for delete', async () => {
      const res = await request(app)
        .delete('/api/transactions/invalid')
        .expect(400);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'VALIDATION_ERROR');
    });

    test('should reject zero row parameter for delete', async () => {
      const res = await request(app)
        .delete('/api/transactions/0')
        .expect(400);

      assert.equal(res.body.success, false);
      assert.equal(res.body.error.code, 'VALIDATION_ERROR');
    });
  });
});
