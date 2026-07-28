# syntax=docker/dockerfile:1

# --------------------------------------------------
# Stage 1: Build the Vendure server, worker and dashboard
# --------------------------------------------------
FROM node:20-bookworm-slim AS build

WORKDIR /app

ENV NODE_ENV=development

# Copy workspace manifests first.
# This allows Docker to cache npm dependency installation.
COPY package.json package-lock.json ./
COPY apps/server/package.json ./apps/server/package.json
COPY apps/storefront/package.json ./apps/storefront/package.json

RUN npm ci

# Copy only the Vendure server workspace source.
COPY apps/server ./apps/server

# In the server workspace, "build" runs:
# vendure build all
#
# It produces the server, worker and dashboard builds.
RUN npm run build -w server


# --------------------------------------------------
# Stage 2: Production runtime
# --------------------------------------------------
FROM node:20-bookworm-slim AS runtime

WORKDIR /app

ENV NODE_ENV=production

# Install only the production dependencies required
# by the server workspace.
COPY package.json package-lock.json ./
COPY apps/server/package.json ./apps/server/package.json
COPY apps/storefront/package.json ./apps/storefront/package.json

RUN npm ci \
    --omit=dev \
    --workspace=server \
    --include-workspace-root \
    && npm cache clean --force

# Copy the compiled Vendure output.
COPY --from=build --chown=node:node \
    /app/apps/server/dist \
    ./apps/server/dist

# Copy runtime assets and email templates.
COPY --from=build --chown=node:node \
    /app/apps/server/static \
    ./apps/server/static

RUN mkdir -p \
    /app/apps/server/static/assets \
    /app/apps/server/static/email/test-emails \
    && chown -R node:node /app/apps/server/static

# Run the application as the non-root Node user.
USER node

# Vendure commonly listens on port 3000.
# The real runtime port will be checked against vendure-config.
EXPOSE 3000

# Default process: Vendure API server.
# ECS Worker will override this command.
CMD ["node", "apps/server/dist/index.js"]
