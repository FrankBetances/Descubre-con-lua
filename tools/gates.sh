#!/usr/bin/env bash
# The gates. CI runs this same file, so the list cannot drift from what is
# actually enforced.
#
#   tools/gates.sh          # everything
#   tools/gates.sh --fast   # skip the release build (format, analyze, test, content)
#
# Every gate runs even after one fails, so a single run tells you everything
# that is wrong instead of one thing at a time. The exit code is non-zero if
# any gate failed.
set -uo pipefail

cd "$(dirname "$0")/.."

FAST=0
[[ "${1:-}" == "--fast" ]] && FAST=1

FAILED=()
PASSED=()

# Google Play refuses an upload whose versionCode is not greater than the last
# one, so CI derives it from the workflow run number and passes it in here. A
# contributor running the gates locally leaves it unset and gets the value in
# pubspec.yaml, which is what you want on a machine that never uploads.
BUILD_ARGS=()
[[ -n "${BUILD_NUMBER:-}" ]] && BUILD_ARGS+=("--build-number=${BUILD_NUMBER}")

run_gate() {
  local name="$1"; shift
  printf '\n\033[1m── %s\033[0m\n' "$name"
  if "$@"; then
    PASSED+=("$name")
  else
    FAILED+=("$name")
    printf '\033[31mFAILED: %s\033[0m\n' "$name"
  fi
}

# Las dependencias, ANTES del primer gate. Sin `.dart_tool/package_config.json`,
# `dart format` no puede resolver el `include` de analysis_options.yaml, escupe
# un «Package resolution error» por fichero y da los 95 por CAMBIADOS: el gate
# sale rojo con el código perfectamente formateado.
#
# Hasta ahora no pasaba porque `package_config.json` estaba TRACKEADO, con la
# ruta absoluta de la máquina que lo generó por última vez. Al sacarlo del
# índice —que es donde tiene que estar, porque es un fichero de máquina— quedó
# a la vista que este script nunca resolvió sus propias dependencias: se
# apoyaba en que alguien hubiera corrido `flutter pub get` antes. El workflow de
# CI sí lo hace; un clon nuevo, no.
#
# Es barato: con las dependencias ya resueltas no hace nada.
printf '\n\033[1m── flutter pub get\033[0m\n'
if ! flutter pub get; then
  echo "No se pudieron resolver las dependencias; los gates no pueden correr."
  exit 1
fi

# ---------------------------------------------------------------- Dart gates
run_gate "dart format" dart format --output=none --set-exit-if-changed .
run_gate "flutter analyze" flutter analyze
# --exclude-tags capturas: `test/capturas_test.dart` NO comprueba nada, produce
# las imágenes del manual. Compararlas aquí metería una golden en la ruta
# crítica, y una golden depende de la máquina que la pinta: en cuanto CI use
# otra versión del motor o de las fuentes, el gate se pone rojo sin que la app
# haya cambiado. Se corre a mano:
#   flutter test --tags capturas --update-goldens test/capturas_test.dart
run_gate "flutter test" flutter test --exclude-tags capturas

# ------------------------------------------------------------- content gates
run_gate "contact address" python3 tools/check_contact_email.py
# Nace del Calendario, que llegó al aparato como un disco girando para siempre
# porque `assets/content/calendario/` no estaba en pubspec.yaml. Un asset que
# falta no rompe la compilación: rompe una pantalla, en silencio.
run_gate "every asset asked for exists and is packaged" python3 tools/check_bundled_assets.py
# Nace de la barra de la toalla, que no se pintaba porque el formato usaba `w`
# para el ancho del rectángulo Y para el grosor del contorno: clave repetida,
# JSON se queda con la última y el fichero se lee perfectamente bien.
run_gate "every lamina shape actually paints" python3 tools/check_laminas.py
# Nace de la galería del banco, que enseñaba 205 iconos grises de «imagen rota»
# porque el campo que traía el dibujo venía vacío en las 205. Ahora cada lámina
# del banco apunta a un dibujo, y esto comprueba que siga siendo verdad.
run_gate "every bank card has a drawing" python3 tools/draw_flashcards.py --check
# Nace del aviso de seguridad del aula, que llevaba un ⚠️ del teclado JUSTO al
# lado de un icono del set propio diciendo lo mismo: dos avisos y dos dibujos,
# distintos en cada fabricante. Regla 5 del CLAUDE.md.
run_gate "no system emoji used as iconography" python3 tools/check_no_emoji.py
# Nace del vocabulario inglés, que llegó del proyecto de origen con la
# categoría gramatical y la frecuencia INVENTADAS y sin una sola frase. Ahora
# las 3.995 traen categoría, frase entera y frecuencia medida, y esto comprueba
# que ninguna se quede sin ellas, que ninguna salga de las bandas 1k-4k y que
# no vuelva ninguna de las doce que Frank mandó quitar. No reconstruye —eso
# pide WordNet y una descarga— sino que mira el fichero que viaja en el
# repositorio.
run_gate "every corpus word has a part of speech and a whole sentence" \
  python3 tools/build_corpus_ingles.py --check
# Nace de las 1.000 rutinas de familia, que eran cinco textos repetidos
# doscientas veces, idénticos para un bebé de doce meses y para una criatura de
# seis años, y que empezaban por un corchete de máquina y una firma personal.
# Esto comprueba que no vuelvan.
run_gate "family routines sound like a home, not like a leaflet" \
  python3 tools/humaniza_rutinas_fogar.py --check
run_gate "voice corpus in sync" python3 tools/export_voice_corpus.py --check
run_gate "declared tempo matches the pulse track" python3 tools/check_pulse_bpm.py
run_gate "one steady pulse per bar, in both languages" python3 tools/check_pulse_markers.py
run_gate "every locution has a recording" python3 tools/check_voice_coverage.py
run_gate "no recording peaks near full scale" python3 tools/check_voice_levels.py
run_gate "manual PDF and Word match their source" python3 tools/check_manual_build.py
# --offline: la mitad de red vive en su propio workflow, por calendario. Entre
# despliegue y despliegue es cuando un sitio de Pages se apaga sin avisar, y
# eso no lo caza un gate que solo corre cuando alguien empuja.
run_gate "legal pages are what Play Console declares" python3 tools/check_legal_urls.py --offline

# --------------------------------------------------------------- binary gates
if [[ $FAST -eq 0 ]]; then
  run_gate "release APK builds" flutter build apk --release "${BUILD_ARGS[@]}"

  # The one gate that reads the artefact rather than the source. A manifest
  # that removes INTERNET proves nothing on its own: a merged dependency can
  # put it back, and only the built APK settles it.
  run_gate "release APK declares no permission but AndroidX's" bash -c '
    set -euo pipefail
    apk=build/app/outputs/flutter-apk/app-release.apk
    [[ -f "$apk" ]] || { echo "No APK at $apk"; exit 1; }

    sdk="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-/opt/android-sdk}}"
    aapt2=$(ls -1 "$sdk"/build-tools/*/aapt2 2>/dev/null | sort -V | tail -1 || true)
    [[ -n "$aapt2" ]] || { echo "aapt2 not found under $sdk/build-tools"; exit 1; }

    # AndroidX Core injects one permission into every app that uses it, and
    # Flutter requires AndroidX. It is namespaced to this application id, is
    # declared at protectionLevel "signature", and only lets the app register
    # its own non-exported broadcast receivers: it grants access to nothing
    # outside the app and appears in no Play data-safety category. Everything
    # else is a failure — INTERNET included.
    allowed="uses-permission: name=com.earlify.descubreconlua.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION"

    perms=$("$aapt2" dump permissions "$apk" | grep "^uses-permission" || true)
    # aapt2 quotes the value; compare without the quotes.
    unexpected=$(printf %s "$perms" | tr -d "\047" | grep -vxF "$allowed" || true)

    if [[ -n "$unexpected" ]]; then
      echo "The release APK declares permissions that were not approved:"
      echo "$unexpected"
      exit 1
    fi

    echo "OK: the release APK declares no permission beyond the AndroidX"
    echo "    signature-level one. No INTERNET, no network state, nothing."
    printf %s "$perms" | sed "s/^/    /"
  '
fi

# --------------------------------------------------------------------- report
printf '\n\033[1m════ gates ════\033[0m\n'
for name in "${PASSED[@]:-}"; do
  [[ -n "$name" ]] && printf '  \033[32mPASS\033[0m  %s\n' "$name"
done
for name in "${FAILED[@]:-}"; do
  [[ -n "$name" ]] && printf '  \033[31mFAIL\033[0m  %s\n' "$name"
done

if [[ ${#FAILED[@]} -gt 0 ]]; then
  printf '\n\033[31m%d gate(s) failed.\033[0m\n' "${#FAILED[@]}"
  exit 1
fi

printf '\n\033[32mAll gates passed.\033[0m\n'
