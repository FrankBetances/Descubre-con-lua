# Pendiente después de P10

Rama `antigravity/escoita` con la entrega integral **P10** completada localmente (`P10.0`–`P10.9`). Quedan únicamente las validaciones en dispositivo real, los pasos que requieren ejecución en GitHub/CI y las decisiones reservadas a Frank / Claude Code:

1. **Push de `antigravity/escoita`, CI y revisión por Claude Code (`O-20261122-1`)**
   - Desde este entorno el `git push` devuelve HTTP 403 porque `FrankBetances/Descubre-con-lua` no figura montado como recurso conectable. Quedan todos los commits (`P10.0`–`P10.9`) en local sobre `antigravity/escoita`.
   - Tras subir la rama, Claude Code valida el trabajo, marca las evidencias en `docs/ORDENES.md` (incluidos `O-20261120-1`, `O-20261120-2` y `O-20261122-1`) y comprueba el run completo en CI (`Flutter 3.47.9`, `AGP 8.11.1`, `Gradle 8.14.3`) más `aapt2 dump permissions` sobre el APK generado por CI.

2. **Síntesis de nuevos audios en CI (`voice-assets`)**
   - `voice-corpus.json` está al día (`40160 locutions`, `export_voice_corpus.py --check` en verde) tras P10.1, P10.2, P10.4 y P10.5.
   - Falta ejecutar en CI el workflow `voice-assets` para sintetizar los `.m4a` nuevos/modificados (gallego, castellano e inglés en voz `child` `1.05` y lenta `1.6`) y verificar `python3 tools/check_voice_coverage.py`.

3. **Prueba en dispositivo Android físico con ARCore y cámara real (NO PROBADO)**
   - Comprobar en teléfono físico con Android: escena ARCore + Filament en mesa real, espejo facial frontal MediaPipe (`ar1`–`ar6`), degradación en un terminal sin ARCore o sin permiso de cámara y escucha real de «Oír amodo / Oír despacio» (`1.6`).

4. **Decisión de Frank sobre 302 grabaciones huérfanas (`8.4 MB`)**
   - `python3 tools/prune_voice_assets.py --check` detecta 302 ficheros `.m4a` que ya no corresponden a ninguna locución (p. ej. `en_child_0321e0f6_32.m4a`, `en_child_062f5505_35.m4a`, `en_child_08eaa6cc_30.m4a`, `en_child_0911caa2_10.m4a`, `en_child_14248edc_34.m4a`).
   - Conservados en disco sin borrar por regla R-BORRAR; pendientes de que Frank autorice `python3 tools/prune_voice_assets.py --borrar`.

5. **Actualización de `CLAUDE.md` («Privacidad declarada = privacidad compilada»)**
   - Antigravity no edita `CLAUDE.md`; texto propuesto incluido en la entrega para que Claude Code lo someta a Frank y actualice el párrafo de permisos permitidos (`CAMERA` opcional junto a `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`).

6. **Pendientes previos de repositorio / herramienta**
   - Revisar `.claude/hooks/sin_borrar.py` (fuera del alcance de Antigravity) para que distinga el borrado de trabajo de una orden expresa de quitar un elemento repetido.
   - Compilar `check_pulse_bpm.py` (con `numpy`) y `check_voice_levels.py` (con `ffmpeg`) en CI, donde ambas herramientas están disponibles.
