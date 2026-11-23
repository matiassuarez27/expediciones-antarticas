"""Acceso a datos: consultas parametrizadas y transacciones SQLAlchemy."""
from sqlalchemy import text
from db.connection import engine


def query(sql, params=None):
    with engine.connect() as conn:
        return conn.execute(text(sql), params or {}).mappings().all()


def scalar(sql, params=None):
    with engine.connect() as conn:
        value = conn.execute(text(sql), params or {}).scalar()
        return value if value is not None else 0


def execute(sql, params=None):
    """Ejecuta una sentencia en una transacción y devuelve lastrowid."""
    with engine.begin() as conn:
        result = conn.execute(text(sql), params or {})
        return result.lastrowid


def execute_many(statements):
    """Ejecuta varias sentencias atómicas. Revierte todo si una falla.

    statements: iterable de tuplas (sql, parámetros). Devuelve los lastrowid.
    """
    ids = []
    with engine.begin() as conn:
        for sql, params in statements:
            result = conn.execute(text(sql), params or {})
            ids.append(result.lastrowid)
    return ids
