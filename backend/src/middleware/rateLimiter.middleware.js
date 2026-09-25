'use strict';

const rateLimit = require('express-rate-limit');
const { env } = require('../config/env');
const { RateLimitError } = require('../errors/AppError');

const scanRateLimiter = rateLimit({
  windowMs: env.SCAN_RATE_LIMIT_WINDOW_SECONDS * 1000,
  max: env.SCAN_RATE_LIMIT_MAX,
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res, next) => {
    next(
      new RateLimitError(
        `Rate limit exceeded. Maximum ${env.SCAN_RATE_LIMIT_MAX} scans per ${env.SCAN_RATE_LIMIT_WINDOW_SECONDS} seconds.`
      )
    );
  },
});

module.exports = {
  scanRateLimiter,
};
