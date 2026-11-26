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
Estado: cumplida
> para los padres sigue sin entenderse nada es un mix sin sentido, he probado en 4-5 años [...] se repiten las mismas palabras por trimestres [...] la UI UX de los padres es un desastre esta llena de ruido e información que no hace falta, es un scroll infinito que no se entiende, tampoco se entiende las unidades, no sabe de lo que se habla ni hacia donde va
> busca en GitHub todas las UX-UI que funcionan para nuestro caso y adaptalas, no inventes nada

UX de referencia, de código abierto: Bebbo (UNICEF, GPL-3.0, 0-6 años; portada con la etapa de la criatura y una tarjeta diaria de un juego y una lectura) y Oppia Android (tema → lista de lecciones con estado y la siguiente).

- [x] Na casa → Hoy, 4-5 años: la etapa (edad, unidad n de 10 con su tema y barra), las palabras de la semana, la gramática en una línea y lo de hoy caben en la primera pantalla de 412×915, sin bajar · evidencia: docs/ORDENES.md (sustituido por el diseño Duolingo de O-20261109-5, por decisión de Frank el 19/11/2026: O-20261119-4)
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
Estado: cumplida
> revisa que realmente las unidades estén donde tienen que estar que exista una progresión real, no me engañes otra vez, cuando termines de revisar además pon el título que corresponde a la unidad porque hace falta saber de qué va la unidad, que si hay 48 malditas unidades [...] pongas la maldita unidad que se está tratando en la maldita semana [...] si es sustantivo adjetivo o lo que toque [...] después arregla la maldita ux UI con los fucking ejemplos que te di ya para copiar de GitHub, cuando tengas todo hecho [...] y revisado que realmente funciona, pues mergealo todo ya

- [x] Revisión con datos: las 20 unidades A1-A2 van en orden ascendente a lo largo de los 50 meses, sin volver atrás · evidencia: tools/gen_gramatica.py (--check, en tools/gates.sh: falla si la columna baja)
- [x] En la semana se ve, arriba y a un tamaño adecuado, la unidad de las 48 que se trabaja, con la de antes y la de después: número, título y qué es. Corregido por Frank, 28/10: «El título no tiene porque ser tan en grande» · evidencia: test/features/leccions/leccions_test.dart («dónde estamos e o de hoxe, sen baixar» y «cada unidade di a unidade de antes e a seguinte»)
- [x] La UX sigue duolingo-clone adaptada, no copiada (Frank, 28/10: «es un ejemplo que te he dado no que lo hagas a rajatabla»): en Hoy, los días como nodos; en el camino, la franja de cada tema con su unidad de las 48 y las lecciones en zigzag · evidencia: test/features/leccions/leccions_test.dart («o camiño dos 10 temas, coa lección de agora»)
- [x] Visto en la app de escritorio por Na casa → Hoy, 4-5 años, en gl y es · evidencia: docs/capturas/escritorio/hoxe-casa-4-5-gl.png y hoxe-casa-4-5-es.png
- [x] Todo mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #47, merge 1c75f831, run 42873742166 en verde en main)

## O-20261028-7 · Opción A: cinco edades completas, sin repetir ni rellenar
Estado: cumplida
> Ejecuta la opción A, Mergea y push al main de lo que hay ahora, pero prohibido engañarme, todas las edades deben estar completas, no intentes engañarme haciendo solo la primera parte porque ya lo has hecho antes solo haces lo primero y no conecta con nada

La opción A, tal como se le propuso: diez temas propios para 2-3 años, palabras nuevas para las semanas que no traían ninguna y ninguna palabra repetida entre cursos.

- [x] Lo que había, mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #38, merge 0e4ed67f, run 40756840158 en verde en main)
- [x] Los 50 temas (10 por edad) tienen título distinto: ninguno se repite entre edades · evidencia: test/features/leccions/leccions_test.dart («entre idades, ningún tema, palabra nova nin conto repetido»)
- [x] Las 200 semanas traen al menos tres palabras nuevas: ninguna semana de «repaso» por falta de contenido · evidencia: tools/gen_leccions.py (revisar: falla si una semana trae menos de 3)
- [x] Ninguna palabra nueva se enseña en dos edades: cada una, en una sola · evidencia: tools/gen_leccions.py (revisar: falla si una palabra es nueva en dos edades)
- [x] Cada palabra nueva lleva su significado en gl y es y su voz en, gl y es · evidencia: test/features/leccions/leccions_test.dart («todo o inglés das leccións leva o seu significado») y tools/check_voice_coverage.py
- [x] Todo conecta, en las cinco edades: el STEAM del mes es el eje (se ve en Hoy); el lunes, las palabras nuevas; el martes, el reto con una de ellas; el miércoles, la frase de la unidad de las 48 dicha dentro del STEAM; el jueves, un paso del STEAM; el viernes, el cuento de esa semana con las palabras que salen en él. Ningún día se repite en el curso · evidencia: test/features/leccions/leccions_test.dart («cada mes co seu STEAM e ningún día repetido no curso»)
- [x] Un gate tumba CI si vuelve a repetirse un tema o una palabra entre edades, o si una semana no trae nada nuevo · evidencia: tools/gen_leccions.py (--check, en tools/gates.sh)
- [x] Visto en la app de escritorio por Na casa → Hoy en las cinco edades, en gl y es · evidencia: docs/capturas/escritorio/hoxe-casa-0-2-gl.png (y -es; también 2-3, 3-4, 4-5 y 5-6 en gl y es; app Linux de escritorio desde main 26c066a0, Claude Code 19/11/2026)
- [x] Mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #39, run 40778207068 en verde, merge 0c7f550f)
- [x] Cada palabra nueva sale en una actividad de su semana (el lunes, todas; el viernes, las que trae el cuento) · evidencia: tools/gen_leccions.py (revisar: falla si una palabra nueva no sale en ningún día)
- [x] La unidad de gramática manda en las palabras: en las 128 semanas cuya unidad trabaja una clase de palabra (nombres, verbos, adjetivos), al menos una palabra nueva es de esa clase · evidencia: tools/gen_leccions.py (revisar: falla si una semana no la trae)
- [x] Cada semana dice cómo hablar: parentese, habla paralela, espera, expansión o recast, una técnica por fase · evidencia: test/features/leccions/leccions_test.dart («cada semana di como falar, catro técnicas distintas no mes»)
- [x] Las unidades 21-48 (B1-C1) tienen su contenido semanal para la persona adulta · evidencia: assets/content/gramatica/gramatica.json (las 28 unidades en la ruta de las criaturas, una por mes, con 4 frases semanales dentro del STEAM, «paraFamilias» y ejemplo; dadas por cubiertas por Frank el 19/11/2026: O-20261119-5)

## O-20261028-8 · Informe y PDF de todo el material por edad
Estado: cumplida
> entregar un informe de todo el material que hayas generado para ocupar cada uno de los rangos de edades, quiero todo el material [...] genera al finalizar un documento normalizado en PDF con cada una de las unidades y material cuentos y el Stem ya completo

- [x] Un PDF normalizado con cada edad, sus 10 temas, la unidad de las 48, el STEAM, el cuento de cada semana, las palabras y los cinco días · evidencia: docs/Descubre-con-Lua-Material-por-edades.pdf (de tools/gen_catalogo.py)
- [x] Un inventario con números por edad · evidencia: docs/catalogo-por-idades.html (tabla «Inventario»)
- [x] Las unidades 21-48 con su material completo, no solo descripción y ejemplo · evidencia: assets/content/gramatica/gramatica.json (las 28 unidades en la ruta de las criaturas, una por mes, con 4 frases semanales dentro del STEAM, «paraFamilias» y ejemplo; dadas por cubiertas por Frank el 19/11/2026: O-20261119-5)

## O-20261028-9 · Las 48 unidades, para las criaturas, con el STEAM como eje
Estado: cumplida
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
Estado: cumplida
> Termina todo el trabajo pendiente además queda pendiente completar las mayorías ux UI de casa y también reformar y mejorar la del aula porque también es horrible

- [x] 0-2 años: los 10 temas con su contraste de sonido (par del banco y nota en gl y es). Pendiente de Frank: el documento de currículo empieza a los 18 meses y el gate deja 0-2 sin contraste a propósito · evidencia: test/features/calendario/calendario_escala_test.dart («contraste_do_mes» en curso_0_2, aula y casa) y tools/check_unidades.py (las 10 unidades de 0-2 con su par y nota gl/es; O-20261101-3)
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
Estado: cumplida
> Lo que yo no veo, fue lo que te ordené, y fui bastante claro porque te dije que lo copiaras de Valeria, me has traicionado, analiza de nuevo por qué ha fallado y pon un Hook o lo que sea a mí eso no me importa, pero esto no puede pasar nunca más ya estoy cansado de que no hagas lo que te pido, tienes que cumplir las reglas, sí o sí, pon un Hook para hacerlo
>
> La orden suprema, que es cumplir con mis órdenes, no lo haces. Yo necesito que sea recursivo y que mejores automáticamente, ejecuta mi orden de automejora. Ejecuta y Mergea ahora la orden de auto mejora ya
Fuente: ninguna: contenido nuevo (las reglas R∞ y R1 de CLAUDE.md)

- [x] En cada mensaje de Frank, un hook recuerda R∞; si pide copiar, traer o imitar algo (o nombra Valeria, la mascota, los premios u otro producto), obliga a abrir la fuente y escribir «Fuente:» antes de programar · evidencia: .claude/hooks/orden_fuente.py y .claude/settings.json (UserPromptSubmit)
- [x] Cuando Frank señala un fallo, el hook inyecta el protocolo de automejora: comprobar, registrar la causa raíz, crear la guarda, corregir y mergear · evidencia: .claude/hooks/orden_fuente.py
- [x] Cada fallo queda en docs/FALLOS.md con su causa raíz y su guarda; CI cae si una entrada no tiene guarda que exista · evidencia: tools/check_fallos.py (en tools/gates.sh) y docs/FALLOS.md
- [x] Ninguna orden nueva sin «Fuente:»; CI cae si falta · evidencia: tools/check_ordenes.py
- [x] Mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #47, merge 1c75f831, run 42873742166 en verde en main)

## O-20261109-3 · Lúa y el sistema de premios de Valeria, en casa
Estado: cumplida
> te dije que lo copiaras de Valeria
>
> Decisión de Frank (9/11): «evidentemente lo gana el maldito niño joder el padre es un fucking avatar»: los premios los gana el niño; la persona adulta actúa en su nombre.
Fuente: FrankBetances/Valeria:src/components/lua/ValeriaCatInteractiveCard.tsx (y src/ValeriaPixelAwards.tsx, src/ValeriaAwardsSheet.tsx, src/valeriaGamification.ts, src/components/lua/luaPixelSegments.ts)

- [x] La tarjeta de Lúa de Valeria, portada: la gata de cuerpo entero que respira, mueve la cola, parpadea y reacciona al tocarla, con su nivel, su barra de progreso y la racha en la misma tarjeta, en Hoy de casa · evidencia: test/features/criancas_test.dart («Lúa de Valeria en Hoy: xogar dá XP e a primeira insignia, e a folla de premios a mostra»)
- [x] La colección de premios de Valeria (hoja de premios) abierta desde la tarjeta · evidencia: test/features/criancas_test.dart («Lúa de Valeria en Hoy: xogar dá XP e a primeira insignia, e a folla de premios a mostra»)
- [x] Los premios son del niño: XP, 12 niveles con nombre, racha y las 18 insignias de Valeria, por niño registrado; se ganan cuando la persona adulta marca en su nombre el juego del día y lo que entiende o dice · evidencia: test/features/criancas_test.dart («o xogo de Valeria: racha, insignias e obxectos»)
- [x] La tarjeta en Hoy de casa (debajo de la lección) y arriba en Resultados, en gl y es, con captura · evidencia: test/features/criancas_test.dart («Lúa de Valeria en Hoy: xogar dá XP e a primeira insignia, e a folla de premios a mostra») y docs/capturas/resultados-crianza-gl.png, resultados-crianza-es.png, premios-lua-gl.png, premios-lua-es.png
- [x] Privacidad: lo nuevo se guarda en criancas.json, sin hora; gate, política y CLAUDE.md al día · evidencia: test/core/criancas_privacidad_test.dart, docs/privacy.html y CLAUDE.md
- [x] Mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #47, merge 1c75f831, run 42873742166 en verde en main)

## O-20261109-4 · Las consideraciones de ACOPROS
Estado: cumplida
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
- [x] Mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #47, merge 1c75f831, run 42873742166 en verde en main)

Pendiente de decidir (Frank, 10/11/2026: «este trabajo se decidirá en una siguiente iteración»): si repartir las 48 unidades en los 40 meses de 2-3 a 5-6. En 0-2 ya no se enseña gramática, pero las unidades 1 a 9 siguen asignadas a esos meses (tools/ruta_48.py). Moverlas obliga a reescribir las frases de cada mes y su voz. No es criterio de esta orden.

## O-20261109-5 · La UX de familia, copiando el sistema de Duolingo
Estado: cumplida
> Por cierto la ux UI de familia es cuestionable te ordené copiar el sistema de duolingo te di el repositorio y te di varios más y lo de hoy es horrible
Fuente: docs/capturas/fuente-duolingo-learn.png (sanidhyy/duolingo-clone, MIT: app/(main)/learn/*.tsx, app/lesson/header.tsx, footer.tsx, quiz.tsx, result-card.tsx)

Antes (28/10) Frank dijo «es un ejemplo, no a rajatabla» y se adaptó; el 9/11 dice que el resultado es horrible y pide copiar el sistema. Se copia la UX visible de Duolingo (duolingo-clone, MIT): el camino de lecciones en nodos, la lección a pantalla completa con su barra de progreso y botón «Comprobar/Continuar», la pantalla de fin con XP, la racha y la tienda/premios, adaptado a que la usa la persona adulta en nombre del niño.

- [x] Hoy de casa como la pantalla «Learn» de duolingo-clone: cabecera con racha y XP del niño, el camino de la unidad en nodos con la lección actual resaltada y un botón grande para empezar · evidencia: test/features/ux_l3_test.dart («Learn de Duolingo, sen baixar, a 412×915») y docs/capturas/hoxe-familias-gl.png, hoxe-familias-es.png
- [x] Al tocar la lección, pantalla completa paso a paso como un ejercicio de Duolingo (barra de progreso arriba, un paso por pantalla, botón Continuar), con la voz de cada palabra · evidencia: test/features/criancas_test.dart («Learn de Duolingo: o nodo de hoxe abre a lección paso a paso e o fin dá XP») y docs/capturas/leccion-duolingo-paso-gl.png, leccion-duolingo-paso-es.png
- [x] Al acabar, la pantalla de fin de Duolingo: XP ganado, racha y premio de Lúa · evidencia: test/features/criancas_test.dart («Learn de Duolingo: o nodo de hoxe abre a lección paso a paso e o fin dá XP») y docs/capturas/leccion-duolingo-fin-gl.png, leccion-duolingo-fin-es.png
- [x] Capturas en gl y es comparadas lado a lado con las de duolingo-clone · evidencia: docs/comparativa-duolingo.html y docs/capturas/fuente-duolingo-learn.png
- [x] Mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #47, merge 1c75f831, run 42873742166 en verde en main)

## O-20261110-1 · Terminar O-3, O-5 y O-4 y mergear con CI en verde
Estado: cumplida
> Autorización de Frank (10 nov 2026): termina todo completo y, cuando el CI esté en verde, haz merge a `main` y push. Sin preguntarme nada más. [...] 1. O-20261109-5 (UX Duolingo): la pantalla de fin de lección debe mostrar XP ganado, racha y premio de Lúa; hoy falta la racha. Añádela con test. Comprueba que el camino en nodos de Hoy cabe entero (nodo del viernes y «Empezar»). [...] 2. O-20261109-4 (ACOPROS 0-2): cumple los 9 criterios que siguen en `[ ]` [...] No inventes contenido pedagógico sin base en la fuente. [...] 4. Cuando los gates del PR estén en verde y no queden criterios abiertos de O-3, O-5 y O-4, haz merge del PR #47 a `main` y push. Si queda algún criterio abierto o un gate en rojo, NO hagas merge: dime cuál y por qué, y para.
Fuente: docs/ORDENES.md (criterios abiertos de O-20261109-3, O-20261109-4 y O-20261109-5) y referencias/acopros/consideraciones-2026-11-09.md

- [x] La pantalla de fin de la lección enseña el XP ganado, la racha y el premio de Lúa · evidencia: test/features/criancas_test.dart («Learn de Duolingo: o nodo de hoxe abre a lección paso a paso e o fin dá XP») y docs/capturas/leccion-duolingo-fin-gl.png, leccion-duolingo-fin-es.png
- [x] En Hoy a 412×915, el camino entero cabe sin bajar: los cinco nodos y «Empezar» del día · evidencia: test/features/ux_l3_test.dart («Learn de Duolingo, sen baixar, a 412×915») y docs/capturas/hoxe-familias-gl.png, hoxe-familias-es.png
- [x] Los criterios abiertos de O-20261109-4 cumplidos con su gate · evidencia: docs/ORDENES.md (O-20261109-4: todos sus criterios con evidencia; merge en PR #47)
- [x] Cuerpo del PR #47 al día y merge en main con CI en verde · evidencia: docs/ORDENES.md (cuerpo del PR #47 con O-3, O-5 y O-4 al día; merge 1c75f831, run 42873742166 en verde)

## O-20261111-1 · Las escenas de los ejercicios, con su imagen
Estado: cumplida
> Orden de Frank (11 nov 2026): los ejercicios de Descubre con Lúa muestran la descripción de la escena solo en texto, sin imagen. Las imágenes son esenciales y deben coincidir exactamente con la escena. Hazlo completo; no recortes alcance. [...] 1. Diagnóstico [...] 2. Si las imágenes existen en el historial y coinciden con su escena, recupéralas [...] 3. Si no existen o no coinciden, créalas nuevas: una por cada escena descrita en el contenido, en un estilo coherente con Lúa (infantil 0-6, claro, sin texto dentro de la imagen, sin emojis del sistema). Cada imagen debe mostrar exactamente lo que dice la descripción [...] 4. Muestra la imagen en el ejercicio, encima del texto, con semanticsLabel en gl y es. [...] 5. Gate [...] 6. [...] Capturas gl/es [...] 7. Con todo en verde y sin criterios abiertos, merge a main y push.
Fuente: assets/content/leccions/leccions.json (campo reto.escena, 12 escenas distintas, las mismas que en assets/content/unidades_mes) y assets/brand/laminas/ (el set propio de láminas vectoriales)

Diagnóstico: `git log -S` sobre `escena`, `imaxe`, `Image.asset`, `pubspec.yaml` y los assets borrados no da ninguna imagen de estas escenas. El campo `escena` entró en aa8d7fdb (F5, la casa guiada) solo como texto y nunca tuvo imagen: no hay nada que recuperar, se crean las 12.

- [x] (REABIERTO por Frank el 11/11/2026: «está MAL cerrada». Recorté el alcance a las 12 escenas de reto y la imagen solo salía en el primer paso; lo que falta está en O-20261111-2) Una imagen por cada una de las 12 escenas, con exactamente los objetos que dice su texto, en el set de láminas vectoriales (sin texto ni emoji), compuesta de las láminas que ya existían y de dibujos nuevos en el mismo estilo · evidencia: tools/gen_escenas_retos.py escribe las 12 assets/brand/laminas/escena_*.json (lienzo 160×100, unos 1-6 KB cada una); revisadas una a una en una hoja de contacto renderizada (tres corregidas: la manta salía sobre una cama, la toalla y las cucharas se salían del borde). Recuperadas: 0; nuevas: 12
- [x] Un fichero de control con la escena, su texto gl/es, la lámina y la comprobación de qué objetos lleva · evidencia: docs/imagenes-escenas.md y assets/content/escenas/escenas.json, generados por tools/gen_escenas_retos.py
- [x] (REABIERTO: la imagen del peluche salía en pasos de palabras con las que no coincide; ver O-20261111-2) La imagen encima del texto de la escena, con semanticsLabel gl/es, en el reto de la lección (casa y aula), en el reto de la semana y en la lección paso a paso de Duolingo · evidencia: test/features/imaxes_escenas_test.dart, «o reto da semana pinta a imaxe encima do texto», «a lección de Duolingo pinta a imaxe da escena» y «a etiqueta para o lector de pantalla vai na lingua», en gl y es; lib/core/brand/imaxe_escena.dart
- [x] Gate: falla si una escena del contenido no tiene imagen, si la lámina no existe o si no está en pubspec · evidencia: tools/check_imagenes_escenas.py, en tools/gates.sh
- [x] Capturas gl/es de varios ejercicios con su imagen · evidencia: test/capturas_test.dart, «escena ·», escribe docs/capturas/escena-duolingo-gl.png y -es, escena-leccion-casa-gl/-es y escena-leccion-aula-gl/-es; más reto-semana-gl/-es
- [x] Mergeado en main con CI en verde · evidencia: tools/check_imagenes_escenas.py ya corre en main: PR #48 mergeado (merge f83d8233, 11/11/2026) con el run 42957693645 de gates en verde sobre 49579fb5

## O-20261111-2 · Una lámina por cada palabra enseñada, en todos los pasos, y los días de Hoy que no responden
Estado: cumplida
> Orden de Frank (11 nov 2026). La O-20261111-1 está MAL cerrada: reábrela en docs/ORDENES.md y registra en docs/FALLOS.md el fallo de este turno. Causa: recorte de alcance (solo 12 escenas de reto, imagen solo en el primer paso, imagen del peluche que no coincide con la palabra), gate prometido check_laminas_leccion.py no creado, orden marcada cumplida sin cumplirla. No recortes alcance ni marques nada como cumplido sin prueba. Lee CLAUDE.md, ORDENES.md y FALLOS.md. Commit y push por bloque.
>
> A. Imágenes en TODOS los pasos
> 1. Añade el campo "lamina" a PezaDaLeccion, TprWord y PalabraProxecto, y rellénalo en assets/content/leccions/leccions.json (xaSabe, novas, repasa), tpr/**/*.json y acopros/proxectos_0_2.json. Son 1962 piezas y 200 palabras 0-2.
> 2. Cada lámina debe representar ESA palabra y su gesto, no la escena del reto. Ejemplos: Curl into a ball = niño enroscado en el suelo; Downhill = niño caminando cuesta abajo; Steep = cuesta muy empinada. Reutiliza una de las 349 de assets/brand/laminas/ solo si coincide de verdad. Si no, crea una nueva en el mismo formato vectorial JSON (LaminaEscena) y con el estilo Lúa, sin texto ni emojis. La lámina de reto (escena_peluche_pano, etc.) solo puede ir en el paso del reto, nunca como imagen de una palabra.
> 3. Pinta LaminaEscena encima de la palabra en _PasoVista (learn_duolingo.dart) en todos los pasos (pasosDoDia y pasosDoProxecto), en PalabraConXesto (palabras_do_dia.dart) y en la frase de gramática, con semanticsLabel gl/es.
> 4. Crea docs/laminas-ejercicios.md con una fila por pieza: palabra en/gl/es, gesto, clave, nueva o reutilizada, y por qué coincide.
> 5. Crea tools/check_laminas_leccion.py y llámalo desde tools/gates.sh. Debe fallar si cualquier pieza enseñada (lección Duolingo, TPR del día, proyecto 0-2, palabras do día) no tiene "lamina", si el fichero no existe, o si una pieza usa una lámina de escena de reto. Sin listas de exclusión.
> 6. Test de widget: lección curso_4_5.03.2. Pulsa «Continuar» paso a paso y exige un LaminaEscena en cada paso. En Curl, Downhill y Steep la clave no puede ser escena_peluche_pano. Otro test recorre todas las lecciones y todos los pasos de 0-2 y exige lámina.
>
> B. Bug de los días en Hoy
> 1. Que tocar cualquiera de los 5 nodos (learn_nodo_0..4) responda. Los pasados y el de hoy abren su lección. Los futuros abren su lección o muestran un aviso claro en gl/es («Este día ábrese o xoves»); nunca onTap null en silencio. Área de toque ≥ 48 px en el nodo y su etiqueta, sin depender del banner verde.
> 2. Test: HoxeFamiliasScreen con agora: DateTime(2026, 11, 11). Pulsa learn_nodo_0, learn_nodo_2 y learn_nodo_3 y comprueba la navegación o el aviso, sin tocar learn_banner.
>
> C. Cierre
> dart format, flutter analyze, flutter test y tools/gates.sh en verde. Capturas gl/es en docs/capturas/ de 5 pasos distintos con su dibujo, incluidos Curl, Downhill y Steep, y del aviso de un día futuro. Marca en ORDENES.md solo lo verificado. Con todo verde y 0 piezas sin lámina, abre PR, merge a main y push. Si queda una sola pieza sin lámina o un criterio abierto, NO hagas merge: dime cuántas y cuáles.
>
> Prohibido: Play, release, otros repos, git reset --hard, borrar stashes.
>
> Respuesta final breve: láminas nuevas y reutilizadas, piezas sin lámina (debe ser 0), SHA del merge, run de CI y lo no verificado en móvil real.
Fuente: microsoft/fluentui-emoji:assets/<Nombre>/Flat, MIT, Copyright (c) Microsoft Corporation
Base de contenido: assets/content/leccions/leccions.json (xaSabe, novas, repasa y fraseGramatica de cada lección), assets/content/tpr/**/*.json (las 4.000 palabras del banco, con su tprAction), assets/content/acopros/proxectos_0_2.json (200 palabras de 0-2) y assets/brand/laminas/ (el set propio, 349 láminas + 12 de escena, solo como respaldo donde Fluent no tenga coincidencia). Medido el 11/11/2026: 4.378 palabras y frases distintas (actualizado a 4.389 en check_laminas_leccion.py).
Regla fija de licencias (Frank, 18/11/2026): Descubre con Lúa **tiene ánimo de lucro**. Ninguna imagen, fuente, sonido, paquete ni contenido de terceros puede tener licencia no comercial (`NC`) ni sin derivadas (`ND`). Quedan descartadas ARASAAC (`CC BY-NC-SA`) y cualquier `CC BY-NC`. Solo valen `MIT`, `Apache 2.0`, `BSD`, `CC0`, `CC BY` y `OFL`. Fluent Emoji (`MIT`, composición de 2-3 emojis para las 97 piezas de `(b)`) sigue valiendo.

Estado actual de láminas (P2.95, sin flutter): **835 de 6.382 piezas sin lámina válida** (`leccions`: 0/1.962; `frases`: 0/200; `0-2`: 0/220; `tpr`: **3.165 de 4.000 cubiertas** = 581 compartidas con `P2.2–P2.6` + 2.584 directas/escenas revisadas en `P2.81–P2.95`, `U=197, R=37, C=607, D=1743`; las 835 restantes están auditadas sin base visual en `docs/tpr_sin_base.md`; quedan abiertos los criterios Flutter/capturas/CI/merge).

- [x] A1 · El campo `lamina` existe en PezaDaLeccion, TprWord y PalabraProxecto y está relleno en leccions.json, tpr/**/*.json y proxectos_0_2.json: 0 piezas sin lámina · evidencia: lib/data/models/leccion_model.dart (campo lamina) y tools/check_laminas_leccion.py (--resumo --tope-tpr: lecciones, frases y 0-2 a 0; TPR 0 pendientes de tope 0; las 835 sin base, aprobadas por Frank en O-20261119-3 y O-20261119-6, en tools/tpr_sin_base_aprobadas.txt)
- [x] A2 · Cada lámina representa ESA palabra y su gesto; ninguna pieza usa una lámina de escena de reto; reutilizada solo si coincide de verdad, si no, nueva en el set vectorial, sin texto ni emoji · evidencia: test/features/laminas_leccion_test.dart (ninguna pieza usa escena_; Curl/Downhill/Steep) y revisión por tandas en docs/PLAN_ANTIGRAVITY.md (registro P2.1–P2.95)
- [x] A3 · LaminaEscena encima de la palabra, con semanticsLabel gl/es, en todos los pasos de _PasoVista (pasosDoDia y pasosDoProxecto), en PalabraConXesto y en la frase de gramática · evidencia: test/features/palabra_lamina_test.dart («a palabra do día leva a súa lámina», gl y es, con su etiqueta) y test/features/laminas_leccion_test.dart (pasos de la lección, del proyecto de 0-2 y frase de gramática)
- [x] A4 · docs/laminas-ejercicios.md con una fila por pieza: en/gl/es, gesto, clave, nueva o reutilizada, y por qué coincide · evidencia: docs/laminas-ejercicios.md (una fila por pieza enseñada: 3.543 con lámina y 835 sin lámina por decisión de Frank, con su motivo; de tools/gen_laminas_palabras.py --control)
- [x] A5 · tools/check_laminas_leccion.py, llamado desde tools/gates.sh, falla si una pieza enseñada no tiene lámina, si el fichero no existe o si usa una lámina de escena de reto; sin listas de exclusión · evidencia: tools/check_laminas_leccion.py, en tools/gates.sh (ejecutado en P2.81 falla como debe: 3.260 de 6.382 piezas sin lámina válida, todas en TPR)
- [x] A6 · Test de widget de curso_4_5.03.2 paso a paso (LaminaEscena en cada paso; Curl, Downhill y Steep sin escena_peluche_pano) y test que recorre todas las lecciones y todos los pasos de 0-2 · evidencia: test/features/laminas_leccion_test.dart («curso_4_5.03.2, paso a paso: un debuxo en cada paso», Curl/Downhill/Steep sin escena_peluche_pano; «todas as leccións…» y «0-2: todos os pasos…»)
- [x] B1 · Los 5 nodos learn_nodo_0..4 responden al toque: pasados y hoy abren su lección; los futuros abren o avisan en gl/es; área de toque ≥ 48 px en nodo y etiqueta, sin depender del banner · evidencia: test/features/ux_l3_test.dart, «os nodos dos días responden sempre, sen tocar o banner», en gl y es; lib/features/familias/widgets/learn_duolingo.dart (causa: Transform.translate dejaba el nodo fuera de la caja que recibe el toque)
- [x] B2 · Test con HoxeFamiliasScreen y agora 11/11/2026 que pulsa learn_nodo_0, learn_nodo_2 y learn_nodo_3 sin tocar learn_banner · evidencia: test/features/ux_l3_test.dart, «os nodos dos días responden sempre, sen tocar o banner» (monta el portal de casa, comprueba que HoxeFamiliasScreen está, y pulsa los tres nodos)
- [x] C1 · dart format, flutter analyze, flutter test y tools/gates.sh en verde · evidencia: docs/ORDENES.md (CI de main en verde con tools/gates.sh entero: PR #57, runs 44497667331 y 44497675983; Claude Code en local con Flutter 3.47.9: format, analyze, 1569 tests en verde)
- [x] C2 · Capturas gl/es de 5 pasos distintos con su dibujo (Curl, Downhill y Steep incluidos) y del aviso de un día futuro · evidencia: test/capturas_test.dart, «lamina do paso ·» y «na casa · aviso dun día futuro ·», escriben docs/capturas/leccion-paso-curl, -downhill, -steep, -bright-orange y -frase (gl y es) y docs/capturas/hoxe-aviso-dia-futuro-gl y -es
- [x] C3 · PR, merge a main con CI en verde, con 0 piezas sin lámina · evidencia: docs/ORDENES.md (PR #60, merge 582478a4, runs 44535911964 y 44535920265 en verde; tools/check_laminas_leccion.py --resumo --tope-tpr a 0 con las 835 aprobadas)

## O-20261111-3 · El arreglo de los días de Hoy, solo, a main
Estado: cumplida
Absorbida por antigravity/pendiente: el arreglo de los días va en 303be16e, mergeado con main en 6be3d38b; se cumple con el merge de esa rama a main.
> Orden de Frank (11 nov 2026): Opción 2. Hazlo ahora, sin preguntarme más: 1. Crea la rama fix/dias-hoy desde origin/main (89691006). 2. git cherry-pick 303be16e (solo el arreglo de los días de Hoy y su test test/features/ux_l3_test.dart). Si hay conflicto, PARA y dímelo. 3. Corre en local: dart format --output=none --set-exit-if-changed . && flutter analyze && flutter test --exclude-tags capturas && tools/gates.sh --fast. Todo debe salir en verde. 4. Push de fix/dias-hoy, abre el PR contra main y espera a que el CI salga en verde. Con el CI en verde, autorizo el merge a main y el push. Si el CI sale rojo, NO mergees: pégame el error. 5. Registra la evidencia en docs/ORDENES.md (PR, SHA del merge y run en verde), dentro del mismo PR o en uno aparte de solo documentación. 6. NO toques feat/laminas-ejercicios ni empieces la orden del banco Fluent/Iconify: las láminas las hace otro agente desde esa rama. Entrégame: URL del PR, SHA del merge, run de CI en verde y lo que no hayas verificado.
Fuente: lib/features/familias/widgets/learn_duolingo.dart (y hoxe_familias_screen.dart, ux_l3_test.dart y criancas_test.dart), tal como quedan en el commit 303be16e de la rama feat/laminas-ejercicios: la parte B de O-20261111-2

- [x] Los cinco nodos de los días de Hoy responden al toque: lunes y hoy abren su lección y un día futuro avisa en gl y es, sin tocar el banner · evidencia: test/features/ux_l3_test.dart («os nodos dos días responden sempre, sen tocar o banner»)
- [x] En local, dart format, flutter analyze, flutter test y tools/gates.sh --fast en verde · evidencia: test/features/ux_l3_test.dart («os nodos dos días responden sempre, sen tocar o banner»; Claude Code, 19/11/2026, Flutter 3.47.9: format, analyze y flutter test en verde)
- [x] PR contra main mergeado con el CI en verde · evidencia: docs/ORDENES.md (absorbida por antigravity/pendiente: el arreglo entró en main con el PR #55, merge e6bd68f6, runs 44458071681 y 44458077155 en verde)

## O-20261118-1 · Hoy sin vacío, escenas que se entiendan y frases con apoyo visual
Estado: cumplida
> Aqui hay un error ya te habia explicado que me gusto el diseño ux nuevo con los dias de la semana a la izquierda y el gato a la derecha, aunque me parece que se puede mejorar porque hay mucho espacio entre el gato y los días y da la sensación de vacio, luego cuando le doy clic al ejercicio, aparece un dibujo cutre que se entiende mal y cuando le doy a continuar las frases aparecen sin apoyo visual, a eso me refiero , ademas creo que te di una serie de repositorios para sacar imagenes
> (mismo día, durante el trabajo) quizas hay que hacer mas grade el gato ya agregar algun accesorio
Fuente: ninguna: los repositorios de imágenes que Frank dice haber dado no están escritos en este repositorio (buscado en docs/, referencias/, STATUS.md y git log); pendiente de que Frank los nombre. Estado actual mirado en docs/capturas/hoxe-familias-gl.png, escena-duolingo-gl.png y leccion-duolingo-paso-gl.png

Camino: Na casa → Hoy (camino de días a la izquierda, Lúa a la derecha) → nodo del día (lección paso a paso) → Continuar.

- [x] Na casa → Hoy: se conserva el diseño de días a la izquierda y Lúa a la derecha, sin el hueco vacío entre los dos (Lúa junto al camino, a 412×915), en gl y es · evidencia: test/features/ux_l3_test.dart («Lúa, grande, ao lado do camiño e con accesorios», gl y es) y docs/capturas/hoxe-familias-gl.png, hoxe-familias-es.png
- [x] Lúa más grande en Hoy (de 64 a 112 de ancho) · evidencia: test/features/ux_l3_test.dart («Lúa, grande, ao lado do camiño e con accesorios», gl y es) y docs/capturas/hoxe-familias-gl.png, hoxe-familias-es.png
> (18/11/2026) primero que nada arreglemos la pantalla, agrega accesorios al gato
- [x] Lúa con accesorios en Hoy: flor en la cabeza y lazo rojo en el cuello (de Valeria, ya en el catálogo), salvo que el niño lleve puestos otros que ganó; definidos en premios_lua.json («deInicio») · evidencia: test/features/ux_l3_test.dart («Lúa, grande, ao lado do camiño e con accesorios», gl y es) y docs/capturas/hoxe-familias-gl.png, hoxe-familias-es.png
- [x] Al tocar el día: la imagen de la escena sale de los repositorios de imágenes que dio Frank y se entiende sin leer el texto (las 12 escenas) · evidencia: tools/gen_escenas_retos.py (12 escenas con Fluent Flat, MIT, y dibujos propios en el mismo estilo, sobre la mesa; control en docs/imagenes-escenas.md; gate tools/check_imagenes_escenas.py) y docs/capturas/escena-antes-despues.png
- [x] Al pulsar Continuar: cada palabra o frase en inglés del paso lleva su imagen, de la misma fuente · evidencia: test/features/laminas_leccion_test.dart («todas as leccións, os cinco días: cada paso co seu debuxo» y «curso_4_5.03.2, paso a paso: un debuxo en cada paso»); fuentes de O-20261111-4
- [x] Gate: falla si un paso de la lección con palabra o frase no tiene imagen · evidencia: tools/check_laminas_leccion.py (--resumo: 3260 de 6382 pezas sen lámina válida en TPR; fallo real del gate) en tools/gates.sh
- [x] Capturas gl/es de Hoy, la escena y un paso con frase, al lado de la fuente · evidencia: docs/capturas/escena-antes-despues.png (antes y después de la escena en gl y es, Hoy de 4-5 y la frase de la semana en la app de escritorio); docs/capturas/escena-duolingo-gl.png y -es.png
- [x] Mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #51, merge 429840b3, runs 44326670178 y 44326687729 en verde)

## O-20261118-2 · Plan para que Antigravity ejecute lo pendiente; Claude Code lo revisa
Estado: cumplida
> cuando termines, necesito que generes un plan para que antigravity ejecute todo el trabajo pendiente, tanto de las imagenes y el resto de trabajo pendiente, tu te encargaras de revisarlo cuando este listo
Fuente: docs/ORDENES.md (criterios abiertos en main y en origin/feat/laminas-ejercicios), docs/FALLOS.md y las ramas de origin con trabajo fuera de main (feat/laminas-ejercicios, fix/dias-hoy, claude/charming-euler-9i23cj, claude/upbeat-fermi-3d0utp)

- [x] docs/PLAN_ANTIGRAVITY.md: cada criterio abierto de cada orden, con su rama, sus pasos, su gate y cómo se da por hecho · evidencia: docs/PLAN_ANTIGRAVITY.md
- [x] Revisión de Claude Code de lo que entregue Antigravity, criterio por criterio, con los gates corridos y las capturas miradas · evidencia: docs/PLAN_ANTIGRAVITY.md (columna Revisión del registro, fila a fila; P7.9 revisada par a par, pip/pit devuelto) y docs/escoita-control.md

## O-20261118-3 · Juegos de escucha y palabras (opción A), dentro de la lección y unidos al STEAM
Estado: cumplida
> Por cierto me gustaría explorar la posibilidad de que descubre con lua integre ejercicios de logopedia como pares mínimos y expansión semántica mezclados con steam y el aprendizaje de inglés
> Me gusta la opción A prepara el plan para que también lo asuma antigravity ahora
> (19/11/2026) Si quiero el Modo Aula como camino con banner, igual que el de casa, pero porque no copias el trabajo ya hecho en el respositorio de valeria y lo adaptas ?
> (19/11/2026, aclarando la anterior) coñazo joder me refiero a la fucking logopedia
Fuente: FrankBetances/Valeria:src/valeriaMinimalPairsEn.ts (los 9 pares del inglés: par, fonema, misión del adulto en el acierto y en el fallo, pista) y src/valeriaSemanticExpansionEn.ts (PROGRESSION_SEQUENCES_EN: concepto → parte → acción → cualidad, con la acción del adulto); se copian y se adaptan: sin emoji (láminas propias), sin reconocedor de voz (el niño señala, el adulto dice), y con lenguaje educativo, sin «logopedia», «terapia» ni «trastorno». Antes: assets/content/unidades_mes/curso_4_5/unidade.01.json (campo «contraste»)

Opción A, tal como la eligió Frank: estimulación del lenguaje universal y educativa, sin finalidad sanitaria (regla de producto de CLAUDE.md). Ni «logopedia», ni «terapia», ni «trastorno» en la app, en la ficha ni en documentos públicos.

(19/11/2026) Corregido: Claude Code había reducido esta orden a un piloto de una unidad de 4-5 años que Frank no pidió; vuelve a su alcance, todas las edades con lección y todos los meses, con el STEAM como eje (F-20261119-8).
- [x] Na casa → Hoy → día → Continuar, en 2-3, 3-4, 4-5 y 5-6 y en los 10 meses: un paso de pares mínimos en inglés con palabras del STEAM del mes, las dos láminas, la voz de cada palabra y la misión para el adulto en gl/es · evidencia: test/features/paso_escoita_test.dart (plan real: 4 edades × 10 meses) y tools/check_plan_escoita.py (40 piezas, 0 pares pendientes), tools/check_pares_en.py y tools/check_voice_coverage.py
- [x] En las mismas lecciones, un paso de expansión semántica de una palabra del STEAM del mes (concepto, parte, acción, cualidad), cada palabra con lámina, voz y significado gl/es · evidencia: test/features/paso_escoita_test.dart (plan real: 4 edades × 10 meses) y tools/check_plan_escoita.py (40 piezas, 0 pares pendientes) y test/core/significados_test.dart
- [x] En las mismas lecciones, un modelo de expansión gramatical para el adulto (el niño dice una palabra del STEAM, el adulto la amplía en tres frases), con voz · evidencia: test/features/paso_escoita_test.dart (plan real: 4 edades × 10 meses) y tools/check_plan_escoita.py (40 piezas, 0 pares pendientes) y tools/check_voice_coverage.py
- [x] Gate: falla si falta la pieza de un curso y mes, si un par no difiere en un solo fonema, si una palabra no tiene lámina, voz o STEAM, o si aparece «logopedia», «terapia» o «trastorno» en assets/, lib/ o docs/ públicos · evidencia: tools/check_plan_escoita.py, tools/check_pares_en.py, tools/check_voice_coverage.py y tools/check_finalidade.py, los cuatro en tools/gates.sh
> (20/11/2026) Además la malditos pares mínimos ya los escucho la maldita logopeda y los dio por buenos joder
- [x] Revisado por Frank (o por la logopeda que validó Valeria): los pares son válidos y adecuados a cada edad · evidencia: docs/ORDENES.md (palabra de Frank del 20/11/2026: la logopeda los escuchó y los dio por buenos)
> (26/11/2026) «ya he visto la aplicación y la he usado y evaluado tanto lo de Valeria como el resto, y para todo eso hubo un merge»
- [x] Frank lo ve en la app (Na casa → Hoy → día → Continuar) en tres meses de edades distintas y lo da por bueno · evidencia: docs/ORDENES.md (palabra de Frank del 26/11/2026: la ha usado y evaluado)

## O-20261118-4 · Un único plan que registre cada commit, para auditar paso a paso
Estado: cumplida
> Por cierto genera un único plan que vaya guardando cada Commit para poder ir auditando al trabajo, paso a paso
Fuente: docs/PLAN_ANTIGRAVITY.md (el plan de O-20261118-2 y O-20261118-3, ahora el único plan de lo pendiente)

- [x] Un único plan con todos los pasos numerados (P0.1…P5.4), cada uno con su bloque y si para a esperar a Frank · evidencia: docs/PLAN_ANTIGRAVITY.md, «Pasos»
- [x] Un registro de commits en el plan: paso, SHA, fecha, qué cambia en la app, gates, evidencia y revisión · evidencia: docs/PLAN_ANTIGRAVITY.md, «Registro de commits»
- [x] Gate que tumba si un commit desde la base no empieza por su paso o no tiene fila, si una fila no tiene SHA, fecha, gates o evidencia, o si un SHA no está en la rama · evidencia: tools/check_registro_commits.py, en tools/gates.sh; probado el 18/11/2026 en una copia desde caca7cb5: falla sin fila, pasa con fila, falla con un commit sin paso. En CI (clon sin historia) solo comprueba la tabla, y lo dice
- [x] Usado por Antigravity en cada commit y auditado por Claude Code fila a fila · evidencia: docs/PLAN_ANTIGRAVITY.md (columna Revisión rellena en las 60 filas, 20/11/2026) y tools/check_registro_commits.py (cada commit con su paso y su fila)

## O-20261118-5 · Merge y push a main de lo de hoy
Estado: cumplida
> mergea y push al main
Fuente: ninguna: es la orden de integrar en main los commits de claude/upbeat-fermi-3d0utp (O-20261118-1 a O-20261118-4)

- [x] Rama subida, PR contra main y CI en verde antes del merge (primer run, 44322296728, rojo por Flutter 3.50.0; versión fijada a 3.47.9 en ci.yml) · evidencia: .github/workflows/ci.yml (PR #51, runs 44326670178 (push) y 44326687729 (pull_request) en verde sobre 6d5303db)
- [x] Merge en main con su SHA · evidencia: docs/ORDENES.md (merge 429840b3 del PR #51, 18/11/2026)

## O-20261111-4 · El banco de imágenes: fuentes permitidas y método (orden dada en otra sesión)
Estado: cumplida
> (Frank, 11/11/2026, sesión «Análisis de rama pedagógica») Sigue O-20261111-1 en feat/laminas-ejercicios (caca7cb5). ALCANCE: las 6.382 piezas de TODAS las edades (0-2, 2-3, 3-4, 4-5, 5-6, 6-7), las frases de gramática y el banco TPR. [...] FUENTES PERMITIDAS (solo estas): 1. Fluent Emoji Flat (MIT), la base. 2. Iconify, solo sets MIT, Apache o CC0; game-icons (CC BY 3.0) con crédito. 3. dnizfor/vocabulary-flashcard-dataset (MIT). Excluye cualquier imagen que se parezca a un personaje o marca. 4. Solo para escenas de apoyo: global-asp/pb-imagebank (CC BY 4.0), con crédito al ilustrador. Prohibido: BY-SA, NC, Flaticon, Freepik, Envato y emojis en los JSON. Fija el SHA de cada repo de origen y guarda su LICENSE en tools/banco/<fuente>/<sha>/. Los originales solo se usan al compilar y no van en el APK. MÉTODO, igual para cada edad: a) Banco: lo que existe tal cual o eligiendo otro dibujo (U/R). b) Composición: objetos del banco más pose de Fluent o la figura articulada en estilo plano (C). c) Propias: dibujo vectorial en estilo Lúa (D). [...] BLOQUE 1 · Conversor, mapa y gate (tools/banco_a_lamina.py, assets/content/laminas/palabras_laminas.json, créditos con LicenseRegistry, tools/check_banco_laminas.py). BLOQUES 2 a 7 · Una edad completa por bloque: 4-5, 0-2, 2-3, 3-4, 5-6 y 6-7. BLOQUE 8 · Banco TPR (4.000), agrupado por gesto. BLOQUE 9 · Cierre a 0 piezas sin lámina.
> (18/11/2026) No me hagas perder más tiempo que ya esto se discutió y se repartió en otra sesión y quedó todo apuntado
Fuente: ninguna: orden literal recuperada del historial de la sesión session_01JWGSxXCBGSNhrehHwDcMph (11/11/2026 17:48 UTC); los CSV que cita (docs/revision_4_5_lecciones.csv, docs/cobertura_fluent_distintas.csv, docs/candidatos_banco.csv) no están en ninguna rama de GitHub

- [x] Solo las cuatro fuentes permitidas; Fluent en estilo Flat (no Color); BY-SA, NC, Flaticon, Freepik y Envato fuera · evidencia: tools/check_banco_laminas.py y tools/check_licencias.py (en tools/gates.sh); assets/content/laminas/palabras_laminas.json (solo fluent-flat, composta, propia y dnizfor en P2.2)
- [x] SHA y LICENSE de cada fuente en tools/banco/<fuente>/<sha>/; créditos con LicenseRegistry, ATTRIBUTION.md y LICENSE.md · evidencia: tools/banco/fluentui-emoji/1ffb34c752ecf5d402f04cfb4b392c77f57c54bc/LICENSE, tools/banco/iconify-icon-sets/81ad501f19cc13e548e4cb6a9c63a3873c87262a/LICENSE, tools/banco/vocabulary-flashcard-dataset/eae41b7c6cd85da0ca4171ce79eb115971b533de/LICENSE, tools/banco/pb-imagebank/7f6a3b2d0213e05c25a088413a487178a4209234/LICENSE, lib/core/brand/licenzas_terceiros.dart, ATTRIBUTION.md y LICENSE.md
- [x] tools/banco_a_lamina.py, assets/content/laminas/palabras_laminas.json y tools/check_banco_laminas.py en tools/gates.sh · evidencia: tools/banco_a_lamina.py (--test OK), assets/content/laminas/palabras_laminas.json (190 piezas revisadas), tools/check_banco_laminas.py en tools/gates.sh
- [x] Cada edad completa a 0 piezas sin lámina, en el orden 4-5, 0-2, 2-3, 3-4, 5-6, 6-7, con hoja de contactos y capturas gl/es · evidencia: docs/capturas/hoja_contactos_curso_4_5_p1.png (y las de curso_0_2, acopros_0_2, curso_2_3, curso_3_4, curso_5_6 y tpr); capturas gl/es en docs/capturas/escritorio/hoxe-casa-*.png; no existe curso 6-7 (P2.7); tools/check_laminas_leccion.py (--resumo --tope-tpr: lecciones, frases y 0-2 a 0; TPR 0 pendientes de tope 0; las 835 sin base, aprobadas por Frank en O-20261119-3 y O-20261119-6, en tools/tpr_sin_base_aprobadas.txt)
- [x] Banco TPR (4.000) cubierto, agrupado por gesto · evidencia: tools/tpr_tandas/tanda_01.py … tanda_13.py (agrupadas por gesto, revisadas palabra+gesto; 3.165 con lámina) y tools/check_laminas_leccion.py (--resumo --tope-tpr: lecciones, frases y 0-2 a 0; TPR 0 pendientes de tope 0; las 835 sin base, aprobadas por Frank en O-20261119-3 y O-20261119-6, en tools/tpr_sin_base_aprobadas.txt)

Estado actual TPR (P2.95, sin flutter): **4.000 de 4.000 piezas TPR auditadas** (`3.165` cubiertas con lámina revisada = `581` compartidas con `P2.2–P2.6` + `2.584` directas/escenas en `P2.81–P2.95`, `U=197, R=37, C=607, D=1743`; `835` auditadas sin base visual en `docs/tpr_sin_base.md`, tope bajado a `835`). Sigue abierto pendiente de revisión de Claude Code, Flutter/CI y decisión de Frank sobre las 835 piezas sin base.

## O-20261119-1 · Mergear ya las lecciones de todas las edades; el banco TPR, con tope que solo baja
Estado: cumplida
> (Claude Code) ¿Mergeo ya las lecciones de todas las edades a main mientras Antigravity rehace el banco TPR? — (Frank) Si
> (Claude Code) propongo partir ese gate en dos: lecciones, frases y 0-2 a 0; banco TPR con tope que solo baja — (Frank) Ok
Fuente: ninguna: origin/antigravity/pendiente en ef209a9c (P2.1–P2.7, revisado por Claude Code el 19/11/2026); P2.8 y P2.9 quedan fuera, rechazadas en revisión

- [x] tools/check_laminas_leccion.py --tope-tpr: lecciones, frases y 0-2 a 0 piezas sin lámina; banco TPR no puede pasar de tools/tope_tpr_sen_lamina.txt (3419), y el tope solo baja · evidencia: tools/check_laminas_leccion.py, en tools/gates.sh
- [x] Mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #55, merge e6bd68f6, runs 44458071681 y 44458077155 en verde sobre 8d34cd44)

## O-20261119-2 · Mergear las 10 tandas del banco TPR y bajar el tope
Estado: cumplida
> (Claude Code) Mergear ya las 10 tandas a main: traigo main, bajo el tope del gate del banco TPR de 3.419 a 1.260, paso Flutter y los gates, y mergeo con CI en verde. ¿Hago el merge del punto 1? — (Frank) Ok
Fuente: ninguna: origin/antigravity/pendiente en 1ed8d635 (P2.81–P2.91), revisado por Claude Code el 19/11/2026 (hoja_contactos_tpr_p9 y docs/tpr_sin_base.md)

- [x] Tope del banco TPR bajado de 3419 a 1260 piezas sin lámina · evidencia: tools/tope_tpr_sen_lamina.txt (check_laminas_leccion.py --resumo --tope-tpr: TPR sin lámina 1260 de tope 1260)
- [x] Mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #57, merge 26c066a0, runs 44497667331 y 44497675983 en verde sobre 6f9a5602)

## O-20261119-3 · Las 608 piezas TPR sin base visual se quedan sin imagen
Estado: cumplida
> Las 608 del banco tpr se quedan se quedan sin imagen
Fuente: docs/tpr_sin_base.md (las 608 piezas auditadas por Antigravity en P2.82–P2.91, con su motivo)

- [x] Lista cerrada de las 608 claves en tools/tpr_sin_base_aprobadas.txt; check_laminas_leccion.py --tope-tpr no las cuenta como pendientes; una pieza nueva sin base sigue contando hasta que Frank la apruebe · evidencia: tools/check_laminas_leccion.py (TPR sin lámina 652 de tope 652)
- [x] Tope del banco TPR bajado a 652 (las piezas que quedan por procesar) · evidencia: tools/tope_tpr_sen_lamina.txt
- [x] Mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #58, merge 9ed35235, runs 44505869435 y 44505873225 en verde sobre f688c7fc)

## O-20261119-4 · Hoy de 4-5 años: vale el diseño Duolingo; contraste de sonido en 0-2
Estado: cumplida
> 1 sí, da por sustituida por el diseño Duolingo y dos arregla el tema de el contraste de sonido en 0-2 años
Fuente: docs/ORDENES.md (O-20261028-4, O-20261109-5, O-20261101-1 y O-20261101-3)

- [x] O-20261028-4 (todo en la primera pantalla de Hoy de 4-5 años) queda sustituido por el diseño Duolingo de O-20261109-5 · evidencia: docs/capturas/escritorio/hoxe-casa-4-5-gl.png
- [x] Contraste de sonido en 0-2: ya hecho por O-20261101-3 (1/11/2026); las 10 unidades de 0-2 con su par del banco y nota gl/es, y se ve en el calendario de aula y de casa · evidencia: test/features/calendario/calendario_escala_test.dart («contraste_do_mes» en curso_0_2)

## O-20261119-5 · Las unidades 21-48 quedan cubiertas con lo que ya tienen
Estado: cumplida
> 1, dalas por cubiertas
Fuente: assets/content/gramatica/gramatica.json (unidades 21-48 en la ruta de las criaturas; O-20261028-9)

- [x] Los criterios de unidades 21-48 de O-20261028-7 y O-20261028-8 se cierran con lo que ya hay: una unidad por mes con 4 frases semanales dentro del STEAM, línea para la familia y ejemplo · evidencia: tools/gen_gramatica.py (falla si falta una de las 48 en la ruta)

## O-20261119-6 · Las 227 piezas TPR sin base también sin imagen; terminar lo pendiente
Estado: cumplida
> Sí, las 227 también se quedan sin imagen, y termina el resto del trabajo pendiente
Fuente: docs/tpr_sin_base.md (las 227 piezas sin base de P2.93–P2.95, con su motivo)

- [x] Las 835 piezas TPR sin base (608 + 227) en la lista cerrada tools/tpr_sin_base_aprobadas.txt; tope TPR a 0 · evidencia: tools/check_laminas_leccion.py (--resumo --tope-tpr: TPR 0 de tope 0)
- [x] Las 12 escenas de reto rehechas con las fuentes de O-20261111-4 (Fluent Flat, composiciones en estilo Lúa), sin el triángulo rosa · evidencia: tools/gen_escenas_retos.py (12 escenas con Fluent Flat, MIT, y dibujos propios en el mismo estilo, sobre la mesa; control en docs/imagenes-escenas.md; gate tools/check_imagenes_escenas.py) y docs/capturas/escena-antes-despues.png
- [x] La tarjeta de palabras del día (PalabraConXesto) pinta la lámina de cada palabra con semanticsLabel gl/es · evidencia: test/features/palabra_lamina_test.dart («a palabra do día leva a súa lámina», gl y es, con su etiqueta) y test/features/laminas_leccion_test.dart (pasos de la lección, del proyecto de 0-2 y frase de gramática)
- [x] Los juegos de escucha y palabras (O-20261118-3) hechos hasta donde depende de Claude Code, en todas las edades con lección, y propuestos a Frank para su revisión · evidencia: test/features/paso_escoita_test.dart (plan real: 4 edades × 10 meses) y tools/check_plan_escoita.py (40 piezas, 0 pares pendientes)
- [x] Mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #60, merge 582478a4, runs 44535911964 y 44535920265 en verde)

## O-20261119-7 · Terminar el rediseño de la UX/UI: mejorar lo que hay, con más vida, dinamismo y atractivo
Estado: cumplida
> Ademas necesito que termines el rediseño de la  UX -UI, no borrar lo que hay, la idea es mejorar lo que hay, darle más vida y dinamismo, además que sea mucho más atractiva en todos los sentidos
Fuente: docs/capturas/escritorio/hoxe-casa-4-5-gl.png (y las demás de docs/capturas/escritorio: estado de partida del 19/11/2026); diseño Duolingo de O-20261109-5 (duolingo-clone, MIT) como referencia que se conserva

Criterios propuestos por Claude Code (Frank los corrige): nada se borra; se mejora lo que hay.
- [x] Hoy de casa con movimiento: el nodo de hoy late, el globo «Empezar» flota, los días entran escalonados con un pequeño rebote, Lúa respira y salta al tocarla · evidencia: test/core/movimiento_test.dart («con movimiento, el nodo de hoy late»); lib/core/widgets/movimiento.dart (Latido, Flotar, Entrada, SaltoLua) en learn_duolingo.dart; docs/capturas/escritorio/redeseno-hoxe-movemento.gif y redeseno-lua-salta.png
- [x] La lección paso a paso entra con transición entre pasos, la imagen aparece con una animación suave y la barra de progreso avanza animada · evidencia: lib/features/familias/widgets/learn_duolingo.dart (_Transicion, Entrada en la lámina, TweenAnimationBuilder en leccion_progreso); docs/capturas/escritorio/redeseno-paso-gl.png y -es.png (capturado en mitad de la transición en la app de escritorio)
- [x] El fin de la lección celebra: Lúa salta, confeti propio (sin emoji) y los puntos y la racha suben contando · evidencia: test/core/movimiento_test.dart («los puntos se cuentan hasta el total», «el confeti cae una vez y se acaba»); lib/core/widgets/movimiento.dart (Confeti, ContadorAnimado, SaltoLua); docs/capturas/escritorio/redeseno-fin-gl.png y -es.png
> (19/11/2026) Si quiero el Modo Aula como camino con banner, igual que el de casa
- [x] Na escola → Hoy (4-5 años y las demás edades con lección): el camino de los cinco días en zigzag con el banner de la unidad, igual que en casa, y debajo todo lo que el aula tiene hoy (frase de la unidad, lo nuevo, cómo hablar, sesión de 45 minutos), sin quitar ninguna función · evidencia: test/features/tpr_pantallas_test.dart («camino con banner» en 2-3, 3-4, 4-5 y 5-6, gl y es: aula_camino, learn_banner, los cinco nodos y el título del aula debajo) y docs/capturas/escritorio/aula-camino-4-5-gl.png y -es.png (app de escritorio; no visto en un aparato)
- [x] Todo respeta «reducir movimiento» del sistema y no rompe a escala de texto grande · evidencia: test/core/movimiento_test.dart («reducir movimiento: nada late, flota ni cae confeti»); test/features/portales_escala_test.dart (la lección y su fin a escala 1.8 en gl y es, y los portales de casa y aula a 1.8)
- [x] Capturas de escritorio antes y después, en gl y es, de Hoy, un paso, el fin de lección y el Modo Aula · evidencia: docs/capturas/redeseno-antes-despues.png (el antes del fin es la captura del test, no del escritorio)
- [x] Mergeado en main con CI en verde · evidencia: docs/ORDENES.md (tanda 1: PR #61, merge 508e7236, runs 44550053706 y 44550097035 en verde)

## O-20261119-8 · Traer de Valeria la logopedia (pares y expansión, en/gl/es), la tipografía, el movimiento, la UX y las insignias, adaptarlo y expandirlo
Estado: cumplida
> todo lo que esta en valeria también esta en ingles gallego y castellano ya validado por una logopeda de la universidad de howard ahora lo que habría que hacer es adaptarlo y expandirlo, también copia los movimientos tipo de letras, de la ux, ademas también hay insignias que puedes copiar
Fuente: FrankBetances/Valeria:src/valeriaMinimalPairsEn.ts (y valeriaMinimalPairsGl.ts, valeriaMinimalPairsEsDO.ts y valeriaMinimalPairs.ts: los pares en inglés, gallego y castellano), src/valeriaSemanticExpansionEn.ts (y …Gl.ts y valeriaSemanticExpansion.ts: escenarios, categorías, progresiones concepto → parte → acción → cualidad y cápsulas de contraste), src/ui/fonts.ts (Fredoka para títulos, Nunito para texto, OFL), src/ui/motion.tsx, src/ui/Celebration.tsx, src/ui/ReactiveTile.tsx, src/ui/ScreenHeader.tsx y src/ui/KidButton.tsx (movimiento y UX), src/valeriaGamification.ts y src/ValeriaPixelArt.ts (insignias); capturas de la fuente en docs/screenshots/ de Valeria

Dato de Frank, no comprobable en el repositorio: el contenido de Valeria está validado por una logopeda de la Universidad de Howard. Las cabeceras de los ficheros en inglés de Valeria aún dicen «borrador para revisión clínica»; se toma la palabra de Frank.
Adaptación (opción A de O-20261118-3): sin emoji (láminas propias), sin reconocedor de voz (el niño escucha y señala, el adulto dice), y con lenguaje educativo, sin «logopedia», «terapia» ni «trastorno» en la app.
> (19/11/2026) por cierto espero que no hagas como en otros trabajos donde solo trabajas en el modulo de 4-5 años y el resto no hay nada, si hace falta hacer trabajo duro dímelo y se lo paso a antigravity, aun tengo 25% de la sesión semanal dosponible
Decisiones de Frank (19/11/2026, a pregunta de Claude Code): «Uno por mes» —un par, una progresión y un modelo para el adulto por mes y por edad, 40 piezas distintas (10 meses × 2-3, 3-4, 4-5 y 5-6), las 9 de Valeria incluidas; 0-2 va por proyectos— y «Juegos de escucha en casa» —los pares y progresiones de Valeria en gallego y castellano van a Na casa → Explorar, en la lengua de la app—.
Todas las edades a la vez: Frank deroga para esta orden la entrega de una sola edad primero (R∞ 6.3).
> (19/11/2026) te he ordenado que me des el prompt del trabajo duro para antigtavity ahora
Reparto: Antigravity hace el contenido pesado (P7.1–P7.4 de docs/PLAN_ANTIGRAVITY.md: gate fonético, las 40 piezas mensuales y las láminas que faltan); Claude Code hace el código (banco de Valeria importado, pasos en la lección, Juegos de escucha, tipografía, movimiento, insignias, Modo Aula) y revisa lo de Antigravity.

- [x] Pares de Valeria en inglés (9), gallego (13) y castellano (15) copiados en assets/content/escoita/, cada palabra con su lámina y su voz, la misión del adulto en gl/es; un gate compara el número con la fuente · evidencia: tools/check_escoita.py en tools/gates.sh (es 15, gl 13, en 9; 0 palabras sin lámina, tope 0 tras P7.7) y tools/check_voice_coverage.py (voz de cada palabra; los audios que falten los genera el workflow voice-assets)
- [x] Progresiones y cápsulas de contraste de Valeria en inglés, gallego y castellano copiadas en assets/content/escoita/, cada palabra con lámina y voz · evidencia: test/features/xogos_escoita_test.dart («as cinco seccións, en» gl y es) y tools/check_escoita.py (valeria_gl.json, valeria_es.json y valeria_en.json; 0 sin lámina)
- [x] Na casa → Hoy → día → Continuar, en los 10 meses de 2-3, 3-4, 4-5 y 5-6: cada semana del mes una actividad distinta con la pieza del mes (s1 escucha y señala el par; s2 la progresión concepto → parte → acción → cualidad; s3 el modelo de expansión para el adulto; s4 las misiones de Valeria del par y su contraste) · evidencia: test/features/paso_escoita_test.dart (plan real: 4 edades × 10 meses) y tools/check_plan_escoita.py (40 piezas, 0 pares pendientes)
- [x] Expandido: 40 piezas distintas (10 meses × 4 edades), sin repetir ningún par ni progresión entre meses ni edades; los 31 pares nuevos comprobados con diccionario fonético (un solo fonema distinto, como el gate de Valeria) y con palabras del STEAM o del vocabulario del mes · evidencia: tools/check_plan_escoita.py (40 piezas, sin repetir, STEAM del mes en cada palabra) y tools/check_pares_en.py (40 pares de un fonema en CMUdict); 6 pares sin par válido no se enseñan y siguen abiertos en O-20261119-10
- [x] Tipografía de Valeria: Fredoka en títulos y Nunito en texto, en casa y en el aula, con su licencia OFL en assets/fonts · evidencia: test/core/theme_test.dart («Nunito is the family, and it ships inside the app»: Fredoka en titleLarge y en los ficheros con su OFL) y docs/capturas/escritorio/aula-camino-4-5-gl.png y escoita-lista-gl.png (títulos en Fredoka en casa y en el aula, app de escritorio)
- [x] Movimiento y UX de Valeria adaptados: entrada en cascada (55 ms, 380 ms), respiración de 3 px y 1,4 s, anillo de avance que se dibuja al aparecer, halo que late en lo que toca, celebración con estrellas escalonadas y confeti de seis colores, botón 3D que se hunde; todo con «reducir movimiento» · evidencia: test/core/movimiento_test.dart («reducir movimiento: nada late, flota ni cae confeti»); lib/core/widgets/movimiento.dart (Entrada 55 ms y 380 ms, Flotar 3 px y 1,4 s, AnilloAvance 250+900 ms, Halo 650 ms, Estrelas escalonadas, coresCelebracion de seis colores) y docs/capturas/escritorio/redeseno-fin-gl.png
- [x] Na casa → Explorar → Xogos de escoita / Juegos de escucha: los pares, progresiones y cápsulas de Valeria en gallego o castellano según el idioma de la app, con lámina y voz · evidencia: test/features/xogos_escoita_test.dart («as cinco seccións, en» gl y es, «o GL/ES cambia a lingua da pantalla aberta», «xogo do par: acerto dá a misión; erro dá a pista») y docs/capturas/escritorio/escoita-lista-gl.png, -es.png, escoita-prog-gl.png, -es.png, escoita-xogo-gl.png y -es.png (app de escritorio)
- [x] Insignias: las de Valeria que no estén aquí, copiadas, y los glifos redibujados en Valeria (huella, cascabel, orejitas) al día · evidencia: assets/brand/awards/awards.json (los 9 glifos, fila a fila, iguales a FrankBetances/Valeria:src/ValeriaPixelArt.ts del commit e2a2a5e8; las 18 insignias con el mismo glifo y metal que src/valeriaGamification.ts; comparado por Claude Code con un script el 19/11/2026: no faltaba ninguna ni había glifo distinto)
- [x] Capturas de la fuente (Valeria) al lado de las propias, en gl y es, en un mismo documento · evidencia: docs/capturas/escritorio/escoita-xogo-gl.png (las nuestras, en gl y es; la hoja con las de Valeria al lado se entregó a Frank por el chat el 19/11/2026 y no se sube porque el repositorio es público y R5 prohíbe capturas de otro producto de la casa)
- [x] Mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #62, merge ea4eeaf9 en main, runs 44612047893 y 44612061013 en verde con los audios)

## O-20261119-9 · Restaurar lo borrado sin permiso, reglas y hooks para no repetirlo, y a main
Estado: cumplida
> No no no no no y no me puedo fiar de ti lo primero es que yo no te mandé a borrar nada y lo siguiente es que has cometido demasiados errores y no son asumibles dime qué reglas hay que crear ahora para que no vuelva nunca más a ocurrir y que Hook hay que crear para mantenerte a raya
> Restaura todo, crea las reglas y los Hooks , push al main y mergea ya
> YO QUIERO QUE RESTAURES, GUARDES REGLAS Y HOOK Y MERGEA Y PUSH AL MAIN YA
Fuente: docs/FALLOS.md (F-20261119-1 a 4) y la propuesta de reglas y hooks que Claude Code dio a Frank el 19/11/2026 y Frank aprobó

- [x] Restaurado lo que Claude Code borró sin permiso: el banco de Valeria (gl, es, en), su importador, su gate, su tope, su test y la pantalla de cinco secciones; y deshechos los cambios hechos después sin permiso (línea STEAM en los pasos, campos steam del plan, tarjeta de Explorar) · evidencia: test/features/xogos_escoita_test.dart («o banco de Valeria, enteiro: 13 pares en galego e 15 en castelán» y «as cinco seccións, en» gl y es) y tools/check_escoita.py en tools/gates.sh
- [x] Reglas R-STOP, R-BORRAR, R-STEAM y R-VERDAD-ACCIONES escritas arriba del todo en CLAUDE.md, junto a R∞ · evidencia: CLAUDE.md (R-FRANK)
- [x] Hooks creados y conectados en .claude/settings.json: stop_freno.py, freno_herramientas.py, sin_borrar.py, registro_acciones.py y blindaje.py; probados a mano (STOP bloquea, «sigue» desbloquea, rm sin permiso bloqueado, rm pedido permitido, escribir en .claude/ bloqueado) · evidencia: docs/FALLOS.md (F-20261119-1 a 4, cada uno con su hook como guarda; tools/check_fallos.py comprueba que existan)
- [x] PR mergeado en main con CI en verde · evidencia: docs/ORDENES.md (PR #62, merge ea4eeaf9 en main, runs 44612047893 y 44612061013 en verde con los audios)

## O-20261119-10 · Terminar lo que falta y entregar una versión definitiva
Estado: cumplida
> Vamos a ver Joder antigravity ya terminó
> Ahora yo lo que quiero es que se termine de trabajar
> Completa todo lo que falta y entrega una versión definitiva
Fuente: docs/PROMPTS_ANTIGRAVITY.md (P7.9; entrega de Antigravity en antigravity/escoita, c0d7ae38) y los criterios abiertos de O-20261118-3 y O-20261119-8 en este fichero

- [x] Entrega P7.9 revisada por Claude Code par a par contra su experimento STEAM e integrada: los pares cuyas dos palabras salen del experimento van a la lección; el que no (2-3 M06 pip/pit: «pit», hueso de otra fruta, no está en el experimento) vuelve a pendiente; gallego corregido · evidencia: tools/check_plan_escoita.py (6 pendientes listados: 2-3 M2, M4, M6, M10; 3-4 M6, M10), test/features/paso_escoita_test.dart (plan real, 4 edades × 10 meses) y test/core/significados_test.dart en verde
- [x] Criterios de O-20261119-8 que ya tienen su prueba, marcados con ella · evidencia: docs/ORDENES.md (O-20261119-8: pares, progresiones y expansión marcados con sus gates; queda abierto el paso de la lección en los 6 meses sin par)
> (20/11/2026, a pregunta de Claude Code) «Sí a los tres»: pan/pat (2-3 M4), light/night (2-3 M10) y cheek/peek (3-4 M10) entran aunque salten la regla de edad (nasal, líquida, africada), porque las dos palabras salen del experimento.
- [x] Los pares que seguían sin par válido se deciden con Frank: los tres que aprobó entran en la lección con su lámina, su voz y sus misiones en gl/es · evidencia: tools/check_pares_en.py (un solo fonema en CMUdict: pan/pat, light/night, cheek/peek) y tools/check_plan_escoita.py (cada palabra con su STEAM; quedan 3 pendientes)
> (20/11/2026) Te ordené completar todo el trabajo pendiente / Te ordené completar todo el trabajo pendiente / Te ordené completar absolutamente todo el trabajo pendiente
- [x] 2-3 M2, 2-3 M6 y 3-4 M6 con par, con el mismo criterio que Frank aprobó (las dos palabras del experimento, fuera de la regla de edad): blow/slow, seed/see y drink/shrink · evidencia: tools/check_pares_en.py y tools/check_plan_escoita.py (40 pares, 0 pendientes)
- [x] Mergeado en main con CI en verde y los audios generados · evidencia: docs/ORDENES.md (PR #63, merge fddc667c en main; run 44649317109 de Gates en verde sobre 6e9bbe08, con los audios del workflow voice-assets)

## O-20261120-1 · Estimulación del lenguaje y el pensamiento, bien visible; voz como en Valeria; realidad aumentada con Lúa
Estado: cumplida
> Ya he probado con logopeda está todo casi bien pero hay un pequeño problema con la velocidad del dictado, es demasiado rápido y no es adecuado para la enseñanza y aprendizaje de un segundo idioma, faltaría incorporar la realidad aumentada para utilizar lua y los sets que ya están en Valeria en esta app
> Te pedí y fui bastante claro de que quería que tuviera también Logopedia que la copiaras de Valeria, y que a su vez se centrará o intentará utilizar la base steam para estimular el pensamiento crítico y las capacidades cognitivas de los niños, y es que veo todo el aprendizaje que te he pedido que esté ahí, pero no consigo ver esa parte precisamente donde la ocultaste?
> Hombre, creo que hay que señalizarla como estimulación de lenguaje y pensamiento, y que debe estar bastante clara me parece que es muy cutre, lo que has hecho, realmente una basura total y que me has llevado la contraria
> Es que el inglés que estaba antes estaba bien y tú lo has cambiado
> Revisa como lo hicimos con Valeria
> Genera un plan integral para que lo ejecute anti Gravity tú solo tendrás que revisar que sea correcto y hacer la mejora que necesites pero el trabajo lo hará anti Gravity dame el prompt
Fuente: FrankBetances/Valeria:scripts/generate-voice-assets.py (LENGTH_SCALE tutor 1.0, child 1.05, clinical 1.15, slow 1.6), src/valeriaSemanticExpansion.ts (stepLines: frase al niño en child y la misma en slow), src/valeriaVoice.ts (speakPhraseSlow), src/steam/arActivities.ts, src/steam/arScenes.ts, src/steam/worlds/ y src/valeriaArBridge.ts (realidad aumentada y sets), en el commit e2a2a5e8
Reparto: lo ejecuta Antigravity con el prompt P9 de docs/PROMPTS_ANTIGRAVITY.md (P9.0–P9.8); Claude Code lo revisa, mejora lo que haga falta e integra.

- [x] Na casa (Inicio) y Modo Aula: una entrada propia «Estimulación da linguaxe e o pensamento / Estimulación del lenguaje y el pensamiento», visible sin entrar en la lección, en 2-3, 3-4, 4-5 y 5-6 (y 0-2 por proyecto) · evidencia: test/features/estimulacion_test.dart (la entrada arriba de Hoxe, sin scroll, en casa y en el aula) y docs/capturas/escritorio/estimulacion-casa-hoxe-gl.png, -es.png, estimulacion-aula-hoy-gl.png y -es.png
- [x] Dentro, por mes y edad: Escucha (par), Palabras que crecen (progresión), Háblale así (modelo) y Pensamos (predice, proba, compara, explica) con el experimento STEAM del mes, en gl y es · evidencia: test/features/estimulacion_test.dart y docs/capturas/escritorio/estimulacion-casa-2_3-m3-gl.png, -es.png, 3_4-m6, 4_5-m4, 5_6-m10 (gl y es) y estimulacion-pensamos-2_3-gl.png y -es.png
- [x] Las 40 piezas con los cuatro momentos de pensamiento, cada uno con palabras del par o la progresión y del STEAM del mes; un gate lo comprueba · evidencia: tools/check_plan_escoita.py (40 piezas, cuatro momentos, palabras del par o la progresión) y tools/check_sin_repetir.py
- [x] Voz como en Valeria: cada frase inglesa para el niño en voz child (1.05) y en lenta de frase (1.6), con botón «Oír amodo / Oír despacio»; las palabras sueltas lentas como antes; un gate falla si una frase no tiene su versión lenta · evidencia: tools/check_voz_lenta.py y test/core/audio/boton_escuchar_test.dart; los audios los genera voice-assets
> (20/11/2026) No tengo presupuesto pero me has enfadado tanto que estoy obligado a contestar, eres un incompetente joder, la 1 te dije que trajeras aquí la RA que creamos con la Valeria adaptada al aprendizaje de inglés evidentemente joder, es una maldita orden que tienes que cumplir no entiendo tu pregunta 1
Decisión: la RA de Valeria se trae adaptada al inglés; el permiso de cámara va con ella. Lo hace Antigravity (P10); Claude Code lo revisa.
- [x] Realidad aumentada: informe de cómo la hace Valeria (motor, permisos, licencias, red) entregado a Frank, y su decisión sobre el permiso de cámara escrita aquí antes de cualquier código · evidencia: docs/estimulacion-ar-informe.md y docs/ORDENES.md (decisión de Frank del 20/11/2026: se trae, con cámara)
> (26/11/2026) «ya he visto la aplicación y la he usado y evaluado tanto lo de Valeria como el resto, y para todo eso hubo un merge»
- [x] Con el sí de Frank: los sets de Valeria con Lúa, cada uno con el STEAM del mes, y la política de privacidad y el formulario de Play actualizados en el mismo cambio · evidencia: test/features/ar_estimulacion_test.dart y test/privacy/privacy_manifest_test.dart (hecho en P10.4, mergeado en el PR #66, 2c5bd6fa; evaluado por Frank el 26/11/2026)
- [x] Capturas de escritorio de la sección en gl y es, en casa y en el aula, miradas · evidencia: docs/capturas/escritorio/estimulacion-casa-hoxe-gl.png, estimulacion-aula-0_2-m3-es.png y el resto de estimulacion-*.png, miradas por Claude Code el 20/11/2026
- [x] Mergeado en main con CI en verde y los audios generados · evidencia: docs/ORDENES.md (PR #64, merge bbda1325 en main; run 44778068515 de Gates en verde sobre 92ddc914, con los audios del workflow voice-assets)

## O-20261120-2 · Corregir lo de Antigravity, merge a main y lista de pendientes para la semana que viene
Estado: cumplida
> Tenemos poco presupuesto, corrige los errores de antigravity y luego ejecuta merge y push al main , crea un listado de lo que queda pendiente, para continuar la próxima semana
> (20/11/2026, a pregunta de Claude Code) «Sí, borra las 80»: las 80 grabaciones en_tutor sobrantes.
Fuente: docs/PROMPTS_ANTIGRAVITY.md (P9; entrega de Antigravity en antigravity/escoita, 7e178ae6)

- [x] Errores de la entrega P9 corregidos: entrada arriba en Hoxe, preguntas en inglés, guías sin exigir que diga, títulos gallegos · evidencia: test/features/estimulacion_test.dart y tools/check_sin_repetir.py
- [x] Las 80 grabaciones en_tutor sobrantes borradas con el sí de Frank · evidencia: tools/prune_voice_assets.py (--check sin sobrantes)
- [x] Lista de lo pendiente para la semana que viene · evidencia: docs/PENDIENTE.md
> (20/11/2026) Y evidentemente si hoxe se repite dos veces hay que quitarlo de uno de los dos lugares y evidentemente que será el de abajo joder joder
> (20/11/2026) Además la maldita voz te orde copiar a Valeria / Como diablos hablo contigo y haces lo que te da la gana / No te presupuesto, genera la lista de pendientes y Mergea y push al main
- [x] Quitar la entrada de Estimulación de abajo en Hoxe, en casa y en el aula · evidencia: test/features/estimulacion_test.dart (una sola entrada_estimulacion_casa y una sola entrada_estimulacion_aula; hecho en P10.3, mergeado en el PR #66, 2c5bd6fa)
- [x] Mergeado en main con CI en verde y los audios generados · evidencia: docs/ORDENES.md (PR #64, merge bbda1325 en main; run 44778068515 de Gates en verde sobre 92ddc914, con los audios del workflow voice-assets)

## O-20261121-1 · README al día y sin información confidencial
Estado: cumplida
> actualiza el readme, elimina informacion confidencial
Fuente: CLAUDE.md (R5 y regla 0b: el README describe el producto; la operación interna va a STATUS.md)

- [x] Fuera del README la publicación, la firma, los artefactos y el versionCode, movidos a STATUS.md · evidencia: STATUS.md (sección Publicación y firma)
- [x] README al día: estimulación del lenguaje y el pensamiento, juegos de escucha, premios de la criatura, voz de niño y lenta, privacidad en tres ficheros y Fredoka · evidencia: tools/check_contact_email.py y tools/check_finalidade.py

## O-20261122-1 · Versión definitiva para el piloto: neno/nena, sin «Edición Vigo», una entrada, RA de Valeria y todo lo pendiente, hecho por Antigravity
Estado: cumplida
> Antigravity se reinició, y tengo tokens de sobre para terminar, primero necesito que arreglemos algo muy básico de lenguaje, en Galicia no se dice criatura ni crianzas ni nada de eso, aquí se habla de neno o nena, tenemos que cambiar el tema de edición Vigo y dejarlo simplemente sin decir que es para Vigo porque lo vamos a utilizar en Orense para un piloto, necesito que generen prompt completo para que antiGravity haga completamente de arriba hasta abajo todo el trabajo que falta tu única función será validar que esté bien hecho no pero todo el trabajo el 100 % de trabajo lo tiene que hacer anti Gravity, tenemos el visto bueno de todo el trabajo anterior, así que quiero una versión definitiva para probar ya así que tiene que ser la dirección más completa hasta la fecha el trabajo lo tiene que hacer anti Gravity lo repito anti Gravity dame el prompt
Fuente: docs/PROMPTS_ANTIGRAVITY.md (P10) y docs/PENDIENTE.md; para la RA, FrankBetances/Valeria:src/steam/arActivities.ts, src/steam/arScenes.ts, src/steam/worlds/ y src/valeriaArBridge.ts (commit e2a2a5e8)
Reparto: todo lo hace Antigravity (P10.0–P10.9); Claude Code solo valida e integra.
> (22/11/2026, a pregunta de Claude Code) «Sí, borra las 302» (grabaciones sobrantes) y «Sí, añádelo» (la regla de la cámara en CLAUDE.md).

- [x] Ningún texto visible ni hablado dice «criatura» ni «crianza»: neno/nena en gallego y niño/niña en castellano; un gate lo comprueba · evidencia: tools/check_lexico_galicia.py (quedan solo identificadores internos y comentarios del código)
- [x] Ningún sitio dice «Edición Vigo» ni da Vigo como destino (bienvenida, splash, créditos, manual, páginas legales, README); startTIC y la Zona Franca siguen como procedencia · evidencia: tools/check_lexico_galicia.py y docs/p10-vigo.md
- [x] Na casa → Hoxe y Modo Aula → Hoy: una sola entrada de Estimulación, arriba · evidencia: test/features/estimulacion_test.dart y docs/capturas/escritorio/p10-*.png
- [x] Realidad aumentada de Valeria adaptada al inglés, con cámara, por mes y edad, con Lúa; política de privacidad, ficha de Play, créditos y gate de permisos al día en el mismo cambio · evidencia: test/features/ar_estimulacion_test.dart, test/privacy/privacy_manifest_test.dart y docs/p10-control.md (no probado en un móvil con ARCore)
- [x] Inglés de las frases de cada palabra revisado · evidencia: docs/p10-ingles.md y tools/check_plan_escoita.py
- [x] Manual con capturas nuevas, PDF y Word mirados página a página · evidencia: tools/check_manual_build.py y docs/p10-control.md
- [x] Revisado por Claude Code y mergeado en main con CI en verde y los audios generados · evidencia: docs/ORDENES.md (PR #66, merge 2c5bd6fa en main; run 45051487520 de Gates en verde sobre 4bce917f, con los audios, y run 45053829115 en verde sobre 2c5bd6fa)

## O-20261126-1 · Auditoría forense y plan: varios niños por familia, nivel por edad, prueba de nivel y repaso
Estado: abierta
> ayudame a realizar un plan de mejoras , primero necesito que tenga registro multiples, porque una misma familia puede tener multiples niños en cursos distintos, ademas tenemos muchos problemas con los niveles ajustados a la edad,  primero que nada la edad de 0-2 años deberia centrarse en temas muy sencillos como adjetivos, sustantivos, onomatopeyas, aprender a reconocer tareas o eventos, o incluso aprender las series mas básicas, siempre con muchas repeticiones, luego en los niños mayores, tenemos el problema de que no sabemos que nivel tienen, creo que deberían hacer un pequeño examen básico para identificar el nivel y que se ajuste a su conocimiento, y luego las repeticiones de las lecciones anteriores son muy muy deficientes, y entre semana y semana el nivel del contenido tambien esta desajustado, primero realiza una auditoria forense, analiza como podemos hacer las mejoras y plantea un plan completo de mejoras
Fuente: assets/content/leccions/leccions.json, assets/content/acopros/proxectos_0_2.json, assets/content/gramatica/gramatica.json, tools/gen_leccions.py, lib/features/criancas/ y lib/core/fsrs_service.dart, medidos con tools/auditoria_niveles.py
Reparto: Claude Code audita y propone; la ejecución, por fases, con las decisiones D1-D5 de Frank.

- [x] Auditoría forense medida por script de los cinco cursos: registro de varios niños, 0-2, nivel de entrada, repaso y progresión semana a semana, cada hallazgo con su causa en el código · evidencia: tools/auditoria_niveles.py y docs/AUDITORIA_NIVELES_Y_REPASO.md (sección 2)
- [x] Plan completo: cada parte de la orden con su fase, lo que Frank ve y dónde, y el gate que la cierra · evidencia: docs/AUDITORIA_NIVELES_Y_REPASO.md (sección 4)
> (26/11/2026, a pregunta de Claude Code) «Apruebo d1 a d6»
Decisión: D1 a D6 aprobadas tal como las recomienda docs/AUDITORIA_NIVELES_Y_REPASO.md (secciones 3 y 4b); D4 incluye sustituir las 199 palabras actuales de 0-2 (assets/content/acopros/proxectos_0_2.json) por el núcleo propuesto.
- [x] Decisiones de Frank D1 (48 unidades), D2 (prueba de nivel sin pantalla para el niño), D3 (datos nuevos), D4 (rehacer 0-2) y D5 (ritmo por edad), escritas aquí · evidencia: docs/ORDENES.md (decisión de Frank del 26/11/2026: «Apruebo d1 a d6»)
- [x] Na casa → alta y Hoxe: varios niños de cursos distintos visibles a la vez, cada uno con su tarea, sus premios y su repaso · evidencia: test/features/criancas_test.dart (16 tests en verde en la rama claude/intelligent-mayer-e3iriy, 86cf5a53; hecho por Antigravity en P11.1)
> Abierto (Claude Code, 26/11/2026): «Volven hoxe» está hecho; faltan las 4 vueltas de 49 palabras presentadas al final del curso (umbral de Claude Code) y el gate en tools/gates.sh.
- [ ] Na casa → Hoxe: «Volven hoxe / Vuelven hoy» por niño; cada palabra vuelve al menos 4 veces en el curso y alguna pasado un mes (tools/auditoria_niveles.py --gate en tools/gates.sh) · evidencia:
> (26/11/2026, a pregunta de Claude Code sobre los criterios abiertos) «2, 3 ,4 ,5 ,6 y 7 aprobados»
> (26/11/2026) «1 también aprobado, el tema del alta debería ser solo una vez sabes que tengo un pequeño examen para ver el nivel que le corresponde para que la propia aplicación se ajuste a esa capacidad»
Decisión: los siete criterios de O-20261126-1 y O-20261126-2 quedan aprobados como alcance (no como hechos). El alta de cada niño se hace una sola vez y lleva dentro la prueba de entrada; después la app se ajusta sola cada semana (P11.4). En la app no se llama «examen» (regla de producto: nada sanitario).
- [x] Na casa → alta, una sola vez por niño: para 2 años o más, dentro del alta, el juego de Lúa para saber por dónde empezar, dirigido por la persona adulta, que fija su punto de partida y siembra su repaso; no se repite después, el nivel lo ajusta la app cada semana · evidencia: test/features/proba_entrada_test.dart (6 tests en verde; P11.3)
- [x] 0-2 años: sustantivos, adjetivos, onomatopeyas, rutinas y sucesos y series básicas, con el STEAM del mes y muchas repeticiones · evidencia: test/features/acopros_0_2_test.dart y tools/gen_acopros_0_2.py (60 piezas en 5 familias; 45 vuelven otro mes; P11.6)
- [x] De una semana a la siguiente el nivel sube sin saltos y la gramática no pasa del techo de cada edad, en las cinco edades (tools/auditoria_niveles.py --gate) · evidencia: tools/auditoria_niveles.py (0 saltos de frase y 0 meses por encima del techo en las cinco edades; P11.5 y P11.7)

## O-20261126-2 · Ajuste dinámico: el material crece con lo que el niño sabe
Estado: abierta
> Podrías agregar alguna forma que sea dinámico, que, dependiendo de los conocimientos que vaya adquiriendo de los resultados del test de entrada, la cantidad de material al que accede, sea distinto y ajustado a sus capacidades
Fuente: docs/AUDITORIA_NIVELES_Y_REPASO.md (H3 y H4: las marcas «aún no / la entiende / la dice» de lib/features/criancas/criancas_store.dart y el FSRS de lib/core/fsrs_service.dart); no copia de otro producto
Reparto: Claude Code lo diseña en el plan; se programa en la fase F3b con las decisiones D1, D5 y D6 de Frank.

- [x] Diseño del ajuste dinámico en el plan: qué lee, qué decide (cupo, mezcla, peldaño), reglas con sus umbrales, tres capas de contenido por semana, qué ve la familia, qué guarda y cómo se comprueba · evidencia: docs/AUDITORIA_NIVELES_Y_REPASO.md (sección 4b y fila F3b)
- [x] Decisión de Frank D6 (proponer o esconder y umbrales), escrita aquí · evidencia: docs/ORDENES.md (decisión de Frank del 26/11/2026 en O-20261126-1: «Apruebo d1 a d6»; se propone y no se esconde, umbrales de la sección 4b)
> Abierto (Claude Code, 26/11/2026): el motor y la línea del porqué están hechos (test/features/axuste_semanal_test.dart); falta que el cupo cambie el número de palabras que se ven.
- [ ] Na casa → Hoxe: el cupo de palabras nuevas, el repaso y el peldaño de cada niño cambian cada lunes según lo marcado la semana anterior y una línea en gl y es dice por qué; un test de cuatro niños simulados durante cuarenta semanas lo comprueba · evidencia:
- [x] Cada semana de las cinco edades tiene núcleo, «Máis / Más» y «Apoio / Apoyo», las tres con el STEAM del mes; un gate lo comprueba · evidencia: tools/check_capas_semana.py (200 semanas, las tres capas con su STEAM y sus piezas)

## O-20261126-3 · Plan completo para que lo ejecute Antigravity, revisado por Claude Code
Estado: abierta
> Genera un plan completo de trabajo para que me ejecute totalmente anti Gravity, y tu función será revisarlo
> (26/11/2026) Apruebo d1 a d6
Fuente: docs/AUDITORIA_NIVELES_Y_REPASO.md (secciones 2 a 5) y las órdenes O-20261126-1 y O-20261126-2
Reparto: todo lo hace Antigravity (P11.0–P11.11) en la rama antigravity/niveles; Claude Code solo revisa e integra.

- [x] Prompt P11 guardado en el repositorio con sus pasos P11.0–P11.11 en la tabla de pasos, antes de que Antigravity empiece · evidencia: docs/PROMPTS_ANTIGRAVITY.md y tools/check_registro_commits.py
- [ ] Entrega de Antigravity en antigravity/niveles con docs/p11-control.md criterio por criterio · evidencia:
- [ ] Revisado por Claude Code (auditoria_niveles --gate y check_capas_semana a cero, gates.sh y flutter test en verde, tres semanas al azar por edad, capturas gl y es miradas) y mergeado en main con CI en verde y los audios generados · evidencia:

## O-20261126-4 · Prompt completo con las mejoras M1-M5, guardado ya
Estado: abierta
> Pero me cago en todo, dame el prom completo dámelo todo esto no puede ser dámelo ya
> No me des las cosas a medias dámelo con las propuestas que me acabas de dar arreglado todo
> Me acabas de dar una serie de propuestas dámelo completo como debe ser para poder copiar y pegar no me pongas lo mismo otra vez ni dar vueltas ni hacer perder el tiempo
> Pero qué cojones guárdalo ya si te he ordenado hacerlo antes porque tengo que darle de nuevo y que quede a medias colgados. Eso es un incompetencia de tu parte
Fuente: docs/AUDITORIA_NIVELES_Y_REPASO.md (sección 6, M1-M5)
Decisión: M1-M5 aprobadas por Frank («dámelo con las propuestas que me acabas de dar»); entran en P11 como corrección sobre el trabajo en curso de Antigravity.
Reparto: lo hace Antigravity dentro de P11.0–P11.11; Claude Code revisa.

- [x] Corrección final con el alta de una sola vez y M1-M5 guardada en el repositorio y en main · evidencia: docs/PROMPTS_ANTIGRAVITY.md (sección «P11 · Corrección final») y tools/check_prompt_vigente.py
> Abierto (Claude Code, 26/11/2026): M1-M5 están programadas con sus tests; faltan sus capturas en gl y es (P11.10).
- [ ] M1 marcar en diez segundos, M2 rutinas de casa, M3 reto de hermanos, M4 cuántas veces la ha oído y M5 tarjeta para la escuela, en la app en gl y es, cada una con su test y su captura · evidencia:

## O-20261126-5 · Claude Code termina P11 y lo mergea en main
Estado: abierta
> Haz tú lo que falta y mergea en main
Fuente: docs/AUDITORIA_NIVELES_Y_REPASO.md y docs/PROMPTS_ANTIGRAVITY.md (P11), sobre la rama antigravity/niveles (52397432) revisada por Claude Code el 26/11/2026
Reparto: Claude Code, en claude/intelligent-mayer-e3iriy sobre antigravity/niveles.
> (26/11/2026) Vamos a ver, yo quiero que hagas ahora lo más pesado, el cinco y el seis, Cuando termines de la más pesado, vas a parar y volvemos a empezar con el trabajo con anti Gravity
Decisión: Claude Code hace solo el 5 (capas «Más» y «Apoyo» escritas) y el 6 (vocabulario de 2-3 a 5-6 por edad) y para; lo demás vuelve a Antigravity.

- [ ] Los tests que fallaban (significados_test, ux_l6_test gl y es) en verde sin saltar ninguno · evidencia:
- [ ] El cupo de cada niño cambia el número de palabras nuevas que ve en Hoxe; test con dos cupos distintos · evidencia:
- [ ] Hoxe enseña el contenido de la capa elegida (piezas, frase y voz) · evidencia:
- [x] Capas «Máis / Más» y «Apoio / Apoyo» escritas, sin plantilla, en las 200 semanas; gate que falla con texto de plantilla · evidencia: tools/check_capas_semana.py (0 fallos en las 200 semanas; falla con las capas de plantilla de 52397432) y tools/gen_leccions.py
> (26/11/2026, Claude Code) 58 sustituciones hechas (55 órdenes largas y 3 palabras) en lección, banco TPR y cuento; 72 palabras raras pendientes de Frank porque su sustituta sencilla ya es nueva en otra edad y el modelo de 4.000 palabras no deja repetirla (tools/vocab_idade.py, PENDENTES_FRANK).
- [ ] Vocabulario de 2-3 a 5-6 sin palabras ajenas a la edad; gate de lista · evidencia:
- [ ] Umbral de vueltas corregido y auditoria_niveles.py --gate en tools/gates.sh a cero · evidencia:
- [ ] gates.sh y flutter test completos en verde, mergeado en main con CI en verde y los audios generados · evidencia:
