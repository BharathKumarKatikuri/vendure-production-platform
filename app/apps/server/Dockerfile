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

RUN npm ci \
    --workspace=server \
    --include-workspace-root

# Copy only the Vendure server workspace source.
COPY apps/server ./apps/server

# In the server workspace, "build" runs:
# vendure build all
#
# It produces the server, worker and dashboard builds.
RUN npm run build -w server


# --------------------------------------------------
# Stage 2: Prepare production dependencies
# --------------------------------------------------
FROM build AS production-deps

ENV NODE_ENV=production

# Remove development-only dependencies after the application
# has already been compiled.
#
# This avoids performing another full npm ci in an independent
# runtime stage.
RUN npm prune \
    --omit=dev \
    --workspace=server \    
    --include-workspace-root \
    && mkdir -p /app/apps/server/node_modules

# ---------------------------------------------------
# Stage 3: Production runtime  
# ---------------------------------------------------

FROM node:20-bookworm-slim AS runtime

WORKDIR /app

ENV NODE_ENV=production

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libgnutls30 \
        libcap2 \
    && rm -rf /var/lib/apt/lists/* 
    
RUN rm -rf /usr/local/lib/node_modules/npm \
    && rm -f /usr/local/bin/npm /usr/local/bin/npx

# Copy package metadata.
COPY --from=production-deps --chown=node:node \
    /app/package.json \
    /app/package-lock.json \
    ./


COPY --from=production-deps --chown=node:node \
    /app/apps/server/package.json \
    ./apps/server/package.json

# Copy the already-pruned production dependency tree.
#
# npm workspaces hoist most dependencies to /app/node_modules,
# but some dependencies can remain inside the server workspace,
# so both locations are preserved.
COPY --from=production-deps --chown=node:node \
    /app/node_modules \
    ./node_modules

COPY --from=production-deps --chown=node:node \
    /app/apps/server/node_modules \
    ./apps/server/node_modules

RUN rm -rf \
    /app/node_modules/esbuild \
    /app/node_modules/@esbuild \
    /app/node_modules/next \
    /app/node_modules/sharp

# Copy the compiled Vendure output.
COPY --from=build --chown=node:node \
    /app/apps/server/dist \
    ./apps/server/dist

# Copy runtime assets and email templates.
COPY --from=build --chown=node:node \
    /app/apps/server/static \
    ./apps/server/static

# Ensure writable runtime directories exist.
RUN mkdir -p \
    /app/apps/server/static/assets \
    /app/apps/server/static/email/test-emails \
    && chown -R node:node /app/apps/server/static

# Never run the application as root.
USER node

# Vendure API port.
EXPOSE 3000

# Default ECS process = Vendure API.
# The ECS Worker task will override this command with:
# node apps/server/dist/index-worker.js
CMD ["node", "apps/server/dist/index.js"]


