# Plan integral de mejora docente

Cómo pasa la app entera, en los cinco cursos y los tres modos, de su estado
actual a la arquitectura de `docs/PLAN_ARQUITECTURA_PEDAGOGIA.md`. **Este
documento no cambia ninguna pantalla.** No hay piloto: cada fase se aplica a
las 50 unidades a la vez, o se dice qué unidad falta y por qué.

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
- Nada guardado de ninguna criatura.

### Lo que rompe la arquitectura

**1. Cada pieza del mes cuenta un tema distinto.** Ejemplos tomados del JSON:

| Curso · mes | Banco | Asamblea | Cuentos del mes |
| --- | --- | --- | --- |
| 2-3 · enero | Autobús, ciudad, puerto | Ropa de invierno, botas, manoplas | Nueces olvidadas; una correa |
| 4-5 · noviembre | Monte de A Guía, robles | Samaín y Magosto | Receta de la abuela; viento del norte |
| 5-6 · abril | La ría limpia, delfines | Animales de granja y monte | Mapa del tesoro; embalse vacío |

**2. El inglés del mes sale de fuentes que no se hablan.**
- Solo 13 de las 133 órdenes de las asambleas están en el banco.
- El léxico mensual de `calendario/curriculo_50_meses.json` (250 palabras, cinco
  al mes) coincide con el banco del mismo mes en 33.
- Hay frases inglesas propias en las dinámicas, los juegos de casa, STEAM, las
  láminas y las guías de atención.

Un mismo día, la docente puede tener tres o cuatro listas inglesas distintas.

**3. Hay dos asambleas.** El Modo Aula usa la de cuatro fases. El calendario
del aula abre otra, de seis pasos, construida sobre `asamblea/fases.json` y las
diez unidades `unidades/juega.*` de un solo tramo (0-3). Esa segunda la abre
`calendario_screen.dart`. «Formación en el aula» también sigue explicando seis
pasos.

**4. Tres calendarios.** Conviven:
- `meses.json`: diez meses, ligados a las unidades de seis pasos;
- `curriculo_50_meses.json`: cincuenta, con su propio léxico;
- `calendario_dias.json`: mil días.

`calendario_3_6_anos.json` y `corpus/bnc_coca_8000.json` no los carga ningún
fichero de `lib/`.

**5. No hay núcleo estable.** Hoy enseña cinco palabras nuevas cada día y
ninguna se queda el mes.

**6. La manera de hablar no está escrita entera.** Faltan el habla paralela y la
expansión. La espera no distingue sus tiempos. El visor del cuento no dibuja
`tempoEsperaSegundos`.

**7. No hay microcuento dialógico.** Falta la lámina corta con frase de Lúa,
tríada en inglés y guion de recast.

**8. Las indicaciones para el hogar están repartidas en ocho sitios que no se
hablan:**
- `formacion/formacion.familia.json` (seis pasos);
- seis cápsulas de Academy;
- `calendario/atencion.json` (tres reglas y cinco tramos, **solo hasta los 36
  meses**);
- las micro-rutinas de casa dentro de las 30 asambleas del **2.º ciclo**;
- `actividadHogar` y `rutinaRecomendadaHogar` de `curriculo_50_meses.json`;
- `actividadHogar` de `meses.json`;
- diez juegos de casa con franjas de edad propias;
- el apartado de casa de STEAM.

**El 1.º ciclo no tiene ninguna rutina de casa por mes**, y ninguna pieza dice
cómo se lee un cuento en casa lámina a lámina.

**9. Identificadores.** El banco de 3-4 usa claves sin prefijo; los otros
cuatro cursos usan `<curso>.<mes>.s<semana>.<clave>`.

**10. Fonética.** La voz inglesa de la app es americana
(`en_US-ljspeech-medium`). Los textos de base transcriben a veces en británico y
proponen contrastes que esa voz no produce.

## 2. Decisiones que toma Frank

**Decididas por Frank:**

| # | Decisión | Qué se hace | Fase |
| --- | --- | --- | --- |
| D4 | Qué centro de interés manda cuando la asamblea y el banco no coinciden | **Manda la asamblea.** El núcleo, los cuentos, los juegos y la casa siguen al centro de interés de la asamblea del mes | 2 |
| D6 | Microcuentos | **Entran, y son esenciales.** Uno por unidad desde 2-3 años: 40 microcuentos y unas 140 láminas | 5 |

**Pendientes.** Cada una dice con qué opción se trabaja mientras Frank no
conteste, y es reversible hasta la fase en que se usa.

| # | Decisión | Opción de trabajo | Fase |
| --- | --- | --- | --- |
| D1 | El banco de cinco palabras al día | Se queda como ampliación; el núcleo va delante | 2 |
| D2 | Inmersión o lengua de casa | Translanguaging: trama en gl/es y frase de Lúa en inglés | 1 |
| D3 | Pedir repetir | Prohibido en las tres lenguas | 1 |
| D5 | La asamblea de seis pasos y sus unidades | Se retira; el calendario abre la de cuatro fases | 4 |
| D7 | Lista de práctica de la persona adulta | No entra hasta que Frank la apruebe, porque añade una clave guardada | 8 |
| D8 | `docs/base/` en el sitio público | Sale de `docs/` a una carpeta que Pages no publica | 0 |

## 3. Fases

Cada fase cubre **los cinco cursos, los diez meses y los tres modos** en las
capas que toca.

**Capas:**
- JSON en gallego y en castellano;
- audio inglés de cada frase que se oye;
- audio gl/es si la cadena se reproduce;
- imprimible;
- textos de la interfaz;
- manual;
- si cambia lo que se guarda: política de privacidad, formulario de Seguridad
  de los datos y gates de privacidad.

**Una fase está hecha cuando:**
1. el JSON gallego y el castellano dicen lo mismo;
2. el audio va en el mismo cambio que el texto;
3. `tools/gates.sh` sale verde y el APK de release sigue sin permiso de red;
4. se abre la app, se llega por el camino de uso y se miran las capturas en
   gallego y en castellano, también con texto grande.

Hasta entonces, la fase está en la rama, pendiente de mergear.

### Fase 0 · Base

- **Contrastar con el DOG**: área y bloque del inglés, el código de criterio
  (los textos dicen CA2.7, las asambleas citan CA1.1 y CA3.1) y el horario del
  2.º ciclo.
- **Fe de erratas de los cinco textos**, para que ningún error pase al JSON:
  - identificador HIS-001 repetido y escenario de otra edad;
  - pez de color cambiante;
  - fonética británica, contrastes que no casan con la lista y objetivos que se
    contradicen;
  - calendario de unidades que se solapa;
  - ejemplos que piden repetir;
  - modelos ingleses poco naturales;
  - lenguaje clínico;
  - las dos definiciones de CROWD y de expansión.
- **Normalizar los identificadores** del banco de 3-4, con tabla de
  equivalencias y los ficheros que los citan.
- **`docs/base/`**: lo que decida D8.

**Hecho cuando** cada dato normativo que vaya a pantalla lleva su cita del DOG,
la fe de erratas está escrita y el banco tiene un único esquema de
identificador.

### Fase 1 · El modelo

- Glosario de la arquitectura (apartado 7) en JSON, en gl y es, con ejemplo
  de aula y de casa.
- El espacio «El modelo» en Eu y en Guías.
- Estrategias: de cinco a siete fichas, con la espera en tres tiempos.
- «Formación en el aula» pasa a cuatro fases.
- **Gate nuevo**: falla si cualquier consigna, guion o pregunta, en gl, es o en,
  pide repetir o corrige de forma explícita.

**Hecho cuando** las dos puertas abren el mismo esqueleto en las dos lenguas,
las siete fichas se ven y el gate está en `tools/gates.sh`.

### Fase 2 · Las 50 unidades

Un JSON por unidad con los campos del apartado 3 de la arquitectura, para los
**50 meses**:

- centro de interés: el de la asamblea del mes (D4). Donde el banco de ese mes
  cuenta otro tema, sus semanas se realinean al centro de la asamblea. Se
  pueden mover palabras entre meses del mismo curso, pero no se borra
  ninguna, y el gate del banco (800 por curso, ninguna nueva dos veces) sigue
  verde;
- núcleo citado por identificador, con el tamaño de su edad;
- fórmulas y estructura donde toquen;
- órdenes hechas con el núcleo;
- realia;
- contraste solo si la voz lo produce;
- canción;
- cuatro retos de casa;
- qué observar;
- reactivación del núcleo del mes anterior.

Volumen: 50 núcleos y 50 juegos de órdenes. Los retos de casa se escriben en
la fase 6. Las expresiones
que falten en el banco se añaden al banco con gesto y audio. Si un mes no tiene
candidatas que cumplan las reglas, se lista con el motivo y lo decide Frank. No
se inventa un identificador.

**Gate nuevo**: falla si una unidad cita un identificador que no existe, si
una orden usa una palabra que no está en el núcleo ni en el registro, o si
falta uno de los 50 meses.

**Hecho cuando** las 50 unidades existen en gl y es y pasan el gate.

### Fase 3 · El calendario único

- `meses.json` y `curriculo_50_meses.json` pasan a leerse de las unidades.
- `calendario_dias.json` sigue siendo el mapa de fechas.
- `calendario_3_6_anos.json` y `bnc_coca_8000.json` salen del paquete, si nada
  los usa.
- El calendario del aula y el de casa enseñan el núcleo del día y la semana de
  la progresión.

**Hecho cuando** el mismo día enseña el mismo núcleo en el calendario del aula,
en el de casa y en Hoy.

### Fase 4 · La asamblea

- Las 50 asambleas (20 + 30) leen órdenes, canción y reactivación de su
  unidad.
- La fase de reto TPR lleva una línea para la adulta y la espera visible.
- La nota de cierre lleva el reto de la semana.
- Se retira la asamblea de seis pasos (según D5): `asamblea/fases.json`, las
  diez unidades `juega.*` y su pantalla. El calendario abre la de cuatro fases.

**Hecho cuando** las 50 asambleas sacan sus órdenes del núcleo y no queda en la
app ningún camino que abra la de seis pasos.

### Fase 5 · El cuento

- **Cuento de la semana**: espera visible con los segundos del dato. No gana
  preguntas.
- **Microcuentos** (D6, decidido): uno por unidad desde 2-3 años, **40 en
  total**. Son la pieza central del inglés de cada unidad, no un extra:
  - 3 láminas en 2-3 y 3-4 años, 4 en 4-5 y 5-6, unas 140 láminas;
  - trama en gl y es, frase de Lúa, tríada, espera y guion de recast por cinco
    respuestas;
  - los dos arquetipos de los textos (*Lúa e o peixiño azul* y *Lúa y el viento
    travieso*) entran corregidos, en la unidad cuyo centro de interés
    corresponda;
  - audio inglés estimado: unas seis frases por lámina, unas 840 en total.

Sin lámina dibujada, el microcuento no entra en la lista: se dice cuál falta.

**Hecho cuando** cada uno de los 40 se abre desde Explorar → Cuentos y desde
su unidad, en los dos portales y las dos lenguas, o figura en la lista de
pendientes con su motivo.

### Fase 6 · Las indicaciones pedagógicas para el hogar

Los tres niveles del apartado 8 de la arquitectura, completos.

**1. La guía estable** (`assets/content/hogar/guia_hogar.json`).
- Diez principios, con las cuatro herramientas en versión de casa y un ejemplo
  doméstico de cada una.
- Absorbe `formacion.familia.json`, las tres reglas de `atencion.json` y la
  tarjeta de recast de Academy. «Antes de empezar» pasa a ser su resumen de dos
  minutos.

**2. La guía por edad** (`assets/content/hogar/hogar_por_edad.json`).
- Ocho filas: los cinco tramos de 0 a 36 meses que ya existen y tres nuevas (3-4,
  4-5 y 5-6 años).
- Cada fila: minutos, momento del día, herramienta principal, qué se le pide,
  cómo se lee y qué evitar, con un ejemplo citado del registro.

**3. La guía de cada unidad** (bloque `hogar` de las 50 unidades).
- **200 retos de casa** (50 unidades × 4 semanas):
  - en el 2.º ciclo, el primer reto de cada mes sale de la micro-rutina que ya
    trae su asamblea (30) y los otros tres siguen la progresión (90);
  - en el 1.º ciclo se escriben los 80, porque no hay ninguna rutina previa.
- **40 lecturas en casa** del microcuento, con una pregunta por lámina.
- **50 juegos del mes**, citados de los juegos de casa o de STEAM. Los meses
  sin juego que encaje se listan.
- **50 «qué observar en casa»** y 50 líneas de reactivación.
- `actividadHogar` de `curriculo_50_meses.json` y de `meses.json` se vuelcan al
  bloque `hogar` y dejan de ser una fuente aparte.
- Cada frase inglesa cita el registro y lleva su audio para que la adulta la
  oiga antes.

**Pantallas** (apartado 8.4 de la arquitectura):
- Hoy y Calendario del portal de familias;
- Explorar → Cuentos y Palabras en inglés;
- Guías → Antes de empezar, El modelo y las lecturas de Academy enlazadas.

**Puente aula-casa:** la nota de cierre de la asamblea y Hoy en casa muestran el
mismo reto, con el mismo identificador.

**Gate nuevo:** falla si una unidad no tiene sus cuatro retos, si un reto cita
una frase que no está en el registro o no tiene audio, o si un reto o una guía
pide repetir, traducir o «decir cómo se dice».

**Hecho cuando** los cinco cursos tienen su guía por edad, las 50 unidades
tienen sus cuatro retos, su lectura (desde 2-3 años), su juego o su motivo de
falta y su qué observar, en gl y es, y una familia llega a todo ello desde Hoy
y desde Guías.

### Fase 7 · El inglés de recursos y el resto de la jornada

- **Palabras, repaso y frases** abren por el núcleo.
- **Colocaciones**: fórmulas de turno marcadas.
- **Sonidos**: solo los contrastes que la voz produce, en inglés americano.
- **Corpus de 4.000** como consulta de la adulta.
- **Dinámicas, Ciencia y láminas**: sus frases inglesas citan el registro y
  llevan la línea de espera y recast.
- **Planificador**: el área por su nombre oficial, con el criterio contrastado
  en la fase 0.

**Hecho cuando** no queda en la app ninguna frase inglesa que no esté en el
registro y ninguna pantalla llama al inglés asignatura.

### Fase 8 · Observación y lista de la adulta

- «Qué observar» en cada unidad, sin casilla.
- La lista de práctica de la adulta solo si D7 lo aprueba, con política de
  privacidad, formulario de Seguridad de los datos y los dos gates en el mismo
  cambio.

**Hecho cuando** ninguna pantalla guarda nada de una criatura y, si entra la
lista, un día marcado se cierra, se vuelve a abrir y se ve igual.

### Fase 9 · Papel y documentación

Manual, imprimibles y README de todo lo tocado. El manual se revisa página a
página.

**Hecho cuando** el manual y la pantalla dicen lo mismo.

### Dependencias

- La 0 va antes que todo.
- La 1 y la 2 van antes de la 3, la 4, la 5 y la 6.
- Las lecturas en casa de la 6 esperan a los microcuentos de la 5; la guía
  estable y la guía por edad, no.
- La 4 retira la asamblea de seis pasos solo cuando la 3 ya da el calendario
  único.
- La 8 va al final.

## 4. Riesgos

| Riesgo | Cobertura |
| --- | --- |
| Un dato de un resumen llega a pantalla como si fuera norma | Fase 0: cita del DOG al lado de cada dato normativo |
| Un «repite» o un «say» se cuela en una lengua | Gate de la fase 1 |
| Una unidad cita una palabra que no existe | Gate de la fase 2 |
| La tarjeta única del aula desborda en gallego o con texto grande | Lo nuevo sustituye o se pliega, no se apila; captura con texto grande |
| El volumen de láminas y audio frena la fase 5 | Sin lámina no entra; lista de pendientes visible |
| Retirar la asamblea de seis pasos rompe un camino | La fase 4 recorre cada camino que la abría antes de quitarla |
| El lenguaje clínico de los textos llega a la app | Fe de erratas y revisión de cada JSON nuevo con la regla «nada sanitario» |
| Se lee la lista de la adulta como evaluación | No guarda nada de la criatura y lo dice en pantalla |
