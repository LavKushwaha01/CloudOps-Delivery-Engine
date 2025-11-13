# 1️⃣ Build Stage
FROM node:22-alpine AS builder

WORKDIR /app

# Fix npm network issues
RUN npm config set registry https://registry.npmjs.org/ \
 && npm config set fetch-retry-maxtimeout 600000 \
 && npm config set fetch-retry-minTimeout 30000 \
 && npm config set fetch-timeout 600000 \
 && npm config set maxsockets 50

# Install dependencies
COPY ./my-app/package*.json ./
RUN npm ci

COPY my-app/ .

# Build Next.js
RUN npm run build

# 2️⃣ Run Stage (Production)
FROM node:22-alpine

WORKDIR /app

# Fix npm network issues
RUN npm config set registry https://registry.npmjs.org/ \
 && npm config set fetch-retry-maxtimeout 600000 \
 && npm config set fetch-retry-minTimeout 30000 \
 && npm config set fetch-timeout 600000 \
 && npm config set maxsockets 50

# Install only production deps
COPY ./my-app/package*.json ./
RUN npm ci --omit=dev

# Copy build files from previous stage
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.ts ./ 

EXPOSE 3000

CMD ["npm", "start"]
