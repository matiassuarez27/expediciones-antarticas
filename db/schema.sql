CREATE DATABASE IF NOT EXISTS expediciones_antarticas CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE expediciones_antarticas;

CREATE TABLE IF NOT EXISTS pais (
 cod_pais INT AUTO_INCREMENT PRIMARY KEY, nombre_oficial VARCHAR(100) NOT NULL UNIQUE,
 organismo_responsable VARCHAR(150), presupuesto_anual DECIMAL(15,2) DEFAULT 0
);
CREATE TABLE IF NOT EXISTS base_cientifica (
 cod_base INT AUTO_INCREMENT PRIMARY KEY, nombre VARCHAR(120) NOT NULL, ubicacion VARCHAR(180) NOT NULL,
 fecha_instalacion DATE, capacidad_maxima INT NOT NULL DEFAULT 1, presupuesto DECIMAL(15,2) DEFAULT 0,
 nivel_aislamiento VARCHAR(40), activo TINYINT(1) NOT NULL DEFAULT 1,
 cod_pais INT NOT NULL, CONSTRAINT fk_base_pais FOREIGN KEY(cod_pais) REFERENCES pais(cod_pais)
);
CREATE TABLE IF NOT EXISTS sector_investigacion (
 cod_base INT NOT NULL, num_sector INT NOT NULL, nombre VARCHAR(120) NOT NULL,
 superficie DECIMAL(12,2), condiciones_climaticas VARCHAR(180), nivel_acceso VARCHAR(50),
 PRIMARY KEY(cod_base,num_sector), FOREIGN KEY(cod_base) REFERENCES base_cientifica(cod_base)
);
CREATE TABLE IF NOT EXISTS expedicion (
 cod_expedicion INT AUTO_INCREMENT PRIMARY KEY, fecha_inicio DATE NOT NULL, duracion INT NOT NULL,
 capacidad_maxima INT NOT NULL, cod_base INT NOT NULL, FOREIGN KEY(cod_base) REFERENCES base_cientifica(cod_base)
);
CREATE TABLE IF NOT EXISTS persona (
 id_persona INT AUTO_INCREMENT PRIMARY KEY, nombre VARCHAR(120) NOT NULL,
 correo VARCHAR(150) UNIQUE, especialidad VARCHAR(120), activo TINYINT(1) NOT NULL DEFAULT 1
);
CREATE TABLE IF NOT EXISTS participacion_expedicion (
 cod_expedicion INT NOT NULL, id_persona INT NOT NULL, funcion VARCHAR(100), fecha_incorporacion DATE,
 estado VARCHAR(40) DEFAULT 'Activa', observaciones TEXT,
 PRIMARY KEY(cod_expedicion,id_persona), FOREIGN KEY(cod_expedicion) REFERENCES expedicion(cod_expedicion),
 FOREIGN KEY(id_persona) REFERENCES persona(id_persona)
);
CREATE TABLE IF NOT EXISTS muestra (
 cod_muestra INT AUTO_INCREMENT PRIMARY KEY, nombre VARCHAR(150) NOT NULL, descripcion TEXT,
 fecha_hallazgo DATE, estado_conservacion VARCHAR(80), activo TINYINT(1) NOT NULL DEFAULT 1
);
CREATE TABLE IF NOT EXISTS muestra_biologica (cod_muestra INT PRIMARY KEY, atributo_especifico VARCHAR(180), FOREIGN KEY(cod_muestra) REFERENCES muestra(cod_muestra));
CREATE TABLE IF NOT EXISTS muestra_geologica (cod_muestra INT PRIMARY KEY, composicion VARCHAR(180), FOREIGN KEY(cod_muestra) REFERENCES muestra(cod_muestra));
CREATE TABLE IF NOT EXISTS muestra_climatica (cod_muestra INT PRIMARY KEY, variable_medida VARCHAR(180), FOREIGN KEY(cod_muestra) REFERENCES muestra(cod_muestra));
CREATE TABLE IF NOT EXISTS recoleccion (
 cod_expedicion INT NOT NULL, nro_recoleccion INT NOT NULL, cod_base INT NOT NULL, num_sector INT NOT NULL,
 cod_muestra INT NOT NULL, id_persona INT, fecha_recoleccion DATE NOT NULL,
 PRIMARY KEY(cod_expedicion,nro_recoleccion),
 FOREIGN KEY(cod_expedicion) REFERENCES expedicion(cod_expedicion),
 FOREIGN KEY(cod_base,num_sector) REFERENCES sector_investigacion(cod_base,num_sector),
 FOREIGN KEY(cod_muestra) REFERENCES muestra(cod_muestra), FOREIGN KEY(id_persona) REFERENCES persona(id_persona)
);
CREATE TABLE IF NOT EXISTS evaluacion (
 cod_expedicion INT NOT NULL, id_persona INT NOT NULL, nro_evaluacion INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 fecha DATE, calificacion DECIMAL(3,2) NOT NULL, comentario TEXT,
 UNIQUE KEY uq_eval_persona_exp(cod_expedicion,id_persona,nro_evaluacion),
 FOREIGN KEY(cod_expedicion,id_persona) REFERENCES participacion_expedicion(cod_expedicion,id_persona)
);
CREATE TABLE IF NOT EXISTS rol (
 id_rol INT AUTO_INCREMENT PRIMARY KEY, nombre VARCHAR(60) NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS cuenta_usuario (
 id_usuario INT AUTO_INCREMENT PRIMARY KEY, usuario VARCHAR(60) NOT NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL, id_rol INT NOT NULL, activo TINYINT(1) NOT NULL DEFAULT 1,
 FOREIGN KEY(id_rol) REFERENCES rol(id_rol)
);

INSERT IGNORE INTO rol(id_rol,nombre) VALUES (1,'administrador_base'),(2,'tecnico_terreno');

-- Datos iniciales de demostración; se pueden reemplazar por los datos originales del equipo.
INSERT INTO pais(cod_pais,nombre_oficial,organismo_responsable,presupuesto_anual) VALUES
(1,'Chile','Instituto Antártico Chileno',120000000),(2,'Argentina','Dirección Nacional del Antártico',110000000),
(3,'Australia','Australian Antarctic Division',130000000),(4,'Noruega','Instituto Polar Noruego',90000000)
ON DUPLICATE KEY UPDATE nombre_oficial=VALUES(nombre_oficial);
INSERT INTO base_cientifica(cod_base,nombre,ubicacion,fecha_instalacion,capacidad_maxima,presupuesto,nivel_aislamiento,cod_pais) VALUES
(1,'Base Prof. Julio Escudero','Isla Rey Jorge, Antártida','1995-01-01',60,2500000,'Alto',1),
(2,'Base Presidente Eduardo Frei Montalva','Isla Rey Jorge, Antártida','1969-03-07',80,3000000,'Medio',1),
(3,'Base Marambio','Isla Marambio, Antártida','1969-10-29',70,2800000,'Alto',2),
(4,'Estación Casey','Bahía Vincennes, Antártida','1969-02-19',65,3200000,'Muy alto',3),
(5,'Base Esperanza Sur','Península Antártica','1952-12-17',50,2100000,'Alto',2)
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);
INSERT IGNORE INTO sector_investigacion(cod_base,num_sector,nombre,superficie,condiciones_climaticas,nivel_acceso) VALUES
(1,1,'Laguna Glaciar',120,'Frío extremo','Restringido'),(1,2,'Sector Biológico',80,'Húmedo y frío','Medio'),
(2,1,'Sector Costero',100,'Viento intenso','Medio'),(3,1,'Sector Rocoso',90,'Seco y frío','Restringido'),
(4,1,'Sector Glaciar',150,'Frío extremo','Restringido'),(5,1,'Sector Marino',110,'Viento intenso','Medio');
INSERT IGNORE INTO persona(id_persona,nombre,correo,especialidad) VALUES
(1,'Sofía Martínez','sofia@example.org','Biología'),(2,'Diego Fernández','diego@example.org','Geología'),
(3,'Camila Torres','camila@example.org','Climatología'),(4,'Javier Soto','javier@example.org','Oceanografía');
INSERT IGNORE INTO muestra(cod_muestra,nombre,descripcion,fecha_hallazgo,estado_conservacion) VALUES
(1,'Muestra de líquenes','Muestra biológica antártica','2026-01-14','Refrigerada'),
(2,'Roca basáltica','Muestra geológica de terreno','2026-02-12','Seca'),
(3,'Registro de temperatura','Registro climático local','2026-03-15','Digital'),
(4,'Microorganismos antárticos','Muestra biológica marina','2026-04-19','Refrigerada');
INSERT IGNORE INTO muestra_biologica VALUES(1,'Líquenes'),(4,'Microorganismos');
INSERT IGNORE INTO muestra_geologica VALUES(2,'Basalto');
INSERT IGNORE INTO muestra_climatica VALUES(3,'Temperatura');
INSERT IGNORE INTO expedicion(cod_expedicion,fecha_inicio,duracion,capacidad_maxima,cod_base) VALUES
(1,'2026-01-10',30,12,1),(2,'2026-02-01',45,15,1),(3,'2026-03-05',20,10,2),
(4,'2026-04-12',35,14,3),(5,'2026-05-20',28,12,4),(6,'2026-06-15',40,16,5);
INSERT IGNORE INTO participacion_expedicion(cod_expedicion,id_persona,funcion,fecha_incorporacion) VALUES
(1,1,'Investigadora','2026-01-10'),(1,2,'Geólogo','2026-01-10'),(1,3,'Climatóloga','2026-01-10'),
(2,1,'Investigadora','2026-02-01'),(2,2,'Geólogo','2026-02-01'),(3,3,'Climatóloga','2026-03-05'),
(4,2,'Geólogo','2026-04-12'),(4,4,'Oceanógrafo','2026-04-12'),(5,1,'Investigadora','2026-05-20'),(6,4,'Oceanógrafo','2026-06-15');
INSERT IGNORE INTO recoleccion(cod_expedicion,nro_recoleccion,cod_base,num_sector,cod_muestra,id_persona,fecha_recoleccion) VALUES
(1,1,1,1,1,1,'2026-01-14'),(1,2,1,2,2,2,'2026-01-16'),(2,1,1,1,3,3,'2026-02-12'),
(3,1,2,1,4,3,'2026-03-15'),(4,1,3,1,2,2,'2026-04-19'),(5,1,4,1,1,1,'2026-05-22'),(6,1,5,1,3,4,'2026-06-18');
INSERT IGNORE INTO evaluacion(cod_expedicion,id_persona,fecha,calificacion,comentario) VALUES
(1,1,'2026-02-10',6.5,'Desempeño destacado'),(1,2,'2026-02-10',6.0,'Buen trabajo'),
(1,3,'2026-02-10',6.2,'Cumplimiento de objetivos'),(2,1,'2026-03-20',6.8,'Excelente desempeño'),
(2,2,'2026-03-20',5.9,'Buen desempeño'),(3,3,'2026-04-01',6.1,'Trabajo satisfactorio');

CREATE OR REPLACE VIEW R3_duracion_evaluacion AS
SELECT e.cod_expedicion,b.nombre AS base,e.duracion,COUNT(DISTINCT pe.id_persona) AS total_participantes,
ROUND(AVG(ev.calificacion),2) AS evaluacion_promedio
FROM expedicion e JOIN base_cientifica b ON e.cod_base=b.cod_base
LEFT JOIN participacion_expedicion pe ON pe.cod_expedicion=e.cod_expedicion
LEFT JOIN evaluacion ev ON ev.cod_expedicion=pe.cod_expedicion AND ev.id_persona=pe.id_persona
GROUP BY e.cod_expedicion,b.nombre,e.duracion;
CREATE OR REPLACE VIEW vw_r5_tasa_ocupacion_bases AS
SELECT bc.cod_base,bc.nombre AS base_cientifica,COUNT(e.cod_expedicion) AS total_expediciones,
COALESCE(SUM(p.cant),0) AS participantes_asignados,COALESCE(SUM(e.capacidad_maxima),0) AS capacidad_total,
CASE WHEN COALESCE(SUM(e.capacidad_maxima),0)=0 THEN 0 ELSE ROUND(100*COALESCE(SUM(p.cant),0)/SUM(e.capacidad_maxima),2) END AS tasa_ocupacion_pct
FROM base_cientifica bc LEFT JOIN expedicion e ON e.cod_base=bc.cod_base
LEFT JOIN (SELECT cod_expedicion,COUNT(*) cant FROM participacion_expedicion GROUP BY cod_expedicion) p ON p.cod_expedicion=e.cod_expedicion
GROUP BY bc.cod_base,bc.nombre;
CREATE OR REPLACE VIEW vw_r6_recolecciones_por_tipo_base_sector AS
SELECT bc.cod_base,bc.nombre AS base_cientifica,si.num_sector,si.nombre AS sector,
CASE WHEN mb.cod_muestra IS NOT NULL THEN 'Biologica' WHEN mg.cod_muestra IS NOT NULL THEN 'Geologica' WHEN mc.cod_muestra IS NOT NULL THEN 'Climatica' ELSE 'Sin clasificar' END AS tipo_muestra,
COUNT(r.nro_recoleccion) AS total_recolecciones
FROM recoleccion r JOIN muestra m ON m.cod_muestra=r.cod_muestra
JOIN sector_investigacion si ON si.cod_base=r.cod_base AND si.num_sector=r.num_sector
JOIN base_cientifica bc ON bc.cod_base=si.cod_base
LEFT JOIN muestra_biologica mb ON mb.cod_muestra=m.cod_muestra
LEFT JOIN muestra_geologica mg ON mg.cod_muestra=m.cod_muestra
LEFT JOIN muestra_climatica mc ON mc.cod_muestra=m.cod_muestra
GROUP BY bc.cod_base,bc.nombre,si.num_sector,si.nombre,tipo_muestra;
CREATE OR REPLACE VIEW v_r7_diversidad_muestras_sector AS
SELECT bc.cod_base,bc.nombre nombre_base,si.num_sector,si.nombre nombre_sector,
COUNT(DISTINCT m.cod_muestra) diversidad_muestras,COUNT(*) total_recolecciones
FROM recoleccion r JOIN expedicion e ON e.cod_expedicion=r.cod_expedicion
JOIN base_cientifica bc ON bc.cod_base=e.cod_base
JOIN sector_investigacion si ON si.cod_base=r.cod_base AND si.num_sector=r.num_sector
JOIN muestra m ON m.cod_muestra=r.cod_muestra
GROUP BY bc.cod_base,bc.nombre,si.num_sector,si.nombre;
CREATE OR REPLACE VIEW v_r8_participantes_mas_expediciones AS
SELECT p.id_persona,p.nombre nombre_participante,COUNT(DISTINCT pe.cod_expedicion) cantidad_expediciones,
COUNT(ev.nro_evaluacion) cantidad_evaluaciones,ROUND(AVG(ev.calificacion),2) evaluacion_promedio
FROM persona p JOIN participacion_expedicion pe ON pe.id_persona=p.id_persona
LEFT JOIN evaluacion ev ON ev.cod_expedicion=pe.cod_expedicion AND ev.id_persona=pe.id_persona
GROUP BY p.id_persona,p.nombre HAVING COUNT(DISTINCT pe.cod_expedicion)>=6;

DELIMITER $$
DROP PROCEDURE IF EXISTS R1_bases_expediciones$$
CREATE PROCEDURE R1_bases_expediciones(IN fecha_desde DATE,IN fecha_hasta DATE)
BEGIN SELECT pa.nombre_oficial pais,bc.nombre base,COUNT(e.cod_expedicion) total_expediciones FROM pais pa JOIN base_cientifica bc ON pa.cod_pais=bc.cod_pais JOIN expedicion e ON e.cod_base=bc.cod_base WHERE e.fecha_inicio BETWEEN fecha_desde AND fecha_hasta GROUP BY pa.nombre_oficial,bc.cod_base,bc.nombre ORDER BY total_expediciones DESC; END$$
DROP PROCEDURE IF EXISTS R2_muestras_expediciones$$
CREATE PROCEDURE R2_muestras_expediciones()
BEGIN SELECT e.cod_expedicion,bc.nombre base,m.nombre muestra,CASE WHEN mb.cod_muestra IS NOT NULL THEN 'Biologica' WHEN mg.cod_muestra IS NOT NULL THEN 'Geologica' WHEN mc.cod_muestra IS NOT NULL THEN 'Climatica' ELSE 'Sin clasificar' END tipo_muestra,r.fecha_recoleccion FROM recoleccion r JOIN muestra m ON r.cod_muestra=m.cod_muestra JOIN expedicion e ON r.cod_expedicion=e.cod_expedicion JOIN base_cientifica bc ON r.cod_base=bc.cod_base LEFT JOIN muestra_biologica mb ON mb.cod_muestra=m.cod_muestra LEFT JOIN muestra_geologica mg ON mg.cod_muestra=m.cod_muestra LEFT JOIN muestra_climatica mc ON mc.cod_muestra=m.cod_muestra ORDER BY e.cod_expedicion; END$$
DROP PROCEDURE IF EXISTS sp_r4_paises_expediciones_participantes$$
CREATE PROCEDURE sp_r4_paises_expediciones_participantes(IN p_fecha_inicio DATE,IN p_fecha_termino DATE)
BEGIN SELECT pa.cod_pais,pa.nombre_oficial pais,COUNT(DISTINCT e.cod_expedicion) total_expediciones,COUNT(DISTINCT pe.id_persona) total_participantes FROM pais pa JOIN base_cientifica bc ON bc.cod_pais=pa.cod_pais JOIN expedicion e ON e.cod_base=bc.cod_base LEFT JOIN participacion_expedicion pe ON pe.cod_expedicion=e.cod_expedicion WHERE e.fecha_inicio BETWEEN p_fecha_inicio AND p_fecha_termino GROUP BY pa.cod_pais,pa.nombre_oficial ORDER BY total_expediciones DESC,total_participantes DESC; END$$
DROP PROCEDURE IF EXISTS sp_r9_expediciones_sobre_promedio_base$$
CREATE PROCEDURE sp_r9_expediciones_sobre_promedio_base(IN p_cod_base INT,IN p_fecha_inicio DATE,IN p_fecha_fin DATE)
BEGIN SELECT bc.cod_base,bc.nombre nombre_base,e.cod_expedicion,e.fecha_inicio,e.duracion duracion_dias,COUNT(pe.id_persona) total_participantes FROM expedicion e JOIN base_cientifica bc ON bc.cod_base=e.cod_base LEFT JOIN participacion_expedicion pe ON pe.cod_expedicion=e.cod_expedicion WHERE e.cod_base=p_cod_base AND e.fecha_inicio BETWEEN p_fecha_inicio AND p_fecha_fin AND e.duracion>(SELECT AVG(e2.duracion) FROM expedicion e2 WHERE e2.cod_base=e.cod_base AND e2.fecha_inicio BETWEEN p_fecha_inicio AND p_fecha_fin) GROUP BY bc.cod_base,bc.nombre,e.cod_expedicion,e.fecha_inicio,e.duracion ORDER BY e.duracion DESC; END$$
DROP PROCEDURE IF EXISTS sp_r10_sectores_sobre_promedio_base$$
CREATE PROCEDURE sp_r10_sectores_sobre_promedio_base(IN p_cod_base INT)
BEGIN
 SELECT bc.cod_base,bc.nombre AS base_cientifica,si.num_sector,si.nombre AS sector,
 COUNT(r.nro_recoleccion) AS total_muestras_recolectadas
 FROM base_cientifica bc JOIN sector_investigacion si ON si.cod_base=bc.cod_base
 LEFT JOIN recoleccion r ON r.cod_base=si.cod_base AND r.num_sector=si.num_sector
 WHERE bc.cod_base=p_cod_base
 GROUP BY bc.cod_base,bc.nombre,si.num_sector,si.nombre
 HAVING COUNT(r.nro_recoleccion)>(SELECT AVG(sub.cnt_sector) FROM
   (SELECT COUNT(r2.nro_recoleccion) cnt_sector FROM sector_investigacion si2
    LEFT JOIN recoleccion r2 ON r2.cod_base=si2.cod_base AND r2.num_sector=si2.num_sector
    WHERE si2.cod_base=p_cod_base GROUP BY si2.num_sector) sub)
 ORDER BY total_muestras_recolectadas DESC,si.num_sector;
END$$
DROP PROCEDURE IF EXISTS sp_r11_participantes_destacados_periodo$$
CREATE PROCEDURE sp_r11_participantes_destacados_periodo(IN p_fecha_inicio DATE,IN p_fecha_fin DATE)
BEGIN
 SELECT p.id_persona,p.nombre participante,COUNT(DISTINCT pe.cod_expedicion) total_expediciones,
 ROUND(AVG(ev.calificacion),2) promedio_evaluacion
 FROM persona p JOIN participacion_expedicion pe ON pe.id_persona=p.id_persona
 JOIN expedicion e ON e.cod_expedicion=pe.cod_expedicion
 LEFT JOIN evaluacion ev ON ev.cod_expedicion=pe.cod_expedicion AND ev.id_persona=pe.id_persona
 WHERE e.fecha_inicio BETWEEN p_fecha_inicio AND p_fecha_fin
 GROUP BY p.id_persona,p.nombre
 HAVING COUNT(DISTINCT pe.cod_expedicion)>(SELECT AVG(x.cant_exp) FROM
   (SELECT COUNT(DISTINCT pe2.cod_expedicion) cant_exp FROM participacion_expedicion pe2
    JOIN expedicion e2 ON e2.cod_expedicion=pe2.cod_expedicion
    WHERE e2.fecha_inicio BETWEEN p_fecha_inicio AND p_fecha_fin GROUP BY pe2.id_persona) x)
 AND AVG(ev.calificacion)>(SELECT AVG(ev3.calificacion) FROM evaluacion ev3
   JOIN expedicion e3 ON e3.cod_expedicion=ev3.cod_expedicion
   WHERE e3.fecha_inicio BETWEEN p_fecha_inicio AND p_fecha_fin)
 ORDER BY total_expediciones DESC,promedio_evaluacion DESC;
END$$
DROP PROCEDURE IF EXISTS sp_r12_bases_duracion_sobre_promedio$$
CREATE PROCEDURE sp_r12_bases_duracion_sobre_promedio(IN p_fecha_inicio DATE,IN p_fecha_fin DATE)
BEGIN
 SELECT pa.nombre_oficial pais,bc.cod_base,bc.nombre base_cientifica,
 COUNT(e.cod_expedicion) total_expediciones,ROUND(AVG(e.duracion),2) duracion_promedio_base
 FROM pais pa JOIN base_cientifica bc ON bc.cod_pais=pa.cod_pais
 JOIN expedicion e ON e.cod_base=bc.cod_base
 WHERE e.fecha_inicio BETWEEN p_fecha_inicio AND p_fecha_fin
 GROUP BY pa.nombre_oficial,bc.cod_base,bc.nombre
 HAVING AVG(e.duracion)>(SELECT AVG(e2.duracion) FROM expedicion e2 WHERE e2.fecha_inicio BETWEEN p_fecha_inicio AND p_fecha_fin)
 ORDER BY duracion_promedio_base DESC;
END$$
DELIMITER ;
