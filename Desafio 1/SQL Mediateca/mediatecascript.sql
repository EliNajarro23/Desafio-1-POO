 -- Tabla general de materiales
CREATE TABLE material (
    codigo VARCHAR(10) PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    tipo ENUM('LIBRO', 'REVISTA', 'CD_AUDIO', 'DVD') NOT NULL
);

-- Tabla específica para libros
CREATE TABLE libro (
    codigo VARCHAR(10) PRIMARY KEY,
    autor VARCHAR(100),
    num_paginas INT,
    editorial VARCHAR(100),
    isbn VARCHAR(20),
    anio_publicacion INT,
    unidades_disponibles INT,
    FOREIGN KEY (codigo) REFERENCES material(codigo)
);

-- Tabla específica para revistas
CREATE TABLE revista (
    codigo VARCHAR(10) PRIMARY KEY,
    editorial VARCHAR(100),
    periodicidad VARCHAR(50),
    fecha_publicacion DATE,
    unidades_disponibles INT,
    FOREIGN KEY (codigo) REFERENCES material(codigo)
);

-- Tabla específica para CDs de audio
CREATE TABLE cd_audio (
    codigo VARCHAR(10) PRIMARY KEY,
    artista VARCHAR(100),
    genero VARCHAR(50),
    duracion TIME,
    num_canciones INT,
    unidades_disponibles INT,
    FOREIGN KEY (codigo) REFERENCES material(codigo)
);

-- Tabla específica para DVDs
CREATE TABLE dvd (
    codigo VARCHAR(10) PRIMARY KEY,
    director VARCHAR(100),
    duracion TIME,
    genero VARCHAR(50),
    FOREIGN KEY (codigo) REFERENCES material(codigo)
);