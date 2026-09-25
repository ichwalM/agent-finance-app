'use strict';

const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const { env } = require('./config/env');
const requestIdMiddleware = require('./middleware/requestId.middleware');
const loggerMiddleware = require('./middleware/logger.middleware');
const errorHandler = require('./middleware/error.middleware');
const apiRoutes = require('./routes');
const { NotFoundError, AppError } = require('./errors/AppError');

const app = express();

// Disable 'X-Powered-By' header for security
app.disable('x-powered-by');

// Trust reverse proxy if behind docker/nginx
app.set('trust proxy', 1);

// Set secure HTTP headers with Helmet
app.use(helmet());

// Configure CORS
const allowedOrigins = env.CORS_ORIGIN.split(',').map((o) => o.trim()).filter(Boolean);
const corsOptions = {
  origin: (origin, callback) => {
    // Allow requests with no origin (such as mobile apps, curl, or server-to-server)
    if (!origin) {
      return callback(null, true);
    }
    if (allowedOrigins.includes('*') || allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    return callback(
      new AppError(`Origin '${origin}' not allowed by CORS policy`, 403, 'CORS_FORBIDDEN')
    );
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-Id'],
};
app.use(cors(corsOptions));

// Assign Request ID
app.use(requestIdMiddleware);

// Structured HTTP Request Logger
app.use(loggerMiddleware);

// JSON body parser with strict size limit
app.use(express.json({ limit: '100kb' }));

// Mount all REST API endpoints under /api
app.use('/api', apiRoutes);

// Catch-all for undefined routes
app.use((req, res, next) => {
  next(new NotFoundError(`Route ${req.method} ${req.originalUrl} not found`));
});

// Centralized error handler
app.use(errorHandler);

module.exports = app;
