'use strict';

const { ZodError } = require('zod');
const { AppError } = require('../errors/AppError');
const logger = require('../utils/logger');

function errorHandler(err, req, res, next) {
  // If headers already sent, delegate to default express error handler
  if (res.headersSent) {
    return next(err);
  }

  let statusCode = 500;
  let code = 'INTERNAL_SERVER_ERROR';
  let message = 'An unexpected internal error occurred';
  let details = null;

  if (err instanceof AppError) {
    statusCode = err.statusCode;
    code = err.code;
    message = err.message;
    details = err.details || null;
  } else if (err instanceof ZodError) {
    statusCode = 400;
    code = 'VALIDATION_ERROR';
    message = 'Validation failed';
    details = err.issues.map((issue) => ({
      field: issue.path.join('.'),
      message: issue.message,
    }));
  } else if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    statusCode = 400;
    code = 'INVALID_JSON';
    message = 'Malformed JSON in request body';
  }

  // Log error with context, redacting any sensitive data
  logger.error(`Error: ${message}`, {
    code,
    statusCode,
    method: req.method,
    path: req.originalUrl,
    requestId: req.id,
    stack: process.env.NODE_ENV !== 'production' ? err.stack : undefined,
  });

  const responseBody = {
    success: false,
    error: {
      code,
      message,
    },
  };

  if (details) {
    responseBody.error.details = details;
  }

  res.status(statusCode).json(responseBody);
}

module.exports = errorHandler;
