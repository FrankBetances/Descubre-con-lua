# Informe de Análisis Pedagógico y Portado de Módulos: el proyecto anterior de la casa → Descubre con Lúa · Edición Vigo

**Fecha de relevamiento**: 2026-09-11  
**Explorador**: el proyecto anterior de la casa Pedagogical Port Explorer (`teamwork_preview_explorer_survey_3`)  
**Proyecto destino**: «Descubre con Lúa · Edición Vigo» (Flutter Android, `com.earlify.descubreconlua`)  
**Repositorio de referencia**: el repositorio del proyecto anterior de la casa (v14 Expo/React Native, ubicado en `<repositorio del proyecto anterior de la casa> UX/el proyecto anterior de la casa`)

---

## 1. Síntesis Ejecutiva y Hallazgos Principales

1. **Localización de fuentes de referencia en el entorno local**:
   - Se localizó el código fuente completo y actualizado de **el proyecto anterior de la casa v14** en `<repositorio del proyecto anterior de la casa> UX/el proyecto anterior de la casa`.
   - Se auditaron en profundidad los dos módulos canónicos:
     - **Academy**: Implementado en `<módulo del proyecto anterior>` (`<fichero del proyecto anterior>`, `<fichero del proyecto anterior>`, `<fichero del proyecto anterior>`, `<fichero del proyecto anterior>`, `<fichero del proyecto anterior>`).
     - **Aventuras con Lúa**: Implementado en `<módulo del proyecto anterior>` (`<módulo del proyecto anterior>`, `<módulo del proyecto anterior>`, `<módulo del proyecto anterior>`, `<módulo del proyecto anterior>`, `<módulo del proyecto anterior>`).
2. **Reconversión de paradigma clínico a educativo (0–3 años)**:
   - El proyecto anterior de la casa es un producto clínico, con otra finalidad, otro público y otro marco regulatorio.
   - «Descubre con Lúa · Edición Vigo» requiere una **desinfección clínica total**: se erradican los silos de patología y términos clínicos (`trastorno`, `patoloxía`, `diagnóstico`, `terapia`, `paciente`, `síntoma`). En su lugar, se adopta un marco estrictamente pedagógico y de estimulación natural para el **primer ciclo de educación infantil en Galicia (0–3 años)** bajo el amparo curricular del **Decreto 150/2022**.
3. **Academy (Familias)**:
   - Se estructura sobre **5 Bloques de Desarrollo** en lugar de patologías.
   - Cada cápsula adopta una **arquitectura rígida de 4 partes pedagógicas**: (1) Idea clave, (2) Por qué importa, (3) Qué hacer en casa, y (4) Ejemplo cotidiano.
   - Incorpora una sección de reflexión interactiva para el adulto (`Afirmación pedagógica`) sin dinámicas de videojuego infantil.
   - UI ergonómica para adultos: tipografía amplia (17-18 sp), selector dinámico bilingüe (`GL` / `ES`) en caliente, cero enlaces externos y cero mecánicas lúdicas infantiles.
4. **Juega con Lúa (Aula / Docentes)**:
   - Rediseño integral: pasa de ser una pantalla táctil infantil a ser una **herramienta docente de asamblea (Modo Asamblea Guiada)**. Los niños de 0–3 años no interactúan con la pantalla; la docente orquesta la sesión en el aula.
   - Selector de tramos etarios normativos: `0-2 anos` y `2-3 anos`.
   - Flujo lineal de 6 pasos secuenciales: (1) Canción a pulso con audio local offline, (2) Cuento / historia, (3) Preguntas graduadas por tramo etario, (4) Exploración científica manipulativa con aviso visible de seguridad y materiales reales de la ría de Vigo, (5) Matemáticas tempranas, y (6) Puente a casa (caderno de comunicación).
   - UI sobria, funcional y de alta densidad para la educadora en el aula.
5. **Arquitectura de Audio Offline**:
   - 100% offline empaquetado en assets locales (`assets/audio/**`).
   - Cero llamadas de red, cero streaming, cero permisos de internet en el binario.
   - Reproductor local desacoplado (`LocalAudioPlayer`) fácilmente mockeable para widget tests.

---

## 2. Estudio Comparativo de Arquitectura: el proyecto anterior de la casa vs. Descubre con Lúa

| Dimensión | el proyecto anterior de la casa v14 (Referencia) | Descubre con Lúa · Edición Vigo (Port) |
|---|---|---|
| **Stack tecnológico** | React Native 0.81 / Expo SDK 54 / TypeScript | Flutter 3.x / Dart / Android Nativo (`com.earlify.descubreconlua`) |
| **Público objetivo** | Clínico / Familiar mixto (niños de 0 a 10 años + cuidadores) | **Doble interfaz segregada**: Familias (Academy) y Docentes de aula 0-3 (Juega) |
| **Marco regulatorio** | Producto clínico (marco propio, fuera de este repositorio) | Educativo / Normativo Galicia: **Decreto 150/2022** (0–3 años) |
| **Vocabulario** | Diagnóstico y terapéutico (pares mínimos, hipoacusia, implante) | **Educativo y estimulativo puro** (cero terminología clínica prohibida) |
| **Almacenamiento de contenido** | Archivos TypeScript en memoria (`<fichero del proyecto anterior>`, etc.) | **Archivos JSON bilingües desacoplados** en `assets/content/**` |
| **Estructura Academy** | Diapositivas libres + micro-quiz con XP vectorial | **4 partes fijas por cápsula** + reflexión adulta + ficha curricular |
| **Estructura Juega** | Videojuegos táctiles infantiles (memorama, selección táctil) | **Modo Asamblea Guiada (6 pasos)** orquestado por la docente |
| **Mecánicas infantiles en pantalla** | Sí (fichas voxel, premios, armario de Lúa, confeti) | **Eliminadas**: sobriedad adulta y pedagógica |
| **Audio** | Locuciones neuronales sintetizadas en 6 variedades | **Audio local offline pregenerado** (canción a pulso a 72 BPM) |
| **Permisos de red** | Cero llamadas (cero Firebase en v14) | **Cero `android.permission.INTERNET` verificado en AndroidManifest** |

---

## 3. Especificación Detallada: Academy (Familias)

### 3.1. Los 5 Bloques de Desarrollo Infantil (0–3 años)
En lugar de los dominios patológicos del proyecto anterior de la casa (`hipoacusia`, `dislalias`, `dislexia`, `tea`), Academy en Descubre con Lúa se organiza en torno a los 5 ejes naturales del desarrollo psicopedagógico temprano alineados con las tres áreas curriculares del Decreto 150/2022:

1. **`comunicacion_linguaxe` (Comunicación e linguaxe / Comunicación y lenguaje)**:
   - *Enfoque*: El baño de lenguaje, la atención conjunta, el turno de conversación (*serve and return*), el valor de la pausa silenciosa (4-5 segundos), entonación afectiva y modelado sin corrección punitiva.
   - *Área Decreto 150/2022*: Área 3 (Comunicación e representación da realidade).
2. **`desenvolvemento_socioemocional` (Desenvolvemento socioemocional e apego / Desarrollo socioemocional y apego)**:
   - *Enfoque*: Vínculo seguro, contención del llanto, validación de frustraciones tempranas, contacto visual y juego interactivo cara a cara.
   - *Área Decreto 150/2022*: Área 1 (Crecemento en harmonía).
3. **`psicomotricidade_sensorial` (Desenvolvemento psicomotor e sensorial / Desarrollo psicomotor y sensorial)**:
   - *Enfoque*: Tono muscular, volteo, gateo, agarre en pinza, exploración descalzos, texturas del entorno y coordinación óculo-manual.
   - *Área Decreto 150/2022*: Área 1 (Crecemento en harmonía).
4. **`cognicion_descubrimento` (Descubrimento do contorno / Descubrimiento y exploración del entorno)**:
   - *Enfoque*: Causa-efecto, permanencia del objeto, exploración de elementos naturales (agua, arena, hojas, conchas de la ría), curiosidad espontánea.
   - *Área Decreto 150/2022*: Área 2 (Descubrimento e exploración do contorno).
5. **`autonomia_rutinas` (Autonomía e rutinas cotiás / Autonomía y rutinas cotidianas)**:
   - *Enfoque*: Higiene, rutinas de sueño predecibles, participación activa en el vestido y desvestido, alimentación autorregulada y despedidas seguras.
   - *Área Decreto 150/2022*: Área 1 (Crecemento en harmonía).

### 3.2. Estructura Canónica de la Cápsula (Las 4 Partes)
Cada cápsula se visualiza en una pantalla estructurada en 4 tarjetas de contenido verticalmente ordenadas:

1. **💡 Idea Clave (`ideaClave`)**:
   - Enunciado esencial sintetizado en 2 o 3 líneas. Transmite el concepto pedagógico nuclear sin tecnicismos.
2. **🔍 Por Qué Importa (`porQueImporta`)**:
   - Justificación basada en la neurociencia del desarrollo y la psicología evolutiva, explicada de forma clara y accesible para los progenitores.
3. **🏡 Qué Hacer en Casa (`queHacerEnCasa`)**:
   - Orientaciones prácticas, directas y realistas para aplicar en los momentos ordinarios del hogar (comida, baño, paseo, juego libre).
4. **🌟 Ejemplo Cotidiano (`ejemploCotidiano`)**:
   - Micro-diálogo o situación contextualizada paso a paso con frases textuales que la madre o el padre pueden emplear con el bebé.

Adicionalmente, cada cápsula contiene:
- **Ficha de Reflexión Pedagógica (`afirmacion`)**: Un micro-desafío interactivo para el adulto compuesto por una pregunta, dos opciones de respuesta (una adecuada y otra equivocada sobre mitos habituales) y una retroalimentación explicativa inmediata.
- **Metadatos Curriculares y de Revisión (`revision`)**: Código identificador, fecha de revisión editorial y vinculación con el Decreto 150/2022.

### 3.3. Ergonomía y UI para Adultos
- **Tipografía amplia y confortable**: Tamaños de cuerpo entre 16 y 18 sp con altura de línea de 1.45 a 1.5, garantizando lectura descansada en dispositivos móviles para madres y padres en momentos de fatiga.
- **Selector dinámico de idioma (`gl` / `es`)**: Conmutador visible en la barra superior (`AppBar`) que actualiza instantáneamente todos los textos de la interfaz y del contenido JSON sin reiniciar la pantalla ni perder la posición de lectura.
- **Prohibición estricta de enlaces externos**: No existen botones de enlace a páginas web externas, ni `launchUrl`, ni `WebView`, salvaguardando el principio de privacidad total sin acceso a red.
- **Eliminación de mecánicas infantiles**: Cero sonidos estridentes, cero confeti animado, cero avatares jugables. La interfaz transmite rigor, serenidad, calidez y profesionalidad.

---

## 4. Especificación Detallada: Juega con Lúa (Aula / Docentes)

### 4.1. Selector de Tramo Etario
La docente puede filtrar las unidades o las actividades de la asamblea mediante un selector de dos tramos oficiales:
- **`0-2 anos`**: Prioridad en contacto visual, canciones rítmicas de balanceo, estimulación auditivo-vocal, imitación y exploración sensorial de bajo tono.
- **`2-3 anos`**: Prioridad en lenguaje verbal expresivo, juego simbólico elemental, clasificación por atributos sencillos (tamaño, textura), conteo intuitivo de 1 y 2, y formulación de preguntas.

### 4.2. El Modo Asamblea Guiada (6 Pasos Secuenciales)
El modo asamblea convierte a la aplicación en una guía de apoyo pedagógico para la educadora. No se entrega el dispositivo a los niños; la educadora lo consulta para dinamizar la sesión grupal en el aula:

```
[ Paso 1: Canción a pulso ]
       ↓
[ Paso 2: Cuento / Historia ]
       ↓
[ Paso 3: Preguntas graduadas por nivel ]
       ↓
[ Paso 4: Exploración científica con materiales y aviso de seguridad ]
       ↓
[ Paso 5: Matemáticas tempranas ]
       ↓
[ Paso 6: Puente a casa ]
```

#### Paso 1: Canción a Pulso
- **Objetivo**: Entrada a la asamblea, sincronización atencional y estimulación del ritmo del lenguaje mediante el pulso motor.
- **Componentes**:
  - Reproductor de audio local integrado (reproducir, pausar, reiniciar).
  - Pauta rítmica fijada a **72 BPM** (ritmo cardíaco tranquilo / pulso pedagógico de balanceo).
  - Guía didáctica para la docente (ej. acompañar con palmas sobre las piernas o balanceo de telas azules imitando las olas de la ría de Vigo).
  - Letra bilingüe completa presentada en estrofas claras.

#### Paso 2: Cuento / Historia
- **Objetivo**: Inmersión narrativa y ampliación léxica contextualizada en la realidad cultural de Vigo (el puerto, las gaviotas, las conchas en Samil, los barcos de la ría).
- **Componentes**:
  - Guion de lectura expresiva con indicaciones de modulación de voz y pausas.
  - Párrafos narrativos breves ilustrados con pictogramas o apoyos visuales estáticos.

#### Paso 3: Preguntas Graduadas por Nivel
- **Objetivo**: Fomentar la comprensión y la participación activa respetando el ritmo madurativo de cada grupo.
- **Estructuración diferencial**:
  - *Preguntas 0–2 años*: Consignas deícticas y de respuesta gestual («¿Onde está o barco?», «¿Como fan as gaivotas? ¡Uuuh, uuuh!») con pauta para que la docente muestre objetos concretos y espere la fijación de la mirada.
  - *Preguntas 2–3 años*: Preguntas abiertas de denominación y funcionalidad («¿Que atopou Lúa na area?», «¿Para que serven os barcos?») fomentando frases simples de 2 y 3 palabras.

#### Paso 4: Exploración Científica con Materiales y Aviso de Seguridad
- **Objetivo**: Experiencia de descubrimiento sensorial y científico manipulativo (agua marina o salada, esponjas, conchas lisas).
- **Materiales sugeridos**: Lista de elementos seguros y accesibles en el aula infantil.
- **Aviso Mandatorio de Seguridad (`avisoSeguridade`)**:
  - Caja de alerta visual prominente (borde ámbar/rojo con icono de advertencia).
  - Prescripción explícita: **Vigilancia adulta directa y continua obligatoria**.
  - Control de tamaño: **Todas las piezas manipulables deben superar los 4 cm de diámetro** para anular cualquier riesgo de asfixia o atragantamiento.
  - Prohibición de elementos desmenuzables, arenas finas sin humedecer o conchas con bordes afilados.
- **Procedimiento docente**: Pauta paso a paso de facilitación en el suelo sobre toallas.

#### Paso 5: Matemáticas Tempranas
- **Objetivo**: Asentamiento de las nociones pre-numéricas y topológicas básicas.
- **Contenidos adaptados**:
  - Cuantificadores intuitivos: *Moito / Pouco* (Mucho / Poco).
  - Nociones dimensionales: *Grande / Pequeno* (Grande / Pequeño).
  - Primeras cantidades discretas: Identificación y recuento de 1 y 2 elementos reales.
  - Nociones espaciales: *Dentro / Fóra* (Dentro / Fuera de la bandeja o del cubo).

#### Paso 6: Puente a Casa
- **Objetivo**: Corresponsabilidad educativa aula-hogar.
- **Componentes**:
  - Sugerencia de continuidad para las familias (ej. recordar la canción de las olas durante el baño nocturno).
  - Texto formateado para el «Caderno de comunicación / Axenda escolar», listo para copiar o transcribir por la docente.

### 4.3. UI Sobria y Funcional para Docentes
- **Panel de control limpio**: Barra superior con indicador de progreso (`Paso 3 de 6`), botones grandes de avance y retroceso accesibles con una sola mano.
- **Tarjetas colapsables / legibles a distancia**: Tipografía limpia (16 sp para instrucciones, 20 sp para consignas) con fondo neutro y contrastado para permitir lectura mientras la docente mantiene contacto visual con los niños en la alfombra.
- **Sin elementos distractores infantiles**: Se descartan animaciones llamativas, efectos de sonido estridentes, mascotas parlantes o botones de minijuegos diseñados para que el niño pulse en pantalla.

---

## 5. Requisitos de Audio Offline y Reproductor Local

### 5.1. Almacenamiento y Formatos
- Ubicación estricta: `assets/audio/` declarado en `pubspec.yaml`.
- Formato recomendado: `.wav` (PCM 16-bit, 44.1 kHz, mono/estéreo) o `.mp3` (128 kbps CBR).
- Nombres canónicos:
  - `assets/audio/cancion_mar_vigo.mp3` (o `.wav`): Canción a pulso de la Unidad 1 de Vigo.
  - `assets/audio/pulso_72bpm.wav`: Metrónomo de pulso rítmico a 72 BPM para acompañamiento musical sin instrumentación invasiva.

### 5.2. Generación Determinista de Audio Local
Para garantizar que el proyecto sea completamente autónomo y no dependa de descargas de red ni de grabaciones externas en tiempo de compilación:
- Puede utilizarse un script en Python 3 puro (utilizando el módulo estándar `wave` y `math`) para sintetizar el patrón armónico rítmico a 72 BPM de la canción de Vigo con timbres suaves de carillón/marimba adecuados para bebés.
- Esto garantiza que `assets/audio/` contenga binarios válidos, reproducibles y verificables en tests.

### 5.3. Reproductor Local y Desacoplamiento Arquitectónico
- En Flutter, la reproducción de audio offline se gestionará mediante un servicio abstracto:
  ```dart
  abstract class LocalAudioService {
    Future<void> playAsset(String assetPath);
    Future<void> pause();
    Future<void> stop();
    Stream<Duration> get positionStream;
    Stream<bool> get isPlayingStream;
    void dispose();
  }
  ```
- Este diseño desacoplado permite:
  1. Usar un paquete liviano como `audioplayers` (con `AssetSource`) en la implementación nativa Android.
  2. Inyectar un `MockLocalAudioService` en los widget tests (`test/features/juega/`), permitiendo validar el 100% de la UI del Modo Asamblea y sus cambios de estado sin necesidad de emuladores ni hardware de sonido real.

---

## 6. Modelos de Datos Dart y Especificación de Esquemas JSON

### 6.1. Modelos de Academy (Familias)
```dart
// lib/data/models/capsula_model.dart

class BloqueModel {
  final String id;
  final LocalizedString titulo;
  final LocalizedString descripcion;
  final String icono;
  final int orden;
  // ...
}

class CapsulaModel {
  final String id;
  final String bloqueId;
  final int orden;
  final LocalizedString titulo;
  final LocalizedString subtitulo;
  final int tempoLecturaMinutos;
  final ReferenciaCurricularModel referenciaCurricular;
  final ContidoCapsulaModel contido;
  final AfirmacionModel afirmacion;
  final RevisionModel revision;
  // ...
}

class ContidoCapsulaModel {
  final LocalizedString ideaClave;
  final LocalizedString porQueImporta;
  final LocalizedString queHacerEnCasa;
  final LocalizedString ejemploCotidiano;
  // ...
}

class AfirmacionModel {
  final LocalizedString pregunta;
  final List<OpcionAfirmacionModel> opcions;
  final LocalizedString explicacion;
  // ...
}
```

### 6.2. Modelos de Juega con Lúa (Docentes)
```dart
// lib/data/models/unidad_model.dart

class UnidadModel {
  final String id;
  final String tema;
  final LocalizedString titulo;
  final LocalizedString subtitulo;
  final List<String> tramosEtarios; // ["0-2", "2-3"]
  final ReferenciaCurricularModel referenciaCurricular;
  final List<VocabularioItemModel> vocabulario;
  final AsambleaModel asamblea;
  final RevisionModel revision;
  // ...
}

class AsambleaModel {
  final PasoCancionModel paso1Cancion;
  final PasoCuentoModel paso2Cuento;
  final PasoPreguntasModel paso3Preguntas;
  final PasoExploracionModel paso4Exploracion;
  final PasoMatematicasModel paso5Matematicas;
  final PasoPuenteCasaModel paso6PuenteCasa;
  // ...
}
```

---

## 7. Diccionario de Términos Prohibidos y Validación Lingüística

Para cumplir con el requerimiento R2 y R3 de enfoque exclusivamente educativo y familiar, el validador de esquemas y tests unitarios rechazará cualquier contenido que contenga los siguientes términos clínicos o diagnósticos:

| Categoría | Términos Prohibidos (Gallego / Castellano) | Sustitución Pedagógica Recomendada |
|---|---|---|
| **Patología** | `patoloxía`, `patología`, `trastorno`, `enfermidade`, `enfermedad`, `síndrome`, `déficit` | *proceso de aprendizaxe*, *ritmo de desenvolvemento*, *necesidade individual* |
| **Diagnóstico** | `diagnóstico`, `diagnosticar`, `síntoma`, `signo clínico`, `cribado clínico`, `screening` | *observación atenta*, *fito do desenvolvemento*, *sinais de alerta educativa* |
| **Intervención** | `terapia`, `tratamento`, `tratamiento`, `terapeuta`, `rehabilitación`, `clínico`, `paciente` | *actividade pedagóxica*, *estimulación na aula*, *acompañamento*, *nena / neno* |
| **Disfunción** | `retraso mental`, `dislalia`, `hipoacusia`, `dislexia`, `afasia`, `disfasia`, `mutismo` | *comunicación emerxente*, *estimulación auditiva*, *desenvolvemento da fala* |

Asimismo, la suite de tests en `test/data/` verificará la **paridad estricta 1:1** de claves entre `gl` y `es` en cada objeto de `LocalizedString`.

---

## 8. Recomendaciones para los Siguientes Milestones

1. **Para M1 (Setup Flutter & Privacidad)**:
   - Configurar `pubspec.yaml` sin dependencias de red, utilizando `audioplayers: ^6.0.0` o similar.
   - Certificar que `android/app/src/main/AndroidManifest.xml` (especialmente en variante release) omita completamente `android.permission.INTERNET`.
2. **Para M2 (Content-as-Data & JSONs)**:
   - Crear `assets/content/unidades/juega.mar.01.json` y `assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json` con la estructura bilingüe completa especificada en este informe.
   - Generar `assets/audio/cancion_mar_vigo.wav` a 72 BPM.
   - Programar los tests unitarios en `test/data/` que validen esquema, integridad de audio, referencias al Decreto 150/2022 y filtro de términos clínicos.
3. **Para M3 (Implementación de Pantallas y Widget Tests)**:
   - Implementar `AcademyScreen` con lista de los 5 bloques, vista de cápsula de 4 partes y conmutador `gl`/`es`.
   - Implementar `JuegaScreen` con selector de edad 0-2 / 2-3 y el wizard de 6 pasos de la asamblea para la docente.
   - Probar flujos completos mediante widget tests (`test/features/academy/` y `test/features/juega/`).
