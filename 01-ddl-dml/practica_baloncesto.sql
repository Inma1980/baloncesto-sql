USE Baloncesto;

-- =============================================================================
-- EJERCICIO 1: Crear tabla Entrenadores con clave foránea y ON DELETE adecuado
-- =============================================================================
-- Justificación ON DELETE SET NULL:
-- Si se elimina un equipo, tiene sentido conservar el registro del entrenador
-- en la base de datos (su historial, salario, etc.) aunque ya no esté asignado
-- a ningún equipo. Por eso usamos ON DELETE SET NULL, que pone id_equipo a NULL
-- en lugar de eliminar al entrenador o bloquear la operación.
-- ON DELETE CASCADE borraría entrenadores al borrar equipos (no deseable).
-- ON DELETE RESTRICT impediría borrar un equipo que tenga entrenadores (demasiado restrictivo).

CREATE TABLE Entrenadores (
    id_entrenador INT PRIMARY KEY AUTO_INCREMENT,
    nombre        VARCHAR(50) NOT NULL,
    edad          INT         NOT NULL,
    especialidad  VARCHAR(50),
    id_equipo     INT,
    CONSTRAINT fk_entrenadores_equipo
        FOREIGN KEY (id_equipo)
        REFERENCES Equipos(id_equipo)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- =============================================================================
-- EJERCICIO 2: Añadir columna salario (no acepta valores negativos)
-- =============================================================================

ALTER TABLE Entrenadores
    ADD COLUMN salario DECIMAL(10,2),
    ADD CONSTRAINT chk_entrenadores_salario CHECK (salario >= 0);

-- =============================================================================
-- EJERCICIO 3: Modificar la columna salario a tipo DECIMAL(10,2)
-- (Ya fue creada como DECIMAL(10,2) en el ejercicio 2; se muestra igualmente
--  la sentencia ALTER para cumplir el enunciado)
-- =============================================================================

ALTER TABLE Entrenadores
    MODIFY COLUMN salario DECIMAL(10,2);

-- =============================================================================
-- EJERCICIO 4: Crear tabla Prueba con al menos dos columnas
-- =============================================================================

CREATE TABLE Prueba (
    id_prueba   INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(100) NOT NULL,
    fecha_alta  DATE
);

-- =============================================================================
-- EJERCICIO 5: Eliminar completamente la tabla Prueba
-- =============================================================================

DROP TABLE Prueba;

-- =============================================================================
-- EJERCICIO 6: Vaciar completamente la tabla Entrenadores sin eliminar su estructura
-- =============================================================================

TRUNCATE TABLE Entrenadores;

-- =============================================================================
-- EJERCICIO 7: Insertar un entrenador en la tabla Entrenadores
-- =============================================================================

INSERT INTO Entrenadores (nombre, edad, especialidad, id_equipo, salario)
VALUES ('Luis Fernandez', 45, 'Ataque', 1, 3500.00);

-- =============================================================================
-- EJERCICIO 8: Insertar al menos tres entrenadores en una sola sentencia
-- =============================================================================

INSERT INTO Entrenadores (nombre, edad, especialidad, id_equipo, salario) VALUES
    ('Maria Gomez',    38, 'Defensa',         2, 2800.00),
    ('Pedro Sanchez',  52, 'Preparacion fisica', 3, 4100.00),
    ('Ana Martinez',   41, 'Tactica general', 4, 3200.00);

-- =============================================================================
-- EJERCICIO 9: Insertar un entrenador con un id_equipo que NO existe
-- ¿Qué ocurre?
-- MySQL lanzará un error de integridad referencial:
--   ERROR 1452 (23000): Cannot add or update a child row: a foreign key
--   constraint fails (`Baloncesto`.`Entrenadores`, CONSTRAINT
--   `fk_entrenadores_equipo` FOREIGN KEY (`id_equipo`) REFERENCES
--   `Equipos` (`id_equipo`))
-- La inserción se rechaza porque id_equipo=999 no existe en la tabla Equipos.
-- =============================================================================

-- INSERT INTO Entrenadores (nombre, edad, especialidad, id_equipo, salario)
-- VALUES ('Entrenador Fantasma', 35, 'Ninguna', 999, 1000.00);
-- ^ Esta sentencia produce ERROR. Se deja comentada para que no interrumpa
--   la ejecución del script, pero documenta lo que ocurriría al ejecutarla.

-- =============================================================================
-- EJERCICIO 10: Actualizar el salario de un entrenador concreto
-- =============================================================================

UPDATE Entrenadores
SET salario = 5000.00
WHERE id_entrenador = 1;

-- =============================================================================
-- EJERCICIO 11: Incrementar el salario de TODOS los entrenadores en 200 unidades
-- =============================================================================

UPDATE Entrenadores
SET salario = salario + 200;

-- =============================================================================
-- EJERCICIO 12: Eliminar un entrenador concreto de la tabla
-- =============================================================================

DELETE FROM Entrenadores
WHERE id_entrenador = 2;

-- =============================================================================
-- EJERCICIO 13: UPDATE Entrenadores SET salario = 3000 (sin WHERE)
-- ¿Qué ocurre?
-- Se actualiza el campo salario de TODOS los registros de la tabla a 3000.
-- No hay filtro WHERE, por lo que afecta a cada fila existente.
-- Si el modo safe updates está activado, MySQL puede bloquear esta operación.
-- =============================================================================

UPDATE Entrenadores SET salario = 3000;

-- =============================================================================
-- EJERCICIO 14: DELETE FROM Entrenadores (sin WHERE)
-- ¿Qué ocurre y por qué es peligroso?
-- Elimina TODOS los registros de la tabla Entrenadores sin excepción.
-- Es peligroso porque:
--   1. No hay filtro: afecta a cada fila de la tabla.
--   2. La operación es irreversible si no hay transacción activa.
--   3. A diferencia de TRUNCATE, dispara triggers y genera log de transacción,
--      pero el resultado final es idéntico: tabla vacía.
--   4. Un simple olvido del WHERE puede causar pérdida masiva de datos en producción.
-- =============================================================================

DELETE FROM Entrenadores;

-- =============================================================================
-- EJERCICIO 15: Eliminar todos los registros de la tabla Entrenadores
-- (Equivalente al DELETE sin WHERE del ejercicio anterior; aquí usamos TRUNCATE
--  que es más eficiente para vaciar tablas grandes)
-- =============================================================================

-- Primero re-insertamos datos para que tenga sentido la operación
INSERT INTO Entrenadores (nombre, edad, especialidad, id_equipo, salario) VALUES
    ('Carlos Ruiz',   50, 'Ataque', 1, 3000.00),
    ('Lucia Torres',  44, 'Defensa', 5, 2700.00);

TRUNCATE TABLE Entrenadores;

-- =============================================================================
-- EJERCICIO 16: Intentar eliminar un equipo que tiene jugadores asociados
-- ¿Qué ocurre, por qué y qué relación lo impide?
-- Al ejecutar: DELETE FROM Equipos WHERE id_equipo = 1;
-- MySQL lanza:
--   ERROR 1451 (23000): Cannot delete or update a parent row: a foreign key
--   constraint fails (`Baloncesto`.`Partidos`, CONSTRAINT
--   `fk_partidos_equipo_local` FOREIGN KEY (`equipo_local`) REFERENCES
--   `Equipos` (`id_equipo`))
-- La restricción ON DELETE RESTRICT definida en la FK de la tabla Jugadores
-- (fk_jugadores_equipo) impide borrar un equipo que todavía tenga jugadores
-- asociados. También las FKs de Partidos (fk_partidos_equipo_local y
-- fk_partidos_equipo_visitante) bloquean la operación si hay partidos del equipo.
-- Para poder borrarlo habría que reasignar o eliminar primero los jugadores
-- y partidos relacionados.
-- =============================================================================

-- DELETE FROM Equipos WHERE id_equipo = 1;
-- ^ Produce ERROR por violación de integridad referencial. 
