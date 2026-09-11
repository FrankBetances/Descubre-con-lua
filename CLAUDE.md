# Lúa · Edición Vigo (Flutter) · Notas para Claude Code

App Android nativa en Flutter, de finalidad **exclusivamente educativa**, para las escuelas infantiles municipales de Vigo y sus familias. Tiene dos módulos:

- **Juega con Lúa**: lo usa la docente en la asamblea.
- **Academy**: lo usan las familias en casa.

Todo el contenido está en gallego y castellano. La primera versión la generó Google Antigravity y la revisión y mejora la hace Claude Code.

**No es Valeria+.** No se copia código, pantallas ni módulos de Valeria+. De Valeria+ se heredan las reglas de trabajo de abajo, la identidad de Lúa y las tuberías de compilación (voz neuronal, rejilla de la mascota), nada más.

## Reglas de producto

Este archivo importaba `.agents/rules/01-producto.md`, `02-flutter-android.md` y `03-contenido.md`. **Esos tres ficheros no existen en el repositorio**, así que las importaciones se han retirado: un import roto no es una regla, es una regla que nadie lee. Estas son las reglas, sin depender de ningún import:

- el niño no usa la pantalla;
- cero datos personales;
- sin permiso INTERNET en release;
- nada con finalidad sanitaria;
- contenido en JSON, nunca escrito en los widgets.

No edites `.agents/` sin autorización: es la configuración de Antigravity.

Plataforma de esta fase: **solo Android**. No crees ni borres `ios/`.

## Reglas de trabajo (obligatorias, no negociables)

Heredadas del CLAUDE.md de Valeria+ y adaptadas a Flutter. Allí nacieron de errores reales, cada uno con su coste. No son buenas prácticas genéricas: son lo que ya salió mal.

### 0. No afirmes nada que no hayas comprobado. Manda sobre todas las demás

| Puedes decir | Cuándo |
| --- | --- |
| «He escrito / he cambiado X» | Siempre. Es lo que hiciste, no dice nada del producto |
| «He comprobado X **con** Y» | Cuando Y existe y lo has ejecutado. **Nombra Y**: el gate, la captura, el comando |
| «Está hecho» | Solo con la evidencia al lado, y solo del alcance que cubre esa evidencia |

- **No presentes tu actividad como el estado del producto.** «Cambiado en el widget» y «analyze limpio» son hechos sobre ti. Frank necesita hechos sobre lo que la app hace.
- **`flutter analyze` no es verificación.** Corre los gates (§1b).
- **«Hecho» se mide en capas, no en ficheros editados.** Un cambio de contenido vive en: JSON gl, JSON es, audio gl, audio es, imprimible, ARB de interfaz y README. **Enumera las capas y di cuál has mirado y cuál no.**
- **Lo que Antigravity dejó escrito en `docs/` es contexto, no verdad.** Contrástalo con el código antes de repetirlo.
- **Nada llega a Frank como «entregado» mientras esté en una rama.** Se dice «en la rama X, pendiente de mergear» y se da la versión o el número de build.

**Si no lo has comprobado, dilo con esas palabras: «esto no lo he verificado».**

Coste heredado: en Valeria+ se dijo «está hecho» tres veces sin haber mirado, y la tercera la build ya estaba distribuida a testers de todo el mundo.

Coste propio: este proyecto llegó a declarar «1443/1443 · CERTIFIED READY FOR PRODUCTION» mientras la app no compilaba. El certificador leía los `.dart` y comprobaba que contuvieran `import flutter_test`.

### 0a. No actúes sin autorización

**No hagas nada que Frank no haya pedido.** Decide él. Si ves algo que convendría cambiar, **no lo cambies: díselo en una frase y espera.** Estas tres cosas no son un sí:

- que el cambio sea pequeño u obvio;
- que autorizara algo parecido en otro momento;
- que no conteste.

«Revisa y mejora» no es permiso para cambiar. Se ejecuta así: informe, Frank elige lotes, se aplica solo el lote elegido.

Coste heredado: en Valeria+ un trabajo pedido para el galego tocó también un formulario que nadie mandó tocar. Frank publicó sin saberlo, y la app llegó a producción con ese formulario bloqueado.

### 1. No digas que una pantalla está hecha sin haberla mirado

Todo cambio visual lleva **captura propia en emulador o aparato**, en gallego **y** en castellano:

```bash
flutter run -d <dispositivo>
adb exec-out screencap -p > docs/capturas/<pantalla>-<gl|es>.png
```

Las dos lenguas no miden lo mismo: una pantalla correcta en castellano puede cortarse en gallego. **Mira las capturas antes de decir «hecho».**

### 1b. «Hecho» exige los gates, no solo analyze

Los gates se sacan **del script o del workflow de CI** (`tools/gates.sh` o `.github/workflows/`), nunca de una lista escrita aquí. En Valeria+ la lista del CLAUDE.md se quedó atrás respecto al workflow y una build murió en un gate que no figuraba en ella.

Si todavía no existe ni script ni CI, díselo a Frank. Hasta entonces, el mínimo es:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --release
apkanalyzer manifest permissions build/app/outputs/flutter-apk/app-release.apk   # o aapt2 dump permissions
```

A eso se suma el validador de contenido, si existe. **Bloqueante:** INTERNET o cualquier permiso no aprobado en el APK release.

**Texto con audio:** si cambia el texto de un ítem que tiene audio, el audio gl/es se regenera **en el mismo commit**. Si no, la app enseña un texto y reproduce otro, y ningún test lo detecta.

Verde en local no es verde en CI. Si hay CI, no se dice «entregado» hasta que `main` tenga un run completo en verde.

### 1c. Un widget test o una golden NO prueban un Android

Flutter pinta su propia disposición, así que los tests se parecen al aparato más que una captura web de React Native. Aun así hay cuatro cosas que no se ven en ellos:

- en tests el texto sale con fuentes de relleno salvo que se carguen las reales;
- no hay insets reales (muesca, barra de gestos);
- no hay escala de texto del sistema ni densidades reales;
- el audio no suena de verdad.

La familia de defectos típica aquí es **`RenderFlex overflowed`** con una cadena gallega más larga o con texto grande del sistema. En debug salen las franjas amarillas y negras. **En release no sale nada: el texto simplemente se corta.**

En todo cambio de disposición:

- comprueba en aparato con gl, es y **escala de texto grande**;
- si no hay aparato, escribe **«esto no lo he visto en un aparato»** y no mergees a `main` sin que Frank lo mire;
- lo más seguro sin aparato es **no cambiar la disposición**.

### 2. Informa de lo que Frank VA A VER, no de lo que has hecho

Primera línea de la respuesta: qué cambia en pantalla. Si no cambia nada visible (refactor, tests, docs), **dilo en la primera línea**.

### 3. Nada de feature flags para cambios de pantalla completa

Un flag convierte «está mergeado» y «se ve» en dos cosas distintas.

### 4. Un push por cambio, y solo a la rama destino

Nunca empujes el mismo commit a dos ramas. Un agente por rama a la vez: antes de empezar, `git status` y `git log --oneline -5`. Si hay cambios sin commit de otra herramienta, **para y díselo a Frank**.

### 5. «Premium» significa activos propios

Nada de emoji del sistema como iconografía: cambian entre fabricantes y nunca forman un set. Los iconos salen de un set propio coherente (misma rejilla, grosor y terminaciones). Si el set no existe, díselo a Frank antes de improvisar.

### 5b. La mascota es Lúa, la gata

- Es el mismo personaje que en Valeria+. Allí el sprite vive como rejilla de caracteres en `src/ValeriaCatPixel.tsx` del repositorio Valeria, y de esa rejilla salen icono, icono adaptativo y splash.
- Aquí se **porta la rejilla**, no se redibuja a ojo. Vive en `assets/brand/lua_head.txt`, y de ahí salen icono, icono adaptativo y splash mediante `tools/build_launcher_icons.py`. Icono y splash deben salir de la misma fuente.
- **No se hereda nada del sistema de premios de Valeria+:** ni insignias, ni desfile, ni espejo con el periférico Lúa. En esta edición no existen, porque el niño no usa la pantalla. Lúa aparece para la docente y la familia, no para captar la atención infantil.

### 6. Rediseñar, no parchear

Si Frank dice que algo se ve pobre, se rehace la pieza entera y se enseña la captura. No se hacen rondas de ajustes de padding.

### 7. Menos prosa, más resultado

Comenta solo lo que evita que alguien rompa algo (red, datos, finalidad educativa, sincronía texto-audio). Calla el resto.

## El pulso se ve, no se oye

El metrónomo de la canción a pulso es **visual**, como en Valeria+. La razón no es estética: parte de las crianzas llevan audiófono o implante, y un metrónomo sonoro compite justo con la voz que tienen que seguir. El pulso se dibuja y el canal auditivo queda entero para la letra.

Los tiempos del compás salen de las marcas `*` de `letraConPulsos`, no de una configuración aparte: así el pulso no puede discrepar de lo que la docente está leyendo.

## Correo de contacto (regla fija)

El correo de contacto del proyecto es **siempre**:

```
frank.alberto.betances.reinoso@gmail.com
```

Aplica a la política de privacidad, las fichas de Google Play Console, los textos legales y cualquier documento de contacto. No lo sustituyas por una dirección de dominio (`@futureforkids.eu` u otra), ni propongas el cambio como mejora.

Lo comprueba un gate: `tools/check_contact_email.py`.

## Privacidad declarada = privacidad compilada

Si la app se publica en Google Play, la política de privacidad y el formulario de *Seguridad de los datos* deben decir lo mismo que el APK: sin datos, sin permisos, sin SDKs de terceros.

Cualquier cambio en lo que la app recoge (un permiso, un paquete, un campo guardado) obliga a actualizar **en el mismo cambio** la política y el formulario de Play Console. Las URLs legales de esta app **no están definidas todavía**: no las inventes ni reutilices las de Valeria+, que describen otra app.
