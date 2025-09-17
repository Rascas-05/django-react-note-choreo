# -----------------------------
# Stage 1: Build React frontend
# -----------------------------
FROM node:22.15.0-alpine AS builder

WORKDIR /app/frontend

# Copy package and lockfiles from /frontend
COPY frontend/package.json frontend/yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy all frontend sources
COPY frontend/ ./

# Build React → dist
RUN yarn build


# -----------------------------
# Stage 2: Django + Gunicorn + Nginx
# -----------------------------
FROM python:3.11-slim AS final

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Python requirements
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn

# Copy Django backend
COPY . .

# Copy built React → served as static files
COPY --from=builder /app/frontend/dist ./static/

# Copy nginx config (combined)
COPY nginx-combined.conf /etc/nginx/conf.d/default.conf

# Expose ports
EXPOSE 8000 80

# Start both Django (gunicorn) + Nginx
CMD service nginx start && gunicorn --bind 0.0.0.0:8000 DJANGO_REACT_NOTE_CHORIO.wsgi:application