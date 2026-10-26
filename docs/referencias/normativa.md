# Marco normativo del inglés en la app

**Pendiente de contrastar con el DOG.** Todo lo de esta página sale del texto
curricular que aportó Frank (`referencias/base/curriculo-ingles-infantil-galicia.txt`),
que cita el Decreto 150/2022 y la Orden de 30 de mayo de 2023. El Diario
Oficial de Galicia no es accesible desde el entorno donde se hace la app, así
que ningún dato está contrastado con el texto oficial. Frank lo decidió así (P6
de `docs/PLAN_DE_TRABAJO.md`): los criterios se pintan del texto, con el aviso.

Los datos viven en `assets/content/curriculo/normativa.json`. Las pantallas los
leen de ahí, no de los widgets.

| Dato | Qué dice el texto | Línea |
| --- | --- | --- |
| Área | Área de Comunicación y Representación de la Realidad | 5 |
| Saber básico | «Aproximación á lingua estranxeira. Elementos para unha comunicación funcional básica.» | 46 |
| 1.º ciclo, encuadre | Bloques 1 y 2 del área | 18 |
| 1.º ciclo, horario | Sin asignación horaria específica | 21 |
| 2.º ciclo, encuadre | Bloque 2: As linguas e os seus falantes | 19 |
| 2.º ciclo, horario | Un periodo lectivo semanal, en una sesión o en dos medias sesiones | 22 |
| Criterio CA2.7 | «Participar en interaccións comunicativas en lingua estranxeira relacionadas con rutinas e situacións cotiás» (OBX5) | 43 |
| 0-3 años | OBX1 y OBX2; criterio operativo: reacción orientativa motriz ante canciones y estímulos sonoros, imitación gestual en el juego de crianza | 59-61 |
| 3-4 años | OBX5; CA2.7: respuesta física total (TPR) a instrucciones del docente y canciones con mímica | 62-65 |
| 4-5 años | OBX5; CA2.7: comprensión y reproducción de estructuras sencillas y fórmulas de cortesía en las rutinas | 66-69 |
| 5-6 años | OBX5; CA2.7: uso espontáneo de léxico funcional en juegos de simulación e intervenciones en asamblea | 70-73 |

## Lo que no pasa a la app

Lo deja fuera `referencias/base/ERRATAS.md`:

- lo que el texto atribuye a la Inspección (líneas 75-77 y 90), porque no trae
  fuente primaria;
- la rúbrica de las líneas 123-142, porque evalúa a cada criatura y la app no
  guarda nada de ninguna;
- la duración de las medias sesiones (línea 84), porque es una inferencia.

## Lo que queda por contrastar

- Que el criterio sea CA2.7. Las cápsulas de Academy citan CA1.1 y CA3.1 en sus
  datos; no se ha tocado ninguna de las dos cosas hasta tener el DOG.
- La denominación exacta del área y del bloque.
- El horario del 2.º ciclo (artículo 3 de la Orden).
