# Stage 1: Base Python image
FROM python:3.11-slim AS base

# Prevents writing .pyc and enables unbuffered stdout
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set workdir
WORKDIR /app

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc curl netcat \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first (for caching)
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy Django project code
COPY . .

# Collect static files into /app/staticfiles
RUN python manage.py collectstatic --noinput

# Create unprivileged user that matches Choreo’s requirement (UID between 10000–20000)
RUN groupadd -g 10015 django && \
    useradd -m -u 10015 -g django django && \
    chown -R django:django /app

# Switch to secure user (✅ satisfies CKV_CHOREO_1)
USER 10015

# Expose Gunicorn/Django port
EXPOSE 8000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Start Gunicorn WSGI server (adjust module:app to your Django project)
# If your project is called "backend" with wsgi.py in backend/wsgi.py:
#CMD ["gunicorn", "--bind", "0.0.0.0:8000", "backend.wsgi:application"]
# Start Gunicorn WSGI server
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "DJANGO_REACT_NOTE_CHORIO.wsgi:application"]