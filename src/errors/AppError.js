'use strict';

class AppError extends Error {
  constructor(message, statusCode = 500, code = 'INTERNAL_SERVER_ERROR', details = null) {
    super(message);
    this.name = this.constructor.name;
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
    Error.captureStackTrace(this, this.constructor);
  }
}

class ValidationError extends AppError {
  constructor(message = 'Validation failed', details = null) {
    super(message, 400, 'VALIDATION_ERROR', details);
  }
}

class UploadError extends AppError {
  constructor(message = 'Upload failed', statusCode = 400, code = 'UPLOAD_ERROR') {
    super(message, statusCode, code);
  }
}

class GeminiError extends AppError {
  constructor(message = 'Failed to process receipt with Gemini Vision') {
    super(message, 502, 'GEMINI_ERROR');
  }
}

class GeminiTimeoutError extends AppError {
  constructor(message = 'Gemini Vision request timed out') {
    super(message, 504, 'GEMINI_TIMEOUT');
  }
}

class GoogleAppsScriptError extends AppError {
  constructor(message = 'Failed to communicate with Google Apps Script') {
    super(message, 502, 'GOOGLE_APPS_SCRIPT_ERROR');
  }
}

class GoogleAppsScriptTimeoutError extends AppError {
  constructor(message = 'Google Apps Script request timed out') {
    super(message, 504, 'GOOGLE_APPS_SCRIPT_TIMEOUT');
  }
}

class NetworkError extends AppError {
  constructor(message = 'Network connection failed') {
    super(message, 502, 'NETWORK_ERROR');
  }
}

class NotFoundError extends AppError {
  constructor(message = 'Resource not found') {
    super(message, 404, 'NOT_FOUND');
  }
}

class RateLimitError extends AppError {
  constructor(message = 'Rate limit exceeded. Please try again later.') {
    super(message, 429, 'TOO_MANY_REQUESTS');
  }
}

class StorageError extends AppError {
  constructor(message = 'Failed to interact with object storage') {
    super(message, 502, 'STORAGE_ERROR');
  }
}

module.exports = {
  AppError,
  ValidationError,
  UploadError,
  GeminiError,
  GeminiTimeoutError,
  GoogleAppsScriptError,
  GoogleAppsScriptTimeoutError,
  NetworkError,
  NotFoundError,
  RateLimitError,
  StorageError,
};
