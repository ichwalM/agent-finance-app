'use strict';

const { Router } = require('express');
const { scanReceipt, getReceiptImage } = require('../controllers/receipt.controller');
const uploadMiddleware = require('../middleware/upload.middleware');
const { scanRateLimiter } = require('../middleware/rateLimiter.middleware');

const router = Router();

router.post('/', scanRateLimiter, uploadMiddleware, scanReceipt);
router.get('/:folder/:fileName', getReceiptImage);

module.exports = router;
