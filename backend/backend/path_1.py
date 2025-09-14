import os
from pathlib import Path
from dotenv import load_dotenv, dotenv_values
load_dotenv()

ALLOWED_HOSTS = []

frontend_server = os.getenv("FRONTEND_SERVER")
backend_server = os.getenv("BACKEND_SERVER")

if frontend_server:
    ALLOWED_HOSTS.append(Path(frontend_server))
if backend_server:
    ALLOWED_HOSTS.append(Path(backend_server))

print(ALLOWED_HOSTS)