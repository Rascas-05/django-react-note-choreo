# Stage 1: Build the frontend with Node
FROM node:22.15.0-alpine AS builder

# Work inside frontend directory
WORKDIR /app/frontend

# Copy only package files to install deps
COPY frontend/package.json frontend/yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy dependency files first (for build caching)
#COPY package*.json yarn.lock* pnpm-lock.yaml* ./

# Install dependencies (auto-detect package manager)
RUN npm install -g pnpm && \
    if [ -f "./package-lock.json" ]; then npm ci --only=production; \
    elif [ -f "./yarn.lock" ]; then yarn install --frozen-lockfile; \
    elif [ -f "./pnpm-lock.yaml" ]; then pnpm install --frozen-lockfile; \
    else npm install; fi

# Copy the rest of the source code
COPY . .

# Build the Vite application (outputs to /app/dist)
RUN yarn build

# Stage 2: Serve with Nginx
FROM choreoanonymouspullable.azurecr.io/nginxinc/nginx-unprivileged:stable-alpine-slim

# Required envs (Choreo style)
ENV ENABLE_PERMISSIONS=TRUE
ENV DEBUG_PERMISSIONS=TRUE

# Copy nginx configuration
COPY --from=builder /app/default.conf /etc/nginx/conf.d/default.conf

# Copy built frontend
COPY --from=builder /app/dist /usr/share/nginx/html/

# Switch to root only for fixing ownership
USER root
RUN chown -R 10015:10015 /usr/share/nginx/html/ && \
    chmod -R 755 /usr/share/nginx/html/

# ✅ Explicit UID (passes CKV_CHOREO_1)
USER 10015

# Expose the default unprivileged nginx port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]