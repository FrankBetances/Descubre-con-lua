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
# R∞ (Frank, 28/10/2026): ninguna orden suya se da por cumplida sin la
# evidencia de cada criterio.
run_gate "every order marked done has evidence for each criterion" \
  python3 tools/check_ordenes.py
# F-20261126-2: ninguna orden ya mergeada sigue con el merge pendiente.
run_gate "no merged order still says its merge is pending" \
  python3 tools/check_ordenes_mergeadas.py
# F-20261126-4: el plan de mejoras trae mejoras propias de Claude Code.
run_gate "the improvement plan carries Claude Code's own proposals" \
  python3 tools/check_plan_mejoras.py
# F-20261126-5: lo aprobado para Antigravity está guardado en un prompt vigente.
run_gate "approved improvements are saved in a current prompt" \
  python3 tools/check_prompt_vigente.py
# Automejora (Frank, 9/11/2026, O-20261109-2): cada fallo que señala Frank,
# con su causa raíz y una guarda que exista.
run_gate "every failure Frank reported has its guard" python3 tools/check_fallos.py
run_gate "every plan commit is in the audit log (O-20261118-4)" python3 tools/check_registro_commits.py
run_gate "no non-commercial licence in a for-profit app (F-20261118-2)" python3 tools/check_licencias.py
# ACOPROS (O-20261109-4): 0-2 por proyectos, ~20 palabras, frases de dos
# elementos como mucho, sin to be, ya debería saber en holofrase, canción y
# rima, y las cuatro semanas empiezan por el vocabulario y la canción.
run_gate "0-2 by projects, as ACOPROS asked" python3 tools/gen_acopros_0_2.py --check
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
# Nace de la decisión D3 del plan docente (M2.4): ningún texto pide a la
# criatura que repita, traduzca o diga «cómo se dice», en gl, es ni en. El
# modelo es el recast. Los textos de base lo pedían en varios sitios («Can you
# say…?», «Say: …»), y un «repite» escrito en una consigna no lo ve ningún test.
run_gate "nothing asks the child to repeat, translate or say how it's said" \
  python3 tools/check_sin_repetir.py
# Nace de la arquitectura docente (M3.2): el inglés que no es palabra del
# banco vive en un registro con id, gesto y voz. Se deriva de sus fuentes; si
# una orden cambia en su asamblea y no se regenera, rojo.
run_gate "phrase register in sync with its sources" \
  python3 tools/xera_rexistro_frases.py --check
# Nace del mismo plan (M3.1): una unidad por curso y mes como única fuente del
# mes. Antes cada pieza del mes contaba un tema distinto y solo 13 de las 133
# órdenes estaban en el banco. Esto comprueba que lo que una unidad cita
# existe, que su centro es el de la asamblea (D4) y que el núcleo tiene el
# tamaño de su edad. En --estricto: las 50 tienen que estar.
run_gate "every month unit cites what exists and follows its assembly" \
  python3 tools/check_unidades.py --estricto
# F5: la guía de casa de cada mes sale del plan curricular por script; si se
# toca el plan o una unidad sin regenerarla, la casa contaría otro mes.
run_gate "home guide of every month is regenerated from its sources" \
  python3 tools/gen_hogar.py --check
# P11: las lecciones semanales salen del plan curricular por script; si se
# toca el plan sin regenerarlas, la lección enseñaría otra unidad.
run_gate "weekly lessons are regenerated from the plan" \
  python3 tools/gen_leccions.py --check
run_gate "sibling challenges are regenerated (M3)" \
  python3 tools/gen_reto_irmans.py --check
run_gate "every week in 5 ages has 3 STEAM layers, 6 unique M2 routines and sibling challenges" \
  python3 tools/check_capas_semana.py
run_gate "levels, review returns and age ceilings pass audit" \
  python3 tools/auditoria_niveles.py --gate
# O-20261126-5 (punto 6): ninguna sustitución de vocabulario por edad sin aplicar.
run_gate "age vocabulary substitutions are applied" python3 tools/vocab_idade.py --check
# F-20261126-6: un criterio con evidencia en la tabla de control no sigue abierto sin motivo.
run_gate "no criterion is closed with an evidence that says it is not done (F-20261126-13)" python3 tools/check_evidencia_honesta.py
run_gate "done criteria are not left open" python3 tools/check_ordenes_abertas.py
# F-20261126-7: un solo prompt vigente para Antigravity, entero.
run_gate "one complete current prompt for Antigravity" python3 tools/check_prompt_unico.py
# F-20261126-9: el manual enseña cada pantalla, en gallego y castellano.
run_gate "the manual shows every screen in gl and es" python3 tools/check_manual_pantallas.py
# La gramática del curso (Frank, 28/10/2026): los 20 puntos de A1-A2 en las
# cinco edades, sin bajar de una edad a la siguiente.
run_gate "course grammar covers A1-A2 across the five ages" \
  python3 tools/gen_gramatica.py --check
# Nace de O5 (M5.1): el microcuento es una conversación sobre el núcleo, no
# otro vocabulario. Comprueba que lo que dice Lúa sale del núcleo, que hay
# tríada, guion de recast para cinco respuestas y pregunta de casa por edad, y
# que nada pide repetir. Con --estricto desde F1: las 140 láminas están, y un
# microcuento sin todas sus láminas no se abre en la app.
run_gate "every microcuento talks about its unit's core words and is drawn" \
  python3 tools/check_microcuentos.py --estricto
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

# Los nombres del inicio y de los dos portales son contenido: viven en
# assets/content/nomes/nomes_portais.json y el Dart sale de ahí. Un nombre
# cambiado a mano en el Dart, o en el JSON sin volver a generar, pone esto rojo.
run_gate "portal names come from their JSON" python3 tools/xera_nomes.py --check
# Nace del planificador de la rama UI, que multiplicaba 5 × 4 × 4 × 10 y
# enseñaba «800» con veinte palabras de muestra escritas en él: el número salía
# bueno aunque el curso no lo tuviera. Ahora se CUENTA en assets/content/tpr/,
# curso a curso, y ninguna palabra puede ser nueva dos veces en los cinco.
run_gate "English: 5 new words a day, 800 per course, 4,000 from 0 to 6" \
  python3 tools/planificador_5_palabras.py --check
# Nace de un encargo de Frank: «no tiene sentido un cuento que no tenga las
# palabras del día». El cuento de cada semana se lee los mismos días que sus
# palabras, y no traía ninguna. Ahora trae las veinte, entre “…” y declaradas
# en su página, y esto comprueba que siga siendo así.
run_gate "every weekly story carries its week's 20 English words" \
  python3 tools/check_contos_palabras.py
# Nace de otro: una criatura que llega nueva a 4-5 o 5-6 no puede seguir
# órdenes hechas con palabras que el curso dio antes. Lo que cada orden da por
# sabido sale del curso y de las asambleas, con la revisión a mano escrita en
# el mismo JSON. Si cambia una orden, una palabra o su gesto y no se vuelve a
# generar, o si queda una decisión de la revisión que ya no hace falta, rojo.
run_gate "what each order takes as known comes from the course" \
  python3 tools/xera_ponte_ao_dia.py --check
run_gate "voice corpus in sync" python3 tools/export_voice_corpus.py --check
run_gate "declared tempo matches the pulse track" python3 tools/check_pulse_bpm.py
run_gate "one steady pulse per bar, in both languages" python3 tools/check_pulse_markers.py
run_gate "every locution has a recording" python3 tools/check_voice_coverage.py
# Y el contrario: que no queden grabaciones de locuciones que ya no existen.
# Al recortar el vocabulario inglés a las 4.000 de uso habitual quedaron 1.275
# ficheros huérfanos, 9 MB de APK que nadie reproduce. El gate de cobertura no
# los veía: un fichero de más no es una locución de menos.
run_gate "no recording left over from content that is gone" \
  python3 tools/prune_voice_assets.py --check
run_gate "no recording peaks near full scale" python3 tools/check_voice_levels.py
run_gate "manual PDF and Word match their source" python3 tools/check_manual_build.py
# --offline: la mitad de red vive en su propio workflow, por calendario. Entre
# despliegue y despliegue es cuando un sitio de Pages se apaga sin avisar, y
# eso no lo caza un gate que solo corre cuando alguien empuja.
run_gate "legal pages are what Play Console declares" python3 tools/check_legal_urls.py --offline
run_gate "every scene has its image (O-20261111-1)" python3 tools/check_imagenes_escenas.py
run_gate "allowed image banks, pinned SHAs, licences and credits (O-20261111-4)" python3 tools/check_banco_laminas.py
run_gate "every taught piece has its own picture (O-20261111-2)" python3 tools/check_laminas_leccion.py --resumo --tope-tpr
run_gate "every English minimal pair in escoita contrasts one phoneme (CMUdict)" python3 tools/check_pares_en.py
run_gate "the listening bank copied from Valeria is whole and clean (O-20261119-8)" python3 tools/check_escoita.py
run_gate "an educational game, no clinical words in assets, lib or public pages (O-20261118-3)" python3 tools/check_finalidade.py
run_gate "one listening piece per month and age, none repeated (O-20261119-8)" python3 tools/check_plan_escoita.py
run_gate "every English phrase for the child has a slow version (O-20261120-1)" python3 tools/check_voz_lenta.py
run_gate "Galician and Spanish use neno/nena and niño/niña (O-20261122-1)" python3 tools/check_lexico_galicia.py
run_gate "Frank's brakes work with real sentences (F-20261119-5)" python3 tools/check_hooks.py

# --------------------------------------------------------------- binary gates
if [[ $FAST -eq 0 ]]; then
  run_gate "release APK builds" flutter build apk --release "${BUILD_ARGS[@]}"

  # The one gate that reads the artefact rather than the source. A manifest
  # that removes INTERNET proves nothing on its own: a merged dependency can
  # put it back, and only the built APK settles it.
  run_gate "release APK declares only approved permissions (AndroidX + CAMERA)" bash -c '
    set -euo pipefail
    apk=build/app/outputs/flutter-apk/app-release.apk
    [[ -f "$apk" ]] || { echo "No APK at $apk"; exit 1; }

    sdk="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-/opt/android-sdk}}"
    aapt2=$(ls -1 "$sdk"/build-tools/*/aapt2 2>/dev/null | sort -V | tail -1 || true)
    [[ -n "$aapt2" ]] || { echo "aapt2 not found under $sdk/build-tools"; exit 1; }

    # AndroidX Core injects DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION.
    # P10.4 adds android.permission.CAMERA for optional AR scenes and face mirror
    # (processed in volatile RAM only; zero files written, zero network).
    # Everything else is a failure — INTERNET included.
    allowed_androidx="uses-permission: name=com.earlify.descubreconlua.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION"
    allowed_camera="uses-permission: name=android.permission.CAMERA"

    perms=$("$aapt2" dump permissions "$apk" | grep "^uses-permission" || true)
    # aapt2 quotes the value; compare without the quotes.
    unexpected=$(printf %s "$perms" | tr -d "\047" | grep -vxF "$allowed_androidx" | grep -vxF "$allowed_camera" || true)

    if [[ -n "$unexpected" ]]; then
      echo "The release APK declares permissions that were not approved:"
      echo "$unexpected"
      exit 1
    fi

    echo "OK: the release APK declares only AndroidX signature-level receiver"
    echo "    permission and CAMERA. No INTERNET, no network state, nothing else."
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
