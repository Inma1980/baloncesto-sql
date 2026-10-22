-- =============================================================================
--  Base de datos Baloncesto · Vista y Trigger
--  Autora: Inma Villaverde · 1º ASIR
-- =============================================================================

USE Baloncesto;

-- =============================================================================
-- 1. VISTA: jugadores con su equipo
-- -----------------------------------------------------------------------------
-- Une Jugadores y Equipos para no tener que escribir el JOIN cada vez.
-- =============================================================================

CREATE VIEW VistaJugadoresEquipo AS
SELECT j.nombre   AS jugador,
       j.posicion,
       e.nombre   AS equipo
FROM Jugadores j
JOIN Equipos  e ON j.id_equipo = e.id_equipo;

-- Ejemplo de uso: jugadores del equipo Lions
SELECT jugador, posicion
FROM VistaJugadoresEquipo
WHERE equipo = 'Lions';


-- =============================================================================
-- 2. TRIGGER: edad mínima de 18 años al dar de alta un jugador
-- -----------------------------------------------------------------------------
-- BEFORE INSERT: el dato se comprueba ANTES de guardarse. Si la edad es
-- menor de 18, se cancela la inserción con un error personalizado.
-- =============================================================================

DELIMITER $$

CREATE TRIGGER trg_edad_jugador
BEFORE INSERT ON Jugadores
FOR EACH ROW
BEGIN
    IF NEW.edad < 18 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El jugador debe tener al menos 18 años';
    END IF;
END$$

DELIMITER ;

-- Prueba 1: 16 años → ERROR 1644 (45000): El jugador debe tener al menos 18 años
-- INSERT INTO Jugadores (nombre, edad, posicion, id_equipo)
-- VALUES ('Pedro Ruiz', 16, 'Base', 1);

-- Prueba 2: 20 años → Query OK, 1 row affected
INSERT INTO Jugadores (nombre, edad, posicion, id_equipo)
VALUES ('Pedro Ruiz', 20, 'Base', 1);


-- =============================================================================
-- 3. MEJORAS tras la corrección de la práctica 💡
-- -----------------------------------------------------------------------------
--  a) Incluir los identificadores en la vista: así se puede filtrar o cruzar
--     con otras tablas sin depender de los nombres (que pueden repetirse).
--  b) Añadir también un trigger BEFORE UPDATE: sin él, se podría insertar un
--     jugador con 20 años y luego cambiarle la edad a 15 con un UPDATE.
-- =============================================================================

-- a) Vista ampliada con los ID
CREATE OR REPLACE VIEW VistaJugadoresEquipo AS
SELECT j.id_jugador,
       j.nombre     AS jugador,
       j.posicion,
       e.id_equipo,
       e.nombre     AS equipo
FROM Jugadores j
JOIN Equipos  e ON j.id_equipo = e.id_equipo;

-- b) La misma regla al modificar un jugador
DELIMITER $$

CREATE TRIGGER trg_edad_jugador_update
BEFORE UPDATE ON Jugadores
FOR EACH ROW
BEGIN
    IF NEW.edad < 18 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El jugador debe tener al menos 18 años';
    END IF;
END$$

DELIMITER ;

-- Prueba: → ERROR 1644 (45000)
-- UPDATE Jugadores SET edad = 15 WHERE nombre = 'Pedro Ruiz';
