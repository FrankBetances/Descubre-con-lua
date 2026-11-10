# Órdenes de Frank

Cada orden, literal y con fecha, partida en criterios de aceptación. Regla R∞
de `CLAUDE.md`. Una orden está **cumplida** solo si cada criterio tiene su
evidencia: el test, el gate o la captura que lo demuestra. Lo comprueba
`tools/check_ordenes.py`.

Formato de cada orden:

```
## O-AAAAMMDD-n · Título
Estado: abierta | cumplida
> texto literal de Frank

- [ ] criterio · evidencia: (vacío mientras no la haya)
- [x] criterio · evidencia: test/… o tools/… o docs/capturas/…
```

## O-20261027-1 · Lecciones claras por grupos y edades
Estado: cumplida
> tiene que ser modular tiene que haber lecciones claras por grupos adaptadas a los años [...] padres no entienden cuáles son las palabras que deberían saber antes que tienen que saber en este módulo

- [x] Cada curso tiene su propio camino de unidades y lecciones · evidencia: test/features/leccions/leccions_test.dart («progresión: 10 unidades distintas…»)
- [x] Cada lección dice lo que ya debería saber y lo nuevo · evidencia: test/features/leccions/leccions_test.dart («o que xa coñece é o ensinado antes»)
- [x] Se ve en Na casa → Hoxe y Na escola → Hoxe · evidencia: docs/capturas/hoxe-familias-gl.png, docs/capturas/hoxe-docentes-gl.png

## O-20261027-2 · Para quien no sabe pedagogía
Estado: cumplida
> los padres no tienen ni idea de pedagogía [...] que entiendan los que están haciendo y cómo lo deben hacer y el porqué de las cosas

- [x] Cada paso de la semana dice qué hacer y por qué · evidencia: test/features/leccions/leccions_test.dart («a lección, a 360 px e escala 1.8»)
- [x] De dónde viene y a dónde va cada lección · evidencia: docs/capturas/hoxe-familias-es.png

## O-20261028-1 · Progresión sin repetir
Estado: cumplida
> no existe progresión, has colocado solo un ejercicio por ciclo / año que se repite dia a dia, mes tras mes

- [x] Ninguna palabra se enseña dos veces en un curso · evidencia: test/features/leccions/leccions_test.dart («ningunha palabra se ensina dúas veces…»)
- [x] Nunca dos retos iguales seguidos; 0-2 y 2-3 distintos · evidencia: test/features/leccions/leccions_test.dart («progresión: 10 unidades distintas…»)
- [x] Cada día de la semana, una actividad distinta · evidencia: test/features/leccions/leccions_test.dart («ningunha palabra se ensina dúas veces e cada unha di que é»)

## O-20261028-2 · Doble toque con significado
Estado: cumplida
> cuando doy doble toque no dice el significado ni en gallego ni castellano ni aparece en la pantalla

- [x] Todo el inglés de las lecciones lleva significado en gl y es · evidencia: test/features/leccions/leccions_test.dart («todo o inglés das leccións leva o seu significado…»)
- [x] Cada significado tiene su grabación · evidencia: tools/check_voice_coverage.py

## O-20261028-3 · Estructura gramatical A1-C1
Estado: cumplida
> la maldita estructura debe ser : Nivel A1 (Principiante / Acceso) [...] Nivel C1 (Dominio Operativo Eficaz) [48 puntos]

- [x] Los 48 puntos de Frank, en su orden, con su descripción · evidencia: tools/gen_gramatica.py
- [x] A1-A2 (1-20) en la columna de las cinco edades, sin bajar de una edad a la siguiente · evidencia: tools/gen_gramatica.py
- [x] Cada unidad trabaja un punto y cada semana tiene su frase con significado · evidencia: test/features/leccions/leccions_test.dart («cada unidade leva o seu punto de gramática…»)
- [x] B1-C1 para la persona adulta, con ejemplo · evidencia: test/features/leccions/leccions_test.dart («a gramática do curso, a 360 px e escala 1.8»)
- [x] Las frases nuevas tienen su voz · evidencia: tools/check_voice_coverage.py (37057 locuciones, todas grabadas; run 104 de Generate Voice Assets en verde)
- [x] Se ve en Na casa → Hoxe, en gl y es · evidencia: docs/capturas/escritorio/hoxe-casa-4-5-gl.png y hoxe-casa-4-5-es.png

## O-20261028-4 · Hoy de las familias: claro, sin ruido, con UX validada
Estado: abierta
> para los padres sigue sin entenderse nada es un mix sin sentido, he probado en 4-5 años [...] se repiten las mismas palabras por trimestres [...] la UI UX de los padres es un desastre esta llena de ruido e información que no hace falta, es un scroll infinito que no se entiende, tampoco se entiende las unidades, no sabe de lo que se habla ni hacia donde va
> busca en GitHub todas las UX-UI que funcionan para nuestro caso y adaptalas, no inventes nada

UX de referencia, de código abierto: Bebbo (UNICEF, GPL-3.0, 0-6 años; portada con la etapa de la criatura y una tarjeta diaria de un juego y una lectura) y Oppia Android (tema → lista de lecciones con estado y la siguiente).

- [ ] Na casa → Hoy, 4-5 años: la etapa (edad, unidad n de 10 con su tema y barra), las palabras de la semana, la gramática en una línea y lo de hoy caben en la primera pantalla de 412×915, sin bajar · evidencia:
- [x] Hoy tiene una sola tarjeta «Hoy» con una cosa que hacer (Bebbo) · evidencia: test/features/leccions/leccions_test.dart («dónde estamos e o de hoxe, sen baixar» y «a 360 px e escala 1.8, sen desbordar»)
- [x] La unidad es una lista de 4 lecciones con su estado y dice cuál viene después (Oppia) · evidencia: test/features/leccions/leccions_test.dart («o camiño dos 10 temas, coa lección de agora»)
- [x] En Hoy, lo nuevo nunca es una palabra ya enseñada en el curso; lo de antes solo sale rotulado «Ya debería saber». Reescrito por la orden posterior de Frank, 28/10: «los padres tienen que saber lo que iba antes o lo que deben saber antes si o sí» · evidencia: test/features/leccions/leccions_test.dart («ningunha palabra se ensina dúas veces» y «o que xa coñece é o ensinado antes»)
- [x] Lo complementario no ocupa Hoy: queda plegado al final · evidencia: test/features/ux_l3_test.dart («Máis para casa» vai pregado, ao final)
- [x] Visto en la app de escritorio por Na casa → Hoy, en gl y es · evidencia: docs/capturas/escritorio/hoxe-casa-4-5-gl.png, hoxe-casa-4-5-es.png y hoxe-casa-4-5-es-abaixo.png

## O-20261028-5 · Replicar la UX de los repositorios de GitHub que da Frank
Estado: cumplida
> Específicos para niños: phonics-app, 453★ [...] Kids Zone, 12★ [...] yarareads, 29★, MIT [...] s5s5/phonics, MIT [...] buzzphonics, 63★, MIT [...] Adaptables, con muy buena UI: duolingo-clone, 691★, MIT y activo (Next.js y Tailwind). Es la mejor base para montar un "Duolingo para niños". react-duolingo, 471★, MIT.

Límites que Frank conoce: phonics-app sin licencia y Kids Zone con licencia que impide competir: de esos se toma solo la UX visible, no el código. Los infantiles los usa la criatura; aquí la pantalla la usa la persona adulta.

- [x] Las unidades se ven como el camino de duolingo-clone / react-duolingo: cabecera de unidad y lecciones en fila, con la actual resaltada y las siguientes por delante · evidencia: test/features/leccions/leccions_test.dart («o camiño dos 10 temas, coa lección de agora»)
- [x] Al tocar una palabra se oye y se ve su significado (como yarareads al tocar) · evidencia: test/features/leccions/leccions_test.dart («todo o inglés das leccións leva o seu significado…»)
- [x] Visto en la app de escritorio por Na casa → Hoy, 4-5 años, en gl y es · evidencia: docs/capturas/escritorio/hoxe-casa-4-5-gl.png, hoxe-casa-4-5-es.png y camino-aula-0-2-gl.png

## O-20261028-6 · Progresión real y la unidad de la semana a la vista
Estado: abierta
> revisa que realmente las unidades estén donde tienen que estar que exista una progresión real, no me engañes otra vez, cuando termines de revisar además pon el título que corresponde a la unidad porque hace falta saber de qué va la unidad, que si hay 48 malditas unidades [...] pongas la maldita unidad que se está tratando en la maldita semana [...] si es sustantivo adjetivo o lo que toque [...] después arregla la maldita ux UI con los fucking ejemplos que te di ya para copiar de GitHub, cuando tengas todo hecho [...] y revisado que realmente funciona, pues mergealo todo ya

- [x] Revisión con datos: las 20 unidades A1-A2 van en orden ascendente a lo largo de los 50 meses, sin volver atrás · evidencia: tools/gen_gramatica.py (--check, en tools/gates.sh: falla si la columna baja)
- [x] En la semana se ve, arriba y a un tamaño adecuado, la unidad de las 48 que se trabaja, con la de antes y la de después: número, título y qué es. Corregido por Frank, 28/10: «El título no tiene porque ser tan en grande» · evidencia: test/features/leccions/leccions_test.dart («dónde estamos e o de hoxe, sen baixar» y «cada unidade di a unidade de antes e a seguinte»)
- [x] La UX sigue duolingo-clone adaptada, no copiada (Frank, 28/10: «es un ejemplo que te he dado no que lo hagas a rajatabla»): en Hoy, los días como nodos; en el camino, la franja de cada tema con su unidad de las 48 y las lecciones en zigzag · evidencia: test/features/leccions/leccions_test.dart («o camiño dos 10 temas, coa lección de agora»)
- [x] Visto en la app de escritorio por Na casa → Hoy, 4-5 años, en gl y es · evidencia: docs/capturas/escritorio/hoxe-casa-4-5-gl.png y hoxe-casa-4-5-es.png
- [ ] Todo mergeado en main con CI en verde · evidencia:

## O-20261028-7 · Opción A: cinco edades completas, sin repetir ni rellenar
Estado: abierta
> Ejecuta la opción A, Mergea y push al main de lo que hay ahora, pero prohibido engañarme, todas las edades deben estar completas, no intentes engañarme haciendo solo la primera parte porque ya lo has hecho antes solo haces lo primero y no conecta con nada

La opción A, tal como se le propuso: diez temas propios para 2-3 años, palabras nuevas para las semanas que no traían ninguna y ninguna palabra repetida entre cursos.

- [ ] Lo que había, mergeado en main con CI en verde · evidencia:
- [x] Los 50 temas (10 por edad) tienen título distinto: ninguno se repite entre edades · evidencia: test/features/leccions/leccions_test.dart («entre idades, ningún tema, palabra nova nin conto repetido»)
- [x] Las 200 semanas traen al menos tres palabras nuevas: ninguna semana de «repaso» por falta de contenido · evidencia: tools/gen_leccions.py (revisar: falla si una semana trae menos de 3)
- [x] Ninguna palabra nueva se enseña en dos edades: cada una, en una sola · evidencia: tools/gen_leccions.py (revisar: falla si una palabra es nueva en dos edades)
- [x] Cada palabra nueva lleva su significado en gl y es y su voz en, gl y es · evidencia: test/features/leccions/leccions_test.dart («todo o inglés das leccións leva o seu significado») y tools/check_voice_coverage.py
- [x] Todo conecta, en las cinco edades: el STEAM del mes es el eje (se ve en Hoy); el lunes, las palabras nuevas; el martes, el reto con una de ellas; el miércoles, la frase de la unidad de las 48 dicha dentro del STEAM; el jueves, un paso del STEAM; el viernes, el cuento de esa semana con las palabras que salen en él. Ningún día se repite en el curso · evidencia: test/features/leccions/leccions_test.dart («cada mes co seu STEAM e ningún día repetido no curso»)
- [x] Un gate tumba CI si vuelve a repetirse un tema o una palabra entre edades, o si una semana no trae nada nuevo · evidencia: tools/gen_leccions.py (--check, en tools/gates.sh)
- [ ] Visto en la app de escritorio por Na casa → Hoy en las cinco edades, en gl y es · evidencia:
- [x] Mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #39, run 40778207068 en verde, merge 0c7f550f)
- [x] Cada palabra nueva sale en una actividad de su semana (el lunes, todas; el viernes, las que trae el cuento) · evidencia: tools/gen_leccions.py (revisar: falla si una palabra nueva no sale en ningún día)
- [x] La unidad de gramática manda en las palabras: en las 128 semanas cuya unidad trabaja una clase de palabra (nombres, verbos, adjetivos), al menos una palabra nueva es de esa clase · evidencia: tools/gen_leccions.py (revisar: falla si una semana no la trae)
- [x] Cada semana dice cómo hablar: parentese, habla paralela, espera, expansión o recast, una técnica por fase · evidencia: test/features/leccions/leccions_test.dart («cada semana di como falar, catro técnicas distintas no mes»)
- [ ] Las unidades 21-48 (B1-C1) tienen su contenido semanal para la persona adulta · evidencia:

## O-20261028-8 · Informe y PDF de todo el material por edad
Estado: abierta
> entregar un informe de todo el material que hayas generado para ocupar cada uno de los rangos de edades, quiero todo el material [...] genera al finalizar un documento normalizado en PDF con cada una de las unidades y material cuentos y el Stem ya completo

- [x] Un PDF normalizado con cada edad, sus 10 temas, la unidad de las 48, el STEAM, el cuento de cada semana, las palabras y los cinco días · evidencia: docs/Descubre-con-Lua-Material-por-edades.pdf (de tools/gen_catalogo.py)
- [x] Un inventario con números por edad · evidencia: docs/catalogo-por-idades.html (tabla «Inventario»)
- [ ] Las unidades 21-48 con su material completo, no solo descripción y ejemplo · evidencia:

## O-20261028-9 · Las 48 unidades, para las criaturas, con el STEAM como eje
Estado: abierta
> las 48 unidades son para los niños. Si hay que adaptarlas no para el adulto, esto está mal, y se adaptan sí o sí
> Steam es el eje vertebrador [...] hay 48 unidades que hay que cumplir sí o sí y debe dejarse claro cómo se avanza entre uno y la otra

- [x] Las 48 unidades van en la ruta de las criaturas, una por mes de los 50 meses, sin volver atrás (la 1 y la 25 duran dos meses) · evidencia: tools/gen_gramatica.py (revisar: falla si falta una de las 48 o la columna baja)
- [x] Cada semana, su frase de la unidad, con significado en gl y es · evidencia: test/features/leccions/leccions_test.dart («cada unidade leva o seu punto de gramática e cada semana a súa frase»)
- [x] Las cuatro frases de cada mes cuentan el STEAM de ese mes con la estructura de su unidad · evidencia: tools/ruta_48.py (escritas a mano a partir de cada STEAM; sin comprobación automática del sentido)
- [x] La clase de palabra de la unidad entra en cada semana que la pide · evidencia: tools/gen_leccions.py (revisar: falla si una semana no la trae)
- [x] Se ve cómo se avanza: antes, ahora y después en Hoy, y la unidad de cada tema en el camino · evidencia: test/features/leccions/leccions_test.dart («dónde estamos e o de hoxe, sen baixar» y «o camiño dos 10 temas, coa lección de agora»)
- [x] Las frases nuevas tienen su voz · evidencia: tools/check_voice_coverage.py (run 107 de Generate Voice Assets en verde)
- [x] Mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #39, run 40778207068 en verde, merge 0c7f550f)

## O-20261101-1 · Terminar lo pendiente y rehacer la UX de casa y del aula
Estado: abierta
> Termina todo el trabajo pendiente además queda pendiente completar las mayorías ux UI de casa y también reformar y mejorar la del aula porque también es horrible

- [ ] 0-2 años: los 10 temas con su contraste de sonido (par del banco y nota en gl y es). Pendiente de Frank: el documento de currículo empieza a los 18 meses y el gate deja 0-2 sin contraste a propósito · evidencia:
- [x] Cada frase de la unidad comparte al menos una palabra con su STEAM, en las 200 semanas · evidencia: tools/gen_gramatica.py (revisar: falla si una frase no nombra nada de su STEAM; 21 frases reescritas)
- [x] Cada palabra nueva sale en el cuento de su semana, en las 200 semanas · evidencia: tools/gen_leccions.py (revisar con CONTO_COMPLETO en las cinco edades)
- [x] Hoy (casa y aula): franja con antes · AHORA · después, tema y STEAM; tarjeta de hoy con el día, qué hacer, la frase con voz y las palabras nuevas; todo eso sin bajar a 412×915 en gl y es; «Ya debería saber», «Cómo hablar» y «Guía» como tres botones que abren una hoja (aprobado por Frank, 1/11) · evidencia: test/features/ux_l3_test.dart («Learn de Duolingo, sen baixar, a 412×915»; desde O-20261109-5, la primera pantalla es la «Learn» de Duolingo y la lección queda justo debajo) y docs/capturas/escritorio/ux-casa-gl.png, ux-casa-es.png, ux-aula-es.png
- [x] Aula → Hoy: debajo de la lección, solo «Sesión de 45 min» y «Asamblea del día»; el resto del material, plegado al final en «Más material del día» (no en Recursos: así no se pierde nada de lo que había) · evidencia: test/features/tpr_pantallas_test.dart y docs/capturas/escritorio/ux-aula-es.png
- [x] Calendario (casa y aula): un solo selector de edad, los 10 meses en una fila y las 4 semanas de cada mes como tarjetas con su unidad, su STEAM y sus palabras; tocar una semana abre esa lección, la misma que Hoy · evidencia: test/features/leccions/leccions_test.dart («o calendario abre a mesma lección que Hoxe») y docs/capturas/escritorio/ux-cal-casa-gl.png, ux-cal-casa-es.png, ux-cal-aula-es.png, ux-leccion-cal-gl.png
- [x] Capturas en escritorio de casa y aula, en gl y es, por Inicio → Na casa / Na escola · evidencia: docs/capturas/escritorio/ux-casa-gl.png, ux-casa-es.png, ux-aula-es.png, ux-cal-casa-gl.png, ux-cal-aula-es.png
- [x] Mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #40, run 41344504153 en verde, merge bdff495d)

## O-20261101-2 · Las otras cuatro edades, completas
Estado: cumplida
> la evaluación de 4-5 años ya se hizo joder y te dije que la di por buena [...] yo te orden hacer el trabajo completo, cuando termines Mergea y push

- [x] 0-2, 2-3, 3-4 y 5-6 años: cada palabra nueva sale en el cuento de su semana, en las 160 semanas (129/129, 120/120, 132/132, 140/140; con 4-5, 663/663) · evidencia: tools/gen_leccions.py (revisar con CONTO_COMPLETO en las cinco edades) y tools/check_contos_palabras.py
- [x] Mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #41, run 41357557391 en verde, merge 0c5bf406)

## O-20261101-3 · Contraste de sonido en 0-2 años
Estado: cumplida
> Queda una decisión tuya: el contraste de sonido en 0-2 años. [...] ¿Lo añado? Ok

- [x] Los 10 meses de 0-2 años tienen su contraste de sonido: dos palabras del banco de 0-2 que solo cambian en un sonido, con su nota en gl y es para que la persona adulta las diga en parentese · evidencia: tools/check_unidades.py (--estricto: falla si un mes de cualquier edad no trae contraste)

## O-20261104-1 · Página de Términos del Servicio para Google Play Console
Estado: cumplida
> Necesito crear la pagina para el playstore de google, me piden :Términos del Servicio. Si está disponible, proporciona una URL de los Términos del Servicio. Este enlace se mostrará a los usuarios de Google Play de todo el mundo. Asegúrate de que la URL de tus Términos del Servicio: Se aloja en una URL activa y de acceso público (que empieza por http:// o https://) con un certificado SSL válido; Es accesible en todo el mundo sin restricciones geográficas, geoperimetraje ni requisitos de inicio de sesión; Se muestra en una página web estándar no editable (no en un PDF ni en un archivo descargable); Se aplica específicamente a tu aplicación

- [x] Página web estándar HTML no editable en docs/terms.html específica para Descubre con Lúa (com.earlify.descubreconlua), en castellano, galego e inglés, con correo oficial frank.alberto.betances.reinoso@gmail.com · evidencia: docs/terms.html («Términos del Servicio» y «com.earlify.descubreconlua»)
- [x] Enlazada desde docs/index.html y docs/privacy.html · evidencia: docs/index.html («terms.html») y docs/privacy.html
- [x] Vigilada por el gate tools/check_legal_urls.py (offline en gates.sh y online por red contra https://frankbetances.github.io/Descubre-con-lua/terms.html) · evidencia: tools/check_legal_urls.py («terms.html»)


## O-20261109-1 · Registro de cada niño, Lúa y premios, y pantalla de resultados (casa)
Estado: cumplida
> Necesito agregar una pequeña pantalla de registro donde se coloque el nombre del niño, edad y curso en que está para no repetir lo mismo cada vez que se abre la app, además incorporar la mascota lua y el diseño de premios, y una pantalla de resultados para ver evolución y animar a los padres y profesores, cuando termines, actualiza el manual y luego Mergea y push al main
>
> Decisiones de Frank (9/11): «Poner nombre porque pueden ser varios niños en una misma casa, modifica la página legal además el dato no sale del móvil»; resultados: «lo que hizo el adulto + observación del adulto»; registro: «Solo en casa».

- [x] Inicio → Na casa, la primera vez: pantalla de registro con Lúa, nombre, edad (0 a 6 años) y curso (las cinco edades de la app); al guardar se entra en Hoy con ese curso · evidencia: test/features/criancas_test.dart («a primeira vez pide nome, idade e curso con Lúa; a segunda xa non») y docs/capturas/rexistro-crianza-gl.png, rexistro-crianza-es.png
- [x] Al volver a abrir la app no se pregunta nada: Hoy abre con el último niño y su curso, y el chip de arriba dice «Nombre · curso» · evidencia: test/features/criancas_test.dart (misma prueba: segunda apertura sobre el mismo fichero) y docs/capturas/hoxe-familias-gl.png, hoxe-familias-es.png
- [x] Varios niños en una casa: desde el chip se cambia de niño, se añade otro, se cambia su curso y se borra uno · evidencia: test/features/criancas_test.dart («varios nenos: cambiar de neno, de curso e borrar»)
- [x] Pantalla de resultados del niño (chip → Ver resultados, y Guías → Resultados): Lúa con un mensaje de ánimo hecho con números reales, lo que hizo la persona adulta (días de juego en casa, racha) con las medallas del diseño de premios, la observación de la semana (cada palabra nueva: «aún no» / «la entiende» / «la dice») y la evolución semana a semana de esas observaciones · evidencia: test/features/criancas_test.dart («resultados: Lúa, sen evolución inventada, e a observación da semana conta» y «Guías leva aos resultados») y docs/capturas/resultados-crianza-gl.png, resultados-crianza-es.png
- [x] Nada inventado: si no hay observaciones, la pantalla lo dice y no pinta evolución · evidencia: test/features/criancas_test.dart (cifras a 0 y «Todavía no has marcado ninguna palabra» antes de marcar)
- [x] El aula no cambia (sin registro de niños) · evidencia: lib/features/familias/widgets/selector_idade.dart (con paraAula, ni nombre ni hoja del niño; CrianzaDaCasa solo existe en el Portal Familias) y la suite de aula en verde (test/features/tpr_pantallas_test.dart, test/features/ux_l8_test.dart)
- [x] Privacidad: el nombre, la edad, el curso y las observaciones se guardan solo en el móvil (`criancas.json`), sin hora; un gate falla si aparece una clave nueva o una hora; la política de privacidad (gl y es) y CLAUDE.md lo dicen · evidencia: test/core/criancas_privacidad_test.dart, docs/privacy.html (apartados 2, 4, 5 y 6; gl 2, 4 y 4 bis; en 2), docs/terms.html y CLAUDE.md (apartado de privacidad declarada)
- [x] Manual actualizado (PDF y Word regenerados) · evidencia: docs/manual-casos-de-uso.html (6 · «Quién aprende» y «Resultados»; 10) y tools/check_manual_build.py
- [x] Todas las capturas del manual son de la app actual (corrección del 9/11: 16 estaban viejas y el calendario de lecciones no salía): regeneradas las 34 pantallas en gl y es, y añadidas el calendario de lecciones (casa y aula) y la hoja del chip · evidencia: test/capturas_test.dart («calendario de leccions» y «folla do neno») y docs/Descubre-con-Lua-Manual-Casos-de-Uso.pdf (42 páginas, miradas en hoja de contactos)
- [x] Mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #43, run 42630292325 en verde, merge 29362552)

## O-20261109-2 · Automejora: que no vuelva a pasar
Estado: abierta
> Lo que yo no veo, fue lo que te ordené, y fui bastante claro porque te dije que lo copiaras de Valeria, me has traicionado, analiza de nuevo por qué ha fallado y pon un Hook o lo que sea a mí eso no me importa, pero esto no puede pasar nunca más ya estoy cansado de que no hagas lo que te pido, tienes que cumplir las reglas, sí o sí, pon un Hook para hacerlo
>
> La orden suprema, que es cumplir con mis órdenes, no lo haces. Yo necesito que sea recursivo y que mejores automáticamente, ejecuta mi orden de automejora. Ejecuta y Mergea ahora la orden de auto mejora ya
Fuente: ninguna: contenido nuevo (las reglas R∞ y R1 de CLAUDE.md)

- [x] En cada mensaje de Frank, un hook recuerda R∞; si pide copiar, traer o imitar algo (o nombra Valeria, la mascota, los premios u otro producto), obliga a abrir la fuente y escribir «Fuente:» antes de programar · evidencia: .claude/hooks/orden_fuente.py y .claude/settings.json (UserPromptSubmit)
- [x] Cuando Frank señala un fallo, el hook inyecta el protocolo de automejora: comprobar, registrar la causa raíz, crear la guarda, corregir y mergear · evidencia: .claude/hooks/orden_fuente.py
- [x] Cada fallo queda en docs/FALLOS.md con su causa raíz y su guarda; CI cae si una entrada no tiene guarda que exista · evidencia: tools/check_fallos.py (en tools/gates.sh) y docs/FALLOS.md
- [x] Ninguna orden nueva sin «Fuente:»; CI cae si falta · evidencia: tools/check_ordenes.py
- [ ] Mergeado en main con CI en verde · evidencia:

## O-20261109-3 · Lúa y el sistema de premios de Valeria, en casa
Estado: abierta
> te dije que lo copiaras de Valeria
>
> Decisión de Frank (9/11): «evidentemente lo gana el maldito niño joder el padre es un fucking avatar»: los premios los gana el niño; la persona adulta actúa en su nombre.
Fuente: FrankBetances/Valeria:src/components/lua/ValeriaCatInteractiveCard.tsx (y src/ValeriaPixelAwards.tsx, src/ValeriaAwardsSheet.tsx, src/valeriaGamification.ts, src/components/lua/luaPixelSegments.ts)

- [x] La tarjeta de Lúa de Valeria, portada: la gata de cuerpo entero que respira, mueve la cola, parpadea y reacciona al tocarla, con su nivel, su barra de progreso y la racha en la misma tarjeta, en Hoy de casa · evidencia: test/features/criancas_test.dart («Lúa de Valeria en Hoy: xogar dá XP e a primeira insignia, e a folla de premios a mostra»)
- [x] La colección de premios de Valeria (hoja de premios) abierta desde la tarjeta · evidencia: test/features/criancas_test.dart («Lúa de Valeria en Hoy: xogar dá XP e a primeira insignia, e a folla de premios a mostra»)
- [x] Los premios son del niño: XP, 12 niveles con nombre, racha y las 18 insignias de Valeria, por niño registrado; se ganan cuando la persona adulta marca en su nombre el juego del día y lo que entiende o dice · evidencia: test/features/criancas_test.dart («o xogo de Valeria: racha, insignias e obxectos»)
- [x] La tarjeta en Hoy de casa (debajo de la lección) y arriba en Resultados, en gl y es, con captura · evidencia: test/features/criancas_test.dart («Lúa de Valeria en Hoy: xogar dá XP e a primeira insignia, e a folla de premios a mostra») y docs/capturas/resultados-crianza-gl.png, resultados-crianza-es.png, premios-lua-gl.png, premios-lua-es.png
- [x] Privacidad: lo nuevo se guarda en criancas.json, sin hora; gate, política y CLAUDE.md al día · evidencia: test/core/criancas_privacidad_test.dart, docs/privacy.html y CLAUDE.md
- [ ] Mergeado en main con CI en verde · evidencia:

## O-20261109-4 · Las consideraciones de ACOPROS
Estado: abierta
> Completa la mascota y Además Además, las compañeras de Acopros han enviado un informe con todos los cambios necesarios: CONSIDERACIONES DESCUBRE CON LÚA […] (el informe entero, literal, en la fuente)
Fuente: referencias/acopros/consideraciones-2026-11-09.md

Primero una edad entera, 0-2 años (R∞.6.3), que es la que revisaron; las demás después de que Frank la dé por buena.

Decisiones de Frank (9/11), a tres preguntas de Claude Code: 0-2 con unas 20 palabras por tema (el gate de las 4.000 deja de contar 0-2; las demás edades, después); sin gramática en 0-2: las 48 unidades empiezan en 2-3 y se reparten en sus 40 meses; el cuento de 0-2, rimas y canciones inglesas tradicionales de dominio público, una por tema, con voz más lenta.

- [x] 0-2: cada unidad (proyecto del mes) empieza por su vocabulario base y su canción; ninguna frase usa una palabra que no se haya presentado antes (no «leaves are falling» sin «tree», «leaf», «brown») · evidencia: test/features/acopros_0_2_test.dart («os 10 proxectos: unhas 20 palabras, dous elementos como moito, sen to be») y tools/gen_acopros_0_2.py (--check en gates.sh: semana 1 = vocabulario y canción; cómo hablar solo con palabras del proyecto)
- [x] 0-2: «Ya debería saber» sin verbo to be ni frases: palabras sueltas (holofrase) · evidencia: test/features/acopros_0_2_test.dart («os 10 proxectos: unhas 20 palabras, dous elementos como moito, sen to be») y tools/gen_acopros_0_2.py
- [x] 0-2: «Cómo hablar» con frases de 2 elementos como mucho y su gesto («wash hands») · evidencia: test/features/acopros_0_2_test.dart («os 10 proxectos: unhas 20 palabras, dous elementos como moito, sen to be») y docs/capturas/proxecto-0-2-gl.png, proxecto-0-2-es.png
- [x] 0-2: la guía, sencilla: canta la canción del tema, repasa su vocabulario · evidencia: test/features/acopros_0_2_test.dart («Hoxe 0-2») y tools/gen_acopros_0_2.py
- [x] 0-2: unas 20 palabras bien escogidas por tema, en vez del vocabulario núcleo de miles · evidencia: test/features/acopros_0_2_test.dart («Máis material do día en 0-2: as palabras do proxecto, non o banco») y tools/gen_acopros_0_2.py (18-22 por proyecto, de la lección y el banco TPR del mes)
- [x] El plan curricular, por proyectos, como trabajan las escuelas infantiles (0-2, primera edad entera según R∞.6.3; las demás, cuando Frank la dé por buena) · evidencia: test/features/acopros_0_2_test.dart («Hoxe 0-2») y tools/gen_acopros_0_2.py (10 proyectos de 4 semanas)
- [x] 0-2: el cuento de la semana con vocabulario de la edad y audio más lento: una rima tradicional de dominio público por proyecto, grabada (en, gl, es) y con la voz a 0,8 en 0-2 · evidencia: test/features/acopros_0_2_test.dart («Hoxe 0-2»), test/core/velocidade_voz_test.dart y tools/gen_acopros_0_2.py
- [x] Gates que lo midan: frases de 0-2 de 2 elementos como mucho, palabra nueva solo tras presentarla, 20 por tema · evidencia: tools/gen_acopros_0_2.py (en tools/gates.sh) y test/features/acopros_0_2_test.dart; tools/check_ordenes.py exige ese gate o test en cada criterio marcado
- [ ] Mergeado en main con CI en verde · evidencia:

Pendiente de decidir (Frank, 10/11/2026: «este trabajo se decidirá en una siguiente iteración»): si repartir las 48 unidades en los 40 meses de 2-3 a 5-6. En 0-2 ya no se enseña gramática, pero las unidades 1 a 9 siguen asignadas a esos meses (tools/ruta_48.py). Moverlas obliga a reescribir las frases de cada mes y su voz. No es criterio de esta orden.

## O-20261109-5 · La UX de familia, copiando el sistema de Duolingo
Estado: abierta
> Por cierto la ux UI de familia es cuestionable te ordené copiar el sistema de duolingo te di el repositorio y te di varios más y lo de hoy es horrible
Fuente: docs/capturas/fuente-duolingo-learn.png (sanidhyy/duolingo-clone, MIT: app/(main)/learn/*.tsx, app/lesson/header.tsx, footer.tsx, quiz.tsx, result-card.tsx)

Antes (28/10) Frank dijo «es un ejemplo, no a rajatabla» y se adaptó; el 9/11 dice que el resultado es horrible y pide copiar el sistema. Se copia la UX visible de Duolingo (duolingo-clone, MIT): el camino de lecciones en nodos, la lección a pantalla completa con su barra de progreso y botón «Comprobar/Continuar», la pantalla de fin con XP, la racha y la tienda/premios, adaptado a que la usa la persona adulta en nombre del niño.

- [x] Hoy de casa como la pantalla «Learn» de duolingo-clone: cabecera con racha y XP del niño, el camino de la unidad en nodos con la lección actual resaltada y un botón grande para empezar · evidencia: test/features/ux_l3_test.dart («Learn de Duolingo, sen baixar, a 412×915») y docs/capturas/hoxe-familias-gl.png, hoxe-familias-es.png
- [x] Al tocar la lección, pantalla completa paso a paso como un ejercicio de Duolingo (barra de progreso arriba, un paso por pantalla, botón Continuar), con la voz de cada palabra · evidencia: test/features/criancas_test.dart («Learn de Duolingo: o nodo de hoxe abre a lección paso a paso e o fin dá XP») y docs/capturas/leccion-duolingo-paso-gl.png, leccion-duolingo-paso-es.png
- [x] Al acabar, la pantalla de fin de Duolingo: XP ganado, racha y premio de Lúa · evidencia: test/features/criancas_test.dart («Learn de Duolingo: o nodo de hoxe abre a lección paso a paso e o fin dá XP») y docs/capturas/leccion-duolingo-fin-gl.png, leccion-duolingo-fin-es.png
- [x] Capturas en gl y es comparadas lado a lado con las de duolingo-clone · evidencia: docs/comparativa-duolingo.html y docs/capturas/fuente-duolingo-learn.png
- [ ] Mergeado en main con CI en verde · evidencia:

## O-20261110-1 · Terminar O-3, O-5 y O-4 y mergear con CI en verde
Estado: abierta
> Autorización de Frank (10 nov 2026): termina todo completo y, cuando el CI esté en verde, haz merge a `main` y push. Sin preguntarme nada más. [...] 1. O-20261109-5 (UX Duolingo): la pantalla de fin de lección debe mostrar XP ganado, racha y premio de Lúa; hoy falta la racha. Añádela con test. Comprueba que el camino en nodos de Hoy cabe entero (nodo del viernes y «Empezar»). [...] 2. O-20261109-4 (ACOPROS 0-2): cumple los 9 criterios que siguen en `[ ]` [...] No inventes contenido pedagógico sin base en la fuente. [...] 4. Cuando los gates del PR estén en verde y no queden criterios abiertos de O-3, O-5 y O-4, haz merge del PR #47 a `main` y push. Si queda algún criterio abierto o un gate en rojo, NO hagas merge: dime cuál y por qué, y para.
Fuente: docs/ORDENES.md (criterios abiertos de O-20261109-3, O-20261109-4 y O-20261109-5) y referencias/acopros/consideraciones-2026-11-09.md

- [x] La pantalla de fin de la lección enseña el XP ganado, la racha y el premio de Lúa · evidencia: test/features/criancas_test.dart («Learn de Duolingo: o nodo de hoxe abre a lección paso a paso e o fin dá XP») y docs/capturas/leccion-duolingo-fin-gl.png, leccion-duolingo-fin-es.png
- [x] En Hoy a 412×915, el camino entero cabe sin bajar: los cinco nodos y «Empezar» del día · evidencia: test/features/ux_l3_test.dart («Learn de Duolingo, sen baixar, a 412×915») y docs/capturas/hoxe-familias-gl.png, hoxe-familias-es.png
- [ ] Los criterios abiertos de O-20261109-4 cumplidos con su gate · evidencia:
- [ ] Cuerpo del PR #47 al día y merge en main con CI en verde · evidencia:
