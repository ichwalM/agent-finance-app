'use strict';

const { Router } = require('express');
const {
  getAllTransactions,
  createTransaction,
  updateTransaction,
  deleteTransaction,
} = require('../controllers/transactions.controller');

const router = Router();

router.get('/', getAllTransactions);
router.post('/', createTransaction);
router.put('/:row', updateTransaction);
router.delete('/:row', deleteTransaction);

module.exports = router;
