'use strict';

const multer = require('multer');
const { UploadError } = require('../errors/AppError');
const { isAllowedImageType, ALLOWED_MIME_TYPES } = require('../utils/magicBytes');

const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5 MB

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: MAX_FILE_SIZE,
    files: 1,
  },
  fileFilter: (req, file, cb) => {
    if (!ALLOWED_MIME_TYPES.has(file.mimetype)) {
      return cb(
        new UploadError(
          `Invalid file MIME type: ${file.mimetype}. Allowed types: ${Array.from(ALLOWED_MIME_TYPES).join(', ')}`,
          415,
          'UNSUPPORTED_MEDIA_TYPE'
        ),
        false
      );
    }
    cb(null, true);
  },
}).single('receipt');

function uploadMiddleware(req, res, next) {
  upload(req, res, (err) => {
    if (err) {
      if (err instanceof multer.MulterError) {
        if (err.code === 'LIMIT_FILE_SIZE') {
          return next(
            new UploadError(
              'File size exceeds the 5 MB limit',
              413,
              'FILE_TOO_LARGE'
            )
          );
        }
        if (err.code === 'LIMIT_UNEXPECTED_FILE') {
          return next(
            new UploadError(
              `Unexpected field '${err.field}'. Expected 'receipt'`,
              400,
              'UNEXPECTED_FIELD'
            )
          );
        }
        return next(new UploadError(err.message, 400, 'UPLOAD_ERROR'));
      }
      return next(err);
    }

    if (!req.file) {
      return next(
        new UploadError(
          "Receipt file is required. Send a multipart/form-data request with field 'receipt'",
          400,
          'MISSING_FILE'
        )
      );
    }

    // Deep inspection: verify file buffer magic bytes match declared and allowed MIME type
    if (!isAllowedImageType(req.file.buffer, req.file.mimetype)) {
      return next(
        new UploadError(
          'File content does not match allowed image formats (JPEG, PNG, WebP)',
          415,
          'UNSUPPORTED_MEDIA_TYPE'
        )
      );
    }

    next();
  });
}

module.exports = uploadMiddleware;
