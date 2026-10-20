# Plan integral de mejora docente

Cómo pasa la app entera, en los cinco cursos y los tres modos, de su estado
actual a la arquitectura de `docs/PLAN_ARQUITECTURA_PEDAGOGIA.md`. **Este
documento no cambia ninguna pantalla.** No hay piloto: cada módulo cubre todo
su alcance (los cursos y los meses que le tocan) o dice qué pieza falta y por
qué.

El plan está organizado en **ocho objetivos** y **módulos** que se ejecutan en
varias sesiones de trabajo. Cada módulo tiene un identificador fijo (`M3.4`),
dependencias declaradas y un criterio de hecho que se puede comprobar. Así,
cualquier sesión puede retomar el trabajo donde lo dejó la anterior, sin
depender de la memoria de nadie.

Si este documento y el JSON no dicen lo mismo, manda el JSON.

## 1. Diagnóstico

Sale de leer el contenido de `assets/content/` y el código que lo carga, no de
documentos anteriores.

### Lo que funciona y se conserva

- **Cinco cursos × diez meses.** Banco TPR de 80 palabras al mes con gesto en
  gl y es, y un gate que lo vigila.
- **Asamblea de cuatro fases**: 20 del 1.º ciclo (10 meses × 2 tramos, unos
  9 minutos) y 30 del 2.º ciclo (10 meses × 3 niveles, unos 10 minutos). Las
  43 órdenes del 1.º ciclo ya dicen «fai o xesto mentres di a orde, e agarda
  sen esixir resposta».
- **Progresión semanal** (descubrir, practicar, combinar, consolidar) en
  `assets/content/progresion/`.
- **Cuento de la semana** con sus veinte palabras y preguntas graduadas.
- **Cinco estrategias**, formación de entrada de seis pasos por perfil y nota
  para las casas sin botón de compartir.
- **30 micro-rutinas de casa** en las asambleas del 2.º ciclo.
- Nada guardado de ninguna criatura.

### Lo que rompe la arquitectura

1. **Cada pieza del mes cuenta un tema distinto.** Ejemplos tomados del JSON:

   | Curso · mes | Banco | Asamblea | Cuentos del mes |
   | --- | --- | --- | --- |
   | 2-3 · enero | Autobús, ciudad, puerto | Ropa de invierno, botas, manoplas | Nueces olvidadas; una correa |
   | 4-5 · noviembre | Monte de A Guía, robles | Samaín y Magosto | Receta de la abuela; viento del norte |
   | 5-6 · abril | La ría limpia, delfines | Animales de granja y monte | Mapa del tesoro; embalse vacío |

2. **El inglés del mes sale de fuentes que no se hablan.** Solo 13 de las 133
   órdenes de las asambleas están en el banco. El léxico mensual de
   `curriculo_50_meses.json` (250 palabras) coincide con el banco del mismo mes
   en 33. Las dinámicas, los juegos de casa, STEAM, las láminas y las guías de
   atención tienen frases inglesas propias.
3. **Hay dos asambleas.** El calendario del aula abre todavía la de seis pasos
   (`asamblea/fases.json` y las diez unidades `unidades/juega.*`, de un solo
   tramo 0-3). El propio código la marca para retirar
   (`asamblea_guiada_screen.dart`). «Formación en el aula» sigue explicando
   seis pasos.
4. **Tres calendarios**: `meses.json` (10), `curriculo_50_meses.json` (50) y
   `calendario_dias.json` (1.000 días). Además, `calendario_3_6_anos.json` y
   `corpus/bnc_coca_8000.json` no los carga ningún fichero de `lib/`.
5. **No hay núcleo estable.** Hoy enseña cinco palabras nuevas cada día y
   ninguna se queda el mes.
6. **La manera de hablar no está escrita entera.** Faltan el habla paralela y
   la expansión. La espera no distingue sus tiempos. El visor del cuento no
   dibuja `tempoEsperaSegundos`.
7. **No hay microcuento dialógico.**
8. **Las indicaciones para el hogar están repartidas en ocho sitios** que no se
   hablan, `atencion.json` llega solo hasta los 36 meses y **el 1.º ciclo no
   tiene ninguna rutina de casa por mes**.
9. **Identificadores.** El banco de 3-4 usa claves sin prefijo. El repaso
   espaciado guarda cada tarjeta con un hash del identificador
   (`idDaTarxetaDeRepaso`), así que renombrar un identificador sin migrarlo
   deja huérfano el repaso que la persona adulta ya tiene en su aparato.
10. **El banco está cerrado.** El gate exige 800 palabras por curso, ninguna
    nueva dos veces, y cada cuento semanal lleva exactamente las veinte de su
    semana (`tools/check_contos_palabras.py`). Mover palabras entre meses
    obliga a reescribir cuentos y cambia identificadores.
11. **Fonética.** La voz inglesa de la app es americana
    (`en_US-ljspeech-medium`). Los textos de base transcriben a veces en
    británico.

## 2. Decisiones de Frank

**Decididas:**

| # | Decisión | Qué se hace | Módulos |
| --- | --- | --- | --- |
| D4 | Qué centro de interés manda | **La asamblea del mes.** El núcleo, los cuentos nuevos, los juegos y la casa siguen su centro de interés | M3.x, M5.x, M6.x |
| D6 | Microcuentos | **Entran, y son esenciales.** Uno por unidad desde 2-3 años: 40 microcuentos y unas 140 láminas | O5 |
| D3 | Pedir repetir | **Prohibido en gl, es y en**, vigilado por `tools/check_sin_repetir.py`. Las órdenes de 6.º que esperan que la criatura use una fórmula de turno (*Here you go*, *Your turn*) **se quedan**: no piden repetir un modelo | M2.4 |

**Pendientes.** Se trabaja con la opción marcada mientras Frank no conteste. El
módulo que la usa no se cierra sin la respuesta.

| # | Decisión | Opción de trabajo | Módulo que la necesita |
| --- | --- | --- | --- |
| D1 | El banco de cinco palabras al día | Se queda como ampliación; el núcleo va delante | M3.10 |
| D2 | Inmersión o lengua de casa | Translanguaging: trama en gl/es y frase de Lúa en inglés | M2.1 |
| D5 | La asamblea de seis pasos | Se retira; el calendario abre la de cuatro fases | M4.3 |
| D7 | Lista de práctica de la persona adulta | No entra hasta que Frank la apruebe (añade una clave guardada) | M8.2 |
| D8 | Los textos de base en el sitio público | Aplicada la opción de trabajo: están en `referencias/base/`, fuera de lo que publica Pages. Se deshace con un `git mv` | M1.2 |
| D9 | El banco de los meses cuyo tema no es el de la asamblea | **No se mueve.** Sigue como ampliación del día; el núcleo sale de la asamblea y del registro de frases. Moverlo obligaría a reescribir los cuentos semanales y a migrar el repaso guardado | M3.3 |

## 3. Cómo se ejecuta

### Una sesión, un módulo

Cada sesión trabaja **un módulo**, o una parte declarada de uno, en su propia
rama y con su PR a `main`. Nada se da por entregado mientras esté en una rama:
Frank compila `main`.

**Al empezar la sesión:**
1. `git status` y `git log --oneline -5`. Si hay cambios sin commit de otra
   herramienta, se para y se avisa.
2. Leer `CLAUDE.md`, este plan, la arquitectura y el **registro del plan
   docente** en `STATUS.md` (abajo).
3. Elegir el módulo: el siguiente de la ruta (apartado 6) cuyas dependencias
   estén en `main` y cuyas decisiones estén tomadas o tengan opción de trabajo.
4. Escribir en la primera respuesta el módulo, su alcance y el camino de la
   app que va a tocar, para que Frank lo corrija antes de empezar.

**Al cerrar la sesión:**
1. Correr `tools/gates.sh` y los gates propios del módulo.
2. Si el módulo cambia algo que se ve: abrir la app, llegar por el camino de
   uso y mirar las capturas en gallego y en castellano, también con texto
   grande.
3. Commit, push y PR.
4. Anotar el módulo en el registro de `STATUS.md`: estado, evidencia (gate,
   captura o comando), qué falta y el siguiente paso.

### Estados de un módulo

| Estado | Quiere decir |
| --- | --- |
| Pendiente | No empezado |
| En curso | Empezado en una rama; el registro dice qué parte está hecha |
| Bloqueado | Falta algo externo (una decisión, un acceso, un dibujo); el registro dice qué y quién |
| En rama | Terminado y con gates verdes, con PR abierto y sin mergear |
| En `main` | Mergeado, con CI completo en verde |
| Visto | En `main` y recorrido en la app por el camino de uso, con capturas |

Un módulo solo está **hecho** en «Visto», o en «En `main`» si no tiene nada
visible.

### El registro del plan docente

Vive en `STATUS.md`, en una tabla con una fila por módulo: identificador,
estado, fecha, evidencia y siguiente paso. Es contabilidad interna, así que va
ahí y no en este documento.

### Capas y criterio común de hecho

Cada módulo dice qué capas toca:
- JSON en gallego y en castellano;
- audio inglés de cada frase que se oye;
- audio gl/es si la cadena se reproduce;
- imprimible;
- textos de la interfaz;
- manual;
- si cambia lo que se guarda: política de privacidad, formulario de Seguridad
  de los datos de Play Console y gates de privacidad.

Además de su criterio propio, todo módulo cumple esto:
1. el JSON gallego y el castellano dicen lo mismo;
2. el audio va en el mismo commit que su texto;
3. `tools/gates.sh` está verde y el APK de release no declara permiso de red;
4. ninguna pieza nueva pide repetir, traducir ni «decir cómo se dice» (gate
   de M2.4, desde que exista).

## 4. Objetivos

| Objetivo | Qué cambia para quien usa la app | Módulos |
| --- | --- | --- |
| **O1 · Base fiable** | Nada visible. Lo que llegue a pantalla está contrastado y los identificadores son estables | M1.1-M1.3 |
| **O2 · Una sola manera de hablar** | La docente y la familia tienen el modelo entero, siete estrategias y una formación de cuatro fases | M2.1-M2.4 |
| **O3 · Una unidad por mes** | Cada mes cuenta un solo tema con un núcleo estable, igual en el aula, en el calendario y en casa | M3.1-M3.10 |
| **O4 · Una sola asamblea** | La asamblea sale de su unidad, la espera se ve y desaparece la de seis pasos | M4.1-M4.4 |
| **O5 · El cuento como conversación** | 40 microcuentos con lámina, frase de Lúa, tríada y recast; la espera se ve en todos los cuentos | M5.1-M5.8 |
| **O6 · La casa guiada** | La familia tiene guía estable, guía de su edad y, cada semana, un reto que coincide con el del aula | M6.1-M6.8 |
| **O7 · Inglés y jornada coherentes** | Recursos, dinámicas, ciencia y juegos usan las mismas frases que la unidad | M7.1-M7.3 |
| **O8 · Observación y papel** | Qué observar sin casilla; manual e imprimibles al día | M8.1-M8.3 |

## 5. Módulos

Cada ficha dice: objetivo, dependencias (**Dep.**), decisiones, alcance,
entregables, verificación, cuándo está hecho y **sesiones** (estimación, no
compromiso). Los módulos que dicen «por curso» se pueden partir en una sesión
por curso; el registro anota qué cursos están hechos.

### O1 · Base fiable

**M1.1 · Normativa contrastada**
- **Dep.:** ninguna. **Bloqueo conocido:** el DOG no es accesible desde el
  entorno de trabajo. Hace falta permitir el host `xunta.gal` o que Frank
  aporte los PDF del Decreto 150/2022 y de la Orden de 30 de mayo de 2023.
- **Alcance:**
  - área y bloque del inglés;
  - código del criterio: los textos dicen CA2.7 y las asambleas citan CA1.1
    y CA3.1;
  - horario del 2.º ciclo;
  - denominación oficial.
- **Entregable:** `docs/referencias/normativa.md`, con cita literal y artículo
  por dato. Si el código de criterio de las asambleas está mal, se anota para
  M4.1.
- **Hecho cuando:** cada dato normativo que vaya a una pantalla tiene su cita
  literal al lado.
- **Sesiones:** 1.

**M1.2 · Fe de erratas de los textos de base**
- **Dep.:** ninguna. **Decisión:** D8.
- **Alcance:** todo lo que no debe pasar al JSON:
  - identificador HIS-001 repetido;
  - escenarios de otra edad;
  - pez de color cambiante;
  - fonética británica y contrastes que no casan;
  - calendario de unidades solapado;
  - ejemplos que piden repetir;
  - inglés poco natural;
  - lenguaje clínico;
  - las dos definiciones de CROWD y de expansión.

  Además, la ubicación de los textos según D8: `referencias/base/`.
- **Entregable:** `referencias/base/ERRATAS.md`, junto a los textos.
- **Hecho cuando:** cada errata tiene fichero, línea y corrección.
- **Sesiones:** 1.

**M1.3 · Identificadores estables**
- **Dep.:** ninguna.
- **Alcance:**
  - el banco de 3-4 pasa al esquema `<curso>.<mes>.s<semana>.<clave>`, con
    tabla de equivalencias;
  - se actualiza todo lo que cita esos identificadores (cuentos semanales,
    `ponte_ao_dia.json`, manifiestos de voz);
  - **migración del repaso guardado**: al cargar `user_progress.json`, una
    tarjeta con el hash antiguo pasa al nuevo.
- **Verificación:**
  - los gates del banco y de los cuentos, verdes;
  - un test con un `user_progress.json` antiguo, que conserva sus tarjetas;
  - el gate de privacidad, verde (no aparece ninguna clave nueva).
- **Hecho cuando:** los cinco cursos usan el mismo esquema y ningún repaso se
  pierde.
- **Sesiones:** 1-2.

### O2 · Una sola manera de hablar

**M2.4 · Gate «nunca repetir»** (va primero en O2, porque vigila todo lo que
venga después)
- **Dep.:** ninguna. **Decisión:** D3.
- **Alcance:**
  - `tools/check_sin_repetir.py`, para gl, es y en: «say», «can you say»,
    «repeat», «repite», «di …», «dime cómo se dice», «no se dice así», «that's
    wrong», con una lista de excepciones justificadas en el propio fichero;
  - corregir lo que ya exista en el contenido.
- **Hecho cuando:** está en `tools/gates.sh` y sale verde sobre todo
  `assets/content/`.
- **Sesiones:** 1.

**M2.1 · El modelo y su espacio**
- **Dep.:** M2.4. **Decisión:** D2.
- **Alcance:**
  - `assets/content/modelo/modelo.json`, con el glosario del apartado 7 de la
    arquitectura, los objetivos de cada tramo y qué no es un objetivo, en
    perfil docente y familia;
  - pantalla «El modelo» en Eu (aula) y en Guías (casa).
- **Capas:** JSON gl/es, interfaz, capturas gl/es y texto grande.
- **Hecho cuando:** las dos puertas abren el mismo esqueleto en las dos
  lenguas.
- **Sesiones:** 2.

**M2.2 · Siete estrategias**
- **Dep.:** M2.4.
- **Alcance:**
  - `estrategias_pedagogicas.json` pasa de 5 a 7 fichas, con el habla paralela
    y la expansión, y la espera en tres tiempos;
  - los ejemplos, reescritos según la fe de erratas.
- **Hecho cuando:** Recursos → Estrategias enseña las siete en gl y es.
- **Sesiones:** 1.

**M2.3 · Formación en cuatro fases**
- **Dep.:** M2.1.
- **Alcance:** «Formación en el aula» (`capsulas/aula.*`) pasa de seis pasos a
  las cuatro fases y las herramientas; se revisa también la formación docente.
- **Hecho cuando:** ninguna pantalla habla de seis pasos.
- **Sesiones:** 1.

### O3 · Una unidad por mes

**M3.1 · Esquema de unidad y su gate**
- **Dep.:** M1.3.
- **Alcance:**
  - formato de `assets/content/unidades_mes/<curso>/unidade.NN.json` (NN, el mes del curso), con los campos del
    apartado 3 de la arquitectura;
  - modelo Dart (el cargador entra en M3.4, con la primera unidad: una ruta de assets que no existe no pasa `check_bundled_assets`);
  - `tools/check_unidades.py`, que comprueba que el esquema se cumple, que
    cada identificador citado existe y que cada orden usa el núcleo o el
    registro de frases. Lista los meses que faltan y, en `--estricto`, exige
    los 50.
- **Hecho cuando:** el gate está en `tools/gates.sh`, en modo no estricto.
- **Sesiones:** 1-2.

**M3.2 · Registro de frases**
- **Dep.:** M1.3.
- **Alcance:**
  - `assets/content/registro/frases.json`: las expresiones que no son palabras
    del banco (órdenes de asamblea, fórmulas de turno, frases de Lúa, frases
    de juegos, dinámicas y STEAM), cada una con identificador, gesto en gl/es
    y audio. El banco no cambia (D9);
  - inventario de todas las frases inglesas sueltas de la app, con su destino.
- **Hecho cuando:** cada frase inglesa que hoy está fuera del banco tiene
  identificador en el registro y su audio está generado.
- **Sesiones:** 2.

**M3.3 · El banco frente a la asamblea**
- **Dep.:** M3.2. **Decisión:** D9.
- **Alcance:** con la opción de trabajo, documentar mes a mes qué palabras del
  banco encajan con el centro de la asamblea (y pueden entrar en el núcleo) y
  cuáles no. No se mueve ninguna palabra.
- **Hecho cuando:** existe la tabla de los 50 meses que usan M3.4-M3.8.
- **Sesiones:** 1.

**M3.4 · M3.5 · M3.6 · M3.7 · M3.8 · Unidades de 0-2, 2-3, 3-4, 4-5 y 5-6**
- **Dep.:** M3.1, M3.2, M3.3. Un módulo por curso, diez unidades cada uno.
- **Alcance por unidad:**
  - centro de interés: el de la asamblea (D4);
  - núcleo extraído de las órdenes de la asamblea y del banco que encaja, con
    el tamaño de su edad;
  - fórmulas y estructura donde toquen;
  - órdenes;
  - realia, sacada del material de la asamblea;
  - contraste solo si la voz lo produce;
  - canción;
  - qué observar en el aula;
  - reactivación del mes anterior.

  El bloque `hogar` se escribe en O6.
- **Verificación:** `check_unidades.py` sobre el curso.
- **Hecho cuando:** las diez unidades del curso pasan el gate en gl y es.
- **Sesiones:** 1-2 por curso (5-10 en total).

**M3.9 · Calendario único**
- **Dep.:** M3.4-M3.8.
- **Alcance:**
  - el calendario del aula y el de casa leen la unidad (núcleo del día y semana
    de la progresión);
  - `meses.json` y `curriculo_50_meses.json` quedan derivados o se retiran;
  - salen del paquete los dos ficheros que nada carga.
- **Hecho cuando:** el mismo día enseña el mismo núcleo en el calendario del
  aula, en el de casa y en Hoy (capturas gl/es).
- **Sesiones:** 2.

**M3.10 · Hoy, por la unidad**
- **Dep.:** M3.9. **Decisión:** D1.
- **Alcance:** Hoy del aula y Hoy de casa enseñan primero el núcleo, con su
  objeto, y debajo las cinco del día del banco. En la tarjeta del aula, sin
  desplazamiento vertical: se sustituye o se pliega, no se apila.
- **Hecho cuando:** capturas en gl, es y texto grande en los dos portales.
- **Sesiones:** 1-2.

`check_unidades.py` pasa a `--estricto` cuando M3.4-M3.8 están en `main`.

### O4 · Una sola asamblea

**M4.1 · La asamblea lee su unidad**
- **Dep.:** M3.4-M3.8, M1.1.
- **Alcance:**
  - las 50 asambleas toman órdenes, canción y reactivación de su unidad;
  - la fase de reto TPR lleva una línea para la adulta;
  - el campo de criterio, corregido según M1.1.
- **Hecho cuando:** las 50 sacan las órdenes de su unidad (gate) y se ven en
  la app en los dos ciclos.
- **Sesiones:** 2.

**M4.2 · La espera se ve**
- **Dep.:** M2.1.
- **Alcance:** una cuenta visual y silenciosa, un solo widget, en la fase de
  reto, en el cuento de la semana (lee `tempoEsperaSegundos`) y, cuando exista,
  en el microcuento.
- **Hecho cuando:** se ve en la asamblea y en el cuento, en las dos lenguas y
  sin sonido.
- **Sesiones:** 1.

**M4.3 · Retirar la asamblea de seis pasos**
- **Dep.:** M3.9, M4.1. **Decisión:** D5.
- **Alcance:**
  - recorrer y anotar cada camino que la abre (calendario, lista de unidades,
    Academy);
  - pasar esos caminos a la de cuatro fases;
  - retirar `asamblea/fases.json`, las diez unidades `juega.*` y sus
    pantallas.
- **Hecho cuando:** ningún camino abre la de seis pasos y los gates siguen
  verdes.
- **Sesiones:** 1-2.

**M4.4 · Nota para las casas con el reto**
- **Dep.:** M6.3-M6.7.
- **Alcance:** la nota de cierre enseña el reto de la semana con el mismo
  identificador que Hoy en casa.
- **Hecho cuando:** la nota y Hoy en casa muestran el mismo reto en los 50
  meses (gate) y en capturas.
- **Sesiones:** 1.

### O5 · El cuento como conversación

**M5.1 · Microcuento: modelo y visor**
- **Dep.:** M3.1, M4.2.
- **Alcance:**
  - esquema del microcuento (láminas, frase de Lúa, tríada, guion de recast
    para cinco respuestas, lectura en casa);
  - modelo Dart, visor en modo aula y modo casa, y espera;
  - `tools/check_microcuentos.py`: identificadores, que la frase de Lúa sale
    del núcleo, tres preguntas por lámina, cinco recasts y lámina dibujada.
- **Hecho cuando:** el visor abre un microcuento de prueba en los dos modos y
  el gate está en `tools/gates.sh`.
- **Sesiones:** 2.

**M5.2 · M5.3 · M5.4 · M5.5 · Textos de 2-3, 3-4, 4-5 y 5-6**
- **Dep.:** M5.1 y la unidad de ese curso (M3.5-M3.8). Diez por curso.
- **Alcance:**
  - trama en gl y es, frase de Lúa en inglés, tríada, guion de recast,
    lectura en casa y encargo de cada lámina (una acción, un contraste);
  - 3 láminas en 2-3 y 3-4 años, 4 en 4-5 y 5-6;
  - los dos arquetipos de los textos entran corregidos, en la unidad cuyo
    centro corresponda.
- **Hecho cuando:** los diez del curso pasan el gate, salvo la comprobación de
  lámina, que es M5.6.
- **Sesiones:** 2 por curso (8 en total).

**M5.6 · Láminas**
- **Dep.:** M5.2-M5.5 (encargo de cada lámina).
- **Alcance:**
  - unas 140 láminas con el sistema de láminas propio (`assets/brand/laminas/`
    y `tools/check_laminas.py`);
  - antes de la primera tanda, Frank aprueba el estilo con tres láminas de
    muestra (regla de activos propios).
- **Hecho cuando:** cada microcuento tiene todas sus láminas y
  `check_laminas.py` sale verde.
- **Sesiones:** 1 de estilo + 1-2 por curso (5-9 en total).

**M5.7 · Voz de los microcuentos**
- **Dep.:** M5.2-M5.5.
- **Alcance:**
  - unas 840 frases inglesas (frase de Lúa, tríada y recasts);
  - la narración gl/es, si el visor la reproduce;
  - con el flujo de voz del repositorio.
- **Hecho cuando:** los gates de cobertura y niveles de voz salen verdes.
- **Sesiones:** 1-2.

**M5.8 · Microcuentos en la app**
- **Dep.:** M5.6, M5.7.
- **Alcance:** Explorar → Cuentos y la unidad de cada mes, en los dos portales.
- **Hecho cuando:** `check_microcuentos.py --estricto` está verde (40 de 40) y
  hay capturas gl/es de aula y de casa.
- **Sesiones:** 1.

### O6 · La casa guiada

**M6.1 · Guía estable del hogar**
- **Dep.:** M2.1.
- **Alcance:**
  - `hogar/guia_hogar.json`: diez principios, con las herramientas en versión
    casa;
  - absorbe `formacion.familia.json`, las reglas de `atencion.json` y la
    tarjeta de recast;
  - «Antes de empezar» pasa a ser su resumen.
- **Hecho cuando:** Guías → Antes de empezar y Guías → El modelo la enseñan en
  gl y es.
- **Sesiones:** 1.

**M6.2 · Guía por edad**
- **Dep.:** M6.1.
- **Alcance:** `hogar/hogar_por_edad.json`, con ocho tramos: los cinco que
  existen y tres nuevos de 3 a 6 años. Cada uno con minutos, momento,
  herramienta, qué se le pide, cómo se lee y qué evitar.
- **Hecho cuando:** el portal de familias enseña la guía de la edad elegida en
  los cinco cursos.
- **Sesiones:** 1.

**M6.3 · M6.4 · M6.5 · M6.6 · M6.7 · Casa de 0-2, 2-3, 3-4, 4-5 y 5-6**
- **Dep.:** la unidad del curso (M3.4-M3.8). Para la lectura en casa, el
  microcuento del curso (M5.2-M5.5); la lectura se puede dejar marcada como
  pendiente y cerrar después.
- **Alcance por unidad:** bloque `hogar` con:
  - cuatro retos semanales; en el 2.º ciclo, el primero parte de la
    micro-rutina de su asamblea;
  - la lectura del microcuento en casa;
  - el juego del mes, citado;
  - qué observar en casa;
  - la reactivación.

  Volumen total: 200 retos, 40 lecturas y 50 juegos.
- **Hecho cuando:** las diez unidades del curso tienen su bloque `hogar`
  completo en gl y es (gate) y cada frase tiene audio.
- **Sesiones:** 1-2 por curso (5-10 en total).

**M6.8 · Pantallas de casa**
- **Dep.:** M6.2, M6.3-M6.7, M3.10.
- **Alcance:**
  - Hoy, Calendario, Explorar y Guías del portal de familias, según el
    apartado 8.4 de la arquitectura;
  - el gate del hogar en modo estricto.
- **Hecho cuando:** una familia llega desde Hoy y desde Guías a todo lo de su
  edad y su mes (capturas gl/es y texto grande).
- **Sesiones:** 2.

### O7 · Inglés y jornada coherentes

**M7.1 · Recursos de inglés**
- **Dep.:** M3.10, M3.2.
- **Alcance:**
  - palabras, repaso y frases abren por el núcleo;
  - colocaciones con las fórmulas de turno marcadas;
  - sonidos en inglés americano y solo con contrastes que la voz produce;
  - el corpus de 4.000, rotulado como consulta.
- **Hecho cuando:** capturas gl/es de las cuatro pantallas.
- **Sesiones:** 1-2.

**M7.2 · Dinámicas, ciencia, láminas y juegos**
- **Dep.:** M3.2.
- **Alcance:** sus frases inglesas citan el registro y llevan una línea de
  espera y recast; no se crean actividades nuevas.
- **Hecho cuando:** ninguna frase inglesa de la app queda fuera del registro
  (gate).
- **Sesiones:** 1.

**M7.3 · Planificador**
- **Dep.:** M1.1, M3.4-M3.8.
- **Alcance:** cada mes con el área por su nombre oficial, el criterio con su
  cita, el centro de interés y el núcleo; nunca «Área de Inglés».
- **Hecho cuando:** capturas gl/es de los cinco cursos.
- **Sesiones:** 1.

### O8 · Observación y papel

**M8.1 · Qué observar**
- **Dep.:** M3.4-M3.8, M6.3-M6.7.
- **Alcance:** «qué observar» de cada unidad, en el aula y en casa, sin casilla
  ni guardado, con una línea que dice que no se guarda.
- **Hecho cuando:** se ve en los dos portales y los gates de privacidad siguen
  sin claves nuevas.
- **Sesiones:** 1.

**M8.2 · Lista de práctica de la adulta**
- **Dep.:** M3.10, M6.8. **Decisión:** D7; sin aprobación, el módulo no se
  abre.
- **Alcance:** lista cerrada del apartado 10 de la arquitectura; día sin hora
  e identificadores.
- **Capas:** en el mismo cambio, la política de privacidad y los dos gates. El
  formulario de Seguridad de los datos lo actualiza Frank en Play Console con
  el texto preparado.
- **Hecho cuando:** un día marcado se cierra, se vuelve a abrir y se ve igual.
- **Sesiones:** 1-2.

**M8.3 · Manual, imprimibles y README**
- **Dep.:** todo lo visible ya en `main`.
- **Alcance:** cada pantalla tocada, con sus capturas, en el manual; los
  imprimibles de las unidades; el README.
- **Hecho cuando:** el PDF del manual se mira página a página y no desborda
  nada.
- **Sesiones:** 2.

## 6. Ruta y paralelismo

```text
O1   M1.1 (bloqueado por acceso)   M1.2   M1.3
                                            │
O2   M2.4 ──► M2.1 ──► M2.3                 │
         └──► M2.2                          │
                │                           ▼
O3              │        M3.1 ◄─────────────┤
                │        M3.2 ◄─────────────┘
                │          └──► M3.3
                │                 └──► M3.4 … M3.8 (un curso por sesión)
                │                           └──► M3.9 ──► M3.10
O4   M4.2 ◄─────┘        M4.1 (M3.4-8 + M1.1) ──► M4.3 (con M3.9)
O5   M5.1 (M3.1 + M4.2) ──► M5.2 … M5.5 ──► M5.6 · M5.7 ──► M5.8
O6   M6.1 (M2.1) ──► M6.2     M6.3 … M6.7 (M3.x) ──► M6.8 ──► M4.4
O7   M7.2 (M3.2)    M7.1 (M3.10)    M7.3 (M1.1 + M3.4-8)
O8   M8.1    M8.2 (D7)    M8.3 al final
```

**Orden recomendado:** M2.4 → M1.2 → M1.3 → M3.1 → M3.2 → M2.1 → M3.3 →
M3.4-M3.8, curso a curso. Detrás de cada curso van su casa (M6.x) y sus
microcuentos (M5.x).

**Se puede hacer en paralelo, en otra rama:** M2.2, M2.3, M4.2, M6.1, M6.2 y
M5.1, en cuanto estén sus dependencias. M1.1 en cuanto haya acceso al DOG.

**Rutas largas:** las láminas (M5.6) y la voz (M5.7). Se adelantan en cuanto
cada curso tenga los textos.

## 7. Volumen estimado

| Objetivo | Sesiones |
| --- | --- |
| O1 | 3-4 |
| O2 | 5 |
| O3 | 12-19 |
| O4 | 5-6 |
| O5 | 17-22 |
| O6 | 9-14 |
| O7 | 3-4 |
| O8 | 4-5 |
| **Total** | **58-79** |

La cifra es una estimación para planificar, no un compromiso.

## 8. Riesgos

| Riesgo | Cobertura |
| --- | --- |
| Un dato de un resumen llega a pantalla como si fuera norma | M1.1: cita literal al lado de cada dato normativo |
| Renombrar identificadores borra el repaso guardado | M1.3: migración y test con un fichero antiguo |
| Un «repite» o un «say» se cuela en una lengua | Gate de M2.4, desde el principio |
| Una unidad cita una palabra que no existe | `check_unidades.py` |
| La tarjeta del aula desborda en gallego o con texto grande | Se sustituye o se pliega, no se apila; captura con texto grande en cada módulo visible |
| Las láminas y la voz frenan O5 | Estilo aprobado al principio; los textos de cada curso salen antes y las láminas se encargan por tandas |
| Una sesión deja un módulo a medias sin decirlo | Estado «En curso» en el registro, con qué parte está hecha |
| Dos sesiones tocan los mismos ficheros | Una rama por módulo; al empezar, `git status` y el registro |
| El lenguaje clínico de los textos llega a la app | Fe de erratas (M1.2) y gate de M2.4 |
