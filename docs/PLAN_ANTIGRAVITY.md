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
`origin/feat/laminas-ejercicios`. Ningún otro agente toca esos ficheros
mientras Antigravity trabaja. Claude Code no empuja nada a esa rama.

## Bloque 0 · Rescate e integración

1. Ejecuta el «BLOQUE 0 · RESCATE» que Frank te dio el 18/11, tal cual, en la
   carpeta de Frank (no en un worktree propio). Pega la salida entera.
2. Crea `antigravity/pendiente` desde `origin/feat/laminas-ejercicios` y mete
   ahí lo útil del rescate, con los JSON de contenido regenerados con sus
   generadores, nunca copiados a mano.
3. Mete los commits de O-20261118-1 desde `origin/claude/upbeat-fermi-3d0utp`
   (`git log origin/main..origin/claude/upbeat-fermi-3d0utp`). **Choque
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
- Un commit por bloque, solo a `antigravity/pendiente`. Ni merge ni PR a
  `main` hasta que Claude Code haya revisado y Frank diga sí.
- Cada fallo que Frank señale va a `docs/FALLOS.md` con su guarda (R∞+).

## Entrega de Antigravity (formato)

Empieza por lo que falta, con números: «de 6.382 piezas, sin lámina N; de 14
criterios abiertos, cerrados M». Después, por bloque: SHA de cada commit,
salida entera de los gates, rutas de las capturas gl/es y lo que no se ha
verificado.

## Revisión de Claude Code (lo que se comprobará)

1. `git log origin/main..origin/antigravity/pendiente`: que cada commit
   corresponde a un bloque y no toca lo que no se pidió (regla 0a).
2. Corre en limpio `dart format`, `flutter analyze`, `flutter test` y
   `tools/gates.sh`. Se pega la salida.
3. `check_laminas_leccion.py --resumo` = 0, y 20 piezas al azar abiertas una a
   una: que la imagen muestra esa palabra.
4. Capturas gl/es miradas, y la app de escritorio recorrida por Na casa → Hoy
   → día → Continuar, en tres semanas al azar de 4-5 años.
5. Cada criterio de `docs/ORDENES.md` con su evidencia existente.
6. Informe a Frank, empezando por lo que falta.
