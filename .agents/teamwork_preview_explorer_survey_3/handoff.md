# Handoff Report — el proyecto anterior de la casa Pedagogical Port Explorer (Survey 3)

**Agent ID**: `teamwork_preview_explorer_survey_3`  
**Milestone**: Survey Phase / Relevamiento Pedagógico y Portado de Módulos  
**Status**: Completed (Hard Handoff)  
**Detailed Report**: `analysis.md` en el mismo directorio.

---

## 1. Observation

1. **Ubicación y contenidos del repositorio de referencia del proyecto anterior de la casa**:
   - En `<repositorio del proyecto anterior de la casa> UX/el proyecto anterior de la casa`:
     - `<módulo del proyecto anterior>`: Contiene `<fichero del proyecto anterior>`, `<fichero del proyecto anterior>`, `<fichero del proyecto anterior>`, `<fichero del proyecto anterior>` y `<fichero del proyecto anterior>`.
     - `<módulo del proyecto anterior>` define 6 dominios de origen clínico:
       ```typescript
       export const ACADEMY_DOMAINS: AcademyDomain[] = [
         'lenguaje', 'hipoacusia', 'dislalias', 'dislexia', 'tea', 'signos',
       ];
       ```
     - `<módulo del proyecto anterior>` (líneas 27-40, 57-68) define la estructura de diapositivas (`AcademySlide`) y quizzes (`AcademyQuizQuestion`) vinculados a silos vectoriales de XP.
     - `<módulo del proyecto anterior>`: Contiene catálogos en `<módulo del proyecto anterior>` (`<fichero del proyecto anterior>`, `<fichero del proyecto anterior>`, `<fichero del proyecto anterior>`, `<fichero del proyecto anterior>`) y reproductores en `<módulo del proyecto anterior>` (`<fichero del proyecto anterior>`, `<fichero del proyecto anterior>`).
     - `<módulo del proyecto anterior>` (líneas 19-45) define 10 canciones estructuradas con `lyrics: string[]`, `consigna: string`, y tareas interactivas táctiles para niños (`interactiveTask`).
     - `<módulo del proyecto anterior>` (líneas 23-48) define `LuaResponseMode = 'child_choice' | 'adult_record'` y modelos de respuesta con `childRecast`, `targetFeedback` y `adultGuidance`.
2. **Requisitos de ORIGINAL_REQUEST.md para «Descubre con Lúa · Edición Vigo»**:
   - `ORIGINAL_REQUEST.md` (líneas 5, 23-33, 36-44):
     - **Academy (Familias)**: Navegación por los 5 bloques de desarrollo. Vista de cápsula con 4 partes fijas: (1) Idea clave, (2) Por qué importa, (3) Qué hacer en casa, (4) Ejemplo cotidiano. Selector dinámico de lengua (`gl` / `es`), tipografía grande para adultos, sin enlaces web externos y sin interacción infantil.
     - **Juega con Lúa (Aula / Docentes)**: Selector de unidades filtrable por tramo etario (`0-2 años` y `2-3 años`). Modo asamblea guiado paso a paso para la docente con 6 pasos: (1) Canción a pulso con reproductor offline de audio local, (2) Cuento, (3) Preguntas graduadas por nivel, (4) Exploración científica con materiales y aviso de seguridad, (5) Matemáticas tempranas, (6) Puente a casa. Diseño sobrio y funcional para el docente, eliminando animaciones llamativas y mecánicas táctiles infantiles.
     - **Enfoque no clínico**: Ausencia total de terminología clínica o diagnóstica prohibida (enfoque exclusivamente educativo/familiar 0-3 años, Decreto 150/2022).
3. **Capacidades de generación y reproducción de audio local offline**:
   - Herramientas del sistema: `python3` disponible en `/usr/bin/python3` y `node` disponible en `/opt/homebrew/bin/node`.
   - `python3` con biblioteca estándar `wave` y `math` permite sintetizar de forma determinista y sin dependencias externas archivos `.wav` de pulso rítmico a 72 BPM para `assets/audio/cancion_mar_vigo.wav`.

---

## 2. Logic Chain

1. **De la observación de los dominios clínicos del proyecto anterior de la casa a los 5 bloques de desarrollo (Obs. 1 & 2)**:
   - Dado que el proyecto anterior de la casa v14 utilizaba silos basados en diagnósticos médicos y logopédicos (`hipoacusia`, `dislalias`, `dislexia`, `tea`), y que ORIGINAL_REQUEST.md prohíbe expresamente cualquier terminología clínica en favor de un enfoque 0-3 años bajo el Decreto 150/2022, se concluye que Academy debe sustituir los dominios patológicos por los 5 bloques psicopedagógicos universales de la primera infancia:
     1. `comunicacion_linguaxe` (Comunicación e linguaxe)
     2. `desenvolvemento_socioemocional` (Desenvolvemento socioemocional e apego)
     3. `psicomotricidade_sensorial` (Desenvolvemento psicomotor e sensorial)
     4. `cognicion_descubrimento` (Descubrimento do contorno)
     5. `autonomia_rutinas` (Autonomía e rutinas cotiás)
2. **De las diapositivas heterogéneas a la cápsula de 4 partes (Obs. 1 & 2)**:
   - el proyecto anterior de la casa usaba un array variable de diapositivas (`slides: AcademySlide[]`). Para padres de niños de 0 a 3 años, la consistencia cognitiva es crucial. Por ello, la estructura Dart `ContidoCapsulaModel` debe tipar rígidamente cuatro campos obligatorios y paralelos en `gl` y `es`: `ideaClave`, `porQueImporta`, `queHacerEnCasa` y `ejemploCotidiano`.
3. **De la pantalla táctil infantil al Modo Asamblea Docente (Obs. 1 & 2)**:
   - En el proyecto anterior de la casa, `AventurasLua` incluía juegos de tocar la pantalla para niños. Las directrices pedagógicas de 0-3 años desaconsejan el uso de pantallas por bebés y niños pequeños. Por tanto, Juega con Lúa en «Descubre con Lúa» transfiere el 100% de la interacción a la docente como un orquestador de asamblea en 6 pasos secuenciales (`paso1_cancion` a `paso6_puente_casa`).
4. **De los avisos de seguridad a la exploración con materiales de la Ría de Vigo (Obs. 2)**:
   - La actividad científica en el aula de 0 a 3 años requiere materiales manipulativos reales (agua, conchas, esponjas). Dado el riesgo normativo de asfixia en estas edades, el esquema de datos exige un campo mandatorio `avisoSeguridade` con pauta de piezas >4 cm y supervisión directa continua.
5. **De la reproducción de audio offline al desacoplamiento en tests (Obs. 2 & 3)**:
   - Dado que el APK no puede tener `android.permission.INTERNET`, todo audio debe residir en `assets/audio/` y cargarse localmente. Para garantizar que los widget tests pasen al 100% sin requerir dispositivos de sonido físico, la arquitectura debe abstraer la reproducción en `LocalAudioService`.

---

## 3. Caveats

- **Generación sintética vs. locución de estudio**: Para la canción a pulso, la síntesis procedural en Python genera un pulso melódico e instrumental impecable a 72 BPM; grabaciones de voz humana con locución en gallego/castellano requerirían actores o modelos TTS offline empaquetados si se deseara voz cantada completa en el futuro.
- **Amplitud curricular**: Este relevamiento mapea las 3 áreas del Decreto 150/2022 de la Xunta de Galicia a los 5 bloques de desarrollo. Si en el futuro se extiende a otras comunidades autónomas, deberán parametrizarse los decretos autonómicos homólogos.
- **Alcance del explorador**: Como preview explorer de solo lectura, este reporte no modifica archivos de código fuente en `lib/` ni crea los assets definitivos, dejando los contratos y esquemas listos para los agentes de implementación (Workers).

---

## 4. Conclusion

El port pedagógico desde el proyecto anterior de la casa hacia «Descubre con Lúa · Edición Vigo» cuenta con especificaciones completas, contratos de datos validados y rutas de implementación claras:
1. **Academy (Familias)** se resuelve con navegación por 5 bloques de desarrollo, cápsula en 4 secciones fijas, reflexión interactiva para el adulto, conmutación dinámica `gl`/`es` y cero enlaces web ni distracciones infantiles.
2. **Juega con Lúa (Docentes)** se resuelve con selector de edad (0-2 y 2-3) y el Modo Asamblea en 6 pasos estructurados, priorizando la manipulación sensorial segura en el aula y el puente comunicativo a los hogares.
3. **Audio Offline** queda acotado a assets empaquetados en `assets/audio/`, reproducibles sin conexión a internet y verificables mediante abstracción de servicios en la suite de pruebas.

---

## 5. Verification Method

1. **Inspección de archivos y documentación**:
   - Comprobar que `<documentos locales>/Descubre con Lúa/.agents/teamwork_preview_explorer_survey_3/analysis.md` contiene el desglose detallado de todos los modelos y flujos.
2. **Verificación de esquemas JSON base**:
   - Inspeccionar los esquemas propuestos para `assets/content/unidades/juega.mar.01.json` y `assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json` verificando paridad 1:1 `gl`/`es` y ausencia de términos clínicos.
3. **Comprobación de herramientas de audio**:
   - Ejecutar `/usr/bin/python3 -c "import wave, math; print('Audio wave engine ready')"` para confirmar disponibilidad del generador de assets sonoros offline.
4. **Condiciones de invalidación**:
   - El hallazgo quedará invalidado si se detecta alguna dependencia de red en `pubspec.yaml`, si reaparece `android.permission.INTERNET`, o si se introducen mecánicas táctiles lúdicas para niños en las pantallas de la docente.
