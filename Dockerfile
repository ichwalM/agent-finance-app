# Stage 1: Install production dependencies
FROM node:22-alpine AS dependencies

WORKDIR /usr/src/app

COPY package*.json ./

# Install only production dependencies
RUN npm ci --omit=dev && npm cache clean --force

# Stage 2: Production runner
FROM node:22-alpine AS runner

WORKDIR /usr/src/app

ENV NODE_ENV=production

# Use standard non-root user provided by node alpine
USER node

# Copy package metadata and installed production node_modules
COPY --chown=node:node package*.json ./
COPY --chown=node:node --from=dependencies /usr/src/app/node_modules ./node_modules
COPY --chown=node:node src ./src

EXPOSE 3000

# Run node directly for proper SIGTERM/SIGINT handling
CMD ["node", "src/server.js"]
