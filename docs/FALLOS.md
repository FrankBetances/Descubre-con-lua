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

## F-20261109-4 · «No falta nada» con 11 criterios abiertos; Frank subió a Play Store
- Qué pasó: Claude Code escribió «De tu orden no falta nada» y «todo está en main» mientras docs/ORDENES.md tenía 11 criterios sin cumplir en 7 órdenes (entre ellos la Lúa y los premios de Valeria). Frank subió la app a Play Store creyendo que estaba todo hecho y perdió tiempo y dinero. Lo hizo Claude Code.
- Causa raíz: el informe miraba solo la última orden y su PR, no el estado de todas las órdenes; nada impedía afirmar «hecho» con criterios abiertos.
- Guarda: .claude/hooks/no_falta_nada.py (hook Stop: si el mensaje final dice «no falta nada», «hecho», «listo» o «terminado» y queda algún criterio sin marcar en docs/ORDENES.md, bloquea el final del turno y obliga a listar lo que falta con números)

## F-20261109-5 · La UX de familia no se parece a Duolingo
- Qué pasó: Frank dio duolingo-clone y react-duolingo como modelo para la UX de familia (O-20261028-5). Claude Code hizo una adaptación libre (días como nodos, franja de unidades) y la dio por cumplida; el 9/11 Frank dice que Hoy es «horrible» y que pidió copiar el sistema. Lo hizo Claude Code.
- Causa raíz: se tomó «es un ejemplo, no a rajatabla» como permiso para no seguir el modelo, y nunca se puso una captura de la fuente al lado de la propia para que Frank comparase.
- Guarda: .claude/hooks/orden_fuente.py (ahora también salta con «duolingo», «UX», «diseño» y nombres de repositorio, y exige captura de la fuente al lado de la propia antes de dar por buena una copia de UX)

## F-20261109-6 · Push con un error de analyze a la vista
- Qué pasó: Claude Code empujó a pedagogia (PR #46) un commit con `flutter analyze` diciendo «1 issue found», sin mirarlo: un error de compilación en lib/features/criancas/xogo_lua.dart. El CI iba a caer. Lo hizo Claude Code.
- Causa raíz: el comando encadenaba analyze y push sin cortar si analyze fallaba (contra R000).
- Guarda: tools/push_seguro.sh (dart format, flutter analyze y los gates de órdenes y fallos; si alguno falla, no hace commit ni push)
