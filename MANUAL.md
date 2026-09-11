# Manual de uso · Descubre con Lúa · Edición Vigo

Manual de la aplicación Android **Descubre con Lúa**, para las escuelas
infantiles municipales de Vigo y sus familias.

Regla de este documento, la misma que la del resto del proyecto: **sólo
describe lo que la app hace hoy.** Lo que todavía no existe está en
[«Límites de esta versión»](#límites-de-esta-versión), no escondido entre los
casos de uso.

---

## Qué es, y qué no es

**Es** material pedagógico para el primer ciclo de educación infantil (0-3
años), en gallego y castellano, que funciona entero sin conexión.

**No es** un producto sanitario. No evalúa, no diagnostica y no trata
nada. No emite informes ni puntuaciones sobre ninguna criatura.

**La criatura no usa la pantalla.** Las dos partes de la app están escritas
para la persona adulta que acompaña: la docente en la asamblea y la familia en
casa. No hay juegos, ni recompensas, ni animaciones pensadas para captar la
atención infantil.

---

## Antes de empezar

| | |
| --- | --- |
| **Instalación** | APK de Android. No está publicada en Google Play todavía |
| **Conexión** | Ninguna. La app no puede conectarse: el paquete no lleva permiso de internet |
| **Cuentas** | No hay. No se pide correo, ni nombre, ni nada |
| **Datos** | Cero. No se recoge, no se envía, no se guarda nada sobre quien la usa |
| **Idiomas** | Gallego y castellano, conmutables en cualquier pantalla con el selector **GL / ES** de la barra superior |

Al desinstalar no queda nada que borrar en ningún servidor, porque nunca hubo
ninguno.

---

## Mapa de la aplicación

```
Pantalla inicial
├── Juega con Lúa · Aula      → para la docente
│   └── Lista de unidades (filtro por tramo)
│       └── Modo Asamblea · Aula (6 fases)
└── Academy · Familias        → para padres y madres
    └── Los 5 bloques de desarrollo
        └── Cápsula (4 partes + reflexión)
```

---

# Casos de uso · Docente

## CU-1 · Elegir la unidad de la asamblea

**Cuándo:** antes de sentar al grupo, con un minuto de margen.

1. Abre la app y pulsa **Entrar en Modo Aula**.
2. Verás **Juega con Lúa · Aula** con las unidades disponibles.
3. Filtra con las pestañas: **Todas as idades**, **0-2 anos**, **2-3 anos**.
4. Cada tarjeta muestra el título, el tramo y una descripción breve.
5. Pulsa la unidad para abrirla.

**Qué verás si no hay nada:** «Non se atoparon unidades para este tramo de
idade». Es un aviso honesto, no un error.

> **Hoy:** hay **una** unidad, *Explorando o Mar de Vigo: A nosa Ría*, marcada
> como `0-3`, así que aparece en las tres pestañas.

---

## CU-2 · Conducir la asamblea guiada

**Cuándo:** durante la asamblea, con el aparato en la mano o apoyado.

La pantalla se llama **Modo Asemblea · Aula** y va indicando **Fase N de 6**.
Se avanza con **Seguinte** y se retrocede con **Anterior**. En la última fase
el botón es **Finalizar**.

| Fase | Qué te da |
| --- | --- |
| **1. Canción a pulso** | Metrónomo visual, letra con marcas de pulso, consigna docente y la grabación del recitado |
| **2. Cuento guiado** | El cuento página a página, con la pregunta de comprensión de cada una |
| **3. Preguntas graduadas** | Tres niveles: señalar, nombrar y onomatopeyas, causa-efecto |
| **4. Exploración sensorial** | Objetivo, materiales, pasos y **aviso de seguridad** |
| **5. Matemáticas tempranas** | Enfoque, vocabulario matemático y acciones manipulativas |
| **6. Puente a casa** | Mensaje para el tablón y recomendación para la conversación en el hogar |

**Al avanzar de la fase 1 a la 2 el recitado se pausa solo.** No hace falta
acordarse. Al pulsar **Finalizar** se detiene del todo.

Al finalizar aparece «Asemblea completada. A app non garda nada da sesión» y
vuelves a la lista. Es literal: no hay registro de qué grupo hizo qué, ni
aquí ni en ningún servidor.

---

## CU-3 · Marcar el pulso

**Cuándo:** en la fase 1, mientras cantáis o recitáis.

1. Pulsa **Marcar o pulso**.
2. Los círculos se encienden uno a uno, al tempo de la unidad.
3. Para parar, **Deter o pulso**.

**El metrónomo no suena, y es a propósito.** Parte de las criaturas llevan
audiófono o implante, y un metrónomo sonoro compite justo con la voz que tienen
que seguir. Por eso el pulso se dibuja y el canal auditivo queda entero para la
letra.

Cómo leer los círculos:

- **Círculo grande y relleno** → tiempo fuerte, el primero del compás.
- **Círculos en aro** → tiempos débiles.
- **Anillo exterior** → el tiempo que suena ahora. Sirve para **anticipar** el
  siguiente, que es la mitad del ejercicio.

Los tiempos del compás son los asteriscos de la letra. En
`* On-das * que veñen, * on-das * que van,` hay cuatro marcas: cuatro tiempos.
Lo que lees y lo que marcas son la misma cosa, por construcción.

---

## CU-4 · Reproducir el recitado de la letra

**Cuándo:** para dar el modelo de pronunciación, o si prefieres no recitar tú.

1. En la fase 1, pulsa ▶ en la tarjeta del recitado.
2. Controles: reproducir, pausar, detener y reiniciar.
3. El estado se lee arriba: «Reproducindo o recitado da letra».

La grabación está dentro de la app. No se descarga nada.

---

## CU-5 · Cambiar de lengua a media asamblea

**Cuándo:** en cualquier momento, en cualquier pantalla.

Pulsa **GL** o **ES** en la barra superior. Cambia el texto y también la
grabación que se reproduce. No pierdes la fase en la que estás.

---

## CU-6 · Cuando una grabación no está

Si una grabación no viaja en esa versión de la app, verás:

> «Esta gravación non está incluída nesta versión. Podes marcar o pulso coa túa
> voz.»

No es un fallo tuyo ni del aparato. La asamblea sigue: el metrónomo visual, la
letra y la consigna funcionan igual.

---

# Casos de uso · Familias

## CU-7 · Leer una cápsula

**Cuándo:** tres minutos, cuando la criatura ya duerme.

1. Abre la app y pulsa **Entrar en Academy**.
2. Verás **Los 5 bloques de desarrollo**:

   1. Como se aprende a falar
   2. O baño de linguaxe nas rutinas
   3. Quendas de conversa e atención conxunta
   4. Xogo corporal e espazos sen pantallas
   5. Crianza bilingüe e contorna cultural

3. Entra en un bloque y elige una cápsula.
4. La cápsula siempre tiene las mismas cuatro partes, en este orden:

   | | |
   | --- | --- |
   | **1. Idea clave** | La idea, en dos frases |
   | **2. Por qué importa** | Qué hay detrás |
   | **3. Qué hacer en casa** | Algo concreto para hoy |
   | **4. Ejemplo cotidiano** | La misma idea dentro de una escena real |

Si un bloque aún no tiene cápsulas, lo dice: «Novas cápsulas deste bloque en
preparación pedagóxica».

> **Hoy:** hay **una** cápsula, en el bloque 1.

---

## CU-8 · Responder la reflexión

Al final de cada cápsula está **Reflexión para a familia**: afirmaciones para
responder **Verdadeiro** o **Falso**.

- La respuesta aparece al instante, con una explicación.
- **No puntúa y no corrige.** Si te equivocas, te explica por qué, sin más.
- No se guarda nada ni se envía a ningún sitio.
- Si cambias de lengua, tu respuesta se mantiene y la explicación cambia de
  idioma.

---

## CU-9 · Usar la app sin la criatura delante

Es la forma prevista. Academy no tiene nada que un niño quiera tocar: ni
sonidos llamativos, ni animaciones, ni premios. Es un texto para una persona
adulta, con tipografía grande y cómoda.

---

# Casos de uso · Mantenimiento

Esta parte es para quien edita el proyecto.

## CU-10 · Añadir una unidad o una cápsula

1. Crea el JSON en `assets/content/unidades/` o `assets/content/capsulas/`,
   con los dos idiomas completos.
2. `python3 tools/export_voice_corpus.py` — extrae las locuciones nuevas y
   sincroniza las rutas de audio.
3. Lanza el workflow **Generate Voice Assets** para sintetizarlas.
4. `tools/gates.sh`.

No hay que tocar Dart: el catálogo se descubre del propio paquete.

---

## CU-11 · Cambiar un texto que tiene audio

**Esto es lo que más fácil se rompe en apps bilingües con voz**, así que está
resuelto por construcción.

El identificador de cada grabación es el hash de su propio texto. Si cambias
una frase:

1. Cambia el identificador.
2. La grabación vieja queda huérfana y la nueva no existe.
3. `tools/check_voice_coverage.py` **falla** y dice exactamente cuál falta.

No se puede publicar una pantalla que enseñe un texto y reproduzca otro.

---

## CU-12 · Regenerar las voces

| Lengua | Voz | Requisito |
| --- | --- | --- |
| Gallego | **Celtia**, do Proxecto Nós | Secret `HF_TOKEN` (el modelo es *gated* en Hugging Face) |
| Castellano | **Sharvard** (rhasspy/piper-voices) | Ninguno |

Lanza el workflow **Generate Voice Assets**. Sintetiza sólo lo que falta,
masteriza con objetivo de −3 dBFS, **comprueba el pico del fichero ya
codificado** y atenúa si hace falta, y commitea los `.m4a`.

El objetivo previo no basta: un códec con pérdida no conserva el pico que se le
entrega. Un recitado masterizado a −3 dBFS salió del codificador a −0,0, sin
margen ninguno. `tools/check_voice_levels.py` mide los ficheros que se publican.

**Los modelos corren en CI y jamás en el aparato.** La app lleva grabaciones,
no inferencia: por eso el APK no necesita ni un permiso de red.

---

## CU-13 · Comprobar antes de entregar

```bash
tools/gates.sh --fast   # formato, análisis, tests y contenido
tools/gates.sh          # además compila el APK y audita sus permisos
```

CI ejecuta ese mismo script. Ver [`STATUS.md`](STATUS.md) para el estado real
de cada gate.

---

## CU-14 · Auditar la privacidad del binario

El gate lo hace en cada ejecución, pero a mano es:

```bash
flutter build apk --release
aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk
```

Debe aparecer **un único permiso**, el que AndroidX inyecta
(`…DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`, de nivel *signature* y con el
nombre de paquete de la propia app). Cualquier otro, y en especial
`android.permission.INTERNET`, es un fallo bloqueante.

Esa salida es la prueba que sostiene la política de privacidad y el formulario
de *Seguridad de los datos* de Google Play. No se afirma desde el manifiesto
fuente: se lee del binario.

---

## Límites de esta versión

Para que nadie se lleve una sorpresa en un aula:

| Límite | Detalle |
| --- | --- |
| **Contenido** | Una unidad y una cápsula. Cuatro de los cinco bloques de Academy están vacíos, y lo dicen |
| **Ilustraciones** | El cuento no lleva láminas. La pantalla lo indica y sugiere señalar en el aula |
| **Grabaciones** | Faltan varias. Cuando falta una, la app lo dice (CU-6) |
| **Filtro por edad** | La única unidad es `0-3`, así que aparece en las tres pestañas |
| **Sin aparato** | Ninguna pantalla se ha visto todavía en un móvil o tablet real |
| **Google Play** | No está publicada |

---

## Si algo va mal

| Qué ves | Qué pasa |
| --- | --- |
| «Non se atoparon unidades…» | El filtro no tiene unidades de ese tramo. Prueba **Todas as idades** |
| «Esta gravación non está incluída…» | Esa locución no viaja en esta versión. La asamblea sigue sin ella |
| «Lámina ilustrada pendente» | El cuento aún no tiene imágenes. Lee el texto y señalad en el aula |
| «Novas cápsulas deste bloque…» | Ese bloque de Academy todavía no tiene contenido |
| Listas vacías sin mensaje | Eso sí sería un defecto: escríbelo al correo de abajo |

---

## Contacto

Dr. Frank Alberto Betances Reinoso
frank.alberto.betances.reinoso@gmail.com

Política de privacidad: [`docs/privacy.html`](docs/privacy.html)
