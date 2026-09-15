# E2E Test Infra: Descubre con Lúa · Edición Vigo

## Test Philosophy
- Opaque-box, requirement-driven. No dependency on implementation design.
- Methodology: Category-Partition + BVA + Pairwise + Workload Testing.

## Feature Inventory
| # | Feature | Source | Tier 1 | Tier 2 | Tier 3 |
|---|---------|--------|:------:|:------:|:------:|
| 1 | 1-Touch Calendar Launch | ORIGINAL_REQUEST §R1 | 5 | 5 | ✓ |
| 2 | Agile Dual-Role Switch | ORIGINAL_REQUEST §R3 | 5 | 5 | ✓ |
| 3 | Reactive Doble Estimulación | ORIGINAL_REQUEST §R1 | 5 | 5 | ✓ |
| 4 | Sovereign CalendarioStore | ORIGINAL_REQUEST §R1 | 5 | 5 | ✓ |
| 5 | High-Contrast Visual Cards | ORIGINAL_REQUEST §R2 | 5 | 5 | ✓ |
| 6 | 4 Session Moments | ORIGINAL_REQUEST §R2 | 5 | 5 | ✓ |
| 7 | Dual Model Audio LJSpeech / Celtia | ORIGINAL_REQUEST §R2 | 5 | 5 | ✓ |
| 8 | Atlantic Warm Palette & LuaPixel | ORIGINAL_REQUEST §R2 | 5 | 5 | ✓ |
| 9 | Quality Gate Scripts Execution | ORIGINAL_REQUEST §AC | 5 | 5 | ✓ |
| 10 | Strict Asset Verification | ORIGINAL_REQUEST §AC | 5 | 5 | ✓ |

## Test Architecture
- Test runner: `flutter test` across `test/features/calendario/`, `test/core/`, `test/data/`, etc. + python3 tools quality gates
- Pass/fail semantics: exit code 0 on all gates and test suites

## Real-World Application Scenarios (Tier 4)
| # | Scenario | Features Exercised | Complexity |
|---|----------|--------------------|------------|
| 1 | Teacher Morning Assembly: Select active month, 1-touch launch assembly, run 6 steps, auto-sync to calendar | F1, F2, F3, F4, F6, F7, F8 | High |
| 2 | Family Evening Micro-Routine: Open calendar, toggle Hogar mode, read attention guide, check 3 golden rules, register home session, achieve Doble Estimulación | F1, F2, F3, F4, F6, F7, F8 | High |
| 3 | Toddler TPR English Listening: Teacher plays TPR command audio with LJSpeech model, engages movement | F5, F6, F7, F8 | Medium |
| 4 | Offline Persistence Cycle: Register aula, register hogar, restart store, verify state and Doble Estimulación count | F3, F4 | Medium |
| 5 | Full Repository Safety & Privacy Audit: Zero internet manifest, 5 python quality gates, 100% asset extension match | F9, F10 | Medium |

## Coverage Thresholds
- Tier 1: ≥5 per feature
- Tier 2: ≥5 per feature (boundary conditions)
- Tier 3: Pairwise coverage of major feature interactions
- Tier 4: ≥5 realistic application scenarios
