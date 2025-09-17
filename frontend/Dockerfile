# Multi-stage build for React frontend + Django backend
FROM node:22.15.0-alpine AS builder

# Build React frontend
WORKDIR /app/frontend
COPY frontend/package.json frontend/yarn.lock ./
RUN yarn install --frozen-lockfile

COPY frontend/ ./
RUN yarn build

# Django backend stage
FROM python:3.11-slim AS backend

WORKDIR /app

# Install Python dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy Django backend
COPY . .

# Copy built React files from frontend stage
COPY --from=builder /app/frontend/dist ./static/

# Expose port
EXPOSE 8000

# Run Django with Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "your_project.wsgi:application"]