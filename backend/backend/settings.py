"""
Django settings for backend project.
Refactored to use django-environ for clean env management.
"""

from pathlib import Path
from datetime import timedelta
from urllib.parse import urlparse
import os
from dotenv import load_dotenv
import dj_database_url

# ------------------------------------
# Base paths
# ------------------------------------
BASE_DIR = Path(__file__).resolve().parent.parent

# ------------------------------------
# Security
# ------------------------------------
# Load environment variables from .env file
load_dotenv()

# Now use os.environ to access variables
DEBUG = os.environ.get('DEBUG', 'False').lower() == 'true'
SECRET_KEY = os.environ.get('SECRET_KEY', 'your-default-secret-key')

# ------------------------------------
# Hosting & Debug
# ------------------------------------
HOSTING_STATUS = os.environ.get("HOSTING_STATUS", default="DEVELOPMENT")  # DEVELOPMENT or PRODUCTION
SECRET_KEY = os.environ.get("DJANGO_SECRET_KEY", default="unsafe-secret-key")

DEBUG = os.environ.get("DJANGO_DEBUG", default=(HOSTING_STATUS != "PRODUCTION"))

# ------------------------------------
# Hosts
# ------------------------------------
ALLOWED_HOSTS = []

for env_host in [os.environ.get("FRONTEND_SERVER", default=None), os.environ.get("BACKEND_SERVER", default=None)]:
    if env_host:
        parsed = urlparse(env_host if "://" in env_host else f"http://{env_host}")
        if parsed.hostname:
            ALLOWED_HOSTS.append(parsed.hostname)

print("FINAL ALLOWED_HOSTS =", ALLOWED_HOSTS)

# ------------------------------------
# Binance API Keys
# ------------------------------------
USE_TESTNET = os.environ.get("BINANCE_TESTNET", default=True)

if USE_TESTNET:
    BINANCE_API_KEY = os.environ.get("BINANCE_TESTNET_API_KEY", default="")
    BINANCE_API_SECRET = os.environ.get("BINANCE_TESTNET_API_SECRET", default="")
    BINANCE_ENV = "TESTNET"
else:
    BINANCE_API_KEY = os.environ.get("BINANCE_MAINNET_API_KEY", default="")
    BINANCE_API_SECRET = os.environ.get("BINANCE_MAINNET_API_SECRET", default="")
    BINANCE_MAINNET_API_ACTIVATE_DATE = os.environ.get("BINANCE_MAINNET_API_ACTIVATE_DATE", default="")
    BINANCE_MAINNET_API_EXPIRY_DATE = os.environ.get("BINANCE_MAINNET_API_EXPIRY_DATE", default="")
    BINANCE_ENV = "MAINNET"

print(f"Using Binance {BINANCE_ENV} keys")

# ------------------------------------
# REST Framework / JWT
# ------------------------------------
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": (
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ),
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.IsAuthenticated",
    ],
}

SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=30),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=1),
}

# ------------------------------------
# Applications
# ------------------------------------
INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "api",
    "rest_framework",
    "corsheaders",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "corsheaders.middleware.CorsMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

# ------------------------------------
# CORS
# ------------------------------------
CORS_ALLOWED_ORIGINS = []
for server in [os.environ.get("FRONTEND_SERVER", default=None), os.environ.get("BACKEND_SERVER", default=None)]:
    if server:
        if not server.startswith("http"):
            server = "http://" + server
        CORS_ALLOWED_ORIGINS.append(server)

CORS_ALLOW_CREDENTIALS = True
CORS_PREFLIGHT_MAX_AGE = 0

print("CORS_ALLOWED_ORIGINS =", CORS_ALLOWED_ORIGINS)

# ------------------------------------
# URLs / WSGI
# ------------------------------------
ROOT_URLCONF = "backend.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "backend.wsgi.application"

# ------------------------------------
# Database (django-environ powered)
# ------------------------------------
# Hosted Choreo Database Configuration

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": os.environ.get("DB_NAME"),
        "USER": os.environ.get("DB_USER"),
        "PASSWORD": os.environ.get("DB_PWD"),
        "HOST": os.environ.get("DB_HOST"),
        "PORT": os.environ.get("DB_PORT"),
        "CONN_MAX_AGE": 600,
        "OPTIONS": {"sslmode": "require"},  # Uncomment if SSL is required
    }
}

# Check PORT
# ------------------------------------
# Password validation
# ------------------------------------
AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

# ------------------------------------
# Internationalization
# ------------------------------------
LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"
USE_I18N = True
USE_TZ = True

# ------------------------------------
# Static files
# ------------------------------------
STATIC_URL = "/static/"
STATIC_ROOT = os.path.join(BASE_DIR, "staticfiles")
# ------------------------------------
# Default primary key
# ------------------------------------
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# Optional logging (helps on Choreo logs)
LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
        },
    },
    "root": {
        "handlers": ["console"],
        "level": os.environ.get("DJANGO_LOG_LEVEL", "INFO"),
    },
}
