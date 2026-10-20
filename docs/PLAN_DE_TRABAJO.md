# Plan de trabajo · lo que falta, entero y sin recortes

Plan escrito el 20/10/2026 por orden de Frank: «un plan completo de trabajo, y
no se puede parar hasta que no se termine». Sustituye, para lo que falta, a la
ruta de `docs/PLAN_MEJORA_INTEGRAL.md`, cuyo diagnóstico y módulos hechos
siguen valiendo. Se rige por la **R1** del `CLAUDE.md`: nada de lo que piden
los cinco documentos de `referencias/base/` se quita, se reduce ni se aplaza
sin que Frank lo decida.

## 1. Cómo se ejecuta

- **No se para hasta terminar.** Se trabaja fase tras fase. Solo se espera
  cuando hay una pregunta abierta a Frank en la tabla del apartado 4, y
  mientras tanto se sigue con lo que no depende de ella.
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
| Ratios de 3 adultos y subgrupos | sparkling | No está | **Pregunta P3** |
| Marioneta-ancla de habla solo en L2 | sparkling | Lúa existe, pero no habla solo en inglés | **Pregunta P4** |
| Registro objetivo (LENA, pruebas) | sparkling | No está; la app no guarda datos de criaturas | **Pregunta P5** |

## 3. Fases, en orden de lo que Frank verá antes

**F1 · Los microcuentos, abiertos (M5.6, M5.8)**
- Láminas: las 137 que faltan, en el estilo que Frank elija (P1).
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
- La asamblea corta de 4 fases se queda como opción diaria, si Frank lo
  confirma (P2).
- Hecho cuando: Modo Aula → la sesión de 45 min se recorre entera en gl y es,
  en los cursos que Frank fije.

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
- Los criterios de cada unidad, con la normativa contrastada (P6).
- O7: los recursos de inglés abren por el núcleo; las dinámicas, la ciencia,
  las láminas y los juegos citan el registro; el planificador muestra el área
  por su nombre oficial.
- O8: qué observar sin casilla; manual, imprimibles y README al día, con el
  PDF mirado página a página.

## 4. Preguntas abiertas a Frank

Hasta que conteste, no se decide por él; se trabaja en lo que no depende de
ellas.

| | Pregunta | Afecta a |
| --- | --- | --- |
| P1 | Lúa de las láminas: **A** (marrón, la de los cuentos) o **B** (la del icono) | F1 |
| P2 | En **1.º ciclo (0-3)**, que no tiene franja de inglés: ¿también la sesión de 45 min, o la asamblea corta? En 2.º ciclo, ¿la sesión de 45 min es el período semanal de inglés? | F3 |
| P3 | Ratio de 3 adultos y subgrupos de 4-6: ¿se propone en la app como organización recomendada, o se adapta a una adulta? | F3 |
| P4 | ¿Lúa hace de marioneta-ancla que solo habla en inglés? Choca con la frase de Lúa dentro de una trama en gl/es (D2) | F1, F3 |
| P5 | LENA y pruebas estandarizadas: la app no guarda datos de criaturas. ¿Se explican como referencia del modelo o no entran? | F2 |
| P6 | Criterios de evaluación: el DOG no es accesible desde aquí. ¿Se toman del texto curricular de Frank (CA2.7 por nivel) mientras tanto? | F6 |
| P7 | D7, la lista de práctica de la adulta: añade una clave guardada. ¿Entra? | F2 |

## 5. Lo que ya está hecho y no se repite

O1 (salvo M1.1), O3 (las 50 unidades, el registro y el núcleo en Hoy y en los
calendarios), O4 (salvo M4.4) y O5 (salvo M5.6 y M5.8). El detalle y la
evidencia de cada módulo están en `STATUS.md`.
