### -------------------------
### Stage 1: Build Frontend (Vite)
### -------------------------
FROM node:22-alpine AS frontend-builder

WORKDIR /app/frontend

# Install pnpm globally
RUN npm install -g pnpm

# Copy frontend source
COPY frontend/ ./

# Install deps and build
RUN yarn install --frozen-lockfile && yarn build

### -------------------------
### Stage 2: Build Backend (Django)
### -------------------------
FROM python:3.11-slim-bullseye AS backend-builder

WORKDIR /app

# Install system dependencies and update packages to latest security patches
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev && \
    apt-get dist-upgrade -y && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy Django source
COPY . .

# Collect static files (Django admin, etc.)
RUN python manage.py collectstatic --noinput

### -------------------------
### Stage 3: Production (nginx + Django)
### -------------------------
FROM python:3.11-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    libpq5 \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Copy Python dependencies from backend builder
COPY --from=backend-builder /usr/local/lib/python3.11/site-packages/ /usr/local/lib/python3.11/site-packages/
COPY --from=backend-builder /usr/local/bin/ /usr/local/bin/

# Copy Django app
COPY --from=backend-builder /app/ /app/

# Copy built frontend to nginx html directory
COPY --from=frontend-builder /app/frontend/dist /usr/share/nginx/html/

# Copy nginx config for SPA + API proxy
COPY nginx-combined.conf /etc/nginx/sites-available/default

# Copy supervisor config to manage both services
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create nginx user and set permissions
RUN chown -R www-data:www-data /usr/share/nginx/html/ \
    && chown -R www-data:www-data /var/log/nginx/ \
    && chown -R www-data:www-data /var/lib/nginx/

# Expose port
EXPOSE 8080

# Start supervisor (manages nginx + Django)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]