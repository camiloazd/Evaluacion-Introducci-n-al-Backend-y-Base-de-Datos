# Tienda de libros · Normalización y modelado E-R

Proyecto de bases de datos: normalización hasta **3FN**, diagrama **conceptual E-R** y diagrama **UML E-R**.

## Contenido

| Archivo | Qué contiene |
|---|---|
| [`01-normalizacion.md`](01-normalizacion.md) | 0FN → 1FN → 2FN → 3FN, paso a paso, con justificación y supuestos |
| [`02-diagrama-conceptual-er.md`](02-diagrama-conceptual-er.md) | Diagrama conceptual, cardinalidades, restricciones y decisiones de diseño |
| [`03-diagrama-uml-er.md`](03-diagrama-uml-er.md) | Diagrama UML de clases y vista E-R con PK/FK, e integridad referencial |
| [`schema.sql`](schema.sql) | Script MySQL con las tablas, datos de ejemplo y consultas de verificación |

## Resumen del modelo final (10 tablas)

`EDITORIAL` · `CATEGORIA` · `AUTOR` · `LIBRO` · `LIBRO_AUTOR` · `CLIENTE` · `PEDIDO` · `DETALLE_PEDIDO` · `METODO_PAGO` · `PAGO`

## Decisiones principales

1. Cada fila original es una línea de pedido; se agregó `id_pedido` y `cantidad`.
2. Un libro puede tener varios autores (tabla `LIBRO_AUTOR`).
3. El precio de la compra se guarda en `DETALLE_PEDIDO.precio_unitario`.
4. El total del pedido se calcula, no se almacena.
5. El pago es una entidad separada del pedido.

## Cómo ver los diagramas

Los diagramas están en Mermaid. GitHub y GitLab los muestran al abrir los `.md`. En local, se pueden ver con la extensión "Markdown Preview Mermaid Support" de VS Code, o pegando el bloque en <https://mermaid.live>.

## Cómo subirlo al repositorio compartido

```bash
git init
git add .
git commit -m "Normalización 3FN y diagramas E-R de la tienda de libros"
git branch -M main
git remote add origin <URL_DEL_REPOSITORIO>
git push -u origin main
```
