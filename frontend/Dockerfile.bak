# Stage 1: Build the Vite frontend
FROM node:22.15.0-alpine AS builder

# Set working directory
WORKDIR /app

# Copy dependency files for caching
COPY package*.json yarn.lock* pnpm-lock.yaml* ./

# Install dependencies using whichever lockfile exists
RUN npm install -g pnpm && \
    if [ -f "./package-lock.json" ]; then npm ci --only=production; \
    elif [ -f "./yarn.lock" ]; then yarn install --frozen-lockfile; \
    elif [ -f "./pnpm-lock.yaml" ]; then pnpm install --frozen-lockfile; \
    else npm install; fi

# Copy rest of the frontend source code
COPY . .

# Build Vite frontend (outputs to /app/dist)
RUN yarn build

# Stage 2: Serve with Nginx unprivileged
FROM choreoanonymouspullable.azurecr.io/nginxinc/nginx-unprivileged:stable-alpine-slim

# Choreo requires UID between 10000–20000
ENV ENABLE_PERMISSIONS=TRUE
ENV DEBUG_PERMISSIONS=TRUE

# Copy nginx configuration (if you keep one in frontend/default.conf)
COPY --from=builder /app/default.conf /etc/nginx/conf.d/default.conf

# Copy built frontend files
COPY --from=builder /app/dist /usr/share/nginx/html/

# Fix ownership, then drop privileges
USER root
RUN chown -R 10015:10015 /usr/share/nginx/html/ && \
    chmod -R 755 /usr/share/nginx/html/

# ✅ Required by CKV_CHOREO_1
USER 10015

# Expose nginx-unprivileged default port
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
