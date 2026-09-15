# Especificación Técnica y Minería de Requisitos y Estándares de Contenido
## Proyecto: «Descubre con Lúa · Edición Vigo» (Flutter / Android)
**Documento**: `analysis.md`  
**Autor**: Spec Miner Requirements (`teamwork_preview_spec_miner_survey_1`)  
**Fecha**: 2026-09-11  
**Estado**: Completado  
**Referencia Principal**: `ORIGINAL_REQUEST.md`  
**Marco Curricular**: Decreto 150/2022, do 8 de setembro (Educación Infantil en Galicia, 0-3 anos)

---

## 1. Resumen Ejecutivo y Marco General

La aplicación nativa Android «Descubre con Lúa · Edición Vigo» (Package ID: `com.earlify.descubreconlua`) traslada la experiencia pedagógica y de estimulación de la comunicación temprana al contexto educativo infantil y familiar de Vigo y Galicia (0 a 3 años). 

A diferencia de los proyectos clínicos de la casa, este desarrollo tiene un carácter **estrictamente educativo, preventivo y familiar**, operando bajo el paradigma de **«Contenido como Datos» (Content-as-Data)**:
1. **Zero-Network / Privacidad Absoluta**: Ausencia total de permisos de internet en el `AndroidManifest.xml` de release y cero dependencias de red en `pubspec.yaml`.
2. **Arquitectura Content-as-Data**: Todo el contenido temático y formativo se modela como documentos JSON fuertemente tipados bajo `assets/content/**`, con validación estricta en tiempo de pruebas unitarias (`test/data/`).
3. **Paridad Bilingüe Estricta 1:1**: Coexistencia paritaria, simétrica y simultánea del Gallego (`gl` - RAG) y Castellano (`es`) en cada campo textual.
4. **Alineación Curricular Oficial**: Anclaje en el Decreto 150/2022 de la Xunta de Galicia para el primer ciclo de Educación Infantil (0-3 años).
5. **Muro Terminológico Educativo**: Erradicación absoluta de cualquier término clínico, patológico o diagnóstico.

---

## 2. Requisitos Funcionales y Pedagógicos (R1, R2, R3)

### 2.1. Módulo «Juega con Lúa · Aula» (Uso Docente)
- **Destinatarios**: Educadoras y educadores infantiles de escuelas de 0 a 3 años (Galiña Azul, escuelas infantiles municipales y privadas de Vigo).
- **Enfoque de Interfaz**: Herramienta de mediación para el adulto; se eliminan deliberadamente mecánicas táctiles infantiles, gamificación ruidosa o animaciones distractoras. La pantalla asiste a la docente para conducir la dinámica presencial en el aula.
- **Filtro Etario**: Selección ágil por tramos evolutivos:
  - `0-2 años` (0-12 meses y 12-24 meses: estimulación sensorial, canciones a pulso, señalamiento).
  - `2-3 años` (iniciación al léxico activo, pequeñas frases, categorización temprana).
- **Modo Asamblea Guiada (6 Fases Canónicas)**:
  1. **Canción a Pulso**: Estímulo rítmico musical con reproductor offline de audio local, marcas visuales de compás/pulso para percusión corporal (palmadas, balanceo).
  2. **Cuento Ilustrado**: Narración breve contextualizada en la geografía marina y social de Vigo (la ría, los barcos, las gaviotas, las bateas de mejillón, Samil o Bouzas).
  3. **Preguntas Graduadas**: Secuencia de 3 niveles de andamiaje:
     - Nivel 1: Señalamiento e identificación visual/auditiva («¿Dónde está el barco?»).
     - Nivel 2: Denominación y onomatopeyas («¿Qué es esto? ¡El barco hace pi-pi!»).
     - Nivel 3: Relación causal y experiencia vivida («¿Quién viaja en el barco?»).
  4. **Exploración Científica y Sensorial**: Manipulación de objetos reales con consigna paso a paso, lista de materiales y **Aviso Crítico de Seguridad** (previsión de atragantamiento, elementos >5 cm, no tóxicos, supervisión 100%).
  5. **Matemáticas Tempranas**: Discriminación prelógica 0-3 años (grande/pequeño, dentro/fuera, uno/muchos, lleno/vacío).
  6. **Puente a Casa**: Sugerencias claras y amables para transmitir a las familias al finalizar la jornada escolar.

### 2.2. Módulo «Academy · Familias» (Uso Hogar)
- **Destinatarios**: Madres, padres y cuidadores principales de bebés y niños de 0 a 3 años.
- **Enfoque de Interfaz**: Lectura cómoda para adultos (tipografía amplia, alto contraste, estilo editorial sobrio), sin enlaces web salientes, sin navegación infantil desatendida.
- **Estructura en 5 Bloques de Desarrollo**:
  1. `desarrollo_comunicativo`: Cómo se aprende a hablar (hitos evolutivos normativos, audición y lenguaje).
  2. `rutinas_y_bano_de_lenguaje`: El baño de lenguaje en la vida cotidiana (comida, baño, paseo, cambio de pañal).
  3. `turnos_y_atencion_conjunta`: Conversar antes de hablar (la técnica de servir y devolver, la regla de los 5 segundos de espera, miradas compartidas).
  4. `juego_movimiento_sin_pantallas`: Psicomotricidad, juego corporal compartido y entorno libre de pantallas para menores de 3 años.
  5. `bilinguismo_y_cultura`: Crianza bilingüe armoniosa en Galicia (aprender y convivir en gallego y castellano sin interferencias ni presiones).
- **Las 4 Partes Canónicas de la Cápsula**:
  1. **Idea Clave**: Concepto nuclear sintetizado en 2-3 oraciones directas.
  2. **Por Qué Importa**: Fundamento del desarrollo cerebral y vincular explicado con claridad divulgativa.
  3. **Qué Hacer en Casa**: Pautas de acción prácticas, aplicables en cualquier hogar sin materiales especiales.
  4. **Ejemplo Cotidiano**: Guion dialogado de una escena real (ej. calzando los zapatos, en la bañera).
- **Reflexión Formativa (Afirmaciones)**: 2-3 afirmaciones reflexivas (verdadero/falso con retroalimentación inmediata comprensiva, nunca punitiva).

---

## 3. Capa de Contenido como Datos (R2): Modelos Dart y Esquemas

La capa de datos se implementará en Dart fuertemente tipado en `lib/data/models/` y se alimentará de archivos JSON locales en `assets/content/`.

### 3.1. Modelo Primitivo de Localización: `LocalizedString`
Para evitar desincronizaciones o archivos paralelos huérfanos, cada campo de texto visible para el usuario se modela mediante el objeto `LocalizedString`:

```dart
class LocalizedString {
  final String gl;
  final String es;

  const LocalizedString({
    required this.gl,
    required this.es,
  });

  factory LocalizedString.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('gl') || !json.containsKey('es')) {
      throw FormatException('LocalizedString requiere claves gl y es: $json');
    }
    final glStr = json['gl']?.toString().trim() ?? '';
    final esStr = json['es']?.toString().trim() ?? '';
    if (glStr.isEmpty || esStr.isEmpty) {
      throw FormatException('LocalizedString no admite cadenas vacías en gl o es');
    }
    return LocalizedString(gl: glStr, es: esStr);
  }

  Map<String, dynamic> toJson() => {'gl': gl, 'es': es};

  String resolve(String langCode) => langCode.toLowerCase() == 'gl' ? gl : es;
}
```

### 3.2. Jerarquía de Modelos para Unidades Temáticas («Juega con Lúa»)
Archivos en: `assets/content/unidades/*.json`

```
Unidad
├── id: String (ej. "juega.mar.01")
├── tramoEtario: String ("0-2" | "2-3" | "0-3")
├── orden: int
├── titulo: LocalizedString
├── subtitulo: LocalizedString
├── descripcion: LocalizedString
├── portadaAsset: String (ruta relativa local)
├── cancionPulso: CancionPulso
│   ├── titulo: LocalizedString
│   ├── letraConPulsos: LocalizedString (marcas visuales '*')
│   ├── bpm: int (ej. 80)
│   ├── audioAsset: LocalizedString (gl y es)
│   └── consignaDocente: LocalizedString
├── cuento: Cuento
│   ├── titulo: LocalizedString
│   └── paginas: List<CuentoPagina>
│       ├── orden: int
│       ├── texto: LocalizedString
│       ├── imagenAsset: String
│       └── preguntaComprension: LocalizedString
├── vocabulario: List<VocabularioItem>
│   ├── id: String
│   ├── palabra: LocalizedString
│   ├── definicionBreve: LocalizedString
│   ├── imagenAsset: String
│   └── audioAsset: LocalizedString
├── preguntas: List<PreguntasItem>
│   ├── nivel: int (1, 2, 3)
│   ├── enunciado: LocalizedString
│   ├── respuestaSugerida: LocalizedString
│   └── consejoDocente: LocalizedString
├── exploracion: Exploracion
│   ├── titulo: LocalizedString
│   ├── materiales: List<LocalizedString>
│   ├── pasos: List<LocalizedString>
│   ├── avisoSeguridad: LocalizedString (obligatorio)
│   └── objetivoSensorial: LocalizedString
├── matematicas: Matematicas
│   ├── concepto: LocalizedString
│   ├── descripcion: LocalizedString
│   ├── accionesSugeridas: List<LocalizedString>
│   └── vocabularioMatematico: LocalizedString
├── puenteCasa: PuenteCasa
│   ├── mensajeFamilias: LocalizedString
│   ├── actividadesSugeridas: List<LocalizedString>
│   └── recomendacionConversacion: LocalizedString
├── curriculo: CurriculoReferencia
│   ├── normativa: String ("Decreto 150/2022")
│   ├── etapa: String ("educacion_infantil")
│   ├── ciclo: String ("primeiro_ciclo_0_3")
│   ├── areas: List<String>
│   └── criteriosEvaluacion: List<String>
└── revision: Revision
    ├── autor: String
    ├── revisorPedagogico: String
    ├── fechaRevision: String (ISO 8601 YYYY-MM-DD)
    ├── version: String
    └── aprobadoParaAula: bool
```

### 3.3. Jerarquía de Modelos para Cápsulas («Academy»)
Archivos en: `assets/content/capsulas/*.json`

```
Capsula
├── id: String (ej. "academy.como_se_aprende_a_hablar.01")
├── bloqueId: String (ej. "desarrollo_comunicativo")
├── orden: int
├── titulo: LocalizedString
├── subtitulo: LocalizedString
├── tiempoLecturaMinutos: int
├── icono: String (emoji o nombre de icono)
├── ideaClave: LocalizedString        <--- Parte 1
├── porQueImporta: LocalizedString     <--- Parte 2
├── queHacerEnCasa: LocalizedString    <--- Parte 3
├── ejemploCotidiano: LocalizedString  <--- Parte 4
├── afirmaciones: List<Afirmacion>
│   ├── id: String
│   ├── enunciado: LocalizedString
│   ├── esVerdadera: bool
│   └── explicacion: LocalizedString
├── curriculo: CurriculoReferencia
│   ├── normativa: String ("Decreto 150/2022")
│   ├── etapa: String ("educacion_infantil")
│   ├── ciclo: String ("primeiro_ciclo_0_3")
│   ├── areas: List<String>
│   └── criteriosEvaluacion: List<String>
└── revision: Revision
    ├── autor: String
    ├── revisorPedagogico: String
    ├── fechaRevision: String (ISO 8601 YYYY-MM-DD)
    ├── version: String
    └── aprobadoParaAula: bool

Bloque (Catálogo estático de los 5 bloques en lib/data/models/academy/bloque.dart)
├── id: String ("desarrollo_comunicativo", "rutinas_y_bano_de_lenguaje", etc.)
├── orden: int (1..5)
├── titulo: LocalizedString
├── descripcion: LocalizedString
├── icono: String
└── colorHex: String
```

---

## 4. Alineación Curricular con el Decreto 150/2022 de Galicia

El **Decreto 150/2022, do 8 de setembro** (DOG nº 172, do 9 de setembro de 2022) establece la ordenación y el currículo de la Educación Infantil en la Comunidad Autónoma de Galicia. 

Para el **primer ciclo (0 a 3 años)**, la norma articula la experiencia educativa en **3 áreas formativas interconectadas y globalizadas**:

### 4.1. Las 3 Áreas Curriculares Oficiales y su Aplicación a Lúa

| Código de Área | Denominación en Galego (DOG 172) | Denominación en Castellano | Obxectivos y Saberes para 0-3 años | Mapeo en «Descubre con Lúa» |
|---|---|---|---|---|
| **Área 1** | **Crecemento en harmonía** | **Crecimiento en armonía** | Descubrimiento del propio cuerpo, coordinación psicomotriz, apego seguro, expresión emocional, hábitos saludables y bienestar. | `Aviso de seguridad`, `Seguridad afectiva`, `Psicomotricidad`, `Rutinas cotidianas`. |
| **Área 2** | **Descubrimento e exploración da contorna** | **Descubrimiento y exploración del entorno** | Exploración y manipulación sensorial de materiales (textura, agua, temperatura, sonido); curiosidad por el medio físico y natural local (la Ría de Vigo, elementos marinos); inicio del razonamiento lógico-matemático (grande/pequeño, clasificaciones simples). | Sección de `Exploracion` sensorial, sección de `Matematicas` tempranas, temáticas marinas viguesas. |
| **Área 3** | **Comunicación e representación da realidade** | **Comunicación e representación de la realidad** | Comunicación verbal y gestual; comprensión y escucha atenta; prosodia, ritmo y canciones a pulso; aproximación al cuento; convivencia comunicativa y valoración del bilingüismo gallego-castellano. | `CancionPulso`, `Cuento`, `Vocabulario`, `Preguntas graduadas`, `Academy` (baño de lenguaje, turnos). |

### 4.2. Criterios de Evaluación Oficiales para Primer Ciclo (0-3 años)
En las unidades y cápsulas se codifican los siguientes identificadores canónicos para el validador:
- **`CA1.1`**: Mostrar curiosidade e seguridade na exploración motriz e no manexo de obxectos seguros.
- **`CA2.1`**: Explorar materiais e elementos da contorna próxima a través dos sentidos (tacto, vista, oído), recoñecendo cualidades básicas (auga, cunchas, texturas).
- **`CA2.2`**: Iniciarse no razoamento lóxico elemental mediante a agrupación e discriminación perceptual (grande/pequeno, dentro/fóra).
- **`CA3.1`**: Participar con interese en situacións comunicativas e xogos vocais/musicais, escoitando con atención e respondendo a través de xestos, miradas ou palabras.
- **`CA3.2`**: Comprender mensaxes sinxelas e participar na lectura compartida de contos e imaxes da contorna.

---

## 5. Diccionario Terminológico y Reglas Estrictas

### 5.1. Muro Terminológico: Términos Clínicos Prohibidos
Debido a que «Descubre con Lúa» es exclusivamente un recurso pedagógico de aula y familiar para el primer ciclo de educación infantil (0-3 años), **queda terminantemente prohibido** el uso de lenguaje clínico, patologizante, deficitario o diagnóstico.

#### Lista Negra de Términos Prohibidos (Regex de Validación):
```regex
\b(trastorno|trastornos|patolog[ií]a|patolog[ií]as|patol[oó]xic[oa]s?|diagn[oó]stic[oa]s?|diagnosticar|s[ií]ntoma|s[ií]ntomas|sintomatolog[ií]a|sintomatolox[ií]a|d[eé]ficit|d[eé]ficits|paciente|pacientes|terapia|terapias|terap[eé]utic[oa]s?|tratamiento|tratamientos|tratamento|tratamentos|retraso\s+cl[ií]nico|dislalia|dislalias|dislexia|dislexias|hipoacusia\s+cl[ií]nica|afasia|disfasia|rehabilitaci[oó]n|rehabilitar|criba\s+cl[ií]nica|screening|pron[oó]stico)\b
```

#### Tabla de Equivalencias y Sustituciones Obligatorias:

| Término Prohibido | Sustitución Pedagógica en Galego | Sustitución Pedagógica en Castellano |
|---|---|---|
| *Paciente* | neno / nena / crianzas / alumnado / bebé | niño / niña / infancia / alumnado / bebé |
| *Terapia / Terapéutico* | actividade educativa / xogo guiado / estimulación | actividad educativa / juego guiado / estimulación |
| *Trastorno / Patología* | diferenza individual / necesidade de apoio educativo | ritmo propio / necesidad de apoyo educativo |
| *Diagnóstico / Síntoma* | observación educativa / manifestación comunicativa | observación en el aula / expresión comunicativa |
| *Tratamiento / Rehabilitación* | acompañamento pedagóxico / xogo interactivo | acompañamiento educativo / juego interactivo |
| *Retraso clínico / Déficit* | ritmo individual de desenvolvemento / etapa de maduración | ritmo personal de desarrollo / proceso madurativo |
| *Dislalia / Disfasia* | desenvolvemento da linguaxe / emisión de primeiras palabras | desarrollo del lenguaje / primeras palabras |

### 5.2. Estándar de Paridad Bilingüe 1:1 (Gallego RAG / Castellano)
- **Simetría Total**: Cada nodo textual del JSON debe contener exactamente `{ "gl": "...", "es": "..." }`.
- **Calidad Normativa en Galego**: Ortografía y léxico oficial fijado por la Real Academia Galega (RAG).
  - *cuncha* (no *concha*).
  - *gaivota* (no *gaviota*).
  - *mexillón* (no *mejillón*).
  - *peixe* (no *pescado* ni *pez* en gl).
  - *praia de Samil* (no *playa*).
  - *quenda* (no *turno*).
  - *colo* (no *regazo*).
  - *agarimo* (no *cariño* en contextos de vínculo).
  - *neno / nena / crianza* (no *chaval* o *crío*).
- **Prohibición de Cadenas Vacías o Marcadores Temporales**: El validador debe fallar si `gl` o `es` contiene cadenas en blanco, "TODO", "TBD" o "Pendiente".

---

## 6. Contenido JSON Canónico de Referencia

### 6.1. Unidad Marítima de Vigo: `assets/content/unidades/juega.mar.01.json`

```json
{
  "id": "juega.mar.01",
  "tramoEtario": "0-3",
  "orden": 1,
  "titulo": {
    "gl": "Explorando o Mar de Vigo: A nosa Ría",
    "es": "Explorando el Mar de Vigo: Nuestra Ría"
  },
  "subtitulo": {
    "gl": "Unidade de descubrimento sensorial e lingua na contorna mariña viguesa",
    "es": "Unidad de descubrimiento sensorial y lenguaje en el entorno marino vigués"
  },
  "descripcion": {
    "gl": "Proposta de aula para achegar ás crianzas aos sons, animais e texturas da ría de Vigo mediante cancións a pulso, narración interactiva e xogos sensoriais con auga.",
    "es": "Propuesta de aula para acercar a los niños y niñas a los sonidos, animales y texturas de la ría de Vigo mediante canciones a pulso, narración interactiva y juegos sensoriales con agua."
  },
  "portadaAsset": "assets/images/unidades/juega_mar_01_cover.png",
  "cancionPulso": {
    "titulo": {
      "gl": "As ondas da nosa ría",
      "es": "Las olas de nuestra ría"
    },
    "letraConPulsos": {
      "gl": "* On-das * que veñen, * on-das * que van,\n* no mar * de Vi-go * os pei-xes * es-tán.\n* Chof, * chof, * bate * a au-ga,\n* chas, * chas, * sobre * a a-rea.",
      "es": "* O-las * que vienen, * o-las * que van,\n* en el * mar de * Vi-go * los pe-ces * es-tán.\n* Chof, * chof, * cae * el a-gua,\n* chas, * chas, * en la a-re-na."
    },
    "bpm": 80,
    "audioAsset": {
      "gl": "assets/audio/canciones/juega_mar_01_gl.mp3",
      "es": "assets/audio/canciones/juega_mar_01_es.mp3"
    },
    "consignaDocente": {
      "gl": "Marcar o pulso amodo palmeando nas pernas ou movendo os brazos en compás suave coma se fósemos ondas.",
      "es": "Marcar el pulso despacio palmeando en las piernas o balanceando los brazos al ritmo como olas suaves."
    }
  },
  "cuento": {
    "titulo": {
      "gl": "Lúa pasea pola praia de Samil",
      "es": "Lúa pasea por la playa de Samil"
    },
    "paginas": [
      {
        "orden": 1,
        "texto": {
          "gl": "A gata Lúa colle o seu barquiño de madeira e mira a ría de Vigo. A auga brilla baixo o sol e o aire cheira a mar fresco.",
          "es": "La gata Lúa coge su barquito de madera y mira la ría de Vigo. El agua brilla bajo el sol y el aire huele a mar fresco."
        },
        "imagenAsset": "assets/images/cuento/juega_mar_01_p1.png",
        "preguntaComprension": {
          "gl": "Que ten Lúa na man? Mirade como brilla a auga!",
          "es": "¿Qué tiene Lúa en la mano? ¡Mirad cómo brilla el agua!"
        }
      },
      {
        "orden": 2,
        "texto": {
          "gl": "Polo ceo cruza unha gaivota branca que fai: ¡Aaaah, aaah! Na beira da auga hai cunchas grandes e lisas que gardan o son das ondas.",
          "es": "Por el cielo cruza una gaviota blanca que hace: ¡Aaaah, aaah! En la orilla del agua hay conchas grandes y suaves que guardan el sonido de las olas."
        },
        "imagenAsset": "assets/images/cuento/juega_mar_01_p2.png",
        "preguntaComprension": {
          "gl": "Onde está a gaivota? Que son fai cando voa alto?",
          "es": "¿Dónde está la gaviota? ¿Qué sonido hace cuando vuela alto?"
        }
      },
      {
        "orden": 3,
        "texto": {
          "gl": "Lúa atopa unha cuncha fermosa na area de Samil. Achégaa á orella e sorrí con agarimo. O mar de Vigo está cheo de vida!",
          "es": "Lúa encuentra una concha hermosa en la arena de Samil. La acerca a la oreja y sonríe con alegría. ¡El mar de Vigo está lleno de vida!"
        },
        "imagenAsset": "assets/images/cuento/juega_mar_01_p3.png",
        "preguntaComprension": {
          "gl": "A quen saúda Lúa antes de marchar para a casa?",
          "es": "¿A quién saluda Lúa antes de volver a casa?"
        }
      }
    ]
  },
  "vocabulario": [
    {
      "id": "barco",
      "palabra": {
        "gl": "Barco",
        "es": "Barco"
      },
      "definicionBreve": {
        "gl": "Embarcación que navega polas augas da nosa ría.",
        "es": "Embarcación que navega por las aguas de nuestra ría."
      },
      "imagenAsset": "assets/images/vocabulario/barco.png",
      "audioAsset": {
        "gl": "assets/audio/vocabulario/barco_gl.mp3",
        "es": "assets/audio/vocabulario/barco_es.mp3"
      }
    },
    {
      "id": "gaivota",
      "palabra": {
        "gl": "Gaivota",
        "es": "Gaviota"
      },
      "definicionBreve": {
        "gl": "Ave mariña de cor branca que voa preto da costa de Vigo.",
        "es": "Ave marina blanca que vuela cerca de la costa de Vigo."
      },
      "imagenAsset": "assets/images/vocabulario/gaivota.png",
      "audioAsset": {
        "gl": "assets/audio/vocabulario/gaivota_gl.mp3",
        "es": "assets/audio/vocabulario/gaivota_es.mp3"
      }
    },
    {
      "id": "cuncha",
      "palabra": {
        "gl": "Cuncha",
        "es": "Concha"
      },
      "definicionBreve": {
        "gl": "Pesa dura e redondeada que deixan os moluscos no areal.",
        "es": "Pieza dura y redondeada que dejan los moluscos en el arenal."
      },
      "imagenAsset": "assets/images/vocabulario/cuncha.png",
      "audioAsset": {
        "gl": "assets/audio/vocabulario/cuncha_gl.mp3",
        "es": "assets/audio/vocabulario/cuncha_es.mp3"
      }
    },
    {
      "id": "mexillon",
      "palabra": {
        "gl": "Mexillón",
        "es": "Mejillón"
      },
      "definicionBreve": {
        "gl": "Molusco escuro que medra nas bateas da ría de Vigo.",
        "es": "Molusco oscuro que crece en las bateas de la ría de Vigo."
      },
      "imagenAsset": "assets/images/vocabulario/mexillon.png",
      "audioAsset": {
        "gl": "assets/audio/vocabulario/mexillon_gl.mp3",
        "es": "assets/audio/vocabulario/mexillon_es.mp3"
      }
    },
    {
      "id": "peixe",
      "palabra": {
        "gl": "Peixe",
        "es": "Pez"
      },
      "definicionBreve": {
        "gl": "Animal que nada na auga e move a súa cola con rapidez.",
        "es": "Animal que nada en el agua y mueve su cola con rapidez."
      },
      "imagenAsset": "assets/images/vocabulario/peixe.png",
      "audioAsset": {
        "gl": "assets/audio/vocabulario/peixe_gl.mp3",
        "es": "assets/audio/vocabulario/peixe_es.mp3"
      }
    }
  ],
  "preguntas": [
    {
      "nivel": 1,
      "enunciado": {
        "gl": "Onde está o barco grande que navega no mar?",
        "es": "¿Dónde está el barco grande que navega en el mar?"
      },
      "respuestaSugerida": {
        "gl": "Sinalar co dedo a imaxe do barco ou coller o xoguete.",
        "es": "Señalar con el dedo la imagen del barco o coger el juguete."
      },
      "consejoDocente": {
        "gl": "Dar tempo para que a nena ou o neno explore a lámina antes de pedir o sinalamento.",
        "es": "Dar tiempo a que la niña o el niño explore la lámina antes de pedir el señalamiento."
      }
    },
    {
      "nivel": 2,
      "enunciado": {
        "gl": "Que animal voa polo ceo e fai son de gaivota?",
        "es": "¿Qué animal vuela por el cielo y hace sonido de gaviota?"
      },
      "respuestaSugerida": {
        "gl": "Pronunciar 'gaivota' ou imitar o seu son e voo.",
        "es": "Pronunciar 'gaviota' o imitar su sonido y vuelo."
      },
      "consejoDocente": {
        "gl": "Celebrar calquera aproximación vocal ou xesto de abrir as mans coma ás.",
        "es": "Celebrar cualquier aproximación vocal o gesto de abrir los brazos como alas."
      }
    },
    {
      "nivel": 3,
      "enunciado": {
        "gl": "Que pasa cando metemos a cuncha dentro da auga morna?",
        "es": "¿Qué pasa cuando metemos la concha dentro del agua tibia?"
      },
      "respuestaSugerida": {
        "gl": "Moléstase, brilla, faise máis escura ou cae ata o fondo.",
        "es": "Se moja, brilla, se vuelve oscura o cae hasta el fondo."
      },
      "consejoDocente": {
        "gl": "Aproveitar para vincular a palabra coa sensación térmica e táctil.",
        "es": "Aprovechar para vincular la palabra con la sensación térmica y táctil."
      }
    }
  ],
  "exploracion": {
    "titulo": {
      "gl": "Auga morna, cunchas suaves e esponxas de mar",
      "es": "Agua tibia, conchas suaves y esponjas de mar"
    },
    "materiales": [
      {
        "gl": "Unha batea ou bandexa ampla de plástico transparente con cantos redondeados.",
        "es": "Una batea o bandeja amplia de plástico transparente con esquinas redondeadas."
      },
      {
        "gl": "Auga morna a temperatura corporal (36-37 °C).",
        "es": "Agua tibia a temperatura corporal (36-37 °C)."
      },
      {
        "gl": "Cunchas grandes de vieira ou ameixón limpas e sen fíos (tamaño mínimo 6 cm).",
        "es": "Conchas grandes de vieira o almejón limpias y sin bordes afilados (tamaño mínimo 6 cm)."
      },
      {
        "gl": "Esponxas vexetais suaves e anacos de tea azul para simular ondas.",
        "es": "Esponjas vegetales suaves y trozos de tela azul para simular olas."
      }
    ],
    "pasos": [
      {
        "gl": "Acomodar ás crianzas en círculo seguro arredor da bandexa de auga.",
        "es": "Acomodar a los niños y niñas en círculo seguro alrededor de la bandeja de agua."
      },
      {
        "gl": "Ofrecer primeiro unha cuncha seca para acariciar a súa superficie estriada.",
        "es": "Ofrecer primero una concha seca para acariciar su superficie con relieve."
      },
      {
        "gl": "Somerxer a cuncha na auga morna xuntos e observar como cambia a súa cor.",
        "es": "Sumergir la concha en el agua tibia juntos y observar cómo cambia su color."
      },
      {
        "gl": "Apertar a esponxa mollada producindo pingas de auga e son de choiva suave.",
        "es": "Apretar la esponja mojada produciendo gotas de agua y sonido de lluvia suave."
      }
    ],
    "avisoSeguridad": {
      "gl": "Aviso de seguridade obrigatorio: Esta actividade require presenza e supervisión docente constante. Asegúrese de que todas as cunchas superen os 5 cm de diámetro e non presenten bordos cortantes nin estelas para evitar calquera risco de atragoamento.",
      "es": "Aviso de seguridad obligatorio: Esta actividad requiere presencia y supervisión docente constante. Asegúrese de que todas las conchas superen los 5 cm de diámetro y carezcan de bordes cortantes o astillas para evitar cualquier riesgo de atragantamiento."
    },
    "objetivoSensorial": {
      "gl": "Estimular o tacto, a propiocepción e a diferenza entre seco e mollado.",
      "es": "Estimular el tacto, la propiocepción y la diferencia entre seco y mojado."
    }
  },
  "matematicas": {
    "concepto": {
      "gl": "Discriminación de tamaño: Grande e pequeno na ría",
      "es": "Discriminación de tamaño: Grande y pequeño en la ría"
    },
    "descripcion": {
      "gl": "Introdución visual e manipulativa ás nocións de magnitude mediante barcos e cunchas.",
      "es": "Introducción visual y manipulativa a las nociones de magnitud mediante barcos y conchas."
    },
    "accionesSugeridas": [
      {
        "gl": "Colocar un barco grande e un barquiño pequeno diante da crianza.",
        "es": "Colocar un barco grande y un barquito pequeño delante del niño o la niña."
      },
      {
        "gl": "Preguntar: 'Cal é o barco grande coma o de Vigo?' e acompañar co xesto dos brazos abertos.",
        "es": "Preguntar: '¿Cuál es el barco grande como el de Vigo?' y acompañar con el gesto de brazos abiertos."
      }
    ],
    "vocabularioMatematico": {
      "gl": "Grande / Pequeno, Moito / Pouco, Dentro / Fóra",
      "es": "Grande / Pequeño, Mucho / Poco, Dentro / Fuera"
    }
  },
  "puenteCasa": {
    "mensajeFamilias": {
      "gl": "Hoxe no aula navegamos polo mar de Vigo coa gata Lúa! Aprendemos a cantar as ondas e descubrimos cunchas e barcos.",
      "es": "¡Hoy en el aula navegamos por el mar de Vigo con la gata Lúa! Aprendimos a cantar las olas y descubrimos conchas y barcos."
    },
    "actividadesSugeridas": [
      {
        "gl": "Na hora do baño na casa, xogar con vasos de plástico a encher e baleirar auga cantando a canción das ondas.",
        "es": "En la hora del baño en casa, jugar con vasos de plástico a llenar y vaciar agua cantando la canción de las olas."
      },
      {
        "gl": "Nun paseo pola praia ou polo porto de Bouzas ou Samil, sinalar as gaivotas que descansan nas rochas.",
        "es": "En un paseo por la playa o por el puerto de Bouzas o Samil, señalar las gaviotas que descansan en las rocas."
      }
    ],
    "recomendacionConversacion": {
      "gl": "Non esixir repetición forzada: nomear os obxectos con entusiasmo e esperar cinco segundos con mirada agarimosa.",
      "es": "No exigir repetición forzada: nombrar los objetos con entusiasmo y esperar cinco segundos con mirada afectuosa."
    }
  },
  "curriculo": {
    "normativa": "Decreto 150/2022",
    "etapa": "educacion_infantil",
    "ciclo": "primeiro_ciclo_0_3",
    "areas": [
      "area_2_descubrimento_contorna",
      "area_3_comunicacion_representacion"
    ],
    "criteriosEvaluacion": [
      "CA2.1",
      "CA2.2",
      "CA3.1",
      "CA3.2"
    ]
  },
  "revision": {
    "autor": "Equipo Pedagóxico Descubre con Lúa",
    "revisorPedagogico": "Especialista en Educación Infantil 0-3 Galicia",
    "fechaRevision": "2026-09-11",
    "version": "1.0.0",
    "aprobadoParaAula": true
  }
}
```

---

### 6.2. Cápsula de Academy: `assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json`

```json
{
  "id": "academy.como_se_aprende_a_hablar.01",
  "bloqueId": "desarrollo_comunicativo",
  "orden": 1,
  "titulo": {
    "gl": "Como se aprende a falar: o baño de lingua e as primeiras quendas",
    "es": "Cómo se aprende a hablar: el baño de lenguaje y los primeros turnos"
  },
  "subtitulo": {
    "gl": "A importancia de escoitar con calma e interactuar antes das primeiras palabras",
    "es": "La importancia de escuchar con calma e interactuar antes de las primeras palabras"
  },
  "tiempoLecturaMinutos": 3,
  "icono": "ear_sparkles",
  "ideaClave": {
    "gl": "A fala comeza moito antes da primeira palabra. O cerebro infantil constrúe a linguaxe a partir das conversas cálidas, miradas compartidas e palabras agarimosas que escoita acotío na súa familia.",
    "es": "El habla comienza mucho antes de la primera palabra. El cerebro infantil construye el lenguaje a partir de las conversaciones cálidas, miradas compartidas y palabras afectuosas que escucha a diario en su familia."
  },
  "porQueImporta": {
    "gl": "O cerebro do bebé precisa escoitar miles de repeticións significativas nun clima afectivo seguro. Cando respondemos aos seus balbuceos e xestos coma se fosen palabras reais, fortalecemos os circuítos neurais da comunicación social.",
    "es": "El cerebro del bebé necesita escuchar miles de repeticiones significativas en un clima afectivo seguro. Cuando respondemos a sus balbuceos y gestos como si fuesen palabras reales, fortalecemos los circuitos neuronales de la comunicación social."
  },
  "queHacerEnCasa": {
    "gl": "Nomea en voz alta o que o teu bebé está a mirar neste intre. Despois de facerlle unha pregunta ou dicir unha palabra, garda un silencio atento de 5 segundos para concederlle a súa quenda de resposta.",
    "es": "Nombra en voz alta lo que tu bebé está mirando en este instante. Después de hacerle una pregunta o decir una palabra, guarda un silencio atento de 5 segundos para concederle su turno de respuesta."
  },
  "ejemploCotidiano": {
    "gl": "No intre de poñer os zapatos pola mañá: «Mira, aquí está o teu zapato azul! Onde vai? No pé! Primeiro un pé... (pausa de 5 segundos con sorriso)... e agora o outro pé! Que cóxegas nos dedas!»",
    "es": "En el momento de poner los zapatos por la mañana: «¡Mira, aquí está tu zapato azul! ¿Dónde va? ¡En el pie! Primero un pie... (pausa de 5 segundos con sonrisa)... ¡y ahora el otro pie! ¡Qué cosquillas en los dedos!»"
  },
  "afirmaciones": [
    {
      "id": "afirmacion_01",
      "enunciado": {
        "gl": "Esperar en silencio durante uns segundos despois de falar axuda a que o neno tome a iniciativa comunicativa.",
        "es": "Esperar en silencio durante unos segundos después de hablar ayuda a que el niño tome la iniciativa comunicativa."
      },
      "esVerdadera": true,
      "explicacion": {
        "gl": "Exacto: a pausa atenta é a invitación máis respectuosa para que a crianza intente comunicarse cos seus propios recursos.",
        "es": "Exacto: la pausa atenta es la invitación más respetuosa para que el niño intente comunicarse con sus propios recursos."
      }
    },
    {
      "id": "afirmacion_02",
      "enunciado": {
        "gl": "É necesario esixir que o bebé repita as palabras correctamente cada vez que as pronuncia mal.",
        "es": "Es necesario exigir que el bebé repita las palabras correctamente cada vez que las pronuncia mal."
      },
      "esVerdadera": false,
      "explicacion": {
        "gl": "Non é conveniente: nos primeiros 3 anos, o mellor modelo é repetir nós a palabra de xeito natural e agarimoso dentro da conversa, sen correccións forzadas.",
        "es": "No es conveniente: en los primeros 3 años, el mejor modelo es repetir nosotros la palabra de forma natural y afectuosa dentro de la conversación, sin correcciones forzadas."
      }
    }
  ],
  "curriculo": {
    "normativa": "Decreto 150/2022",
    "etapa": "educacion_infantil",
    "ciclo": "primeiro_ciclo_0_3",
    "areas": [
      "area_1_crecemento_harmonia",
      "area_3_comunicacion_representacion"
    ],
    "criteriosEvaluacion": [
      "CA1.1",
      "CA3.1"
    ]
  },
  "revision": {
    "autor": "Equipo Pedagóxico Descubre con Lúa",
    "revisorPedagogico": "Especialista en Desenvolvemento Infantil e Familia",
    "fechaRevision": "2026-09-11",
    "version": "1.0.0",
    "aprobadoParaAula": true
  }
}
```

---

## 7. Especificación de la Suite de Validación Automatizada (`test/data/`)

El comando `flutter test test/data/` ejecutará una batería exhaustiva de pruebas unitarias sobre los datos base del proyecto. Cualquier fallo impedirá el paso al ciclo de construcción o empaquetado.

### 7.1. Estructura de la Suite en `test/data/`
- `test/data/content_loader_test.dart`: Carga de recursos JSON desde el sistema de ficheros de assets en entorno de test.
- `test/data/schema_validation_test.dart`: Parsing y deserialización estricta hacia modelos Dart (`Unidad` y `Capsula`).
- `test/data/bilingual_parity_test.dart`: Inspección recursiva de paridad 1:1 en todos los campos `LocalizedString`.
- `test/data/referential_integrity_test.dart`: Comprobación de que las rutas relativas de audio e imágenes son canónicas y consistentes.
- `test/data/curricular_alignment_test.dart`: Certificación de citas al Decreto 150/2022, etapa 0-3 y áreas válidas.
- `test/data/clinical_terms_blocker_test.dart`: Linter terminológico que escanea cada string contra la lista negra clínica.

### 7.2. Lógica y Aserciones de cada Validador

```dart
// Ejemplo de implementación conceptual del Bloqueador Clínico en test/data/clinical_terms_blocker_test.dart
final forbiddenClinicalPattern = RegExp(
  r'\b(trastorno|trastornos|patolog[ií]a|patolog[ií]as|patol[oó]xic[oa]s?|'
  r'diagn[oó]stic[oa]s?|diagnosticar|s[ií]ntoma|s[ií]ntomas|sintomatolog[ií]a|'
  r'sintomatolox[ií]a|d[eé]ficit|d[eé]ficits|paciente|pacientes|terapia|'
  r'terapias|terap[eé]utic[oa]s?|tratamiento|tratamientos|tratamento|tratamentos|'
  r'retraso\s+cl[ií]nico|dislalia|dislalias|dislexia|dislexias|'
  r'hipoacusia\s+cl[ií]nica|afasia|disfasia|rehabilitaci[oó]n|rehabilitar|'
  r'criba\s+cl[ií]nica|screening|pron[oó]stico)\b',
  caseSensitive: false,
);

void assertZeroClinicalTerms(Map<String, dynamic> json, String filePath) {
  void inspectNode(dynamic node, String path) {
    if (node is String) {
      final match = forbiddenClinicalPattern.firstMatch(node);
      expect(
        match,
        isNull,
        reason: 'Término clínico prohibido encontrado ("${match?.group(0)}") en $filePath en el nodo: $path',
      );
    } else if (node is Map) {
      node.forEach((k, v) => inspectNode(v, '$path.$k'));
    } else if (node is List) {
      for (var i = 0; i < node.length; i++) {
        inspectNode(node[i], '$path[$i]');
      }
    }
  }
  inspectNode(json, 'root');
}
```

---

## Features Discovered
| # | Category | Feature | Description | Inputs | Outputs | Error Behavior | Discovered Via |
|---|----------|---------|-------------|--------|---------|----------------|----------------|
| 1 | R1 Arquitectura | Privacidad Estricta en Binario | Exclusión de `android.permission.INTERNET` del AndroidManifest.xml release y cero clientes de red en pubspec | AndroidManifest.xml y pubspec.yaml | Binario Android 100% offline y seguro | Build audit falla si detecta permiso de red | ORIGINAL_REQUEST.md R1 |
| 2 | R2 Content-Data | Modelo `Unidad` | Entidad raíz para unidades didácticas de aula con metadatos y secciones pedagógicas | JSON en `assets/content/unidades/*.json` | Objeto `Unidad` Dart inmutable | `FormatException` si faltan campos obligatorios | ORIGINAL_REQUEST.md R2 |
| 3 | R2 Content-Data | Modelo `Vocabulario` | Catálogo de léxico con palabra gl/es, audio local gl/es e imagen | Nodo `vocabulario` de la unidad | Lista de `VocabularioItem` | Falla si no cumple 1:1 o falta audio | ORIGINAL_REQUEST.md R2 |
| 4 | R2 Content-Data | Modelo `Actividad` / Modo Asamblea | Secuencia pedagógica para asamblea guiada docente | Nodo de actividades o fases | Pasos secuenciales de facilitación | Falla si orden o estructura es incorrecta | ORIGINAL_REQUEST.md R2 & R3 |
| 5 | R2 Content-Data | Modelo `Preguntas` | Banco de preguntas graduadas en 3 niveles de andamiaje | Nodo `preguntas` con niveles 1, 2 y 3 | Lista de `PreguntasItem` | Falla si falta algún nivel del 1 al 3 | ORIGINAL_REQUEST.md R2 & R3 |
| 6 | R2 Content-Data | Modelo `Exploracion` | Actividad sensorial física manipulativa con aviso de seguridad | Materiales, pasos, aviso de seguridad | Objeto `Exploracion` Dart | Falla si `avisoSeguridad` está ausente o vacío | ORIGINAL_REQUEST.md R2 & R3 |
| 7 | R2 Content-Data | Modelo `Matematicas` | Actividad de matemáticas tempranas para 0-3 años | Concepto, descripción, vocabulario | Objeto `Matematicas` Dart | Falla si falta concepto o acciones | ORIGINAL_REQUEST.md R2 & R3 |
| 8 | R2 Content-Data | Modelo `PuenteCasa` | Recomendación y actividades para comunicar a las familias | Mensaje y actividades sugeridas | Objeto `PuenteCasa` Dart | Falla si no hay paridad bilingüe | ORIGINAL_REQUEST.md R2 & R3 |
| 9 | R2 Content-Data | Modelo `Revision` | Trazabilidad de autoría y aprobación pedagógica | Autor, revisor, fecha, versión | Objeto `Revision` Dart | Falla si falta fecha ISO o aprobadoParaAula | ORIGINAL_REQUEST.md R2 |
| 10 | R2 Content-Data | Modelo `Capsula` (Academy) | Cápsula formativa para familias estructurada en 4 partes | JSON en `assets/content/capsulas/*.json` | Objeto `Capsula` Dart | Falla si falta alguna de las 4 partes canónicas | ORIGINAL_REQUEST.md R2 & R3 |
| 11 | R2 Content-Data | Modelo `Bloque` (Academy) | Agrupación temática en 5 bloques del desarrollo infantil | `bloqueId` y catálogo estático | Objeto `Bloque` Dart | Falla si el ID de bloque es ajeno a los 5 oficiales | ORIGINAL_REQUEST.md R2 & R3 |
| 12 | R2 Content-Data | Modelo `Afirmacion` | Micro-preguntas reflexivas formativas (verdadero/falso) | Nodo `afirmaciones` | Lista de `Afirmacion` | Falla si falta la explicación pedagógica | ORIGINAL_REQUEST.md R2 & R3 |
| 13 | R2 Content-Data | Canción a Pulso con Audio Offline | Reproducción de audio local con apoyo visual de marcas rítmicas | Archivo de audio local y letra marcada | Audio continuo + pulsos en pantalla | Falla si el asset de audio no existe | ORIGINAL_REQUEST.md R3 |
| 14 | Curricular | Referencia Curricular Decreto 150/2022 | Vinculación explícita con áreas y criterios oficiales de Galicia 0-3 | Objeto `curriculo` en cada JSON | Metadatos curriculares validados | Test falla si no referencia Decreto 150/2022 | ORIGINAL_REQUEST.md R2 |
| 15 | Lingüística | Conmutador Dinámico de Lengua | Cambio de idioma en tiempo de ejecución entre `gl` y `es` | Interacción de usuario con selector | Cambio instantáneo de strings y audio | Fallback tipado seguro | ORIGINAL_REQUEST.md R3 |
| 16 | Validación | Linter de Bloqueo de Términos Clínicos | Filtro automatizado contra patologización y vocabulario médico | Cadenas de texto de los JSONs | Pasa o emite error de aserción | Falla el test unitario con el término exacto | ORIGINAL_REQUEST.md R2 |
| 17 | Validación | Validador de Paridad Bilingüe 1:1 | Inspección simétrica de claves y contenidos no vacíos en gl y es | Todos los objetos `LocalizedString` | Pasa si ambas lenguas son completas | Falla si falta alguna lengua o es vacía | ORIGINAL_REQUEST.md R2 |

---

## Edge Cases
| # | Feature | Input | Observed Behavior / Mitigación Requerida |
|---|---------|-------|------------------------------------------|
| 1 | Paridad Bilingüe | Cadena en gallego válida y cadena en castellano con espacios en blanco `"   "` | El constructor de `LocalizedString` detecta cadena vacía tras `.trim()` y lanza `FormatException`. |
| 2 | Linter Clínico | Uso inadvertido de palabras derivadas como "diagnóstico", "patologías" o "terapéutico" | Expresión regular con comodines y límites de palabra `\b` detecta todas las formas flexivas y falla el test con ruta JSON exacta. |
| 3 | Audio Local Offline | Dispositivo sin conexión ejecutando `CancionPulso` o `Vocabulario` | El reproductor lee exclusivamente de `AssetSource('assets/audio/...')`, garantizando sonido 100% offline sin búfer de red ni dependencias web. |
| 4 | Cambio de Lengua en Reproducción | Usuario cambia de `gl` a `es` mientras se reproduce la canción en gallego | El reproductor detiene el audio previo, recarga el asset correspondiente al nuevo idioma y actualiza la letra sincronizada. |
| 5 | Filtro de Edad | Unidad configurada para tramo `"0-3"` frente a filtros de pestaña `"0-2"` y `"2-3"` | La unidad con tramo `"0-3"` debe ser visible en ambas pestañas o clasificarse en sub-actividades graduadas. |
| 6 | Integridad Curricular | JSON con área inexistente como `"area_4"` o normativa estatal sin adaptación gallega | El test `curricular_alignment_test.dart` restringe áreas a `area_1_crecemento_harmonia`, `area_2_descubrimento_contorna`, `area_3_comunicacion_representacion` bajo `Decreto 150/2022`. |
| 7 | Seguridad en Exploración | Unidad didáctica sin el campo `avisoSeguridad` en el objeto `exploracion` | El test unitario rechaza el JSON; en la interfaz docente, la pantalla de exploración no se activa sin mostrar previamente la tarjeta destacada de seguridad. |
