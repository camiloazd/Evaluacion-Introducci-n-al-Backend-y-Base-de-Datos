# Parte 1 · Normalización hasta 3FN

## 0. Tabla inicial (0FN)

Datos tomados de la tabla proporcionada (3 filas):

| ISBN | Título | Autor | Fecha Publicación | Editorial | Categoría | Precio | Stock | Cliente | Correo Cliente | Dirección Cliente | Teléfono Cliente | Método Pago | Monto |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 978-3-16-148410-0 | El Principito | Antoine de Saint-Exupéry | 1943-04-06 | Gallimard | Infantil | 10.00 | 50 | Juan Pérez | juan.perez@email.com | Calle Falsa 123 | 3001234567 | Tarjeta Crédito | 10.00 |
| 978-0-14-143960-0 | Orgullo y Prejuicio | Jane Austen | 1813-01-28 | Penguin Classics | Romance | 15.00 | 30 | María García | maria.garcia@email.com | Avenida Siempreviva 456 | 3109876543 | PayPal | 15.00 |
| 978-0-553-21311-7 | 1984 | George Orwell | 1949-06-08 | Signet Classics | Ciencia Ficción | 20.00 | 20 | Juan Pérez | juan.perez@email.com | Calle Falsa 123 | 3001234567 | Tarjeta Crédito | 20.00 |

**Problemas detectados**

- Redundancia: los datos de Juan Pérez (correo, dirección, teléfono) están repetidos en dos filas.
- Mezcla de cuatro conceptos en una sola tabla: libros, clientes, pedidos y pagos.
- No hay identificador de pedido, y el nombre del cliente mezcla nombre y apellido.
- No hay cantidad comprada, aunque `Monto` depende de ella.

### Supuestos (decisiones tomadas por falta de información)

| # | Supuesto | Justificación |
|---|---|---|
| S1 | Cada fila de la tabla es **una línea de un pedido**; se agrega `id_pedido`. | El enunciado habla de pedidos, pero la tabla no tiene identificador. Sin él, un cliente no podría comprar dos veces el mismo libro. |
| S2 | Se agrega `cantidad` (en los datos de ejemplo vale 1, porque `Monto = Precio`). | Es lo que hace que `Monto` tenga sentido: `Monto = cantidad × precio`. |
| S3 | Un libro puede tener **varios autores** y un autor **varios libros**. | Es el caso real en una librería; modelarlo desde el inicio evita rediseñar. |
| S4 | El correo del cliente es único y lo identifica. | Es el único dato único que trae la tabla. Se usará además una clave sustituta `id_cliente`. |
| S5 | Se agregan `fecha_pedido` y `fecha_pago`. | Son atributos naturales de un pedido y de una transacción; no estaban en la tabla original. |

---

## 1. Primera Forma Normal (1FN)

**Regla:** todos los atributos son atómicos, no hay grupos repetitivos y existe una clave primaria.

**Acciones**

1. `Cliente` se separa en `nombre_cliente` y `apellido_cliente` (valor atómico).
2. Se agregan `id_pedido` y `cantidad` (supuestos S1 y S2).
3. `Monto` se mantiene por ahora, y `Método Pago` también.
4. Se define la clave primaria compuesta **(id_pedido, isbn)**: identifica cada línea de pedido.

**Nota sobre atomicidad:** `direccion` se deja como un único campo de texto porque el sistema solo la usa para envío y no para filtrar o agrupar por ciudad o barrio. Si se necesitara, se dividiría en calle, ciudad y departamento.

**Resultado (1FN)** — `PEDIDO_LINEA`

`PK = (id_pedido, isbn)`

| id_pedido | isbn | titulo | autor | fecha_publicacion | editorial | categoria | precio | stock | nombre_cliente | apellido_cliente | correo_cliente | direccion_cliente | telefono_cliente | metodo_pago | cantidad | monto |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 978-3-16-148410-0 | El Principito | Antoine de Saint-Exupéry | 1943-04-06 | Gallimard | Infantil | 10.00 | 50 | Juan | Pérez | juan.perez@email.com | Calle Falsa 123 | 3001234567 | Tarjeta Crédito | 1 | 10.00 |
| 2 | 978-0-14-143960-0 | Orgullo y Prejuicio | Jane Austen | 1813-01-28 | Penguin Classics | Romance | 15.00 | 30 | María | García | maria.garcia@email.com | Avenida Siempreviva 456 | 3109876543 | PayPal | 1 | 15.00 |
| 3 | 978-0-553-21311-7 | 1984 | George Orwell | 1949-06-08 | Signet Classics | Ciencia Ficción | 20.00 | 20 | Juan | Pérez | juan.perez@email.com | Calle Falsa 123 | 3001234567 | Tarjeta Crédito | 1 | 20.00 |

---

## 2. Segunda Forma Normal (2FN)

**Regla:** estar en 1FN y que ningún atributo no clave dependa de **solo una parte** de una clave compuesta.

**Dependencias funcionales sobre la PK (id_pedido, isbn)**

| Dependencia | Tipo |
|---|---|
| `isbn → titulo, autor, fecha_publicacion, editorial, categoria, precio, stock` | **Parcial** (depende solo de `isbn`) |
| `id_pedido → nombre_cliente, apellido_cliente, correo_cliente, direccion_cliente, telefono_cliente, metodo_pago, monto, fecha_pedido` | **Parcial** (depende solo de `id_pedido`) |
| `(id_pedido, isbn) → cantidad, precio_unitario` | Total (depende de toda la clave) |

**Anomalías que causan las dependencias parciales**

- *Inserción:* no se puede registrar un libro nuevo hasta que alguien lo compre.
- *Actualización:* cambiar el precio o el stock de un libro obliga a editar todas las filas donde aparece.
- *Eliminación:* si se borra el único pedido de un libro, se pierde el libro.

**Acciones:** se separa cada grupo según de qué parte de la clave depende, y se agrega `precio_unitario` a la línea de pedido para conservar el precio **al momento de la compra**, porque el precio del catálogo puede cambiar después.

**Resultado (2FN)**

**LIBRO** — `PK = isbn`

| isbn | titulo | autor | fecha_publicacion | editorial | categoria | precio | stock |
|---|---|---|---|---|---|---|---|
| 978-3-16-148410-0 | El Principito | Antoine de Saint-Exupéry | 1943-04-06 | Gallimard | Infantil | 10.00 | 50 |
| 978-0-14-143960-0 | Orgullo y Prejuicio | Jane Austen | 1813-01-28 | Penguin Classics | Romance | 15.00 | 30 |
| 978-0-553-21311-7 | 1984 | George Orwell | 1949-06-08 | Signet Classics | Ciencia Ficción | 20.00 | 20 |

**PEDIDO** — `PK = id_pedido`

| id_pedido | fecha_pedido | nombre_cliente | apellido_cliente | correo_cliente | direccion_cliente | telefono_cliente |
|---|---|---|---|---|---|---|
| 1 | *(fecha)* | Juan | Pérez | juan.perez@email.com | Calle Falsa 123 | 3001234567 |
| 2 | *(fecha)* | María | García | maria.garcia@email.com | Avenida Siempreviva 456 | 3109876543 |
| 3 | *(fecha)* | Juan | Pérez | juan.perez@email.com | Calle Falsa 123 | 3001234567 |

**PAGO_2FN** (`metodo_pago` y `monto` dependen del pedido) — `PK = id_pedido`

| id_pedido | metodo_pago | monto |
|---|---|---|
| 1 | Tarjeta Crédito | 10.00 |
| 2 | PayPal | 15.00 |
| 3 | Tarjeta Crédito | 20.00 |

**DETALLE_PEDIDO** — `PK = (id_pedido, isbn)`

| id_pedido | isbn | cantidad | precio_unitario |
|---|---|---|---|
| 1 | 978-3-16-148410-0 | 1 | 10.00 |
| 2 | 978-0-14-143960-0 | 1 | 15.00 |
| 3 | 978-0-553-21311-7 | 1 | 20.00 |

> `PAGO_2FN` se muestra separada de `PEDIDO` porque el pago es una **transacción** distinta del pedido (el enunciado las menciona por separado) y en 3FN se convierte en su propia entidad.

---

## 3. Tercera Forma Normal (3FN)

**Regla:** estar en 2FN y que ningún atributo no clave dependa de **otro atributo no clave** (sin dependencias transitivas).

### 3.1 Dependencias transitivas encontradas

| Tabla | Dependencia transitiva | Solución |
|---|---|---|
| PEDIDO | `id_pedido → correo_cliente → nombre, apellido, dirección, teléfono` | Extraer **CLIENTE** |
| LIBRO | `isbn → editorial` (la editorial es una entidad con identidad propia) | Extraer **EDITORIAL** |
| LIBRO | `isbn → categoria` | Extraer **CATEGORIA** |
| LIBRO | `autor` es multivaluado en la realidad (S3) | Extraer **AUTOR** + tabla intermedia **LIBRO_AUTOR** |
| PAGO_2FN | `metodo_pago` es un catálogo reutilizable por muchos pagos | Extraer **METODO_PAGO** |

**Sobre `monto`:** con `cantidad × precio_unitario` el total del pedido se puede **calcular**, por lo que no se guarda en `PEDIDO`. El `monto` que sí se guarda en `PAGO` es lo efectivamente cobrado en esa transacción. Así se evita un valor derivado que pueda quedar inconsistente.

**Honestidad técnica:** en los datos de ejemplo, `Editorial`, `Categoría` y `Método Pago` solo tienen su nombre como atributo. Estrictamente, extraerlos es una **decisión de diseño** más que una obligación formal de 3FN. Se justifica porque:

1. Evita inconsistencias de escritura (`Penguin Classics` vs `penguin classics`).
2. Permite agregar atributos después (país de la editorial, comisión del método de pago).
3. Permite renombrar una categoría en un solo lugar.

### 3.2 Esquema final en 3FN

| Tabla | Clave primaria | Claves foráneas | Atributos |
|---|---|---|---|
| **EDITORIAL** | `id_editorial` | — | `nombre` (único) |
| **CATEGORIA** | `id_categoria` | — | `nombre` (único) |
| **AUTOR** | `id_autor` | — | `nombre` |
| **LIBRO** | `isbn` | `id_editorial`, `id_categoria` | `titulo`, `fecha_publicacion`, `precio`, `stock` |
| **LIBRO_AUTOR** | (`isbn`, `id_autor`) | `isbn`, `id_autor` | — |
| **CLIENTE** | `id_cliente` | — | `nombre`, `apellido`, `correo` (único), `direccion`, `telefono` |
| **PEDIDO** | `id_pedido` | `id_cliente` | `fecha_pedido` |
| **DETALLE_PEDIDO** | (`id_pedido`, `isbn`) | `id_pedido`, `isbn` | `cantidad`, `precio_unitario` |
| **METODO_PAGO** | `id_metodo_pago` | — | `nombre` (único) |
| **PAGO** | `id_pago` | `id_pedido`, `id_metodo_pago` | `monto`, `fecha_pago` |

### 3.3 Verificación de 3FN

En cada tabla, todo atributo no clave depende **de la clave, de toda la clave y nada más que la clave**:

| Tabla | Dependencia funcional |
|---|---|
| EDITORIAL | `id_editorial → nombre` |
| CATEGORIA | `id_categoria → nombre` |
| AUTOR | `id_autor → nombre` |
| LIBRO | `isbn → titulo, fecha_publicacion, precio, stock, id_editorial, id_categoria` |
| CLIENTE | `id_cliente → nombre, apellido, correo, direccion, telefono` |
| PEDIDO | `id_pedido → id_cliente, fecha_pedido` |
| DETALLE_PEDIDO | `(id_pedido, isbn) → cantidad, precio_unitario` |
| METODO_PAGO | `id_metodo_pago → nombre` |
| PAGO | `id_pago → id_pedido, id_metodo_pago, monto, fecha_pago` |

### 3.4 Los datos originales, ya normalizados

Nada se pierde en la descomposición: la consulta de `schema.sql` (sección 4) reconstruye la tabla inicial con JOINs.

**EDITORIAL:** 1 Gallimard · 2 Penguin Classics · 3 Signet Classics
**CATEGORIA:** 1 Infantil · 2 Romance · 3 Ciencia Ficción
**AUTOR:** 1 Antoine de Saint-Exupéry · 2 Jane Austen · 3 George Orwell
**METODO_PAGO:** 1 Tarjeta Crédito · 2 PayPal
**CLIENTE:** 1 Juan Pérez (juan.perez@email.com) · 2 María García (maria.garcia@email.com)
Ahora Juan aparece **una sola vez**, y sus dos pedidos apuntan a `id_cliente = 1`.

### 3.5 Anomalías resueltas

| Anomalía | Antes | Ahora |
|---|---|---|
| Inserción | No se podía crear un libro sin pedido | `LIBRO` existe por sí sola |
| Actualización | Cambiar la dirección de Juan = editar varias filas | Se edita 1 fila en `CLIENTE` |
| Eliminación | Borrar un pedido borraba datos del libro y del cliente | Borrar un pedido solo borra pedido, detalle y pago |
