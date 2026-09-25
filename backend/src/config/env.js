'use strict';

const dotenv = require('dotenv');
const { z } = require('zod');

dotenv.config();

const isTest = process.env.NODE_ENV === 'test';

const booleanSchema = (defaultValue = false) =>
  z.preprocess((val) => {
    if (typeof val === 'string') {
      const lower = val.trim().toLowerCase();
      if (lower === 'true' || lower === '1') return true;
      if (lower === 'false' || lower === '0' || lower === '') return false;
    }
    if (val === undefined || val === null) return defaultValue;
    return Boolean(val);
  }, z.boolean());

const envSchema = z
  .object({
    NODE_ENV: z.enum(['development', 'production', 'test']).default('production'),
    PORT: z.coerce.number().int().positive().default(3000),

    // AI Provider Selection: 'gemini' | '9router'
    AI_PROVIDER: z.enum(['gemini', '9router']).default('gemini'),

    // Gemini Official API Configuration
    GEMINI_API_KEY: z
      .string()
      .default(isTest ? 'test-gemini-api-key' : ''),
    GEMINI_MODEL: z.string().min(1).default('gemini-1.5-flash'),
    GEMINI_TIMEOUT_MS: z.coerce.number().int().positive().default(30000),

    // 9Router API Configuration
    ROUTER9_BASE_URL: z
      .string()
      .url('ROUTER9_BASE_URL must be a valid URL')
      .default('https://agent.walldev.my.id/v1'),
    ROUTER9_API_KEY: z
      .string()
      .default(isTest ? 'test-9router-key' : ''),
    ROUTER9_MODEL: z.string().min(1).default('web-dev'),
    ROUTER9_TIMEOUT_MS: z.coerce.number().int().positive().default(30000),

    // Google Apps Script Configuration
    GAS_URL: z
      .string({
        required_error: 'GAS_URL is required and must be a valid URL',
      })
      .url('GAS_URL must be a valid URL')
      .default(
        isTest
          ? 'https://script.google.com/macros/s/AKfycbw9hjsnm4qsZWxOjbrx2UVxJVlS09DJ2l8f3bcpMeZS13zwezLWftsuQt_U76CyX8y0NA/exec'
          : undefined
      ),
    GAS_TIMEOUT_MS: z.coerce.number().int().positive().default(10000),

    // MinIO Object Storage Configuration
    STORAGE_ENABLED: booleanSchema(true),
    MINIO_ENDPOINT: z.string().default('minio'),
    MINIO_PORT: z.coerce.number().int().positive().default(9000),
    MINIO_USE_SSL: booleanSchema(false),
    MINIO_ROOT_USER: z.string().default('admin'),
    MINIO_ROOT_PASSWORD: z.string().default('password123'),
    MINIO_BUCKET: z.string().default('receipts'),
    MINIO_PUBLIC_URL: z.string().default('http://localhost:9000'),

    // CORS & Rate Limiter Configuration
    CORS_ORIGIN: z.string().default('http://localhost:3000'),
    SCAN_RATE_LIMIT_WINDOW_SECONDS: z.coerce.number().int().positive().default(60),
    SCAN_RATE_LIMIT_MAX: z.coerce.number().int().positive().default(10),
  })
  .superRefine((data, ctx) => {
    if (!isTest) {
      if (data.AI_PROVIDER === 'gemini' && (!data.GEMINI_API_KEY || data.GEMINI_API_KEY.trim() === '')) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['GEMINI_API_KEY'],
          message: 'GEMINI_API_KEY is required when AI_PROVIDER is set to gemini',
        });
      }
      if (data.AI_PROVIDER === '9router' && (!data.ROUTER9_API_KEY || data.ROUTER9_API_KEY.trim() === '')) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['ROUTER9_API_KEY'],
          message: 'ROUTER9_API_KEY is required when AI_PROVIDER is set to 9router',
        });
      }
    }
  });

function loadEnv() {
  const result = envSchema.safeParse(process.env);
  if (!result.success) {
    const issues = result.error.issues
      .map((issue) => ` - ${issue.path.join('.')}: ${issue.message}`)
      .join('\n');
    const errorMessage = `[STARTUP ERROR] Invalid environment configuration:\n${issues}`;
    if (!isTest) {
      console.error(errorMessage);
    }
    throw new Error(errorMessage);
  }
  return Object.freeze(result.data);
}

const env = loadEnv();

module.exports = {
  env,
  loadEnv,
};
