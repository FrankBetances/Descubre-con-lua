# Fe de erratas de los textos de base

Módulo M1.2 del plan docente. Qué no puede pasar de estos cinco textos al
contenido de la app tal como está escrito, y con qué se sustituye. Las líneas
son las del fichero de esta carpeta.

**Qué hace cada etiqueta en la columna «Tipo»:**

- **error**: es incorrecto y se corrige al llevarlo al JSON;
- **contradicción**: choca con otro texto o consigo mismo, y la arquitectura
  dice cuál vale;
- **fuera**: choca con las reglas de la app y no entra;
- **por verificar**: cifra o cita que no se ha contrastado con su fuente; no se
  pinta hasta contrastarla.

## En los cinco

| Tipo | Qué pasa | Qué se hace |
| --- | --- | --- |
| error | Números de nota pegados a las palabras («unidad17», «aula1») y, en algunos sitios, restos de herramienta como «[cite: 8, 13]» | Se quitan al copiar cualquier frase |
| error | Fórmulas y símbolos perdidos al copiar: huecos en blanco donde había una fórmula o un tamaño de efecto | No se reconstruyen; no pasan a la app |
| por verificar | Las listas de «Obras citadas» mezclan artículos con blogs, foros y webs comerciales | Solo se cita lo que se haya leído en la fuente |
| fuera | Lenguaje clínico: «diagnóstico», «mutismo», «intervención», «silencio clínico», «logopedia», TDL, SAAC | La app no es sanitaria. En el JSON se habla de «espera», «respuesta de la criatura» y «persona adulta» |

## `curriculo-ingles-infantil-galicia.txt`

| Línea | Tipo | Qué pasa | Qué se hace |
| --- | --- | --- | --- |
| 39, 47, 49, 51 | error | «[cite: …]» sueltos | Se quitan |
| 43 | por verificar | Dice que el criterio es **CA2.7**. Las asambleas de la app citan CA1.1 y CA3.1 | M1.1: se contrasta con el Decreto 150/2022 antes de pintar ningún código |
| 84 | por verificar | Las medias sesiones «de 25 a 30 minutos» son una inferencia del texto, no una cifra de la Orden | No se pinta como norma |
| 75-77, 90 | por verificar | Afirmaciones sobre lo que la Inspección «rechaza de forma sistemática», «jurisprudencia» y lo que «carece de fundamento legal» en 0-3, sin fuente primaria | No pasan a la app |
| 123-142 | error · fuera | La rúbrica usa «En proceso / Sin dificultad / Plena adquisición», que no es la escala SD / EP / CD que el propio texto cita (115-118), y le falta CD. Además, es una evaluación por criatura | No entra |
| 154 | error | La referencia 4 se titula «Decreto 150/2022», pero su enlace es el DOG del 13/6/2023, la Orden | Se cita por la Orden |

## `curriculo-vocabulario-infantil-2-6.txt`

| Línea | Tipo | Qué pasa | Qué se hace |
| --- | --- | --- | --- |
| 1 / 9 | error | El título dice «2 a 6 años» y el primer tramo empieza a los 18 meses | Se habla de «18 meses a 6 años» |
| 20-127 | contradicción | «Seis unidades bimestrales» de seis semanas. La unidad 5 (mayo-junio) y la 6 (junio-julio / inicio de curso) se solapan y se salen del curso | Manda el calendario de 10 meses de la app (arquitectura, apartado 3) |
| 27 | error | Contraste /ɪ/ de *fish* con /iː/ de *sea*, y *sea* no está en el vocabulario | Contraste entre palabras del núcleo o del registro |
| 90 / 99 | contradicción | El objetivo es /ʊ/ de *foot* frente a /uː/ de *boot*; la focalización trabaja /ʌ/ de *rub*. Ninguna de las tres está en el vocabulario | Un solo contraste, con palabras que estén |
| 111 / 120 | contradicción | El objetivo es *dog* frente a *duck*; la focalización compara *dog* y *cat* | Igual |
| 29, 31, 50-54, 141 | error | Transcripción británica (/bəʊt/, /stəʊn/, /ɡəʊ/, /drɒp/) mezclada con rótica (/ˈwɔːtər/). La voz de la app es americana | Transcripción americana: /boʊt/, /stoʊn/, /ɡoʊ/, /drɑp/, /ˈwɑtɚ/ |
| 132 | fuera | Contraste /ɒ/ de *box* frente a /ɔː/ de *ball*: en inglés americano no existe así | No entra |
| 261 | error | «Segmentar palabras polisilábicas aislando cada fonema en palabras monosilábicas»: se contradice | Se reescribe: segmentar palabras de una sílaba (*boat*: /b/-/oʊ/-/t/) |
| 176 | fuera | «Say: 'Help me, please!'» pide a la criatura que lo diga | La adulta dice «Help me, please!» con la pieza en la mano y espera |
| 180, 334 | fuera | El paso *Repeat* de PEER: «Can you say: on the bridge?», «Can you say jumping frog?» | Se cambia por **retomar**: la adulta vuelve a decir la frase y deja el hueco |
| 217 | fuera | La pregunta de distanciamiento lleva al pediatra («Do you remember when we went to the pediatrician?») | Otra experiencia de casa que no sea sanitaria |
| 252 | fuera | El guion usa nombres de criaturas (Daniel, Lucas) | Los guiones de la app no llevan nombres |
| 291-322 | fuera | Horario de 09:00 a 13:00 con todo en inglés: choca con el período semanal del 2.º ciclo y con el «sin franja» del 1.º | No entra |
| 350-389 | fuera | Rúbrica de cuatro estadios por criatura, escala de turnos y registro anecdótico rotativo | No entra: de la criatura no se guarda nada |
| 4 | error | «Neurológicamente inertes»: exagera lo que dicen los estudios sobre pantallas | No se dice así en la app |
| 5 | error | Llama «metaanálisis» a Thieme et al. (2022); la referencia 9 es una revisión sistemática | Revisión sistemática |
| 10, 285 | por verificar | El 80 % de las órdenes y las «15-20 activaciones por jornada», con reactivación en las semanas 6 y 10, se atribuyen a SparkLing sin cita exacta | El 80 % solo se explica, no se calcula; las cifras no se pintan |

## `biblioteca-cuentos-dialogicos-bilingues.txt`

| Línea | Tipo | Qué pasa | Qué se hace |
| --- | --- | --- | --- |
| 155-166 | error | La fórmula del «espacio narrativo» se perdió al copiar. Con los tamaños de los módulos (8 × 5 × 8 × 4) salen 1.280 combinaciones | No pasa a la app: combinar no garantiza un buen cuento |
| 195-201 / 355 | error | **HIS-001** son dos cuentos: el del baño con el pato (matriz) y el del mar con el pez | Cada microcuento lleva un identificador propio del contenido de la app |
| 45 / 357 | contradicción | El cuento de 2-3 años usa ESC-06 (el mar), que el propio texto reserva para 3-6 | Escenario de su edad, o el cuento cambia de cohorte |
| 162 / 393 | error | HIS-008 se resuelve con «ayuda zoológica colaborativa», que no está entre los modos de resolución del texto | Uno de los modos definidos |
| 361, 371, 326 | error | El título dice pez azul; en la lámina 1 asoma una aleta amarilla, en la 2 es azul y amarillo y el guion dice *yellow fish* | Un solo color en el encargo de la lámina y en el guion |
| 178-179 | contradicción | La regla de 1-2 palabras (2-3 años) y de 3-4 (4-6) no la cumplen los propios cuentos modelo: el de 4-6 trae más de diez expresiones | La frase de Lúa sale del núcleo de la unidad |
| 266 | error | Dice que CROWD «se concibió para evaluar»: son tipos de pregunta de la lectura dialógica. Además, su gradación en tres niveles no es CROWD | En la app se llama **tríada** (señalar, imitar, acercar); CROWD se reserva para la lectura en casa |
| 266, 310, 316 | fuera | «Mutismo selectivo inducido», «latencia electrofisiológica» y una columna «Diagnóstico lingüístico» | No entra; la columna es «Respuesta de la criatura» |
| 330 | fuera | «¡Sí, que lindo can!» mezcla castellano y gallego, y acaba en «Say hello to the dog: Hello!», que pide decirlo | «¡Sí, un can!» o «¡Sí, un perro!» según la lengua, y «A happy dog! Hello, dog!» |
| 376 | error | El nivel 3 («Is it big like an elephant or small?») compara, no acerca la escena a la vida de la criatura | «Do you splash in the bath, like the little fish?» |
| 422 | error | Igual («Are squirrels fast animals or slow animals?») | «Do you see squirrels in the park?» |
| 390-435 | error | El cuento 2 está entero en castellano: falta el gallego | Se escribe el gallego, título incluido |
| 404, 414 | contradicción | «5 segundos de cronómetro», «5 segundos exactos» | Espera visual y silenciosa en tres tiempos (arquitectura, apartado 7) |

## `estrategias-apoyo-linguistico.txt`

| Línea | Tipo | Qué pasa | Qué se hace |
| --- | --- | --- | --- |
| 2-7, 212-214 | por verificar | La evidencia es de intervención clínica (TDL, AAC, Hanen, EMT, recasts en terapia) aplicada a criaturas que aprenden inglés sin dificultad | Se usa como práctica de aula, sin cifras de eficacia |
| 7 | error | Tamaños de efecto perdidos al copiar | No se citan |
| 26 | error | «Can the boy not jump over the bench?» no es un inglés natural | «The boy can't jump? Oh, the boy can't jump over the bench.» |
| 37-39 | fuera | «tat → cat»: es un proceso fonológico clínico (frontalización velar) | No entra |
| 65 / 263 | contradicción | El recast va «en los dos primeros segundos» y el Wait Time 2 pide «tres segundos de silencio antes de cualquier comentario» | Espera en tres tiempos: callar, recast en el turno siguiente y otra espera antes del elogio |
| 75 / 83-108, 126 | contradicción | Define la expansión como solo gramática, pero sus ejemplos añaden contenido y se saltan su propia regla de +1/+2 («Water» → «You want to drink some cold water») | +1/+2: «Water» → «Cold water» o «Water, please»; «Truck go» → «The truck goes»; «Shoe» → «Your shoe»; «Bird» → «A little bird»; «Ball» → «The red ball»; «More» → «More playdough»; «Horse run» → «The horse is running» |
| 162-182 | contradicción | Las frases de habla paralela pasan de doce palabras y el mismo texto pide frases cortas (201) | Frases cortas: «You put the red block on top», «You wash your hands», «You fill the bucket» |
| 211 | error | Llama «umbral neurofisiológico» a lo que en Rowe es una medida de conducta en el aula | No se dice así |
| 300 | fuera · por verificar | «Una o dos reformulaciones por minuto en sesiones de 15-20 minutos» es una dosis clínica | No entra |
| 3, 208 | fuera | «Regla del silencio clínico» | Se llama **espera** |
| 307 (ref. 5) | error | Un foro de Reddit citado como fuente | No se cita |

## `rutinas-sparkling-sintesis.txt`

| Línea | Tipo | Qué pasa | Qué se hace |
| --- | --- | --- | --- |
| 1 | error | Se titula «Manual de Operaciones … SparkLing™ (UW I-LABS)», pero es una síntesis, no un documento de esa institución | Se cita como síntesis. El nombre del fichero ya no lleva el de la institución |
| 33-34 | por verificar | 45 minutos «exactos», «tres tutores certificados», grupos de 14 a 20 | No entra: choca con el horario gallego y con una sola adulta |
| 64, 108, 128, 131 | fuera | Saluda y llama a cada criatura por su nombre | La app no pide ni guarda nombres; lo que haga la adulta en la sala es cosa suya |
| 63 | fuera | Marioneta-ancla como reclamo para la criatura | Lúa es la guía de la adulta, no un reclamo |
| 72 | contradicción | «Good pointing!» al instante choca con la espera antes del elogio | Espera en tres tiempos |
| 74 | fuera | «Can we all say: bunny?» | Retomar, sin pedir que lo digan |
| 136, 151 | por verificar | Tono +100-150 Hz y parentese durante «más del 80 % de la sesión» | No se pintan |
| 103, 140, 166 | error | «Inmunes al olvido», mielinización atribuida a los turnos, crecimiento «exponencial» | No se dice así |
| 31, 166 | fuera | Registro con LENA y pruebas CCT | No entra: de la criatura no se guarda nada |
| 163-164 | fuera | Inmersión sin pasar nunca a la lengua de casa | No entra (D2: translanguaging) |
| 185 (ref. 17) | error | Enlace a una web que, por su URL, parece una copia no autorizada de un libro | No se cita |
