#!/bin/sh

# Exit immediately if a command fails
set -e

echo "🎯 Running database migrations..."
python manage.py migrate --noinput

echo "🎯 Collecting static files..."
python manage.py collectstatic --noinput

echo "✅ Starting Gunicorn..."
#exec gunicorn myproject.wsgi:application --bind 0.0.0.0:8000
# Choreo project name = "Django-React-Note"
exec gunicorn Django-React-Note.wsgi:application --bind 0.0.0.0:8000
#(👉 replace myproject.wsgi with your actual project name)

Make it executable locally:
chmod +x backend/entrypoint.sh
