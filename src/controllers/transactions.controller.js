'use strict';

const {
  createTransactionSchema,
  updateTransactionSchema,
  rowParamSchema,
} = require('../schemas/transaction.schema');
const { googleSheetsService } = require('../services/googleSheets.service');

async function getAllTransactions(req, res, next) {
  try {
    const data = await googleSheetsService.getAllTransactions();
    res.status(200).json({
      success: true,
      data,
    });
  } catch (err) {
    next(err);
  }
}

async function createTransaction(req, res, next) {
  try {
    const validatedData = createTransactionSchema.parse(req.body);
    const result = await googleSheetsService.createTransaction(validatedData);
    res.status(201).json({
      success: true,
      data: result,
    });
  } catch (err) {
    next(err);
  }
}

async function updateTransaction(req, res, next) {
  try {
    const { row } = rowParamSchema.parse(req.params);
    const validatedData = updateTransactionSchema.parse(req.body);
    const result = await googleSheetsService.updateTransaction(row, validatedData);
    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (err) {
    next(err);
  }
}

async function deleteTransaction(req, res, next) {
  try {
    const { row } = rowParamSchema.parse(req.params);
    const result = await googleSheetsService.deleteTransaction(row);
    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  getAllTransactions,
  createTransaction,
  updateTransaction,
  deleteTransaction,
};
