# BRIEFING — 2026-09-11T08:32:00Z

## Mission
Survey the project root, Flutter/Dart toolchain, Android configuration, clean architecture layout, privacy constraints, offline audio options, and testing setup for «Descubre con Lúa · Edición Vigo».

## 🔒 My Identity
- Archetype: teamwork_preview_explorer
- Roles: Flutter Arch Explorer
- Working directory: <documentos locales>/Descubre con Lúa/.agents/teamwork_preview_explorer_survey_2
- Original parent: 155c43c0-be2b-46ce-b47d-cc280903c77f
- Milestone: Survey Phase (M0)

## 🔒 Key Constraints
- Read-only investigation — do NOT implement source code
- Package ID must be com.earlify.descubreconlua
- Release manifest android/app/src/main/AndroidManifest.xml must NOT contain android.permission.INTERNET or non-essential permissions
- Zero network dependencies, sockets, analytics, or telemetry SDKs in pubspec.yaml and lib/
- Strict offline audio architecture for local assets
- All findings documented in analysis.md and handoff.md

## Current Parent
- Conversation ID: 155c43c0-be2b-46ce-b47d-cc280903c77f
- Updated: 2026-09-11T08:32:00Z

## Investigation State
- **Explored paths**:
  - `<documentos locales>/Descubre con Lúa` (root listing, .gitignore, README.md, ORIGINAL_REQUEST.md)
  - `<repositorio del proyecto anterior de la casa>` (Academy models, Galician voice manifests, assets/voice)
  - System PATH, Homebrew cellar, Java OpenJDK 17, Android Studio application
- **Key findings**:
  - Root is greenfield workspace; no Flutter project exists yet.
  - Package ID `com.earlify.descubreconlua` needs to be configured in Gradle and Kotlin directories.
  - Manifest privacy requires explicit `tools:node="remove"` for `INTERNET` and `ACCESS_NETWORK_STATE`.
  - Zero-network dependencies in `pubspec.yaml`; offline audio player abstracted via `OfflineAudioService`.
  - Clean architecture blueprints designed for `lib/core`, `lib/data`, `lib/features/juega`, `lib/features/academy`.
  - Test suites mapped for `test/data/`, `test/features/`, and `test/privacy/`.
- **Unexplored areas**: None for M0 survey. Implementation work ready for dispatch in M1-M4.

## Key Decisions Made
- Recommended abstract `OfflineAudioService` pattern with `MockOfflineAudioService` for deterministic widget/unit tests and lightweight Android native asset player.
- Defined explicit manifest stripping to guarantee binary-level zero internet permission.
- Formulated the exact testing suite architecture covering models, JSON loader, repository, validator, widget flows, and static privacy gates.

## Artifact Index
- `<documentos locales>/Descubre con Lúa/ORIGINAL_REQUEST.md` — Original user request
- `<documentos locales>/Descubre con Lúa/.agents/teamwork_preview_explorer_survey_2/DISPATCH.md` — Dispatch log
- `<documentos locales>/Descubre con Lúa/.agents/teamwork_preview_explorer_survey_2/BRIEFING.md` — Working memory
- `<documentos locales>/Descubre con Lúa/.agents/teamwork_preview_explorer_survey_2/progress.md` — Liveness & progress heartbeat
- `<documentos locales>/Descubre con Lúa/.agents/teamwork_preview_explorer_survey_2/analysis.md` — Comprehensive survey findings & blueprints
- `<documentos locales>/Descubre con Lúa/.agents/teamwork_preview_explorer_survey_2/handoff.md` — 5-component survey handoff report
