import 'package:flutter/foundation.dart';
import '../../core/localization/localized_string.dart';
import 'curricular_model.dart';
import 'unidad_model.dart' show Revision;

/// Quién lee la cápsula.
///
/// Las cápsulas de Academy las lee una familia en casa; las del aula las lee
/// la maestra antes o después de la asamblea. Es el mismo objeto y la misma
/// estructura de cuatro secciones —la diferencia no da para dos modelos—, pero
/// no la misma lista ni los mismos títulos de sección: a una maestra no se le
/// dice «qué hacer en casa».
enum DestinatarioCapsula {
  /// Academy. Es el valor por defecto: las cinco cápsulas que ya existían no
  /// declaran el campo y son todas de familia.
  familia,

  /// Juega con Lúa. Formación breve atada a los seis pasos de la asamblea.
  docente;

  String get clave => name;

  static DestinatarioCapsula desdeClave(String? valor) =>
      DestinatarioCapsula.values.firstWhere(
        (d) => d.clave == valor?.trim(),
        orElse: () => DestinatarioCapsula.familia,
      );
}

/// Formative reflective statement (true/false) with immediate supportive feedback.
@immutable
class Afirmacion {
  final String id;
  final LocalizedString enunciado;
  final bool esVerdadera;
  final LocalizedString explicacion;

  const Afirmacion({
    required this.id,
    required this.enunciado,
    required this.esVerdadera,
    required this.explicacion,
  });

  factory Afirmacion.fromJson(Map<String, dynamic> json) {
    return Afirmacion(
      id: json['id']?.toString().trim() ?? '',
      enunciado: LocalizedString.fromJson(
          json['enunciado'] as Map<String, dynamic>? ?? {}),
      esVerdadera: json['esVerdadera'] as bool? ??
          json['es_verdadera'] as bool? ??
          false,
      explicacion: LocalizedString.fromJson(
          json['explicacion'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'enunciado': enunciado.toJson(),
        'esVerdadera': esVerdadera,
        'explicacion': explicacion.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Afirmacion &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          enunciado == other.enunciado &&
          esVerdadera == other.esVerdadera &&
          explicacion == other.explicacion;

  @override
  int get hashCode => Object.hash(id, enunciado, esVerdadera, explicacion);

  @override
  String toString() => 'Afirmacion($id, true: $esVerdadera)';
}

/// The 4 canonical sections of an Academy capsule for families.
@immutable
class ContidoCapsula {
  /// Section 1: Core idea synthesized in 2-3 direct sentences.
  final LocalizedString ideaClave;

  /// Section 2: Neurodevelopmental foundation explained with clarity.
  final LocalizedString porQueImporta;

  /// Section 3: Practical everyday actions without special materials.
  final LocalizedString queHacerEnCasa;

  /// Section 4: Dialogue script of a realistic home scene.
  final LocalizedString ejemploCotidiano;

  const ContidoCapsula({
    required this.ideaClave,
    required this.porQueImporta,
    required this.queHacerEnCasa,
    required this.ejemploCotidiano,
  });

  factory ContidoCapsula.fromJson(Map<String, dynamic> json) {
    return ContidoCapsula(
      ideaClave: LocalizedString.fromJson(
        (json['ideaClave'] ?? json['idea_clave']) as Map<String, dynamic>? ??
            {},
      ),
      porQueImporta: LocalizedString.fromJson(
        (json['porQueImporta'] ?? json['por_que_importa'])
                as Map<String, dynamic>? ??
            {},
      ),
      queHacerEnCasa: LocalizedString.fromJson(
        (json['queHacerEnCasa'] ?? json['que_hacer_en_casa'])
                as Map<String, dynamic>? ??
            {},
      ),
      ejemploCotidiano: LocalizedString.fromJson(
        (json['ejemploCotidiano'] ?? json['ejemplo_cotidiano'])
                as Map<String, dynamic>? ??
            {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'ideaClave': ideaClave.toJson(),
        'porQueImporta': porQueImporta.toJson(),
        'queHacerEnCasa': queHacerEnCasa.toJson(),
        'ejemploCotidiano': ejemploCotidiano.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContidoCapsula &&
          runtimeType == other.runtimeType &&
          ideaClave == other.ideaClave &&
          porQueImporta == other.porQueImporta &&
          queHacerEnCasa == other.queHacerEnCasa &&
          ejemploCotidiano == other.ejemploCotidiano;

  @override
  int get hashCode => Object.hash(
        ideaClave,
        porQueImporta,
        queHacerEnCasa,
        ejemploCotidiano,
      );
}

/// One of the 5 canonical developmental blocks in Academy.
@immutable
class Bloque {
  final String id;
  final int orden;
  final LocalizedString titulo;
  final LocalizedString descripcion;
  final String icono;
  final String colorHex;

  const Bloque({
    required this.id,
    required this.orden,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.colorHex,
  });

  static const String desarrolloComunicativoId = 'desarrollo_comunicativo';
  static const String rutinasYBanoDeLenguajeId = 'rutinas_y_bano_de_lenguaje';
  static const String turnosYAtencionConjuntaId = 'turnos_y_atencion_conjunta';
  static const String juegoMovimientoSinPantallasId =
      'juego_movimiento_sin_pantallas';
  static const String bilinguismoYCulturaId = 'bilinguismo_y_cultura';

  /// The 5 official developmental blocks of Academy.
  static const List<Bloque> todos = [
    Bloque(
      id: desarrolloComunicativoId,
      orden: 1,
      titulo: LocalizedString(
        gl: 'Como se aprende a falar',
        es: 'Cómo se aprende a hablar',
      ),
      descripcion: LocalizedString(
        gl: 'Hitos evolutivos normativos, audición e desenvolvemento da linguaxe no fogar.',
        es: 'Hitos evolutivos normativos, audición y desarrollo del lenguaje en el hogar.',
      ),
      icono: 'ear_sparkles',
      colorHex: '#1B4965',
    ),
    Bloque(
      id: rutinasYBanoDeLenguajeId,
      orden: 2,
      titulo: LocalizedString(
        gl: 'O baño de linguaxe nas rutinas',
        es: 'El baño de lenguaje en las rutinas',
      ),
      descripcion: LocalizedString(
        gl: 'Aproveitar a comida, o baño, o paseo e o cambio de cueiro como momentos de conversa.',
        es: 'Aprovechar la comida, el baño, el paseo y el cambio de pañal como momentos de conversación.',
      ),
      icono: 'chat_bubble_heart',
      colorHex: '#62B6CB',
    ),
    Bloque(
      id: turnosYAtencionConjuntaId,
      orden: 3,
      titulo: LocalizedString(
        gl: 'Quendas de conversa e atención conxunta',
        es: 'Turnos de conversación y atención conjunta',
      ),
      descripcion: LocalizedString(
        gl: 'A arte de servir e devolver balbuceos, a regra dos 5 segundos de espera e miradas compartidas.',
        es: 'El arte de servir y devolver balbuceos, la regla de los 5 segundos de espera y miradas compartidas.',
      ),
      icono: 'people_arrows',
      colorHex: '#81B29A',
    ),
    Bloque(
      id: juegoMovimientoSinPantallasId,
      orden: 4,
      titulo: LocalizedString(
        gl: 'Xogo corporal e espazos sen pantallas',
        es: 'Juego corporal y espacios sin pantallas',
      ),
      descripcion: LocalizedString(
        gl: 'Psicomotricidade, contacto físico e protección activa fronte a pantallas nos primeiros 3 anos.',
        es: 'Psicomotricidad, contacto físico y protección activa frente a pantallas en los primeros 3 años.',
      ),
      icono: 'child_play',
      colorHex: '#E07A5F',
    ),
    Bloque(
      id: bilinguismoYCulturaId,
      orden: 5,
      titulo: LocalizedString(
        gl: 'Crianza bilingüe e contorna cultural',
        es: 'Crianza bilingüe y entorno cultural',
      ),
      descripcion: LocalizedString(
        gl: 'Convivir e medrar en galego e castelán con harmonía e sen presións dende o berce.',
        es: 'Convivir y crecer en gallego y castellano con armonía y sin presiones desde la cuna.',
      ),
      icono: 'home_globe',
      colorHex: '#3D5A80',
    ),
  ];

  static const String aulaPulsoId = 'aula_pulso';
  static const String aulaContoId = 'aula_conto';
  static const String aulaPreguntasId = 'aula_preguntas';
  static const String aulaExploracionId = 'aula_exploracion';
  static const String aulaMatematicasId = 'aula_matematicas';
  static const String aulaPonteCasaId = 'aula_ponte_casa';

  /// Los 6 bloques de las cápsulas del aula.
  ///
  /// No son temas elegidos a gusto: son EXACTAMENTE los seis pasos de la
  /// asamblea, en su orden. Así la formación de la maestra no vive aparte de
  /// lo que hace: la cápsula del pulso está al lado del paso del pulso, y si
  /// mañana se añade o se quita un paso, salta a la vista que aquí falta o
  /// sobra un bloque.
  static const List<Bloque> aula = [
    Bloque(
      id: aulaPulsoId,
      orden: 1,
      titulo: LocalizedString(
        gl: 'O pulso que se ve',
        es: 'El pulso que se ve',
      ),
      descripcion: LocalizedString(
        gl: 'Por que o metrónomo se debuxa e non se escoita, e como marcar o '
            'pulso co corpo.',
        es: 'Por qué el metrónomo se dibuja y no se oye, y cómo marcar el '
            'pulso con el cuerpo.',
      ),
      icono: 'ear_sparkles',
      colorHex: '#1B4965',
    ),
    Bloque(
      id: aulaContoId,
      orden: 2,
      titulo: LocalizedString(
        gl: 'Ler para quen aínda non fala',
        es: 'Leer para quien todavía no habla',
      ),
      descripcion: LocalizedString(
        gl: 'A voz, o dedo e as pausas: como se le un conto nunha asemblea de '
            'cero a tres.',
        es: 'La voz, el dedo y las pausas: cómo se lee un cuento en una '
            'asamblea de cero a tres.',
      ),
      icono: 'chat_bubble_heart',
      colorHex: '#62B6CB',
    ),
    Bloque(
      id: aulaPreguntasId,
      orden: 3,
      titulo: LocalizedString(
        gl: 'Preguntar sen examinar',
        es: 'Preguntar sin examinar',
      ),
      descripcion: LocalizedString(
        gl: 'Os tres niveis de pregunta e o silencio que vai despois.',
        es: 'Los tres niveles de pregunta y el silencio que va después.',
      ),
      icono: 'people_arrows',
      colorHex: '#5FA8D3',
    ),
    Bloque(
      id: aulaExploracionId,
      orden: 4,
      titulo: LocalizedString(
        gl: 'Poñer palabras ao que tocan',
        es: 'Poner palabras a lo que tocan',
      ),
      descripcion: LocalizedString(
        gl: 'A exploración sensorial: seguridade primeiro, e nomear a '
            'sensación mentres pasa.',
        es: 'La exploración sensorial: seguridad primero, y nombrar la '
            'sensación mientras pasa.',
      ),
      icono: 'child_play',
      colorHex: '#E07A5F',
    ),
    Bloque(
      id: aulaMatematicasId,
      orden: 5,
      titulo: LocalizedString(
        gl: 'Grande e pequeno antes dos números',
        es: 'Grande y pequeño antes de los números',
      ),
      descripcion: LocalizedString(
        gl: 'As primeiras nocións de cantidade e tamaño chegan coas mans, non '
            'coa conta.',
        es: 'Las primeras nociones de cantidad y tamaño llegan con las manos, '
            'no con la cuenta.',
      ),
      icono: 'home_globe',
      colorHex: '#3D5A80',
    ),
    Bloque(
      id: aulaPonteCasaId,
      orden: 6,
      titulo: LocalizedString(
        gl: 'Pasar a mensaxe á casa',
        es: 'Pasar el mensaje a casa',
      ),
      descripcion: LocalizedString(
        gl: 'Como se conta na porta o que se fixo na aula para que siga na '
            'casa.',
        es: 'Cómo se cuenta en la puerta lo que se hizo en el aula para que '
            'siga en casa.',
      ),
      icono: 'chat_bubble_heart',
      colorHex: '#127A75',
    ),
  ];

  /// Todos los bloques, los de Academy y los del aula.
  static List<Bloque> get todosIncluidoAula => [...todos, ...aula];

  /// Resolves a block by its canonical ID, Academy or aula.
  static Bloque? byId(String id) {
    final cleanId = id.trim().toLowerCase();
    for (final b in todosIncluidoAula) {
      if (b.id.toLowerCase() == cleanId) return b;
    }
    return null;
  }

  /// Resolves a block by its order index (1..5).
  static Bloque? byOrden(int orden) {
    for (final b in todos) {
      if (b.orden == orden) return b;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bloque &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          orden == other.orden;

  @override
  int get hashCode => Object.hash(id, orden);

  @override
  String toString() => 'Bloque($id, orden: $orden)';
}

/// Strongly typed micro-learning capsule model for «Academy · Familias».
@immutable
class Capsula {
  final String id;
  final String bloqueId;

  /// Quién la lee. Sin el campo, familia: las cinco de Academy son anteriores.
  final DestinatarioCapsula destinatario;

  final int orden;
  final LocalizedString titulo;
  final LocalizedString subtitulo;
  final int tiempoLecturaMinutos;
  final String icono;
  final LocalizedString ideaClave;
  final LocalizedString porQueImporta;
  final LocalizedString queHacerEnCasa;
  final LocalizedString ejemploCotidiano;
  final List<Afirmacion> afirmaciones;
  final CurricularReference curriculo;
  final Revision revision;

  const Capsula({
    required this.id,
    required this.bloqueId,
    this.destinatario = DestinatarioCapsula.familia,
    required this.orden,
    required this.titulo,
    required this.subtitulo,
    required this.tiempoLecturaMinutos,
    required this.icono,
    required this.ideaClave,
    required this.porQueImporta,
    required this.queHacerEnCasa,
    required this.ejemploCotidiano,
    required this.afirmaciones,
    required this.curriculo,
    required this.revision,
  });

  /// Canonical aggregated content object.
  ContidoCapsula get contido => ContidoCapsula(
        ideaClave: ideaClave,
        porQueImporta: porQueImporta,
        queHacerEnCasa: queHacerEnCasa,
        ejemploCotidiano: ejemploCotidiano,
      );

  factory Capsula.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('id')) {
      throw const FormatException('Capsula missing required key: id');
    }

    final rawAfirmaciones = json['afirmaciones'];
    final List<Afirmacion> afirmations;
    if (rawAfirmaciones is List) {
      afirmations = rawAfirmaciones
          .whereType<Map<String, dynamic>>()
          .map((a) => Afirmacion.fromJson(a))
          .toList();
    } else {
      afirmations = const [];
    }

    // Support either top-level sections or a nested 'contido' map
    final Map<String, dynamic> contidoMap =
        json['contido'] as Map<String, dynamic>? ?? {};

    final ideaClaveData = (json['ideaClave'] ??
            json['idea_clave'] ??
            contidoMap['ideaClave'] ??
            contidoMap['idea_clave']) as Map<String, dynamic>? ??
        {};

    final porQueImportaData = (json['porQueImporta'] ??
            json['por_que_importa'] ??
            contidoMap['porQueImporta'] ??
            contidoMap['por_que_importa']) as Map<String, dynamic>? ??
        {};

    final queHacerEnCasaData = (json['queHacerEnCasa'] ??
            json['que_hacer_en_casa'] ??
            contidoMap['queHacerEnCasa'] ??
            contidoMap['que_hacer_en_casa']) as Map<String, dynamic>? ??
        {};

    final ejemploCotidianoData = (json['ejemploCotidiano'] ??
            json['ejemplo_cotidiano'] ??
            contidoMap['ejemploCotidiano'] ??
            contidoMap['ejemplo_cotidiano']) as Map<String, dynamic>? ??
        {};

    final curriculoData =
        (json['curriculo'] ?? json['curricular']) as Map<String, dynamic>? ??
            {};
    final revisionData = json['revision'] as Map<String, dynamic>? ?? {};

    return Capsula(
      id: json['id']?.toString().trim() ?? '',
      bloqueId: json['bloqueId']?.toString().trim() ??
          json['bloque_id']?.toString().trim() ??
          '',
      destinatario:
          DestinatarioCapsula.desdeClave(json['destinatario']?.toString()),
      orden: (json['orden'] as num?)?.toInt() ?? 1,
      titulo: LocalizedString.fromJson(
          json['titulo'] as Map<String, dynamic>? ?? {}),
      subtitulo: LocalizedString.fromJson(
          json['subtitulo'] as Map<String, dynamic>? ?? {}),
      tiempoLecturaMinutos: (json['tiempoLecturaMinutos'] ??
                  json['tiempo_lectura_minutos'] as num?)
              ?.toInt() ??
          3,
      icono: json['icono']?.toString().trim() ?? 'ear_sparkles',
      ideaClave: LocalizedString.fromJson(ideaClaveData),
      porQueImporta: LocalizedString.fromJson(porQueImportaData),
      queHacerEnCasa: LocalizedString.fromJson(queHacerEnCasaData),
      ejemploCotidiano: LocalizedString.fromJson(ejemploCotidianoData),
      afirmaciones: List.unmodifiable(afirmations),
      curriculo: CurricularReference.fromJson(curriculoData),
      revision: Revision.fromJson(revisionData),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bloqueId': bloqueId,
        'destinatario': destinatario.clave,
        'orden': orden,
        'titulo': titulo.toJson(),
        'subtitulo': subtitulo.toJson(),
        'tiempoLecturaMinutos': tiempoLecturaMinutos,
        'icono': icono,
        'ideaClave': ideaClave.toJson(),
        'porQueImporta': porQueImporta.toJson(),
        'queHacerEnCasa': queHacerEnCasa.toJson(),
        'ejemploCotidiano': ejemploCotidiano.toJson(),
        'afirmaciones': afirmaciones.map((a) => a.toJson()).toList(),
        'curriculo': curriculo.toJson(),
        'revision': revision.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Capsula &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          bloqueId == other.bloqueId &&
          orden == other.orden &&
          titulo == other.titulo &&
          subtitulo == other.subtitulo &&
          tiempoLecturaMinutos == other.tiempoLecturaMinutos &&
          icono == other.icono &&
          ideaClave == other.ideaClave &&
          porQueImporta == other.porQueImporta &&
          queHacerEnCasa == other.queHacerEnCasa &&
          ejemploCotidiano == other.ejemploCotidiano &&
          listEquals(afirmaciones, other.afirmaciones) &&
          curriculo == other.curriculo &&
          revision == other.revision;

  @override
  int get hashCode => Object.hashAll([
        id,
        bloqueId,
        orden,
        titulo,
        subtitulo,
        tiempoLecturaMinutos,
        icono,
        ideaClave,
        porQueImporta,
        queHacerEnCasa,
        ejemploCotidiano,
        Object.hashAll(afirmaciones),
        curriculo,
        revision,
      ]);

  @override
  String toString() =>
      'Capsula(id: "$id", bloque: "$bloqueId", titulo: $titulo)';
}
