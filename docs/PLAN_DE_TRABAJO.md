# Plan de trabajo · lo que falta, entero y sin recortes

Plan escrito el 20/10/2026 por orden de Frank: «un plan completo de trabajo, y
no se puede parar hasta que no se termine». Sustituye, para lo que falta, a la
ruta de `docs/PLAN_MEJORA_INTEGRAL.md`, cuyo diagnóstico y módulos hechos
siguen valiendo. Se rige por la **R1** del `CLAUDE.md`: nada de lo que piden
los cinco documentos de `referencias/base/` se quita, se reduce ni se aplaza
sin que Frank lo decida.

## 1. Cómo se ejecuta

- **No se para hasta terminar.** Se trabaja fase tras fase. Si surge una
  pregunta nueva que solo Frank puede decidir, se le hace en ese momento y se
  sigue con lo que no depende de ella.
- **Cada fase acaba en `main`.** Con las capas completas, gates y CI en verde,
  y capturas gl/es mirando lo que Frank verá. Rama `pedagogia`, PR y merge.
- **El informe de cada fase empieza por lo que se ve en la app**, por su
  camino, y dice lo que no se ha visto en un aparato.
- **Ahorro**: una pasada larga de tests por entrega, logs filtrados, agentes
  solo cuando abaraten. Nada se da por hecho sin comprobarlo.

## 2. Qué piden los cinco documentos y dónde entra cada cosa

Comprobado contra la app el 20/10/2026 con `grep` sobre `lib/` y
`assets/content/`.

| Pieza | Documento | Hoy en la app | Fase |
| --- | --- | --- | --- |
| Sesión de 45 min en 4 fases: acogida y pulso 7-10, cuento dialógico 10-12, taller TPR 15-18, despedida con *Mystery Bag* 5-7 | `rutinas-sparkling-sintesis.txt` | No está; hay una asamblea de unos 9 min sin cuento | **F3** |
| Parentese: qué es, cómo se hace y por qué | sparkling, vocabulario | 0 ficheros | **F2** |
| Compuerta social (Kuhl): por qué el audio o la pantalla no sustituyen a la persona | vocabulario | 0 ficheros | **F2** |
| Habla paralela | estrategias | 0 ficheros | **F2** |
| Expansión y modelado sintáctico (+1/+2) | estrategias | 0 ficheros | **F2** |
| Recast, con sus ejemplos y errores que evitar | estrategias | 1 estrategia de 5 y una tarjeta en Academy | **F2** |
| Espera en tres tiempos | estrategias, cuentos | Espera visible en asamblea y cuento | F2 (se explica) |
| Lectura dialógica PEER y CROWD | cuentos, sparkling | Escrita en los 40 microcuentos, sin abrir | **F1**, F3 |
| Cuento dialógico de 3-4 láminas con frase de Lúa y tríada | cuentos | 40 escritos con voz, sin abrir; 3 láminas de 140 | **F1** |
| Etapas por edad (18-36 m y 3-6 años) con objetivos operativos | vocabulario | Solo en los datos; ninguna pantalla | **F2**, F4 |
| Unidades temáticas con objetivos y contraste fonético | vocabulario | 50 unidades; contraste en 2; objetivos en 0 | **F4** |
| Guía de casa: estable, por edad y por mes | arquitectura 8 (sobre los cinco) | No existe (`hogar` vacío en las 50) | **F5** |
| Marco normativo: OBX5, CA2.7 por nivel, un período semanal en 2.º ciclo, XADE | `curriculo-ingles-infantil-galicia.txt` | Citas del Decreto 150/2022; criterios de 1.º ciclo vacíos | **F6** |
| Ratios de 3 adultos y subgrupos | sparkling | No está | P3: una adulta |
| Marioneta-ancla de habla solo en L2 | sparkling | Lúa existe, pero en Academy habla en gl/es | P4: **F2** (Lúa solo en inglés) |
| Registro objetivo (LENA, pruebas) | sparkling | No está; la app no guarda datos de criaturas | P5: **F2** (se explica) |

## 3. Fases, en orden de lo que Frank verá antes

**F1 · Los microcuentos, abiertos (M5.6, M5.8)**
- Láminas: las tres de muestra pasan a la Lúa B y se dibujan las 137 que faltan.
- Caminos: Explorar → Cuentos (casa, una pregunta por lámina) y Modo Aula →
  tarjeta del mes (aula, tríada y recast), en los cinco cursos desde 2-3.
- Hecho cuando: los 40 se abren por los dos caminos, en gl y es, con
  `check_microcuentos.py --estricto` en verde.

**F2 · «El modelo»: cómo se habla (M2.1, M2.2, M2.3, ampliados)**
- Una pantalla en Eu (aula) y otra en Guías (casa) con:
  - parentese y compuerta social;
  - las técnicas una a una: habla paralela, espera en tres tiempos, expansión
    y recast, cada una con su ejemplo bueno, el error que se evita y su voz;
  - las etapas por edad: qué se puede esperar en cada tramo y qué no.
- Estrategias de aula: de 5 a 7 fichas, con los ejemplos corregidos según
  `referencias/base/ERRATAS.md`.
- La formación docente y familiar enlaza con «El modelo».
- Hecho cuando: Eu → El modelo y Guías → El modelo se abren en gl y es, con
  texto grande, y ninguna pantalla habla de seis pasos.

**F3 · La sesión de 45 minutos (nueva)**
- En el Modo Aula, por curso: acogida y pulso (con la canción del mes), cuento
  dialógico (el microcuento), taller TPR (las órdenes y la realia de la
  unidad) y despedida (*Mystery Bag* con los objetos del mes y la canción de
  despedida). Cada fase con sus minutos, su espera y su recast.
- La asamblea corta de 4 fases se queda como opción diaria (P2). En 1.º
  ciclo es una sesión propuesta; en 2.º, el período semanal de inglés.
- Hecho cuando: Modo Aula → la sesión de 45 min se recorre entera en gl y es,
  en los cinco cursos.

**F4 · Unidades completas (M3.x ampliado)**
- Objetivos operativos de cada unidad, sacados del currículo de vocabulario.
- Contraste fonético donde la voz inglesa lo produzca, de 2 a 50 o los que
  quepan.
- Se ve en la tarjeta del mes (aula) y en el calendario.

**F5 · La casa guiada (O6: M6.1-M6.8, y M4.4)**
- La guía estable, la guía por edad y, en cada una de las 50 unidades, el
  bloque `hogar`: cuatro retos semanales, la lectura del microcuento, el juego,
  qué observar y la reactivación.
- La nota para las casas trae el reto de la semana (M4.4).

**F6 · Normativa, inglés y papel (M1.1, O7, O8)**
- Los criterios de cada unidad, del texto curricular de Frank y pendientes de contrastar con el DOG (P6).
- O7: los recursos de inglés abren por el núcleo; las dinámicas, la ciencia,
  las láminas y los juegos citan el registro; el planificador muestra el área
  por su nombre oficial.
- O8: qué observar sin casilla; manual y README al día (sin imprimibles, P10), con el
  PDF mirado página a página.

**F7 · El doble toque dice el significado (orden de Frank, 21/10/2026)**
- Orden: en toda la app, dos toques sobre una frase o palabra en inglés dicen
  su significado en la lengua de la sesión (gl o es), con voz.
- El mecanismo ya existe (`BotonEscuchar.significado`), pero solo lo llevan
  7 de los 34 botones en inglés. Faltan 27, en: calendario (3), STEAM,
  vocabulario (2), asamblea (2), barra de inglés, colocaciones (2), repaso,
  escucha, «O modelo», juego de casa, microcuento (3), visor de cuentos, guía
  de atención, cápsulas, phonics, aprender a leer (3) y láminas (2).
- Capas: el significado gl/es en el JSON de cada frase, su voz gl y es, el
  botón y un gate que falle si un botón en inglés no trae significado.
- Hecho cuando: el gate está verde y el doble toque se ha probado en cada
  pantalla, en gl y en es.

**F8 · STEAM vertebrador (orden de Frank, 21/10/2026)**
- Orden: STEAM no puede ser un añadido de cinco sesiones (una por curso). Tiene
  que vertebrar el curso, con la documentación y los ejemplos que dio Frank.
- Hoy: 5 unidades en `assets/content/steam/unidades_steam.json`, una por
  curso, y `docs/BASE_PEDAGOGICA_STEAM.md`.
- Antes de diseñar: localizar el material STEAM que aportó Frank (en el
  repositorio solo hay el commit 15f1988f, del 29/9) y contrastarlo pieza a
  pieza, con una tabla como la del apartado 2. Lo que no se encuentre se le
  pide a Frank.

**F9 · Las láminas, rehechas con dirección de arte (orden de Frank, 21/10/2026)**
- Orden: el diseño artístico de las 140 láminas de los microcuentos no es
  correcto. Se rehacen con la mejor calidad, no con la vía más rápida.
- Las de F1 salieron de componer piezas de catálogo con rectángulos: sin poses
  ni expresiones, y con colores fijos. Ese método no sirve.
- Antes de dibujar: definir con Frank la dirección de arte (estilo,
  personajes, paleta, poses) sobre tres láminas de muestra, y después las 140.

**F10 · La estructura y el uso se entienden (orden de Frank, repetida muchas veces)**
- Orden: «la estructura no se entiende, hay que mejorarla; tampoco se entiende
  el uso». Ya la dio el 15/9 («la UX del aula está mal», «estructurado por
  edad») y Claude Code no la puso en este plan: lo hizo él.
- Método: (1) recorrer la app entera por los caminos de Frank y capturar cada
  pantalla, en gl y es; (2) dibujar el mapa actual (qué hay, dónde y cuántos
  toques cuesta llegar); (3) proponer UNA estructura nueva, con la primera
  pantalla de cada portal y su recorrido de uso; (4) Frank la aprueba o la
  corrige; (5) se rehace entera (regla 6), no por parches.
- Hecho cuando: Frank abre la app y entiende dónde está cada cosa y para qué
  sirve sin que nadie se lo explique.

**F11 · El plan curricular de Frank, tal cual (orden de Frank, 21/10/2026)**
- Las 50 unidades mensuales no siguen `curriculo-vocabulario-infantil-2-6.txt`:
  sus temas los escribió Claude Code (commits 0106f237, 238fa2c0, a0673d65) y
  ERRATAS.md descartó las unidades del documento sin preguntar. Lo hizo él.
- Se transcriben las 12 unidades del documento (6 bimestrales de 18-36 meses;
  3.1-3.2, 4.1-4.2, 5.1-5.2 de 3-6 años) a `assets/content/curriculo/`, con
  objetivos, vocabulario, acciones TPR, realia, fonología, dinámica y fórmulas,
  y cada unidad mensual cita la suya: centro de interés, núcleo y objetivos
  salen de ella.
- P8 (Frank, 21/10): en 3-6 años cada unidad ocupa medio curso (septiembre-enero
  y febrero-junio); sus 8 semanas se trabajan con la recuperación espaciada del
  propio documento (línea 285).

**F12 · La biblioteca de 100 cuentos dialógicos (orden de Frank, 21/10/2026)**
- `biblioteca-cuentos-dialogicos-bilingues.txt`: HIS-001 a HIS-100, con su
  cabecera (escenario, desafío, acción TPR, resolución, palabras diana, frase de
  Lúa) y, por lámina, composición, narración gl/es con la frase de Lúa en
  inglés, tríada CROWD y pauta de espera y recast. 3 láminas en 2-3 años y 4 en
  4-6 años. Cada cuento, atado a su unidad del plan curricular.
- P9 (Frank, 21/10): los 97 cuentos largos de antes se quedan como material
  complementario.
- Las láminas de los 100 se dibujan con la dirección de arte de F9.

## 4. Decisiones de Frank (20/10/2026)

| | Pregunta | Decisión de Frank | Afecta a |
| --- | --- | --- | --- |
| P1 | Lúa de las láminas | **B, la del icono** (`assets/brand/palette.json`) | F1 |
| P2 | Dónde va la sesión de 45 min | **Ambos ciclos.** En 2.º ciclo es el período semanal de inglés; en 1.º ciclo, una sesión propuesta. La asamblea corta se queda como opción diaria | F3 |
| P3 | Ratio de 3 adultos | **Solo una adulta**: la sesión se escribe para una adulta y no se mencionan ratios | F3 |
| P4 | Lúa como marioneta-ancla | **Sí: Lúa solo habla en inglés**, en todas sus apariciones; la trama y las ayudas las dice la adulta en gl/es | F1, F2, F3 |
| P5 | LENA y pruebas | **Se explican en «El modelo», no se usan**; la app no mide ni guarda nada | F2 |
| P6 | Criterios de evaluación | **Del texto de Frank** (CA2.7 por nivel), marcados como pendientes de contrastar con el DOG | F6 |
| P7 | Lista de práctica de la adulta | **Entra**, con la política de privacidad y los dos gates en el mismo cambio; Frank actualiza el formulario de Play Console | F2 |
| P10 | Imprimibles de las unidades | **No se hacen: es una app.** En su lugar, un código que la escuela da a la familia y que, escrito en la app de casa, abre el núcleo, el reto de la semana y qué mirar (Frank, 26/10/2026) | F6 |

## 5. Lo que ya está hecho y no se repite

O1 (salvo M1.1), O3 (las 50 unidades, el registro y el núcleo en Hoy y en los
calendarios), O4 (salvo M4.4) y O5 (salvo M5.6 y M5.8). El detalle y la
evidencia de cada módulo están en `STATUS.md`.

El 26/10/2026, en la rama `pedagogia`: F4 (contraste de sonido en 48 unidades
y objetivos en el calendario), F5 (la casa guiada: 50 bloques `hogar`, guía
estable y por edad, nota para las casas) y F6 salvo el contraste de la
normativa con el DOG, que sigue inaccesible desde aquí. Los imprimibles no se
hacen (P10): en su lugar, el código para casa. Detalle y evidencia en `STATUS.md`.
