'use strict';

const SENSITIVE_KEYS = new Set([
  'gemini_api_key',
  'api_key',
  'apikey',
  'key',
  'token',
  'secret',
  'authorization',
  'password',
  'buffer',
  'data',
]);

function sanitize(obj, depth = 0) {
  if (depth > 4 || obj === null || typeof obj !== 'object') {
    return obj;
  }

  if (Buffer.isBuffer(obj)) {
    return `[Buffer: ${obj.length} bytes]`;
  }

  if (Array.isArray(obj)) {
    return obj.map((item) => sanitize(item, depth + 1));
  }

  const sanitized = {};
  for (const [key, value] of Object.entries(obj)) {
    const lowerKey = key.toLowerCase();
    if (SENSITIVE_KEYS.has(lowerKey)) {
      sanitized[key] = '***REDACTED***';
    } else if (typeof value === 'object' && value !== null) {
      sanitized[key] = sanitize(value, depth + 1);
    } else {
      sanitized[key] = value;
    }
  }
  return sanitized;
}

function writeLog(level, message, meta = {}) {
  const logEntry = {
    timestamp: new Date().toISOString(),
    level,
    message,
    ...sanitize(meta),
  };

  const output = JSON.stringify(logEntry);
  if (level === 'error') {
    process.stderr.write(output + '\n');
  } else {
    process.stdout.write(output + '\n');
  }
}

const logger = {
  info: (message, meta) => writeLog('info', message, meta),
  warn: (message, meta) => writeLog('warn', message, meta),
  error: (message, meta) => writeLog('error', message, meta),
  debug: (message, meta) => {
    if (process.env.NODE_ENV !== 'production') {
      writeLog('debug', message, meta);
    }
  },
};

module.exports = logger;
