#!/usr/bin/env bash
# F-20261126-12: una sola orden regenera todo lo que sale de un script, en el
# orden en que dependen unos de otros. Después: bash tools/generadores_al_dia.sh
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tools/vocab_idade.py --aplicar
python3 tools/gen_gramatica.py
python3 tools/gen_acopros_0_2.py
python3 tools/gen_leccions.py
python3 tools/gen_hogar.py
python3 tools/gen_reto_irmans.py
python3 tools/gen_escenas_retos.py
python3 tools/gen_laminas_palabras.py
python3 tools/export_voice_corpus.py
bash tools/generadores_al_dia.sh
