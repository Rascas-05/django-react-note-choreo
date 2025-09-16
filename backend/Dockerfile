# =====================================
# 1) Builder Stage (Python 3.12-slim)
# =====================================
FROM python:3.12-slim AS builder

# Prevent Python from writing .pyc files and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install build deps temporarily
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies into a wheel cache
COPY backend/requirements.txt .
RUN pip install --upgrade pip && pip wheel --no-cache-dir --no-deps -r requirements.txt -w /wheels


# =====================================
# 2) Runtime Stage (slim, secure, non-root)
# =====================================
FROM python:3.12-slim

# Create non-root user
RUN addgroup --system django && adduser --system --ingroup django django

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Copy wheels from builder and install
COPY --from=builder /wheels /wheels
COPY backend/requirements.txt .
RUN pip install --no-cache-dir /wheels/* && rm -rf /wheels

# Copy Django project code
COPY backend/ .

# Make entrypoint executable
RUN chmod +x /app/entrypoint.sh

# Switch to non-root user
USER django

# Expose Django port
EXPOSE 8000

# Entry command runs migrations + static + gunicorn
ENTRYPOINT ["/app/entrypoint.sh"]