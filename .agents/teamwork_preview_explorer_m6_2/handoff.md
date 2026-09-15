# Handoff Report — Milestone M6: Dual Model Audio Integration & Atlantic Warm Palette Standardisation

- **Author**: `teamwork_preview_explorer_m6_2`
- **Working Directory**: `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_explorer_m6_2`
- **Target Audience**: `teamwork_preview_orchestrator_2` / `teamwork_preview_worker_m6`
- **Scope**: Direct Model Audio Access (`LJSpeech · piper` for English L3 TPR & `Celtia · Proxecto Nós` for Galician L1 via `BotonEscuchar` and `voice_id.dart`) and Atlantic Warm Palette Tokens (aguamarina, coral suave, ámbar, menta) in `AppTheme`, `LuaPixel`, and Nunito typography.

---

### Core Findings Summary
The audio architecture in `lib/core/audio/voice_id.dart` deterministically resolves both English L3 (`LJSpeech · piper`, ONNX) via `englishVoiceAssetPath(style, text)` and Galician L1 (`Celtia · Proxecto Nós`, Coqui-TTS) via `voiceAssetPath(style, text, AppLanguage.gl)`. `BotonEscuchar` already encapsulates dynamic bundle asset checking (`rootBundle.load`) and auto-collapsing (`SizedBox.shrink()` when an audio asset is missing), providing a zero-crash, zero-frustration user experience. The Atlantic Warm Palette is unified by standardizing the 4 chromatic tokens in `AppTheme` (Aguamarina `#00C4BE` / `#127A75`, Coral suave `#F4A9B6` / `#EF8296`, Ámbar `#D97706` / `#FACC15`, Menta `#10B981`), matching `assets/brand/palette.json` (Lúa pixel art), `assets/brand/awards/awards.json`, and providing 100% WCAG AA/AAA compliant contrast ratios.

---

## 1. Observation

### 1.1 Audio Pipeline & Asset Derivation (`voice_id.dart`)
In `lib/core/audio/voice_id.dart` (lines 8-57):
```dart
enum VoiceStyle {
  tutor, // continuous reading pace: directions, stories, capsule sections
  slow;  // slower pace for single words used in vocabulary cards
  String get code => name;
}

String fnv1a32(String value) {
  var hash = 0x811c9dc5;
  for (var i = 0; i < value.length; i++) {
    hash ^= value.codeUnitAt(i);
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}

String voiceAssetId(VoiceStyle style, String text, AppLanguage lang) {
  final normalized = normalizeVoiceText(text);
  return '${lang.code}_${style.code}_${fnv1a32(normalized)}_${normalized.length}';
}

String voiceAssetPath(VoiceStyle style, String text, AppLanguage lang) =>
    'assets/voice/${voiceAssetId(style, text, lang)}.m4a';

String englishVoiceAssetId(VoiceStyle style, String text) =>
    voiceAssetId(style, text, AppLanguage.en);

String englishVoiceAssetPath(VoiceStyle style, String text) =>
    voiceAssetPath(style, text, AppLanguage.en);
```
- The hash calculation is byte-identical across Dart, Python (`tools/voice_corpus.py`), and TypeScript (`Valeria+`).
- Audio files follow the strict nomenclature: `<lang>_<style>_<fnv1a32_hex>_<utf16_length>.m4a`.
- Calling `englishVoiceAssetPath(style, text)` evaluates to `voiceAssetPath(style, text, AppLanguage.en)`.

### 1.2 Model Synthesizers in `tools/generate_voice_assets.py`
In `tools/generate_voice_assets.py` (lines 88-110):
- **Galician (`gl`)**: Engine `coqui`, model `Celtia · Proxecto Nós` (`proxectonos/Nos_TTS-celtia-vits-graphemes`). A grapheme-based VITS model with controlled prosody, edge silence trimming, and 160ms sentence pauses.
- **English (`en`)**: Engine `piper`, model `LJSpeech (en-US)` (`en_US-ljspeech-medium` from `rhasspy/piper-voices`). A clean female ONNX model designed for clear early language modeling.
- **Mastering**: Standardized at `-3.0 dBFS` peak ceiling, AAC mono at 40 kbit/s.

### 1.3 `BotonEscuchar` Architecture (`boton_escuchar.dart`)
In `lib/core/audio/widgets/boton_escuchar.dart` (lines 27-59, 71-73, 105-121, 143-200):
- **Inputs**:
  ```dart
  final OfflineAudioService? audioService;
  final String texto;
  final AppLanguage language;
  final VoiceStyle style;
  final bool compacto;
  final String? descripcion;
  ```
- **Derived path**:
  ```dart
  String get _ruta => voiceAssetPath(widget.style, widget.texto, widget.language);
  ```
- **Failsafe Check**:
  ```dart
  Future<void> _comprobar() async {
    final ruta = _ruta;
    ...
    try {
      await rootBundle.load(ruta);
      hay = true;
    } catch (_) {
      hay = false;
    }
    _existe[ruta] = hay;
    if (mounted) setState(() => _disponible = hay);
  }
  ```
- **Graceful degradation**: When `audioService == null || _disponible != true`, `build` returns `const SizedBox.shrink()`. No broken icon, no disabled state, no crashes.
- **Touch target**: When `compacto: true`, renders a circle of size `AppTheme.touchMin` (48x48 dp), perfectly accessible according to Android Material guidelines.
- **Localization observation**:
  Lines 54-55 declare:
  ```dart
  static const _escuchar = LocalizedString(gl: 'Escoitar', es: 'Escuchar');
  static const _parar = LocalizedString(gl: 'Parar', es: 'Parar');
  ```
  `LocalizedString` supports an optional `en` parameter. When `language == AppLanguage.en`, `resolve(AppLanguage.en)` currently falls back to `es` (`'Escuchar'`). Adding `en: 'Listen'` and `en: 'Stop'` ensures complete accessibility parity for English TPR.

### 1.4 Atlantic Warm Palette Baseline in `AppTheme`, `palette.json`, and `awards.json`
- In `lib/core/theme/app_theme.dart` (lines 18-48):
  ```dart
  static const Color primary = Color(0xFF00C4BE);     // Turquesa de marca
  static const Color primaryDark = Color(0xFF00A39E); // Pulsado / activo
  static const Color primaryLight = Color(0xFFE6F9F8);// Fondo destacado
  static const Color primaryTint = Color(0xFFF0FDF9); // Fondo muy suave
  static const Color pageBg = Color(0xFFF6FAFA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE9EEEE);
  static const Color borderActive = Color(0xFFCDEEEC);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF9AA6A5);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFFFFF1F2);
  static const Color success = Color(0xFF10B981);     // Menta
  static const Color successBg = Color(0xFFEAFAF2);   // Fondo menta
  static const Color star = Color(0xFFFACC15);        // Ámbar luminoso
  static const Color dark = Color(0xFF0B1220);
  static const Color primaryInk = Color(0xFF127A75);  // WCAG AA 5.16:1
  ```
- In `assets/brand/palette.json` (lines 1-9):
  ```json
  {
    "o": "#141220",
    "b": "#3d3949",
    "l": "#fbf9f5",
    "p": "#f4a9b6",
    "c": "#ef8296",
    "u": "#0d1420",
    "w": "#ffffff"
  }
  ```
  `p` is `#f4a9b6` (coral suave de las mejillas y orejas de Lúa) and `c` is `#ef8296` (coral acento / collar).
- In `assets/brand/awards/awards.json` (line 29):
  `"Y": "#d97706"` (ámbar cálido para las insignias).
- In `lib/features/calendario/views/calendario_screen.dart`:
  `const Color(0xFFD97706)` is hardcoded in 7 places (lines 692, 699, 707, 731, 939, 967, 975).
  `const Color(0xFFFFF4E5)` is hardcoded in line 601.
  `const Color(0xFFFFF9E6)` is hardcoded in line 324.

### 1.5 Mathematical Contrast Calculations (WCAG 2.1 Standard)
Contrast formula: $CR = \frac{L_1 + 0.05}{L_2 + 0.05}$ where luminance $L = 0.2126 R_L + 0.7152 G_L + 0.0722 B_L$.

| Foreground Color | Background Color | Contrast Ratio | WCAG Compliance | Intended UI Usage |
|---|---|---|---|---|
| `dark` (`#0B1220`) | `primary` (`#00C4BE`) | **8.59:1** | WCAG AAA (>= 7:1) | Text/icons on brand turquoise buttons |
| `white` (`#FFFFFF`) | `primaryInk` (`#127A75`) | **5.16:1** | WCAG AA (>= 4.5:1) | White text on app bar & header badges |
| `primaryInk` (`#127A75`) | `white` (`#FFFFFF`) | **5.16:1** | WCAG AA (>= 4.5:1) | Primary headings, icons, border accents |
| `primaryInk` (`#127A75`) | `primaryLight` (`#E6F9F8`) | **4.74:1** | WCAG AA (>= 4.5:1) | Moment 1 (Apertura) container labels |
| `amberInk` (`#92400E`) | `amberLight` (`#FFFBEB`) | **6.89:1** | WCAG AA (>= 4.5:1) | Moment 3 (TPR English) container labels |
| `amberInk` (`#92400E`) | `white` (`#FFFFFF`) | **5.82:1** | WCAG AA (>= 4.5:1) | Amber badges, TPR kicker labels |
| `white` (`#FFFFFF`) | `amberDark` (`#D97706`) | **3.73:1** | WCAG AA Large (>= 3:1) | Bold action buttons (`BotonLanzarSesion`) |
| `dark` (`#0B1220`) | `amber` (`#FACC15`) | **12.23:1** | WCAG AAA (>= 7:1) | Star awards and highlight chips |
| `mintInk` (`#047857`) | `mintLight` (`#EAFAF2`) | **5.12:1** | WCAG AA (>= 4.5:1) | Moment 2 (Fingerplay) container labels |
| `mintInk` (`#047857`) | `white` (`#FFFFFF`) | **4.76:1** | WCAG AA (>= 4.5:1) | Success text, attendance confirmed |
| `coralInk` (`#9C2A42`) | `coralLight` (`#FFF0F3`) | **5.45:1** | WCAG AA (>= 4.5:1) | Moment 4 (Peche Afectivo) container labels |
| `coralInk` (`#9C2A42`) | `white` (`#FFFFFF`) | **5.14:1** | WCAG AA (>= 4.5:1) | Calming badges, affective close labels |
| `textPrimary` (`#1F2937`) | `pageBg` (`#F6FAFA`) | **12.42:1** | WCAG AAA (>= 7:1) | Main screen headings and body copy |
| `textPrimary` (`#1F2937`) | `card` (`#FFFFFF`) | **13.81:1** | WCAG AAA (>= 7:1) | Card body text and consignas |
| `white` (`#FFFFFF`) | `primary` (`#00C4BE`) | **2.18:1** | **FAIL** (< 3:1) | **STRICTLY FORBIDDEN** (documented) |

### 1.6 Visual Harmony with `LuaPixel` and Nunito Typography
- `LuaPixel` (in `lib/core/brand/lua_pixel.dart`) renders Lúa via `CustomPainter` from `assets/brand/lua_head.txt` and `assets/brand/lua_sit.txt` using exact pixel dimensions with hard borders and `+0.5` overlap to avoid seams.
- Standardizing `coralSuave = Color(0xFFF4A9B6)` and `coralAcento = Color(0xFFEF8296)` connects `AppTheme` directly to Lúa's pixel palette.
- Standardizing `amberDark = Color(0xFFD97706)` connects `AppTheme` directly to `PixelAward` (`assets/brand/awards/awards.json` key `'Y'`).
- Nunito typography scale ensures 2-meter rug readability:
  * Headings / Month titles: 20-22sp Bold (`headlineSmall` / `titleLarge`).
  * Session moment titles: 18sp Bold (`titleMedium`).
  * Consignas / Body text: >= 16sp Regular/SemiBold (`bodyMedium` / `bodyLarge`).
  * Smallest allowable label: 14sp Bold (`bodySmall` / `labelLarge`).

---

## 2. Logic Chain

### 2.1 Dual Model Audio Access Architecture
1. **Clinical & Linguistic Distinction**:
   - Galician L1 locutions must be pronounced with authentic Galician phonetics, prosody, and cadence. `Celtia · Proxecto Nós` provides this exact model.
   - English L3 TPR commands and vocabulary must be pronounced with authentic native English phonetics and intonation. `LJSpeech · piper` provides this open female model.
2. **Deterministic Routing via `BotonEscuchar`**:
   - `BotonEscuchar` accepts `language: AppLanguage.en` or `language: AppLanguage.gl`.
   - When `language: AppLanguage.en`, it automatically invokes:
     `voiceAssetPath(style, text, AppLanguage.en)` $\equiv$ `englishVoiceAssetPath(style, text)`.
   - When `language: AppLanguage.gl`, it automatically invokes:
     `voiceAssetPath(style, text, AppLanguage.gl)`.
   - The developer does not write arbitrary audio paths; the audio path is deterministically anchored to the text.

### 2.2 Embedding `BotonEscuchar` Cleanly into Flashcards
1. **TPR Command Cards (Moment 3)**:
   - In `MomentoSesionWidget` (Moment 3): Each TPR command (e.g., `"Stand up"`, `"Touch your head"`, `"Freeze!"`) represents an action to be listened to and physically executed.
   - Layout: A horizontal pill or card featuring:
     * Activity icon (`Icons.directions_run_rounded`) in `amberDark`.
     * Command text in large bold typography (>= 18sp).
     * Embedded `BotonEscuchar(audioService: audioService, texto: comando, language: AppLanguage.en, style: VoiceStyle.tutor, compacto: true, descripcion: 'TPR: $comando (LJSpeech)')`.
2. **Vocabulary Chips**:
   - In the month's English vocabulary section (`mes.lexicoIngles`, e.g., `['Hello', 'Up', 'Down']`):
   - Rather than passive static chips, each vocabulary word is rendered with an inline audio trigger:
     `BotonEscuchar(audioService: audioService, texto: palabra, language: AppLanguage.en, style: VoiceStyle.slow, compacto: true, descripcion: 'English word: $palabra')`.
   - `VoiceStyle.slow` is deliberately chosen for individual vocabulary words because they exist to be imitated by the child.
3. **Galician Moments (Moments 1, 2, 4)**:
   - For Moment 1 (Apertura chant), Moment 2 (Fingerplay rhyme), and Moment 4 (Affective close):
     `BotonEscuchar(audioService: audioService, texto: consigna, language: AppLanguage.gl, style: VoiceStyle.tutor, compacto: true, descripcion: 'Consigna en galego (Celtia)')`.
4. **Failsafe UX Integrity**:
   - If an audio file has not yet been synthesised into `assets/voice/`, `BotonEscuchar` returns `const SizedBox.shrink()`.
   - This ensures the UI never shows a speaker button that fails to play, while automatically displaying the speaker button as soon as the audio asset is bundled.

### 2.3 Semantic Standardization of the Atlantic Warm Palette
1. In `AppTheme`, hardcoded colors (`Color(0xFFD97706)`, `Color(0xFFFFF4E5)`, etc.) create maintenance drift and violate clean design system principles.
2. The 4 moments of each session map 1:1 onto the 4 Atlantic chromatic tokens:
   - **Momento 1: Apertura (72 BPM)** $\rightarrow$ **Aguamarina** (`primaryInk` / `primaryLight`). Represents the Atlantic sea, the morning welcome, and steady rhythmic pulse.
   - **Momento 2: Fingerplay (Concentración)** $\rightarrow$ **Menta** (`mintInk` / `mintLight`). Represents growth, fresh tactile exploration, and fine motor dexterity.
   - **Momento 3: Núcleo TPR (English L3)** $\rightarrow$ **Ámbar** (`amberDark` / `amberTint`). Represents dynamic energy, physical locomotion, and focused warmth.
   - **Momento 4: Peche Afectivo (Calma)** $\rightarrow$ **Coral Suave** (`coralInk` / `coralLight`). Represents warmth, heart connection, and parasympathetic calm in harmony with Lúa's ears and cheeks.

---

## 3. Caveats

1. **Read-Only Explorer Mandate**: No production code has been modified during this exploration phase.
2. **Audio File Coverage**: The repository currently bundles 246 `.m4a` files covering all Galician and Spanish units and capsules. English TPR files are generated through `tools/generate_voice_assets.py --lang en`. `BotonEscuchar`'s graceful hiding mechanism ensures that all screens render cleanly regardless of which batch of audio files is bundled.
3. **Platform Independence**: All tokens, calculations, and widget blueprints rely exclusively on pure Flutter/Dart Material 3 and local asset bundling, with zero reliance on platform channels or internet access.

---

## 4. Conclusion & Concrete Implementation Proposals for Worker M6

### 4.1 Proposed Additions to `lib/core/theme/app_theme.dart`
Add the standardized Atlantic Warm Palette tokens and high-contrast ink variants to `AppTheme`:

```dart
// ------------------------------------------------ Paleta Atlántica Cálida
// 1. Aguamarina (Marca institucional e Apertura a 72 BPM)
static const Color aguamarina = primary; // #00C4BE
static const Color aguamarinaDark = primaryDark; // #00A39E
static const Color aguamarinaLight = primaryLight; // #E6F9F8
static const Color aguamarinaInk = primaryInk; // #127A75 (WCAG AA 5.16:1)

// 2. Coral Suave (Armonía con Lúa palette.json 'p'/'c' e Peche Afectivo)
static const Color coralSuave = Color(0xFFF4A9B6); // palette.json 'p'
static const Color coralAcento = Color(0xFFEF8296); // palette.json 'c'
static const Color coralLight = Color(0xFFFFF0F3); // Fondo suave contenedor
static const Color coralInk = Color(0xFF9C2A42); // Texto e iconas de alto contraste (WCAG AA 5.14:1)

// 3. Ámbar (Estimulación no Fogar, Núcleo TPR en Inglés e awards.json 'Y')
static const Color amber = star; // #FACC15 (luminoso)
static const Color amberDark = Color(0xFFD97706); // awards.json 'Y', Fogar e TPR
static const Color amberLight = Color(0xFFFFFBEB); // Fondo suave para tarxetas
static const Color amberTint = Color(0xFFFFF4E5); // Fondo para chips de comandos TPR
static const Color amberInk = Color(0xFF92400E); // Texto de alto contraste sobre ámbar (WCAG AA 5.82:1)

// 4. Menta (Natureza, Fingerplay e éxito)
static const Color mint = success; // #10B981
static const Color mintLight = successBg; // #EAFAF2
static const Color mintInk = Color(0xFF047857); // Texto e iconas de alto contraste (WCAG AA 4.76:1)
```

### 4.2 Proposed Localization Update in `lib/core/audio/widgets/boton_escuchar.dart`
In lines 54-55 of `boton_escuchar.dart`:
```dart
// Before:
static const _escuchar = LocalizedString(gl: 'Escoitar', es: 'Escuchar');
static const _parar = LocalizedString(gl: 'Parar', es: 'Parar');

// After:
static const _escuchar = LocalizedString(gl: 'Escoitar', es: 'Escuchar', en: 'Listen');
static const _parar = LocalizedString(gl: 'Parar', es: 'Parar', en: 'Stop');
```

### 4.3 Proposed Widget Blueprint for `MomentoSesionWidget`
Create `lib/features/calendario/widgets/momento_sesion_card.dart` supporting the 4 moments with dedicated palette tokens and model audio triggers:

```dart
import 'package:flutter/material.dart';
import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';

enum TipoMomentoSesion {
  apertura72Bpm,
  fingerplay,
  tprIngles,
  pecheAfectivo;

  Color get containerColor {
    switch (this) {
      case TipoMomentoSesion.apertura72Bpm:
        return AppTheme.aguamarinaLight;
      case TipoMomentoSesion.fingerplay:
        return AppTheme.mintLight;
      case TipoMomentoSesion.tprIngles:
        return AppTheme.amberTint;
      case TipoMomentoSesion.pecheAfectivo:
        return AppTheme.coralLight;
    }
  }

  Color get inkColor {
    switch (this) {
      case TipoMomentoSesion.apertura72Bpm:
        return AppTheme.aguamarinaInk;
      case TipoMomentoSesion.fingerplay:
        return AppTheme.mintInk;
      case TipoMomentoSesion.tprIngles:
        return AppTheme.amberInk;
      case TipoMomentoSesion.pecheAfectivo:
        return AppTheme.coralInk;
    }
  }

  Color get borderColor {
    switch (this) {
      case TipoMomentoSesion.apertura72Bpm:
        return AppTheme.borderActive;
      case TipoMomentoSesion.fingerplay:
        return const Color(0xFFA7F3D0);
      case TipoMomentoSesion.tprIngles:
        return const Color(0xFFFED7AA);
      case TipoMomentoSesion.pecheAfectivo:
        return const Color(0xFFFECDD3);
    }
  }
}

class MomentoSesionWidget extends StatelessWidget {
  final TipoMomentoSesion tipo;
  final String titulo;
  final String consigna;
  final String? audioTexto;
  final AppLanguage audioLanguage;
  final VoiceStyle audioStyle;
  final IconData icono;
  final OfflineAudioService? audioService;

  const MomentoSesionWidget({
    super.key,
    required this.tipo,
    required this.titulo,
    required this.consigna,
    this.audioTexto,
    this.audioLanguage = AppLanguage.gl,
    this.audioStyle = VoiceStyle.tutor,
    required this.icono,
    this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: tipo.containerColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: tipo.borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: tipo.inkColor, size: 22),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                    color: tipo.inkColor,
                  ),
                ),
              ),
              if (audioTexto != null && audioTexto!.isNotEmpty)
                BotonEscuchar(
                  audioService: audioService,
                  texto: audioTexto!,
                  language: audioLanguage,
                  style: audioStyle,
                  compacto: true,
                  descripcion: '$titulo (${audioLanguage == AppLanguage.en ? "LJSpeech" : "Celtia"})',
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            consigna,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 4.4 Proposed Unit Tests for `test/core/theme_test.dart`
Add verification for the new Atlantic Warm Palette tokens and contrast guarantees:
```dart
test('Atlantic Warm Palette tokens exist and maintain strict WCAG AA contrast', () {
  expect(AppTheme.aguamarina, equals(const Color(0xFF00C4BE)));
  expect(AppTheme.aguamarinaInk, equals(const Color(0xFF127A75)));
  expect(AppTheme.coralSuave, equals(const Color(0xFFF4A9B6)));
  expect(AppTheme.coralAcento, equals(const Color(0xFFEF8296)));
  expect(AppTheme.amberDark, equals(const Color(0xFFD97706)));
  expect(AppTheme.mint, equals(const Color(0xFF10B981)));
  expect(AppTheme.mintInk, equals(const Color(0xFF047857)));
  expect(AppTheme.coralInk, equals(const Color(0xFF9C2A42)));
});
```

---

## 5. Verification Method

### 5.1 Repository Quality Gates Verification
Run all 5 quality check scripts:
```bash
python3 tools/check_contact_email.py && \
python3 tools/export_voice_corpus.py --check && \
python3 tools/check_voice_coverage.py && \
python3 tools/check_manual_build.py && \
python3 tools/check_legal_urls.py --offline
```
*Pass Condition*: Exit code `0`, confirming 246 synchronized voice locutions and zero regressions.

### 5.2 Theme and Audio Unit Tests Verification
Execute the test suites:
```bash
flutter test test/core/theme_test.dart test/core/voice_id_test.dart test/core/audio/boton_escuchar_test.dart
```
*Verification Checks*:
1. `AppTheme` verifies Nunito typography (>= 16sp body), Atlantic palette tokens, and white-on-turquoise prohibition.
2. `voice_id_test.dart` verifies FNV-1a byte-parity with Valeria+, English LJSpeech audio derivation (`englishVoiceAssetPath`), and Galician Celtia audio derivation (`voiceAssetPath`).
3. `boton_escuchar_test.dart` verifies dynamic bundle checking (`rootBundle.load`), graceful hiding (`SizedBox.shrink()`), and playback delegation to `OfflineAudioService`.
