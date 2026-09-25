'use strict';

/**
 * Detect the image MIME type by checking the initial buffer magic bytes.
 * Supports image/jpeg, image/png, and image/webp.
 *
 * @param {Buffer} buffer
 * @returns {string|null} Detected MIME type or null if unrecognized
 */
function detectImageMimeType(buffer) {
  if (!buffer || !Buffer.isBuffer(buffer) || buffer.length < 12) {
    return null;
  }

  // JPEG: starts with 0xFF, 0xD8, 0xFF
  if (buffer[0] === 0xff && buffer[1] === 0xd8 && buffer[2] === 0xff) {
    return 'image/jpeg';
  }

  // PNG: starts with 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A
  if (
    buffer[0] === 0x89 &&
    buffer[1] === 0x50 &&
    buffer[2] === 0x4e &&
    buffer[3] === 0x47 &&
    buffer[4] === 0x0d &&
    buffer[5] === 0x0a &&
    buffer[6] === 0x1a &&
    buffer[7] === 0x0a
  ) {
    return 'image/png';
  }

  // WebP: RIFF header (bytes 0-3: 0x52, 0x49, 0x46, 0x46) and WEBP identifier (bytes 8-11: 0x57, 0x45, 0x42, 0x50)
  if (
    buffer[0] === 0x52 &&
    buffer[1] === 0x49 &&
    buffer[2] === 0x46 &&
    buffer[3] === 0x46 &&
    buffer[8] === 0x57 &&
    buffer[9] === 0x45 &&
    buffer[10] === 0x42 &&
    buffer[11] === 0x50
  ) {
    return 'image/webp';
  }

  return null;
}

const ALLOWED_MIME_TYPES = new Set(['image/jpeg', 'image/png', 'image/webp']);

function isAllowedImageType(buffer, declaredMimeType) {
  const detected = detectImageMimeType(buffer);
  if (!detected || !ALLOWED_MIME_TYPES.has(detected)) {
    return false;
  }
  // Ensure the detected type matches or is consistent with declared MIME type
  if (declaredMimeType && declaredMimeType !== detected) {
    return false;
  }
  return true;
}

module.exports = {
  detectImageMimeType,
  isAllowedImageType,
  ALLOWED_MIME_TYPES,
};
