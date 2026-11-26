# Auditoría y plan · varios niños por familia, nivel por edad y repaso

Órdenes O-20261126-1 y O-20261126-2 de Frank (26/11/2026), copiadas literal en
`docs/ORDENES.md`.
Este documento no cambia nada de la app: mide, explica la causa y propone. Lo que
sale de él se ejecuta solo con las decisiones de Frank de la sección 3.

Cómo leerlo. Cada afirmación lleva su origen: **[medido]** sale de
`python3 tools/auditoria_niveles.py`, que cualquiera puede volver a correr;
**[código]** es lo que dice un fichero, con su ruta; **[orden]** es una orden
anterior de Frank en `docs/ORDENES.md`; **[inferencia]** es una conclusión mía
a partir de lo anterior; **[propuesta]** es lo que recomiendo y decide Frank.
Nada de esto lo he visto en un aparato ni he arrancado la app para hacerlo:
**esto no lo he verificado en pantalla**. La auditoría es del contenido y del
código.

## 1. Lo que falta de la orden

De la orden de hoy (auditoría forense, análisis y plan completo) no falta nada:
está en este documento y en el script. De las mejoras en sí no hay nada hecho,
porque cuatro de las cinco tocan contenido que Frank dio por bueno o datos que
la app guarda, y eso lo decide él (sección 3).

## 2. Auditoría

### H1 · Varios niños: el dato lo admite, la app lo esconde

[código] `lib/features/criancas/criancas_store.dart` guarda una lista de niños,
cada uno con nombre, edad, curso, observaciones por semana y premios propios.
El problema no es el almacén: es el camino. El alta inicial
(`lib/features/familias/portal_familias_screen.dart`, `rexistro_primeira`) pide
un solo niño y entra en el portal. Para añadir el segundo hay que tocar el chip
de arriba, bajar la hoja entera y encontrar «Añadir otro niño» al fondo, debajo
de la lista de cursos (`lib/features/criancas/crianza_da_casa.dart`). Hoy
enseña un niño cada vez: con dos hermanos en cursos distintos la familia cambia
a mano y no hay ninguna vista de la casa entera.

Tres defectos más, del mismo fichero. La lista de cursos de esa hoja no elige
qué se ve, sino que reescribe el curso del niño activo (`_cambiarCurso` →
`actualizar`): un toque equivocado le cambia el curso a Uxía. La edad se guarda
en años enteros, así que en 0-2 no se distingue un bebé de 7 meses de uno de 22,
y ni la edad ni el curso avanzan solos en septiembre. Y el repaso espaciado que
existe (`user_progress.json`, FSRS) es de la persona adulta, no de cada niño
(ver H4).

### H2 · 0-2 años: mucho vocabulario, raro y sin volver

[medido] En casa, 0-2 sigue `assets/content/acopros/proxectos_0_2.json`: 20
palabras por mes, cinco nuevas cada semana, **199 palabras distintas en el
curso y solo una vuelve otro mes** («Mittens»). La semana 4 se llama «Repasamos
todo el proyecto» y trae cinco palabras nuevas. Entre ellas: Toenails, Chestnut
husk, Roasting pan, Window pane, Knuckles, Tree bark, Wrapping paper, Coat hook.
En la lección de 0-2 de `leccions.json` hay 3 adjetivos de 129 piezas nuevas,
ninguna pieza de tipo serie ni secuencia de rutina, y frases de la unidad de
hasta 8 palabras.

[inferencia] Lo que Frank pide para 0-2 (sustantivos, adjetivos, onomatopeyas,
reconocer rutinas y sucesos, series muy básicas, muchas repeticiones) está
disperso: hay onomatopeyas («Splash!», «Baa», «Tweet», «Drip, drop!») y alguna
rutina («Bath time!», «Sleep!»), pero como piezas sueltas que no vuelven.

Aviso sobre la medida de frecuencia. El corpus de la app
(`assets/content/corpus/ingles_4000_uso_habitual.json`) es de uso adulto: deja
fuera tummy, toes o puppy, que son núcleo del habla a un bebé. No sirve para
decidir qué palabra es frecuente a esta edad. Hace falta una referencia de habla
dirigida a niños pequeños, con licencia comercial compatible (por verificar).

### H3 · Nivel de entrada: no existe, se supone

[código] No hay ninguna prueba de nivel en `lib/` ni en `assets/content/`.
[medido] La semana 1 de 2-3, 3-4, 4-5 y 5-6 lista en «Ya las conoce» 8 palabras
de cursos anteriores. Un niño que empieza a los 4 años arranca como si llevase
dos cursos con la app. Ejemplo, 3-4 años, primera semana de septiembre: «Calm
sea», «Sandpit», «Sea glass», «Driftwood».

[inferencia] La materia prima para saber el nivel ya está: cada palabra tiene su
observación por niño («aún no», «la entiende», «la dice»). Falta usarla al
principio y para decidir qué viene después.

### H4 · Repaso: no hay sistema, hay un eco de tres semanas

[medido] **0 semanas de repaso de 200** en los cinco cursos, y el campo
`repasa` vacío en todas. [código] La causa está en `tools/gen_leccions.py`,
línea 524: `repaso = not novas`. Solo hay repaso si una semana no trae palabras
nuevas, y todas las traen.

Lo único que vuelve es «Ya las conoce», que son las últimas 8 piezas
(`gen_leccions.py`, línea 634). [medido] Resultado: cada palabra vuelve como
mucho tres veces, **siempre dentro de las tres semanas siguientes y nunca
después**. Las palabras de septiembre no han vuelto desde octubre cuando acaba
el curso. Ninguna de las 663 palabras nuevas vuelve cuatro veces.

[código] El motor de repaso espaciado existe (`lib/core/fsrs_service.dart`),
pero solo lo usa el entrenador de Recursos docentes
(`lib/features/docentes/views/recursos_docentes_screen.dart`). En casa no se usa,
no es por niño y las observaciones de la familia no deciden nada de lo que
vuelve.

### H5 · Progresión: gramática a ritmo de adulto y dificultad que oscila

[orden] Frank pidió los 48 puntos de gramática A1-C1 (O-20261028-3) y que fueran
para los niños, uno por mes a lo largo de los 50 meses (O-20261028-9). [código]
Lo ejecuté yo (commits `86d0cfe4` y `dd6c87b7`), con un gate en
`tools/gen_gramatica.py` que falla si la columna baja.

[medido] Lo que sale: 2-3 años trabaja A2 desde octubre; 3-4 años, B1 (presente
perfecto) desde octubre; 4-5 años, B1 y desde febrero B2; 5-6 años, B2 y desde
febrero C1 («Inversión enfática»).
Ejemplo literal de 4-5 años, un miércoles: «If we had used boots, we would have
stayed clean.», tercer condicional para un niño de cuatro años.

[medido] La frase de la semana no sube, oscila. 4-5 años, semanas 20 a 29:
5, 9, 10, 8, 6, 11, 8, 8, 11, 5 palabras. Saltos de más de dos palabras de una
semana a la siguiente: 1 en 0-2, 1 en 2-3, 2 en 3-4, 5 en 4-5 y 3 en 5-6.

[inferencia] El desajuste que Frank nota entre semanas tiene tres causas que se
suman: nadie controla la longitud de la frase; las palabras se eligen por el
tema STEAM sin control de dificultad; y el punto de gramática cambia cada mes
lo domine o no el niño.

[inferencia] Lo que pide Frank hoy choca con O-20261028-9. Con 48 puntos
repartidos en el tiempo y sin bajar, un niño de 5-6 años siempre estará en C1.
No se arregla afinando contenido: hay que cambiar la regla, y eso es decisión
de Frank (D1).

## 3. Decisiones de Frank, con mi recomendación

**D1 · Las 48 unidades.** Recomiendo que dejen de ir una por mes y pasen a ser
una escalera: el niño sube un peldaño cuando domina el anterior, con un techo
por edad. 0-2 sin gramática, solo palabra, onomatopeya, rutina y serie; 2-3 con
fórmulas fijas de los puntos 1-9 («All done!», «More, please»); 3-4 con los
puntos A1 como fórmulas; 4-5 con A1 y algunos A2; 5-6 hasta A2. B1-C1 pasan a la
guía de la persona adulta, que es quien los usa al hablar. Las 48 siguen todas
en la app y con su STEAM; lo que cambia es quién llega a cuál. Referencia para
el techo: los exámenes de inglés de Cambridge para escolares empiezan en Pre-A1
(por verificar en la fuente oficial antes de citarlo fuera de aquí). La
alternativa, dejarlas por mes, mantiene el problema de H5.

**D2 · La prueba de nivel.** La regla del producto dice que el niño no usa la
pantalla. Recomiendo un juego de 5 a 8 minutos que dirige la persona adulta: la
app le dice qué pedir, con objetos de casa o una lámina impresa, el niño lo hace
y la persona adulta marca lo que ve con las tres marcas de siempre. No es un
examen ni un diagnóstico, y la app no lo llamará así (nada sanitario). La
alternativa de que el niño toque la pantalla rompe la regla.

**D3 · Qué se guarda de nuevo.** La prueba necesita guardar su resultado (el
peldaño de entrada) y el repaso por niño necesita una tarjeta por palabra y por
niño. Recomiendo además mes y año de nacimiento, sin día, para que la edad y el
curso avancen solos y para distinguir meses en 0-2. Cualquier campo nuevo obliga,
en el mismo cambio, a tocar la política de privacidad, el formulario de Play y
`test/core/criancas_privacidad_test.dart`.

**D4 · Rehacer 0-2.** Sustituir las 199 palabras es borrar contenido, así que
solo con el sí de Frank nombrándolo (R-BORRAR). Propuesta: un núcleo de unas 60
piezas en cinco familias (sustantivos de su mundo, adjetivos de contraste,
onomatopeyas, rutinas y sucesos, series básicas como «one, two, three» o
grande-pequeño-grande), dos o tres nuevas por semana y cada una de vuelta muchos
meses. Cada pieza nombra el STEAM del mes y qué parte trabaja: «Wet» y «Dry» ya
son el STEAM de septiembre («Mollado e seco»).

**D5 · Ritmo por edad.** Propuesta, a ajustar con la logopeda que ya probó la
app: palabras nuevas por semana 2-3 en 0-2, 3 en 2-3, 3-4 en 3-4, 4 en 4-5 y
4-5 en 5-6, y frase máxima de 3, 4, 5, 6 y 7 palabras. Son cifras de partida,
no datos de un estudio.

**D6 · Ajuste dinámico (O-20261126-2).** Dos preguntas. Primera: si el
material que no toca se esconde o solo se deja de proponer. Recomiendo lo
segundo: Hoxe propone lo justo para ese niño, y Explorar sigue enseñándolo todo
a la persona adulta, que a veces tiene dos hijos o quiere adelantarse. Esconder
contenido a quien paga por él genera quejas y no aporta nada al niño. Segunda:
los umbrales de la sección 4b. Son mi propuesta; conviene que la logopeda los
revise antes de programarlos.

## 4. Plan por fases

Cada fase acaba en algo que Frank ve en la app, por su camino, en gallego y en
castellano, con su gate. Los umbrales de `tools/auditoria_niveles.py --gate`
son los de D1 y D5; hoy se incumplen 30, y el gate entra en `tools/gates.sh` en
la fase que corrige cada uno, no antes, porque hoy tumbaría CI.

| Fase | Qué ve Frank y dónde | Depende de | Gate que la cierra |
| --- | --- | --- | --- |
| F1 · Familia con varios niños | Na casa: al dar de alta, «¿Hay otro neno na casa?». En Hoxe, arriba, una fila con cada niño (Lúa y su nombre) y la tarea de hoy de cada uno; un toque cambia de niño. El curso solo se cambia dentro de «Editar». Premios por niño | D3 (si se guarda la fecha) | widget test con tres niños en tres cursos y capturas gl/es |
| F2 · Repaso por niño | En Hoxe, «Volven hoxe / Vuelven hoy»: 2 a 4 palabras de cualquier semana anterior, elegidas por el FSRS de ese niño. «La dice» alarga el intervalo, «la entiende» lo mantiene, «aún no» lo acorta. En el aula, donde no hay niños, vuelven a 1, 2, 4, 8 y 16 semanas fijas | D3 | `auditoria_niveles.py --gate`: cada palabra vuelve al menos 4 veces y alguna pasado un mes; test de la tarjeta por niño |
| F3 · Prueba de nivel | Dentro del alta, una sola vez por niño de 2 años o más (Frank, 26/11/2026): «Xogo de Lúa para saber por onde empezar». Después no se repite: el nivel lo ajusta F3b cada semana. Peldaños de comprensión de órdenes, señalar, contraste, decir la palabra y decir una frase corta, con palabras del STEAM de su curso. Para tras tres fallos seguidos; el peldaño es el último con dos de tres. Siembra el repaso con lo que ya sabe | D1, D2, D3 | test del árbol de decisión y de la siembra |
| F3b · Ajuste dinámico | Na casa → Hoxe: cada lunes, cuántas palabras nuevas tiene el niño, cuánto repaso y en qué peldaño está cambian según lo que la familia marcó la semana anterior; una línea dice por qué («Esta semana 4 palabras novas: Uxía xa di 4 das 5 da anterior»). Ver 4b | F2, F3, D1, D5, D6 | test con cuatro niños simulados (rápido, medio, lento y sin marcas) y gate de capas por semana |
| F4 · 0-2 rehecho | Na casa, 0-2: dos o tres piezas nuevas por semana de las cinco familias de D4, frases de tres palabras como mucho, y lo de semanas anteriores volviendo cada día | D4, D5 | `--gate` en 0-2 |
| F5 · 2-3 a 5-6 recalibrados | Cada semana un poco más que la anterior, sin saltos; la gramática dentro del techo de su edad y avanzando por peldaño | D1, D5 | `--gate` en las cuatro edades |
| F6 · Capas | Audio gl, es y en de cada frase cambiada, imprimible, manual con capturas nuevas, privacidad y ficha de Play si cambian los datos; mergeado en `main` con CI en verde | todas | `tools/gates.sh`, `check_voice_coverage.py`, `check_manual_build.py` |

Orden que recomiendo: F1 y F2 primero, porque arreglan dos de las quejas sin
tocar contenido ya aprobado; F3 en cuanto estén D1 a D3; F3b justo después,
porque sin la prueba y el repaso por niño no tiene de dónde leer; F4 y F5
después, ya escritas en las tres capas de 4b.

Coste, dicho antes (R00). F4 y F5 rehacen frases con voz: cientos de audios
nuevos en tres idiomas que genera el workflow de voz. F1 y F2 son código y no
generan audio.

## 4b. Ajuste dinámico: el material crece con lo que el niño ya sabe

Pedido por Frank el 26/11/2026 (O-20261126-2). Todo es **[propuesta]**.

**Qué decide.** Tres mandos por niño, que se recalculan cada lunes, sin red y
con reglas fijas que se pueden explicar a la familia (nada de inteligencia
artificial): el **cupo** de palabras nuevas de la semana, la **mezcla** de
nuevo y repaso de cada día, y el **peldaño** de la escalera de D1, que fija la
longitud de la frase y la gramática.

**De qué lee.** Del punto de partida que dio la prueba de entrada (F3), de lo
que la persona adulta marcó la semana anterior («aún no», «la entiende», «la
dice»), de las tarjetas de repaso de ese niño que vencen esta semana (F2) y de
cuántos días se hizo el juego. Las marcas ya existen hoy (H3); la prueba y el
repaso por niño son F3 y F2.

**Reglas de partida.** La tasa de la semana es la parte de las palabras nuevas
que el niño entiende o dice.

| Lo que pasó la semana anterior | Qué cambia esta semana |
| --- | --- |
| Entiende el 80 % o más y dice el 50 % o más | Una palabra nueva más, hasta el máximo de su edad, y se abre la capa «Máis / Más» |
| Entiende entre el 50 % y el 79 % | Igual que la semana anterior |
| Entiende menos del 50 % | Una palabra nueva menos, hasta el mínimo de su edad, se usa la capa «Apoio / Apoyo» y el repaso gana peso |
| Menos del 30 % tres semanas seguidas | Semana de consolidar: ninguna palabra nueva, todo repaso; el peldaño baja uno |
| Dice el 80 % de las piezas del peldaño dos semanas seguidas | Sube un peldaño, sin pasar del techo de su edad (D1) |
| Más de 6 tarjetas de repaso vencidas | Ese día no entran palabras nuevas, para no pasar de cinco minutos |
| La familia no marcó nada | No sube ni baja: sigue el ritmo base de su edad. Nunca se inventa un avance |

Cupo de palabras nuevas por semana, mínimo y máximo: 0-2 de 1 a 3; 2-3 de 2 a
4; 3-4 de 2 a 5; 4-5 de 3 a 6; 5-6 de 3 a 7. Arrancan en la cifra de D5 o en la
que diga la prueba de entrada.

**Qué exige al contenido.** Para que haya material distinto según el niño, cada
semana tiene que estar escrita en tres capas, y las tres nombran el STEAM del
mes y la parte que trabajan (R-STEAM). El **núcleo** lo ve todo niño de esa
edad. **Máis / Más** es para el que va rápido: dos o tres piezas más del mismo
experimento y una frase del peldaño siguiente. **Apoio / Apoyo** es para el que
va despacio: la misma idea con una frase más corta y una palabra ya conocida.
Escribirlo es trabajo nuevo, no se rellena repitiendo lo que hay (R∞.3).
Además, cada pieza lleva su peldaño y su longitud, y así el motor elige sin
mirar el texto.

**Qué ve la familia.** En Hoxe, una línea con el porqué del cambio de la semana,
en gallego y en castellano, sin notas ni porcentajes: «Esta semana, catro
palabras novas: Uxía xa di catro das cinco da semana pasada». En la ficha del
niño, su peldaño y cómo ha ido cambiando. En el aula no cambia nada: no hay
niños registrados y la docente sigue el núcleo.

**Qué no hace.** No etiqueta ni compara al niño con otros, no diagnostica, no
lleva lenguaje clínico (lo vigila `tools/check_finalidade.py`) y no le quita
nada a la persona adulta: todo el material sigue en Explorar.

**Qué guarda de nuevo** (forma parte de D3). En `criancas.json`, por niño, el
peldaño, el cupo y, por semana del curso (`curso/mes/semana`, sin fecha ni
hora), la tasa y la capa usada. Obliga a actualizar en el mismo cambio la
política de privacidad, el formulario de Play y
`test/core/criancas_privacidad_test.dart`.

**Cómo se comprueba.** Un test que hace pasar cuarenta semanas a cuatro niños
simulados (uno rápido, uno medio, uno lento y uno sin marcas) y comprueba que
el cupo y el peldaño se quedan dentro de los límites de su edad, que el niño
sin marcas no se mueve y que el lento llega a la semana de consolidar. Un gate
de contenido que falla si una semana no tiene sus tres capas o si alguna no
nombra el STEAM del mes.

**Riesgo principal.** Si la familia marca a la ligera, el motor sube demasiado
rápido. Por eso para subir de peldaño hacen falta dos semanas seguidas, el
repaso devuelve las palabras que se marcaron como sabidas y, si después no
salen, la regla del 50 % vuelve a frenar.

## 6. Mejoras propuestas por Claude Code, para que decida Frank

Lo de arriba arregla lo que Frank señaló. Esto es lo que yo añadiría, ordenado
por valor. Todo es **[propuesta]**; nada entra en P11 sin el sí de Frank.

**M1 · Marcar en diez segundos (recomendada, la primera).** Por qué: el repaso
por niño y el ajuste dinámico solo funcionan si la familia marca; sin marcas,
la regla de 4b deja al niño quieto y todo P11 rinde como hoy. Qué: al acabar el
juego del día, una sola pantalla con las 2 a 4 palabras de hoy y tres botones
grandes por palabra («aínda non», «entende», «dío»), sin texto que leer; y el
domingo, «Lúa pregunta» por tres palabras de la semana. Cómo se mide: semanas
con marcas por niño, guardado como contador, sin hora. Coste: una pantalla y un
test; sin audio nuevo.

**M2 · El inglés dentro de una rutina que elige la familia.** Por qué: hoy el
«momento» de cada unidad lo fija el contenido (`hogar.momento` en
`assets/content/unidades_mes/`), no la casa; si en esa casa no hay baño a esa
hora, no hay inglés. Qué: en el alta, la familia elige una o dos rutinas suyas
(baño, comida, coche, ir a dormir) y la app pone ahí las palabras de cada día,
con su gesto. Principio general de la intervención temprana en rutinas, no un
dato medido en esta app. Coste: un campo más en el alta (privacidad) y una
línea por rutina en cada capa.

**M3 · Reto de hermanos.** Por qué: con varios niños en cursos distintos, cada
uno tiene otro experimento STEAM el mismo mes (por ejemplo, en septiembre 2-3
hace «¿Flota o se hunde?» y 4-5 «¿Qué venda absorbe?»), así que la familia
tiene que hacer dos cosas. Qué: una vez por semana, una actividad que junta las
palabras de los dos, en la que el mayor se las dice al pequeño; el mayor
practica decir y el pequeño oye a otro niño. Coste: una pieza por semana y por
pareja de cursos; contenido nuevo con su STEAM.

**M4 · Cuántas veces la ha oído.** Por qué: la familia no ve la repetición, y
por eso no sabe si «aún no la dice» es normal. Qué: junto a cada palabra, «a
oído 12 veces», contando las veces que la persona adulta la puso en la app y
las que marcó; el motor no espera que la diga antes de un mínimo de veces. Coste:
un contador por palabra y por niño, sin hora.

**M5 · La tarjeta de Lúa para la escuela.** Por qué: lo que se hace en casa y
lo que hace la docente no se tocan; ningún dato puede salir del móvil. Qué: una
pantalla que la familia enseña en la escuela, con el peldaño del niño y las
palabras que ya dice, para que la docente sepa por dónde va. No se envía ni se
imprime sola: se muestra. Coste: una pantalla; nada de red.

Lo que no propongo: grabar la voz de la familia o del niño. Pediría micrófono,
y hoy el único permiso es la cámara.

Recomiendo M1 dentro de P11, antes de P11.4, porque sin ella el ajuste dinámico
no tiene datos. M2 a M5, como P12, después de ver P11 en la app.

## 7. Riesgos

La prueba de nivel es una observación de juego hecha por la familia, no una
medida fiable: sirve para no empezar en el sitio equivocado, no para etiquetar
al niño, y se repite sola si las observaciones de las semanas siguientes la
contradicen. El repaso por niño añade minutos al día de la familia: el tope de
2 a 4 palabras es para que no pase de cinco minutos. Cambiar la regla de las 48
unidades deshace parte de O-20261028-9, una orden de Frank: por eso es D1 y no
se toca sin su palabra. Y nada de lo de este plan se ha probado en un móvil.
