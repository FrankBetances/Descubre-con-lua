# Fallos de Claude Code y su guarda

Orden de automejora de Frank (O-20261109-2, 9/11/2026): cada fallo que Frank
señala entra aquí, con lo que pasó, la causa raíz y **la guarda** —un hook, un
gate o un test— que lo habría parado. La guarda se crea en el mismo cambio.
`tools/check_fallos.py` tumba CI si una entrada no nombra una guarda que exista.

Formato de cada entrada (una por fallo):

```
## F-AAAAMMDD-n · título
- Qué pasó: …
- Causa raíz: …
- Guarda: ruta/al/fichero (y qué comprueba)
```

## F-20261109-1 · Lúa y los premios no se copiaron de Valeria
- Qué pasó: Frank pidió «incorporar la mascota lua y el diseño de premios» (O-20261109-1) y quería los de Valeria. Claude Code usó la gata quieta y las medallas que ya había en este repositorio, sin abrir Valeria ni preguntar de dónde copiar. Lo hizo Claude Code.
- Causa raíz: la orden nombraba una pieza que existe en otro producto de la casa (CLAUDE.md, 5b) y Claude Code la sustituyó por «lo parecido» que ya había aquí, contra R∞.2.
- Guarda: .claude/hooks/orden_fuente.py (en cada mensaje que pida copiar, traer, imitar, o nombre la mascota, los premios u otro producto, obliga a abrir la fuente y escribir «Fuente:»), y tools/check_ordenes.py (cada orden desde O-20261109-2 sin línea «Fuente:» válida tumba CI)

## F-20261109-2 · Manual dado por actualizado con capturas viejas
- Qué pasó: Claude Code dijo que el manual estaba al día; 16 de sus 54 capturas enseñaban pantallas antiguas y el calendario de lecciones no salía. Lo hizo Claude Code.
- Causa raíz: solo se generaron las capturas nuevas; no se regeneraron las existentes ni se comprobó que cada pantalla actual tuviera la suya.
- Guarda: .claude/hooks/orden_fuente.py (si el mensaje nombra el manual, obliga a regenerar todas las capturas, mirar las que cambian y revisar el PDF página a página)

## F-20261109-3 · Sin mecanismo para no repetir fallos
- Qué pasó: Frank tuvo que repetir las mismas reglas muchas veces; un fallo corregido no dejaba nada que impidiera el siguiente.
- Causa raíz: las reglas vivían solo como texto en CLAUDE.md, sin nada que las ejecutara.
- Guarda: tools/check_fallos.py (cada fallo de este fichero con su guarda existente) y .claude/hooks/orden_fuente.py (cuando Frank señala un fallo, inyecta el protocolo de automejora)
