# Stage 1 - Build Frontend
FROM node:20-bookworm-slim as frontend-build
WORKDIR /app

# Copy package files
COPY package.json yarn.lock ./
COPY .yarn ./.yarn
COPY .yarnrc.yml ./

# Copy source code
COPY packages/app/ ./packages/app/
COPY packages/backend/ ./packages/backend/

# Install dependencies and build frontend
RUN yarn install --immutable
RUN yarn workspace app build

# Stage 2 - Build Backend
FROM node:20-bookworm-slim as backend-build

# Set Python interpreter for node-gyp
ENV PYTHON=/usr/bin/python3

# Install build dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    g++ \
    build-essential \
    libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files
COPY package.json yarn.lock ./
COPY .yarn ./.yarn
COPY .yarnrc.yml ./

# Copy source code
COPY packages/backend/ ./packages/backend/

# Build backend
RUN yarn install --immutable
RUN yarn workspace backend build

# Stage 3 - Production Runtime
FROM node:20-bookworm-slim

# Set Python interpreter for node-gyp
ENV PYTHON=/usr/bin/python3
ENV NODE_ENV=production
ENV NODE_OPTIONS="--no-node-snapshot"

# Install runtime dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files
COPY package.json yarn.lock ./
COPY .yarn ./.yarn
COPY .yarnrc.yml ./

# Copy built frontend from stage 1
COPY --from=frontend-build /app/packages/app/dist ./packages/app/dist

# Copy built backend from stage 2
COPY --from=backend-build /app/packages/backend/dist ./packages/backend/dist

# Copy config files
COPY app-config*.yaml ./

# Install production dependencies
RUN yarn install --immutable --production

# Switch to non-root user
USER node

# Expose ports
EXPOSE 3000 7007

# Start the application
CMD ["yarn", "start"]