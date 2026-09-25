'use strict';

const app = require('./app');
const { env, loadEnv } = require('./config/env');
const logger = require('./utils/logger');

// Execute startup configuration validation
try {
  loadEnv();
} catch (err) {
  process.exit(1);
}

const server = app.listen(env.PORT, () => {
  logger.info(`Finance App REST API started successfully`, {
    port: env.PORT,
    environment: env.NODE_ENV,
    model: env.GEMINI_MODEL,
  });
});

let isShuttingDown = false;

function gracefulShutdown(signal) {
  if (isShuttingDown) {
    return;
  }
  isShuttingDown = true;
  logger.info(`Received ${signal}. Starting graceful shutdown...`);

  // Force exit if graceful shutdown takes longer than 10 seconds
  const forceExitTimeout = setTimeout(() => {
    logger.error('Graceful shutdown timed out. Forcing process termination.');
    process.exit(1);
  }, 10000);

  forceExitTimeout.unref();

  server.close((err) => {
    if (err) {
      logger.error('Error occurred while closing HTTP server', { error: err.message });
      process.exit(1);
    }
    logger.info('HTTP server closed cleanly. Process terminating.');
    process.exit(0);
  });
}

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

process.on('unhandledRejection', (reason) => {
  logger.error('Unhandled Promise Rejection', {
    reason: reason instanceof Error ? reason.message : reason,
    stack: reason instanceof Error ? reason.stack : undefined,
  });
});

process.on('uncaughtException', (err) => {
  logger.error('Uncaught Exception thrown', {
    error: err.message,
    stack: err.stack,
  });
  process.exit(1);
});
