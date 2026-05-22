
--  Sistema de Control de Préstamos
--  Base de Datos: bibliotecaudb

CREATE DATABASE bibliotecaudb
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_spanish_ci;
USE bibliotecaudb;

-- ============================================================
-- TABLA 1: categorias
-- ============================================================
CREATE TABLE categorias (
    id_categoria    INT(11)     NOT NULL AUTO_INCREMENT,
    nombre_categoria VARCHAR(80) NOT NULL,
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLA 2: libros
-- ============================================================
CREATE TABLE libros (
    id_libro            INT(11)      NOT NULL AUTO_INCREMENT,
    titulo              VARCHAR(150) NOT NULL,
    autor               VARCHAR(100) NOT NULL,
    isbn                VARCHAR(20)  NULL,
    id_categoria        INT(11)      NULL,
    cantidad_disponible INT(11)      NOT NULL DEFAULT 1,
    CONSTRAINT pk_libro          PRIMARY KEY (id_libro),
    CONSTRAINT uq_isbn           UNIQUE      (isbn),
    CONSTRAINT fk_libro_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES categorias (id_categoria)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLA 3: estudiantes
-- ============================================================
CREATE TABLE estudiantes (
    id_estudiante   INT(11)      NOT NULL AUTO_INCREMENT,
    carnet          VARCHAR(10)  NOT NULL,
    nombre_estudiante VARCHAR(100) NOT NULL,
    carrera         VARCHAR(80)  NOT NULL,
    telefono        VARCHAR(9)   NULL,
    CONSTRAINT pk_estudiante PRIMARY KEY (id_estudiante),
    CONSTRAINT uq_carnet     UNIQUE      (carnet)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLA 4: prestamos
-- ============================================================
CREATE TABLE prestamos (
    id_prestamo     INT(11)     NOT NULL AUTO_INCREMENT,
    id_estudiante   INT(11)     NOT NULL,
    id_libro        INT(11)     NOT NULL,
    fecha_prestamo  DATE        NOT NULL,
    fecha_devolucion DATE       NOT NULL,
    estado          VARCHAR(20) NOT NULL DEFAULT 'Activo',
    CONSTRAINT pk_prestamo PRIMARY KEY (id_prestamo),
    CONSTRAINT fk_prestamo_estudiante
        FOREIGN KEY (id_estudiante)
        REFERENCES estudiantes (id_estudiante)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_prestamo_libro
        FOREIGN KEY (id_libro)
        REFERENCES libros (id_libro)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- DATOS DE PRUEBA

-- Categorías
INSERT INTO categorias (nombre_categoria) VALUES
    ('Ingeniería y Tecnología'),
    ('Ciencias Básicas'),
    ('Humanidades y Ciencias Sociales'),
    ('Administración y Negocios'),
    ('Literatura y Arte');

-- Libros
INSERT INTO libros (titulo, autor, isbn, id_categoria, cantidad_disponible) VALUES
    ('Ingeniería de Software',          'Ian Sommerville',       '978-0137035151', 1, 3),
    ('Estructuras de Datos en Java',    'Robert Lafore',         '978-0672324536', 1, 2),
    ('Cálculo Vol. 1',                  'James Stewart',         '978-6074819120', 2, 4),
    ('Física Universitaria Vol. 1',     'Sears & Zemansky',      '978-6073221245', 2, 2),
    ('Historia Universal Contemporánea','Florencia Ferrer',      '978-9706863058', 3, 3),
    ('Administración',                  'Stephen Robbins',       '978-6073214636', 4, 2),
    ('El Quijote de la Mancha',         'Miguel de Cervantes',   '978-8467039597', 5, 5),
    ('Introducción a la Programación',  'Paul Deitel',           '978-0133591156', 1, 0),
    ('Estadística para Administración', 'David Levine',          '978-6073233088', 4, 3),
    ('Psicología General',              'Morris & Maisto',       '978-6074429183', 3, 1);

-- Estudiantes
INSERT INTO estudiantes (carnet, nombre_estudiante, carrera, telefono) VALUES
    ('RL210001', 'Carlos Ernesto Rivas López',    'Ingeniería en Sistemas',       '75412365'),
    ('OD210002', 'María Fernanda Orellana Díaz',  'Ingeniería Industrial',        '65238741'),
    ('HF210003', 'José Daniel Hernández Flores',  'Administración de Empresas',   '79514823'),
    ('MC210004', 'Andrea Sofía Martínez Cruz',    'Licenciatura en Psicología',   '61047592'),
    ('MP210005', 'Kevin Alejandro Morales Pérez', 'Ingeniería en Sistemas',       '70283946'),
    ('GT210006', 'Luisa Amanda Guzmán Torres',    'Contaduría Pública',           '68193045'),
    ('CM210007', 'Roberto Alfredo Chávez Mejía',  'Ingeniería Mecatrónica',       '72840513'),
    ('PS210008', 'Gabriela Isabel Portillo Soto', 'Ingeniería en Sistemas',       '64718293');

-- Préstamos de prueba
-- (Fechas variadas: vigentes, vencidos y devueltos)
INSERT INTO prestamos (id_estudiante, id_libro, fecha_prestamo, fecha_devolucion, estado) VALUES
    (1, 1, CURDATE() - INTERVAL 2 DAY,  CURDATE() + INTERVAL 7 DAY,  'Activo'),   -- Vigente
    (2, 3, CURDATE() - INTERVAL 15 DAY, CURDATE() - INTERVAL 6 DAY,  'Activo'),   -- Vencido
    (3, 6, CURDATE() - INTERVAL 10 DAY, CURDATE() - INTERVAL 1 DAY,  'Devuelto'), -- Devuelto
    (4, 7, CURDATE() - INTERVAL 1 DAY,  CURDATE() + INTERVAL 8 DAY,  'Activo'),   -- Vigente
    (5, 2, CURDATE() - INTERVAL 20 DAY, CURDATE() - INTERVAL 11 DAY, 'Activo'),   -- Vencido
    (6, 4, CURDATE(),                   CURDATE() + INTERVAL 9 DAY,  'Activo'),   -- Vigente (hoy)
    (7, 5, CURDATE() - INTERVAL 5 DAY,  CURDATE() + INTERVAL 4 DAY,  'Activo'),   -- Vigente
    (8, 9, CURDATE() - INTERVAL 12 DAY, CURDATE() - INTERVAL 3 DAY,  'Devuelto'); -- Devuelto

-- ============================================================
-- Ajustar stock según préstamos activos registrados
-- (libros con préstamos Activos restan 1 de cantidad_disponible)
-- ============================================================
-- id_libro 1: 1 activo → 3-1 = 2 ya en INSERT; ajuste fino:
UPDATE libros SET cantidad_disponible = 2 WHERE id_libro = 1;
UPDATE libros SET cantidad_disponible = 1 WHERE id_libro = 2;
UPDATE libros SET cantidad_disponible = 3 WHERE id_libro = 3;
UPDATE libros SET cantidad_disponible = 1 WHERE id_libro = 4;
UPDATE libros SET cantidad_disponible = 3 WHERE id_libro = 5;
UPDATE libros SET cantidad_disponible = 2 WHERE id_libro = 6;
UPDATE libros SET cantidad_disponible = 4 WHERE id_libro = 7;
-- id_libro 8: sin stock (cantidad=0, no se presta)
UPDATE libros SET cantidad_disponible = 3 WHERE id_libro = 9;
