# Stage 1: Build React frontend
FROM node:20.19.1-bullseye-slim as frontend-builder
WORKDIR /frontend
COPY frontend/package*.json ./
RUN npm install --legacy-peer-deps
COPY frontend/ ./
RUN npm run build

# Stage 2: Django backend
FROM python:3.11-slim

# Create non-root user for security (Checkov compliance)
RUN addgroup --system app && adduser --system --ingroup app app

WORKDIR /app

# Install system deps
RUN apt-get update && apt-get install -y \
    build-essential libpq-dev gcc curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend explicitly (instead of `.`, which may mix frontend files)
COPY backend/ . 

# Copy Django project
#COPY . .

# Copy built React static files into Django static dir
COPY --from=frontend-builder /frontend/dist ./frontend_dist

# Collect static (including React frontend build into STATIC_ROOT)
RUN python manage.py collectstatic --noinput

# Change permissions
RUN chown -R app:app /app
USER app
# Create non-root user with UID 10001 - Otherwise Choreo build fails
RUN adduser -u 10001 --disabled-password --gecos "" appuser

# Switch to that user
USER 10001

EXPOSE 8000
CMD ["gunicorn", "myproject.wsgi:application", "--bind", "0.0.0.0:8000"]