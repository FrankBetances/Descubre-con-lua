#!/usr/bin/env bash
# Empuja a la rama lo que se acabe de sintetizar.
#
# Existe porque ahora el inglés se sintetiza POR TANDAS y hay que empujar
# después de cada una. Antes esto vivía suelto dentro del workflow, en un solo
# paso al final: con las 16.500 locuciones de las 8.000 palabras, un solo paso
# al final significa que si el runner se acaba, se va TODO lo sintetizado.
#
#   tools/ci_push_voice.sh <rama>
#
# Solo AÑADE ficheros de audio, así que rebasar encima de lo que haya llegado
# a la rama mientras tanto no puede chocar con nada.
set -uo pipefail

RAMA="${1:?falta la rama}"

git config user.name 'github-actions[bot]'
git config user.email 'github-actions[bot]@users.noreply.github.com'
git add assets/voice voice-corpus.json voice-assets-manifest.*.json assets/content

if git diff --cached --quiet; then
  echo 'Nada que empujar: todas las grabaciones ya estaban.'
  exit 0
fi

git commit -m 'chore(voice): synthesise offline voice assets (Celtia gl / Sharvard es / LJSpeech en)'

# Si alguien empuja a la rama mientras se sintetiza, el push se rechaza con
# «fetch first» y las grabaciones se van con el runner: pasó una vez y se
# perdieron 659 locuciones ya sintetizadas.
for intento in 1 2 3; do
  git pull --rebase origin "$RAMA"
  if git push origin HEAD:"$RAMA"; then
    echo "Empujado al intento $intento."
    exit 0
  fi
  echo "::warning::Push rechazado en el intento $intento; se reintenta."
  sleep $((intento * 5))
done

echo "::error::No se pudo empujar la tanda de grabaciones."
exit 1
