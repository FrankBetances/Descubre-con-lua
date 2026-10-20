import '../../core/localization/localized_string.dart';
import 'unidade_do_mes_model.dart';

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
///
/// Aquí no hay léxico. El inglés del curso son cinco palabras nuevas cada día
/// y viven en `assets/content/tpr/` (ver `CursoTpr`); un léxico de seis
/// palabras por mes al lado era un segundo plan que contradecía al primero.
class InglesDelMes {
  /// Órdenes de respuesta física (TPR): lo que se pide con el cuerpo.
  final List<String> tpr;

  /// La frase de la rutina de casa, entera.
  final String frase;

  const InglesDelMes({
    required this.tpr,
    required this.frase,
  });

  factory InglesDelMes.fromJson(Map<String, dynamic> json) => InglesDelMes(
        tpr: List<String>.from(
            (json['tpr'] as List? ?? const []).map((e) => e.toString())),
        frase: json['frase']?.toString() ?? '',
      );

  /// Todo lo que se puede escuchar de este mes, en el orden en que se pinta.
  List<String> get todo => [...tpr, if (frase.isNotEmpty) frase];
}

/// Un mes del calendario escolar (septiembre a junio).
///
/// En el trayecto sale de la unidad del mes ([MesCurricular.daUnidade]); el
/// catálogo de diez meses de `assets/content/calendario/meses.json` queda para
/// el nombre, el icono y los minutos, y como reserva si las unidades no se
/// leen. Aquí no hay ni una cadena de contenido: todo viene del JSON.
class MesCurricular {
  final int orden;
  final int mesCalendario;

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

  /// El curso de este mes en el trayecto 0-6 (`curso_0_2` … `curso_5_6`), o
  /// `null` en el catálogo de diez meses de `meses.json`, que no es de ningún
  /// curso en concreto.
  final String? cursoId;

  /// La unidad del mes, en el trayecto. Cuando está, es la que manda: el centro
  /// de interés es el suyo (que es el de la asamblea, D4) y el calendario pinta
  /// su núcleo. Los textos de actividad y el objetivo quedan vacíos, porque
  /// venían de `curriculo_50_meses.json` y contaban otro tema que la asamblea.
  final UnidadeDoMes? unidade;

  const MesCurricular({
    required this.orden,
    required this.mesCalendario,
    required this.icono,
    this.cursoId,
    this.unidade,
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

  /// El mes dentro de su curso, de 1 (septiembre) a 10 (junio). En el
  /// trayecto el [orden] va de 1 a 50; la tarjeta, sus colores y su dibujo son
  /// los del mes, no los del puesto en el trayecto.
  int get mesDoCurso => cursoId == null ? orden : ((orden - 1) % 10) + 1;

  /// La edad del curso de este mes, para la tarjeta; `null` fuera del trayecto.
  LocalizedString? get etiquetaCurso => etiquetasDosCursos[cursoId];

  /// Las edades de los cinco cursos del trayecto.
  static const Map<String, LocalizedString> etiquetasDosCursos = {
    'curso_0_2': LocalizedString(gl: '0-2 anos', es: '0-2 años'),
    'curso_2_3': LocalizedString(gl: '2-3 anos', es: '2-3 años'),
    'curso_3_4': LocalizedString(gl: '3-4 anos', es: '3-4 años'),
    'curso_4_5': LocalizedString(gl: '4-5 anos', es: '4-5 años'),
    'curso_5_6': LocalizedString(gl: '5-6 anos', es: '5-6 años'),
  };

  static const LocalizedString _sinTexto = LocalizedString(gl: '', es: '');

  /// Un mes del trayecto, leído de su unidad.
  ///
  /// El nombre del mes y el icono son los del mes de [base]
  /// (`meses.json`), que no cuentan tema. El centro de interés es el de
  /// [unidade]. [minutos] son los de casa de ese curso, que crecen con la
  /// edad; sin ellos, los de [base]. [orden] es la posición en el trayecto: 1
  /// es septiembre de 0-2 años y 50 es junio de 5-6.
  factory MesCurricular.daUnidade(
    UnidadeDoMes unidade, {
    required MesCurricular base,
    required int orden,
    int? minutos,
  }) =>
      MesCurricular(
        orden: orden,
        mesCalendario: base.mesCalendario,
        icono: base.icono,
        cursoId: unidade.curso,
        unidade: unidade,
        nombreMes: base.nombreMes,
        centroInteres: unidade.centroInteres,
        objetivoPedagogico: _sinTexto,
        actividadAula: _sinTexto,
        actividadHogar: _sinTexto,
        rutinaRecomendadaHogar: _sinTexto,
        minutosSugeridos: minutos ?? base.minutosSugeridos,
        ingles: const InglesDelMes(tpr: [], frase: ''),
      );
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
