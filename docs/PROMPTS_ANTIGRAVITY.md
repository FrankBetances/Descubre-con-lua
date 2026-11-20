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

## P7.9 · Los 16 pares con una palabra fuera del STEAM (19/11/2026)

```text
P7.9 · REHACER 16 PARES PARA QUE LAS DOS PALABRAS NOMBREN EL STEAM (R-STEAM, regla suprema)
Rama: antigravity/escoita (sigue desde 1853a189). Antes: git fetch origin && git merge
origin/claude/upbeat-fermi-3d0utp (trae el gate nuevo y el paso P7.9). Commit y push SOLO ahí,
con «P7.9:» y su fila en el registro. NO toques lib/, test/ ni .claude/. No borres láminas.

Mi prompt anterior decía «al menos una palabra del experimento»: era un error mío. R-STEAM exige
que CADA palabra nombre el experimento STEAM de su mes. El gate tools/check_plan_escoita.py ya lo
comprueba: falla si una palabra no dice qué parte del experimento nombra o si su "steam" la
describe como contraste ajeno.

Rehaz el par (las dos palabras, o solo la segunda) en estas 16 piezas, con un solo fonema
distinto en CMUdict y las reglas de edad de P7.6:
curso_2_3 meses 1 (boot: basta reescribir su "steam" para que nombre el objeto que se hunde),
2, 3, 4, 5, 6, 7, 9, 10; curso_3_4 meses 1, 4, 6, 7, 8, 10; curso_5_6 mes 10.
Ejemplo de lo que vale: «¿Flota o se hunde?» → boat/boot, con boot = la bota que pesa y se hunde.
Si para una pieza no existe un par de un solo fonema con las DOS palabras del experimento, para
y dímelo con la lista de lo que has probado; no metas una palabra ajena.
Actualiza nota, misiones, pista y modelo si cambia el par; láminas nuevas solo si hacen falta,
y docs/escoita-control.md.
En plan_mensual.json, Claude Code ha marcado esos 16 pares con "par.pendiente" (la lección no los
enseña) y ha añadido "modelo.significado" (gl/es de las tres frases del adulto) y una frase
corregida en curso_2_3 mes 9 y curso_5_6 mes 10. Conserva todo eso: si regeneras con
tools/gen_plan_escoita.py, pásalo antes al script. Al rehacer un par, QUITA su "pendiente"; si
cambias una frase del modelo, cambia también su "significado".
ANTES DEL PUSH, en verde: check_plan_escoita, check_pares_en, check_escoita, check_laminas,
check_bundled_assets, check_licencias, check_no_emoji, check_registro_commits, check_ordenes.
ENTREGA: SHA y la tabla de los 16 pares nuevos con qué parte del experimento nombra cada palabra.
```

## P9 · Estimulación del lenguaje y el pensamiento, voz de Valeria y realidad aumentada (20/11/2026)

```text
TRABAJO INTEGRAL DE ANTIGRAVITY · P9 · Estimulación del lenguaje y el pensamiento, voz de Valeria y realidad aumentada
(órdenes de Frank del 20/11/2026, O-20261120-1; R-STEAM de CLAUDE.md, regla suprema)

Repositorio: FrankBetances/Descubre-con-lua. Rama: antigravity/escoita.
Antes de empezar: git fetch origin && git merge origin/main (trae el PR #63 con las 40 piezas) y
git merge origin/claude/upbeat-fermi-3d0utp (trae los pasos P9.0–P9.8 ya en la tabla). Si hay
conflicto, PARA y dímelo.
Commit y push SOLO a antigravity/escoita. Nada de merge a main, PR, reset duro, git add -f, borrar
ficheros ni tools/push_seguro.sh. NO toques .claude/. En este trabajo SÍ puedes tocar lib/ y test/.
Prohibido borrar, quitar o sustituir pantallas, pasos o contenido que ya existe (R-BORRAR): se añade
y se mejora. El paso de escucha que hoy está dentro de la lección se queda.
Cada commit empieza por su paso (P9.0 … P9.8) y lleva su fila en el «Registro de commits» de
docs/PLAN_ANTIGRAVITY.md. Los pasos P9.0–P9.8 ya están en la tabla de pasos.
Todas las edades a la vez: 2-3, 3-4, 4-5 y 5-6 (10 meses cada una) y 0-2 donde se diga. Nada de pilotos.

REGLA SUPREMA: el eje de toda la app es el pensamiento STEAM aplicado a la estimulación del lenguaje.
Cada palabra, frase, pregunta, imagen y escena nombra el experimento STEAM de su mes
(assets/content/steam/steam_do_mes.json, el id en cursos.<curso>.unidades[mes-1].steam de
assets/content/leccions/leccions.json).
Valeria (github.com/FrankBetances/valeria, commit e2a2a5e8) es la fuente: de ella se copia el MÉTODO
y el código que se indica. Su contenido entra orientado al STEAM del mes.
La app tiene ánimo de lucro: nada NC/ND (ni ARASAAC). Sin emoji del sistema. Contenido en JSON, nunca
escrito en los widgets. Todo en gallego y castellano. No subas capturas de Valeria al repositorio (es
público): compáralas fuera.

P9.0 · Plan y control
- docs/estimulacion-plan.md: qué se copia de Valeria (fichero y función) y dónde entra aquí.

P9.1 · Voz como en Valeria (el inglés hoy suena demasiado rápido)
Fuente: valeria/scripts/generate-voice-assets.py (LENGTH_SCALE = tutor 1.0 · child 1.05 · clinical
1.15 · slow 1.6) y valeria/src/valeriaSemanticExpansion.ts (stepLines: cada frase al niño en «child»
y la MISMA frase entera en «slow»; el adulto en «tutor»).
- tools/voice_corpus.py: añade los estilos «child» (1.05) y «slow» de frase (1.6) con los mismos
  valores. Toda frase inglesa que oye el niño (pares, progresiones, modelo del adulto dicho al niño,
  banco de Valeria, juegos de escucha) se genera en «child» Y en «slow». Las instrucciones para el
  adulto siguen en «tutor». Las palabras sueltas, en «slow» como hoy.
- lib/core/audio/voice_id.dart: VoiceStyle.child y la regla estiloIngles igual que en el corpus
  (si las dos reglas no coinciden, el botón desaparece sin aviso).
- BotonEscuchar: al lado de cada frase inglesa para el niño, un botón «Oír amodo / Oír despacio» que
  reproduce la versión «slow», como speakPhraseSlow de Valeria (valeria/src/valeriaVoice.ts).
- Gate nuevo tools/check_voz_lenta.py en tools/gates.sh: falla si una frase inglesa para el niño no
  tiene su versión «slow» en el corpus.
- No generes los audios: deja voice-corpus.json al día (python3 tools/export_voice_corpus.py); los
  sintetiza el workflow voice-assets.

P9.2 · Pensamiento STEAM en cada pieza (lo que falta y Frank pidió: pensamiento crítico y capacidades
cognitivas)
- En cada una de las 40 piezas de assets/content/escoita/plan_mensual.json, un bloque nuevo
  "pensamiento" con cuatro momentos sobre el MISMO experimento y las MISMAS palabras del par y la
  progresión:
    predice  (antes de probar: «¿Que pasará se…? / ¿Qué pasará si…?»),
    proba    (la acción con los materiales del experimento),
    compara  (las dos cosas del par o de la progresión: cuál, cuál más, en qué se parecen),
    explica  (por qué pasó, con una frase modelo corta para el adulto).
  Cada momento lleva: pregunta en inglés corta para el niño (con voz child + slow), su significado
  gl/es, la guía del adulto en gl/es y qué observar.
- Ejemplo «¿Flota o se hunde?»: predice «Boat or boot: which one sinks?» → proba (meter los dos en
  el agua) → compara «The boat floats. The boot sinks.» → explica «The boot is heavy.».
- Ajusta a la edad: 2-3 y 3-4 eligen entre dos (señalar); 4-5 dicen una palabra o frase de dos;
  5-6 explican con «because».
- 0-2: un momento «mira y nota» por proyecto (assets/content de proyectos ACOPROS), sin preguntas
  abiertas. Si no encaja en lo que hay, PARA y dímelo.
- Amplía tools/check_plan_escoita.py: falla si falta un momento, si una palabra no es del STEAM del
  mes o si la pregunta no usa el par o la progresión.

P9.3 · Sección propia «Estimulación da linguaxe e o pensamento / Estimulación del lenguaje y el
pensamiento», bien visible
- Entrada principal en Na casa (Inicio) y en Modo Aula, con su icono propio del set de la app.
- Dentro: el mes y la edad actuales arriba, y los 10 meses navegables. Por mes, cuatro bloques
  ordenados: Escucha (par), Palabras que crecen (progresión), Háblale así (modelo), Pensamos
  (predice → proba → compara → explica), con láminas, voz y «Oír despacio».
- En Modo Aula, la versión para la asamblea (la docente dirige y el grupo responde).
- El paso dentro de la lección se queda y enlaza a la sección.
- Prohibidos en la app «logopedia», «terapia», «trastorno», «clínico» y «diagnóstico»: lo comprueba
  tools/check_finalidade.py.
- Movimiento y tipografía como el resto (lib/core/widgets/movimiento.dart, Fredoka).

P9.4 · Realidad aumentada con Lúa y los sets de Valeria · PRIMERO PREGUNTA
Fuente: valeria/src/steam/arActivities.ts, arScenes.ts, worlds/ (s1_camino … s6_jardin, retos.ts),
luaSolo.ts, engine/LuaLink.ts y valeria/src/valeriaArBridge.ts.
- Antes de escribir código, entrega a Claude Code un informe: qué hace la AR de Valeria, con qué
  motor, qué permisos pide (cámara), qué paquetes y licencias usa, si necesita red y cómo se
  llevaría a Flutter sin permiso INTERNET. La app hoy no pide ningún permiso, y la política de
  privacidad y la ficha de Play lo dicen.
- PARA ahí. Frank decide si se añade la cámara. Sin su «sí», nada de AR en el código.
- Con su «sí»: cada set orientado al STEAM del mes (qué set va con qué experimento), Lúa como guía,
  en gl y es, y en el mismo commit la política de privacidad (docs/privacy.html), el formulario de
  Seguridad de los datos y el gate de permisos actualizados.

P9.5 · Láminas
Una por cada palabra nueva de P9.2 sin lámina, con el método de P7.3 (Fluent Emoji Flat MIT,
Iconify MIT/Apache/CC0, game-icons), clave pal_<palabra>, sin texto. No sobrescribas ninguna.
Hoja de contactos en docs/capturas/hoja_contactos_p9.png, mirada una a una.

P9.6 · Tests
- Widget tests de la sección en gl y es, con escala de texto 1.8.
- El botón «Oír despacio» pide la grabación «slow».
- Las 40 piezas tienen pensamiento en las cuatro edades.

P9.7 · Capturas
App de escritorio Linux (receta de CLAUDE.md §1d), en gl y es:
- Na casa → la sección: 2-3 M1, 3-4 M6, 4-5 M4 y 5-6 M10.
- Modo Aula → la sección.
- Un momento «Pensamos».
En docs/capturas/escritorio/estimulacion-*.png.

P9.8 · Control
docs/estimulacion-control.md: una fila por pieza con curso, mes, STEAM, par, progresión, los cuatro
momentos de pensamiento en inglés, qué parte del experimento nombra cada palabra y por qué encaja en
la edad.

ANTES DE CADA PUSH, en local y en verde:
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --exclude-tags capturas
python3 tools/check_plan_escoita.py
python3 tools/check_pares_en.py
python3 tools/check_escoita.py
python3 tools/check_finalidade.py
python3 tools/check_voz_lenta.py
python3 tools/check_laminas.py
python3 tools/check_bundled_assets.py
python3 tools/check_licencias.py
python3 tools/check_no_emoji.py
python3 tools/check_registro_commits.py
python3 tools/check_ordenes.py
python3 tools/export_voice_corpus.py

ENTREGA (empieza por lo que falta, con números: «de 40 piezas, con pensamiento N; de 6 bloques,
cerrados M»): rama, SHA de cada commit, salida de los gates, rutas de las capturas gl/es, el informe
de AR de P9.4, y lo que no hayas podido hacer y por qué. Claude Code lo revisa antes de integrar.
```

