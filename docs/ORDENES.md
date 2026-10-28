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
Estado: abierta
> la maldita estructura debe ser : Nivel A1 (Principiante / Acceso) [...] Nivel C1 (Dominio Operativo Eficaz) [48 puntos]

- [x] Los 48 puntos de Frank, en su orden, con su descripción · evidencia: tools/gen_gramatica.py
- [x] A1-A2 (1-20) en la columna de las cinco edades, sin bajar de una edad a la siguiente · evidencia: tools/gen_gramatica.py
- [x] Cada unidad trabaja un punto y cada semana tiene su frase con significado · evidencia: test/features/leccions/leccions_test.dart («cada unidade leva o seu punto de gramática…»)
- [x] B1-C1 para la persona adulta, con ejemplo · evidencia: test/features/leccions/leccions_test.dart («a gramática do curso, a 360 px e escala 1.8»)
- [ ] Las frases nuevas tienen su voz · evidencia:
- [ ] Se ve en Na casa → Hoxe, en gl y es · evidencia:

## O-20261028-4 · Hoy de las familias: claro, sin ruido, con UX validada
Estado: abierta
> para los padres sigue sin entenderse nada es un mix sin sentido, he probado en 4-5 años [...] se repiten las mismas palabras por trimestres [...] la UI UX de los padres es un desastre esta llena de ruido e información que no hace falta, es un scroll infinito que no se entiende, tampoco se entiende las unidades, no sabe de lo que se habla ni hacia donde va
> busca en GitHub todas las UX-UI que funcionan para nuestro caso y adaptalas, no inventes nada

UX de referencia, de código abierto: Bebbo (UNICEF, GPL-3.0, 0-6 años; portada con la etapa de la criatura y una tarjeta diaria de un juego y una lectura) y Oppia Android (tema → lista de lecciones con estado y la siguiente).

- [ ] Na casa → Hoy, 4-5 años: la etapa (edad, unidad n de 10 con su tema y barra), las palabras de la semana, la gramática en una línea y lo de hoy caben en la primera pantalla de 412×915, sin bajar · evidencia:
- [ ] Hoy tiene una sola tarjeta «Hoy» con una cosa que hacer (Bebbo) · evidencia:
- [ ] La unidad es una lista de 4 lecciones con su estado y dice cuál viene después (Oppia) · evidencia:
- [ ] En Hoy no hay ninguna palabra de otro trimestre · evidencia:
- [ ] Lo complementario no ocupa Hoy: queda plegado al final · evidencia:
- [ ] Visto en la app de escritorio por Na casa → Hoy, en gl y es · evidencia:

## O-20261028-5 · Replicar la UX de los repositorios de GitHub que da Frank
Estado: abierta
> Específicos para niños: phonics-app, 453★ [...] Kids Zone, 12★ [...] yarareads, 29★, MIT [...] s5s5/phonics, MIT [...] buzzphonics, 63★, MIT [...] Adaptables, con muy buena UI: duolingo-clone, 691★, MIT y activo (Next.js y Tailwind). Es la mejor base para montar un "Duolingo para niños". react-duolingo, 471★, MIT.

Límites que Frank conoce: phonics-app sin licencia y Kids Zone con licencia que impide competir: de esos se toma solo la UX visible, no el código. Los infantiles los usa la criatura; aquí la pantalla la usa la persona adulta.

- [ ] Las unidades se ven como el camino de duolingo-clone / react-duolingo: cabecera de unidad y lecciones en fila, con la actual resaltada y las siguientes por delante · evidencia:
- [ ] Al tocar una palabra se oye y se ve su significado (como yarareads al tocar) · evidencia: test/features/leccions/leccions_test.dart («todo o inglés das leccións leva o seu significado…»)
- [ ] Visto en la app de escritorio por Na casa → Hoy, 4-5 años, en gl y es · evidencia:

## O-20261028-6 · Progresión real y la unidad de la semana a la vista
Estado: abierta
> revisa que realmente las unidades estén donde tienen que estar que exista una progresión real, no me engañes otra vez, cuando termines de revisar además pon el título que corresponde a la unidad porque hace falta saber de qué va la unidad, que si hay 48 malditas unidades [...] pongas la maldita unidad que se está tratando en la maldita semana [...] si es sustantivo adjetivo o lo que toque [...] después arregla la maldita ux UI con los fucking ejemplos que te di ya para copiar de GitHub, cuando tengas todo hecho [...] y revisado que realmente funciona, pues mergealo todo ya

- [ ] Revisión con datos: las 20 unidades A1-A2 van en orden ascendente a lo largo de los 50 meses, sin volver atrás · evidencia:
- [ ] En la semana se ve, arriba y en grande, la unidad de las 48 que se trabaja: número, título y qué es (sustantivo, adjetivo, verbo…) · evidencia:
- [ ] La UX de Hoy sigue duolingo-clone (franja de unidad y lecciones en zigzag) · evidencia:
- [ ] Visto en la app de escritorio por Na casa → Hoy, 4-5 años, en gl y es · evidencia:
- [ ] Todo mergeado en main con CI en verde · evidencia:
