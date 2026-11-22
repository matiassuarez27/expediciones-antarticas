# Plan de pruebas

## Pruebas automatizadas

Con Python 3.12 y las dependencias de `requirements.txt` instaladas:

```bash
python -m pytest -q
python -m compileall -q .
```

Las pruebas unitarias cubren validaciones de duración, capacidad, campos obligatorios y clasificación de muestras. No insertan ni modifican datos en MySQL.

## Pruebas funcionales con Docker y MySQL

1. Ejecutar `docker compose up -d --build` y comprobar `docker compose ps`.
2. Revisar `docker compose logs db` hasta que MySQL esté listo.
3. Abrir `http://localhost:8501` y comprobar el resumen de expediciones y muestras.
4. Registrar una expedición asociada a una base científica activa.
5. Crear una base asociada a un país existente, modificarla y desactivarla.
6. Crear una muestra biológica, geológica y climática; comprobar que se crea el registro principal y su subtipo.
7. Modificar una muestra y cambiar su clasificación; comprobar que queda un solo subtipo asociado.
8. Desactivar una muestra y comprobar que ya no aparece entre las activas, pero conserva sus relaciones históricas.
9. Verificar en MySQL que los datos persisten tras detener y volver a iniciar los contenedores con `docker compose down` y `docker compose up -d`.

No utilizar `docker compose down -v` en una base con datos que se quieran conservar, porque elimina el volumen de MySQL.
