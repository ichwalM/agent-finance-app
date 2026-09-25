'use strict';

const crypto = require('crypto');
const Minio = require('minio');
const { env } = require('../config/env');
const { StorageError } = require('../errors/AppError');
const logger = require('../utils/logger');

class StorageService {
  constructor() {
    this.enabled = env.STORAGE_ENABLED;
    this.bucket = env.MINIO_BUCKET;
    this.publicUrl = env.MINIO_PUBLIC_URL.replace(/\/$/, '');
    this._client = null;
    this._initialized = false;
  }

  getClient() {
    if (!this._client && this.enabled) {
      this._client = new Minio.Client({
        endPoint: env.MINIO_ENDPOINT,
        port: env.MINIO_PORT,
        useSSL: env.MINIO_USE_SSL,
        accessKey: env.MINIO_ROOT_USER,
        secretKey: env.MINIO_ROOT_PASSWORD,
      });
    }
    return this._client;
  }

  isEnabled() {
    return this.enabled;
  }

  /**
   * Ensure the target MinIO bucket exists and configure read access.
   */
  async ensureBucket() {
    if (!this.enabled || this._initialized) {
      return;
    }

    try {
      const client = this.getClient();
      const exists = await client.bucketExists(this.bucket);
      if (!exists) {
        logger.info(`Creating MinIO bucket: ${this.bucket}`);
        await client.makeBucket(this.bucket, 'us-east-1');

        // Set bucket policy to allow read access for uploaded receipts
        const policy = {
          Version: '2012-10-17',
          Statement: [
            {
              Effect: 'Allow',
              Principal: { AWS: ['*'] },
              Action: ['s3:GetObject'],
              Resource: [`arn:aws:s3:::${this.bucket}/*`],
            },
          ],
        };
        await client.setBucketPolicy(this.bucket, JSON.stringify(policy));
      }
      this._initialized = true;
    } catch (err) {
      logger.error('Failed to initialize MinIO bucket', { error: err.message });
      // Do not crash server, but log error
    }
  }

  /**
   * Upload an in-memory receipt image buffer to MinIO.
   *
   * @param {Buffer} buffer - Image file buffer
   * @param {string} mimeType - Image MIME type (image/jpeg, image/png, image/webp)
   * @param {string} originalName - Original filename
   * @returns {Promise<{ bucket: string, objectName: string, url: string, size: number }|null>}
   */
  async uploadReceipt(buffer, mimeType, originalName = 'receipt.jpg') {
    if (!this.enabled) {
      return null;
    }

    try {
      await this.ensureBucket();
      const client = this.getClient();

      const ext =
        mimeType === 'image/png'
          ? '.png'
          : mimeType === 'image/webp'
          ? '.webp'
          : '.jpg';

      const datePrefix = new Date().toISOString().slice(0, 10).replace(/-/g, '');
      const objectName = `${datePrefix}/${crypto.randomUUID()}${ext}`;

      const metaData = {
        'Content-Type': mimeType,
        'X-Original-Filename': encodeURIComponent(originalName || 'receipt'),
        'X-Uploaded-At': new Date().toISOString(),
      };

      await client.putObject(this.bucket, objectName, buffer, buffer.length, metaData);

      const url = `${this.publicUrl}/${this.bucket}/${objectName}`;

      logger.info('Receipt image stored in MinIO', {
        bucket: this.bucket,
        objectName,
        size: buffer.length,
      });

      return {
        bucket: this.bucket,
        objectName,
        url,
        size: buffer.length,
      };
    } catch (err) {
      logger.error('MinIO upload failed', { error: err.message });
      throw new StorageError(`Failed to save receipt image to storage: ${err.message}`);
    }
  }

  /**
   * Stream a receipt object directly from MinIO.
   */
  async getObjectStream(objectName) {
    if (!this.enabled) {
      throw new StorageError('Storage service is disabled');
    }
    const client = this.getClient();
    return client.getObject(this.bucket, objectName);
  }
}

const storageService = new StorageService();

module.exports = {
  StorageService,
  storageService,
};
