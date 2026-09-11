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

# ---------------------------------------------------------------- Dart gates
run_gate "dart format" dart format --output=none --set-exit-if-changed .
run_gate "flutter analyze" flutter analyze
run_gate "flutter test" flutter test

# ------------------------------------------------------------- content gates
run_gate "contact address" python3 tools/check_contact_email.py
run_gate "voice corpus in sync" python3 tools/export_voice_corpus.py --check
run_gate "declared tempo matches the pulse track" python3 tools/check_pulse_bpm.py
run_gate "every locution has a recording" python3 tools/check_voice_coverage.py

# --------------------------------------------------------------- binary gates
if [[ $FAST -eq 0 ]]; then
  run_gate "release APK builds" flutter build apk --release

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
