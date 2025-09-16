###############################
# Frontend (Vite + React)
###############################
FROM node:22.15.0-alpine AS frontend-builder

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


###############################
# Backend (Django)
###############################
FROM python:3.11-slim AS backend

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy backend dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy Django project
COPY . .

# Collect static files (Django)
RUN python manage.py collectstatic --noinput


###############################
# Final NGINX image (serving frontend)
###############################
FROM choreoanonymouspullable.azurecr.io/nginxinc/nginx-unprivileged:stable-alpine-slim

# Setup env
ENV ENABLE_PERMISSIONS=TRUE
ENV DEBUG_PERMISSIONS=TRUE
ENV USER_NGINX=10015
ENV GROUP_NGINX=10015

# Copy custom nginx config (you must provide this in root dir)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy Vite-built frontend into nginx
COPY --from=frontend-builder /app/frontend/dist /usr/share/nginx/html/

# Copy Django staticfiles into nginx (so CSS/JS/images collected by Django are also served)
COPY --from=backend /app/staticfiles /usr/share/nginx/html/static/

USER nginx
