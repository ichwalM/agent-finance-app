'use strict';

const { Router } = require('express');
const healthRoutes = require('./health.routes');
const transactionsRoutes = require('./transactions.routes');
const receiptRoutes = require('./receipt.routes');

const router = Router();

router.use('/health', healthRoutes);
router.use('/transactions', transactionsRoutes);
router.use('/scan-receipt', receiptRoutes);
router.use('/receipts', receiptRoutes);

module.exports = router;
