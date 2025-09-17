# ================================
# Stage 1: Build React frontend
# ================================
FROM node:22.15.0-alpine AS builder

# Work inside frontend directory
WORKDIR /app/frontend

# Copy only package files to install deps
COPY frontend/package.json frontend/yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy full frontend source and build
COPY frontend/ ./
RUN yarn build


# ================================
# Stage 2: Django + Gunicorn + Nginx
# ================================
FROM python:3.11-slim AS final

# Install system deps: build tools + nginx
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# App directory
WORKDIR /app

# Copy and install Python requirements
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn

# Copy Django backend source code
COPY . .

# Copy React build output into static/
COPY --from=builder /app/frontend/dist ./static/

# Copy Nginx config
COPY nginx-combined.conf /etc/nginx/conf.d/default.conf

# Expose both Django (8000) and Nginx (80)
EXPOSE 8000 80

# Run nginx and Django (Gunicorn)
CMD service nginx start && gunicorn --bind 0.0.0.0:8000 your_project.wsgi:application