# Auditoría y plan · varios niños por familia, nivel por edad y repaso

Orden O-20261126-1 de Frank (26/11/2026), copiada literal en `docs/ORDENES.md`.
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

## 4. Plan por fases

Cada fase acaba en algo que Frank ve en la app, por su camino, en gallego y en
castellano, con su gate. Los umbrales de `tools/auditoria_niveles.py --gate`
son los de D1 y D5; hoy se incumplen 30, y el gate entra en `tools/gates.sh` en
la fase que corrige cada uno, no antes, porque hoy tumbaría CI.

| Fase | Qué ve Frank y dónde | Depende de | Gate que la cierra |
| --- | --- | --- | --- |
| F1 · Familia con varios niños | Na casa: al dar de alta, «¿Hay otro neno na casa?». En Hoxe, arriba, una fila con cada niño (Lúa y su nombre) y la tarea de hoy de cada uno; un toque cambia de niño. El curso solo se cambia dentro de «Editar». Premios por niño | D3 (si se guarda la fecha) | widget test con tres niños en tres cursos y capturas gl/es |
| F2 · Repaso por niño | En Hoxe, «Volven hoxe / Vuelven hoy»: 2 a 4 palabras de cualquier semana anterior, elegidas por el FSRS de ese niño. «La dice» alarga el intervalo, «la entiende» lo mantiene, «aún no» lo acorta. En el aula, donde no hay niños, vuelven a 1, 2, 4, 8 y 16 semanas fijas | D3 | `auditoria_niveles.py --gate`: cada palabra vuelve al menos 4 veces y alguna pasado un mes; test de la tarjeta por niño |
| F3 · Prueba de nivel | Al registrar un niño de 2 años o más, y cuando se quiera desde su ficha: «Xogo de Lúa para saber por onde empezar». Peldaños de comprensión de órdenes, señalar, contraste, decir la palabra y decir una frase corta, con palabras del STEAM de su curso. Para tras tres fallos seguidos; el peldaño es el último con dos de tres. Siembra el repaso con lo que ya sabe | D1, D2, D3 | test del árbol de decisión y de la siembra |
| F4 · 0-2 rehecho | Na casa, 0-2: dos o tres piezas nuevas por semana de las cinco familias de D4, frases de tres palabras como mucho, y lo de semanas anteriores volviendo cada día | D4, D5 | `--gate` en 0-2 |
| F5 · 2-3 a 5-6 recalibrados | Cada semana un poco más que la anterior, sin saltos; la gramática dentro del techo de su edad y avanzando por peldaño | D1, D5 | `--gate` en las cuatro edades |
| F6 · Capas | Audio gl, es y en de cada frase cambiada, imprimible, manual con capturas nuevas, privacidad y ficha de Play si cambian los datos; mergeado en `main` con CI en verde | todas | `tools/gates.sh`, `check_voice_coverage.py`, `check_manual_build.py` |

Orden que recomiendo: F1 y F2 primero, porque arreglan dos de las quejas sin
tocar contenido ya aprobado; F3 en cuanto estén D1 a D3; F4 y F5 después.

Coste, dicho antes (R00). F4 y F5 rehacen frases con voz: cientos de audios
nuevos en tres idiomas que genera el workflow de voz. F1 y F2 son código y no
generan audio.

## 5. Riesgos

La prueba de nivel es una observación de juego hecha por la familia, no una
medida fiable: sirve para no empezar en el sitio equivocado, no para etiquetar
al niño, y se repite sola si las observaciones de las semanas siguientes la
contradicen. El repaso por niño añade minutos al día de la familia: el tope de
2 a 4 palabras es para que no pase de cinco minutos. Cambiar la regla de las 48
unidades deshace parte de O-20261028-9, una orden de Frank: por eso es D1 y no
se toca sin su palabra. Y nada de lo de este plan se ha probado en un móvil.
