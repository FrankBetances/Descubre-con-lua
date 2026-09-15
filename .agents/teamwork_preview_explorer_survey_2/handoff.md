# Handoff Report: Flutter Tooling & Architecture Survey
**Subagent**: `teamwork_preview_explorer_survey_2` (Flutter Arch Explorer)  
**Parent**: `teamwork_preview_orchestrator_1` (`155c43c0-be2b-46ce-b47d-cc280903c77f`)  
**Timestamp**: 2026-09-11T08:32:00Z  
**Handoff Type**: Hard (Survey Phase Complete)  

---

## 1. Observation

1. **Project Root File Structure**:
   Direct observation via `list_dir` on `<documentos locales>/Descubre con Lúa`:
   - `.agents/` (Metadata directory)
   - `.git/` (Git repo)
   - `.gitignore` (Size: 115 bytes; contains node_modules, dist, build, .env)
   - `ORIGINAL_REQUEST.md` (Size: 4443 bytes; verbatim user specifications)
   - `README.md` (Size: 81 bytes; title placeholder)
   - No `pubspec.yaml`, `android/`, `lib/`, `test/`, or `assets/` exists yet.
2. **Host System & Toolchain Status**:
   Direct command execution outputs:
   - `which flutter; flutter --version; dart --version`:
     ```
     flutter not found
     zsh:1: command not found: flutter
     zsh:1: command not found: dart
     (exit code 127)
     ```
   - `/opt/homebrew/opt/openjdk@17/bin/java -version`:
     ```
     openjdk version "17.0.19" 2026-04-21
     OpenJDK Runtime Environment Homebrew (build 17.0.19+0)
     OpenJDK 64-Bit Server VM Homebrew (build 17.0.19+0, mixed mode, sharing)
     (exit code 0)
     ```
   - `ls -d "/Applications/Android Studio.app"`:
     ```
     /Applications/Android Studio.app
     (exit code 0)
     ```
   - `git --version; node --version; python3 --version`:
     ```
     git version 2.50.1 (Apple Git-155)
     v26.3.1
     Python 3.9.6
     (exit code 0)
     ```
   - Network test via `curl -I https://google.com`:
     Returned HTTP/2 403 / certificate block in sandbox environment.
3. **Reference Codebase**:
   Direct inspection of `<repositorio del proyecto anterior de la casa>`:
   - `<módulo del proyecto anterior>` (lines 1-156): Contains domain definitions (`lenguaje`, `hipoacusia`, etc.) and capsule structures (`AcademyCapsule`, `slides`, `quiz`).
   - `assets/voice/`: Contains 3,658 `.m4a` offline audio recordings.
   - `voice-assets-manifest.gl.json`: Manifest for Proxecto Nós Galician voice (`Celtia`).

---

## 2. Logic Chain

1. **From Observation 1**: The workspace has no prior Flutter scaffolding. Therefore, the implementation phase must generate standard, production-ready Flutter and Android project structure from scratch, adhering strictly to the user requirements.
2. **From Observation 2**: In this execution environment, `flutter` is not in the default non-interactive PATH, and outbound sandbox network calls are restricted. Therefore:
   - Scaffolding cannot rely on interactive `flutter create` or external package downloads at build time.
   - All files (`pubspec.yaml`, `android/build.gradle`, `MainActivity.kt`, `AndroidManifest.xml`, `lib/`, `test/`) must be handcrafted with 100% syntactical precision conforming to standard Flutter SDK specifications.
   - Dependencies in `pubspec.yaml` must be zero-network: relying only on the `flutter` SDK and offline local assets.
3. **From Requirement R1 & Observation 2**: To satisfy the release binary privacy requirement ("el manifiesto release `android/app/src/main/AndroidManifest.xml` no debe contener `android.permission.INTERNET` ni permisos no esenciales"):
   - The manifest must explicitly configure `xmlns:tools="http://schemas.android.com/tools"` and `<uses-permission android:name="android.permission.INTERNET" tools:node="remove" />`.
   - This prevents any plugin or Gradle manifest merge from accidentally injecting network permissions.
   - An automated privacy verification test (`test/privacy/privacy_manifest_test.dart`) must be provided to statically certify this constraint.
4. **From Requirement R1 (Local Audio) & Observation 3**: The app needs local offline audio playback for the guided teacher assembly ("canción a pulso").
   - Using third-party audio packages (like `audioplayers` or `just_audio`) can risk pulling transitive network dependencies or manifest permissions.
   - Implementing an abstract `OfflineAudioService` backed by a deterministic `MockOfflineAudioService` for unit/widget tests and a lightweight Android `MediaPlayer` platform channel for runtime guarantees zero external network packages and 100% test reliability.
5. **From Requirement R2, R3 & Observation 3**: el proyecto anterior de la casa contains clinical concepts (hipoacusia, dislalias, TEA, logopedia). «Descubre con Lúa · Edición Vigo» is strictly educational/family (0-3 years) under Decreto 150/2022.
   - Therefore, `lib/data/validators/content_validator.dart` must programmatically verify 1:1 bilingual `gl`/`es` parity, curriculum references, and reject any prohibited clinical/diagnostic terms (`diagnóstico`, `paciente`, `trastorno`, `patología`, `terapia`, etc.).
6. **From Testing Requirements**: `flutter test` must run unit tests in `test/data/` (models, JSON loader, repository, validator) and widget tests in `test/features/` (Academy 5 blocks and capsule view; Juega con Lúa unit selector and step-by-step assembly flow). Decoupling UI from native audio via `OfflineAudioService` ensures all widget tests run seamlessly in headless CI environments.

---

## 3. Caveats

- **No Active Flutter in Shell PATH**: While macOS has Android Studio and OpenJDK 17 installed, `flutter` CLI is not configured in `/usr/local/bin` or `/opt/homebrew/bin`. If the user or parent executes `flutter test` directly in the subshell, PATH may need to include the Flutter SDK binary path, or tests can be verified using Dart/unit test scripts.
- **Audio Files**: el proyecto anterior de la casa has extensive audio files in `el proyecto anterior de la casa/assets/voice/`. The specific song for the maritime unit ("O mar de Vigo") in `assets/audio/mar_pulso.m4a` can be referenced as an offline asset file or synthesized asset.
- **Visual Design**: The UI must remain sober and functional for teachers (no animations or child distraction mechanics) and readable for adults in Academy (high legibility, 0 child clickers).

---

## 4. Conclusion

The architectural survey is complete and provides an actionable blueprint:
1. **Scaffolding Target**: Package ID `com.earlify.descubreconlua` across `android/app/build.gradle` and Kotlin directories.
2. **Binary Privacy**: Zero internet permissions in `android/app/src/main/AndroidManifest.xml` via explicit removal rules, and zero network packages in `pubspec.yaml`.
3. **Clean Architecture**: Complete blueprint established for `lib/core/`, `lib/data/`, `lib/features/juega/`, and `lib/features/academy/`.
4. **Content-as-Data**: Strong Dart models, `gl`/`es` parallel parity validator, Decreto 150/2022 curriculum alignment, and strict clinical term blacklist.
5. **Testing**: Comprehensive test architecture designed for `test/data/`, `test/features/`, and `test/privacy/`.

All detailed specifications, class interfaces, and directory trees are documented in:
`<documentos locales>/Descubre con Lúa/.agents/teamwork_preview_explorer_survey_2/analysis.md`

---

## 5. Verification Method

1. **Inspect Analysis Report**:
   Check `<documentos locales>/Descubre con Lúa/.agents/teamwork_preview_explorer_survey_2/analysis.md`.
2. **Verify Project Root Status**:
   Run `ls -la "<documentos locales>/Descubre con Lúa"` to confirm greenfield status.
3. **Verify Host Environment Discoveries**:
   - Run `/opt/homebrew/opt/openjdk@17/bin/java -version` (returns OpenJDK 17.0.19).
   - Run `ls -d "/Applications/Android Studio.app"` (exists).
4. **Invalidation Conditions**:
   - If an existing Flutter project was hidden in an unlisted subdirectory (ruled out by exhaustive search).
   - If `android.permission.INTERNET` were required for offline audio playback (ruled out: Android `MediaPlayer` playing from APK asset descriptors requires zero permissions).
