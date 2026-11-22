# Sistema Integral de Gestión de Expediciones Científicas en la Antártida

Aplicación web desarrollada con Python 3.12, Streamlit, SQLAlchemy, PyMySQL, MySQL 8.4 y Docker Compose.

## Alcance de esta etapa

- Pantalla de inicio con conteo de expediciones y muestras activas, además de listados básicos.
- Formulario para registrar expediciones: código, base científica existente, fecha de inicio, duración y capacidad máxima.
- Administración de bases científicas: crear, consultar, modificar y desactivar.
- Administración de muestras: crear, consultar, modificar y desactivar, manteniendo su clasificación biológica, geológica o climática.
- Consultas SQL parametrizadas y transacciones para operaciones que afectan más de una tabla.
- Separación en tres capas: interfaz (`main.py`), lógica de negocio (`services/`) y acceso a datos (`db/`).

Esta entrega no implementa inicio de sesión, roles, administración de usuarios ni dashboard con gráficos.

## Estructura

```text
expediciones_antarticas/
├── main.py
├── db/
│   ├── connection.py
│   ├── dao.py
│   └── schema.sql
├── services/
│   └── expeditions.py
├── tests/
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
└── .env.example
```

## Requisitos

- Docker Desktop o Docker Engine con Docker Compose.
- Puerto 8501 disponible para Streamlit.
- Puerto 3307 disponible en el equipo para publicar MySQL (internamente MySQL usa 3306).

## Configuración y ejecución

1. Descomprime el proyecto.
2. Copia `.env.example` a `.env`.
3. Cambia las contraseñas de ejemplo en `.env`. Mantén `DB_HOST=db` para la conexión entre contenedores.
4. Desde la carpeta del proyecto ejecuta:

```bash
docker compose up -d --build
docker compose ps
docker compose logs -f app
```

5. Abre `http://localhost:8501`.

## Funcionalidades a verificar

1. En Inicio, comprobar el resumen y los listados.
2. En Registrar expedición, registrar una expedición asociada a una base activa.
3. En Administrar bases, crear una base vinculada a un país existente, modificarla y desactivarla.
4. En Administrar muestras, crear muestras de las tres clasificaciones, modificar sus datos y desactivarlas.
5. Confirmar en MySQL que las operaciones se guardan correctamente.

## Persistencia y reinicio

El volumen `mysql_data` conserva la información. `db/schema.sql` se ejecuta automáticamente solo al inicializar un volumen vacío. No ejecutes `docker compose down -v` si necesitas conservar datos: ese comando elimina el volumen de MySQL.

Para detener los contenedores sin borrar la base:

```bash
docker compose down
```

Para volver a iniciar:

```bash
docker compose up -d
```

## Pruebas

Con Python 3.12 y las dependencias instaladas:

```bash
python -m pytest -q
python -m compileall -q .
```

Las pruebas unitarias verifican validaciones de negocio sin modificar la base de datos. La integración real debe probarse con Docker y una instancia MySQL disponible.

## Git

```bash
git init
git add .
git commit -m "Implementa gestión de expediciones antárticas"
```

No subas el archivo `.env` al repositorio.

## Nota sobre el esquema

Se conservaron los nombres y las columnas del `db/schema.sql` incluido en el proyecto: `base_cientifica`, `muestra`, `muestra_biologica`, `muestra_geologica`, `muestra_climatica`, `pais` y `expedicion`. Las columnas `activo` existen en `base_cientifica` y `muestra`, por lo que la baja lógica utiliza `activo=0` y preserva las relaciones históricas.
