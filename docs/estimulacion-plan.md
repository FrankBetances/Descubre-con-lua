# Plan P9 · Estimulación del lenguaje y el pensamiento, voz de Valeria y realidad aumentada

Orden de referencia: `O-20261120-1` en `docs/ORDENES.md`.
Fuente: `FrankBetances/valeria` (commit `e2a2a5e8`).
Regla suprema (`R-STEAM`): el eje de toda la app es el pensamiento STEAM aplicado a la estimulación del lenguaje. Cada palabra, frase, pregunta, imagen y escena nombra el experimento STEAM de su mes (`assets/content/steam/steam_do_mes.json`, identificado por `cursos.<curso>.unidades[mes-1].steam.id` en `assets/content/leccions/leccions.json`).
Finalidad exclusivamente educativa (`tools/check_finalidade.py`): sin vocabulario clínico, sin NC/ND, sin emoji del sistema, todo en `gl` y `es`, y el contenido en JSON.

## Qué se copia de Valeria y dónde entra

| Fuente en Valeria (`e2a2a5e8`) | Función / símbolo en Valeria | Destino en Descubre con Lúa | Adaptación (R-STEAM y educativa) |
| --- | --- | --- | --- |
| `scripts/generate-voice-assets.py` | `LENGTH_SCALE = {"tutor": 1.0, "child": 1.05, "clinical": 1.15, "slow": 1.6}` | `tools/voice_corpus.py` (`LENGTH_SCALE` con `tutor: 1.0`, `child: 1.05`, `slow: 1.6`) | Sin estilo clínico; se incorpora `child` (1.05) para frases dichas al niño y se conserva `slow` (1.6). |
| `src/valeriaSemanticExpansion.ts` | `stepLines`: cada frase al niño en `child` y la misma frase completa en `slow`; guía del adulto en `tutor` | `tools/voice_corpus.py` (`estilo_ingles` + emisión doble `child` y `slow` en frases infantiles) y `lib/core/audio/voice_id.dart` (`VoiceStyle.child`, `estiloIngles`) | Toda frase inglesa que oye el niño (pares, progresiones y sus frases, modelo del adulto dicho al niño, momentos de pensamiento y juegos de escucha) se genera en `child` y en `slow`. Las palabras sueltas siguen en `slow` y las consignas adultas en `tutor`. |
| `src/valeriaVoice.ts` | `speakPhraseSlow(text)`: reproduce la frase completa en estilo `slow` (1.6) | `lib/core/audio/widgets/boton_escuchar.dart` (botón «Oír amodo / Oír despacio» junto a frases inglesas para el niño) | Reproducción offline desde `assets/voice/` sin motor TTS en tiempo real ni red; validado por el gate `tools/check_voz_lenta.py`. |
| `src/valeriaMinimalPairs*.ts`, `src/valeriaSemanticExpansion*.ts` | Método: contraste de un fonema, progresión `concepto → parte → acción → cualidad` y expansión | `assets/content/escoita/plan_mensual.json` (`bloque pensamiento`: `predice`, `proba`, `compara`, `explica`), `assets/content/acopros/proxectos_0_2.json` (`mira_e_nota` por proyecto 0-2), `lib/features/estimulacion/` | Orientado al 100 % al experimento STEAM de cada mes y ajustado por edad: `2-3` y `3-4` eligen entre dos (señalar); `4-5` dicen palabra o frase corta; `5-6` explican con `because`; `0-2` observación sensorial guiada sin preguntas abiertas. |
| `src/ValeriaSemanticExpansionScreen.tsx`, `src/ui/fonts.ts`, `src/ui/motion.tsx` | Estructura clara por pasos, tipografía `Fredoka`/`Nunito` y movimiento | `lib/features/estimulacion/` (sección propia «Estimulación da linguaxe e o pensamento / Estimulación del lenguaje y el pensamiento») + entrada en `Na casa` (`HoxeFamiliasScreen` / `ExplorarFamiliasScreen`) y `Modo Aula` (`HoxeDocentesScreen` / `RecursosDocentesScreen`) + enlace desde `VistaPasoEscoita` | Sin borrar ni sustituir `VistaPasoEscoita` ni el paso de la lección. Versión asamblea en Modo Aula. |
| `src/steam/arActivities.ts`, `src/steam/arScenes.ts`, `src/steam/worlds/` (`s0_kit`, `s1_camino`…`s6_jardin`, `retos.ts`), `src/steam/luaSolo.ts`, `src/steam/engine/LuaLink.ts`, `src/valeriaArBridge.ts`, `android-native/valeria-ar/` | AR sobre mesa (ARCore + Filament + Compose) y seguimiento facial (MediaPipe Face Landmarker) con permiso `CAMERA` | **P9.4: solo informe previo (`docs/estimulacion-ar-informe.md`)**. No entra código AR ni permiso `CAMERA` sin el «sí» explícito de Frank | La app actual no declara ningún permiso más allá del interno de AndroidX (`tools/gates.sh` y `docs/privacy.html`). Primero se entrega el informe técnico, de licencias y privacidad; la implementación queda bloqueada hasta decisión de Frank. |

## Secuencia de pasos P9

| Paso | Qué entrega | Salida verificable |
| --- | --- | --- |
| `P9.0` | Plan y mapa Valeria → Descubre con Lúa | `docs/estimulacion-plan.md`, `docs/PLAN_ANTIGRAVITY.md` |
| `P9.1` | Voces `child` (1.05) + `slow` de frase (1.6), botón «Oír amodo / Oír despacio» y gate | `tools/voice_corpus.py`, `lib/core/audio/voice_id.dart`, `lib/core/audio/widgets/boton_escuchar.dart`, `tools/check_voz_lenta.py`, `tools/gates.sh`, `voice-corpus.json` |
| `P9.2` | Bloque `pensamiento` (`predice`, `proba`, `compara`, `explica`) en las 40 piezas y `mira_e_nota` en los 10 proyectos 0-2 | `assets/content/escoita/plan_mensual.json`, `assets/content/acopros/proxectos_0_2.json`, `tools/gen_acopros_0_2.py`, `tools/check_plan_escoita.py` |
| `P9.3` | Sección «Estimulación da linguaxe e o pensamento / Estimulación del lenguaje y el pensamiento» en Na casa y Modo Aula | `lib/features/estimulacion/`, `lib/features/familias/`, `lib/features/docentes/`, `assets/content/nomes/nomes_portais.json` |
| `P9.4` | Informe de realidad aumentada de Valeria (motor, permisos, paquetes, licencias, red, plan Flutter offline) · **PARA antes de código AR** | `docs/estimulacion-ar-informe.md` |
| `P9.5` | Láminas nuevas (`pal_<palabra>`) para palabras nuevas de P9.2 y hoja de contactos | `assets/brand/laminas/pal_*.json`, `assets/content/laminas/palabras_laminas.json`, `docs/capturas/hoja_contactos_p9.png` |
| `P9.6` | Tests de la sección (gl/es, escala 1.8), «Oír despacio» y las 40 piezas con pensamiento | `test/features/estimulacion_test.dart`, `test/core/audio/boton_escuchar_test.dart`, `test/features/paso_escoita_test.dart` |
| `P9.7` | Capturas de escritorio Linux en gl y es | `docs/capturas/escritorio/estimulacion-*.png` |
| `P9.8` | Tabla de control completa de las 40 piezas | `docs/estimulacion-control.md` |
