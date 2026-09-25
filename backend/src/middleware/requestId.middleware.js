'use strict';

const crypto = require('crypto');

function requestIdMiddleware(req, res, next) {
  const existingId = req.headers['x-request-id'];
  // Sanitize incoming request ID: alphanumeric, dash, underscore only, max 64 chars
  const validId =
    typeof existingId === 'string' &&
    existingId.trim().length > 0 &&
    existingId.length <= 64 &&
    /^[a-zA-Z0-9_-]+$/.test(existingId)
      ? existingId
      : crypto.randomUUID();

  req.id = validId;
  res.setHeader('X-Request-Id', validId);
  next();
}

module.exports = requestIdMiddleware;
