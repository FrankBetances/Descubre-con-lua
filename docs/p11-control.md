# Control P11 · Niveles por edad, varios niños, prueba de entrada, repaso y ajuste dinámico

Rama: `antigravity/niveles` (creada desde `main` en `0702c846`).
Órdenes: `O-20261126-1`, `O-20261126-2` y `O-20261126-3` de `docs/ORDENES.md`, con decisiones `D1` a `D6` aprobadas por Frank el 26/11/2026 («Apruebo d1 a d6»).

## Punto de partida (`python3 tools/auditoria_niveles.py` en `0702c846`)

Marca **30** incumplimientos de partida:

```text
== curso_0_2 · 40 semanas
  palabras nuevas distintas: 129 · tipos: {'orde': 37, 'noun': 49, 'verb': 20, 'phrase': 15, 'complex': 5, 'adjective': 3}
  semanas de repaso: 0 de 40
  vuelven menos de 4 veces: 129 de 129
  vuelven tras >4 semanas: 0 de 257 (máximo 3 semanas)
  la semana 1 da por sabidas 0 palabras de otro curso
  frase de la unidad, palabras por semana: [4, 4, 3, 3, 3, 4, 3, 3, 2, 3, 3, 3, 2, 2, 2, 4, 6, 7, 4, 3, 5, 5, 4, 5, 2, 2, 2, 2, 4, 6, 3, 6, 5, 4, 2, 4, 6, 6, 6, 8]
  saltos de más de 2 palabras entre semanas: 1
  gramática por mes (punto de 48, MCER): [(1, 'A1'), (1, 'A1'), (2, 'A1'), (3, 'A1'), (4, 'A1'), (5, 'A1'), (6, 'A1'), (7, 'A1'), (8, 'A1'), (9, 'A1')]

== curso_2_3 · 40 semanas
  palabras nuevas distintas: 120 · tipos: {'orde': 25, 'verb': 55, 'phrase': 7, 'complex': 6, 'adjective': 10, 'noun': 17}
  semanas de repaso: 0 de 40
  vuelven menos de 4 veces: 120 de 120
  vuelven tras >4 semanas: 0 de 242 (máximo 3 semanas)
  la semana 1 da por sabidas 8 palabras de otro curso
  frase de la unidad, palabras por semana: [6, 4, 4, 4, 5, 4, 4, 4, 4, 4, 6, 5, 3, 2, 6, 4, 5, 5, 5, 6, 4, 3, 5, 4, 5, 5, 5, 3, 5, 6, 4, 5, 5, 3, 4, 5, 6, 7, 5, 7]
  saltos de más de 2 palabras entre semanas: 1
  gramática por mes (punto de 48, MCER): [(10, 'A1'), (11, 'A2'), (12, 'A2'), (13, 'A2'), (14, 'A2'), (15, 'A2'), (16, 'A2'), (17, 'A2'), (18, 'A2'), (19, 'A2')]

== curso_3_4 · 40 semanas
  palabras nuevas distintas: 132 · tipos: {'verb': 27, 'palabra': 7, 'noun': 36, 'orde': 30, 'formula': 7, 'phrase': 10, 'adjective': 10, 'estructura': 5}
  semanas de repaso: 0 de 40
  vuelven menos de 4 veces: 132 de 132
  vuelven tras >4 semanas: 0 de 254 (máximo 3 semanas)
  la semana 1 da por sabidas 8 palabras de otro curso
  frase de la unidad, palabras por semana: [7, 6, 5, 7, 5, 4, 5, 6, 5, 5, 5, 4, 7, 4, 6, 6, 5, 5, 6, 6, 4, 4, 4, 4, 5, 5, 4, 4, 6, 7, 7, 7, 8, 8, 8, 9, 6, 6, 5, 9]
  saltos de más de 2 palabras entre semanas: 2
  gramática por mes (punto de 48, MCER): [(20, 'A2'), (21, 'B1'), (22, 'B1'), (23, 'B1'), (24, 'B1'), (25, 'B1'), (25, 'B1'), (26, 'B1'), (27, 'B1'), (28, 'B1')]

== curso_4_5 · 40 semanas
  palabras nuevas distintas: 142 · tipos: {'noun': 42, 'adjective': 29, 'orde': 30, 'formula': 8, 'phrase': 4, 'estructura': 8, 'palabra': 5, 'verb': 15, 'complex': 1}
  semanas de repaso: 0 de 40
  vuelven menos de 4 veces: 142 de 142
  vuelven tras >4 semanas: 0 de 257 (máximo 3 semanas)
  la semana 1 da por sabidas 8 palabras de otro curso
  frase de la unidad, palabras por semana: [7, 7, 8, 6, 6, 4, 5, 4, 7, 6, 6, 6, 5, 4, 4, 5, 4, 6, 7, 5, 9, 10, 8, 6, 11, 8, 8, 11, 5, 6, 6, 8, 5, 5, 8, 5, 6, 8, 6, 4]
  saltos de más de 2 palabras entre semanas: 5
  gramática por mes (punto de 48, MCER): [(29, 'B1'), (30, 'B1'), (31, 'B1'), (32, 'B1'), (33, 'B1'), (34, 'B2'), (35, 'B2'), (36, 'B2'), (37, 'B2'), (38, 'B2')]

== curso_5_6 · 40 semanas
  palabras nuevas distintas: 140 · tipos: {'verb': 28, 'noun': 38, 'adjective': 18, 'palabra': 8, 'orde': 30, 'formula': 8, 'complex': 2, 'estructura': 3, 'phrase': 5}
  semanas de repaso: 0 de 40
  vuelven menos de 4 veces: 140 de 140
  vuelven tras >4 semanas: 0 de 257 (máximo 3 semanas)
  la semana 1 da por sabidas 8 palabras de otro curso
  frase de la unidad, palabras por semana: [7, 6, 6, 7, 8, 9, 8, 7, 8, 7, 8, 7, 6, 5, 6, 8, 7, 9, 5, 7, 7, 5, 6, 7, 8, 8, 7, 6, 7, 5, 6, 5, 8, 9, 7, 7, 10, 8, 3, 8]
  saltos de más de 2 palabras entre semanas: 3
  gramática por mes (punto de 48, MCER): [(39, 'B2'), (40, 'B2'), (41, 'B2'), (42, 'B2'), (43, 'B2'), (44, 'C1'), (45, 'C1'), (46, 'C1'), (47, 'C1'), (48, 'C1')]

== curso_0_2 · palabras de casa (proxectos_0_2.json)
  mes  9: 20 palabras, 2 de dos o más palabras
  mes 10: 20 palabras, 4 de dos o más palabras
  mes 11: 20 palabras, 5 de dos o más palabras
  mes 12: 20 palabras, 5 de dos o más palabras
  mes  1: 20 palabras, 2 de dos o más palabras
  mes  2: 20 palabras, 10 de dos o más palabras
  mes  3: 20 palabras, 10 de dos o más palabras
  mes  4: 20 palabras, 5 de dos o más palabras
  mes  5: 20 palabras, 9 de dos o más palabras
  mes  6: 20 palabras, 6 de dos o más palabras
  distintas en el curso: 199 · vuelven otro mes: 1

Umbrales del plan incumplidos: 30
  - curso_0_2: frase de 8 palabras (techo 3)
  - curso_0_2: 1 saltos de dificultad entre semanas
  - curso_0_2: 129 palabras vuelven menos de 4 veces
  - curso_0_2: ninguna palabra vuelve pasado un mes
  - curso_0_2: ninguna semana de repaso
  - curso_2_3: 9 meses por encima de A1
  - curso_2_3: frase de 7 palabras (techo 4)
  - curso_2_3: 1 saltos de dificultad entre semanas
  - curso_2_3: 120 palabras vuelven menos de 4 veces
  - curso_2_3: ninguna palabra vuelve pasado un mes
  - curso_2_3: ninguna semana de repaso
  - curso_3_4: 10 meses por encima de A1
  - curso_3_4: frase de 9 palabras (techo 5)
  - curso_3_4: 2 saltos de dificultad entre semanas
  - curso_3_4: 132 palabras vuelven menos de 4 veces
  - curso_3_4: ninguna palabra vuelve pasado un mes
  - curso_3_4: ninguna semana de repaso
  - curso_4_5: 10 meses por encima de A2
  - curso_4_5: frase de 11 palabras (techo 6)
  - curso_4_5: 5 saltos de dificultad entre semanas
  - curso_4_5: 142 palabras vuelven menos de 4 veces
  - curso_4_5: ninguna palabra vuelve pasado un mes
  - curso_4_5: ninguna semana de repaso
  - curso_5_6: 10 meses por encima de A2
  - curso_5_6: frase de 10 palabras (techo 7)
  - curso_5_6: 3 saltos de dificultad entre semanas
  - curso_5_6: 140 palabras vuelven menos de 4 veces
  - curso_5_6: ninguna palabra vuelve pasado un mes
  - curso_5_6: ninguna semana de repaso
  - curso_0_2: solo 1 de 199 palabras vuelven otro mes
```

## Tabla de control de criterios abiertos (`O-20261126-1`, `O-20261126-2`, `O-20261126-3`) y mejoras `M1–M5` (corrección 26/11/2026)

| Orden | Criterio abierto | Paso | Evidencia |
| --- | --- | --- | --- |
| O-20261126-1 | Na casa → alta y Hoxe: varios niños de cursos distintos visibles a la vez, cada uno con su tarea, sus premios y su repaso | P11.1 | `54e380fc`: alta encadenada («Hai outro neno ou nena na casa?»), fila arriba de `Hoxe` por niño, hoja sin cambio de curso de un toque (solo «Editar a …» con confirmación), mes/año de nacimiento con propuesta de septiembre, premios/observaciones/repaso por niño activo (`criancas_test.dart`, `criancas_privacidad_test.dart`) |
| O-20261126-1 | Na casa → Hoxe: «Volven hoxe / Vuelven hoy» por niño; cada palabra vuelve al menos 4 veces en el curso y alguna pasado un mes (`tools/auditoria_niveles.py --gate` en `tools/gates.sh`) | P11.2, P11.8 | P11.2: FSRS por niño en `criancas.json` y bloque `Volven hoxe / Vuelven hoy` (2-4 vencidas, `>6` frena nuevas) verificados en `criancas_test.dart`; `gen_leccions.py` genera 10 semanas de repaso + retornos espaciados `+1/+2/+4/+8/+16` (`auditoria_niveles.py`: 0 `ninguna palabra vuelve pasado un mes` y 0 `semana 1 de otro curso`; solo quedan 9-11 de junio con `<4` semanas finales) |
| O-20261126-1 | Al registrar un niño de 2 años o más: juego de Lúa para saber por dónde empezar, dirigido por la persona adulta, que fija su punto de partida y siembra su repaso | P11.3 | P11.3: `assets/content/nivel/proba_entrada.json` (72 ítems STEAM con lámina y voz gl/es/en), `CatalogoProbaEntrada.avaliar` (para tras 3 fallos seguidos, peldaño con >=2/3, siembra FSRS futura) y `ProbaEntradaScreen` verificados en `proba_entrada_test.dart` y `check_finalidade.py` |
| Corrección 26/11 | Alta de una sola vez (`datos -> rutinas -> prueba >=2a -> otro niño?`), reanudable si se interrumpe, no repetida desde ficha ni tras completar | P11.1, P11.3 | `P11.1–P11.3`: recorrido único completo en `RexistroCrianzaScreen` + `ProbaEntradaScreen` (`0-2` salta prueba), reanudación en `Hoxe` si se interrumpe (`retomar_proba_entrada_card`), sin repetición ni botón en `folla_crianza` verificados en `criancas_test.dart` y `proba_entrada_test.dart` |
| M1 | Marcar en diez segundos al acabar el juego del día (2-4 palabras, lámina + 3 botones), «Lúa pregunta» en domingo (3 palabras de la semana), `semanasConMarcas` sin hora y recordatorio en `Hoxe` tras 2 semanas sin marcas | P11.2 | P11.2: `MarcarEnDezSegundosScreen` al terminar `LeccionDuolingoScreen`, `_LuaPreguntaCard` los domingos en `Hoxe`, `semanasConMarcas` y aviso `aviso_duas_semanas_sen_marcas` verificados en `criancas_test.dart` y `criancas_privacidad_test.dart` |
| M2 | El inglés dentro de las rutinas de casa: elegir 1-2 rutinas en el alta y poner en `Hoxe` la línea STEAM de cada rutina por semana sin repetir entre semanas | P11.1, P11.7 | `P11.1–P11.7`: selector de 1-2 rutinas en `RexistroCrianzaScreen` (`Crianza.rutinas`, `criancas_privacidad_test.dart`), 6 rutinas únicas en cada capa (`nucleo`, `mais`, `apoio`) de las 200 semanas (`leccions.json`) y 40 semanas (`proxectos_0_2.json`), y `_RutinasFogarCard` en `Hoxe` filtrando por niño (`rutinas_e_irmans_test.dart`: dos niños con rutinas distintas ven solo la suya) |
| M3 | Reto de hermanos en `Hoxe` (1/semana cuando hay >=2 niños en cursos distintos, gl/es/en + voz + gate por pareja vecina y semana) | P11.7 | `P11.7`: `gen_reto_irmans.py` genera `assets/content/nivel/reto_irmans.json` (4 parejas vecinas × 40 semanas = 160 piezas con ambos STEAM, `child` + `slow` en `voice-corpus.json` y `check_voz_lenta`), `CatalogoRetoIrmans.paraCursos` usa la pareja del pequeño con el siguiente cuando no son vecinos, y `_RetoIrmansCard` en `Hoxe` marca ambos FSRS y persiste `retosIrmans` sin fechas (`rutinas_e_irmans_test.dart` y `criancas_privacidad_test.dart`) |
| M4 | Cuántas veces la ha oído (`Oíuna N veces / La ha oído N veces`, audio + marcas, sin hora) y mínimo de 8 escuchas (`minimoEscoitasParaFallo = 8`) en P11.4 | P11.2, P11.4 | `P11.2–P11.4`: contador `escoitas` mostrado e incrementado (`criancas_test.dart`), y umbral constante `minimoEscoitasParaFallo = 8` en `axuste_semanal.dart` verificado en `axuste_semanal_test.dart` (`<8` escuchas no baja la tasa) |
| M5 | La tarjeta de Lúa para la escuela infantil (en ficha de cada niño, solo mostrar, sin porcentajes ni vocabulario clínico, `check_finalidade.py` verde) | P11.4 | `P11.4`: `TarxetaEscolaScreen` abierta desde `folla_crianza` (`crianza_tarxeta_escola`) con nombre, curso, peldaño en palabras sencillas y palabras dichas con lámina, sin porcentajes ni envío, verificada en `axuste_semanal_test.dart` y `check_finalidade.py` |
| O-20261126-1 | 0-2 años: sustantivos, adjetivos, onomatopeyas, rutinas y sucesos y series básicas, con el STEAM del mes y muchas repeticiones | P11.6 | `P11.6` (D4): `gen_acopros_0_2.py` sustituye las 199 palabras de `proxectos_0_2.json` por 60 piezas en 5 familias (`sustantivos` 24, `adxectivos` 10, `onomatopeias` 8 unidas a objeto, `rutinas` 10, `series` 8), 2 nuevas por semana activa, <=3 palabras sin `to be`, `parteSteam` en cada pieza, 45/60 repetidas entre meses (`auditoria_niveles.py`: 0 incumplimientos en 0-2 casa), 23 láminas nuevas (`check_laminas.py`: 4072 OK), voz `child` + `slow` (`voice-corpus.json`: 40595) y `acopros_0_2_test.dart` verde. Referencia léxica infantil: MacArthur-Bates CDI / Wordbank (Stanford University, CC BY 4.0, sin NC/ND) |
| O-20261126-1 | De una semana a la siguiente el nivel sube sin saltos y la gramática no pasa del techo de cada edad, en las cinco edades (`tools/auditoria_niveles.py --gate`) | P11.5, P11.7, P11.8, P11.10 | `P11.5–P11.10`: techos MCER (0), frases máx. (0), saltos >2 (0), semanas de repaso (50/200), retornos tras >4 sem. (0 fallos en semanas 0–23 con `>=16` sem. por delante), palabras tardías (últimas `<16` sem.) heredadas al `xaSabe` de la semana 1 del curso siguiente en `tools/gen_leccions.py` (`curso_2_3`: 41, `curso_3_4`: 36, `curso_4_5`: 43, `curso_5_6`: 48) y `0-2` casa (0 fallos); `tools/auditoria_niveles.py --gate` devuelve **0 incumplimientos** y queda conectado en `tools/gates.sh` (`P11.10`) |
| O-20261126-2 | Na casa → Hoxe: el cupo de palabras nuevas, el repaso y el peldaño de cada niño cambian cada lunes según lo marcado la semana anterior y una línea en gl y es dice por qué; un test de cuatro niños simulados durante cuarenta semanas lo comprueba | P11.4, P11.10 | `P11.4, P11.10`: `AxusteSemanal` puro en `axuste_semanal.dart`, persistencia por semana del curso en `criancas.json` sin fechas (`criancas_privacidad_test.dart`), línea explicativa en `Hoxe` (`axuste_semanal_explicacion`) sin `%`, `novasConCupo` / `daSemanaConCupo` respetando `cupoNovas` en `Hoxe` (`LeccionDaSemanaCargada`, `TarxetaLua`), `LeccionDuolingoScreen` (`pasosDoDia` / `pasosDoProxecto`) y `ResultadosCrianzaScreen`; test de 40 semanas × 4 niños en `axuste_semanal_test.dart` y test widget de cupos `2` y `5` en el mismo curso y semana en `criancas_test.dart` (`Paso 2`) |
| O-20261126-2 | Cada semana de las cinco edades tiene núcleo, «Máis / Más» y «Apoio / Apoyo», las tres con el STEAM del mes; un gate lo comprueba | P11.6, P11.7, P11.8, P11.10 | `P11.6–P11.10`: `tools/check_capas_semana.py` (conectado en `tools/gates.sh`, 0 fallos) comprueba que las 200 semanas de `leccions.json` y 40 de `proxectos_0_2.json` tienen las 3 capas STEAM con piezas reales, 6 rutinas M2 sin repetir y 160 piezas semanales de `reto_irmans.json`; `_CapaSemanalCard` muestra en `Hoxe` las `pezas` reales de la capa elegida con lámina, voz `child`+`slow` y significado (`criancas_test.dart` Paso 1 + `check_voz_lenta.py` 3698 locuciones / 2140 frases con child 1.05 + slow 1.6) |
| O-20261126-3 | Entrega de Antigravity en `antigravity/niveles` con `docs/p11-control.md` criterio por criterio | P11.10, P11.11 | `P11.10–P11.11`: rama `antigravity/niveles` fusionada con `origin/claude/intelligent-mayer-e3iriy` (`d197777b`), 25 capturas de escritorio a `460x1000` en `gl` y `es` bajo `Xvfb` (con variables `LUA_AGORA`/`LUA_LANG` en el binario de prueba porque `libfaketime.so.1` bloqueaba OpenGL por software de Mesa/Impeller) inspeccionadas visualmente (`docs/capturas/escritorio/p11-*.png`), `capturas_test.dart` (114/114), `manual-casos-de-uso.html`, PDF (43 págs.), DOCX (423 párrafos, 62 imágenes), `catalogo-por-idades.html` + PDF (393 págs., `max_x <= 549.8/595.0`) verificados y `check_manual_build.py` OK. En teléfono móvil físico (APK release instalado, audio en altavoz real, uso real con niños y permisos con `aapt2` en CI): **esto no lo he verificado** |
| O-20261126-3 | Revisado por Claude Code (`auditoria_niveles --gate` y `check_capas_semana` a cero, `gates.sh` y `flutter test` en verde, tres semanas al azar por edad, capturas gl y es miradas) y mergeado en `main` con CI en verde y los audios generados | P11.11 (revisión Claude Code) | Pendiente de revisión de Claude Code sobre `antigravity/niveles`, síntesis en CI (`voice-assets`) de las `3.126` locuciones nuevas de `voice-corpus.json` (total `43.339`) y merge a `main` por Claude Code (sin PR ni merge desde Antigravity) |

## Notas y ajustes de la corrección 26/11/2026 y evolución de `auditoria_niveles.py`

- **Corrección 26/11/2026 («ALTA DE UNA SOLA VEZ Y MEJORAS M1-M5»)**: integrada sin añadir pasos nuevos dentro de `P11.1–P11.11`. El alta incorpora la elección de rutinas de casa (`M2`) desde `P11.2`; `M1` y el contador `M4` quedan integrados en `P11.2` antes de `P11.4`; el tramo final de prueba para >=2 años se añade al alta en `P11.3`; el umbral `>=8` de `M4` y `M5` van en `P11.4`; las líneas por rutina de `M2` y `M3` (reto de hermanos) van en `P11.7` + gate `P11.8`; y `P11.10` cierra la visualización en `Hoxe` de la capa elegida (`_CapaSemanalCard`), el `cupo` semanal (`novasConCupo`), `xaSabe` tardío, `significados.json` (`4.089` entradas) y las 25 capturas de escritorio en `Xvfb 460x1000`.
- **Evolución de `auditoria_niveles.py`**: pasó de **30** incumplimientos de partida en `0702c846` a **0** incumplimientos en `P11.10` (`tools/auditoria_niveles.py --gate` conectado en `tools/gates.sh`): `0` techos MCER superados, `0` frases sobre techo, `0` saltos >2, `50` semanas de repaso en 200 semanas, `0` palabras con `<4` vueltas entre las que tienen `>=16` semanas por delante, y el `100%` de las palabras tardías (`<16` semanas al cierre de curso: `41` de `0-2` a `2-3`, `36` de `2-3` a `3-4`, `43` de `3-4` a `4-5` y `48` de `4-5` a `5-6`) incluidas en el `xaSabe` de la semana 1 del curso siguiente.
- **Lo no verificado en dispositivo físico**: las comprobaciones en teléfono Android físico real (construcción/instalación del APK release y lectura real de voz en dispositivo): **esto no lo he verificado**.
