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
| P2.8 | Banco TPR (4.000 piezas) cubierto, agrupado por gesto | 2 | no |
| P2.9 | Cierre bloque 2: `check_laminas_leccion.py` = 0 en todo, tests de pasos en verde, `docs/ORDENES.md` al día | 2 | no |
| P3.1 | Unidades 21-48 con su material semanal completo | 3 | si falta base en `referencias/` |
| P3.2 | Capturas de escritorio de Hoy en las cinco edades, gl y es | 3 | no |
| P3.3 | 4-5 años: lo de hoy en la primera pantalla de 412×915 | 3 | no |
| P4.1 | Cierres de papeleo con PR, SHA y run en verde | 4 | no |
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
| P2.7 | este | 2026-11-18 | Verificación 6-7 años (nada que generar): comprobado en leccions.json, assets/content/tpr/ y lib/ (calendario_fogar_screen.dart, tpr_curriculum_scheduler.dart) que el currículo infantil termina en 6.º Infantil (curso_5_6, 5 cursos); todos los cursos 0-2..5-6 y ACOPROS a 0 sin lámina | sin flutter; ordenes/fallos/registro/licencias/banco_laminas/bundled/laminas/no_emoji OK; 5 cursos=0; total 3419/6382 | docs/PLAN_ANTIGRAVITY.md, assets/content/leccions/leccions.json, lib/features/calendario/views/calendario_fogar_screen.dart | |
