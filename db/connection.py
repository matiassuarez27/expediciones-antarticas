"""Configuración de conexión SQLAlchemy para MySQL 8.4."""
import os
from sqlalchemy import create_engine

user = os.getenv("DB_USER", "root")
password = os.getenv("DB_PASSWORD", "")
host = os.getenv("DB_HOST", "localhost")
port = os.getenv("DB_PORT", "3306")
database = os.getenv("DB_NAME", "expediciones_antarticas")

url = f"mysql+pymysql://{user}:{password}@{host}:{port}/{database}?charset=utf8mb4"
engine = create_engine(url, pool_pre_ping=True, pool_recycle=1800, future=True)
