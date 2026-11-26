# Pendiente después de P11

Rama `antigravity/niveles` con la entrega integral **P11** completada en local (`P11.0`–`P11.11`, fusionada con `origin/claude/intelligent-mayer-e3iriy`). Quedan únicamente las acciones de CI, las decisiones reservadas a Frank / Claude Code y las comprobaciones en teléfono Android físico:

1. **Revisión e integración por Claude Code (`O-20261126-3`)**
   - Claude Code revisa `antigravity/niveles` (incluidas tres semanas al azar por edad, capturas `docs/capturas/escritorio/p11-*.png` en `gl` y `es`, `auditoria_niveles.py --gate`, `check_capas_semana.py` y `vocab_idade.py --check`), ejecuta la batería completa (`tools/gates.sh` y `flutter test`, ya que en la última ronda antes del `Stop` se completaron `1.118` tests en 6 lotes y quedaron detenidos sin terminar `tpr_pantallas_test.dart`, `portales_escala..xogos_escoita`, `ux_l0/l1/l3/l5` y `ux_l2_test.dart`), `Flutter 3.47.9`, `AGP 8.11.1`, `Gradle 8.14.3` y `aapt2 dump permissions` sobre el APK release, y hace el merge a `main` tras la aprobación.

2. **Síntesis de nuevos audios en CI (`voice-assets`)**
   - `voice-corpus.json` está sincronizado (`43.339` locuciones: `20.202` `en`, `11.567` `es`, `11.570` `gl`; `export_voice_corpus.py --check` y `check_voz_lenta.py` en verde con `3.698` locuciones infantiles y `2.140` frases `child` `1.05` + `slow` `1.6`).
   - Falta ejecutar el workflow `voice-assets` en GitHub Actions para sintetizar las `3.126` locuciones nuevas (principalmente `capas[*].en`, `capas[*].pezas[*].en` y significados incorporados en `P11.10`) y confirmar `python3 tools/check_voice_coverage.py` a cero.

3. **Decisión de Frank sobre 72 palabras de `PENDENTES_FRANK` (`tools/vocab_idade.py`)**
   - Permanecen sin tocar las `72` palabras señaladas por `vocab_idade.py` fuera del modelo de 4.000 por requerir decisión expresa de Frank (regla 1 / Paso 0):
   - **`curso_2_3` (25)**: `Blackbird`, `Blow away`, `Brush head`, `Calm sea`, `Cube`, `Driftwood`, `Finish line`, `Jump in`, `Kneecap`, `Library`, `Meadow`, `Merry-go-round`, `Oval`, `Pavement`, `Pour down`, `Race track`, `Roll up`, `Sea glass`, `Sieve`, `Soap pump`, `Sphere`, `Stroll`, `Tread`, `Walrus`, `Water table`.
   - **`curso_3_4` (2)**: `rebuild`, `steady`.
   - **`curso_4_5` (27)**: `Alert`, `Brightest`, `Deep blue`, `Downhill`, `Evaporate`, `Fair`, `Frozen solid`, `Gull chick`, `Knight`, `Motionless`, `Mussel raft`, `Mysterious`, `Photo book`, `Rope line`, `Rushing`, `Seabird`, `Showery`, `Sly`, `Sneak`, `Stage`, `Steep`, `Sturdy`, `Underpass`, `examine`, `protect`, `splashy`, `temperature`.
   - **`curso_5_6` (18)**: `Balance beam`, `Director`, `Dramatic`, `Fishing village`, `Investigate`, `Memory lane`, `Primary school`, `Responsible`, `Rhythmic`, `Stargaze`, `Symmetry`, `Vote`, `blend`, `creative`, `destination`, `explore`, `journey`, `passport`.

4. **Decisión de Frank sobre 590 grabaciones huérfanas (`6.0 MB`)**
   - `python3 tools/prune_voice_assets.py --check` informa de `590` ficheros `.m4a` (`6.0 MB`) sin referencia activa en el corpus (`en_slow_378f264d_7.m4a`, etc.). Conservados en disco sin borrar por regla 1; pendientes de autorización de Frank para `python3 tools/prune_voice_assets.py --borrar`.

5. **Verificación en dispositivo Android físico (no comprobado)**
   - Instalación del APK release en móvil Android real, audio real por altavoz, pruebas de ARCore / cámara y recorrido completo en dispositivo físico: **esto no lo he verificado**.

6. **Pendientes previos de entorno y `CLAUDE.md`**
   - Revisar en CI `check_pulse_bpm.py` (con `numpy`) y `check_voice_levels.py` (con `ffmpeg`), y actualizar en `CLAUDE.md` si Frank lo aprueba el permiso opcional `CAMERA` junto a `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`.

