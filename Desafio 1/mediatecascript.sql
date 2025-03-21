-- Eliminar la base de datos si ya existe (comentar esta línea si no quieres eliminar la base de datos existente)
DROP DATABASE IF EXISTS mediateca;

-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS mediateca;
USE mediateca;

-- Crear tabla para Material (tabla base)
CREATE TABLE Material (
    id_material VARCHAR(8) PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    tipo_material ENUM('LIBRO', 'REVISTA', 'CD_AUDIO', 'DVD') NOT NULL,
    unidades_disponibles INT NOT NULL
);

-- Crear tabla para Libros
CREATE TABLE Libro (
    id_material VARCHAR(8) PRIMARY KEY,
    autor VARCHAR(255) NOT NULL,
    num_paginas INT NOT NULL,
    editorial VARCHAR(255) NOT NULL,
    isbn VARCHAR(13) NOT NULL,
    anio_publicacion INT NOT NULL,
    FOREIGN KEY (id_material) REFERENCES material(id_material) ON DELETE CASCADE
);

-- Crear tabla para Revistas
CREATE TABLE Revista (
    id_material VARCHAR(8) PRIMARY KEY,
    editorial VARCHAR(255) NOT NULL,
    periodicidad VARCHAR(50) NOT NULL,
    fecha_publicacion DATE NOT NULL,
    FOREIGN KEY (id_material) REFERENCES material(id_material) ON DELETE CASCADE
);

-- Crear tabla para CDs de Audio
CREATE TABLE CdAudio (
    id_material VARCHAR(8) PRIMARY KEY,
    artista VARCHAR(255) NOT NULL,
    genero VARCHAR(100) NOT NULL,
    duracion INT NOT NULL,
    num_canciones INT NOT NULL,
    FOREIGN KEY (id_material) REFERENCES material(id_material) ON DELETE CASCADE
);

-- Crear tabla para DVDs
CREATE TABLE DVD (
    id_material VARCHAR(8) PRIMARY KEY,
    director VARCHAR(255) NOT NULL,
    duracion INT NOT NULL,
    genero VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_material) REFERENCES material(id_material) ON DELETE CASCADE
);

-- Crear procedimiento almacenado para generar IDs automáticos
DELIMITER //
CREATE PROCEDURE generar_nuevo_id(IN tipo_mat VARCHAR(3), OUT nuevo_id VARCHAR(8))
BEGIN
    DECLARE ultimo_num INT;
    DECLARE ultimo_id VARCHAR(8);
    
    -- Obtener el último ID del tipo especificado
    SELECT MAX(id_material) INTO ultimo_id
    FROM material
    WHERE id_material LIKE CONCAT(tipo_mat, '%');
    
    IF ultimo_id IS NULL THEN
        SET nuevo_id = CONCAT(tipo_mat, '00001');
    ELSE
        -- Extraer el número y aumentarlo en 1
        SET ultimo_num = CAST(SUBSTRING(ultimo_id, 4) AS UNSIGNED) + 1;
        SET nuevo_id = CONCAT(tipo_mat, LPAD(ultimo_num, 5, '0'));
    END IF;
END //
DELIMITER ;

-- Crear triggers para manejar la generación de IDs automáticos
DELIMITER //
CREATE TRIGGER before_insert_material
BEFORE INSERT ON material
FOR EACH ROW
BEGIN
    DECLARE nuevo_id VARCHAR(8);
    
    IF NEW.id_material IS NULL OR NEW.id_material = '' THEN
        CASE NEW.tipo_material
            WHEN 'LIBRO' THEN
                CALL generar_nuevo_id('LIB', nuevo_id);
            WHEN 'REVISTA' THEN
                CALL generar_nuevo_id('REV', nuevo_id);
            WHEN 'CD_AUDIO' THEN
                CALL generar_nuevo_id('CDA', nuevo_id);
            WHEN 'DVD' THEN
                CALL generar_nuevo_id('DVD', nuevo_id);
        END CASE;
        
        SET NEW.id_material = nuevo_id;
    END IF;
END //
DELIMITER ;

-- Crear procedimiento almacenado para agregar un libro
DELIMITER //
CREATE PROCEDURE agregar_libro(
    IN p_titulo VARCHAR(255),
    IN p_autor VARCHAR(255),
    IN p_num_paginas INT,
    IN p_editorial VARCHAR(255),
    IN p_isbn VARCHAR(13),
    IN p_anio_publicacion INT,
    IN p_unidades_disponibles INT,
    OUT p_id_material VARCHAR(8)
)
BEGIN
    DECLARE nuevo_id VARCHAR(8);
    
    -- Insertar en la tabla material
    INSERT INTO material (id_material, titulo, tipo_material, unidades_disponibles)
    VALUES ('', p_titulo, 'LIBRO', p_unidades_disponibles);
    
    -- Obtener el ID generado
    SELECT LAST_INSERT_ID() INTO nuevo_id;
    SET p_id_material = (SELECT id_material FROM material WHERE id_material LIKE 'LIB%' ORDER BY id_material DESC LIMIT 1);
    
    -- Insertar en la tabla libro
    INSERT INTO libro (id_material, autor, num_paginas, editorial, isbn, anio_publicacion)
    VALUES (p_id_material, p_autor, p_num_paginas, p_editorial, p_isbn, p_anio_publicacion);
END //
DELIMITER ;

-- Crear procedimiento almacenado para agregar una revista
DELIMITER //
CREATE PROCEDURE agregar_revista(
    IN p_titulo VARCHAR(255),
    IN p_editorial VARCHAR(255),
    IN p_periodicidad VARCHAR(50),
    IN p_fecha_publicacion DATE,
    IN p_unidades_disponibles INT,
    OUT p_id_material VARCHAR(8)
)
BEGIN
    DECLARE nuevo_id VARCHAR(8);
    
    -- Insertar en la tabla material
    INSERT INTO material (id_material, titulo, tipo_material, unidades_disponibles)
    VALUES ('', p_titulo, 'REVISTA', p_unidades_disponibles);
    
    -- Obtener el ID generado
    SELECT LAST_INSERT_ID() INTO nuevo_id;
    SET p_id_material = (SELECT id_material FROM material WHERE id_material LIKE 'REV%' ORDER BY id_material DESC LIMIT 1);
    
    -- Insertar en la tabla revista
    INSERT INTO revista (id_material, editorial, periodicidad, fecha_publicacion)
    VALUES (p_id_material, p_editorial, p_periodicidad, p_fecha_publicacion);
END //
DELIMITER ;

-- Crear procedimiento almacenado para agregar un CD de audio
DELIMITER //
CREATE PROCEDURE agregar_cd_audio(
    IN p_titulo VARCHAR(255),
    IN p_artista VARCHAR(255),
    IN p_genero VARCHAR(100),
    IN p_duracion INT,
    IN p_num_canciones INT,
    IN p_unidades_disponibles INT,
    OUT p_id_material VARCHAR(8)
)
BEGIN
    DECLARE nuevo_id VARCHAR(8);
    
    -- Insertar en la tabla material
    INSERT INTO material (id_material, titulo, tipo_material, unidades_disponibles)
    VALUES ('', p_titulo, 'CD_AUDIO', p_unidades_disponibles);
    
    -- Obtener el ID generado
    SELECT LAST_INSERT_ID() INTO nuevo_id;
    SET p_id_material = (SELECT id_material FROM material WHERE id_material LIKE 'CDA%' ORDER BY id_material DESC LIMIT 1);
    
    -- Insertar en la tabla cd_audio
    INSERT INTO cd_audio (id_material, artista, genero, duracion, num_canciones)
    VALUES (p_id_material, p_artista, p_genero, p_duracion, p_num_canciones);
END //
DELIMITER ;

-- Crear procedimiento almacenado para agregar un DVD
DELIMITER //
CREATE PROCEDURE agregar_dvd(
    IN p_titulo VARCHAR(255),
    IN p_director VARCHAR(255),
    IN p_duracion INT,
    IN p_genero VARCHAR(100),
    IN p_unidades_disponibles INT,
    OUT p_id_material VARCHAR(8)
)
BEGIN
    DECLARE nuevo_id VARCHAR(8);
    
    -- Insertar en la tabla material
    INSERT INTO material (id_material, titulo, tipo_material, unidades_disponibles)
    VALUES ('', p_titulo, 'DVD', p_unidades_disponibles);
    
    -- Obtener el ID generado
    SELECT LAST_INSERT_ID() INTO nuevo_id;
    SET p_id_material = (SELECT id_material FROM material WHERE id_material LIKE 'DVD%' ORDER BY id_material DESC LIMIT 1);
    
    -- Insertar en la tabla dvd
    INSERT INTO dvd (id_material, director, duracion, genero)
    VALUES (p_id_material, p_director, p_duracion, p_genero);
END //
DELIMITER ;

-- Crear procedimiento almacenado para modificar un libro
DELIMITER //
CREATE PROCEDURE modificar_libro(
    IN p_id_material VARCHAR(8),
    IN p_titulo VARCHAR(255),
    IN p_autor VARCHAR(255),
    IN p_num_paginas INT,
    IN p_editorial VARCHAR(255),
    IN p_isbn VARCHAR(13),
    IN p_anio_publicacion INT,
    IN p_unidades_disponibles INT
)
BEGIN
    -- Actualizar tabla material
    UPDATE material
    SET titulo = p_titulo, unidades_disponibles = p_unidades_disponibles
    WHERE id_material = p_id_material;
    
    -- Actualizar tabla libro
    UPDATE libro
    SET autor = p_autor, num_paginas = p_num_paginas, editorial = p_editorial, 
        isbn = p_isbn, anio_publicacion = p_anio_publicacion
    WHERE id_material = p_id_material;
END //
DELIMITER ;

-- Crear procedimiento almacenado para modificar una revista
DELIMITER //
CREATE PROCEDURE modificar_revista(
    IN p_id_material VARCHAR(8),
    IN p_titulo VARCHAR(255),
    IN p_editorial VARCHAR(255),
    IN p_periodicidad VARCHAR(50),
    IN p_fecha_publicacion DATE,
    IN p_unidades_disponibles INT
)
BEGIN
    -- Actualizar tabla material
    UPDATE material
    SET titulo = p_titulo, unidades_disponibles = p_unidades_disponibles
    WHERE id_material = p_id_material;
    
    -- Actualizar tabla revista
    UPDATE revista
    SET editorial = p_editorial, periodicidad = p_periodicidad, 
        fecha_publicacion = p_fecha_publicacion
    WHERE id_material = p_id_material;
END //
DELIMITER ;

-- Crear procedimiento almacenado para modificar un CD de audio
DELIMITER //
CREATE PROCEDURE modificar_cd_audio(
    IN p_id_material VARCHAR(8),
    IN p_titulo VARCHAR(255),
    IN p_artista VARCHAR(255),
    IN p_genero VARCHAR(100),
    IN p_duracion INT,
    IN p_num_canciones INT,
    IN p_unidades_disponibles INT
)
BEGIN
    -- Actualizar tabla material
    UPDATE material
    SET titulo = p_titulo, unidades_disponibles = p_unidades_disponibles
    WHERE id_material = p_id_material;
    
    -- Actualizar tabla cd_audio
    UPDATE cd_audio
    SET artista = p_artista, genero = p_genero, 
        duracion = p_duracion, num_canciones = p_num_canciones
    WHERE id_material = p_id_material;
END //
DELIMITER ;

-- Crear procedimiento almacenado para modificar un DVD
DELIMITER //
CREATE PROCEDURE modificar_dvd(
    IN p_id_material VARCHAR(8),
    IN p_titulo VARCHAR(255),
    IN p_director VARCHAR(255),
    IN p_duracion INT,
    IN p_genero VARCHAR(100),
    IN p_unidades_disponibles INT
)
BEGIN
    -- Actualizar tabla material
    UPDATE material
    SET titulo = p_titulo, unidades_disponibles = p_unidades_disponibles
    WHERE id_material = p_id_material;
    
    -- Actualizar tabla dvd
    UPDATE dvd
    SET director = p_director, duracion = p_duracion, genero = p_genero
    WHERE id_material = p_id_material;
END //
DELIMITER ;

-- Crear procedimiento almacenado para borrar material
DELIMITER //
CREATE PROCEDURE borrar_material(
    IN p_id_material VARCHAR(8)
)
BEGIN
    -- Al borrar de la tabla material, las tablas específicas
    -- se actualizan automáticamente por la restricción ON DELETE CASCADE
    DELETE FROM material WHERE id_material = p_id_material;
END //
DELIMITER ;

-- Crear vistas para facilitar las búsquedas y listados

-- Vista para libros con todos los detalles
CREATE VIEW vista_libros AS
SELECT m.id_material, m.titulo, m.unidades_disponibles, 
       l.autor, l.num_paginas, l.editorial, l.isbn, l.anio_publicacion
FROM material m
JOIN libro l ON m.id_material = l.id_material;

-- Vista para revistas con todos los detalles
CREATE VIEW vista_revistas AS
SELECT m.id_material, m.titulo, m.unidades_disponibles, 
       r.editorial, r.periodicidad, r.fecha_publicacion
FROM material m
JOIN revista r ON m.id_material = r.id_material;

-- Vista para CDs de audio con todos los detalles
CREATE VIEW vista_cd_audio AS
SELECT m.id_material, m.titulo, m.unidades_disponibles, 
       c.artista, c.genero, c.duracion, c.num_canciones
FROM material m
JOIN cd_audio c ON m.id_material = c.id_material;

-- Vista para DVDs con todos los detalles
CREATE VIEW vista_dvds AS
SELECT m.id_material, m.titulo, m.unidades_disponibles, 
       d.director, d.duracion, d.genero
FROM material m
JOIN dvd d ON m.id_material = d.id_material;

-- Vista para todos los materiales (útil para búsquedas generales)
CREATE VIEW vista_todos_materiales AS
SELECT m.id_material, m.titulo, m.tipo_material, m.unidades_disponibles
FROM material m;

-- Insertar algunos datos de ejemplo

-- Libros de ejemplo
CALL agregar_libro('Cien años de soledad', 'Gabriel García Márquez', 471, 'Sudamericana', '9780307474728', 1967, 5, @id);
CALL agregar_libro('El Señor de los Anillos', 'J.R.R. Tolkien', 1200, 'Minotauro', '9788445000663', 1954, 3, @id);
CALL agregar_libro('Harry Potter y la piedra filosofal', 'J.K. Rowling', 309, 'Salamandra', '9788478884459', 1997, 8, @id);

-- Revistas de ejemplo
CALL agregar_revista('National Geographic', 'National Geographic Society', 'Mensual', '2023-01-15', 10, @id);
CALL agregar_revista('Time', 'Time USA, LLC', 'Semanal', '2023-03-01', 7, @id);
CALL agregar_revista('Scientific American', 'Springer Nature', 'Mensual', '2023-02-28', 4, @id);

-- CDs de audio de ejemplo
CALL agregar_cd_audio('Thriller', 'Michael Jackson', 'Pop', 42, 9, 6, @id);
CALL agregar_cd_audio('The Dark Side of the Moon', 'Pink Floyd', 'Rock Progresivo', 43, 10, 2, @id);
CALL agregar_cd_audio('Back in Black', 'AC/DC', 'Hard Rock', 42, 10, 5, @id);

-- DVDs de ejemplo
CALL agregar_dvd('El Padrino', 'Francis Ford Coppola', 175, 'Drama', 3, @id);
CALL agregar_dvd('Star Wars: Una nueva esperanza', 'George Lucas', 121, 'Ciencia Ficción', 4, @id);
CALL agregar_dvd('Titanic', 'James Cameron', 195, 'Drama/Romance', 2, @id);