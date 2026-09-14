import 'package:flutter/foundation.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/localized_string.dart';
import 'curricular_model.dart';

/// Revision and pedagogical certification metadata.
@immutable
class Revision {
  final String autor;
  final String revisorPedagogico;
  final String fechaRevision;
  final String version;
  final bool aprobadoParaAula;

  const Revision({
    required this.autor,
    required this.revisorPedagogico,
    required this.fechaRevision,
    required this.version,
    required this.aprobadoParaAula,
  });

  factory Revision.fromJson(Map<String, dynamic> json) {
    return Revision(
      autor: json['autor']?.toString().trim() ?? '',
      revisorPedagogico: json['revisorPedagogico']?.toString().trim() ??
          json['revisor_pedagogico']?.toString().trim() ??
          '',
      fechaRevision: json['fechaRevision']?.toString().trim() ??
          json['fecha_revision']?.toString().trim() ??
          '',
      version: json['version']?.toString().trim() ?? '1.0.0',
      aprobadoParaAula: json['aprobadoParaAula'] as bool? ??
          json['aprobado_para_aula'] as bool? ??
          false,
    );
  }

  Map<String, dynamic> toJson() => {
        'autor': autor,
        'revisorPedagogico': revisorPedagogico,
        'fechaRevision': fechaRevision,
        'version': version,
        'aprobadoParaAula': aprobadoParaAula,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Revision &&
          runtimeType == other.runtimeType &&
          autor == other.autor &&
          revisorPedagogico == other.revisorPedagogico &&
          fechaRevision == other.fechaRevision &&
          version == other.version &&
          aprobadoParaAula == other.aprobadoParaAula;

  @override
  int get hashCode => Object.hash(
        autor,
        revisorPedagogico,
        fechaRevision,
        version,
        aprobadoParaAula,
      );

  @override
  String toString() =>
      'Revision(v$version, $fechaRevision, approved: $aprobadoParaAula)';
}

/// Song with rhythm pulse markings for assembly step 1.
@immutable
class CancionPulso {
  final LocalizedString titulo;
  final LocalizedString letraConPulsos;
  final int bpm;
  final LocalizedString audioAsset;
  final LocalizedString consignaDocente;

  const CancionPulso({
    required this.titulo,
    required this.letraConPulsos,
    required this.bpm,
    required this.audioAsset,
    required this.consignaDocente,
  });

  factory CancionPulso.fromJson(Map<String, dynamic> json) {
    final rawAudio = json['audioAsset'] ?? json['audio_asset'];
    final LocalizedString resolvedAudio;
    if (rawAudio is Map<String, dynamic>) {
      resolvedAudio = LocalizedString.fromJson(rawAudio);
    } else if (rawAudio is String) {
      resolvedAudio = LocalizedString(gl: rawAudio, es: rawAudio);
    } else {
      resolvedAudio = const LocalizedString(gl: '', es: '');
    }

    return CancionPulso(
      titulo: LocalizedString.fromJson(
          json['titulo'] as Map<String, dynamic>? ?? {}),
      letraConPulsos: LocalizedString.fromJson(
        (json['letraConPulsos'] ?? json['letra_con_pulsos'])
                as Map<String, dynamic>? ??
            {},
      ),
      bpm: (json['bpm'] as num?)?.toInt() ?? 72,
      audioAsset: resolvedAudio,
      consignaDocente: LocalizedString.fromJson(
        (json['consignaDocente'] ?? json['consigna_docente'])
                as Map<String, dynamic>? ??
            {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'titulo': titulo.toJson(),
        'letraConPulsos': letraConPulsos.toJson(),
        'bpm': bpm,
        'audioAsset': audioAsset.toJson(),
        'consignaDocente': consignaDocente.toJson(),
      };

  /// Resolves audio path according to active language.
  String resolveAudio(AppLanguage lang) => audioAsset.resolve(lang);

  /// The song's lines, as written, one per verse.
  List<String> versos(AppLanguage lang) => letraConPulsos
      .resolve(lang)
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  /// Beats in a bar, read from the `*` markers in the lyrics.
  ///
  /// The markers are the beats, so the pulse is not configured separately and
  /// cannot disagree with the words the teacher is reading.
  /// tools/check_pulse_markers.py enforces that every line carries the same
  /// number of them, in both languages.
  int beatsPerLine(AppLanguage lang) {
    for (final verso in versos(lang)) {
      final beats = '*'.allMatches(verso).length;
      if (beats > 0) return beats;
    }
    return 4;
  }

  /// Beats between strong beats: the downbeat of every bar.
  int accentEvery(AppLanguage lang) => beatsPerLine(lang);

  /// How long one beat lasts at this tempo.
  Duration get beatDuration =>
      Duration(microseconds: (60000000 / (bpm <= 0 ? 72 : bpm)).round());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CancionPulso &&
          runtimeType == other.runtimeType &&
          titulo == other.titulo &&
          letraConPulsos == other.letraConPulsos &&
          bpm == other.bpm &&
          audioAsset == other.audioAsset &&
          consignaDocente == other.consignaDocente;

  @override
  int get hashCode => Object.hash(
        titulo,
        letraConPulsos,
        bpm,
        audioAsset,
        consignaDocente,
      );
}

/// A page in the illustrated short story for step 2.
@immutable
class CuentoPagina {
  final int orden;
  final LocalizedString texto;
  final String imagenAsset;
  final LocalizedString preguntaComprension;

  /// Lo que la persona adulta DICE en inglés mientras lee esta página.
  ///
  /// El inglés estaba solo en `ingles.porFase`, que da tres palabras para todo
  /// el cuento: la docente no sabía en qué página decir cuál. Aquí va pegado a
  /// la página que se tiene delante.
  final List<String> ingles;

  const CuentoPagina({
    required this.orden,
    required this.texto,
    required this.imagenAsset,
    required this.preguntaComprension,
    this.ingles = const [],
  });

  factory CuentoPagina.fromJson(Map<String, dynamic> json) {
    return CuentoPagina(
      orden: (json['orden'] as num?)?.toInt() ?? 1,
      texto: LocalizedString.fromJson(
          json['texto'] as Map<String, dynamic>? ?? {}),
      imagenAsset: json['imagenAsset']?.toString().trim() ??
          json['imagen_asset']?.toString().trim() ??
          '',
      preguntaComprension: LocalizedString.fromJson(
        (json['preguntaComprension'] ?? json['pregunta_comprension'])
                as Map<String, dynamic>? ??
            {},
      ),
      ingles: List.unmodifiable(
        (json['ingles'] as List? ?? const [])
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'orden': orden,
        'texto': texto.toJson(),
        'imagenAsset': imagenAsset,
        'preguntaComprension': preguntaComprension.toJson(),
        'ingles': ingles,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CuentoPagina &&
          runtimeType == other.runtimeType &&
          orden == other.orden &&
          texto == other.texto &&
          imagenAsset == other.imagenAsset &&
          preguntaComprension == other.preguntaComprension;

  @override
  int get hashCode =>
      Object.hash(orden, texto, imagenAsset, preguntaComprension);
}

/// Story section for step 2.
@immutable
class Cuento {
  final LocalizedString titulo;
  final List<CuentoPagina> paginas;

  const Cuento({
    required this.titulo,
    required this.paginas,
  });

  factory Cuento.fromJson(Map<String, dynamic> json) {
    final rawPages = json['paginas'];
    final List<CuentoPagina> pages;
    if (rawPages is List) {
      pages = rawPages
          .whereType<Map<String, dynamic>>()
          .map((p) => CuentoPagina.fromJson(p))
          .toList();
    } else {
      pages = const [];
    }

    return Cuento(
      titulo: LocalizedString.fromJson(
          json['titulo'] as Map<String, dynamic>? ?? {}),
      paginas: List.unmodifiable(pages),
    );
  }

  Map<String, dynamic> toJson() => {
        'titulo': titulo.toJson(),
        'paginas': paginas.map((p) => p.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cuento &&
          runtimeType == other.runtimeType &&
          titulo == other.titulo &&
          listEquals(paginas, other.paginas);

  @override
  int get hashCode => Object.hash(titulo, Object.hashAll(paginas));
}

/// Galician/Spanish vocabulary flashcard item with audio and image.
@immutable
class VocabularioItem {
  final String id;
  final LocalizedString palabra;
  final LocalizedString definicionBreve;
  final String imagenAsset;
  final LocalizedString audioAsset;

  /// La misma palabra en inglés. Vacía mientras no esté escrita: la tarjeta
  /// enseña entonces solo galego y castelán, sin prometer un audio que no hay.
  final String ingles;

  const VocabularioItem({
    required this.id,
    required this.palabra,
    required this.definicionBreve,
    required this.imagenAsset,
    required this.audioAsset,
    this.ingles = '',
  });

  factory VocabularioItem.fromJson(Map<String, dynamic> json) {
    final rawAudio = json['audioAsset'] ?? json['audio_asset'];
    final LocalizedString resolvedAudio;
    if (rawAudio is Map<String, dynamic>) {
      resolvedAudio = LocalizedString.fromJson(rawAudio);
    } else if (rawAudio is String) {
      resolvedAudio = LocalizedString(gl: rawAudio, es: rawAudio);
    } else {
      resolvedAudio = const LocalizedString(gl: '', es: '');
    }

    return VocabularioItem(
      id: json['id']?.toString().trim() ?? '',
      palabra: LocalizedString.fromJson(
          json['palabra'] as Map<String, dynamic>? ?? {}),
      definicionBreve: LocalizedString.fromJson(
        (json['definicionBreve'] ?? json['definicion_breve'])
                as Map<String, dynamic>? ??
            {},
      ),
      imagenAsset: json['imagenAsset']?.toString().trim() ??
          json['imagen_asset']?.toString().trim() ??
          '',
      audioAsset: resolvedAudio,
      ingles: json['ingles']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'palabra': palabra.toJson(),
        'definicionBreve': definicionBreve.toJson(),
        'imagenAsset': imagenAsset,
        'audioAsset': audioAsset.toJson(),
        'ingles': ingles,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabularioItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          palabra == other.palabra &&
          definicionBreve == other.definicionBreve &&
          imagenAsset == other.imagenAsset &&
          audioAsset == other.audioAsset;

  @override
  int get hashCode => Object.hash(
        id,
        palabra,
        definicionBreve,
        imagenAsset,
        audioAsset,
      );
}

/// Graduated scaffolding question for assembly step 3.
/// Level 1: Pointing / visual identification.
/// Level 2: Naming / onomatopoeia.
/// Level 3: Causal link / everyday experience.
@immutable
class PreguntaNivel {
  final int nivel;
  final LocalizedString enunciado;
  final LocalizedString respuestaSugerida;
  final LocalizedString consejoDocente;

  const PreguntaNivel({
    required this.nivel,
    required this.enunciado,
    required this.respuestaSugerida,
    required this.consejoDocente,
  });

  factory PreguntaNivel.fromJson(Map<String, dynamic> json) {
    return PreguntaNivel(
      nivel: (json['nivel'] as num?)?.toInt() ?? 1,
      enunciado: LocalizedString.fromJson(
          json['enunciado'] as Map<String, dynamic>? ?? {}),
      respuestaSugerida: LocalizedString.fromJson(
        (json['respuestaSugerida'] ?? json['respuesta_sugerida'])
                as Map<String, dynamic>? ??
            {},
      ),
      consejoDocente: LocalizedString.fromJson(
        (json['consejoDocente'] ?? json['consejo_docente'])
                as Map<String, dynamic>? ??
            {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'nivel': nivel,
        'enunciado': enunciado.toJson(),
        'respuestaSugerida': respuestaSugerida.toJson(),
        'consejoDocente': consejoDocente.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreguntaNivel &&
          runtimeType == other.runtimeType &&
          nivel == other.nivel &&
          enunciado == other.enunciado &&
          respuestaSugerida == other.respuestaSugerida &&
          consejoDocente == other.consejoDocente;

  @override
  int get hashCode => Object.hash(
        nivel,
        enunciado,
        respuestaSugerida,
        consejoDocente,
      );
}

/// Sensory exploration activity with mandatory classroom safety notice for step 4.
@immutable
class ExploracionSensorial {
  final LocalizedString titulo;
  final List<LocalizedString> materiales;
  final List<LocalizedString> pasos;
  final LocalizedString avisoSeguridad;
  final LocalizedString objetivoSensorial;

  const ExploracionSensorial({
    required this.titulo,
    required this.materiales,
    required this.pasos,
    required this.avisoSeguridad,
    required this.objetivoSensorial,
  });

  factory ExploracionSensorial.fromJson(Map<String, dynamic> json) {
    final rawMat = json['materiales'];
    final List<LocalizedString> mats;
    if (rawMat is List) {
      mats = rawMat
          .whereType<Map<String, dynamic>>()
          .map((m) => LocalizedString.fromJson(m))
          .toList();
    } else {
      mats = const [];
    }

    final rawPasos = json['pasos'];
    final List<LocalizedString> steps;
    if (rawPasos is List) {
      steps = rawPasos
          .whereType<Map<String, dynamic>>()
          .map((s) => LocalizedString.fromJson(s))
          .toList();
    } else {
      steps = const [];
    }

    return ExploracionSensorial(
      titulo: LocalizedString.fromJson(
          json['titulo'] as Map<String, dynamic>? ?? {}),
      materiales: List.unmodifiable(mats),
      pasos: List.unmodifiable(steps),
      avisoSeguridad: LocalizedString.fromJson(
        (json['avisoSeguridad'] ?? json['aviso_seguridad'])
                as Map<String, dynamic>? ??
            {},
      ),
      objetivoSensorial: LocalizedString.fromJson(
        (json['objetivoSensorial'] ?? json['objetivo_sensorial'])
                as Map<String, dynamic>? ??
            {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'titulo': titulo.toJson(),
        'materiales': materiales.map((m) => m.toJson()).toList(),
        'pasos': pasos.map((s) => s.toJson()).toList(),
        'avisoSeguridad': avisoSeguridad.toJson(),
        'objetivoSensorial': objetivoSensorial.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExploracionSensorial &&
          runtimeType == other.runtimeType &&
          titulo == other.titulo &&
          listEquals(materiales, other.materiales) &&
          listEquals(pasos, other.pasos) &&
          avisoSeguridad == other.avisoSeguridad &&
          objetivoSensorial == other.objetivoSensorial;

  @override
  int get hashCode => Object.hash(
        titulo,
        Object.hashAll(materiales),
        Object.hashAll(pasos),
        avisoSeguridad,
        objetivoSensorial,
      );
}

/// Early mathematics activity for 0-3 years for step 5.
@immutable
class MatematicasTempras {
  final LocalizedString concepto;
  final LocalizedString descripcion;
  final List<LocalizedString> accionesSugeridas;
  final LocalizedString vocabularioMatematico;

  const MatematicasTempras({
    required this.concepto,
    required this.descripcion,
    required this.accionesSugeridas,
    required this.vocabularioMatematico,
  });

  factory MatematicasTempras.fromJson(Map<String, dynamic> json) {
    final rawAcciones = json['accionesSugeridas'] ?? json['acciones_sugeridas'];
    final List<LocalizedString> actions;
    if (rawAcciones is List) {
      actions = rawAcciones
          .whereType<Map<String, dynamic>>()
          .map((a) => LocalizedString.fromJson(a))
          .toList();
    } else {
      actions = const [];
    }

    return MatematicasTempras(
      concepto: LocalizedString.fromJson(
          json['concepto'] as Map<String, dynamic>? ?? {}),
      descripcion: LocalizedString.fromJson(
          json['descripcion'] as Map<String, dynamic>? ?? {}),
      accionesSugeridas: List.unmodifiable(actions),
      vocabularioMatematico: LocalizedString.fromJson(
        (json['vocabularioMatematico'] ?? json['vocabulario_matematico'])
                as Map<String, dynamic>? ??
            {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'concepto': concepto.toJson(),
        'descripcion': descripcion.toJson(),
        'accionesSugeridas': accionesSugeridas.map((a) => a.toJson()).toList(),
        'vocabularioMatematico': vocabularioMatematico.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatematicasTempras &&
          runtimeType == other.runtimeType &&
          concepto == other.concepto &&
          descripcion == other.descripcion &&
          listEquals(accionesSugeridas, other.accionesSugeridas) &&
          vocabularioMatematico == other.vocabularioMatematico;

  @override
  int get hashCode => Object.hash(
        concepto,
        descripcion,
        Object.hashAll(accionesSugeridas),
        vocabularioMatematico,
      );
}

/// Home bridge suggestions connecting classroom to families for step 6.
@immutable
class PonteCasa {
  final LocalizedString mensajeFamilias;
  final List<LocalizedString> actividadesSugeridas;
  final LocalizedString recomendacionConversacion;

  const PonteCasa({
    required this.mensajeFamilias,
    required this.actividadesSugeridas,
    required this.recomendacionConversacion,
  });

  factory PonteCasa.fromJson(Map<String, dynamic> json) {
    final rawActs =
        json['actividadesSugeridas'] ?? json['actividades_sugeridas'];
    final List<LocalizedString> acts;
    if (rawActs is List) {
      acts = rawActs
          .whereType<Map<String, dynamic>>()
          .map((a) => LocalizedString.fromJson(a))
          .toList();
    } else {
      acts = const [];
    }

    return PonteCasa(
      mensajeFamilias: LocalizedString.fromJson(
        (json['mensajeFamilias'] ?? json['mensaje_familias'])
                as Map<String, dynamic>? ??
            {},
      ),
      actividadesSugeridas: List.unmodifiable(acts),
      recomendacionConversacion: LocalizedString.fromJson(
        (json['recomendacionConversacion'] ??
                json['recomendacion_conversacion']) as Map<String, dynamic>? ??
            {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'mensajeFamilias': mensajeFamilias.toJson(),
        'actividadesSugeridas':
            actividadesSugeridas.map((a) => a.toJson()).toList(),
        'recomendacionConversacion': recomendacionConversacion.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PonteCasa &&
          runtimeType == other.runtimeType &&
          mensajeFamilias == other.mensajeFamilias &&
          listEquals(actividadesSugeridas, other.actividadesSugeridas) &&
          recomendacionConversacion == other.recomendacionConversacion;

  @override
  int get hashCode => Object.hash(
        mensajeFamilias,
        Object.hashAll(actividadesSugeridas),
        recomendacionConversacion,
      );
}

/// Strongly typed pedagogical unit model for «Juega con Lúa · Aula».
@immutable

/// El inglés que la persona adulta DICE durante la asamblea, fase por fase.
///
/// No es una lengua de la app: es contenido que se escucha. Vive junto a la
/// fase en la que se usa —no en una pantalla aparte— porque una docente con
/// doce criaturas en la alfombra no va a ir a buscarlo a otro sitio.
///
/// Las claves de [porFase] son las seis fases de la asamblea, en su orden:
/// `pulso`, `conto`, `preguntas`, `exploracion`, `matematicas`, `ponteCasa`.
class InglesUnidad {
  /// La frase entera del mes, la que se lleva a casa.
  final String frase;

  final Map<String, List<String>> porFase;

  const InglesUnidad({this.frase = '', this.porFase = const {}});

  static const List<String> fases = [
    'pulso',
    'conto',
    'preguntas',
    'exploracion',
    'matematicas',
    'ponteCasa',
  ];

  /// Lo que se dice en la fase [indice] (0..5). Vacío si esa fase no lleva.
  List<String> deFase(int indice) {
    if (indice < 0 || indice >= fases.length) return const [];
    return porFase[fases[indice]] ?? const [];
  }

  bool get estaVacio => porFase.values.every((v) => v.isEmpty);

  factory InglesUnidad.fromJson(Map<String, dynamic> json) {
    final raw = json['porFase'];
    final mapa = <String, List<String>>{};
    if (raw is Map) {
      for (final entry in raw.entries) {
        final valor = entry.value;
        if (valor is List) {
          mapa[entry.key.toString()] =
              List<String>.unmodifiable(valor.map((e) => e.toString()));
        }
      }
    }
    return InglesUnidad(
      frase: json['frase']?.toString() ?? '',
      porFase: Map.unmodifiable(mapa),
    );
  }
}

class Unidad {
  final String id;
  final String tramoEtario; // '0-2' | '2-3' | '0-3'
  final int orden;
  final LocalizedString titulo;
  final LocalizedString subtitulo;
  final LocalizedString descripcion;
  final String portadaAsset;
  final CancionPulso cancionPulso;
  final Cuento cuento;
  final List<VocabularioItem> vocabulario;
  final List<PreguntaNivel> preguntas;
  final ExploracionSensorial exploracion;
  final MatematicasTempras matematicas;
  final PonteCasa puenteCasa;
  final CurricularReference curriculo;
  final Revision revision;

  /// El inglés de esta unidad, repartido por fases. Vacío si la unidad no lo
  /// lleva: entonces la asamblea no pinta la barra y no promete nada.
  final InglesUnidad ingles;

  const Unidad({
    required this.id,
    required this.tramoEtario,
    required this.orden,
    required this.titulo,
    required this.subtitulo,
    required this.descripcion,
    required this.portadaAsset,
    required this.cancionPulso,
    required this.cuento,
    required this.vocabulario,
    required this.preguntas,
    required this.exploracion,
    required this.matematicas,
    required this.puenteCasa,
    required this.curriculo,
    required this.revision,
    this.ingles = const InglesUnidad(),
  });

  // Canonical compatibility getters
  CancionPulso get cancion => cancionPulso;
  Cuento get conto => cuento;
  PonteCasa get ponteCasa => puenteCasa;
  CurricularReference get curricular => curriculo;

  factory Unidad.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('id')) {
      throw const FormatException('Unidad missing required key: id');
    }

    final rawVocab = json['vocabulario'];
    final List<VocabularioItem> vocabs;
    if (rawVocab is List) {
      vocabs = rawVocab
          .whereType<Map<String, dynamic>>()
          .map((v) => VocabularioItem.fromJson(v))
          .toList();
    } else {
      vocabs = const [];
    }

    final rawPreg = json['preguntas'];
    final List<PreguntaNivel> questions;
    if (rawPreg is List) {
      questions = rawPreg
          .whereType<Map<String, dynamic>>()
          .map((q) => PreguntaNivel.fromJson(q))
          .toList();
    } else {
      questions = const [];
    }

    final cancionData =
        (json['cancionPulso'] ?? json['cancion']) as Map<String, dynamic>? ??
            {};
    final cuentoData =
        (json['cuento'] ?? json['conto']) as Map<String, dynamic>? ?? {};
    final exploracionData = (json['exploracion'] ??
            json['exploracionSensorial']) as Map<String, dynamic>? ??
        {};
    final matematicasData = (json['matematicas'] ?? json['matematicasTempras'])
            as Map<String, dynamic>? ??
        {};
    final puenteCasaData = (json['puenteCasa'] ??
            json['ponteCasa'] ??
            json['puente_casa']) as Map<String, dynamic>? ??
        {};
    final curriculoData =
        (json['curriculo'] ?? json['curricular']) as Map<String, dynamic>? ??
            {};
    final revisionData = json['revision'] as Map<String, dynamic>? ?? {};

    return Unidad(
      id: json['id']?.toString().trim() ?? '',
      tramoEtario: json['tramoEtario']?.toString().trim() ??
          json['tramo_etario']?.toString().trim() ??
          '0-3',
      orden: (json['orden'] as num?)?.toInt() ?? 1,
      titulo: LocalizedString.fromJson(
          json['titulo'] as Map<String, dynamic>? ?? {}),
      subtitulo: LocalizedString.fromJson(
          json['subtitulo'] as Map<String, dynamic>? ?? {}),
      descripcion: LocalizedString.fromJson(
          json['descripcion'] as Map<String, dynamic>? ?? {}),
      portadaAsset: json['portadaAsset']?.toString().trim() ??
          json['portada_asset']?.toString().trim() ??
          '',
      cancionPulso: CancionPulso.fromJson(cancionData),
      cuento: Cuento.fromJson(cuentoData),
      vocabulario: List.unmodifiable(vocabs),
      preguntas: List.unmodifiable(questions),
      exploracion: ExploracionSensorial.fromJson(exploracionData),
      matematicas: MatematicasTempras.fromJson(matematicasData),
      puenteCasa: PonteCasa.fromJson(puenteCasaData),
      curriculo: CurricularReference.fromJson(curriculoData),
      revision: Revision.fromJson(revisionData),
      ingles: json['ingles'] is Map
          ? InglesUnidad.fromJson(
              Map<String, dynamic>.from(json['ingles'] as Map))
          : const InglesUnidad(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tramoEtario': tramoEtario,
        'orden': orden,
        'titulo': titulo.toJson(),
        'subtitulo': subtitulo.toJson(),
        'descripcion': descripcion.toJson(),
        'portadaAsset': portadaAsset,
        'cancionPulso': cancionPulso.toJson(),
        'cuento': cuento.toJson(),
        'vocabulario': vocabulario.map((v) => v.toJson()).toList(),
        'preguntas': preguntas.map((q) => q.toJson()).toList(),
        'exploracion': exploracion.toJson(),
        'matematicas': matematicas.toJson(),
        'puenteCasa': puenteCasa.toJson(),
        'curriculo': curriculo.toJson(),
        'revision': revision.toJson(),
      };

  /// Returns a copy of this unit with the given fields replaced.
  Unidad copyWith({
    String? id,
    String? tramoEtario,
    int? orden,
    LocalizedString? titulo,
    LocalizedString? subtitulo,
    LocalizedString? descripcion,
    String? portadaAsset,
    CancionPulso? cancionPulso,
    Cuento? cuento,
    List<VocabularioItem>? vocabulario,
    List<PreguntaNivel>? preguntas,
    ExploracionSensorial? exploracion,
    MatematicasTempras? matematicas,
    PonteCasa? puenteCasa,
    CurricularReference? curriculo,
    Revision? revision,
  }) {
    return Unidad(
      id: id ?? this.id,
      tramoEtario: tramoEtario ?? this.tramoEtario,
      orden: orden ?? this.orden,
      titulo: titulo ?? this.titulo,
      subtitulo: subtitulo ?? this.subtitulo,
      descripcion: descripcion ?? this.descripcion,
      portadaAsset: portadaAsset ?? this.portadaAsset,
      cancionPulso: cancionPulso ?? this.cancionPulso,
      cuento: cuento ?? this.cuento,
      vocabulario: vocabulario ?? this.vocabulario,
      preguntas: preguntas ?? this.preguntas,
      exploracion: exploracion ?? this.exploracion,
      matematicas: matematicas ?? this.matematicas,
      puenteCasa: puenteCasa ?? this.puenteCasa,
      curriculo: curriculo ?? this.curriculo,
      revision: revision ?? this.revision,
    );
  }

  /// Validates whether this unit matches the requested age band filter.
  bool matchesAgeBand(String filter) {
    final f = filter.trim();
    const validFilters = {'0-2', '2-3', '0-3'};
    if (!validFilters.contains(f)) return false;
    if (tramoEtario == '0-3') return true;
    return tramoEtario == f;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unidad &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          tramoEtario == other.tramoEtario &&
          orden == other.orden &&
          titulo == other.titulo &&
          subtitulo == other.subtitulo &&
          descripcion == other.descripcion &&
          portadaAsset == other.portadaAsset &&
          cancionPulso == other.cancionPulso &&
          cuento == other.cuento &&
          listEquals(vocabulario, other.vocabulario) &&
          listEquals(preguntas, other.preguntas) &&
          exploracion == other.exploracion &&
          matematicas == other.matematicas &&
          puenteCasa == other.puenteCasa &&
          curriculo == other.curriculo &&
          revision == other.revision;

  @override
  int get hashCode => Object.hashAll([
        id,
        tramoEtario,
        orden,
        titulo,
        subtitulo,
        descripcion,
        portadaAsset,
        cancionPulso,
        cuento,
        Object.hashAll(vocabulario),
        Object.hashAll(preguntas),
        exploracion,
        matematicas,
        puenteCasa,
        curriculo,
        revision,
      ]);

  @override
  String toString() =>
      'Unidad(id: "$id", tramo: "$tramoEtario", titulo: $titulo)';
}

// Aliases for dispatch & schema parity
typedef Vocabulario = VocabularioItem;
typedef PreguntasItem = PreguntaNivel;
typedef Exploracion = ExploracionSensorial;
typedef Matematicas = MatematicasTempras;
typedef PuenteCasa = PonteCasa;
