# Build Stage
FROM node:22-alpine AS builder

WORKDIR /app


# Improve npm networking robustness 
RUN npm config set registry https://registry.npmjs.org/ \
 && npm config set fetch-retries 5 \
 && npm config set fetch-retry-factor 10 \
 && npm config set fetch-retry-mintimeout 10000 \
 && npm config set fetch-retry-maxtimeout 600000 \
 && npm config set fetch-timeout 600000 \
 && npm config set maxsockets 50

# Install dependencies
COPY ./my-app/package*.json ./
RUN npm ci

COPY my-app/ .

# Build Next.js
RUN npm run build

# Run Stage (Production)
FROM node:22-alpine

WORKDIR /app

# Set npm config again for production stage
RUN npm config set registry https://registry.npmjs.org/ \
 && npm config set fetch-retries 5 \
 && npm config set fetch-retry-factor 10 \
 && npm config set fetch-retry-mintimeout 10000 \
 && npm config set fetch-retry-maxtimeout 600000 \
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
