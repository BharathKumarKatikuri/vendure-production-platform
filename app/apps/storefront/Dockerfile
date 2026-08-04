# Stage 1: Build the Next.js Storefront
FROM node:20-bookworm-slim AS build

WORKDIR /app

# Copy workspace manifest files
COPY package.json package-lock.json ./
COPY apps/server/package.json ./apps/server/package.json
COPY apps/storefront/package.json ./apps/storefront/package.json

# Install exact locked dependencies
RUN npm ci

# Copy Storefront source
COPY apps/storefront ./apps/storefront

# Vendure API required while Next.js prerenders pages
ARG VENDURE_SHOP_API_URL

RUN test -n "$VENDURE_SHOP_API_URL" || \
    (echo "VENDURE_SHOP_API_URL build argument is required" && exit 1)


# Build the production Storefront
RUN VENDURE_SHOP_API_URL="$VENDURE_SHOP_API_URL" \
    npm run build -w storefront


# Stage 2 production runtime
FROM node:20-bookworm-slim AS runtime

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3001
ENV HOSTNAME=0.0.0.0

COPY --from=build --chown=node:node \
    /app/apps/storefront/.next/standalone \
    ./

COPY --from=build --chown=node:node \
    /app/apps/storefront/.next/static \
    ./apps/storefront/.next/static

COPY --from=build --chown=node:node \
    /app/apps/storefront/public \
    ./apps/storefront/public

USER node

EXPOSE 3001

CMD ["node", "apps/storefront/server.js"]
