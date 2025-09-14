import os
from pathlib import Path
from dotenv import load_dotenv, dotenv_values
load_dotenv()

ALLOWED_HOSTS = [
    Path(server) for server in [
        os.getenv("FRONTEND_SERVER"),
        os.getenv("BACKEND_SERVER")
    ] if server is not None
]

print("ALLOWED_HOSTS:", ALLOWED_HOSTS)