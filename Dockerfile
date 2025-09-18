### --- Frontend Build Stage ---
FROM node:20.19.1-bullseye-slim as frontend-builder

WORKDIR /frontend

# Install deps
COPY frontend/package*.json ./
RUN npm install

# Copy source and build
COPY frontend/ .
RUN npm run build


### --- Backend Stage ---
FROM python:3.11-slim AS backend

WORKDIR /app

# Install system deps (helpful for psycopg2/Pillow/etc.)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libpq-dev gcc && \
    rm -rf /var/lib/apt/lists/*

# Copy backend requirements and install
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend project
COPY backend/ .

# Copy built frontend into Django static dir
COPY --from=frontend-builder /frontend/dist ./frontend_dist

# Collect static assets
RUN python manage.py collectstatic --noinput

# Add non-root user (Choreo policy: UID between 10000-20000)
RUN adduser -u 10001 --disabled-password --gecos "" appuser
USER 10001

# Gunicorn entrypoint
CMD ["gunicorn", "backend.wsgi:application", "--bind", "0.0.0.0:8000"]