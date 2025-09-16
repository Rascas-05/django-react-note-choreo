###############################
# Frontend (Vite + React)
###############################
FROM node:22-alpine AS frontend-builder

# Set working dir
WORKDIR /app/frontend

# Copy only package files first (better caching for dependencies)
COPY frontend/package.json frontend/yarn.lock* frontend/pnpm-lock.yaml* ./

# Install deps (use pnpm/yarn/npm depending on your lockfile)
RUN if [ -f "./yarn.lock" ]; then yarn install; \
    elif [ -f "./pnpm-lock.yaml" ]; then pnpm install; \
    else npm install; \
    fi

# Copy all frontend code
COPY frontend/ .

# Build production static assets with Vite
RUN yarn build || npm run build || pnpm build
