### -------------------------
### Stage 1: Build with Node
### -------------------------
FROM node:20-alpine AS builder

# Update Alpine packages to patch vulnerabilities
RUN apk update && apk upgrade --no-cache

# Set working directory inside container
WORKDIR /app/frontend

# Install pnpm globally (optional safeguard)
RUN npm install -g pnpm

# Copy only the frontend folder
COPY frontend/ ./

# Install dependencies (lockfile-aware) + build
RUN if [ -f "package-lock.json" ]; then npm ci; \
    elif [ -f "yarn.lock" ]; then yarn install --frozen-lockfile; \
    elif [ -f "pnpm-lock.yaml" ]; then pnpm install --frozen-lockfile; \
    else echo "No lockfile found, using yarn" && yarn install; \
    fi \
    && yarn build

### -------------------------
### Stage 2: Serve with nginx
### -------------------------
FROM choreoanonymouspullable.azurecr.io/nginxinc/nginx-unprivileged:stable-alpine-slim

ENV ENABLE_PERMISSIONS=TRUE
ENV DEBUG_PERMISSIONS=TRUE
ENV USER_NGINX=10015
ENV GROUP_NGINX=10015

# Copy SPA nginx config (must exist in repo: frontend/default.conf)
COPY frontend/default.conf /etc/nginx/conf.d/default.conf

# Copy built Vite output (correct folder: /frontend/dist)
COPY --from=builder /app/frontend/dist /usr/share/nginx/html/

USER nginx
EXPOSE 8080