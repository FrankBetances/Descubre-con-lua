# Plan para Antigravity · todo lo pendiente (O-20261118-2 y O-20261118-3)

Lo ejecuta Antigravity. Lo revisa Claude Code cuando Antigravity diga «listo»,
criterio por criterio, con los gates corridos y las capturas miradas. Escrito
el 18/11/2026 a partir de `docs/ORDENES.md` de `main` y de las ramas con
trabajo fuera de `main`.

Antes de empezar, lee `CLAUDE.md` entero (R∞, R0, R000, R1…R7). Valen igual
para Antigravity.

## Cifras de partida (medidas, no estimadas)

| Qué | Cifra | Dónde se mide |
| --- | --- | --- |
| Piezas enseñadas sin lámina | **6.351 de 6.382** (en caca7cb5) | `python3 tools/check_laminas_leccion.py --resumo` |
| Órdenes abiertas en `docs/ORDENES.md` de main | 10, con 14 criterios sin marcar | `grep -c "^- \[ \]" docs/ORDENES.md` |
| Unidades de la ruta sin material semanal completo | 28 (de la 21 a la 48) | O-20261028-7 y O-20261028-8 |

La cifra de piezas sin lámina se vuelve a medir al acabar el bloque 0. La
referencia del bloque 2 es esa cifra nueva, no la de caca7cb5.

## Ramas con trabajo fuera de main

| Rama | Commits | Qué es |
| --- | --- | --- |
| `feat/laminas-ejercicios` | 1973cc64, 303be16e, caca7cb5 | O-20261111-2: gate de láminas, arreglo del toque de los días y las 9 láminas de la lección `curso_4_5.03.2` |
| `fix/dias-hoy` | 91e29317, 28ba2dcb | O-20261111-3: el mismo arreglo de los días, cherry-pick para llevarlo solo a main. Sin mergear |
| `claude/upbeat-fermi-3d0utp` | los de O-20261118-1 | Lúa más grande, junto al camino y con flor y lazo en Hoy |
| `claude/charming-euler-9i23cj` | 3653cacd | O-20261116-1: plan para que la app pese menos. Es solo un documento |

**Una sola rama de trabajo:** `antigravity/pendiente`, creada desde
`origin/feat/laminas-ejercicios` y con `origin/main` mezclado encima en P0.3
(así trae el plan, lo de Lúa, la versión de Flutter fijada en CI y el gate del
registro, que entran en `main` con el PR #51). Ningún otro agente toca esos ficheros
mientras Antigravity trabaja. Claude Code no empuja nada a esa rama.

## Pasos (el único plan; cada commit lleva el identificador de su paso)

Este fichero es **el único plan** de lo pendiente. Cada commit empieza por el
identificador de su paso (`P2.1: …`) y deja su fila en el «Registro de
commits» del final. Así Frank y Claude Code auditan el trabajo commit a
commit. Lo vigila `tools/check_registro_commits.py`, dentro de `tools/gates.sh`.

| Paso | Qué | Bloque | Para y espera a Frank |
| --- | --- | --- | --- |
| P0.1 | Rescate: detectar y conservar el trabajo local sin subir | 0 | si aparece algo sin subir |
| P0.2 | Crear `antigravity/pendiente` desde `origin/feat/laminas-ejercicios` e integrar lo útil del rescate | 0 | no |
| P0.3 | `git merge origin/main` (trae O-20261118-1, el plan y CI) y poner su SHA en «Base:» del registro | 0 | no |
| P0.4 | Cerrar O-20261111-3 como absorbida | 0 | no |
| P1.1 | Anotar la fuente de las imágenes y corregir a estilo Flat (`O-20261111-4`), con su licencia | 1 | **sí** |
| P2.0 | Medir cobertura real en Fluent Emoji (`docs/cobertura-fluent.md`) antes de copiar | 2 | **sí** |
| P2.01 | P2.0b: medir cobertura sobre (c) con fuentes compatibles con uso comercial y derivadas | 2 | **sí** |
| P2.1 | Conversor `banco_a_lamina.py`, reparación `lamina_vector.dart`, mapa ampliado, créditos/licencias y gate `check_banco_laminas.py` | 2 | no |
| P2.2 | 4-5 años completo (U/R/C/D): 0 piezas sin lámina en 4-5, cifras, hoja de contactos y nota de capturas gl/es | 2 | **sí**: mira tres semanas al azar |
| P2.21 | Revisión P2.2: dart format en lamina_vector/test, sustituir pal_sand/protect/temperature (sin caras) y 5 pasos de curso_4_5 en test/capturas_test.dart | 2 | no |
| P2.3 | 0-2 años completo a 0 piezas sin lámina | 2 | no (aprobado estilo 4-5) |
| P2.4 | 2-3 años completo a 0 piezas sin lámina | 2 | **sí** |
| P2.5 | 3-4 años completo a 0 piezas sin lámina | 2 | **sí** |
| P2.6 | 5-6 años completo a 0 piezas sin lámina | 2 | **sí** |
| P2.7 | Verificación 6-7 años: la app solo tiene 5 cursos (0-2..5-6 = 6.º Infantil); no existe curso_6_7 | 2 | no |
| P2.71 | Claude Code: lecciones P2.1–P2.7 a main; gate TPR con tope que solo baja (O-20261119-1) | 2 | no |
| P2.72 | Claude Code: evidencia del merge de las lecciones y arreglo del gate del registro en main | 2 | no |
| P2.8 | Banco TPR (4.000 piezas) cubierto, agrupado por gesto | 2 | no |
| P2.9 | Cierre bloque 2: `check_laminas_leccion.py` = 0 en todo, tests de pasos en verde, `docs/ORDENES.md` al día | 2 | no |
| P2.81 | Revisión P2.8: quitar `revisado` automático y las 3.260 láminas sin objeto/con homónimos; dejar solo 159 directas verificadas (740/4.000 TPR cubiertas, 3.260 sin lámina); reabrir O-20261111-4 TPR y O-20261111-2 | 2 | no |
| P2.82 | Tanda 1 TPR (200 revisadas palabra+gesto: cuidados del bebé, descanso, silencio, esconderse/cucú, sentarse/tumbarse/agacharse, escuchar, oler y asentir; 43 auditadas sin base en `docs/tpr_sin_base.md`; quedan 3.060 sin lámina) | 2 | no |
| P2.83 | Tanda 2 TPR (200 revisadas palabra+gesto: equilibrio/inclinarse, gatear, saltar, correr, girar/rodar y primer bloque de caminar; 34 auditadas sin base en `docs/tpr_sin_base.md`, acum. 77; quedan 2.860 sin lámina) | 2 | no |
| P2.84 | Tanda 3 TPR (200 revisadas palabra+gesto: cierre de gatear/correr/caminar, palmas/ritmo completo y primer bloque de abrazos/caricias; 54 auditadas sin base en `docs/tpr_sin_base.md`, acum. 131; quedan 2.660 sin lámina) | 2 | no |
| P2.85 | Tanda 4 TPR (200 revisadas palabra+gesto: cierre de abrazos/caricias, empujar/tirar, lanzar/atrapar, brazos arriba, levantar la mano, brazos abiertos, saludar, equilibrio/cuclillas/giro y primer bloque de agua; 55 auditadas sin base en `docs/tpr_sin_base.md`, acum. 186; quedan 2.460 sin lámina) | 2 | no |
| P2.86 | Tanda 5 TPR (200 revisadas palabra+gesto: cierre completo de acciones con agua, comer/beber, dar/ofrecer, soplar, parar/equilibrio/comparar, sacudir/temblar, alegrarse/sonreír, sostener/llevar y primeras 3 de crear/dibujar; 32 auditadas sin base en `docs/tpr_sin_base.md`, acum. 218; quedan 2.260 sin lámina) | 2 | no |
| P2.87 | Tanda 6 TPR (200 revisadas palabra+gesto: cierre completo de crear/dibujar, enseñar/mostrar, hablar/cantar, contar/dedos y primer bloque de tocar/cuerpo; 71 auditadas sin base en `docs/tpr_sin_base.md`, acum. 289; quedan 2.060 sin lámina) | 2 | no |
| P2.88 | Tanda 7 TPR (200 revisadas palabra+gesto: cierre completo de tocar/cuerpo y abrir/cerrar, y primer bloque de señalar; 67 auditadas sin base en `docs/tpr_sin_base.md`, acum. 356; quedan 1.860 sin lámina) | 2 | no |
| P2.89 | Tanda 8 TPR (200 revisadas palabra+gesto: cierre completo de señalar (`point`) y mirar (`look`), y primer bloque de mover (`move`); 127 auditadas sin base en `docs/tpr_sin_base.md`, acum. 483; quedan 1.660 sin lámina) | 2 | no |
| P2.90 | Tanda 9 TPR (200 revisadas palabra+gesto: cierre completo de mover (`move`) y primer bloque de `present_object`; 57 auditadas sin base en `docs/tpr_sin_base.md`, acum. 540; quedan 1.460 sin lámina) | 2 | no |
| P2.91 | Tanda 10 TPR (200 revisadas palabra+gesto: segundo bloque de `present_object` (`crayon pot`..`jumper`); 68 auditadas sin base en `docs/tpr_sin_base.md`, acum. 608; quedan 1.260 sin lámina) | 2 | no |
| P2.92 | Claude Code: las 10 tandas TPR a main; tope TPR 3419 → 1260 (O-20261119-2) | 2 | no |
| P2.99 | Claude Code: decisiones de Frank sobre el banco TPR (O-20261119-3: 608 sin imagen) | 2 | no |
| P2.93 | Tanda 11 TPR (200 revisadas palabra+gesto: bloque `jumping`..`scratch`; 86 auditadas sin base en `docs/tpr_sin_base.md`, acum. 694; quedan 1.060 sin lámina) | 2 | no |
| P2.94 | Tanda 12 TPR (200 revisadas palabra+gesto: bloque `script`..`weather chart`; 107 auditadas sin base en `docs/tpr_sin_base.md`, acum. 801; quedan 860 sin lámina) | 2 | no |
| P2.97 | Claude Code: 227 sin base aprobadas, 12 escenas rehechas, lámina en palabras del día (O-20261119-6) | 2 | no |
| P2.96 | Claude Code: tandas 11-13 a main; unidades 21-48 cubiertas (O-20261119-5); tope TPR a 227 | 2 | no |
| P2.95 | Tanda 13 TPR (cierre: últimas 25 revisadas palabra+gesto `weight`..`zipper pull` + 34 auditadas sin base en `docs/tpr_sin_base.md`, acum. 835; 4.000/4.000 TPR auditadas, tope bajado a 835) | 2 | no |
| P3.1 | Unidades 21-48 con su material semanal completo | 3 | si falta base en `referencias/` |
| P3.2 | Capturas de escritorio de Hoy en las cinco edades, gl y es | 3 | no |
| P3.3 | 4-5 años: lo de hoy en la primera pantalla de 412×915 | 3 | no |
| P4.1 | Cierres de papeleo con PR, SHA y run en verde | 4 | no |
| P6.1 | Claude Code: rediseño UX/UI, tanda 1: movimiento en Hoy, lección, fin y Modo Aula, con «reducir movimiento» (O-20261119-7) | 6 | no |
| P6.2 | Evidencia del merge del rediseño, tanda 1 (PR #61) | 6 | no |
| P7.0 | Claude Code: orden O-20261119-8, glosas y extractor del banco de Valeria | 7 | no |
| P7.1 | Antigravity: gate fonético de los pares en inglés (CMUdict, un solo fonema distinto) | 7 | no |
| P7.2 | Antigravity: las 40 piezas mensuales (par, progresión y modelo del adulto) de 2-3, 3-4, 4-5 y 5-6 en assets/content/escoita/plan_mensual.json | 7 | no |
| P7.3 | Antigravity: las láminas que faltan para el banco de escucha (fuentes de O-20261111-4) | 7 | no |
| P7.4 | Antigravity: hoja de contactos y docs/escoita-control.md | 7 | sí: Claude Code revisa |
| P7.5 | Claude Code: banco de Valeria (gl, es, en) y Juegos de escucha, pasos de escucha en la lección, Fredoka, movimiento de Valeria, reglas R-FRANK y frenos (O-20261119-8, O-20261119-9) | 7 | no |
| P7.6 | Antigravity: rehacer las 40 piezas de plan_mensual.json orientadas al STEAM de su mes, con campos steam (docs/PROMPTS_ANTIGRAVITY.md) | 7 | no |
| P7.7 | Antigravity: láminas de las palabras nuevas de P7.6 y de las que faltan en el banco de Valeria | 7 | no |
| P7.8 | Antigravity: control de las 40 piezas con qué del STEAM nombra cada palabra, y hoja de contactos | 7 | sí: Claude Code revisa |
| P7.9 | Antigravity: los 16 pares cuya segunda palabra no nombra el STEAM, rehechos (las dos palabras del experimento) | 7 | sí: Claude Code revisa |
| P8.1 | Claude Code: frenos corregidos y probados (F-20261119-5 y 6), R-ENTREGA, lectura de plan_mensual con «piezas», voz solo del banco que la app enseña | 8 | no |
| P8.2 | Claude Code: pasos P7.6–P7.8 en la tabla, prompts de Antigravity guardados en el repositorio y su gate (F-20261119-7) | 8 | no |
| P8.3 | Claude Code: O-20261118-3 vuelve a su alcance (todas las edades, STEAM), sin el piloto que Frank no pidió, y gate contra recortes en los criterios (F-20261119-8) | 8 | no |
| P8.4 | Claude Code: Modo Aula como camino con banner, igual que casa (O-20261119-7) | 8 | no |
| P8.5 | Claude Code: Juegos de escucha con tarjetas blancas y GL/ES que cambia la pantalla abierta; insignias comparadas con Valeria; capturas y evidencias de O-20261119-8 | 8 | no |
| P8.6 | Claude Code: gate de STEAM por palabra en plan_mensual (F-20261119-9) y prompt P7.9 | 8 | no |
| P8.7 | Claude Code: las 40 piezas de Antigravity integradas; 16 pares pendientes de P7.9 sin enseñarse; significados gl/es del modelo del adulto | 8 | no |
| P5.1 | Proponer la unidad y los pares del piloto de escucha y palabras | 5 | **sí** |
| P5.2 | Revisión de los pares por Frank o una logopeda | 5 | **sí** |
| P5.3 | Construir el piloto con su gate y capturas gl/es | 5 | no |
| P5.4 | Frank lo ve en la app y aprueba extenderlo | 5 | **sí** |

## Bloque 0 · Rescate e integración

1. Ejecuta el «BLOQUE 0 · RESCATE» que Frank te dio el 18/11, tal cual, en la
   carpeta de Frank (no en un worktree propio). Pega la salida entera.
2. Crea `antigravity/pendiente` desde `origin/feat/laminas-ejercicios` y mete
   ahí lo útil del rescate, con los JSON de contenido regenerados con sus
   generadores, nunca copiados a mano.
3. Con el PR #51 ya en `main`, `git merge origin/main` en
   `antigravity/pendiente` (merge, no rebase ni cherry-pick). **Choque
   esperado** en `lib/features/familias/widgets/learn_duolingo.dart`: 303be16e
   cambia cómo recibe el toque cada nodo y O-20261118-1 coloca a Lúa. Hay que
   quedarse con las dos cosas:
   - los nodos responden al toque (test «os nodos dos días responden sempre,
     sen tocar o banner»);
   - Lúa en `Positioned(key: Key('learn_lua'), left: ancho/2 + 28, top: 96)`,
     de 112 de ancho, con `cabeza`/`pescozo` del niño o, si no lleva nada, los
     de `deInicio` de `assets/content/premios/premios_lua.json` (test «Lúa,
     grande, ao lado do camiño e con accesorios»).
4. `fix/dias-hoy` no se mergea aparte: su arreglo ya va en 303be16e. Cierra
   O-20261111-3 en `docs/ORDENES.md` diciendo que queda absorbida por esta rama
   y que el merge que la cumple es el de esta rama.

Hecho del bloque 0: los dos tests de arriba en verde y la cifra nueva de
`check_laminas_leccion.py --resumo` escrita en la entrega.

## Bloque 1 · Decisión previa de Frank sobre las imágenes (no empezar el bloque 2 sin ella)

Frank dice que dio unos repositorios para sacar imágenes. En el repositorio
solo queda escrito «el banco Fluent/Iconify», en O-20261111-3, y en ninguna
rama está la orden que lo define. **Pregunta a Frank, en la primera línea:**

- ¿La fuente es **Fluent Emoji** de Microsoft (`microsoft/fluentui-emoji`,
  licencia MIT), servida por Iconify, o es otra? ¿En qué estilo: *flat*,
  *color* o *3D*?
- ¿Sustituye al set vectorial propio (`assets/brand/laminas/`, 349 láminas)
  o lo completa donde no haya una que coincida?

**Dato por verificar:** la licencia y el estilo se comprueban en el
repositorio de origen antes de copiar nada, y se anotan en `docs/ORDENES.md`
(«Fuente: microsoft/fluentui-emoji:assets/<carpeta>, MIT»).

Límites que no cambian, sea cual sea la respuesta:

- las imágenes se empaquetan en el APK; nada se pide a la red (sin permiso
  INTERNET);
- son ficheros propios (SVG/PNG en `assets/`), nunca caracteres emoji del
  sistema: `tools/check_no_emoji.py` sigue mandando;
- el crédito y la licencia se escriben en la pantalla de créditos y en `docs/`;
- `referencias/base/curriculo-vocabulario-infantil-2-6.txt`, línea 287, pide
  evitar los pictogramas abstractos: cada imagen tiene que entenderse sin leer
  el texto.

## Bloque 2 · Imágenes de los ejercicios (O-20261111-2 y O-20261111-1 reabierta)

Los criterios están en `docs/ORDENES.md` de `feat/laminas-ejercicios`
(A1–A6, C1, C3). Lo que pide Frank y cómo se comprueba:

| Qué ve Frank | Camino | Gate o test |
| --- | --- | --- |
| Al tocar el día, la imagen de la escena se entiende (las 12 escenas, rehechas con la fuente del bloque 1, no el triángulo rosa del pañuelo) | Na casa → Hoy → nodo del día → primer paso | `tools/check_imagenes_escenas.py`; capturas `escena-duolingo-gl/-es` |
| Cada palabra y cada frase, en cada paso tras «Continuar», lleva su imagen, que muestra ESA palabra y su gesto | Na casa → Hoy → nodo del día → Continuar… | `tools/check_laminas_leccion.py` (0 piezas sin lámina) y el test de `curso_4_5.03.2` paso a paso |
| La frase de gramática lleva imagen | el paso de la frase | el mismo gate |
| 0-2: todos los pasos del proyecto con imagen | Na casa → Hoy con un niño de 0-2 | test «0-2: todos os pasos…» |
| La escena del reto solo sale en el paso del reto, nunca en una palabra | Curl into a ball, Downhill, Steep | test de `curso_4_5.03.2` |

Orden de trabajo, para que Frank vea antes lo primero:

1. Las 12 escenas de reto, con la fuente nueva. Captura gl/es y para:
   Frank mira tres y dice si el estilo vale. **No se sigue sin su sí**
   (R∞.6.3).
2. Las palabras de la lección de 4-5 años entera (las 40 semanas), por la
   misma razón: una edad entera primero.
3. El resto de edades y el banco TPR, hasta llegar a 0 piezas sin lámina.

Prohibido: repetir una imagen para que cuadre la cifra, usar la escena del
reto para una palabra o meter listas de exclusión en el gate.
`docs/laminas-ejercicios.md` lleva una fila por pieza con la imagen elegida y
por qué coincide.

## Bloque 3 · Contenido pendiente

| Orden | Criterio abierto | Cómo se cierra |
| --- | --- | --- |
| O-20261028-7 / -8 | Unidades 21-48 (B1-C1) con su material semanal completo para la persona adulta | Redactarlo desde `referencias/base/` (R∞.2: si no hay base para una unidad, se dice y se pregunta a Frank, no se rellena). Gate: el validador de unidades falla si una de las 48 no tiene su contenido |
| O-20261028-7 | Visto en la app de escritorio por Na casa → Hoy en las cinco edades, en gl y es | Capturas de escritorio (CLAUDE.md §1d) en `docs/capturas/escritorio/` |
| O-20261028-4 | 4-5 años: etapa, palabras de la semana, gramática y lo de hoy en la primera pantalla de 412×915 | Test a 412×915 que mide que esas cuatro piezas quedan por encima de la barra |

**Decisiones de Frank que bloquean y no se toman por él:**

- 0-2 sin contraste de sonido (O-20261101-1);
- reparto de las unidades 1-9 en los meses de 0-2 (aplazado el 10/11).

## Bloque 4 · Cierre de papeleo

Cada «Mergeado en main con CI en verde» abierto (O-20261028-6,
O-20261109-2, -3, -4, -5, O-20261110-1) se marca **solo** con el PR, el SHA del
merge y el número de run en verde, mirados en GitHub. Si no hay run en verde,
se queda abierto y se dice. O-20261028-9 tiene todos sus criterios con
evidencia: se pasa a «cumplida».

## Bloque 5 · Juegos de escucha y palabras (O-20261118-3, opción A)

Frank eligió el 18/11/2026 integrar pares mínimos y expansión semántica,
unidos al STEAM y al inglés, **como estimulación del lenguaje para todos los
niños, no como logopedia**. La app sigue sin finalidad sanitaria (regla de
producto de `CLAUDE.md`). Nada de diagnóstico, puntuación de errores,
niveles de dificultad por niño ni cribado.

**Depende del bloque 2.** Un par mínimo sin sus dos imágenes no funciona: el
piloto usa las imágenes de la fuente que Frank confirme en el bloque 1. Se
puede redactar el contenido mientras tanto, pero no se da por hecho sin
imágenes.

### Qué se construye: tres pasos nuevos en la lección de la semana

| Paso | Qué hace el adulto | De dónde sale |
| --- | --- | --- |
| **Escucha y señala** (pares mínimos) | Dice una de las dos palabras; el niño señala su imagen; el adulto confirma. Nota gl/es de cómo se nota la diferencia (como la de pear/bear: «coa man diante da boca») | El campo `contraste` que ya tiene cada unidad (`assets/content/unidades_mes/`); si el par del mes no encaja con el STEAM de la semana, se propone otro del banco y se marca para revisión |
| **¿Qué sabemos de…?** (expansión semántica) | Con una palabra del STEAM de la semana: qué es (categoría), para qué sirve (función), cómo es (atributo) y dónde está (lugar). Ejemplo: *sponge — it's soft, it drinks water, it's in the bathroom* | Las palabras del STEAM de esa semana en `leccions.json` |
| **Tú lo amplías** (expansión gramatical) | Modelo grabado: el niño dice «water», el adulto responde «yes, cold water». Sin corregir ni pedir que repita | `referencias/base/estrategias-apoyo-linguistico.txt`, Estrategia 2 |

Todo en JSON de contenido, con texto gl/es, voz en/gl/es regenerada en el
mismo commit (regla 1b) e imagen en cada palabra.

### Orden de trabajo

1. **Piloto: una unidad de 4-5 años, sus 4 semanas.** Antes de escribir,
   Antigravity propone en `docs/ORDENES.md` qué unidad y qué pares, y para.
2. Frank (o una logopeda que él designe) revisa que los pares difieren en un
   solo fonema y son adecuados a 4-5 años.
3. Se construye el piloto, con su gate y sus capturas gl/es.
4. Frank lo abre en la app (Na casa → Hoy → día → Continuar) en tres semanas.
   **Solo con su sí** se extiende a otras unidades y edades (R∞.6.3).

### Gate nuevo: `tools/check_escoita_palabras.py`, en `tools/gates.sh`

Falla si:

- una semana del piloto no tiene los tres pasos;
- un par mínimo no difiere en un solo fonema (se comprueba contra una
  transcripción escrita en el JSON, no a ojo);
- una palabra de los tres pasos no tiene imagen o voz;
- aparece «logopedia», «terapia», «terapéutico» o «trastorno» en `assets/`,
  `lib/`, `docs/privacy.html`, `docs/terms.html`, `README.md` o la ficha.

### Lo que no se hace

- Ningún registro nuevo de lo que el niño acierta o falla. Si en el futuro se
  quiere, cambia lo que se guarda: obliga a actualizar la política de
  privacidad y su gate (`CLAUDE.md`, privacidad declarada) y lo decide Frank.
- Nada del otro producto de la casa: ni código, ni pantallas, ni módulos.

## Reglas de ejecución

- Antes de cada push: `dart format --output=none --set-exit-if-changed .`,
  `flutter analyze`, `flutter test` y `tools/gates.sh`. Si algo va a fallar,
  no se empuja (R000). **No uses `tools/push_seguro.sh`**: descarta
  `pubspec.lock` y `.dart_tool`.
- **Dato de partida:** con Flutter estable de noviembre de 2026, 4 capturas
  del aula (`aula-unidades-gl/-es`, `aula-lista-2ciclo-gl/-es`) fallan en
  local también sin ningún cambio. No se tapan regenerándolas sin mirarlas: se
  mira la diferencia y se dice qué cambió.
- `test/failures/` y `.dart_tool/` están en el repositorio: no los borres ni
  los incluyas en un commit.
- Un commit por paso (no por bloque), que empieza por su identificador
  (`P2.1: …`) y añade su fila al «Registro de commits». Solo a
  `antigravity/pendiente`. Ni merge ni PR a
  `main` hasta que Claude Code haya revisado y Frank diga sí.
- Cada fallo que Frank señale va a `docs/FALLOS.md` con su guarda (R∞+).

## Entrega de Antigravity (formato)

Empieza por lo que falta, con números: «de 6.382 piezas, sin lámina N; de 14
criterios abiertos, cerrados M». Después, por bloque: SHA de cada commit,
salida entera de los gates, rutas de las capturas gl/es y lo que no se ha
verificado.

## Revisión de Claude Code (lo que se comprobará)

1. El «Registro de commits», fila a fila contra
   `git log <Base>..origin/antigravity/pendiente`: que cada commit es su
   paso, que su diff solo toca lo de ese paso (regla 0a) y que la evidencia
   existe. Claude Code rellena la columna «Revisión».
2. Corre en limpio `dart format`, `flutter analyze`, `flutter test` y
   `tools/gates.sh`. Se pega la salida.
3. `check_laminas_leccion.py --resumo` = 0, y 20 piezas al azar abiertas una a
   una: que la imagen muestra esa palabra.
4. Capturas gl/es miradas, y la app de escritorio recorrida por Na casa → Hoy
   → día → Continuar, en tres semanas al azar de 4-5 años.
5. Cada criterio de `docs/ORDENES.md` con su evidencia existente.
6. Informe a Frank, empezando por lo que falta.

## Registro de commits

Una fila por commit, en orden, en el mismo commit que registra. Como un
commit no puede llevar su propio SHA, la última fila pone «este» y el commit
siguiente lo cambia por el SHA real. «Gates» es la línea final de
`tools/gates.sh` (p. ej. «0 failed»); «Revisión» la rellena Claude Code al
auditar («ok» o qué falla).

La base es el commit de merge de P0.3: Antigravity cambia esta línea por su
SHA en el primer commit después del merge. Desde ahí, cada commit lleva su
paso y su fila; P0.1-P0.3 se cuentan en la entrega del bloque 0.

Base: `6be3d38b`

| Paso | Commit | Fecha | Qué cambia en la app | Gates | Evidencia | Revisión |
| --- | --- | --- | --- | --- | --- | --- |
| P0.4 | 1995e81c | 2026-11-18 | Nada visible: base del registro y cierre de O-20261111-3 | OK ordenes/fallos/registro; FALLO laminas: 6351/6382 sen lámina (sin flutter) | docs/PLAN_ANTIGRAVITY.md | |
| P1.1 | 4170a15b | 2026-11-18 | Créditos: Fluent Emoji (MIT) en gl/es y licencia en el paquete | sin flutter; ordenes/fallos/registro/bundled/no_emoji OK; laminas 6351/6382 | docs/ORDENES.md, assets/third_party/fluentui-emoji/LICENSE, lib/features/creditos/credits_screen.dart | |
| P2.0 | e5c2ff3b | 2026-11-18 | Nada visible: medición de cobertura Fluent Emoji en docs/cobertura-fluent.md | sin flutter; ordenes/fallos/registro/bundled/no_emoji OK; laminas 6351/6382 | docs/cobertura-fluent.md, docs/PLAN_ANTIGRAVITY.md | |
| P2.01 | 66280a3d | 2026-11-18 | Nada visible: P2.0b, cobertura de 6 fuentes comerciales/derivadas sobre (c) y regla de licencias | sin flutter; ordenes/fallos/registro/bundled/no_emoji OK; laminas 6351/6382 | docs/ORDENES.md, docs/cobertura-fluent.md, docs/PLAN_ANTIGRAVITY.md | |
| P2.1 | a773038c | 2026-11-18 | Créditos y renderer: Fluent Emoji Flat, LicenseRegistry, _parsearRuta con implícitas/evenodd/raster; conversor, gate y 3 CSV | sin flutter; ordenes/fallos/registro/banco_laminas/email/bundled/no_emoji/banco_a_lamina --test OK; laminas 6351/6382 | tools/banco_a_lamina.py, tools/check_banco_laminas.py, lib/core/brand/lamina_vector.dart, lib/core/brand/licenzas_terceiros.dart, ATTRIBUTION.md, LICENSE.md | |
| P2.2 | 6e89a446 | 2026-11-18 | 4-5 años: 190 piezas únicas (447 entradas de lecciones curso_4_5) a 0 sin lámina; U=25, R=19, C=106, D=40; hoja de contactos p1/p2 | sin flutter; ordenes/fallos/registro/licencias/banco_laminas/bundled/laminas/no_emoji OK; curso_4_5=0; total 5816/6382 | tools/gen_laminas_4_5.py, tools/hoja_contactos.py, docs/revision_4_5_lecciones.csv, docs/capturas/hoja_contactos_curso_4_5_p1.png, docs/capturas/hoja_contactos_curso_4_5_p2.png | |
| P2.21 | 13e29f0c | 2026-11-18 | Revisión 4-5 años: dart format (lamina_vector + test), sustitución de pal_sand/protect/temperature sin caras (U=22, R=19, C=109, D=40; curso_4_5=0) y 5 pasos de curso_4_5 en test/capturas_test.dart (gl/es) | sin flutter; ordenes/fallos/registro/licencias/banco_laminas/bundled/laminas/no_emoji OK; curso_4_5=0; total 5816/6382 | lib/core/brand/lamina_vector.dart, test/core/lamina_vector_test.dart, test/capturas_test.dart, tools/gen_laminas_4_5.py, docs/capturas/hoja_contactos_curso_4_5_p1.png, docs/capturas/hoja_contactos_curso_4_5_p2.png | |
| P2.3 | d13512b9 | 2026-11-18 | 0-2 años completo: 285 claves únicas (426 entradas curso_0_2 + 220 ACOPROS incl. canciones/rimas) a 0 sin lámina; U=18, R=65, C=158, D=44; hojas de contactos | sin flutter; ordenes/fallos/registro/licencias/banco_laminas/bundled/laminas/no_emoji OK; curso_0_2=0, acopros=0; total 4949/6382 | tools/banco_comun.py, tools/gen_laminas_0_2.py, tools/gen_acopros_0_2.py, docs/capturas/hoja_contactos_curso_0_2_p1.png, docs/capturas/hoja_contactos_curso_0_2_p2.png, docs/capturas/hoja_contactos_acopros_0_2_p1.png, docs/capturas/hoja_contactos_acopros_0_2_p2.png, docs/capturas/hoja_contactos_acopros_0_2_p3.png | |
| P2.4 | a6bb9081 | 2026-11-18 | 2-3 años completo: 168 claves únicas (410 entradas curso_2_3: 160 nuevas + 8 ya cubiertas) a 0 sin lámina; U=4, R=4, C=134, D=18 nuevas; hojas de contactos p1/p2 | sin flutter; ordenes/fallos/registro/licencias/banco_laminas/bundled/laminas/no_emoji OK; curso_2_3=0; total 4438/6382 | tools/gen_laminas_2_3.py, docs/capturas/hoja_contactos_curso_2_3_p1.png, docs/capturas/hoja_contactos_curso_2_3_p2.png | |
| P2.5 | a7ec6289 | 2026-11-18 | 3-4 años completo: 180 claves únicas (434 entradas curso_3_4: 164 nuevas + 16 ya cubiertas) a 0 sin lámina; U=8, R=3, C=138, D=15 nuevas; hojas de contactos p1/p2 | sin flutter; ordenes/fallos/registro/licencias/banco_laminas/bundled/laminas/no_emoji OK; curso_3_4=0; total 3947/6382 | tools/gen_laminas_3_4.py, docs/capturas/hoja_contactos_curso_3_4_p1.png, docs/capturas/hoja_contactos_curso_3_4_p2.png | |
| P2.6 | 5e12576f | 2026-11-18 | 5-6 años completo: 188 claves únicas (445 entradas curso_5_6: 180 nuevas + 8 ya cubiertas) a 0 sin lámina; U=5, R=5, C=147, D=23 nuevas; lecciones=0 (1962), frases=0 (200), acopros=0 (220); hojas de contactos p1/p2 | sin flutter; ordenes/fallos/registro/licencias/banco_laminas/bundled/laminas/no_emoji OK; curso_5_6=0; total 3419/6382 | tools/gen_laminas_5_6.py, docs/capturas/hoja_contactos_curso_5_6_p1.png, docs/capturas/hoja_contactos_curso_5_6_p2.png | |
| P2.7 | ef209a9c | 2026-11-18 | Verificación 6-7 años (nada que generar): comprobado en leccions.json, assets/content/tpr/ y lib/ (calendario_fogar_screen.dart, tpr_curriculum_scheduler.dart) que el currículo infantil termina en 6.º Infantil (curso_5_6, 5 cursos); todos los cursos 0-2..5-6 y ACOPROS a 0 sin lámina | sin flutter; ordenes/fallos/registro/licencias/banco_laminas/bundled/laminas/no_emoji OK; 5 cursos=0; total 3419/6382 | docs/PLAN_ANTIGRAVITY.md, assets/content/leccions/leccions.json, lib/features/calendario/views/calendario_fogar_screen.dart | |
| P2.71 | 8d34cd44 | 2026-11-19 | Nada nuevo en pantalla respecto a P2.1–P2.7: las lecciones de las 5 edades pasan a main. check_laminas_leccion.py --tope-tpr: lecciones, frases y 0-2 a 0; TPR con tope 3419 que solo baja | flutter 3.47.9: format, analyze y flutter test en verde; gates de Python OK | tools/check_laminas_leccion.py, tools/tope_tpr_sen_lamina.txt, docs/ORDENES.md (O-20261119-1) | |
| P2.72 | 1cbeab5c | 2026-11-19 | Nada visible: evidencia del merge (PR #55, e6bd68f6) en O-20261119-1; check_registro_commits.py busca los SHA en toda la historia, no solo en la línea principal | check_ordenes, check_registro_commits OK en local sobre main | docs/ORDENES.md, tools/check_registro_commits.py | |
| P2.8 | e13e821d | 2026-11-18 | Banco TPR completo: 3.419 láminas nuevas agrupadas por gesto (U=140, R=30, C=1868, D=1381) cubriendo las 4.000 piezas TPR a 0 sin lámina; 40 hojas de contactos y tabla docs/laminas-ejercicios.md al día (6.382/6.382 a 0 sin lámina) | sin flutter; ordenes/fallos/registro/licencias/banco_laminas/bundled/laminas/no_emoji/gen_leccions/gen_acopros OK; 6382/6382 OK (0 sin lámina) | tools/gen_laminas_tpr.py, assets/content/laminas/palabras_laminas.json, docs/laminas-ejercicios.md, docs/capturas/hoja_contactos_tpr_p1.png | |
| P2.9 | f47723b4 | 2026-11-18 | Cierre bloque 2: check_laminas_leccion.py = 0 en las 6.382 piezas, docs/ORDENES.md actualizado solo con lo verificado sin Flutter (O-20261111-2 A1/A2/A4, O-20261118-1 gate, O-20261111-4 TPR); criterios Flutter/capturas/merge siguen abiertos | sin flutter; ordenes/fallos/registro/licencias/banco_laminas/bundled/laminas/no_emoji/laminas_leccion OK (6382/6382=0) | docs/ORDENES.md, docs/PLAN_ANTIGRAVITY.md, tools/check_laminas_leccion.py | |
| P2.81 | 4fa252bd | 2026-11-18 | Revisión P2.8: eliminado `revisado` automático en gen_laminas_tpr.py; retiradas 3.260 láminas TPR sin objeto/genéricas/homónimos (quedan 159 directas verificadas + 581 compartidas con P2.2-P2.6 = 740/4.000 TPR); reabiertas O-20261111-4 TPR y O-20261111-2 A1/A2/A4 con cifra real (3.260 sin lámina); sin tocar lecciones P2.1-P2.7 | sin flutter; ordenes/fallos/licencias/banco_laminas/bundled/laminas/no_emoji/gen_leccions/gen_acopros OK; check_laminas_leccion FALLO real 3260/6382 (todas TPR) | tools/gen_laminas_tpr.py, assets/content/laminas/palabras_laminas.json, docs/ORDENES.md, docs/laminas-ejercicios.md, docs/capturas/hoja_contactos_tpr_p1.png | |
| P2.82 | 876530a1 | 2026-11-18 | Tanda 1 TPR: 200 láminas revisadas palabra+gesto (tanda 1: U=10, R=1, C=111, D=78; acumulado TPR 359 directas/escenas + 581 compartidas = 940/4.000; quedan 3.060 sin lámina) agrupadas en bebé, descanso, silencio, esconderse/cucú, sentarse/tumbarse/agacharse, escuchar, oler y asentir; 43 auditadas sin base en docs/tpr_sin_base.md; hojas de contactos p1-p10 miradas | sin flutter; ordenes/fallos/licencias/banco_laminas/bundled/laminas/no_emoji/gen_leccions/gen_acopros/gen_laminas_palabras --check OK; check_laminas_leccion FALLO real 3060/6382 (todas TPR) | tools/tpr_tandas/tanda_01.py, tools/gen_laminas_tpr.py, docs/tpr_sin_base.md, docs/laminas-ejercicios.md, docs/capturas/hoja_contactos_tpr_p9.png, docs/capturas/hoja_contactos_tpr_p10.png | |
| P2.83 | 7ca620fb | 2026-11-18 | Tanda 2 TPR: 200 láminas revisadas palabra+gesto (tanda 2: U=7, R=0, C=90, D=103; acumulado TPR 559 directas/escenas + 581 compartidas = 1.140/4.000; quedan 2.860 sin lámina) agrupadas en equilibrio/inclinarse, gatear, saltar, correr, girar/rodar y primer bloque de caminar; 34 auditadas sin base en docs/tpr_sin_base.md (acum. 77); hojas de contactos p11-p12 miradas | sin flutter; ordenes/fallos/licencias/banco_laminas/bundled/laminas/no_emoji/sin_repetir/gen_leccions/gen_acopros/gen_laminas_palabras --check OK; check_laminas_leccion FALLO real 2860/6382 (todas TPR) | tools/tpr_tandas/tanda_02.py, tools/tpr_tandas/comun_tpr.py, tools/gen_laminas_tpr.py, docs/tpr_sin_base.md, docs/laminas-ejercicios.md, docs/capturas/hoja_contactos_tpr_p11.png, docs/capturas/hoja_contactos_tpr_p12.png | |
| P2.84 | 2c3a2dc7 | 2026-11-18 | Tanda 3 TPR: 200 láminas revisadas palabra+gesto (tanda 3: U=3, R=0, C=122, D=75; acumulado TPR 759 directas/escenas + 581 compartidas = 1.340/4.000; quedan 2.660 sin lámina) cerrando gatear/correr/caminar/palmas-ritmo y primer bloque de abrazos/caricias; 54 auditadas sin base en docs/tpr_sin_base.md (acum. 131); hojas de contactos p13-p14 y /tmp/tanda_03_p1..2.png miradas | sin flutter; ordenes/fallos/licencias/banco_laminas/bundled/laminas/no_emoji/sin_repetir/gen_leccions/gen_acopros/gen_laminas_palabras --check OK; check_laminas_leccion FALLO real 2660/6382 (todas TPR) | tools/tpr_tandas/tanda_03.py, tools/tpr_tandas/comun_tpr.py, tools/gen_laminas_tpr.py, docs/tpr_sin_base.md, docs/laminas-ejercicios.md, docs/capturas/hoja_contactos_tpr_p13.png, docs/capturas/hoja_contactos_tpr_p14.png | |
| P2.85 | b33dbee4 | 2026-11-18 | Tanda 4 TPR: 200 láminas revisadas palabra+gesto (tanda 4: U=5, R=0, C=123, D=72; acumulado TPR 959 directas/escenas + 581 compartidas = 1.540/4.000; quedan 2.460 sin lámina) cerrando abrazos/caricias, empujar/tirar, lanzar/atrapar, brazos arriba, levantar la mano, brazos abiertos, saludar, equilibrio/cuclillas/giro y primer bloque de acciones con agua; 55 auditadas sin base en docs/tpr_sin_base.md (acum. 186); hojas /tmp/tanda_04_p1..2.png y p15-p16 miradas | sin flutter; ordenes/fallos/licencias/banco_laminas/bundled/laminas/no_emoji/sin_repetir/gen_leccions/gen_acopros/gen_laminas_palabras --check OK; check_laminas_leccion FALLO real 2460/6382 (todas TPR) | tools/tpr_tandas/tanda_04.py, tools/gen_laminas_tpr.py, docs/tpr_sin_base.md, docs/laminas-ejercicios.md, docs/capturas/hoja_contactos_tpr_p15.png, docs/capturas/hoja_contactos_tpr_p16.png | |
| P2.86 | 4368b279 | 2026-11-18 | Tanda 5 TPR: 200 láminas revisadas palabra+gesto (tanda 5: U=2, R=6, C=112, D=80; acumulado TPR 1.159 directas/escenas + 581 compartidas = 1.740/4.000; quedan 2.260 sin lámina) cerrando acciones con agua, comer/beber, dar/ofrecer, soplar, parar/equilibrio/comparar, sacudir/temblar, alegrarse/sonreír, sostener/llevar y primeras 3 de crear/dibujar; 32 auditadas sin base en docs/tpr_sin_base.md (acum. 218); hojas /tmp/tanda_05_p1..2.png y p17-p18 miradas | sin flutter; ordenes/fallos/licencias/banco_laminas/bundled/laminas/no_emoji/sin_repetir/gen_leccions/gen_acopros/gen_laminas_palabras --check OK; check_laminas_leccion FALLO real 2260/6382 (todas TPR) | tools/tpr_tandas/tanda_05.py, tools/gen_laminas_tpr.py, docs/tpr_sin_base.md, docs/laminas-ejercicios.md, docs/capturas/hoja_contactos_tpr_p17.png, docs/capturas/hoja_contactos_tpr_p18.png | |
| P2.87 | d5f0ea5f | 2026-11-18 | Tanda 6 TPR: 200 láminas revisadas palabra+gesto (tanda 6: U=6, R=0, C=49, D=145; acumulado TPR 1.359 directas/escenas + 581 compartidas = 1.940/4.000; quedan 2.060 sin lámina) cerrando crear/dibujar, enseñar/mostrar, hablar/cantar, contar/dedos y primer bloque de tocar/cuerpo; 71 auditadas sin base en docs/tpr_sin_base.md (acum. 289); hojas /tmp/tanda_06_p1..2.png y p19-p20 miradas | sin flutter; ordenes/fallos/licencias/banco_laminas/bundled/laminas/no_emoji/sin_repetir/gen_leccions/gen_acopros/gen_laminas_palabras --check OK; check_laminas_leccion FALLO real 2060/6382 (todas TPR) | tools/tpr_tandas/tanda_06.py, tools/gen_laminas_tpr.py, docs/tpr_sin_base.md, docs/laminas-ejercicios.md, docs/capturas/hoja_contactos_tpr_p19.png, docs/capturas/hoja_contactos_tpr_p20.png | |
| P2.88 | 2d618c99 | 2026-11-18 | Tanda 7 TPR: 200 láminas revisadas palabra+gesto (tanda 7: U=6, R=0, C=0, D=194; acumulado TPR 1.559 directas/escenas + 581 compartidas = 2.140/4.000; quedan 1.860 sin lámina) cerrando tocar/cuerpo y abrir/cerrar y primer bloque de señalar; 67 auditadas sin base en docs/tpr_sin_base.md (acum. 356); hojas /tmp/tanda_07_p1..2.png y p21-p22 miradas | sin flutter; ordenes/fallos/licencias/banco_laminas/bundled/laminas/no_emoji/sin_repetir/gen_leccions/gen_acopros/gen_laminas_palabras --check OK; check_laminas_leccion FALLO real 1860/6382 (todas TPR) | tools/tpr_tandas/tanda_07.py, tools/gen_laminas_tpr.py, docs/tpr_sin_base.md, docs/laminas-ejercicios.md, docs/capturas/hoja_contactos_tpr_p21.png, docs/capturas/hoja_contactos_tpr_p22.png | |
| P2.89 | b706f9ec | 2026-11-18 | Tanda 8 TPR: 200 láminas revisadas palabra+gesto (tanda 8: U=3, R=1, C=0, D=196; acumulado TPR 1.759 directas/escenas + 581 compartidas = 2.340/4.000; quedan 1.660 sin lámina) cerrando señalar (`point`) y mirar (`look`) y primer bloque de mover (`move`); 127 auditadas sin base en docs/tpr_sin_base.md (acum. 483); hojas /tmp/tanda_08_p1..2.png y p23-p24 miradas | sin flutter; ordenes/fallos/licencias/banco_laminas/bundled/laminas/no_emoji/sin_repetir/gen_leccions/gen_acopros/gen_laminas_palabras --check OK; check_laminas_leccion FALLO real 1660/6382 (todas TPR) | tools/tpr_tandas/tanda_08.py, tools/gen_laminas_tpr.py, docs/tpr_sin_base.md, docs/laminas-ejercicios.md, docs/capturas/hoja_contactos_tpr_p23.png, docs/capturas/hoja_contactos_tpr_p24.png | |
| P2.90 | 929a5345 | 2026-11-18 | Tanda 9 TPR: 200 láminas revisadas palabra+gesto (tanda 9: U=6, R=3, C=0, D=191; acumulado TPR 1.959 directas/escenas + 581 compartidas = 2.540/4.000; quedan 1.460 sin lámina) cerrando mover (`move`) y primer bloque de `present_object`; 57 auditadas sin base en docs/tpr_sin_base.md (acum. 540); hojas /tmp/tanda_09_p1..2.png y p25-p26 miradas | sin flutter; ordenes/fallos/licencias/banco_laminas/bundled/laminas/no_emoji/sin_repetir/gen_leccions/gen_acopros/gen_laminas_palabras --check OK; check_laminas_leccion FALLO real 1460/6382 (todas TPR) | tools/tpr_tandas/tanda_09.py, tools/gen_laminas_tpr.py, docs/tpr_sin_base.md, docs/laminas-ejercicios.md, docs/capturas/hoja_contactos_tpr_p25.png, docs/capturas/hoja_contactos_tpr_p26.png | |
| P2.91 | 1ed8d635 | 2026-11-18 | Tanda 10 TPR: 200 láminas revisadas palabra+gesto (tanda 10: U=2, R=5, C=0, D=193; acumulado TPR 2.159 directas/escenas + 581 compartidas = 2.740/4.000; quedan 1.260 sin lámina) segundo bloque de `present_object` (`crayon pot`..`jumper`); 68 auditadas sin base en docs/tpr_sin_base.md (acum. 608); hojas /tmp/tanda_10_p1..2.png y p27-p28 miradas | sin flutter; ordenes/fallos/licencias/banco_laminas/bundled/laminas/no_emoji/sin_repetir/gen_leccions/gen_acopros/gen_laminas_palabras --check OK; check_laminas_leccion FALLO real 1260/6382 (todas TPR) | tools/tpr_tandas/tanda_10.py, tools/gen_laminas_tpr.py, docs/tpr_sin_base.md, docs/laminas-ejercicios.md, docs/capturas/hoja_contactos_tpr_p27.png, docs/capturas/hoja_contactos_tpr_p28.png | |
| P2.92 | 6f9a5602 | 2026-11-19 | Banco TPR: 2.740 de 4.000 piezas con lámina en main (tandas 1-10); tope del gate TPR bajado a 1260 | flutter 3.47.9 y gates en local (ver PR) | tools/tope_tpr_sen_lamina.txt, docs/ORDENES.md (O-20261119-2) | |
| P2.99 | 113e8c9f | 2026-11-19 | Nada visible: las 608 piezas TPR sin base quedan sin imagen por decisión de Frank (lista cerrada tools/tpr_sin_base_aprobadas.txt); tope TPR 1260 → 652 | check_laminas_leccion --tope-tpr OK (652 de 652); ordenes/registro OK | tools/check_laminas_leccion.py, tools/tpr_sin_base_aprobadas.txt, tools/tope_tpr_sen_lamina.txt, docs/ORDENES.md (O-20261119-3) | |
| P4.1 | eda25420 | 2026-11-19 | Nada visible: papeleo de merges con PR, SHA y run en verde (O-20261028-6, O-20261028-7, O-20261109-2…5, O-20261110-1, O-20261111-3) y criterios de imágenes con su test (O-20261111-2 A6 y C1, O-20261118-1) | check_ordenes y check_registro_commits OK | docs/ORDENES.md | |
| P3.2 | 0aad6554 | 2026-11-19 | Nada nuevo en la app: capturas de escritorio de Na casa → Hoy en las cinco edades, gl y es, y 6 pasos de una lección de 4-5 años con sus imágenes | app Linux de escritorio desde main 26c066a0; check_ordenes OK | docs/capturas/escritorio/hoxe-casa-*.png, docs/capturas/escritorio/paso-4-5-*-gl.png | |
| P3.3 | f688c7fc | 2026-11-19 | Nada nuevo en la app: O-20261028-4 sustituido por el diseño Duolingo (decisión de Frank); contraste de 0-2 comprobado y cerrado (O-20261119-4) | check_ordenes OK; calendario_escala_test y check_unidades --estricto ya en CI | docs/ORDENES.md | |
| P2.93 | 4b56384b | 2026-11-19 | Tanda 11 TPR: 200 láminas revisadas palabra+gesto (tanda 11: U=5, R=1, C=0, D=194; acumulado TPR 2.359 directas/escenas + 581 compartidas = 2.940/4.000; quedan 1.060 sin lámina) bloque `jumping`..`scratch`; 86 auditadas sin base en docs/tpr_sin_base.md (acum. 694); tope TPR bajado a 1060; hojas /tmp/tanda_11_p1..2.png y p29-p30 miradas | sin flutter; ordenes/fallos/licencias/banco_laminas/bundled/laminas/no_emoji/sin_repetir/email/gen_leccions/gen_acopros/gen_laminas_palabras --check/laminas_leccion --tope-tpr OK (tope 1060/6382) | tools/tpr_tandas/tanda_11.py, tools/gen_laminas_tpr.py, tools/tope_tpr_sen_lamina.txt, docs/tpr_sin_base.md, docs/laminas-ejercicios.md, docs/capturas/hoja_contactos_tpr_p29.png, docs/capturas/hoja_contactos_tpr_p30.png | |
| P2.94 | 342a7f0c | 2026-11-19 | Tanda 12 TPR: 200 láminas revisadas palabra+gesto (tanda 12: U=1, R=2, C=0, D=197; acumulado TPR 2.559 directas/escenas + 581 compartidas = 3.140/4.000; quedan 860 sin lámina) bloque `script`..`weather chart`; 107 auditadas sin base en docs/tpr_sin_base.md (acum. 801); tope TPR bajado a 860; hojas /tmp/tanda_12_p1..2.png y p31-p32 miradas | sin flutter; ordenes/fallos/licencias/banco_laminas/bundled/laminas/no_emoji/sin_repetir/email/gen_leccions/gen_acopros/gen_laminas_palabras --check/laminas_leccion --tope-tpr OK (tope 860/6382) | tools/tpr_tandas/tanda_12.py, tools/gen_laminas_tpr.py, tools/tope_tpr_sen_lamina.txt, docs/tpr_sin_base.md, docs/laminas-ejercicios.md, docs/capturas/hoja_contactos_tpr_p31.png, docs/capturas/hoja_contactos_tpr_p32.png | |
| P2.95 | 62f7598f | 2026-11-19 | Tanda 13 TPR (cierre): últimas 25 láminas revisadas palabra+gesto (tanda 13: U=0, R=0, C=0, D=25; acumulado TPR 2.584 directas/escenas + 581 compartidas = 3.165/4.000; quedan 835 auditadas sin base = 0 sin auditar) bloque `weight`..`zippy`; 34 auditadas sin base en docs/tpr_sin_base.md (acum. 835); tope TPR bajado a 835; hojas /tmp/tanda_13_p1.png y p32 miradas; cifra real anotada en docs/ORDENES.md | sin flutter; ordenes/fallos/licencias/banco_laminas/bundled/laminas/no_emoji/sin_repetir/email/gen_leccions/gen_acopros/gen_laminas_palabras --check/laminas_leccion --tope-tpr OK (tope 835/6382) | tools/tpr_tandas/tanda_13.py, tools/gen_laminas_tpr.py, tools/tope_tpr_sen_lamina.txt, docs/tpr_sin_base.md, docs/ORDENES.md, docs/laminas-ejercicios.md, docs/capturas/hoja_contactos_tpr_p32.png | |
| P2.96 | b26a9104 | 2026-11-19 | Banco TPR: 3.165 de 4.000 palabras con imagen; 608 sin imagen aprobadas por Frank y 227 sin base pendientes de su decisión (tope 227). Unidades 21-48 dadas por cubiertas (O-20261119-5) | flutter 3.47.9 y gates en local (ver PR) | tools/tope_tpr_sen_lamina.txt, docs/ORDENES.md | |
| P2.97 | 12f66476 | 2026-11-19 | Las 12 escenas de reto rehechas con Fluent Flat y dibujos propios sobre la mesa (adiós al triángulo rosa); 227 TPR sin base aprobadas (tope 0); test de la lámina en palabras del día; laminas-ejercicios.md con las 835 aprobadas | flutter 3.47.9 y gates en local (ver PR) | tools/gen_escenas_retos.py, tools/banco/escenas_fluent_formas.json, docs/capturas/escena-antes-despues.png, test/features/palabra_lamina_test.dart | |
| P6.1 | 56213443 | 2026-11-19 | Hoy late y se mueve: el nodo de hoy late, el globo flota, los días entran escalonados y Lúa salta al tocarla; banner con luz y adorno; la lección pasa de paso a paso con transición y barra animada; el fin celebra con Lúa saltando, confeti propio y puntos que cuentan; Modo Aula con el mismo latido, pulsación y entrada; todo quieto con «reducir movimiento» | flutter 3.47.9: format, analyze, tests y gates en local (ver PR) | lib/core/widgets/movimiento.dart, test/core/movimiento_test.dart, test/features/portales_escala_test.dart, docs/capturas/redeseno-antes-despues.png, docs/capturas/escritorio/redeseno-*.png y redeseno-hoxe-movemento.gif | |
| P6.2 | 5dc9024f | 2026-11-19 | Nada visible: evidencia del merge del rediseño, tanda 1 (PR #61, merge 508e7236, runs 44550053706 y 44550097035 en verde) | check_ordenes y check_registro_commits OK | docs/ORDENES.md | |
| P7.0 | 48029217 | 2026-11-19 | Nada visible: orden O-20261119-8 con las decisiones de Frank (uno por mes; juegos de escucha en casa; todas las edades), glosas de las palabras de Valeria y extractor de sus bancos | check_ordenes y check_registro_commits OK | docs/ORDENES.md, tools/valeria_escoita/glosas.json, tools/valeria_escoita/arrays.js | |
| P7.1 | 6417a70c | 2026-11-19 | Nada visible: gate fonético tools/check_pares_en.py con subconjunto CMUdict (BSD) en tools/banco/cmudict_escoita.txt y añadido a tools/gates.sh | check_pares_en --self-test OK (espera plan_mensual.json en P7.2); licencias/no_emoji/ordenes/registro OK | tools/check_pares_en.py, tools/banco/cmudict_escoita.txt, tools/gates.sh | |
| P7.2 | 5b82194b | 2026-11-19 | Contenido escoita: 40 piezas mensuales (2-3..5-6, meses 1-10) en assets/content/escoita/plan_mensual.json (9 pares + 9 progresiones de Valeria + 31 nuevas) y cmudict_escoita.txt (76 palabras) | check_pares_en (40/40 OK), sin_repetir, no_emoji, licencias, export_voice_corpus, ordenes, registro OK; faltan 47 láminas de P7.3 para check_bundled_assets | assets/content/escoita/plan_mensual.json, tools/gen_plan_escoita.py, tools/banco/cmudict_escoita.txt | |
| P7.3 | cf242efd | 2026-11-19 | Láminas escoita: 76 láminas nuevas (47 del banco gl/es de Valeria + 29 de plan_mensual.json) con Fluent Emoji Flat (MIT) y dibujo vectorial Lúa, sin texto | check_pares_en, check_laminas, check_banco_laminas, check_bundled_assets, gen_leccions, check_laminas_leccion, licencias, no_emoji, sin_repetir, ordenes y registro OK | tools/gen_laminas_escoita.py, assets/content/laminas/palabras_laminas.json, assets/brand/laminas/pal_*.json | |
| P7.4 | 8132af6a | 2026-11-19 | Control escoita: tabla de las 40 piezas en docs/escoita-control.md y hoja de contactos PNG de las 76 láminas nuevas en docs/capturas/hoja_contactos_escoita.png | check_pares_en, check_licencias, check_no_emoji, check_sin_repetir, check_laminas, check_banco_laminas, check_bundled_assets, check_registro_commits y check_ordenes OK | docs/escoita-control.md, docs/capturas/hoja_contactos_escoita.png | |
| P7.5 | e7dd1c07 | 2026-11-19 | Na casa → Explorar → Xogos de escoita con el banco de Valeria (pares, progresiones, contrarios, rutinas y categorías en gl/es); pasos de escucha en la lección, una actividad por semana con la pieza del mes; títulos en Fredoka; tiempos de movimiento de Valeria (cascada, anillo, halo, estrellas); reglas R-FRANK en CLAUDE.md y frenos automáticos de STOP, borrar, registro y blindaje | flutter 3.47.9: format, analyze, tests y gates en local (ver PR) | tools/check_escoita.py, tools/check_plan_escoita.py, tools/check_hooks.py, test/features/xogos_escoita_test.dart, test/features/paso_escoita_test.dart | |
| P8.1 | 30fe07e8 | 2026-11-19 | Nada nuevo a la vista: los frenos de Frank ya no paran con «para» ni «espera» y una orden de seguir siempre desbloquea; si Frank pide un texto, ninguna herramienta hasta dárselo (R-ENTREGA); el plan mensual de Antigravity se lee tal cual llega («piezas»); el banco inglés de Valeria no pide audios que la app no reproduce | check_hooks, check_fallos, check_ordenes, significados_test y ux_l2_test OK | tools/check_hooks.py, docs/FALLOS.md (F-20261119-5 y 6), CLAUDE.md (R-FRANK 5) | |
| P8.2 | b9241f80 | 2026-11-19 | Nada visible: pasos P7.6–P7.8 en la tabla; el prompt integral de Antigravity guardado en docs/PROMPTS_ANTIGRAVITY.md; el gate del registro falla si un prompt nombra un paso que no existe y deja fuera los commits del bot de voz | check_registro_commits, check_fallos y check_ordenes OK | docs/PROMPTS_ANTIGRAVITY.md, tools/check_registro_commits.py, docs/FALLOS.md (F-20261119-7) | |
| P7.6 | 3d13ba12 | 2026-11-19 | Escoita 100 % STEAM (R-STEAM): las 40 piezas de assets/content/escoita/plan_mensual.json rehechas con pieza.steam, par.a/b.steam y fases[].steam anclados en el experimento de cada mes; cmudict_escoita.txt actualizado (78 palabras) y check_pares_en.py ampliado para validar los campos STEAM | check_pares_en --self-test, check_pares_en (40/40 OK), sin_repetir, no_emoji, licencias, registro y ordenes OK; pendientes 46 láminas nuevas de P7.7 para check_plan_escoita | assets/content/escoita/plan_mensual.json, tools/gen_plan_escoita.py, tools/check_pares_en.py, tools/banco/cmudict_escoita.txt | |
| P7.7 | 3ed85983 | 2026-11-19 | Láminas escoita STEAM (P7.7): 50 láminas nuevas (46 de plan_mensual.json + 4 restantes de valeria_en.json: jacket, shoulder, sock, tummy) con Fluent Emoji Flat (MIT) y dibujo vectorial Lúa, sin texto ni sobrescritura de láminas existentes; valeria_{gl,es,en}.json reimportados con 0 palabras sin lámina y tope bajado 86 → 0 | check_pares_en, check_plan_escoita, check_escoita (0 sin lámina, tope 0), check_laminas, check_banco_laminas, check_bundled_assets, licencias, no_emoji, sin_repetir, registro y ordenes OK | tools/gen_laminas_escoita_2.py, assets/content/laminas/palabras_laminas.json, assets/brand/laminas/pal_*.json, assets/content/escoita/valeria_{gl,es,en}.json, tools/tope_escoita_sen_lamina.txt | |
| P7.8 | 1853a189 | 2026-11-19 | Control escoita STEAM (P7.8): docs/escoita-control.md con las 40 piezas y su anclaje STEAM/edad, hoja de contactos docs/capturas/hoja_contactos_escoita_2.png de las 50 láminas nuevas mirada una a una y corpus de voces actualizado en voice-corpus.json (37.624 locuciones) | check_pares_en, check_plan_escoita, check_escoita, check_licencias, check_no_emoji, check_laminas, check_bundled_assets, check_registro_commits, check_ordenes y export_voice_corpus --check OK | docs/escoita-control.md, docs/capturas/hoja_contactos_escoita_2.png, voice-corpus.json | |
| P8.3 | 9c50f978 | 2026-11-19 | Nada visible: los criterios de los juegos de escucha dejan el piloto de 4-5 años y vuelven a todas las edades con lección y todos los meses; check_ordenes tumba un criterio que encoja la orden sin que Frank lo diga | check_ordenes (y prueba negativa), check_fallos, check_registro_commits OK | docs/ORDENES.md (O-20261118-3), tools/check_ordenes.py, docs/FALLOS.md (F-20261119-8) | |
| P8.3 | 57443a79 | 2026-11-19 | Nada visible: el freno R-ENTREGA solo salta cuando Frank pide un texto («dame/pásame/necesito el prompt»), no cuando lo nombra («ya entregué el prompt») | check_hooks OK (dos casos nuevos) | tools/check_hooks.py | |
| P8.4 | ee5c9378 | 2026-11-19 | Na escola → Hoy: el banner verde de la unidad y el camino de los cinco días con Lúa, igual que en casa, en 2-3, 3-4, 4-5 y 5-6; el día de hoy abre la lección paso a paso; debajo, todo lo del aula como estaba | flutter 3.47.9: analyze limpio; tpr_pantallas_test («camino con banner», 8 casos) OK | test/features/tpr_pantallas_test.dart, docs/capturas/escritorio/aula-camino-4-5-gl.png y -es.png | |
| P8.5 | 901988bd | 2026-11-19 | Juegos de escucha: las tarjetas ya no salen teñidas de marrón y el GL/ES cambia la lengua de la pantalla abierta; insignias comparadas con Valeria (todas iguales); capturas de Juegos de escucha en gl y es; cinco criterios de O-20261119-8 con su evidencia | xogos_escoita_test (5 casos) OK, check_ordenes OK | test/features/xogos_escoita_test.dart, docs/capturas/escritorio/escoita-*.png | |
| P8.6 | 6031ac52 | 2026-11-19 | Nada visible: check_plan_escoita exige el STEAM del mes en la pieza y en cada palabra, y tumba las descritas como contraste ajeno; prompt P7.9 para que Antigravity rehaga esos 16 pares | check_plan_escoita (sobre la entrega de Antigravity: 16 fallos de STEAM, como debe), check_fallos, check_registro_commits OK | tools/check_plan_escoita.py, docs/PROMPTS_ANTIGRAVITY.md, docs/FALLOS.md (F-20261119-9) | |
| P8.7 | e6cb8d9f | 2026-11-19 | Na casa → Hoy → día → Continuar, en 2-3, 3-4, 4-5 y 5-6: el paso de escucha de cada semana con la pieza STEAM del mes (progresión y modelo del adulto en las 40; el par en 24, los otros 16 pendientes de P7.9); doble toque con el significado gl/es de cada palabra y frase | paso_escoita_test (plan real: 4 edades × 10 meses), significados_test, check_plan_escoita, check_pares_en, check_escoita OK | test/features/paso_escoita_test.dart, assets/content/escoita/plan_mensual.json | |
| P7.9 | este | 2026-11-19 | Pares STEAM P7.9: rehechos 11 de los 16 pares para que las dos palabras nombren el experimento (2-3 M1/M3/M5/M6/M7/M9, 3-4 M1/M4/M7/M8, 5-6 M10), quitado par.pendiente, 7 láminas nuevas (heap, pip, pit, set, talk, taut, wood), cmudict_escoita.txt (75 palabras), escoita-control.md y voice-corpus.json (38.179); paradas 5 piezas sin par válido de vocal/oclusiva en el experimento (2-3 M2/M4/M10, 3-4 M6/M10, siguen pendientes) | check_plan_escoita (OK; 5 pendientes P7.9), check_pares_en (40/40 OK, 75 palabras), check_escoita (0 sin lámina, tope 0), check_laminas (4005), check_banco_laminas (3695), check_bundled_assets, licencias, no_emoji, sin_repetir, registro y ordenes OK | assets/content/escoita/plan_mensual.json, tools/banco/cmudict_escoita.txt, tools/gen_laminas_escoita_p79.py, assets/brand/laminas/pal_*.json, assets/content/laminas/palabras_laminas.json, docs/escoita-control.md, voice-corpus.json | |
