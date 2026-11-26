#!/usr/bin/env bash
# F-20261126-12: comprueba en segundos que todo lo generado está al día con
# sus fuentes. Lo usan el hook pre-push (tools/git-hooks/pre-push) y el
# primer paso del CI, para que un desfase salga en un minuto y no al final.
set -uo pipefail
cd "$(dirname "$0")/.."
fallos=0
for c in "tools/gen_gramatica.py --check" "tools/gen_acopros_0_2.py --check" \
         "tools/gen_leccions.py --check" "tools/gen_hogar.py --check" \
         "tools/gen_reto_irmans.py --check" "tools/gen_escenas_retos.py --check" \
         "tools/gen_laminas_palabras.py --check" "tools/vocab_idade.py --check" \
         "tools/export_voice_corpus.py --check"; do
  if python3 $c >/dev/null 2>&1; then echo "OK    $c"
  else echo "ROJO  $c"; fallos=$((fallos+1)); fi
done
if [[ $fallos -gt 0 ]]; then
  echo "$fallos sin regenerar. Arreglo: bash tools/regenerar_todo.sh"; exit 1
fi
