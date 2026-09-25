'use strict';

const { geminiService } = require('../services/gemini.service');
const { storageService } = require('../services/storage.service');
const logger = require('../utils/logger');
const { NotFoundError } = require('../errors/AppError');

async function scanReceipt(req, res, next) {
  try {
    const { buffer, mimetype, originalname } = req.file;

    // 1. Persist receipt photo to MinIO Object Storage
    let storedImage = null;
    if (storageService.isEnabled()) {
      try {
        storedImage = await storageService.uploadReceipt(
          buffer,
          mimetype,
          originalname || 'receipt.jpg'
        );
      } catch (storageErr) {
        logger.warn('Failed to upload receipt to storage', {
          error: storageErr.message,
        });
      }
    }

    // 2. Process image through AI Vision and validate schema
    const parsedData = await geminiService.scanReceipt({
      buffer,
      mimeType: mimetype,
    });

    // NOTE: Does NOT save to Google Sheets! Client reviews/edits then posts to /api/transactions.
    res.status(200).json({
      success: true,
      data: {
        ...parsedData,
        image_url: storedImage ? storedImage.url : null,
        image_key: storedImage ? storedImage.objectName : null,
      },
    });
  } catch (err) {
    next(err);
  }
}

/**
 * Stream a saved receipt image from MinIO through the backend gateway.
 */
async function getReceiptImage(req, res, next) {
  try {
    const { folder, fileName } = req.params;
    const objectName = `${folder}/${fileName}`;

    const stream = await storageService.getObjectStream(objectName);

    const ext = fileName.split('.').pop().toLowerCase();
    const contentType =
      ext === 'png'
        ? 'image/png'
        : ext === 'webp'
        ? 'image/webp'
        : 'image/jpeg';

    res.setHeader('Content-Type', contentType);
    res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');
    stream.pipe(res);
  } catch (err) {
    if (err.code === 'NoSuchKey' || err.statusCode === 404) {
      return next(new NotFoundError('Receipt image not found'));
    }
    next(err);
  }
}

module.exports = {
  scanReceipt,
  getReceiptImage,
};
