# Handoff Report — Spec Miner Requirements & Content Standards

**From**: Spec Miner Requirements (`teamwork_preview_spec_miner_survey_1`)  
**To**: Orchestrator (`teamwork_preview_orchestrator_1` / `155c43c0-be2b-46ce-b47d-cc280903c77f`)  
**Date**: 2026-09-11  
**Handoff Type**: Hard Handoff (Survey and Specification Mining Complete)  
**Deliverable**: `<raíz del proyecto>/.agents/teamwork_preview_spec_miner_survey_1/analysis.md`

---

## 1. Observation

1. **Requisitos de Usuario (`ORIGINAL_REQUEST.md`)**:
   - Líneas 5-8: Construir «Descubre con Lúa · Edición Vigo» en Flutter (Package ID: `com.earlify.descubreconlua`), portando módulos desde el repositorio del proyecto anterior de la casa (`Juega con Lúa · aula` y `Academy · familias`) bajo arquitectura estricta de contenido como datos JSON bilingües (`gl`/`es`), sin permisos de internet y con audio offline pregenerado.
   - Líneas 12-20 (R1): Manifiesto `AndroidManifest.xml` sin `android.permission.INTERNET` y cero clientes de red en `pubspec.yaml` ni en `lib/`.
   - Líneas 22-33 (R2): Modelos Dart para unidades temáticas (`Unidad`, `Vocabulario`, `Actividad`, `Preguntas`, `Exploracion`, `Matematicas`, `PuenteCasa`, `Revision`) y para Academy (`Capsula`, `Bloque`, `Afirmacion`, `Revision`). Carga desde `assets/content/**`. Archivos base: `unidades/juega.mar.01.json` y `capsulas/academy.como_se_aprende_a_hablar.01.json`. Validador automatizado en `test/data/` (paridad 1:1, integridad de audio, Decreto 150/2022 y filtro de términos clínicos prohibidos).
   - Líneas 34-44 (R3): Adaptación para uso exclusivo de adultos (docentes y familias). En Academy: 5 bloques, vista en 4 partes (idea clave, por qué importa, qué hacer en casa, ejemplo cotidiano), selector `gl`/`es`. En Juega: filtro por edad (0-2 y 2-3), asamblea guiada (canción a pulso, cuento, preguntas graduadas, exploración científica con materiales y aviso de seguridad, matemáticas tempranas, puente a casa).

2. **Código de Referencia en el proyecto anterior de la casa (`el proyecto anterior de la casa`)**:
   - `academyTypes.ts:22`: Declara silos de capacitación (`lenguaje`, etc.).
   - `academyContent.ts:25-94`: Estructura de cápsulas de lenguaje orientadas a familias con micro-explicaciones, turnos de conversación («serve and return») y tiempo de espera de 5 segundos.

3. **Normativa Curricular Oficial de Galicia (`Decreto 150/2022, do 8 de setembro`, DOG nº 172)**:
   - Establece 3 áreas de experiencia interrelacionadas para Educación Infantil (primer ciclo 0-3 años):
     - Área 1: *Crecemento en harmonía* (Crecimiento en armonía).
     - Área 2: *Descubrimento e exploración da contorna* (Descubrimiento y exploración del entorno).
     - Área 3: *Comunicación e representación da realidade* (Comunicación y representación de la realidad).
   - Criterios para 0-3: centrados en exploración manipulativa, nociones prelógicas (grande/pequeño), ritmos individuales y desarrollo comunicativo afectivo.

---

## 2. Logic Chain

1. **Desacoplamiento Clínico hacia lo Educativo**:
   - *Premisa*: A diferencia de los productos clínicos de la casa, «Descubre con Lúa · Edición Vigo» está concebida para el aula de infantil (0-3) y el hogar, y no tiene finalidad sanitaria.
   - *Inferencia*: Toda terminología patologizante o diagnóstica (*trastorno*, *patología*, *diagnóstico*, *síntoma*, *déficit*, *paciente*, *terapia*, *tratamiento*, *retraso clínico*) debe ser proscrita tanto de los JSONs como de la UI, sustituyéndose por conceptos del Decreto 150/2022 (*ritmo individual*, *desenvolvemento comunicativo*, *xogo guiado*, *estimulación*, *crianza*).

2. **Garantía de Paridad Bilingüe 1:1 mediante `LocalizedString`**:
   - *Premisa*: El bilingüismo en Galicia (0-3 años) requiere que cada concepto exista en paralelo en Gallego (normativa RAG) y Castellano sin omisiones ni asimetrías.
   - *Inferencia*: El modelo `LocalizedString { required String gl; required String es; }` a nivel de propiedad garantiza que ningún nodo pueda serializarse con una lengua faltante o vacía, permitiendo validación determinista en `test/data/bilingual_parity_test.dart`.

3. **Estructura Rígida de Contenido para el Modo Asamblea y las Cápsulas**:
   - *Premisa*: La docente necesita un flujo ordenado y predecible en asamblea (canción a pulso -> cuento -> preguntas -> exploración con seguridad -> matemáticas -> puente a casa); la familia requiere una micro-cápsula directa (idea clave -> por qué importa -> qué hacer en casa -> ejemplo cotidiano).
   - *Inferencia*: La estructura de datos de `Unidad` y `Capsula` debe reflejar obligatoriamente estas partes canónicas para que los widgets puedan renderizarlas de manera modular y tipada.

4. **Automatización de la Validación como Puerta de Calidad (CI Gate)**:
   - *Premisa*: Los errores en contenidos educativos (términos clínicos no deseados, rutas rotas de audio o textos desalineados) deben atraparse antes de la ejecución.
   - *Inferencia*: La suite en `test/data/` (schema validation, parity test, referential test, curricular test, clinical linter) proporciona el 100% de cobertura y verificación objetiva requerida en el criterio de aceptación.

---

## 3. Caveats

1. **Rutas Físicas de Archivos de Audio**:
   - Se han especificado las rutas relativas canónicas en assets (ej. `assets/audio/canciones/juega_mar_01_gl.mp3`); sin embargo, los binarios de audio MP3 reales deberán ser generados o aportados por los exploradores/trabajadores encargados de assets. La prueba de integridad referencial debe contemplar un modo de validación estructural si los ficheros de audio aún se encuentran en fase de maquetación/stubs.
2. **Catálogo de Unidades Futuras**:
   - Este informe define exhaustivamente el esquema y los datos base para `juega.mar.01.json` y `academy.como_se_aprende_a_hablar.01.json`. El esquema diseñado escala sin modificaciones a las futuras unidades de Vigo (ej. parque de Castrelos, monte do Castro, el puerto pesquero).

---

## 4. Conclusion

El diseño de la capa de Contenido como Datos (R2) y sus estándares pedagógicos, curriculares y lingüísticos están completamente especificados y documentados en `analysis.md`:
- Modelos Dart para unidades didácticas y cápsulas familiares con tipado exhaustivo.
- Cero tolerancia a términos clínicos con regex y tabla de equivalencias educativas.
- Paridad estricta 1:1 (`gl`/`es`) siguiendo la normativa de la Real Academia Galega (RAG).
- Alineación formal con las 3 áreas del Decreto 150/2022 de la Xunta de Galicia para el primer ciclo (0-3 años).
- JSONs completos listos para producción para `juega.mar.01.json` y `academy.como_se_aprende_a_hablar.01.json`.
- Especificación formal para la suite de pruebas unitarias en `test/data/`.

---

## 5. Verification Method

Para verificar independientemente las conclusiones de este informe:
1. **Inspección del Documento de Análisis**:
   - Leer `<raíz del proyecto>/.agents/teamwork_preview_spec_miner_survey_1/analysis.md`.
   - Comprobar que los JSONs de las secciones 6.1 y 6.2 son sintácticamente válidos (`jq . assets/content/...` o validador JSON estándar).
2. **Comprobación de Cumplimiento de Criterios de Aceptación**:
   - Contrastar los requisitos de `ORIGINAL_REQUEST.md` (líneas 22-33) contra las definiciones de `analysis.md` (Secciones 2, 3, 4, 5, 6 y 7).
3. **Condición de Invalidación**:
   - El informe se consideraría inválido si existiese algún término clínico en los textos de ejemplo, si faltase la correspondencia en gallego de algún campo o si no se citasen las áreas oficiales del Decreto 150/2022 para 0-3 años. Se ha verificado que ninguno de estos fallos está presente.
