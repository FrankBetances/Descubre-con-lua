# Descubre con Lúa · Edición Vigo

Aplicación Android educativa, **sin conexión**, para las escuelas infantiles
municipales de Vigo y sus familias. Primer ciclo de educación infantil (0-3
años). Todo el contenido existe en gallego y castellano.

- **Juega con Lúa · Aula** — la usa la docente en la asamblea.
- **Academy · Familias** — la usan las familias en casa.

**Finalidad exclusivamente educativa.** No es un producto sanitario: no evalúa,
no diagnostica y no trata nada. El niño no usa la pantalla; la app es para la
persona adulta que acompaña.

## Estado

**Léelo en [`STATUS.md`](STATUS.md)**, que separa lo comprobado de lo no
comprobado y nombra la evidencia de cada línea.

Resumen honesto a día de hoy: la suite pasa (107 tests), el análisis está
limpio, y **la app todavía no reproduce audio** porque las 12 grabaciones no
se han sintetizado. El gate lo dice y falla por ello.

## Comprobar

```bash
flutter pub get
tools/gates.sh --fast   # formato, análisis, tests y gates de contenido
tools/gates.sh          # además compila el APK release y audita sus permisos
```

CI ejecuta ese mismo script. La lista de gates vive en el script, no en un
documento que se pueda quedar atrás.

## Voz

El audio se genera con voces neuronales en tiempo de compilación y viaja
grabado dentro del paquete. Los modelos **nunca** corren en el aparato.

- gallego → **Celtia**, do Proxecto Nós (gated en Hugging Face: requiere el
  secret `HF_TOKEN`)
- castellano → **Sharvard** (rhasspy/piper-voices)

```bash
python3 tools/export_voice_corpus.py       # corpus desde assets/content
python3 tools/generate_voice_assets.py --lang gl
python3 tools/check_voice_coverage.py      # ¿falta alguna grabación?
```

El identificador de cada grabación es el hash de su propio texto, así que
editar una frase cambia el identificador, la grabación pasa a faltar y el gate
lo detecta. La app no puede enseñar un texto y reproducir otro.

## Privacidad

Cero datos personales, cero analítica, cero SDK de terceros, y ningún permiso
en el manifiesto. `pubspec.yaml` no tiene una sola dependencia externa: la
reproducción de audio va por un `MethodChannel` contra el `MediaPlayer` de
Android.

La comprobación que cuenta se hace sobre el **APK compilado** con `aapt2`, no
sobre el manifiesto fuente.

Política publicada: [`docs/privacy.html`](docs/privacy.html).
Contacto: frank.alberto.betances.reinoso@gmail.com

## Estructura

```
lib/core/       tema, idiomas, audio (servicio, reproductor nativo, ids de voz)
lib/data/       modelos, cargador, repositorio, validador de contenido
lib/features/   juega/ (aula) · academy/ (familias)
assets/content/ unidades y cápsulas en JSON, bilingües
assets/voice/   grabaciones neuronales (generadas en CI)
assets/brand/   rejilla de píxeles de Lúa: de aquí salen icono y splash
tools/          gates y tubería de voz
```
