# Multi-stage build for React/Vite frontend with Nginx

# Stage 1: Build the frontend
FROM node:22.15.0-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files first for better caching
COPY package*.json yarn.lock* pnpm-lock.yaml* ./

# Install package manager and dependencies
RUN npm install -g pnpm && \
    if [ -f "./package-lock.json" ]; then npm ci --only=production; \
    elif [ -f "./yarn.lock" ]; then yarn install --frozen-lockfile; \
    elif [ -f "./pnpm-lock.yaml" ]; then pnpm install --frozen-lockfile; \
    else npm install; fi

# Copy source code
COPY . .

# Build the application (outputs to /app/dist)
RUN yarn build

# Stage 2: Serve with Nginx
FROM choreoanonymouspullable.azurecr.io/nginxinc/nginx-unprivileged:stable-alpine-slim

# Set environment variables for permissions
ENV ENABLE_PERMISSIONS=TRUE
ENV DEBUG_PERMISSIONS=TRUE
ENV USER_NGINX=10015
ENV GROUP_NGINX=10015

# Copy nginx configuration
COPY --from=builder /app/default.conf /etc/nginx/conf.d/default.conf

# Copy built frontend files from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html/

# Ensure proper ownership and permissions
USER root
RUN chown -R ${USER_NGINX}:${GROUP_NGINX} /usr/share/nginx/html/ && \
    chmod -R 755 /usr/share/nginx/html/

# Switch back to nginx user
USER nginx

# Expose port 8080 (nginx-unprivileged default)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Start nginx
