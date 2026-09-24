-- =====================================================================
-- Tienda de libros · Esquema en 3FN (sintaxis MySQL 8.0.16+)
-- =====================================================================
DROP DATABASE IF EXISTS tienda_libros;
CREATE DATABASE tienda_libros CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE tienda_libros;

-- 1. TABLAS SIN DEPENDENCIAS ------------------------------------------
CREATE TABLE editorial (
    id_editorial INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE autor (
    id_autor INT AUTO_INCREMENT PRIMARY KEY,
    nombre   VARCHAR(120) NOT NULL
);

CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre     VARCHAR(60)  NOT NULL,
    apellido   VARCHAR(60)  NOT NULL,
    correo     VARCHAR(120) NOT NULL UNIQUE,
    direccion  VARCHAR(200) NOT NULL,
    telefono   VARCHAR(20)  NOT NULL
);

CREATE TABLE metodo_pago (
    id_metodo_pago INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(40) NOT NULL UNIQUE
);

-- 2. TABLAS CON FK -----------------------------------------------------
CREATE TABLE libro (
    isbn              VARCHAR(17)   PRIMARY KEY,
    titulo            VARCHAR(200)  NOT NULL,
    fecha_publicacion DATE          NOT NULL,
    precio            DECIMAL(10,2) NOT NULL CHECK (precio >= 0),
    stock             INT           NOT NULL CHECK (stock >= 0),
    id_editorial      INT           NOT NULL,
    id_categoria      INT           NOT NULL,
    FOREIGN KEY (id_editorial) REFERENCES editorial(id_editorial) ON DELETE RESTRICT,
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria) ON DELETE RESTRICT
);

CREATE TABLE libro_autor (
    isbn     VARCHAR(17) NOT NULL,
    id_autor INT         NOT NULL,
    PRIMARY KEY (isbn, id_autor),
    FOREIGN KEY (isbn)     REFERENCES libro(isbn)     ON DELETE CASCADE,
    FOREIGN KEY (id_autor) REFERENCES autor(id_autor) ON DELETE RESTRICT
);

CREATE TABLE pedido (
    id_pedido    INT AUTO_INCREMENT PRIMARY KEY,
    fecha_pedido DATE NOT NULL DEFAULT (CURRENT_DATE),
    id_cliente   INT  NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE RESTRICT
);

CREATE TABLE detalle_pedido (
    id_pedido       INT           NOT NULL,
    isbn            VARCHAR(17)   NOT NULL,
    cantidad        INT           NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario >= 0),
    PRIMARY KEY (id_pedido, isbn),
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (isbn)      REFERENCES libro(isbn)       ON DELETE RESTRICT
);

CREATE TABLE pago (
    id_pago        INT AUTO_INCREMENT PRIMARY KEY,
    monto          DECIMAL(10,2) NOT NULL CHECK (monto > 0),
    fecha_pago     DATE          NOT NULL DEFAULT (CURRENT_DATE),
    id_pedido      INT           NOT NULL,
    id_metodo_pago INT           NOT NULL,
    FOREIGN KEY (id_pedido)      REFERENCES pedido(id_pedido)           ON DELETE RESTRICT,
    FOREIGN KEY (id_metodo_pago) REFERENCES metodo_pago(id_metodo_pago) ON DELETE RESTRICT
);

-- 3. DATOS DE LA TABLA INICIAL ----------------------------------------
INSERT INTO editorial (nombre) VALUES ('Gallimard'), ('Penguin Classics'), ('Signet Classics');
INSERT INTO categoria (nombre) VALUES ('Infantil'), ('Romance'), ('Ciencia Ficción');
INSERT INTO autor (nombre) VALUES ('Antoine de Saint-Exupéry'), ('Jane Austen'), ('George Orwell');
INSERT INTO metodo_pago (nombre) VALUES ('Tarjeta Crédito'), ('PayPal');

INSERT INTO cliente (nombre, apellido, correo, direccion, telefono) VALUES
 ('Juan',  'Pérez',  'juan.perez@email.com',   'Calle Falsa 123',         '3001234567'),
 ('María', 'García', 'maria.garcia@email.com', 'Avenida Siempreviva 456', '3109876543');

INSERT INTO libro VALUES
 ('978-3-16-148410-0', 'El Principito',       '1943-04-06', 10.00, 50, 1, 1),
 ('978-0-14-143960-0', 'Orgullo y Prejuicio', '1813-01-28', 15.00, 30, 2, 2),
 ('978-0-553-21311-7', '1984',                '1949-06-08', 20.00, 20, 3, 3);

INSERT INTO libro_autor VALUES
 ('978-3-16-148410-0', 1), ('978-0-14-143960-0', 2), ('978-0-553-21311-7', 3);

INSERT INTO pedido (id_cliente) VALUES (1), (2), (1);

INSERT INTO detalle_pedido VALUES
 (1, '978-3-16-148410-0', 1, 10.00),
 (2, '978-0-14-143960-0', 1, 15.00),
 (3, '978-0-553-21311-7', 1, 20.00);

INSERT INTO pago (monto, id_pedido, id_metodo_pago) VALUES
 (10.00, 1, 1), (15.00, 2, 2), (20.00, 3, 1);

-- 4. VERIFICACIÓN: reconstruye la tabla inicial (descomposición sin pérdida)
SELECT l.isbn, l.titulo, a.nombre AS autor, l.fecha_publicacion,
       e.nombre AS editorial, c.nombre AS categoria, l.precio, l.stock,
       CONCAT(cl.nombre, ' ', cl.apellido) AS cliente, cl.correo AS correo_cliente,
       cl.direccion AS direccion_cliente, cl.telefono AS telefono_cliente,
       mp.nombre AS metodo_pago, p.monto
FROM detalle_pedido d
JOIN pedido       pe ON pe.id_pedido = d.id_pedido
JOIN cliente      cl ON cl.id_cliente = pe.id_cliente
JOIN libro        l  ON l.isbn = d.isbn
JOIN editorial    e  ON e.id_editorial = l.id_editorial
JOIN categoria    c  ON c.id_categoria = l.id_categoria
JOIN libro_autor  la ON la.isbn = l.isbn
JOIN autor        a  ON a.id_autor = la.id_autor
JOIN pago         p  ON p.id_pedido = pe.id_pedido
JOIN metodo_pago  mp ON mp.id_metodo_pago = p.id_metodo_pago;

-- 5. Total de cada pedido (valor derivado, no almacenado)
SELECT id_pedido, SUM(cantidad * precio_unitario) AS total_pedido
FROM detalle_pedido
GROUP BY id_pedido;
