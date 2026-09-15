# Dispatch for teamwork_preview_explorer_m6_2

## Task: Milestone M6 Exploration — Dual Model Audio Integration & Atlantic Warm Palette
You are teamwork_preview_explorer_m6_2.
Your working directory is:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m6_2

Workspace root:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa

Authoritative user request:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/ORIGINAL_REQUEST.md

Master project scope:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_orchestrator_2/PROJECT.md

Scope of Milestone M6:
Requirement R2:
1. Direct access to model pronunciation:
   - English L3 TPR: `LJSpeech · piper` (using `englishVoiceAssetPath(VoiceStyle.tutor, text)` from `lib/core/audio/voice_id.dart`).
   - Galician L1: `Celtia · Proxecto Nós` (using `voiceAssetPath(VoiceStyle.tutor, text, AppLanguage.gl)`).
   - How to embed `BotonEscuchar` cleanly into the flashcard for TPR commands and vocabulary chips.
2. Atlantic Warm Palette tokens:
   - Check `lib/core/theme/app_theme.dart`.
   - Incorporate and standardize:
     * Aguamarina: `#00C4BE` (brand) and `#127A75` (`primaryInk` WCAG AA 5.16:1).
     * Coral suave: `#F4A9B6` / `#EF8296`.
     * Ámbar: `#D97706` / `#FACC15`.
     * Menta: `#10B981`.
   - Verify harmony with `LuaPixel` custom painter and Nunito typography.

Write your findings to:
/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m6_2/handoff.md


## 2026-09-13T09:33:38Z
Investigate direct model audio access on the cards: English LJSpeech · piper and Galician Celtia · Proxecto Nós via BotonEscuchar and voice_id.dart. Also investigate Atlantic warm palette tokens (aguamarina, coral suave, ámbar, menta) in AppTheme.
Write report to: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m6_2/handoff.md
