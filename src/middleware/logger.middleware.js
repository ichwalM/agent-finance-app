'use strict';

const logger = require('../utils/logger');

function loggerMiddleware(req, res, next) {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;
    const { method, originalUrl } = req;
    const { statusCode } = res;

    const level = statusCode >= 500 ? 'error' : statusCode >= 400 ? 'warn' : 'info';

    logger[level](`${method} ${originalUrl} ${statusCode} - ${duration}ms`, {
      method,
      path: originalUrl,
      status: statusCode,
      duration: `${duration}ms`,
      durationMs: duration,
      requestId: req.id,
    });
  });

  next();
}

module.exports = loggerMiddleware;
