# DOCUMENTO MAESTRO DE SALVAGUARDA PEDAGÓGICA Y TÉCNICA STEAM + L2
## Base Curricular para la Integración en «Descubre con Lúa» (Edición Vigo)

> **Destino:** Repositorio oficial `Descubre con Lúa` (App Flutter Android)  
> **Rama destino:** `steam` (derivada de `origin/main`, sin tocar `main`)  
> **Ámbito de aplicación:** Escuelas infantiles municipales de Vigo (Aula / *Juega con Lúa*) y hogares (Familias / *Academy*)  
> **Idiomas de mediación:** Gallego (`gl`, lengua vehicular oficial) y Castellano (`es`)  
> **Idioma de estímulo infantil:** Inglés (L2), **100% auditivo y cinestésico (Respuesta Física Total / TPR)**. Cero texto en inglés visible para la criatura.

---

## 🏛️ 1. Matriz de los 16 Marcos Abiertos Integrados

Esta base pedagógica sintetiza los 10 marcos originales de referencia internacional y 6 repositorios complementarios de código abierto:

| # | Repositorio / Marco | Enfoque Pedagógico Principal | Qué se Extrae e Integra en Descubre con Lúa |
| :- | :--- | :--- | :--- |
| **1** | **UNICEF/accessible-digital-textbooks-content** | Educación inclusiva y accesibilidad universal sin destreza fina digital. | Modelado formal de actividades sensoriales accesibles; graduación funcional según desarrollo motriz real sin tocar pantallas. |
| **2** | **oppia/oppia** | Ciclo de indagación guiada y Exploration State Machine. | Estructura interna atómica de cada experiencia: **Observa** (disparador y pausa socrática) ➔ **Experimenta** (consigna reproducible y pistas N1/N2) ➔ **Construye** (síntesis y Make tangible). |
| **3** | **fossasia/pslab-android** | Indagación científica de física cotidiana en el entorno real. | Banco de instrucciones paso a paso de fenómenos analógicos (acústica, óptica, movimiento, materia) prescindiendo de sensores electrónicos. |
| **4** | **open-learning-exchange/planet (OLE Planet)** | Recursos educativos abiertos (OER) para baja conectividad y aula comunitaria. | Estructura de metadatos: inventario físico accesible/reciclado, tiempos reales de atención (8–22 min) e indicadores cualitativos. |
| **5** | **CS-Unplugged/cs-unplugged** | Pensamiento computacional y modelado lógico sin pantallas. | Respuesta Física Total (TPR): órdenes corporales, patrones rítmicos, algoritmos motrices y saltos en cuadrícula física en el suelo. |
| **6** | **microbit-foundation/microbit-curriculum** | Retos de diseño y construcción tangible con materiales cotidianos. | Fase Make (Construye) basada en ensamblaje físico con cartón, pinzas y material reciclado con anticipación causal previa. |
| **7** | **turingway/the-turing-way** | Cultura de reproducibilidad científica paso a paso en texto plano. | Documentación atómica: hipótesis previa ➔ manipulación estandarizada ➔ registro empírico sin ambigüedad para el adulto. |
| **8** | **scratchfoundation/scratch-curriculum-guide** | Aprendizaje creativo por proyectos (Mitchel Resnick / ScratchJr). | Mediación lúdica adulta sin pantallas mediante roles físicos (tarjetas colgadas al cuello: *Programador/Robot*) y tarjetas de comando motriz. |
| **9** | **freeCodeCamp/curriculum** | Desglose atómico de conceptos en retos secuenciales unitarios. | Estructura desacoplada: contexto, consigna unívoca, pistas graduales (Nivel 1: Socrática; Nivel 2: Modelado físico) y criterio de logro binario. |
| **10** | **World-Bank-Open-Learning/smart-data-hub** | Indicadores de desarrollo infantil temprano (ECD) de 0 a 6 años. | Calibración estricta de estadios madurativos (Cursos `curso_0_2` a `curso_5_6` equivalentes a I1–I5). Prohibido exigir motricidad fina compleja antes de tiempo. |
| **11** | **miczflor/rpi-jukebox-rfid & scanner-soundboard** | Audio físico tangible de baja latencia (<80 ms) sin interfaz gráfica. | Disparo de estímulos acústicos en inglés nativo mediante interacción táctil directa, eliminando la pantalla para el menor. |
| **12** | **beyarkay/card_game_builder & flashcards** | Pipeline automatizado de material imprimible (*Zero-Manual Layout*). | Fichas imprimibles a doble cara con marcas de corte milimétricas para docentes y familias sin diseño manual. |
| **13** | **obserfy/obserfy** | Registro observacional de un solo toque (*1-Tap Logging*). | Matriz de evaluación cualitativa con 3 estados rápidos: `[L]` Logrado (autónomo), `[A]` Asistido (andamiaje físico), `[E]` Explorando (manipula sin discriminación aún). |
| **14** | **DHarrisDevelop/cs4earlyhomeschool** | Informática desenchufada para el hogar y prelectores. | Estilo de redacción de micro-scripts de facilitación para familias sin formación técnica, conectando objetos del salón con conceptos lógicos. |
| **15** | **codeorg/curriculum (CS Fundamentals Unplugged)** | Algoritmos kinestésicos y persistencia infantil ante el error. | Pautas de "debugging corporal" (revisar el paso anterior bailando o retrocediendo) eliminando cualquier refuerzo negativo o frustración. |
| **16** | **KDE/gcompris** | Suite educativa abierta multiplataforma. | Taxonomía de mecánicas de descubrimiento físico: balanzas de palanca, mezclas de luz y color, propagación acústica y texturas hápticas. |

---

## 🚫 2. Los 4 Pilares Innegociables de Producto

1. **Cero Pantallas para el Menor (*Zero-Screen Child Interaction*)**:
   - El niño **jamás toca ni mira la pantalla**. La experiencia infantil es 100% analógica, manipulativa, sensorial, motriz y acústica.
   - El dispositivo móvil (en asamblea o en casa) es **exclusivamente una partitura visual y disparador auditivo para la persona adulta mediadora**.
2. **Formulación Unívoca y Acción Física Directa**:
   - Las consignas para la persona facilitadora se redactan en modo directo e imperativo, libres de abstracciones teóricas (*"Sostén la taza...", "Suelta la pelota...", "Canta pegado a la membrana..."*).
3. **Rigor Neuroevolutivo Estricto (I1 a I5 / Cursos 0 a 6 años)**:
   - Todo reto debe adecuarse a la ventana madurativa real del Banco Mundial.
   - **Prevención de asfixia en menores de 3 años (`curso_0_2` y `curso_2_3`)**: todos los materiales manipulativos propuestos deben superar obligatoriamente los **4 cm de diámetro**.
4. **Muro Regulatorio Educativo (Cero Patología)**:
   - Lenguaje estrictamente pedagógico y del neurodesarrollo. Prohibición absoluta de términos clínicos, diagnósticos o terapéuticos (*trastorno, patología, síntoma, déficit, paciente, terapia, dislalia, dislexia, rehabilitación*).

---

## 📋 3. Banco Completo de las 5 Unidades STEAM Canónicas

Cada unidad implementa el ciclo tripartito de Oppia (**Observa ➔ Experimenta ➔ Construye**) y el andamiaje gradual de FreeCodeCamp.

---

### UNIDAD I1 (`curso_0_2`: 12 a 24 meses) · MATERIA Y TEXTURAS
- **ID:** `I1-MATERIA-001`
- **Fenómeno:** Materia, densidad perceptible, contrastes táctiles y cinemática de caída suave.
- **Justificación neuromadurativa:** Estadio sensoriomotor puro; prensión palmar, pinza gruesa en desarrollo, exploración táctil activa, causa-efecto inmediata y seguimiento visual de trayectorias verticales.
- **Tiempo estimado:** 10 minutos.
- **Materiales (seguridad >4 cm):**
  - Pelota de lana compacta o pompón textil suave (> 6 cm de diámetro) — 1 unidad.
  - Bloque de madera maciza con bordes redondeados (> 5 cm de arista) — 1 unidad.
  - Cesta baja de mimbre o plástico resistente — 1 unidad.
- **Foco TPR motor corporeizado:** La criatura aprieta ambos objetos con las palmas para percibir resistencia/deformación, y los suelta desde la altura del pecho hacia la cesta para contrastar velocidad y sonido del impacto.
- **Ciclo didáctico:**
  - **Observa:**
    - *Planteamiento:* La persona adulta sostiene la pelota de lana en una mano y el bloque de madera en la otra a la altura de los ojos de la criatura.
    - *Pregunta de indagación:* «¿Cuál se esconde si lo apretamos fuerte con la mano? (Pausa de 5 segundos de espera y observación)».
  - **Experimenta:**
    - *Consigna adulto:* Entrega primero la pelota de lana para que la criatura la presione. Luego entrega el bloque de madera para notar la solidez. Di en voz clara: «Soft... /sɑːft/» al tocar la lana y «Hard... /hɑːrd/» al tocar la madera.
    - *Pista N1 (Socrática):* «Mira cómo se aplasta la pelota suave. ¿Puedes apretar el cubo de madera igual?».
    - *Pista N2 (Modelado físico):* La persona adulta coloca sus manos sobre las de la criatura y ayuda a presionar ambos objetos sucesivamente modelando la fuerza de agarre.
  - **Construye (Make):**
    - *Reto tangible:* La criatura deja caer primero la lana y luego la madera dentro de la cesta escuchando la diferencia del impacto. La persona adulta emite la orden TPR: «Drop! /drɑːp/».
    - *Síntesis de cierre:* «¿Cuál hizo ruido al caer en la cesta? ¿El suave o el duro?».
- **Evaluación formativa (1-Tap):**
  - *Criterio de logro:* La criatura presiona activamente ambos objetos y los suelta hacia la cesta respondiendo al estímulo gestual y acústico de caída.
  - *Observación cualitativa:* Registrar `[L]` (suelta y discrimina textura de forma autónoma), `[A]` (requiere modelado físico de la mano adulta), o `[E]` (explora o lanza sin discriminar resistencia).

---

### UNIDAD I2 (`curso_2_3`: 24 a 36 meses) · CINEMÁTICA Y PLANOS INCLINADOS
- **ID:** `I2-CINEMATICA-001`
- **Fenómeno:** Cinemática básica, gravedad, aceleración en plano inclinado y rodar frente a deslizar.
- **Justificación neuromadurativa:** Bipedestación y marcha afianzadas, prensión digital básica, comprensión espacial de arriba/abajo e inclinación, anticipación motriz del movimiento lineal.
- **Tiempo estimado:** 15 minutos.
- **Materiales (seguridad >4 cm):**
  - Plancha rígida de cartón grueso de 60x30 cm — 1 unidad.
  - Caja de zapatos o apoyo para inclinar el plano — 1 unidad.
  - Cilindro de cartón resistente (> 4.5 cm de diámetro exterior) — 1 unidad.
  - Bloque rectangular de madera o esponja densa (> 5 cm de base) — 1 unidad.
- **Foco TPR motor corporeizado:** La criatura coloca los objetos en la parte alta de la rampa, suelta sin empujar y corre hacia el final para atrapar el cilindro rodante antes de que se detenga.
- **Ciclo didáctico:**
  - **Observa:**
    - *Planteamiento:* La rampa de cartón se apoya sobre la caja formando un plano inclinado de 30 grados. En la cima reposan el cilindro y el bloque.
    - *Pregunta de indagación:* «¿Cuál llegará antes al suelo si los soltamos a la vez sin empujar? (Pausa de 5 segundos de espera y anticipación visual)».
  - **Experimenta:**
    - *Consigna adulto:* Coloca el cilindro arriba y di: «Roll! /roʊl/». Suéltalo para que ruede. Luego coloca el bloque plano y di: «Slide! /slaɪd/». Observa cómo el bloque se frena mientras el cilindro vuela.
    - *Pista N1 (Socrática):* «Mira la forma redonda del tubo. ¿Por qué el tubo sigue corriendo y la caja se queda parada?».
    - *Pista N2 (Modelado físico):* La persona adulta sostiene la mano de la criatura sobre la parte superior del cilindro en la rampa, retira la mano conjuntamente y señalan la trayectoria exclamando: «Fast! /fæst/».
  - **Construye (Make):**
    - *Reto tangible:* La criatura coloca dos libros debajo de la rampa para darle más altura y repite la carrera comprobando si el cilindro rueda aún más rápido.
    - *Síntesis de cierre:* «Cuando la rampa está más alta, ¿el tubo corre más rápido o más lento?».
- **Evaluación formativa (1-Tap):**
  - *Criterio de logro:* La criatura anticipa que el cuerpo cilíndrico rodará velozmente mientras el prisma plano deslizará con fricción, situándose al final de la rampa para frenarlo.
  - *Observación cualitativa:* Registrar `[L]` (anticipa trayectoria y coloca en la rampa sin empujar), `[A]` (necesita ayuda para sostener el plano inclinado), `[E]` (empuja con fuerza sin observar el efecto de la gravedad).

---

### UNIDAD I3 (`curso_3_4`: 3 a 4 años) · ACÚSTICA, MEMBRANAS Y VOZ
- **ID:** `I3-ACUSTICA-001`
- **Fenómeno:** Acústica tangible, propagación de ondas mecánicas en el aire, vibración de membranas elásticas y resonancia laríngea.
- **Justificación neuromadurativa:** Coordinación bimanual consolidada, discriminación auditiva de tono e intensidad, función simbólica y percepción cinestésica de la propia fonación en el cuello.
- **Tiempo estimado:** 18 minutos.
- **Materiales:**
  - Taza o cuenco cerámico pesado — 1 unidad.
  - Membrana elástica de látex (globo cortado tensado en la boca de la taza) fijada con goma ancha — 1 unidad.
  - Granos de arroz seco crudo — 15 a 20 granos.
  - Tubo de cartón de cocina de 20 cm — 1 unidad.
- **Foco TPR motor corporeizado:** La criatura apoya las yemas de los dedos sobre la base de la taza, acerca la boca al tubo de cartón y emite sonidos graves y agudos para sentir la vibración laríngea y ver saltar los granos.
- **Ciclo didáctico:**
  - **Observa:**
    - *Planteamiento:* Sobre la membrana elástica tensa reposan los granos de arroz completamente inmóviles.
    - *Pregunta de indagación:* «¿Cómo podemos hacer bailar al arroz sin tocar la taza ni soplar con viento? (Pausa de 5 segundos de silencio clínico)».
  - **Experimenta:**
    - *Consigna adulto:* Acerca el tubo a 2 cm de la membrana sin tocarla. Pon tu mano en tu garganta, canta una nota grave muy profunda: «Ooooommmm» y observa los granos. Luego emite la orden TPR: «Listen! /ˈlɪs.ən/».
    - *Pista N1 (Socrática):* «Toca mi garganta mientras canto. ¿Sientes las cosquillas? Ahora canta tú contra el tubo con voz de oso gigante».
    - *Pista N2 (Modelado físico):* La persona adulta sostiene el tubo con la criatura, produce una vocalización grave que hace saltar el arroz visiblemente y celebra: «Jump, rice, jump!».
  - **Construye (Make):**
    - *Reto tangible:* Añadir un segundo cuenco con la membrana más floja y comparar en cuál de los dos tambores salta más alto el arroz al cantar fuerte: «Loud! /laʊd/» vs «Soft... /sɑːft/».
    - *Síntesis de cierre:* «Si nuestra voz para de cantar y nos quedamos en Freeze (/friːz/), ¿por qué el arroz deja de bailar inmediatamente?».
- **Evaluación formativa (1-Tap):**
  - *Criterio de logro:* La criatura vocaliza de forma sostenida hacia la membrana variando la intensidad y asociando el salto del arroz con la vibración acústica.
  - *Observación cualitativa:* Registrar `[L]` (asocia voz grave/intensa con vibración sin soplar), `[A]` (tiende a soplar aire en vez de fonoarticular), `[E]` (toca el arroz con los dedos).

---

### UNIDAD I4 (`curso_4_5`: 4 a 5 años) · ÓPTICA TANGIBLE Y SOMBRAS
- **ID:** `I4-OPTICA-001`
- **Fenómeno:** Óptica geométrica tangible, propagación rectilínea de la luz, cuerpos opacos vs translúcidos y escala proporcional de sombras.
- **Justificación neuromadurativa:** Visomotricidad fina avanzada, nociones espaciales euclidianas proyectivas (delante/detrás, lejos/cerca), anticipación geométrica de contornos y relaciones causa-efecto bidimensionales.
- **Tiempo estimado:** 20 minutos.
- **Materiales:**
  - Foco de luz puntual (linterna pequeña analógica o flexo de mesa protegido) — 1 unidad.
  - Silueta recortada de cartón opaco de la figura de Lúa pegada a una varilla de madera — 1 unidad.
  - Pantalla o pared lisa blanca vertical — 1 unidad.
  - Cinta de carrocero para marcar distancias en el suelo (1 m y 2 m) — 1 tira.
- **Foco TPR motor corporeizado:** La criatura se desplaza caminando hacia adelante y hacia atrás sosteniendo la figura entre el foco y la pared, estirando los brazos para hacer la sombra gigante o encogiéndose para hacerla diminuta.
- **Ciclo didáctico:**
  - **Observa:**
    - *Planteamiento:* La linterna ilumina la pared blanca. La persona adulta coloca la silueta cerca de la linterna y aparece una sombra enorme en la pared.
    - *Pregunta de indagación:* «¿Qué tenemos que hacer con la figura para que la sombra se haga pequeña como un ratón? (Pausa de 5 segundos de anticipación)».
  - **Experimenta:**
    - *Consigna adulto:* Camina con la silueta hacia la pared y di: «Step forward! /stɛp ˈfɔːr.wɚd/». Observa cómo la sombra se encoge. Luego retrocede hacia la luz y di: «Step back! /stɛp bæk/». Mira cómo la sombra crece: «Big shadow! /bɪɡ ˈʃæd.oʊ/».
    - *Pista N1 (Socrática):* «Mira la linterna. Si la figura tapa mucha luz cerca del foco, ¿sale más sombra o menos sombra?».
    - *Pista N2 (Modelado físico):* La persona adulta guía el brazo de la criatura acercándolo y alejándolo de la pared mientras nombran el contraste visual: «Big! / Small!».
  - **Construye (Make):**
    - *Reto tangible:* Con dos tiras de cinta en el suelo, marcar la posición de "Sombra Bebé" (cerca de la pared) y "Sombra Gigante" (cerca de la linterna), jugando a saltar a la orden de la persona adulta.
    - *Síntesis de cierre:* «¿Dónde viaja la luz cuando colocamos el cartón delante? ¿Puede atravesarlo o se queda atrapada creando la sombra?».
- **Evaluación formativa (1-Tap):**
  - *Criterio de logro:* La criatura ajusta voluntariamente la distancia de la silueta al foco para lograr el tamaño de sombra solicitado por la consigna.
  - *Observación cualitativa:* Registrar `[L]` (deduce la relación distancia-tamaño de forma autónoma), `[A]` (requiere guía motriz en el desplazamiento), `[E]` (juega con la linterna sin fijarse en la escala de la sombra).

---

### UNIDAD I5 (`curso_5_6`: 5 a 6 años) · PENSAMIENTO COMPUTACIONAL UNPLUGGED
- **ID:** `I5-LOGICA-001`
- **Fenómeno:** Pensamiento computacional sin pantallas, secuenciación algorítmica, condicionales lógicos corporeizados y depuración física (*debugging*).
- **Justificación neuromadurativa:** Funciones ejecutivas consolidadas (memoria de trabajo, control inhibitorio), lateralidad corporal afianzada (derecha/izquierda), comprensión de reglas condicionales si-entonces (*if-then*) y capacidad de transferir secuencias motrices a una cuadrícula.
- **Tiempo estimado:** 22 minutos.
- **Materiales:**
  - Cuadrícula física de 3x3 baldosas trazada con cinta de carrocero en el suelo — 1 cuadrícula.
  - Tarjetas de flechas direccionales de cartón de 15x15 cm (Adelante, Giro 90° Derecha, Giro 90° Izquierda) — 6 tarjetas.
  - Tarjetas de colores en el suelo (una baldosa roja y una baldosa azul) — 2 marcas.
  - Figura física o gorro de "Robot Lúa" para la criatura — 1 elemento.
- **Foco TPR motor corporeizado:** La criatura actúa como "Robot Lúa", ejecutando paso a paso las instrucciones del algoritmo físico sin saltarse casillas y respondiendo a los condicionales (*If red, clap! / If blue, jump!*).
- **Ciclo didáctico:**
  - **Observa:**
    - *Planteamiento:* La cuadrícula en el suelo tiene una baldosa de salida y una meta con una flor de papel. En el centro hay una baldosa roja.
    - *Pregunta de indagación:* «¿Cuántos pasos rectos y cuántos giros necesita dar el robot para llegar a la flor esquivando el lago? (Pausa de 5 segundos de planificación mental)».
  - **Experimenta:**
    - *Consigna adulto:* Coloca la secuencia de 3 tarjetas de flechas en el suelo. El robot lee la primera tarjeta y da un paso diciendo: «Step forward! /stɛp ˈfɔːr.wɚd/». Luego lee la segunda y gira: «Turn right! /tɜːrn raɪt/». Si pisa la casilla roja, aplica la regla condicional: «If red: Stop and freeze! /stɑːp ænd friːz/».
    - *Pista N1 (Socrática):* «El robot se ha chocado con la pared. ¿Cuál de las tres tarjetas del suelo tiene la flecha equivocada? Vamos a depurar (debug) el camino».
    - *Pista N2 (Modelado físico):* La persona adulta camina junto a la criatura dentro de la cuadrícula haciendo el giro con los hombros para orientar la nueva dirección corporal.
  - **Construye (Make):**
    - *Reto tangible:* Diseñar un nuevo algoritmo colocando un obstáculo físico (un cojín) y crear la secuencia de tarjetas de cartón en el suelo para que un compañero o la persona adulta lo ejecute sin fallar.
    - *Síntesis de cierre:* «Si cambiamos el orden de dos tarjetas en el suelo, ¿el robot llega al mismo sitio o se pierde en el camino?».
- **Evaluación formativa (1-Tap):**
  - *Criterio de logro:* La criatura sigue la secuencia lineal de instrucciones corporales y ejecuta el control inhibitorio ante la regla condicional sin adelantarse a los comandos.
  - *Observación cualitativa:* Registrar `[L]` (ejecuta algoritmo y condicional de forma autónoma), `[A]` (requiere apoyo para no confundir giro derecha/izquierda), `[E]` (camina libremente fuera de la cuadrícula).

---

## 🔊 4. Catálogo Fonológico TPR en Inglés (L2)

El estímulo en inglés es **puramente auditivo y kinestésico**. A continuación se detalla la partitura fonológica con transcripción IPA, acción física modelada y calibración de volumen para la salud auditiva infantil (≤75 dBA a 50 cm):

| Código | Comando | Fonética IPA | Acción Corporal Modelada (TPR) | Curvatura de Audio |
| :--- | :--- | :--- | :--- | :--- |
| `AUDIO_I1_DROP` | **Drop** | `/drɑːp/` | Manos abiertas soltando el objeto suave hacia la cesta. | 1.8s · Tono descendente suave (180 Hz) · -6 dBFS |
| `AUDIO_I1_TOUCH`| **Touch** | `/tʌtʃ/` | Yemas de los dedos acariciando la textura con suavidad. | 1.6s · Doble toque rítmico (240 Hz) · -6 dBFS |
| `AUDIO_I2_ROLL` | **Roll** | `/roʊl/` | Movimiento circular continuo de ambos antebrazos imitando la rueda. | 2.0s · Tono modulado continuo (160 Hz) · -6 dBFS |
| `AUDIO_I2_PUSH` | **Push** | `/pʊʃ/` | Ambas palmas extendidas empujando suavemente el aire hacia adelante. | 1.5s · Pulso creciente firme (200 Hz) · -6 dBFS |
| `AUDIO_I2_STOP` | **Stop** | `/stɑːp/` | Brazos en cruz o palmas al frente congelando el avance. | 1.4s · Corte seco abrupto (220 Hz) · -6 dBFS |
| `AUDIO_I3_LISTEN`| **Listen**| /ˈlɪs.ən/ | Mano ahuecada llevada a la oreja inclinando la cabeza. | 2.2s · Campana melódica suave (320 Hz) · -6 dBFS |
| `AUDIO_I3_SHAKE` | **Shake** | `/ʃeɪk/` | Sacudida rápida y rítmica de manos o maraca sin desplazarse. | 2.0s · Oscilación rápida rítmica (190 Hz) · -6 dBFS |
| `AUDIO_I3_FREEZE`| **Freeze**| `/friːz/` | Estatua inmóvil inmediata conteniendo la respiración y sonriendo. | 1.6s · Tono suspendido armónico (260 Hz) · -6 dBFS |
| `AUDIO_I4_LOOK`  | **Look**  | `/lʊk/` | Manos simulando prismáticos sobre los ojos señalando la pared. | 1.8s · Barrido ascendente nítido (280 Hz) · -6 dBFS |
| `AUDIO_I5_STEP`  | **Step**  | `/stɛp/` | Un paso firme marcando el pie en el suelo de la cuadrícula. | 1.2s · Golpe seco grave de apoyo (140 Hz) · -6 dBFS |
| `AUDIO_I5_TURN`  | **Turn**  | `/tɜːrn/` | Giro de 90 grados sobre un talón manteniendo el equilibrio. | 1.5s · Transición armónica dual (170-220 Hz) · -6 dBFS |
| `AUDIO_I5_JUMP`  | **Jump**  | `/dʒʌmp/` | Salto vertical con pies juntos cayendo con rodillas flexionadas. | 1.6s · Impulso ascendente elástico (250 Hz) · -6 dBFS |

---

## 📱 5. Arquitectura de Integración en «Descubre con Lúa» (Flutter)

En la aplicación `Descubre con Lúa`, todo el contenido se integra de manera declarativa sin tocar la lógica de widgets:

```
Descubre con Lúa (App Flutter)
├── assets/
│   ├── content/
│   │   ├── capsulas/
│   │   │   ├── aula.steam.01_materia.json      # Asamblea docente (Juega con Lúa)
│   │   │   ├── aula.steam.02_cinematica.json
│   │   │   ├── aula.steam.03_acustica.json
│   │   │   ├── aula.steam.04_optica.json
│   │   │   ├── aula.steam.05_logica.json
│   │   │   ├── academy.steam.01_fogar.json     # Cápsulas familiares (Academy)
│   │   │   ├── academy.steam.02_fogar.json
│   │   │   └── ...
│   │   └── tpr/
│   │       ├── curso_0_2/                      # Vocabulario e indagación motriz
│   │       ├── curso_2_3/
│   │       ├── curso_3_4/
│   │       ├── curso_4_5/
│   │       └── curso_5_6/
│   └── voice/                                  # Audio local pre-sintetizado
│       ├── en_tutor_drop.m4a
│       ├── en_tutor_roll.m4a
│       └── ...
└── lib/features/
    ├── juega/                                  # Interfaz asamblea docente
    └── academy/                                # Interfaz cápsulas familias
```

### Contrato de Paridad Bilingüe Estricta:
Cada texto para la persona adulta en los JSONs lleva paridad 1:1:
```json
{
  "id": "steam_acustica_01",
  "estadio": "curso_3_4",
  "titulo": {
    "gl": "O arroz que baila coa voz",
    "es": "El arroz que baila con la voz"
  },
  "consigna": {
    "gl": "Achega o tubo á membrana e canta un son grave prolongado para ver saltar os grans de arroz.",
    "es": "Acerca el tubo a la membrana y canta un sonido grave prolongado para ver saltar los granos de arroz."
  },
  "orde_tpr": {
    "comando": "Listen",
    "ipa": "/ˈlɪs.ən/",
    "audio_asset": "assets/voice/en_tutor_listen.m4a"
  }
}
```

---

## 🛠️ 6. Plan de Trabajo Limpio en «Descubre con Lúa»

1. **Rama de trabajo:** Operar en `Descubre con Lúa` exclusivamente en la rama **`steam`** (creada a partir de `origin/main`).
2. **Protección absoluta de `main`:** `main` permanece intacta y no se modifica en local ni en remoto.
3. **Generación de JSONs:** Crear las cápsulas STEAM de aula y familia en `assets/content/capsulas/` y registrar el vocabulario en `assets/content/tpr/`.
4. **Verificación local con Gates:**
   ```bash
   flutter test
   tools/gates.sh
   ```
5. **Despliegue remoto:**
   ```bash
   git push -u origin steam
   ```
   (Utilizando la autenticación nativa ya configurada en el repositorio de Descubre con Lúa).
