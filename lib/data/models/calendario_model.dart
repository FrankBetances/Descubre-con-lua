import '../../core/localization/localized_string.dart';

/// Estado de estimulación para un día del calendario compartido.
enum EstadoEstimulacion {
  sinRegistro,
  soloAula,
  soloHogar,
  dobleEstimulacion,
}

/// Las tres cuentas del calendario: los únicos datos que salen de él hacia los
/// premios. Tres enteros; las fechas se quedan en el almacén.
class ContadoresCalendario {
  final int diasAula;
  final int diasFogar;
  final int diasDobres;

  const ContadoresCalendario({
    this.diasAula = 0,
    this.diasFogar = 0,
    this.diasDobres = 0,
  });
}

/// La capa de inglés (L3) de un mes.
///
/// **El inglés no es una lengua de interfaz.** La app se lee en gallego o en
/// castellano; esto es contenido, no traducción. Son las cadenas que la persona
/// adulta va a DECIR, y por eso cada una tiene grabación propia en
/// `assets/voice/`: la docente que no domina el inglés oye la pronunciación
/// antes de llevarla a la asamblea. Si cambia una cadena de aquí, su grabación
/// deja de existir y `tools/check_voice_coverage.py` lo dice.
class InglesDelMes {
  /// Palabras sueltas. Se graban despacio, porque existen para imitarse.
  final List<String> lexico;

  /// Órdenes de respuesta física (TPR): lo que se pide con el cuerpo.
  final List<String> tpr;

  /// La frase de la rutina de casa, entera.
  final String frase;

  const InglesDelMes({
    required this.lexico,
    required this.tpr,
    required this.frase,
  });

  factory InglesDelMes.fromJson(Map<String, dynamic> json) => InglesDelMes(
        lexico: List<String>.from(
            (json['lexico'] as List? ?? const []).map((e) => e.toString())),
        tpr: List<String>.from(
            (json['tpr'] as List? ?? const []).map((e) => e.toString())),
        frase: json['frase']?.toString() ?? '',
      );

  /// Todo lo que se puede escuchar de este mes, en el orden en que se pinta.
  List<String> get todo => [...lexico, ...tpr, if (frase.isNotEmpty) frase];
}

/// Una unidad mensual del calendario escolar (septiembre a junio).
///
/// Sale de `assets/content/calendario/meses.json`. Aquí no hay ni una cadena de
/// contenido: si algo de esta clase se puede leer en pantalla, viene del JSON.
class MesCurricular {
  final int orden;
  final int mesCalendario;

  /// Id de la unidad de aula que se dirige este mes, o `null` si todavía no
  /// está escrita. **No se deduce del `orden`**: el `orden` de una unidad es su
  /// sitio en el catálogo, no el mes del curso, y emparejarlos hacía que la
  /// unidad del mar se abriera en septiembre.
  final String? unidadId;

  /// Token del icono, no un `IconData`: el contenido no conoce Flutter.
  /// Lo traduce `lib/core/brand/iconos_contenido.dart`.
  final String icono;

  final LocalizedString nombreMes;
  final LocalizedString centroInteres;
  final LocalizedString objetivoPedagogico;
  final LocalizedString actividadAula;
  final LocalizedString actividadHogar;
  final LocalizedString rutinaRecomendadaHogar;

  /// Minutos de juego sugeridos. Es una sugerencia de crianza, no una medida
  /// del desarrollo de nadie: la app no evalúa a ninguna criatura.
  final int minutosSugeridos;

  final InglesDelMes ingles;

  const MesCurricular({
    required this.orden,
    required this.mesCalendario,
    required this.icono,
    this.unidadId,
    required this.nombreMes,
    required this.centroInteres,
    required this.objetivoPedagogico,
    required this.actividadAula,
    required this.actividadHogar,
    required this.rutinaRecomendadaHogar,
    required this.minutosSugeridos,
    required this.ingles,
  });

  factory MesCurricular.fromJson(Map<String, dynamic> json) {
    LocalizedString texto(String clave) => LocalizedString.fromJson(
          Map<String, dynamic>.from(json[clave] as Map),
        );

    return MesCurricular(
      orden: (json['orden'] as num).toInt(),
      mesCalendario: (json['mesCalendario'] as num).toInt(),
      icono: json['icono']?.toString() ?? 'mar',
      unidadId: (json['unidad'] as String?)?.trim().isEmpty ?? true
          ? null
          : (json['unidad'] as String).trim(),
      nombreMes: texto('nombreMes'),
      centroInteres: texto('centroInteres'),
      objetivoPedagogico: texto('objetivoPedagogico'),
      actividadAula: texto('actividadAula'),
      actividadHogar: texto('actividadHogar'),
      rutinaRecomendadaHogar: texto('rutinaRecomendadaHogar'),
      minutosSugeridos: (json['minutosSugeridos'] as num).toInt(),
      ingles: InglesDelMes.fromJson(
        Map<String, dynamic>.from(json['ingles'] as Map),
      ),
    );
  }
}

/// Una de las reglas de la guía de la familia.
class ReglaCasa {
  final String id;
  final String icono;
  final LocalizedString titulo;
  final LocalizedString texto;

  const ReglaCasa({
    required this.id,
    required this.icono,
    required this.titulo,
    required this.texto,
  });

  factory ReglaCasa.fromJson(Map<String, dynamic> json) => ReglaCasa(
        id: json['id'].toString(),
        icono: json['icono']?.toString() ?? 'voz',
        titulo: LocalizedString.fromJson(
            Map<String, dynamic>.from(json['titulo'] as Map)),
        texto: LocalizedString.fromJson(
            Map<String, dynamic>.from(json['texto'] as Map)),
      );
}

/// Un tramo de edad con su momento doméstico y su frase en inglés.
///
/// [minutosSugeridos] es tiempo de juego propuesto, en lenguaje de crianza. No
/// es un valor normativo de desarrollo ni un resultado de ninguna medición.
class TramoAtencion {
  final String id;
  final String icono;
  final LocalizedString rangoEdad;
  final int minutosSugeridos;
  final LocalizedString momentoDomestico;
  final LocalizedString queFacer;
  final LocalizedString queEvitar;
  final String fraseIngles;

  const TramoAtencion({
    required this.id,
    required this.icono,
    required this.rangoEdad,
    required this.minutosSugeridos,
    required this.momentoDomestico,
    required this.queFacer,
    required this.queEvitar,
    required this.fraseIngles,
  });

  factory TramoAtencion.fromJson(Map<String, dynamic> json) {
    LocalizedString texto(String clave) => LocalizedString.fromJson(
          Map<String, dynamic>.from(json[clave] as Map),
        );

    return TramoAtencion(
      id: json['id'].toString(),
      icono: json['icono']?.toString() ?? 'bebe',
      rangoEdad: texto('rangoEdad'),
      minutosSugeridos: (json['minutosSugeridos'] as num).toInt(),
      momentoDomestico: texto('momentoDomestico'),
      queFacer: texto('queFacer'),
      queEvitar: texto('queEvitar'),
      fraseIngles: json['fraseIngles']?.toString() ?? '',
    );
  }
}

/// La guía de la familia, leída de `assets/content/calendario/atencion.json`.
class GuiaAtencion {
  final List<ReglaCasa> reglas;
  final List<TramoAtencion> tramos;

  const GuiaAtencion({required this.reglas, required this.tramos});

  factory GuiaAtencion.fromJson(Map<String, dynamic> json) => GuiaAtencion(
        reglas: (json['reglas'] as List? ?? const [])
            .map((e) => ReglaCasa.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(growable: false),
        tramos: (json['tramos'] as List? ?? const [])
            .map((e) =>
                TramoAtencion.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(growable: false),
      );
}
