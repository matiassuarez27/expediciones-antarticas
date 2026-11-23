"""Configuración de conexión SQLAlchemy para MySQL y TiDB Cloud."""
import os
from pathlib import Path

import streamlit as st
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

# Leer los Secrets de Streamlit; si no existen, usar variables locales.
try:
    secrets = st.secrets
except Exception:
    secrets = {}

user = secrets.get("DB_USER", os.getenv("DB_USER", "root"))
password = secrets.get("DB_PASSWORD", os.getenv("DB_PASSWORD", ""))
host = secrets.get("DB_HOST", os.getenv("DB_HOST", "localhost"))
port = int(secrets.get("DB_PORT", os.getenv("DB_PORT", "3306")))
database = secrets.get(
    "DB_NAME", os.getenv("DB_NAME", "expediciones_antarticas")
)

# Crear la URL de conexión de forma segura.
url = URL.create(
    "mysql+pymysql",
    username=user,
    password=password,
    host=host,
    port=port,
    database=database,
    query={"charset": "utf8mb4"},
)

# Activar verificación SSL cuando se utiliza TiDB Cloud.
connect_args = {}

if "tidbcloud.com" in host:
    ca_file = Path(_file_).resolve().parent / "isrgrootx1.pem"

    if not ca_file.exists():
        raise FileNotFoundError(
            f"No se encontró el certificado SSL: {ca_file}"
        )

    connect_args = {
        "ssl": {"ca": str(ca_file)},
        "ssl_verify_cert": True,
        "ssl_verify_identity": True,
    }

engine = create_engine(
    url,
    pool_pre_ping=True,
    pool_recycle=1800,
    connect_args=connect_args,
    future=True,
)