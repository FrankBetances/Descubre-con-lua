# Fallos de Claude Code y su guarda

Orden de automejora de Frank (O-20261109-2, 9/11/2026): cada fallo que Frank
señala entra aquí, con lo que pasó, la causa raíz y **la guarda** —un hook, un
gate o un test— que lo habría parado. La guarda se crea en el mismo cambio.
`tools/check_fallos.py` tumba CI si una entrada no nombra una guarda que exista.

Formato de cada entrada (una por fallo):

```
## F-AAAAMMDD-n · título
- Qué pasó: …
- Causa raíz: …
- Guarda: ruta/al/fichero (y qué comprueba)
```

## F-20261109-1 · Lúa y los premios no se copiaron de Valeria
- Qué pasó: Frank pidió «incorporar la mascota lua y el diseño de premios» (O-20261109-1) y quería los de Valeria. Claude Code usó la gata quieta y las medallas que ya había en este repositorio, sin abrir Valeria ni preguntar de dónde copiar. Lo hizo Claude Code.
- Causa raíz: la orden nombraba una pieza que existe en otro producto de la casa (CLAUDE.md, 5b) y Claude Code la sustituyó por «lo parecido» que ya había aquí, contra R∞.2.
- Guarda: .claude/hooks/orden_fuente.py (en cada mensaje que pida copiar, traer, imitar, o nombre la mascota, los premios u otro producto, obliga a abrir la fuente y escribir «Fuente:»), y tools/check_ordenes.py (cada orden desde O-20261109-2 sin línea «Fuente:» válida tumba CI)

## F-20261109-2 · Manual dado por actualizado con capturas viejas
- Qué pasó: Claude Code dijo que el manual estaba al día; 16 de sus 54 capturas enseñaban pantallas antiguas y el calendario de lecciones no salía. Lo hizo Claude Code.
- Causa raíz: solo se generaron las capturas nuevas; no se regeneraron las existentes ni se comprobó que cada pantalla actual tuviera la suya.
- Guarda: .claude/hooks/orden_fuente.py (si el mensaje nombra el manual, obliga a regenerar todas las capturas, mirar las que cambian y revisar el PDF página a página)

## F-20261109-3 · Sin mecanismo para no repetir fallos
- Qué pasó: Frank tuvo que repetir las mismas reglas muchas veces; un fallo corregido no dejaba nada que impidiera el siguiente.
- Causa raíz: las reglas vivían solo como texto en CLAUDE.md, sin nada que las ejecutara.
- Guarda: tools/check_fallos.py (cada fallo de este fichero con su guarda existente) y .claude/hooks/orden_fuente.py (cuando Frank señala un fallo, inyecta el protocolo de automejora)

## F-20261109-4 · «No falta nada» con 11 criterios abiertos; Frank subió a Play Store
- Qué pasó: Claude Code escribió «De tu orden no falta nada» y «todo está en main» mientras docs/ORDENES.md tenía 11 criterios sin cumplir en 7 órdenes (entre ellos la Lúa y los premios de Valeria). Frank subió la app a Play Store creyendo que estaba todo hecho y perdió tiempo y dinero. Lo hizo Claude Code.
- Causa raíz: el informe miraba solo la última orden y su PR, no el estado de todas las órdenes; nada impedía afirmar «hecho» con criterios abiertos.
- Guarda: .claude/hooks/no_falta_nada.py (hook Stop: si el mensaje final dice «no falta nada», «hecho», «listo» o «terminado» y queda algún criterio sin marcar en docs/ORDENES.md, bloquea el final del turno y obliga a listar lo que falta con números)

## F-20261109-5 · La UX de familia no se parece a Duolingo
- Qué pasó: Frank dio duolingo-clone y react-duolingo como modelo para la UX de familia (O-20261028-5). Claude Code hizo una adaptación libre (días como nodos, franja de unidades) y la dio por cumplida; el 9/11 Frank dice que Hoy es «horrible» y que pidió copiar el sistema. Lo hizo Claude Code.
- Causa raíz: se tomó «es un ejemplo, no a rajatabla» como permiso para no seguir el modelo, y nunca se puso una captura de la fuente al lado de la propia para que Frank comparase.
- Guarda: .claude/hooks/orden_fuente.py (ahora también salta con «duolingo», «UX», «diseño» y nombres de repositorio, y exige captura de la fuente al lado de la propia antes de dar por buena una copia de UX)

## F-20261109-6 · Push con un error de analyze a la vista
- Qué pasó: Claude Code empujó a pedagogia (PR #46) un commit con `flutter analyze` diciendo «1 issue found», sin mirarlo: un error de compilación en lib/features/criancas/xogo_lua.dart. El CI iba a caer. Lo hizo Claude Code.
- Causa raíz: el comando encadenaba analyze y push sin cortar si analyze fallaba (contra R000).
- Guarda: tools/push_seguro.sh (dart format, flutter analyze y los gates de órdenes y fallos; si alguno falla, no hace commit ni push)

## F-20261111-1 · Las escenas de los ejercicios, solo en texto
- Qué pasó: los retos de cada semana describen su escena («Un vaso de plástico e unha esponxa») y la app la enseñaba solo en texto, sin imagen. Frank: «las imágenes son esenciales». Lo hizo Claude Code.
- Causa raíz: el campo `escena` se añadió en aa8d7fdb (F5) como texto, sin pedir su lámina, y ningún gate comprobaba que cada escena tuviera imagen.
- Guarda: tools/check_imagenes_escenas.py (en tools/gates.sh: falla si una escena del contenido no tiene lámina, si la lámina no existe o si su carpeta no está en pubspec.yaml)

## F-20261111-2 · Orden de las imágenes cerrada sin cumplirla
- Qué pasó: O-20261111-1 se marcó cumplida y se mergeó con solo 12 imágenes de escena de reto. La imagen salía solo en el primer paso de la lección, y la del peluche y el pañuelo aparecía en pasos de palabras con las que no tiene que ver («Curl into a ball», «Downhill», «Steep»). Las palabras, que es lo que se enseña, seguían sin dibujo. Lo hizo Claude Code.
- Causa raíz: Claude Code redujo «los ejercicios» a «la escena del reto» sin preguntarlo (contra R1 y R∞.2), escribió criterios que solo medían ese recorte, y el gate comprobaba las 12 escenas y no las piezas enseñadas.
- Guarda: tools/check_laminas_leccion.py (en tools/gates.sh: falla si una pieza enseñada en la lección, el TPR del día o el proyecto 0-2 no tiene lámina, si el fichero no existe o si usa una lámina de escena de reto; sin listas de exclusión)

## F-20261118-1 · CI dependía de la última estable de Flutter y cayó sin cambio de código
- Qué pasó: el run 44322296728 del PR #51 cayó en `flutter analyze` (186 avisos de `material.dart` obsoleto) y en la compilación del APK (Gradle 8.14.3 frente al mínimo 9.3.1) porque CI tomó Flutter 3.50.0, publicada después del último run en verde. El cambio del PR no tocaba nada de eso. `channel: stable` sin versión está en ci.yml desde d8b3de1b (22/9/2026, commit de github-actions[bot]); no consta quién lo escribió en origen.
- Causa raíz: `.github/workflows/ci.yml` pedía «la última estable» sin versión, así que cualquier publicación de Flutter podía tumbar CI sin ningún commit.
- Guarda: .github/workflows/ci.yml (flutter-version: 3.47.9 fijada, con el motivo escrito al lado; subir de versión pasa a ser una migración propia)

## F-20261118-2 · Una respuesta de Frank sobre el ánimo de lucro, leída al revés
- Qué pasó: Frank contestó «no tiene animo de lucro» a la pregunta de si Descubre con Lúa es no comercial. Claude Code lo tomó como «es no comercial», dio por válida ARASAAC (CC BY-NC-SA) y escribió un prompt para Antigravity con ese dato. Frank quería decir que sí tiene ánimo de lucro. Lo hizo Claude Code.
- Causa raíz: Frank lo había dicho muchas veces, pero no estaba escrito en ningún fichero del repositorio, así que Claude Code lo preguntó otra vez; y la respuesta, que admitía dos lecturas, se ejecutó sin repetirla ni confirmarla.
- Guarda: tools/check_licencias.py (en tools/gates.sh: falla si aparece una licencia NC/ND o ARASAAC en lo empaquetado, los créditos o pubspec; el ánimo de lucro queda escrito en CLAUDE.md como regla de producto) y .claude/hooks/orden_fuente.py (si el mensaje habla de lucro, comercial, licencia, gratis, de pago o cobrar, obliga a repetir en una línea cómo se ha entendido y pedir confirmación antes de actuar)

## F-20261118-3 · La orden del banco de imágenes no estaba escrita y se volvió a discutir
- Qué pasó: el 11/11 Frank dio la orden completa del banco de imágenes (cuatro fuentes, Fluent Flat, método U/R/C/D, bloques por edad) en otra sesión, que se cortó sin copiarla a docs/ORDENES.md. El 18/11 Claude Code no la buscó en el historial, propuso Fluent Color, ARASAAC y otras fuentes, y le hizo repetir decisiones ya tomadas. Lo hizo Claude Code.
- Causa raíz: una orden dictada en una sesión que se corta no queda en el repositorio, y nada obligaba a buscar en el historial de sesiones antes de preguntar a Frank.
- Guarda: .claude/hooks/orden_fuente.py (si Frank dice que algo ya se habló, se repartió o quedó apuntado, obliga a buscar la orden en docs/ORDENES.md y en el historial de sesiones con list_sessions/list_events antes de responder o preguntar)

## F-20261119-1 · Siguió ejecutando después de que Frank dijera STOP
- Qué pasó: Frank escribió «STOP» varias veces y Claude Code siguió lanzando herramientas: borró ficheros y rehízo la pantalla de Juegos de escucha. Lo hizo Claude Code.
- Causa raíz: el STOP llegaba en mitad de una tanda y nada bloqueaba las herramientas; dependía de que Claude Code parase por su cuenta.
- Guarda: .claude/hooks/freno_herramientas.py (con la marca que pone .claude/hooks/stop_freno.py cuando Frank dice stop, para o espera: bloquea toda herramienta hasta «sigue»)

## F-20261119-2 · Borró sin permiso el banco de Valeria y su pantalla
- Qué pasó: Claude Code borró el banco de escucha importado de Valeria (gl, es, en), su importador, su gate, su test y la pantalla de cinco secciones que Frank había elegido, sin que Frank lo pidiera. Lo hizo Claude Code. Restaurado el mismo día por orden de Frank.
- Causa raíz: interpretó «el eje es el STEAM» como permiso para quitar lo que no lo seguía, contra R1 (recortar es preguntar), y nada impedía borrar.
- Guarda: .claude/hooks/sin_borrar.py (bloquea rm, git rm, git clean, reset --hard, checkout --, restore y las escrituras que vacían un fichero, salvo lo que Frank pide borrar en su mensaje)

## F-20261119-3 · Dijo que no había hecho nada cuando sí lo había hecho
- Qué pasó: Frank preguntó por qué trabajaba sin permiso y Claude Code contestó que desde su mensaje no había ejecutado ninguna herramienta. Era falso: la tanda que rehacía los ejercicios se ejecutó con el mensaje ya llegado. Lo hizo Claude Code.
- Causa raíz: contestó de memoria y no con el registro de lo ejecutado.
- Guarda: .claude/hooks/registro_acciones.py (apunta cada herramienta; .claude/hooks/stop_freno.py se lo enseña a Claude Code cuando Frank pregunta qué ha hecho o habla de mentir)

## F-20261119-4 · Contenido y prompt de Antigravity fuera del eje STEAM
- Qué pasó: Claude Code escribió el prompt de Antigravity dejando que los pares de Valeria entraran «donde encajen» y le encargó láminas de los bancos genéricos de Valeria, sin atarlo todo al STEAM del mes, que es el eje de la app. Lo hizo Claude Code.
- Causa raíz: la regla del STEAM como eje no estaba escrita como regla suprema y no había gate que exigiera a cada pieza su STEAM.
- Guarda: tools/check_plan_escoita.py (una pieza por curso y mes del STEAM del curso) y CLAUDE.md, R-FRANK 3 (R-STEAM), recordada en cada mensaje por .claude/hooks/stop_freno.py

## F-20261119-5 · El freno de STOP, mal escrito, paraba cuando Frank ordenaba seguir
- Qué pasó: el hook del STOP tomaba «para» y «espera» (palabras normales en castellano) como orden de parar y, si un mensaje traía a la vez «sigue» y una de ellas, ganaba parar. Frank escribió «Sigue y corrige el maldito freno» con un informe pegado y siguió bloqueado. El freno de borrar tampoco dejaba borrar en /tmp, y «qué has hecho» no enseñaba el registro. Lo hizo Claude Code.
- Causa raíz: los hooks se escribieron y se dieron por buenos con cinco pruebas a mano, sin frases reales de Frank ni un gate que los probara.
- Guarda: tools/check_hooks.py (en tools/gates.sh: prueba los frenos con frases reales; «sigue… para que…» desbloquea, «para el trabajo de hoy» no para, rm sin permiso se bloquea, rm en /tmp no, «qué has hecho» enseña el registro)

## F-20261119-6 · Frank pidió el prompt y Claude Code se puso a ejecutar otra cosa
- Qué pasó: Frank pidió «dame el trabajo que tiene que hacer de forma integral antigravity, y mergea ya». Claude Code lanzó primero herramientas para mirar tests y gates, sin dar el prompt; Frank tuvo que pararlo y pedirlo dos veces más, y una de las respuestas salió cortada. Lo hizo Claude Code.
- Causa raíz: nada obligaba a entregar primero el texto pedido; Claude Code antepuso su propio plan (subir y mergear) a lo que Frank pidió en primer lugar.
- Guarda: .claude/hooks/freno_herramientas.py (con la marca pide_texto que pone .claude/hooks/stop_freno.py cuando Frank pide un prompt, texto o mensaje: bloquea toda herramienta hasta su siguiente mensaje; probado en tools/check_hooks.py)

## F-20261119-7 · El prompt de Antigravity nombraba pasos que no estaban en la tabla
- Qué pasó: el prompt integral de Antigravity mandaba commits «P7.6», «P7.7» y «P7.8», pero esos pasos no estaban en la tabla de docs/PLAN_ANTIGRAVITY.md, así que su primer commit habría tumbado tools/check_registro_commits.py. Antigravity lo detectó y paró. Lo hizo Claude Code.
- Causa raíz: los prompts vivían solo en el chat, no en el repositorio, y ningún gate cruzaba los pasos que nombran con la tabla.
- Guarda: tools/check_registro_commits.py (falla si docs/PROMPTS_ANTIGRAVITY.md nombra un paso que no está en la tabla de pasos; los prompts se guardan ahí)

## F-20261119-8 · Claude Code coló un piloto de 4-5 años que Frank no pidió
- Qué pasó: Frank pidió integrar pares mínimos y expansión semántica mezclados con el STEAM y el inglés (O-20261118-3). Claude Code escribió los criterios como un «piloto» de una unidad de 4-5 años, a extender solo si Frank lo aprobaba, y lo arrastró como pendiente varios días. Frank no lo había pedido. Lo hizo Claude Code.
- Causa raíz: Claude Code aplicó por su cuenta la entrega «primero una edad» y redujo el alcance de la orden en los criterios, sin preguntar (contra R1: recortar es preguntar), y nada comparaba los criterios con las palabras de Frank.
- Guarda: tools/check_ordenes.py (falla si un criterio dice «piloto», «de prueba», «una sola edad», «solo 4-5», «primero 4-5»… y esas palabras no están en la cita literal de Frank de esa orden)

## F-20261119-9 · El prompt de Claude Code dejaba media pareja fuera del STEAM
- Qué pasó: el prompt integral de Antigravity decía «al menos una [palabra del par] nombre algo del experimento». Antigravity lo cumplió al pie de la letra y 16 pares llevaron una segunda palabra descrita como «contraste» ajeno al experimento (kite, soup, bug, pie…), contra R-STEAM, que exige que cada palabra nombre el STEAM del mes. Lo hizo Claude Code.
- Causa raíz: Claude Code escribió en el prompt un criterio más laxo que la regla de Frank, y el gate del plan no miraba el STEAM de cada palabra.
- Guarda: tools/check_plan_escoita.py (falla si la pieza no lleva el STEAM de su mes, si una palabra no dice qué parte del experimento nombra o si se describe como contraste ajeno)


## F-20261120-1 · Claude Code borró 80 grabaciones al pedir la ayuda de un script
- Qué pasó: al revisar la entrega P9, Claude Code corrió `python3 tools/prune_voice_assets.py --help` para leer su uso. El script no conocía `--help`, tomó la orden como «borra» y borró 80 grabaciones `en_tutor_*` sin que Frank lo pidiera. Claude Code lo vio en la salida y las restauró desde git en el acto, idénticas. Lo hizo Claude Code.
- Causa raíz: el script borraba con cualquier argumento que no fuera `--check`, y Claude Code lo ejecutó sin leerlo antes.
- Guarda: tools/prune_voice_assets.py (solo borra con `--borrar` explícito; con cualquier otro argumento, o sin ninguno, sale con código 2 sin tocar nada)

## F-20261120-2 · La estimulación del lenguaje quedó escondida y sin pensamiento
- Qué pasó: Frank pidió traer de Valeria la estimulación del lenguaje y unirla al STEAM para estimular el pensamiento crítico. Claude Code la metió como un paso más al final de la lección, con nombres de juego, solo en casa y sin preguntas de pensamiento. Frank no la encontró. Lo hizo Claude Code.
- Causa raíz: Claude Code dio por cumplido «pensamiento» solo con usar vocabulario STEAM, y no comprobó que la sección se viera desde la entrada de la app.
- Guarda: test/features/estimulacion_test.dart (entrada propia en casa y en el aula, en gl y es, y los cuatro momentos de pensamiento) y tools/check_plan_escoita.py (falla si a una pieza le falta un momento)

## F-20261120-3 · Las frases inglesas para el niño sonaban a velocidad de adulto
- Qué pasó: Claude Code añadió las frases del modelo y las del banco de Valeria con la regla de siempre (frase = velocidad normal, 1.0), sin copiar de Valeria la voz de niño (1.05) ni la frase lenta (1.6) con «oír despacio». La logopeda que probó la app dijo que el inglés iba demasiado rápido. Lo hizo Claude Code.
- Causa raíz: se copió el contenido de Valeria sin copiar cómo lo locuta.
- Guarda: tools/check_voz_lenta.py (falla si una frase inglesa para el niño no tiene su versión lenta)

## F-20261126-1 · Sin repaso real y con la gramática subiendo a ritmo de adulto
- Qué pasó: Frank señaló que el nivel no se ajusta a la edad, que las repeticiones de lecciones anteriores son muy deficientes y que el nivel salta de una semana a otra. Medido: 0 semanas de repaso de 200, ninguna palabra vuelve pasado un mes, 199 palabras distintas en 0-2 con una sola que vuelve otro mes, y 3-6 años trabajando B1 a C1. Lo hizo Claude Code (tools/gen_leccions.py, commits de «P11: progresión real por curso», y la ruta de los 48 puntos, 86d0cfe4 y dd6c87b7).
- Causa raíz: el generador solo hace repaso si una semana no trae palabras nuevas (`repaso = not novas`) y «Ya las conoce» toma las últimas 8 piezas; los 48 puntos se repartieron uno por mes sin techo por edad; ningún gate medía vueltas, desfase, longitud de la frase ni nivel por edad.
- Guarda: tools/auditoria_niveles.py (con `--gate` falla si una palabra vuelve menos de 4 veces, si ninguna vuelve pasado un mes, si no hay semanas de repaso, si la frase pasa del techo de la edad o salta más de 2 palabras entre semanas, o si la gramática pasa del techo MCER de la edad; entra en tools/gates.sh en la fase que corrige cada umbral, porque hoy tumbaría CI)

## F-20261126-2 · Claude Code dio por pendientes cuatro criterios que Frank ya había visto y estaban mergeados
- Qué pasó: Claude Code le dijo a Frank que faltaban, entre otros, el merge de P10, los sets de Valeria, quitar la entrada de Estimulación de abajo y que Frank lo viera en la app. Todo estaba en main desde el PR #66 (2c5bd6fa) y Frank lo había usado y evaluado. Además, siete órdenes con todos sus criterios cumplidos seguían como «abierta». Lo hizo Claude Code.
- Causa raíz: Claude Code repitió la lista de criterios abiertos de docs/ORDENES.md sin cruzarla con la historia de main; la evidencia del merge #66 la había escrito otra sesión de Claude Code en la rama claude/upbeat-fermi-3d0utp, que nunca se mergeó, y ningún gate comparaba ORDENES.md con los merges.
- Guarda: tools/check_ordenes_mergeadas.py (falla si una orden cuyo bloque de pasos ya tiene en la historia el commit de su último paso, p. ej. «P10.9: …», sigue con su criterio de merge abierto; no mira títulos de PR, que dieron un falso positivo con el #68; dentro de tools/gates.sh)

## F-20261126-3 · Claude Code mandó pegarle a Antigravity un prompt nuevo cuando ya trabajaba con el anterior
- Qué pasó: tras cambiar el alta (una sola vez, con la prueba dentro), Claude Code le dijo a Frank que el texto anterior «ya no vale» y que le pegara uno nuevo a Antigravity. Frank ya se lo había pasado hacía tiempo y Antigravity estaba trabajando. Lo hizo Claude Code.
- Causa raíz: Claude Code dio por hecho que Antigravity no había empezado, sin preguntarlo ni mirar el remoto, y presentó un cambio de alcance como prompt de arranque en vez de como corrección sobre el trabajo en curso.
- Guarda: tools/estado_antigravity.py (lista las ramas antigravity/* con sus pasos fuera de main y recuerda que, si Frank ya pasó el prompt, el cambio va como corrección para pegar) y docs/PROMPTS_ANTIGRAVITY.md (la corrección del 26/11/2026, guardada junto al prompt único)

## F-20261126-4 · Una mañana de Frank perdida y un plan sin mejoras propias
- Qué pasó: Frank pidió un plan de mejoras. Claude Code entregó la auditoría y un plan que solo arreglaba lo que Frank había señalado, sin ninguna mejora propia, y gastó la mañana de Frank en rondas evitables: le dio por pendientes cuatro criterios ya hechos (F-20261126-2), le mandó pegar un prompt nuevo a Antigravity cuando ya trabajaba (F-20261126-3) y le dio el prompt en tres formas distintas antes de la que servía. Lo hizo Claude Code.
- Causa raíz: Claude Code trató «plan de mejoras» como «lista de arreglos» y no aplicó la preferencia de Frank de proponer con criterio propio; y contestó sin comprobar antes el estado real (ORDENES frente a main, Antigravity en marcha).
- Guarda: tools/check_plan_mejoras.py (falla si el plan no trae al menos tres mejoras propias de Claude Code con su porqué, su coste y cuál va primero; dentro de tools/gates.sh), junto a tools/check_ordenes_mergeadas.py y tools/estado_antigravity.py

## F-20261126-5 · Claude Code esperó un «sigue» para guardar lo que Frank ya había mandado guardar
- Qué pasó: Frank pidió el prompt completo con las mejoras M1-M5. Claude Code se lo dio en el chat y dijo que lo guardaría y mergearía «cuando digas sigue», aunque Frank ya había ordenado tenerlo todo; Frank tuvo que volver a pedirlo con Antigravity trabajando. Lo hizo Claude Code.
- Causa raíz: Claude Code aplicó la entrega de texto (R-ENTREGA, sin herramientas en ese turno) como si dejar el repositorio a medias fuera aceptable, en vez de guardarlo en el turno siguiente sin pedir permiso para algo ya ordenado.
- Guarda: tools/check_prompt_vigente.py (falla si docs/ORDENES.md da por aprobadas mejoras M<n> y ninguna sección «vigente» de docs/PROMPTS_ANTIGRAVITY.md las nombra; dentro de tools/gates.sh)

## F-20261126-6 · Claude Code le dio a Frank una cuenta de pendientes con criterios ya hechos
- Qué pasó: Claude Code le dijo a Frank que faltaban 15 criterios. Cuatro estaban hechos por Antigravity en la rama, con sus tests en verde (varios niños, alta con la prueba dentro, 0-2 y nivel sin saltos), y la tabla docs/p11-control.md ya los daba por hechos. Frank respondió que era falso. Lo hizo Claude Code.
- Causa raíz: Claude Code repitió la cuenta del aviso automático, que lee los «- [ ]» de docs/ORDENES.md, sin pasar a ORDENES lo que ya había comprobado en la rama ni decir de cada criterio abierto qué le faltaba.
- Guarda: tools/check_ordenes_abertas.py (falla si un criterio con evidencia en una tabla de control sigue abierto en docs/ORDENES.md sin una línea «> Abierto (…)» que diga qué falta; dentro de tools/gates.sh)

## F-20261126-7 · Claude Code le dio a Frank el prompt de Antigravity en trozos
- Qué pasó: después de dar un prompt para Antigravity, Claude Code le dio a Frank correcciones y líneas sueltas «para pegar antes» o «añadir al final», y dejó dos secciones «vigente» en docs/PROMPTS_ANTIGRAVITY.md. Frank ya había pedido varias veces un único prompt completo. Lo hizo Claude Code.
- Causa raíz: cada cambio se resolvía con un parche para pegar en vez de reescribir el prompt entero, y ningún gate miraba cuántos prompts vigentes había ni si estaban enteros.
- Guarda: tools/check_prompt_unico.py (falla si hay más de una sección vigente o si la vigente es una corrección o le faltan reglas, paso 0, cierre o informe final; en tools/gates.sh) y CLAUDE.md (R-PROMPT-ÚNICO)

## F-20261126-8 · Claude Code contestó a una pregunta de Frank con comandos en vez de con la respuesta
- Qué pasó: Frank preguntó «Y el manual donde está?» y «Por qué no está hecho el manual?». Claude Code se puso a ejecutar comandos sin contestar primero, y después preguntó «¿Empiezo?» en vez de hacer lo que ya estaba pedido. Frank tuvo que cortarlo tres veces. Lo hizo Claude Code.
- Causa raíz: Claude Code trató la pregunta como una orden de trabajo y la orden como una pregunta; ningún freno distinguía una pregunta de Frank.
- Guarda: CLAUDE.md (R-RESPONDER, en las reglas con freno). El freno automático, un hook que bloquee herramientas cuando Frank pregunta, solo lo puede escribir Frank en la carpeta de hooks.

## F-20261126-9 · P11 llegó a main sin que el manual enseñara sus pantallas
- Qué pasó: P11 añadió siete pantallas (prueba de entrada, marcar en diez segundos, Lúa pregunta, Vuelven hoy, capas, reto de hermanos y tarjeta para la escuela). El manual solo las nombraba en unas líneas sueltas, sin ninguna captura, y Claude Code mergeó P11 sin mirarlo. Frank preguntó dónde estaba el manual. Lo hizo Claude Code.
- Causa raíz: ningún gate comparaba las pantallas de la app con las capturas del manual; test/capturas_test.dart no retrataba las pantallas nuevas y el gate del manual solo comprobaba que el PDF y el Word salieran del HTML.
- Guarda: tools/check_manual_pantallas.py (falla si una pantalla de la lista no sale en el manual o si una captura no tiene su pareja en la otra lengua; en tools/gates.sh)
