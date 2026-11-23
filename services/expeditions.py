"""Reglas de negocio del sistema de expediciones antárticas."""
from db.dao import query, scalar, execute


def summary():
    return {
        "expeditions": int(scalar("SELECT COUNT(*) FROM expedicion")),
        "samples": int(scalar("SELECT COUNT(*) FROM muestra WHERE activo = 1")),
    }


def bases():
    return query(
        "SELECT cod_base, nombre FROM base_cientifica "
        "WHERE activo = 1 ORDER BY nombre"
    )


def create_expedition(base_id, start_date, duration, capacity):
    if int(duration) < 1 or int(capacity) < 1:
        raise ValueError("La duración y la capacidad deben ser mayores que cero.")

    if not scalar(
        "SELECT COUNT(*) FROM base_cientifica WHERE cod_base=:id AND activo=1",
        {"id": int(base_id)}
    ):
        raise ValueError("La base seleccionada no existe o está inactiva.")

    execute(
        "INSERT INTO expedicion(cod_base,fecha_inicio,duracion,capacidad_maxima) "
        "VALUES(:base,:start,:duration,:capacity)",
        {
            "base": int(base_id),
            "start": start_date,
            "duration": int(duration),
            "capacity": int(capacity),
        },
    )


def list_bases():
    return query(
        "SELECT b.cod_base,b.nombre,b.ubicacion,b.capacidad_maxima,b.presupuesto,"
        "b.nivel_aislamiento,b.cod_pais,p.nombre_oficial AS pais "
        "FROM base_cientifica b JOIN pais p ON p.cod_pais=b.cod_pais "
        "WHERE b.activo=1 ORDER BY b.cod_base"
    )


def countries():
    return query("SELECT cod_pais,nombre_oficial FROM pais ORDER BY nombre_oficial")


def create_base(name, location, capacity, budget, isolation, country_id):
    if not name.strip() or not location.strip():
        raise ValueError("El nombre y la ubicación son obligatorios.")
    execute(
        "INSERT INTO base_cientifica(nombre,ubicacion,capacidad_maxima,presupuesto,nivel_aislamiento,cod_pais) "
        "VALUES(:name,:location,:capacity,:budget,:isolation,:country)",
        {"name": name.strip(), "location": location.strip(), "capacity": int(capacity),
         "budget": budget, "isolation": isolation.strip() or None, "country": int(country_id)},
    )


def update_base(base_id, name, location, capacity, budget, isolation, country_id):
    if not name.strip() or not location.strip():
        raise ValueError("El nombre y la ubicación son obligatorios.")
    execute(
        "UPDATE base_cientifica SET nombre=:name,ubicacion=:location,capacidad_maxima=:capacity,"
        "presupuesto=:budget,nivel_aislamiento=:isolation,cod_pais=:country WHERE cod_base=:id AND activo=1",
        {"name": name.strip(), "location": location.strip(), "capacity": int(capacity),
         "budget": budget, "isolation": isolation.strip() or None,
         "country": int(country_id), "id": int(base_id)},
    )


def deactivate_base(base_id):
    # Baja lógica para conservar relaciones históricas y evitar romper claves foráneas.
    execute("UPDATE base_cientifica SET activo=0 WHERE cod_base=:id AND activo=1", {"id": int(base_id)})


def list_samples():
    return query(
        "SELECT m.cod_muestra,m.nombre,m.descripcion,m.fecha_hallazgo,m.estado_conservacion,"
        "CASE WHEN mb.cod_muestra IS NOT NULL THEN 'Biológica' "
        "WHEN mg.cod_muestra IS NOT NULL THEN 'Geológica' "
        "WHEN mc.cod_muestra IS NOT NULL THEN 'Climática' ELSE 'Sin clasificar' END AS tipo,"
        "COALESCE(mb.atributo_especifico,mg.composicion,mc.variable_medida,'') AS detalle "
        "FROM muestra m LEFT JOIN muestra_biologica mb ON mb.cod_muestra=m.cod_muestra "
        "LEFT JOIN muestra_geologica mg ON mg.cod_muestra=m.cod_muestra "
        "LEFT JOIN muestra_climatica mc ON mc.cod_muestra=m.cod_muestra "
        "WHERE m.activo=1 ORDER BY m.cod_muestra"
    )


def create_sample(name, description, found_date, conservation, sample_type, detail):
    if not name.strip():
        raise ValueError("El nombre de la muestra es obligatorio.")
    subtype = {
        "Biológica": ("muestra_biologica", "atributo_especifico"),
        "Geológica": ("muestra_geologica", "composicion"),
        "Climática": ("muestra_climatica", "variable_medida"),
    }
    if sample_type not in subtype:
        raise ValueError("Debe seleccionar una clasificación válida.")
    table, column = subtype[sample_type]
    # El INSERT principal y el subtipo se confirman juntos o se revierten juntos.
    from db.connection import engine
    from sqlalchemy import text
    with engine.begin() as conn:
        result = conn.execute(text(
            "INSERT INTO muestra(nombre,descripcion,fecha_hallazgo,estado_conservacion) "
            "VALUES(:name,:description,:found,:conservation)"
        ), {"name": name.strip(), "description": description.strip() or None,
            "found": found_date, "conservation": conservation.strip() or None})
        sample_id = result.lastrowid
        conn.execute(text(f"INSERT INTO {table}(cod_muestra,{column}) VALUES(:id,:detail)"),
                     {"id": sample_id, "detail": detail.strip() or None})
    return sample_id


def update_sample(sample_id, name, description, found_date, conservation, sample_type, detail):
    if not name.strip():
        raise ValueError("El nombre de la muestra es obligatorio.")
    subtype = {
        "Biológica": ("muestra_biologica", "atributo_especifico"),
        "Geológica": ("muestra_geologica", "composicion"),
        "Climática": ("muestra_climatica", "variable_medida"),
    }
    if sample_type not in subtype:
        raise ValueError("Debe seleccionar una clasificación válida.")
    table, column = subtype[sample_type]
    from db.connection import engine
    from sqlalchemy import text
    with engine.begin() as conn:
        conn.execute(text(
            "UPDATE muestra SET nombre=:name,descripcion=:description,fecha_hallazgo=:found,"
            "estado_conservacion=:conservation WHERE cod_muestra=:id AND activo=1"
        ), {"name": name.strip(), "description": description.strip() or None,
            "found": found_date, "conservation": conservation.strip() or None, "id": int(sample_id)})
        # Garantiza un único subtipo: elimina clasificaciones anteriores y registra la elegida.
        for old_table in ("muestra_biologica", "muestra_geologica", "muestra_climatica"):
            conn.execute(text(f"DELETE FROM {old_table} WHERE cod_muestra=:id"), {"id": int(sample_id)})
        conn.execute(text(f"INSERT INTO {table}(cod_muestra,{column}) VALUES(:id,:detail)"),
                     {"id": int(sample_id), "detail": detail.strip() or None})


def deactivate_sample(sample_id):
    # Baja lógica para preservar recolecciones y trazabilidad científica.
    execute("UPDATE muestra SET activo=0 WHERE cod_muestra=:id AND activo=1", {"id": int(sample_id)})