# Parte 3 · Diagrama UML Entidad-Relación

Estructura final de la base de datos, derivada del diagrama conceptual. Aquí ya aparecen:

- las **tablas intermedias** que resuelven las relaciones N:M (`LIBRO_AUTOR` y `DETALLE_PEDIDO`),
- todos los **atributos con tipo de dato**,
- las **claves primarias (PK)** y **foráneas (FK)**,
- las **cardinalidades** en ambos extremos.

## 3.1 Diagrama de clases UML

```mermaid
classDiagram
    direction LR

    class EDITORIAL {
        +id_editorial : INT PK
        +nombre : VARCHAR(100) UNIQUE
    }
    class CATEGORIA {
        +id_categoria : INT PK
        +nombre : VARCHAR(60) UNIQUE
    }
    class AUTOR {
        +id_autor : INT PK
        +nombre : VARCHAR(120)
    }
    class LIBRO {
        +isbn : VARCHAR(17) PK
        +titulo : VARCHAR(200)
        +fecha_publicacion : DATE
        +precio : DECIMAL(10,2)
        +stock : INT
        +id_editorial : INT FK
        +id_categoria : INT FK
    }
    class LIBRO_AUTOR {
        +isbn : VARCHAR(17) PK, FK
        +id_autor : INT PK, FK
    }
    class CLIENTE {
        +id_cliente : INT PK
        +nombre : VARCHAR(60)
        +apellido : VARCHAR(60)
        +correo : VARCHAR(120) UNIQUE
        +direccion : VARCHAR(200)
        +telefono : VARCHAR(20)
    }
    class PEDIDO {
        +id_pedido : INT PK
        +fecha_pedido : DATE
        +id_cliente : INT FK
    }
    class DETALLE_PEDIDO {
        +id_pedido : INT PK, FK
        +isbn : VARCHAR(17) PK, FK
        +cantidad : INT
        +precio_unitario : DECIMAL(10,2)
    }
    class METODO_PAGO {
        +id_metodo_pago : INT PK
        +nombre : VARCHAR(40) UNIQUE
    }
    class PAGO {
        +id_pago : INT PK
        +monto : DECIMAL(10,2)
        +fecha_pago : DATE
        +id_pedido : INT FK
        +id_metodo_pago : INT FK
    }

    EDITORIAL "1" --> "0..*" LIBRO : publica
    CATEGORIA "1" --> "0..*" LIBRO : clasifica
    LIBRO "1" --> "1..*" LIBRO_AUTOR : tiene
    AUTOR "1" --> "0..*" LIBRO_AUTOR : escribe
    CLIENTE "1" --> "0..*" PEDIDO : realiza
    PEDIDO "1" --> "1..*" DETALLE_PEDIDO : contiene
    LIBRO "1" --> "0..*" DETALLE_PEDIDO : se vende en
    PEDIDO "1" --> "0..*" PAGO : se cancela con
    METODO_PAGO "1" --> "0..*" PAGO : se usa en
```

## 3.2 Vista E-R con claves (notación pata de gallo)

```mermaid
erDiagram
    EDITORIAL ||--o{ LIBRO : publica
    CATEGORIA ||--o{ LIBRO : clasifica
    LIBRO ||--|{ LIBRO_AUTOR : tiene
    AUTOR ||--o{ LIBRO_AUTOR : escribe
    CLIENTE ||--o{ PEDIDO : realiza
    PEDIDO ||--|{ DETALLE_PEDIDO : contiene
    LIBRO ||--o{ DETALLE_PEDIDO : "se vende en"
    PEDIDO ||--o{ PAGO : "se cancela con"
    METODO_PAGO ||--o{ PAGO : "se usa en"

    EDITORIAL {
        int id_editorial PK
        varchar nombre UK
    }
    CATEGORIA {
        int id_categoria PK
        varchar nombre UK
    }
    AUTOR {
        int id_autor PK
        varchar nombre
    }
    LIBRO {
        varchar isbn PK
        varchar titulo
        date fecha_publicacion
        decimal precio
        int stock
        int id_editorial FK
        int id_categoria FK
    }
    LIBRO_AUTOR {
        varchar isbn PK, FK
        int id_autor PK, FK
    }
    CLIENTE {
        int id_cliente PK
        varchar nombre
        varchar apellido
        varchar correo UK
        varchar direccion
        varchar telefono
    }
    PEDIDO {
        int id_pedido PK
        date fecha_pedido
        int id_cliente FK
    }
    DETALLE_PEDIDO {
        int id_pedido PK, FK
        varchar isbn PK, FK
        int cantidad
        decimal precio_unitario
    }
    METODO_PAGO {
        int id_metodo_pago PK
        varchar nombre UK
    }
    PAGO {
        int id_pago PK
        decimal monto
        date fecha_pago
        int id_pedido FK
        int id_metodo_pago FK
    }
```

## 3.3 Claves foráneas y reglas de integridad referencial

| FK | Referencia | ON DELETE | Motivo |
|---|---|---|---|
| `LIBRO.id_editorial` | `EDITORIAL.id_editorial` | RESTRICT | No borrar una editorial con libros. |
| `LIBRO.id_categoria` | `CATEGORIA.id_categoria` | RESTRICT | No borrar una categoría en uso. |
| `LIBRO_AUTOR.isbn` | `LIBRO.isbn` | CASCADE | Si se borra el libro, se borran sus vínculos con autores. |
| `LIBRO_AUTOR.id_autor` | `AUTOR.id_autor` | RESTRICT | No borrar un autor con libros. |
| `PEDIDO.id_cliente` | `CLIENTE.id_cliente` | RESTRICT | Conservar el historial de ventas. |
| `DETALLE_PEDIDO.id_pedido` | `PEDIDO.id_pedido` | CASCADE | Las líneas no existen sin su pedido. |
| `DETALLE_PEDIDO.isbn` | `LIBRO.isbn` | RESTRICT | No borrar un libro que ya fue vendido. |
| `PAGO.id_pedido` | `PEDIDO.id_pedido` | RESTRICT | Los pagos son registro contable; no se borran en cascada. |
| `PAGO.id_metodo_pago` | `METODO_PAGO.id_metodo_pago` | RESTRICT | Conservar la trazabilidad del método usado. |
