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

## P10 · Versión definitiva para el piloto (22/11/2026)

Los pasos P10.0–P10.9 ya están en la tabla de pasos (los añadió Claude Code al guardar este prompt);
en P10.0 Antigravity no los vuelve a añadir.

```text
TRABAJO INTEGRAL DE ANTIGRAVITY · P10 · VERSIÓN DEFINITIVA PARA EL PILOTO
(órdenes de Frank del 22/11/2026, O-20261122-1; R-STEAM de CLAUDE.md, regla suprema)

Frank ha dado por bueno todo el trabajo anterior. Esta es la versión definitiva para probar ya.
El 100 % del trabajo lo haces tú, Antigravity. Claude Code solo valida y, si algo está mal, te lo
devuelve.

REPOSITORIO Y RAMA
Repositorio: FrankBetances/Descubre-con-lua. Rama: antigravity/escoita.
Antes de empezar:
  git fetch origin && git merge origin/main && git merge origin/claude/upbeat-fermi-3d0utp
Si hay conflicto, PARA y dímelo.
Commit y push SOLO a antigravity/escoita. Prohibido: merge a main, PR, reset duro, git add -f,
tools/push_seguro.sh. NO toques la carpeta de configuración de Claude Code (.claude).
SÍ puedes tocar lib/, test/, android/, assets/, docs/ y tools/.

PROHIBIDO BORRAR, salvo lo que este prompt nombra (R-BORRAR). Se cambia texto; no se quitan
pantallas, pasos ni contenido.

REGISTRO DE COMMITS
Los pasos P10.0 … P10.9 ya están en la tabla de pasos de docs/PLAN_ANTIGRAVITY.md. Cada commit
empieza por su paso («P10.3: …») y lleva su fila en el «Registro de commits».

REGLAS DE CONTENIDO
- Todas las edades a la vez: 0-2, 2-3, 3-4, 4-5 y 5-6. Nada de pilotos por edad.
- Todo en gallego y castellano.
- La app tiene ánimo de lucro: nada NC/ND (ni ARASAAC). Valen MIT, Apache 2.0, BSD, CC0, CC BY y
  OFL.
- Sin emoji del sistema.
- Contenido en JSON, nunca escrito en los widgets.
- Prohibidas en la app «logopedia», «terapia», «trastorno», «clínico» y «diagnóstico».
- Ningún texto exige al niño que repita, traduzca o «diga cómo se dice».

══════════════════════════════════════════════════════════════════════════════

P10.0 · Plan
- docs/p10-plan.md: qué vas a cambiar en cada paso y con qué gate lo compruebas.

P10.1 · En Galicia se dice NENO e NENA, no «criatura» ni «crianza»
Orden de Frank: «en Galicia no se dice criatura ni crianzas ni nada de eso, aquí se habla de neno o
nena».
- En TODO texto que se ve o se oye, se cambia:
    gallego: criatura/criaturas/crianza/crianzas → neno ou nena / nenos e nenas / o neno ou a nena
      (concordancia correcta en cada frase);
    castellano: criatura/criaturas/crianza/crianzas → niño o niña / niños y niñas / el niño o la
      niña (concordancia correcta).
- Cuando la frase lo permita sin quedar pesada, «o neno ou a nena» puede ir en plural o como
  «nenos e nenas».
- Lugares:
    assets/content/** (JSON gl/es);
    textos en lib/ (nombres de portales, nomes_*.dart, ARB si hay);
    docs/manual-casos-de-uso.html;
    docs/privacy.html, docs/terms.html, docs/index.html;
    README.md y STATUS.md;
    las fichas de Play que haya en docs/.
- Los identificadores internos (nombres de clase, del fichero criancas.json, claves JSON) NO se
  renombran: romperían los datos guardados. Solo cambia lo que se ve o se oye.
- Gate nuevo tools/check_lexico_galicia.py en tools/gates.sh. Falla si «criatura», «criaturas»,
  «crianza», «crianzas» o «criança» aparecen en texto visible de assets/content, en las cadenas de
  lib/ o en docs/*.html y README.md (insensible a mayúsculas). Excepciones solo para
  identificadores de código, con una lista explícita y justificada en el propio gate.
- Corpus de voz: python3 tools/export_voice_corpus.py. Los audios gl/es nuevos los sintetiza el
  workflow voice-assets. Las grabaciones que queden sin texto NO las borres: me lo dices y Frank
  decide.

P10.2 · Fuera «Edición Vigo»: la app sirve para toda Galicia (piloto en Ourense)
Orden de Frank: «tenemos que cambiar el tema de edición Vigo y dejarlo simplemente sin decir que es
para Vigo porque lo vamos a utilizar en Orense para un piloto».
- Quita «Edición Vigo» y cualquier «para Vigo», «escuelas infantiles municipales de Vigo», «de
  Vigo» como destino. Lugares:
    bienvenida (debajo del logo);
    splash;
    créditos;
    nombres de portales;
    AndroidManifest (android:label);
    README.md;
    manual (HTML, PDF y Word);
    privacy.html, terms.html, index.html;
    fichas de Play;
    textos de la app.
- El nombre queda «Descubre con Lúa».
- Donde hacía falta destino, «escolas infantís de Galicia / escuelas infantiles de Galicia».
- Procedencia: startTIC y el Consorcio da Zona Franca de Vigo SE QUEDAN en créditos y README («nace
  dentro del programa startTIC»).
- El Concello de Vigo como destinatario SE QUITA del texto. Si aparece como logotipo o en algún
  convenio, PARA y pregúntamelo.
- Contenido con lugares de Vigo (Castrelos, Samil, las Cíes, el Castro, la ría de Vigo…):
  inventario en docs/p10-vigo.md (fichero, texto, propuesta) y cambio a referentes gallegos
  neutros que no rompan el STEAM ni la rima («o parque», «a praia», «o río», «o monte»).
  Gallego y castellano a la vez.
- No cambies el applicationId ni el nombre del paquete Android (rompería la ficha de Play).
- Gate: amplía tools/check_lexico_galicia.py para que falle si «Edición Vigo» o «Edición
  Vigo» vuelve a aparecer en texto visible.

P10.3 · Una sola entrada de Estimulación en Hoxe
Orden de Frank: «si hoxe se repite dos veces hay que quitarlo de uno de los dos lugares y
evidentemente que será el de abajo».
- QUITA la EntradaEstimulacionCard de ABAJO en lib/features/familias/views/hoxe_familias_screen.dart
  (la que va después de LeccionDaSemanaCargada) y en
  lib/features/docentes/views/hoxe_docentes_screen.dart (la que va antes de «A sesión de 45
  minutos»).
- Se queda la de ARRIBA (compacta: true).
- test/features/estimulacion_test.dart: findsOneWidget para entrada_estimulacion_casa y
  entrada_estimulacion_aula, y sigue exigiendo que esté arriba sin scroll.
- test/features/ux_l3_test.dart («Learn de Duolingo, sen baixar, a 412×915») tiene que seguir en
  verde.

P10.4 · Realidad aumentada de Valeria, adaptada al aprendizaje del inglés (ORDEN, con cámara)
Orden de Frank: «trajeras aquí la RA que creamos con la Valeria adaptada al aprendizaje de inglés».
Fuente: github.com/FrankBetances/valeria, commit e2a2a5e8:
  src/steam/arActivities.ts, src/steam/arScenes.ts, src/steam/worlds/ (s1_camino … s6_jardin,
  retos.ts), src/steam/luaSolo.ts, src/steam/engine/LuaLink.ts, src/valeriaArBridge.ts y el módulo
  nativo Android de Valeria (ValeriaArSceneActivity, ValeriaArActivity, ValeriaArSceneLaunch).
Tu informe previo: docs/estimulacion-ar-informe.md.
- Módulo nativo Kotlin en android/ llamado por MethodChannel, con los MISMOS paquetes de Valeria,
  todos Apache-2.0:
    com.google.ar:core;
    com.google.android.filament:filament-android, gltfio-android y filament-utils-android;
    com.google.mediapipe:tasks-vision;
    el modelo face_landmarker.task empaquetado, con su SHA-256 fijado.
  Los .glb y el .task dentro del APK, sin descargas.
- Sin permiso INTERNET ni de red: se mantienen los tools:node="remove". Se añade
  android.permission.CAMERA, con <uses-feature android:name="android.hardware.camera.ar"
  android:required="false"/> y com.google.ar.core «optional».
- Si el aparato no tiene ARCore, la app lo dice en gl/es y ofrece la versión sin cámara (las
  láminas y la voz). Nunca se cierra ni se queda en blanco.
- Adaptación al inglés:
    cada escena de RA va con el experimento STEAM del mes y la edad. Mapa por fenómeno:
    materia → S0/S5, acústica → S2/S4, cinemática → S1/S3, óptica → S6, lógica → S8–S11 y
    L02–L05. Cada mes de 2-3 a 5-6 años, una escena.
    Lúa es la guía. Dice en inglés las palabras del par y de la progresión de ese mes
    (assets/content/escoita/plan_mensual.json), con la voz de niño y «Oír despacio».
    La persona adulta lee en gl/es qué hacer.
    El niño toca, señala o hace el gesto. Nunca se le exige que repita.
    Las actividades de cara (cámara frontal, L01/L07, ar1–ar6) van con frases inglesas del mes
    («Open your mouth», «Smile», «Big eyes») con voz de niño y lenta.
    Sin reconocimiento de voz.
- Sin finalidad sanitaria. Ningún dato de la cámara sale ni se guarda: ni foto, ni vídeo, ni
  puntos de la cara. Todo en memoria y se descarta. Un test lo comprueba.
- Entrada:
    en la sección «Estimulación da linguaxe e o pensamento», un quinto bloque «Realidade aumentada
    con Lúa / Realidad aumentada con Lúa» por mes;
    y en Explorar (casa) y Recursos (aula).
- En EL MISMO commit:
    docs/privacy.html: la cámara, para qué, que no se guarda nada y que no sale del móvil;
    docs/terms.html si hace falta;
    la ficha de Seguridad de los datos de Play en docs/ (o crea docs/play-seguridad-datos.md con lo
    que hay que declarar);
    README.md (sección Privacidad);
    CLAUDE.md, sección «Privacidad declarada = privacidad compilada» → NO la toques: me pasas el
    texto propuesto y Claude Code se lo da a Frank;
    el gate de permisos del APK en tools/gates.sh y .github/workflows/ci.yml, que hoy solo acepta
    los de AndroidX: se añade CAMERA a la lista permitida y NADA más.
- Créditos y LICENSE.md: ARCore SDK, Filament y MediaPipe (Apache-2.0), con su aviso NOTICE si lo
  tienen. tools/check_licencias.py en verde.
- Tests:
    el canal nativo con un mock: abrir escena, que no haya cámara, que no haya ARCore;
    la pantalla de entrada en gl y es a escala 1.8;
    que no se guarda nada (ningún fichero nuevo en getFilesDir).

P10.5 · Inglés de las frases de cada palabra
- Revisa todas las frases inglesas que suenan en voz de niño: los «frase» de cada palabra de las
  progresiones y las tres del modelo del adulto en plan_mensual.json, y los textos de la RA de
  P10.4. Que sean cortas, gramaticales, naturales para un niño de esa edad y del experimento del
  mes.
- Corrige las que no lo sean y su «significado» gl/es (también en
  assets/content/significados/significados.json).
- Lista de cambios en docs/p10-ingles.md (antes → después y por qué).
- check_plan_escoita.py, check_pares_en.py, check_voz_lenta.py y test/core/significados_test.dart
  en verde.

P10.6 · Manual
Regla 1 de CLAUDE.md.
- Regenera TODAS las capturas:
  flutter test --tags capturas --update-goldens test/capturas_test.dart
- Mira las que cambian.
- Añade captura de la sección de Estimulación y de la entrada de RA.
- Quita «Vigo» como destino y «criatura/crianza» del manual.
- Reconstruye el PDF (node docs/build-pdf.js) y el Word (python3 docs/build-docx.py) y mira el PDF
  página a página. Ninguna figura se sale de la hoja.
- tools/check_manual_build.py en verde.

P10.7 · Capturas de escritorio
Receta de CLAUDE.md §1d, en gl y es, en docs/capturas/escritorio/p10-*.png. Mira cada una.
- Inicio sin «Edición Vigo».
- Na casa → Hoxe con UNA entrada de Estimulación.
- Modo Aula → Hoy con una.
- La sección con «neno/nena».
- El bloque de RA (en escritorio sale la versión sin cámara; dilo).

P10.8 · Control final
docs/p10-control.md, criterio por criterio, con su evidencia: el gate, el test o la captura.
- P10.1: cuántos textos cambiados, por fichero.
- P10.2: inventario de Vigo y qué se cambió.
- P10.3: el test.
- P10.4: paquetes, licencias, permisos del APK (salida de aapt2 dump permissions si tienes SDK; si
  no, dilo).
- P10.5: la lista.
- P10.6: páginas del PDF miradas.
- P10.7: rutas de las capturas.

P10.9 · Pendientes
Actualiza docs/PENDIENTE.md: quita lo hecho y deja solo lo que de verdad falta. Por ejemplo, probar
en un Android real con ARCore, que solo puede hacer Frank.

══════════════════════════════════════════════════════════════════════════════

ANTES DE CADA PUSH, en local y en verde, y pega la salida en la entrega:
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --exclude-tags capturas
python3 tools/check_lexico_galicia.py
python3 tools/check_plan_escoita.py
python3 tools/check_pares_en.py
python3 tools/check_escoita.py
python3 tools/check_finalidade.py
python3 tools/check_voz_lenta.py
python3 tools/check_sin_repetir.py
python3 tools/check_laminas.py
python3 tools/check_bundled_assets.py
python3 tools/check_licencias.py
python3 tools/check_no_emoji.py
python3 tools/check_contact_email.py
python3 tools/check_legal_urls.py --offline
python3 tools/check_manual_build.py
python3 tools/check_registro_commits.py
python3 tools/check_ordenes.py
python3 tools/export_voice_corpus.py --check
python3 tools/prune_voice_assets.py --check   (si dice que sobran, NO borres: dímelo)
bash tools/gates.sh --fast

ENTREGA
Empieza por lo que falta, con números: «de 10 pasos, cerrados N; textos con criatura/crianza que
quedan: 0; referencias a Vigo como destino que quedan: 0; escenas de RA: N de 40». Después:
- rama y SHA de cada commit;
- salida entera de los gates;
- rutas de las capturas gl/es;
- el texto propuesto para CLAUDE.md (privacidad con cámara);
- lo que no hayas podido hacer y por qué.
Claude Code lo valida y lo mergea a main.
```


## P11 · Niveles por edad, varios niños, prueba de entrada, repaso y ajuste dinámico (26/11/2026)

**Vigente: el «P11 · Prompt único» de más abajo**, que junta los doce pasos y pone la prueba de entrada dentro del alta, una sola vez (Frank, 26/11/2026). Este texto se conserva como historia.

Los pasos P11.0–P11.11 ya están en la tabla de pasos (los añadió Claude Code al guardar este prompt);
Antigravity no los vuelve a añadir. D1-D6 aprobadas por Frank el 26/11/2026 (O-20261126-1).

```text
TRABAJO INTEGRAL DE ANTIGRAVITY · P11 · NIVELES POR EDAD, VARIOS NIÑOS, PRUEBA DE ENTRADA, REPASO Y AJUSTE DINÁMICO

Eres Antigravity y trabajas en FrankBetances/Descubre-con-lua: app Android en Flutter, solo educativa, con Juega con Lúa (la docente, en la asamblea) y Na casa / Academy (las familias), en gallego y castellano, para estimular el inglés. Tú haces el 100 % del trabajo; Claude Code solo revisa e integra. No mergeas nada en main.

DECISIONES DE FRANK (26/11/2026, «Apruebo d1 a d6»): D1 a D6 aprobadas tal como las recomienda docs/AUDITORIA_NIVELES_Y_REPASO.md, secciones 3 y 4b. D4 incluye sustituir las 199 palabras actuales de 0-2. Lo que el plan propone es ahora la orden; no lo cambias por tu criterio.

P11.0 · ANTES DE TOCAR NADA
Lee enteros CLAUDE.md, docs/AUDITORIA_NIVELES_Y_REPASO.md (secciones 2, 3, 4 y 4b) y las órdenes O-20261126-1, O-20261126-2 y O-20261126-3 de docs/ORDENES.md. Crea la rama antigravity/niveles desde main. Haz git status y git log --oneline -5; si hay cambios sin commit que no son tuyos, para y díselo a Frank. Corre python3 tools/auditoria_niveles.py y copia la salida en docs/p11-control.md como punto de partida (hoy marca 30 incumplimientos).

REGLAS QUE NO SE NEGOCIAN (CLAUDE.md)
1. Prohibido borrar, quitar, vaciar o sustituir nada que Frank no haya pedido con palabras en ORDENES.md. Lo autorizado: las 199 palabras de 0-2 (D4) y la asignación de los 48 puntos por mes (D1); los 48 puntos siguen todos en la app.
2. R-STEAM: cada palabra, frase, capa, ítem de la prueba y cuento nuevo nombra el STEAM de su mes y qué parte del experimento trabaja.
3. Prohibido rellenar (R∞.3): no se repite, se estira ni se copia entre cursos para que cuadre una cifra. Si falta material, se escribe en docs/p11-control.md y se sigue con lo demás.
4. El niño no usa la pantalla: la app propone a la persona adulta y la persona adulta marca lo que ve.
5. Nada sanitario: nunca «examen», «diagnóstico», «evaluación», «trastorno», «retraso» ni «puntuación». tools/check_finalidade.py en verde.
6. Ningún dato sale del móvil, sin permiso INTERNET. Todo campo nuevo de criancas.json en día o en semana del curso, nunca con hora. En el mismo commit: docs/privacy.html, docs/play-seguridad-datos.md, README.md y test/core/criancas_privacidad_test.dart.
7. Léxico de Galicia: neno/nena, niño/niña; nunca «criatura» ni «crianza» visibles; nunca «Edición Vigo».
8. Sin emoji; sin licencias NC ni ND.
9. Texto con audio que cambia: corpus de voz exportado en el mismo commit (tools/export_voice_corpus.py); frases inglesas para el niño con voz child y versión lenta (tools/check_voz_lenta.py).
10. Cada commit empieza por «P11.n:» y añade su fila al Registro de commits de docs/PLAN_ANTIGRAVITY.md (la última fila lleva «este»; el commit siguiente la cambia por el SHA). tools/check_registro_commits.py en OK antes de cada push.
11. Antes de cada push: tools/gates.sh y flutter test completos en local. Si algo va a fallar, no se empuja.
12. Cada informe empieza por lo que falta. Lo que no has visto en la app se dice con estas palabras: «esto no lo he verificado».

P11.1 · FAMILIA CON VARIOS NIÑOS (F1)
Na casa → alta: al guardar el primer niño, «Hai outro neno ou nena na casa? / ¿Hay otro niño o niña en casa?», y deja registrar más sin salir. Na casa → Hoxe: arriba, una fila con cada niño de la casa (su Lúa, su nombre y su curso) y debajo de cada uno, en una línea, lo que le toca hoy; un toque cambia el niño activo y Hoxe, Calendario y Explorar pasan a su curso. La lista de cursos sale de la hoja del chip: el curso solo se cambia dentro de «Editar a …», con confirmación. Premios, observaciones y repaso, siempre del niño activo. Se guarda mes y año de nacimiento, sin día (D3); en septiembre la app propone pasar al curso siguiente y la persona adulta confirma.
Ficheros: lib/features/criancas/, lib/features/familias/portal_familias_screen.dart y lib/features/familias/views/hoxe_familias_screen.dart.
Comprobación: widget test con tres niños (0-2, 3-4 y 5-6) que cambia entre ellos y comprueba el curso de Hoxe, Calendario y Explorar; test de que la hoja ya no cambia el curso de un toque; capturas de escritorio en gl y es de la fila de niños.

P11.2 · REPASO POR NIÑO (F2)
En casa, una tarjeta FSRS por palabra y por niño, en criancas.json, reutilizando lib/core/fsrs_service.dart (no se duplica). Las marcas alimentan la tarjeta: «la dice» = Good, «la entiende» = Hard, «aún no» = Again. En Hoxe, el bloque «Volven hoxe / Vuelven hoy»: de 2 a 4 palabras vencidas de cualquier semana anterior del niño, con lámina, audio y gesto; con más de 6 vencidas, ese día no entran palabras nuevas.
En tools/gen_leccions.py, la causa raíz: «repaso = not novas» (línea 524) y «xaSabe» con las últimas 8 piezas (línea 634). Las palabras vuelven a la semana 1, 2, 4, 8 y 16 de haber salido, así que el aula, sin niños registrados, también tiene repaso espaciado; la semana 4 de cada mes trae como mucho una palabra nueva. Regenera leccions.json y todo lo que derive de él.
Comprobación: tests de siembra y vencimiento por niño y test de privacidad actualizado; en la salida de python3 tools/auditoria_niveles.py, los umbrales de vueltas (al menos 4), de desfase (alguna pasado un mes) y de semanas de repaso, a cero incumplimientos en las cinco edades.

P11.3 · PRUEBA DE ENTRADA (F3)
Contenido nuevo en assets/content/nivel/proba_entrada.json, en gl, es y en, con lámina y audio. Por curso, seis peldaños: comprender una orden con gesto; señalar un objeto; distinguir un contraste (grande/pequeño, mojado/seco…); decir la palabra; decir dos palabras juntas; decir una frase corta. Tres ítems por peldaño, todos con palabras y objetos del STEAM de su curso, escritos a mano.
Pantalla «Xogo de Lúa para saber por onde empezar / Juego de Lúa para saber por dónde empezar», que se ofrece al registrar un niño de 2 años o más y desde su ficha. Le dice a la persona adulta qué pedir, con objetos de casa o con la lámina impresa, y ella marca «aínda non / entende / dío» («aún no / la entiende / la dice»). De 5 a 8 minutos; se puede saltar.
Regla: se para tras tres fallos seguidos; el peldaño es el último con dos aciertos de tres. El resultado fija el punto de partida y siembra el repaso: lo que entiende o dice entra como conocido.
Comprobación: test del árbol de decisión con cinco trayectorias, check_finalidade en verde y capturas de escritorio en gl y es.

P11.4 · AJUSTE DINÁMICO (F3b)
Motor puro en Dart, sin widgets, en lib/features/criancas/axuste_semanal.dart, con la tabla de la sección 4b del plan tal cual. Cada lunes decide el cupo de palabras nuevas, la mezcla de repaso y nuevo, el peldaño y la capa («núcleo», «Máis / Más» o «Apoio / Apoyo»). Topes de palabras nuevas por semana: 0-2 de 1 a 3; 2-3 de 2 a 4; 3-4 de 2 a 5; 4-5 de 3 a 6; 5-6 de 3 a 7. Si la familia no marca nada, el niño no sube ni baja. En Hoxe, una línea en gl y es con el porqué, sin porcentajes: «Esta semana, catro palabras novas: Uxía xa di catro das cinco da semana pasada.» Explorar sigue enseñándolo todo a la persona adulta (D6).
Comprobación: test que simula 40 semanas con cuatro niños (rápido, medio, lento y sin marcas): los topes se respetan, el niño sin marcas no se mueve, el lento llega a la semana de consolidar y nadie pasa el techo de su edad.

P11.5 · ESCALERA DE LOS 48 PUNTOS (D1)
Los 48 puntos dejan de ir uno por mes y pasan a ser peldaños por dominio, con techo por edad: 0-2 sin gramática; 2-3 con fórmulas fijas de los puntos 1-9; 3-4 con los puntos A1 como fórmulas; 4-5 con A1 y una selección de A2; 5-6 hasta A2. B1-C1 pasan a la guía de la persona adulta, con su ejemplo. Los 48 siguen todos en la app. En tools/gen_gramatica.py, el gate de «la columna no baja» se cambia por el del techo por edad. Ninguna frase para el niño vuelve a ser como «If we had used boots, we would have stayed clean.» en 4-5 años.

P11.6 · 0-2 AÑOS REHECHO (F4, D4)
Sustituye las 199 palabras de assets/content/acopros/proxectos_0_2.json por un núcleo de unas 60 piezas en cinco familias:
- sustantivos de su mundo: cuerpo, comida, familia, animales;
- adjetivos de contraste: big/small, hot/cold, wet/dry;
- onomatopeyas, siempre unidas a su objeto («Baa» con «Lamb»);
- rutinas y sucesos: «Bath time», «All done», «Bye-bye», «Night night»;
- series básicas: «one, two, three», grande-pequeño-grande, arriba-abajo-arriba.
De dos a tres piezas nuevas por semana; frases de tres palabras como mucho; cada pieza vuelve muchos meses y nombra el STEAM del mes y la parte que trabaja («Wet» y «Dry» en «Mollado e seco»). Cada semana en sus tres capas. Se genera con tools/gen_acopros_0_2.py; láminas nuevas con su gate (check_laminas.py) y voz para cada pieza. La frecuencia no se decide con el corpus adulto de 4000 palabras (la auditoría explica por qué); si usas otra referencia de habla dirigida a niños pequeños, comprueba antes su licencia y anótala en docs/p11-control.md.

P11.7 · 2-3 A 5-6 RECALIBRADOS (F5)
Cada semana de las cuatro edades, con núcleo, «Máis / Más» y «Apoio / Apoyo», las tres con el STEAM del mes. Frase máxima de 4, 5, 6 y 7 palabras; nunca más de dos palabras de diferencia con la frase de la semana anterior; gramática dentro del techo de la edad; la semana 1 sin «ya las conoce» de un curso que el niño no ha hecho (eso lo decide la prueba de entrada). Se regeneran los cuentos que cambien de palabras (check_contos_palabras.py), las láminas y el corpus de voz.

P11.8 · GATES EN CI
Nuevo tools/check_capas_semana.py: falla si una semana de las cinco edades no tiene sus tres capas o si alguna no nombra el STEAM del mes. python3 tools/auditoria_niveles.py --gate y check_capas_semana.py entran en tools/gates.sh solo cuando den cero en local; si alguno no llega a cero, no lo conectes y escribe en docs/p11-control.md cuál falta y por qué.

P11.9 · LAS CAPAS DEL CAMBIO
Al día: corpus de voz (python3 tools/export_voice_corpus.py --check), láminas, manual de casos de uso con capturas nuevas y PDF y Word mirados página a página (tools/check_manual_build.py), catálogo por edades regenerado, política de privacidad y ficha de Play con lo que ahora se guarda, y README sin información interna (lo interno va a STATUS.md).

P11.10 · CAPTURAS Y CONTROL
Con el procedimiento de escritorio de la regla 1d de CLAUDE.md (Xvfb 460×1000 y navegación por clic), capturas en gl y es de: la fila de niños; «Volven hoxe»; la prueba de entrada de principio a fin; la línea del ajuste semanal; 0-2 en tres meses; una semana de 4-5 en sus tres capas. Mira cada captura antes de darla por buena. En docs/p11-control.md, una tabla con cada criterio de O-20261126-1, O-20261126-2 y O-20261126-3, su evidencia (test, gate o captura) y lo que no se ha visto en un aparato.

P11.11 · CIERRE
Actualiza docs/PENDIENTE.md y empuja antigravity/niveles, sin pull request a main y sin merge. El informe final empieza por «De la orden falta: …», criterio por criterio y con números («de 200 semanas, con tres capas 200»).

LO QUE REVISARÁ CLAUDE CODE
auditoria_niveles.py --gate y check_capas_semana.py a cero; gates.sh y flutter test en verde; nada borrado fuera de lo que autorizan D1 y D4; tres semanas al azar por edad (STEAM, longitud de las frases y repaso); la prueba de entrada y la fila de niños abiertas en la app de escritorio en gl y es; la privacidad declarada igual a lo que se guarda; ninguna palabra clínica en pantalla.
```

## P11 · Prompt único (26/11/2026, vigente)

Los doce pasos en un solo prompt, como pidió Frank. Con su decisión del 26/11/2026: el alta de cada niño se hace una sola vez y lleva dentro la prueba de entrada; después la app se ajusta sola cada semana. Los pasos P11.0–P11.11 ya están en la tabla de pasos.

```text
TRABAJO INTEGRAL DE ANTIGRAVITY · P11 COMPLETO (P11.0 A P11.11) · NIVELES POR EDAD, VARIOS NIÑOS, PRUEBA DE ENTRADA, REPASO Y AJUSTE DINÁMICO

Eres Antigravity y trabajas en FrankBetances/Descubre-con-lua: app Android en Flutter, solo educativa, con Juega con Lúa (la docente, en la asamblea) y Na casa / Academy (las familias), en gallego y castellano, para estimular el inglés. Haces el 100 % del trabajo, de P11.0 a P11.11 seguidos y sin esperar entre pasos. Claude Code solo revisa e integra. No abres pull request a main ni mergeas.

DECISIONES DE FRANK (26/11/2026): D1 a D6 aprobadas tal como las recomienda docs/AUDITORIA_NIVELES_Y_REPASO.md, secciones 3 y 4b; D4 incluye sustituir las 199 palabras actuales de 0-2. Los siete criterios de O-20261126-1 y O-20261126-2, aprobados. El alta de cada niño se hace UNA SOLA VEZ y lleva dentro la prueba de entrada; después la app se ajusta sola cada semana. Lo que el plan propone es la orden; no lo cambias por tu criterio.

REGLAS QUE NO SE NEGOCIAN (CLAUDE.md)
1. Prohibido borrar, quitar, vaciar o sustituir nada que Frank no haya pedido con palabras en docs/ORDENES.md. Solo está autorizado lo de D4 (las 199 palabras de 0-2) y lo de D1 (asignar los 48 puntos por mes); los 48 puntos siguen todos en la app.
2. R-STEAM: cada palabra, frase, capa, ítem de la prueba y cuento nuevo nombra el STEAM de su mes y qué parte del experimento trabaja.
3. Prohibido rellenar: no se repite, se estira ni se copia entre cursos para que cuadre una cifra. Si falta material, se escribe en docs/p11-control.md y se sigue.
4. El niño no usa la pantalla: la app propone a la persona adulta y ella marca lo que ve.
5. Nada sanitario: nunca «examen», «diagnóstico», «evaluación», «trastorno», «retraso» ni «puntuación». tools/check_finalidade.py en verde.
6. Ningún dato sale del móvil, sin permiso INTERNET. Todo campo nuevo de criancas.json en día o en semana del curso, nunca con hora. En el mismo commit que lo añade: docs/privacy.html, docs/play-seguridad-datos.md, README.md y test/core/criancas_privacidad_test.dart.
7. Léxico de Galicia: neno/nena, niño/niña; nunca «criatura» ni «crianza» visibles; nunca «Edición Vigo».
8. Sin emoji; sin licencias NC ni ND.
9. Texto con audio que cambia: corpus de voz exportado en el mismo commit (tools/export_voice_corpus.py); frases inglesas para el niño con voz child y versión lenta (tools/check_voz_lenta.py).
10. Cada commit empieza por «P11.n:» y añade su fila al Registro de commits de docs/PLAN_ANTIGRAVITY.md (la última fila con «este»; el commit siguiente la cambia por el SHA real). Los pasos P11.0-P11.11 ya están en la tabla de pasos: no los añadas otra vez. tools/check_registro_commits.py en OK antes de cada push.
11. Antes de cada push: tools/gates.sh y flutter test completos en local. Si algo va a fallar, no se empuja; se arregla primero.
12. Lo que no has visto en la app se dice con estas palabras: «esto no lo he verificado».

CUÁNDO PARAR. Sigues de un paso al siguiente sin esperar. Paras y escribes a Frank solo si hay cambios sin commit que no son tuyos, si un gate no se puede poner en verde sin saltarte una regla o si falta material que solo Frank puede dar. Lo demás lo apuntas en docs/p11-control.md y sigues con lo que no depende de ello.

P11.0 · PREPARACIÓN
Lee enteros CLAUDE.md, docs/AUDITORIA_NIVELES_Y_REPASO.md y las órdenes O-20261126-1, O-20261126-2 y O-20261126-3 de docs/ORDENES.md. Crea la rama antigravity/niveles desde main; git status y git log --oneline -5. Corre python3 tools/auditoria_niveles.py y crea docs/p11-control.md con su salida como punto de partida (hoy 30 incumplimientos; si da otra cifra, dilo) y una tabla con cada criterio abierto de las tres órdenes, columna «evidencia» vacía. Commit «P11.0: punto de partida y tabla de control».

P11.1 · FAMILIA CON VARIOS NIÑOS Y ALTA DE UNA SOLA VEZ
Na casa → alta, una sola vez por niño, en un solo recorrido: nombre o apodo, mes y año de nacimiento (sin día) y curso propuesto por la edad; para 2 años o más, a continuación y dentro de la misma alta, la prueba de entrada de P11.3. Al terminar: «Hai outro neno ou nena na casa? / ¿Hay otro niño o niña en casa?», y se da de alta el siguiente sin salir. Un niño ya dado de alta no vuelve a pasar por el alta: sus datos se cambian en «Editar a …».
Na casa → Hoxe, arriba: una fila con cada niño (su Lúa, su nombre, su curso) y, debajo de cada uno, en una línea, lo que le toca hoy. Un toque cambia el niño activo, y Hoxe, Calendario y Explorar pasan a su curso.
La lista de cursos sale de la hoja del chip: el curso solo se cambia dentro de «Editar a …», con confirmación. En septiembre la app propone el curso siguiente y la persona adulta confirma. Premios, observaciones y repaso, siempre del niño activo.
Ficheros: lib/features/criancas/, lib/features/familias/portal_familias_screen.dart y lib/features/familias/views/hoxe_familias_screen.dart. Privacidad en el mismo commit (regla 6).
Hecho cuando: widget test con tres niños (0-2, 3-4 y 5-6) dados de alta seguidos, que cambia entre ellos y comprueba el curso de Hoxe, Calendario y Explorar; test de que un niño dado de alta no vuelve a ver el alta; test de que la hoja ya no cambia el curso de un toque.

P11.2 · REPASO POR NIÑO
Casa: una tarjeta FSRS por palabra y por niño en criancas.json, reutilizando lib/core/fsrs_service.dart, sin duplicarlo. «La dice» = Good, «la entiende» = Hard, «aún no» = Again.
Na casa → Hoxe: bloque «Volven hoxe / Vuelven hoy» con 2 a 4 palabras vencidas de cualquier semana anterior del niño, con lámina, audio y gesto. Con más de 6 vencidas, ese día no entran palabras nuevas.
En tools/gen_leccions.py, la causa raíz: «repaso = not novas» (línea 524) y «xaSabe» con las últimas 8 piezas (línea 634). Las palabras vuelven a la semana 1, 2, 4, 8 y 16 de haber salido, también en el aula; la semana 4 de cada mes trae como mucho una palabra nueva. Regenera leccions.json y todo lo que derive de él, con su corpus de voz. Privacidad en el mismo commit.
Hecho cuando: tests de siembra y vencimiento por niño y test de privacidad en verde; en auditoria_niveles.py, «vuelven menos de 4 veces», «ninguna vuelve pasado un mes» y «ninguna semana de repaso» a cero en las cinco edades.

P11.3 · PRUEBA DE ENTRADA, DENTRO DEL ALTA
Contenido nuevo en assets/content/nivel/proba_entrada.json, en gl, es y en, con lámina y audio. Por curso, seis peldaños: comprender una orden con gesto; señalar un objeto; distinguir un contraste (grande/pequeño, mojado/seco…); decir la palabra; decir dos palabras juntas; decir una frase corta. Tres ítems por peldaño, escritos a mano, todos con palabras y objetos del STEAM de su curso.
Pantalla «Xogo de Lúa para saber por onde empezar / Juego de Lúa para saber por dónde empezar», como último tramo del alta de cada niño de 2 años o más. Se hace una sola vez: no se ofrece de nuevo desde la ficha ni se repite; desde ahí, el nivel lo ajusta P11.4 cada semana. La dirige la persona adulta, con objetos de casa o con la lámina impresa, y marca «aínda non / entende / dío» («aún no / la entiende / la dice»). De 5 a 8 minutos. Si se interrumpe, la próxima vez que se abra Na casa sigue donde se quedó, y hasta acabarla el niño empieza por el inicio de su curso. 0-2 no hace prueba: empieza por su edad.
Regla: se para tras tres fallos seguidos; el peldaño es el último con dos aciertos de tres. El resultado fija el punto de partida y siembra el repaso: lo que entiende o dice entra como conocido. Privacidad en el mismo commit.
Hecho cuando: test del árbol de decisión con cinco trayectorias, test de la siembra, test de que la prueba sale una sola vez por niño y la de reanudar si se interrumpe, y check_finalidade.py en verde.

P11.4 · AJUSTE DINÁMICO
Motor puro en Dart, sin widgets, en lib/features/criancas/axuste_semanal.dart, con la tabla de la sección 4b de docs/AUDITORIA_NIVELES_Y_REPASO.md tal cual. Arranca en el peldaño que dio la prueba de entrada. Cada lunes decide el cupo de palabras nuevas, la mezcla de repaso y nuevo, el peldaño y la capa («núcleo», «Máis / Más» o «Apoio / Apoyo»). Topes de palabras nuevas por semana: 0-2 de 1 a 3; 2-3 de 2 a 4; 3-4 de 2 a 5; 4-5 de 3 a 6; 5-6 de 3 a 7. Sin marcas de la familia, no sube ni baja.
Na casa → Hoxe: una línea en gl y es con el porqué, sin porcentajes («Esta semana, catro palabras novas: Uxía xa di catro das cinco da semana pasada.»). Explorar sigue enseñándolo todo a la persona adulta. Se guarda por niño el peldaño, el cupo y, por semana del curso (sin fecha), la tasa y la capa. Privacidad en el mismo commit.
Hecho cuando: un test simula 40 semanas con cuatro niños (rápido, medio, lento y sin marcas): se respetan los topes, el niño sin marcas no se mueve, el lento llega a la semana de consolidar y nadie pasa el techo de su edad.

P11.5 · ESCALERA DE LOS 48 PUNTOS
Los 48 puntos de assets/content/gramatica/gramatica.json dejan de ir uno por mes y pasan a ser peldaños por dominio, con techo por edad: 0-2 sin gramática; 2-3 con fórmulas fijas de los puntos 1-9; 3-4 con los puntos A1 como fórmulas; 4-5 con A1 y una selección de A2; 5-6 hasta A2. B1-C1 pasan a la guía de la persona adulta, con su ejemplo; ninguno se borra. En tools/gen_gramatica.py, el gate «la columna no baja» se cambia por el del techo por edad. Las frases de la unidad para el niño se reescriben dentro del techo, con el STEAM del mes; ninguna como «If we had used boots, we would have stayed clean.» en 4-5. Corpus de voz en el mismo commit.
Hecho cuando: auditoria_niveles.py da cero en «meses por encima de» en las cinco edades, y gen_gramatica.py --check y gen_leccions.py --check en verde.

P11.6 · 0-2 AÑOS REHECHO
Sustituye las 199 palabras de assets/content/acopros/proxectos_0_2.json por un núcleo de unas 60 piezas en cinco familias: sustantivos de su mundo (cuerpo, comida, familia, animales); adjetivos de contraste (big/small, hot/cold, wet/dry); onomatopeyas unidas a su objeto («Baa» con «Lamb»); rutinas y sucesos («Bath time», «All done», «Bye-bye», «Night night»); series básicas («one, two, three», grande-pequeño-grande, arriba-abajo-arriba). De dos a tres piezas nuevas por semana; frases de tres palabras como mucho; cada pieza vuelve muchos meses y nombra el STEAM del mes y la parte que trabaja («Wet» y «Dry» en «Mollado e seco»). Cada semana en sus tres capas, sin rellenar repitiendo. Se genera con tools/gen_acopros_0_2.py, con láminas nuevas (check_laminas.py) y voz para cada pieza. La frecuencia no se decide con el corpus adulto de 4000 palabras; si usas otra referencia, comprueba su licencia y anótala en docs/p11-control.md.
Hecho cuando: auditoria_niveles.py da cero en 0-2, y gen_acopros_0_2.py --check, check_laminas.py y export_voice_corpus.py --check en verde.

P11.7 · 2-3 A 5-6 RECALIBRADOS
En las 160 semanas de las cuatro edades: tres capas («núcleo», «Máis / Más», «Apoio / Apoyo»), las tres con el STEAM del mes, escritas y no repetidas; frase máxima de 4, 5, 6 y 7 palabras y nunca más de dos palabras de diferencia con la de la semana anterior; gramática dentro del techo de la edad; la semana 1 sin «ya las conoce» de un curso que el niño no ha hecho. Regenera los cuentos que cambien de palabras (check_contos_palabras.py), las láminas y el corpus de voz. Si hace falta, un commit por edad, todos con «P11.7:».
Hecho cuando: auditoria_niveles.py da cero en las cuatro edades, y check_contos_palabras.py, check_laminas.py, gen_leccions.py --check y export_voice_corpus.py --check en verde.

P11.8 · GATES EN CI
Nuevo tools/check_capas_semana.py: falla si una semana de las cinco edades no tiene sus tres capas o si alguna no nombra el STEAM del mes. Si este gate y «python3 tools/auditoria_niveles.py --gate» dan cero en local, añádelos a tools/gates.sh. Si alguno no da cero, no lo conectes: vuelve al paso que lo arregla y apúntalo en docs/p11-control.md.

P11.9 · LAS CAPAS DEL CAMBIO
Al día y comprobadas: corpus de voz (export_voice_corpus.py --check y check_voz_lenta.py); láminas (check_laminas.py y check_banco_laminas.py); manual de casos de uso con capturas nuevas de todo lo de P11, PDF y Word mirados página a página sin figuras que se salgan de la hoja (tools/check_manual_build.py); catálogo por edades regenerado (docs/Descubre-con-Lua-Material-por-edades.pdf); docs/privacy.html y docs/play-seguridad-datos.md diciendo exactamente lo que guarda criancas.json; README sin información interna (lo interno va a STATUS.md).

P11.10 · CAPTURAS Y CONTROL
Con el procedimiento de escritorio de la regla 1d de CLAUDE.md (Xvfb 460×1000 y navegación por clic, por el camino que usa Frank), capturas en gl y es de: Na casa → alta de un niño de 4 años con su prueba de entrada de principio a fin, y luego la de un segundo niño; Na casa → Hoxe con la fila de tres niños de cursos distintos; «Volven hoxe»; la línea del ajuste semanal; 0-2 en tres meses; una semana de 4-5 en sus tres capas; y Modo Aula → Hoy, para comprobar que el aula no cambió. Guárdalas en docs/capturas/escritorio/p11-*.png y míralas todas. En docs/p11-control.md, cada criterio de las tres órdenes con su evidencia (test, gate o captura) y «esto no lo he verificado en un aparato» donde corresponda.

P11.11 · CIERRE
Actualiza docs/PENDIENTE.md solo con lo que de verdad falta. Corre tools/gates.sh, flutter test y python3 tools/auditoria_niveles.py --gate, y pega las tres salidas en docs/p11-control.md. Push de antigravity/niveles, sin pull request a main y sin merge. Informe final a Frank: empieza por «De la orden falta: …», criterio por criterio y con números («de 200 semanas, con tres capas 200»; «incumplimientos de auditoria_niveles: 0»); después, lo que no se ha visto en un aparato.

LO QUE REVISARÁ CLAUDE CODE
auditoria_niveles.py --gate y check_capas_semana.py a cero; gates.sh y flutter test en verde; nada borrado fuera de lo que autorizan D1 y D4; tres semanas al azar por edad (STEAM, longitud de las frases y repaso); el alta con su prueba, una sola vez, y la fila de niños abiertas en la app de escritorio en gl y es; la privacidad declarada igual a lo que se guarda; ninguna palabra clínica en pantalla.
```

## P11 · Corrección del alta (26/11/2026), para pegar sobre el trabajo en curso

Frank ya le había pasado P11 a Antigravity. Esta es la corrección que se le pega, sin reiniciar el trabajo (F-20261126-3).

```text
CORRECCIÓN DE FRANK (26/11/2026) al trabajo P11 que estás haciendo. No empieces de nuevo; aplica esto donde toque:
1. P11.1 · El alta de cada niño se hace UNA SOLA VEZ, en un solo recorrido: nombre o apodo, mes y año de nacimiento (sin día) y curso propuesto por la edad; para 2 años o más, a continuación y dentro de la misma alta, la prueba de entrada de P11.3; al terminar, «Hai outro neno ou nena na casa? / ¿Hay otro niño o niña en casa?». Un niño ya dado de alta no vuelve a ver el alta; sus datos se cambian en «Editar a …».
2. P11.3 · La prueba de entrada es el último tramo del alta y se hace una sola vez: no se ofrece desde la ficha ni se repite; desde ahí el nivel lo ajusta P11.4 cada semana. Si se interrumpe, la próxima vez que se abra Na casa sigue donde se quedó, y hasta acabarla el niño empieza por el inicio de su curso. 0-2 no hace prueba.
3. Tests nuevos: que un niño dado de alta no vuelve a ver el alta, y que la prueba sale una sola vez y se reanuda si se interrumpe.
4. P11.10 · Captura en gl y es del alta de un niño de 4 años con su prueba de principio a fin, y luego la de un segundo niño.
El texto completo con esta corrección ya está en main: «P11 · Prompt único (26/11/2026, vigente)» de docs/PROMPTS_ANTIGRAVITY.md. Si algo de lo que ya hiciste choca con esto, corrígelo en el paso donde lo hiciste y apúntalo en docs/p11-control.md.
```
