# Prompts para Antigravity

Los prompts que Frank pega en Antigravity, guardados aquí para que no se
pierdan y para que el gate compruebe que cada paso que nombran existe en la
tabla de pasos de `docs/PLAN_ANTIGRAVITY.md` (F-20261119-7,
`tools/check_registro_commits.py`).

## P7.6–P7.8 · Trabajo integral: juegos de escucha y palabras orientados al STEAM (19/11/2026)

```text
TRABAJO INTEGRAL DE ANTIGRAVITY · Juegos de escucha y palabras orientados al STEAM
(O-20261119-8, O-20261118-3 y R-STEAM de CLAUDE.md, regla suprema)

Repositorio: FrankBetances/Descubre-con-lua. Rama: antigravity/escoita (sigue desde 8132af6a).
Antes de empezar: git fetch origin && git merge origin/claude/upbeat-fermi-3d0utp (trae las reglas
R-FRANK, el banco de Valeria restaurado, los gates nuevos y los pasos P7.6–P7.8 en la tabla).
Si hay conflicto, PARA y dímelo.
Commit y push SOLO a antigravity/escoita. Nada de merge a main, PR, reset --hard, git add -f,
borrar ficheros ni tools/push_seguro.sh. NO toques lib/, test/ ni .claude/.
Cada commit empieza por su paso (P7.6, P7.7, P7.8) y lleva su fila en el «Registro de commits» de
docs/PLAN_ANTIGRAVITY.md.

REGLA SUPREMA: el eje de toda la app es el pensamiento STEAM aplicado a la estimulación del lenguaje.
Cada palabra, par, progresión, frase, nota, misión y lámina nombra el experimento STEAM de su mes.
Si una palabra no sale del experimento, no entra. De Valeria se copia el MÉTODO (par de un solo
fonema, misión para el adulto, concepto → parte → acción → cualidad), no sus palabras.
Juego educativo: prohibidas «logopedia», «terapia», «trastorno», «clínico», «diagnóstico».
La app tiene ánimo de lucro: nada NC/ND (ni ARASAAC).

P7.6 · Rehacer las 40 piezas de assets/content/escoita/plan_mensual.json
- En la rama de Claude Code el fichero llega con "piezas": [] (pendiente); tu versión de 8132af6a
  es la base. Al mergear, quédate con TUS 40 piezas y corrígelas.
- Cursos curso_2_3, curso_3_4, curso_4_5 y curso_5_6, meses 1 a 10 (1 = septiembre).
- Para cada pieza, abre cursos.<curso>.unidades[mes-1].steam en assets/content/leccions/leccions.json
  y su experimento (mismo id) en assets/content/steam/steam_do_mes.json: materiales, pasos y lo que
  se observa.
- PAR: dos palabras que difieran en EXACTAMENTE un fonema (CMUdict) y al menos una nombre algo del
  experimento. Reglas de edad: 2-3 y 3-4 vocales y oclusivas; 4-5 añade fricativas y /k/–/t/;
  5-6 añade grupos iniciales (sn-, st-, sp-, pl-, tr-) y /l/–/r/ inicial. Prohibido /r/ tras vocal,
  grupos finales y sonoridad final.
- PROGRESIÓN: las CUATRO palabras (concepto, parte, acción, cualidad) son del experimento.
  Ej.: «Hacemos barro» → mud: water, mix, sticky. «Escuchar el corazón» → heart: chest, beat, fast.
- MODELO DEL ADULTO: 3 frases que crecen y hablan del experimento («Mud. Wet mud. We mix the wet mud.»).
- NOTA, MISIÓN DE ACIERTO, MISIÓN DE FALLO y PISTA en gl y es, con el experimento dentro.
- Campos nuevos obligatorios:
  - en la pieza: "steam": {"id": "<id del mes>", "titulo": {"gl": "...", "es": "..."}};
  - en cada palabra (a, b y las 4 fases): "steam": {"gl": "...", "es": "..."}, con qué parte del
    experimento nombra.
- Ninguna pareja ni progresión repetida en las 40. Las piezas que ya nombran el experimento se
  quedan; el resto se rehace. Mínimo a rehacer: 2-3 M02 M05 M06 M08 M10; 3-4 M02 M03 M04 M05 M07
  M08 M09; 4-5 M01 M02 M04 M05 M06 M07 M10; 5-6 M02 M07 M09 M10, más toda progresión que no nombre
  el experimento.
- Amplía tools/check_pares_en.py y tools/banco/cmudict_escoita.txt con las palabras nuevas.

P7.7 · Láminas
- Una por cada palabra nueva de P7.6 que no tenga lámina, con el método de P7.3
  (tools/banco_a_lamina.py, Fluent Emoji Flat MIT, Iconify MIT/Apache/CC0, game-icons),
  clave pal_<palabra>, sin texto. NO borres ni sustituyas láminas existentes.
- Además, las palabras del banco de Valeria que siguen sin lámina en assets/content/escoita/
  valeria_gl.json, valeria_es.json y valeria_en.json (campo "lamina": null). Cuando existan,
  vuelve a correr python3 tools/importar_valeria_escoita.py /tmp/valeria (con
  git clone --depth 1 https://github.com/FrankBetances/valeria /tmp/valeria) y baja
  tools/tope_escoita_sen_lamina.txt al número que dé tools/check_escoita.py.

P7.8 · Control
- docs/escoita-control.md: una fila por pieza con curso, mes, STEAM, par, fonema, progresión,
  láminas, fuente (valeria o nueva), «qué del STEAM nombra cada palabra» y por qué encaja en la edad.
- Hoja de contactos de las láminas nuevas en docs/capturas/hoja_contactos_escoita_2.png, mirada
  una a una.

ANTES DE CADA PUSH, en local y en verde:
python3 tools/check_pares_en.py
python3 tools/check_plan_escoita.py
python3 tools/check_escoita.py
python3 tools/check_licencias.py
python3 tools/check_no_emoji.py
python3 tools/check_laminas.py
python3 tools/check_bundled_assets.py
python3 tools/check_registro_commits.py
python3 tools/check_ordenes.py
python3 tools/export_voice_corpus.py
(los audios los genera el CI; tú solo dejas el corpus al día)

ENTREGA: rama, SHA, cuántas piezas has cambiado y cuáles, la tabla de las 40 con su STEAM, las
láminas nuevas y lo que no hayas podido hacer y por qué. Claude Code lo revisa antes de integrar.
```
