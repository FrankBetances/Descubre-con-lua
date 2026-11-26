import '../../core/localization/app_language.dart';
import 'criancas_store.dart';

/// Capa de material usada por un niño en una semana (AUDITORIA §4b).
enum CapaSemana { nucleo, mais, apoio }

/// Umbral M4 (corrección 26/11/2026): una palabra no cuenta como fallo de
/// «la dice» hasta que el niño la ha oído al menos estas veces. Constante
/// única pensada para que la logopeda pueda ajustarla fácilmente.
const int minimoEscoitasParaFallo = 8;

/// Topes de palabras nuevas por semana para un curso (D5 + §4b).
class TopesCurso {
  const TopesCurso({
    required this.min,
    required this.max,
    required this.base,
    required this.tectoPeldano,
  });

  final int min;
  final int max;
  final int base;
  final int tectoPeldano;
}

/// Estado semanal persistido por niño y semana del curso (sin fecha ni hora).
class RexistroAxusteSemanal {
  const RexistroAxusteSemanal({
    required this.taxa,
    required this.capa,
    required this.cupo,
    required this.peldano,
    this.consolidando = false,
  });

  final double taxa;
  final CapaSemana capa;
  final int cupo;
  final int peldano;
  final bool consolidando;

  Map<String, dynamic> toJson() => {
        'taxa': double.parse(taxa.toStringAsFixed(2)),
        'capa': capa.name,
        'cupo': cupo,
        'peldano': peldano,
        if (consolidando) 'consolidando': true,
      };

  static RexistroAxusteSemanal? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final taxa = raw['taxa'] is num ? (raw['taxa'] as num).toDouble() : 0.0;
    final capaStr = raw['capa']?.toString() ?? 'nucleo';
    final capa = CapaSemana.values.firstWhere(
      (c) => c.name == capaStr,
      orElse: () => CapaSemana.nucleo,
    );
    final cupo = raw['cupo'] is int ? raw['cupo'] as int : 3;
    final peldano = raw['peldano'] is int ? raw['peldano'] as int : 1;
    final consol = raw['consolidando'] == true;
    return RexistroAxusteSemanal(
      taxa: taxa.clamp(0.0, 1.0),
      capa: capa,
      cupo: cupo,
      peldano: peldano.clamp(1, 6),
      consolidando: consol,
    );
  }
}

/// Resultado del cálculo semanal del lunes (cupo, mezcla, peldaño, capa y
/// explicación en gl/es sin porcentajes).
class ResultadoAxusteSemanal {
  const ResultadoAxusteSemanal({
    required this.cupoNovas,
    required this.pesoRepaso,
    required this.peldano,
    required this.capa,
    required this.taxaEntende,
    required this.taxaDi,
    required this.consolidando,
    required this.senMarcas,
    required this.explicacionGl,
    required this.explicacionEs,
    required this.novasSemanasBaixas,
    required this.novasSemanasDiAlto,
  });

  final int cupoNovas;
  final double pesoRepaso;
  final int peldano;
  final CapaSemana capa;
  final double taxaEntende;
  final double taxaDi;
  final bool consolidando;
  final bool senMarcas;
  final String explicacionGl;
  final String explicacionEs;
  final int novasSemanasBaixas;
  final int novasSemanasDiAlto;

  String explicacion(AppLanguage lang) =>
      lang == AppLanguage.gl ? explicacionGl : explicacionEs;

  RexistroAxusteSemanal get rexistro => RexistroAxusteSemanal(
        taxa: taxaEntende,
        capa: capa,
        cupo: cupoNovas,
        peldano: peldano,
        consolidando: consolidando,
      );
}

/// Motor puro del ajuste dinámico semanal (P11.4, §4b y M4). Sin widgets.
class AxusteSemanal {
  const AxusteSemanal._();

  static const Map<String, TopesCurso> topesPorCurso = {
    'curso_0_2': TopesCurso(min: 1, max: 3, base: 2, tectoPeldano: 1),
    'curso_2_3': TopesCurso(min: 2, max: 4, base: 3, tectoPeldano: 3),
    'curso_3_4': TopesCurso(min: 2, max: 5, base: 3, tectoPeldano: 4),
    'curso_4_5': TopesCurso(min: 3, max: 6, base: 4, tectoPeldano: 5),
    'curso_5_6': TopesCurso(min: 3, max: 7, base: 5, tectoPeldano: 6),
  };

  static TopesCurso topesDe(String curso) =>
      topesPorCurso[curso] ?? topesPorCurso['curso_3_4']!;

  static int tectoPeldano(String curso) => topesDe(curso).tectoPeldano;

  static String _numGl(int n) => switch (n) {
        0 => 'cero',
        1 => 'unha',
        2 => 'dúas',
        3 => 'tres',
        4 => 'catro',
        5 => 'cinco',
        6 => 'seis',
        7 => 'sete',
        _ => '$n',
      };

  static String _numEs(int n) => switch (n) {
        0 => 'cero',
        1 => 'una',
        2 => 'dos',
        3 => 'tres',
        4 => 'cuatro',
        5 => 'cinco',
        6 => 'seis',
        7 => 'siete',
        _ => '$n',
      };

  /// Calcula los mandos de la semana entrante a partir de las marcas de la
  /// semana anterior, el contador de escuchas M4 (`escoitas`), y los acumulados
  /// consecutivos.
  static ResultadoAxusteSemanal calcular({
    required String nome,
    required String curso,
    required int peldanoActual,
    required int cupoActual,
    required Map<String, Observacion> marcasSemanaAnterior,
    Map<String, int> escoitasPorPalabra = const {},
    int semanasBaixasSeguidas = 0,
    int semanasDiAltoSeguidas = 0,
    int vencidas = 0,
  }) {
    final topes = topesDe(curso);
    final pelTecto = topes.tectoPeldano;
    final pelClamped = peldanoActual.clamp(1, pelTecto);
    final cupoClamped = cupoActual.clamp(topes.min, topes.max);

    // Con más de 6 tarjetas de repaso vencidas no entran palabras nuevas ese día.
    if (vencidas > 6) {
      return ResultadoAxusteSemanal(
        cupoNovas: 0,
        pesoRepaso: 1.0,
        peldano: pelClamped,
        capa: CapaSemana.apoio,
        taxaEntende: 0.0,
        taxaDi: 0.0,
        consolidando: false,
        senMarcas: marcasSemanaAnterior.isEmpty,
        explicacionGl:
            'Esta semana, sen palabras novas para $nome: ten máis de seis para repasar primeiro.',
        explicacionEs:
            'Esta semana, sin palabras nuevas para $nome: tiene más de seis para repasar primero.',
        novasSemanasBaixas: semanasBaixasSeguidas,
        novasSemanasDiAlto: semanasDiAltoSeguidas,
      );
    }

    // Si la familia no marcó nada la semana anterior: ni sube ni baja.
    if (marcasSemanaAnterior.isEmpty) {
      return ResultadoAxusteSemanal(
        cupoNovas: cupoClamped,
        pesoRepaso: 0.5,
        peldano: pelClamped,
        capa: CapaSemana.nucleo,
        taxaEntende: 0.0,
        taxaDi: 0.0,
        consolidando: false,
        senMarcas: true,
        explicacionGl:
            'Esta semana, ${_numGl(cupoClamped)} ${cupoClamped == 1 ? 'palabra nova' : 'palabras novas'} para $nome: segue o ritmo desta idade.',
        explicacionEs:
            'Esta semana, ${_numEs(cupoClamped)} ${cupoClamped == 1 ? 'palabra nueva' : 'palabras nuevas'} para $nome: sigue el ritmo de esta edad.',
        novasSemanasBaixas: 0,
        novasSemanasDiAlto: 0,
      );
    }

    final total = marcasSemanaAnterior.length;
    final entendidas = marcasSemanaAnterior.values
        .where((o) => o == Observacion.entende || o == Observacion.di)
        .length;
    final taxaEntende = entendidas / total;

    // M4: una palabra no cuenta como fallo de «la dice» mientras tenga
    // menos de [minimoEscoitasParaFallo] escuchas acumuladas.
    final ditas = marcasSemanaAnterior.entries
        .where((e) => e.value == Observacion.di)
        .length;
    final fallosDiReais = marcasSemanaAnterior.entries.where((e) {
      if (e.value == Observacion.di) return false;
      final esc = escoitasPorPalabra[CriancasStore.claveRepaso(e.key)] ?? 0;
      return esc >= minimoEscoitasParaFallo;
    }).length;
    final denomDi = ditas + fallosDiReais;
    final double taxaDi;
    if (denomDi > 0) {
      taxaDi = ditas / denomDi;
    } else {
      // Todas las palabras no dichas llevan menos de 8 escuchas: no bajan
      // la tasa como fallo, pero tampoco simulan un avance que no existe si ditas==0.
      taxaDi = ditas > 0 ? 1.0 : 0.0;
    }

    final eBaixa = taxaEntende < 0.30;
    final novasBaixas = eBaixa ? semanasBaixasSeguidas + 1 : 0;

    final eDiAlto = denomDi > 0 && ditas > 0 && taxaDi >= 0.80;
    final novasDiAlto = eDiAlto ? semanasDiAltoSeguidas + 1 : 0;

    var peldanoFinal = pelClamped;
    if (novasBaixas >= 3) {
      // Menos del 30 % tres semanas seguidas: consolidar sin palabras nuevas.
      peldanoFinal = (pelClamped - 1).clamp(1, pelTecto);
      return ResultadoAxusteSemanal(
        cupoNovas: 0,
        pesoRepaso: 1.0,
        peldano: peldanoFinal,
        capa: CapaSemana.apoio,
        taxaEntende: taxaEntende,
        taxaDi: taxaDi,
        consolidando: true,
        senMarcas: false,
        explicacionGl:
            'Esta semana, todo repaso sen palabras novas para $nome: consolidamos as anteriores con calma.',
        explicacionEs:
            'Esta semana, todo repaso sin palabras nuevas para $nome: consolidamos las anteriores con calma.',
        novasSemanasBaixas: novasBaixas,
        novasSemanasDiAlto: 0,
      );
    }

    if (novasDiAlto >= 2) {
      peldanoFinal = (pelClamped + 1).clamp(1, pelTecto);
    }

    late final int cupoFinal;
    late final CapaSemana capaFinal;
    late final double pesoFinal;
    late final String expGl;
    late final String expEs;

    if (taxaEntende >= 0.80 && taxaDi >= 0.50 && ditas > 0) {
      cupoFinal = (cupoClamped + 1).clamp(topes.min, topes.max);
      capaFinal = CapaSemana.mais;
      pesoFinal = 0.35;
      final denomMostrado = denomDi > 0 ? denomDi : total;
      expGl =
          'Esta semana, ${_numGl(cupoFinal)} ${cupoFinal == 1 ? 'palabra nova' : 'palabras novas'} para $nome: xa di ${_numGl(ditas)} das ${_numGl(denomMostrado)} anteriores.';
      expEs =
          'Esta semana, ${_numEs(cupoFinal)} ${cupoFinal == 1 ? 'palabra nueva' : 'palabras nuevas'} para $nome: ya dice ${_numEs(ditas)} de las ${_numEs(denomMostrado)} anteriores.';
    } else if (taxaEntende < 0.50) {
      cupoFinal = (cupoClamped - 1).clamp(topes.min, topes.max);
      capaFinal = CapaSemana.apoio;
      pesoFinal = 0.70;
      expGl =
          'Esta semana, ${_numGl(cupoFinal)} ${cupoFinal == 1 ? 'palabra nova' : 'palabras novas'} e máis repaso para $nome: reforzamos as da semana pasada.';
      expEs =
          'Esta semana, ${_numEs(cupoFinal)} ${cupoFinal == 1 ? 'palabra nueva' : 'palabras nuevas'} y más repaso para $nome: reforzamos las de la semana pasada.';
    } else {
      cupoFinal = cupoClamped;
      capaFinal = CapaSemana.nucleo;
      pesoFinal = 0.50;
      expGl =
          'Esta semana, ${_numGl(cupoFinal)} ${cupoFinal == 1 ? 'palabra nova' : 'palabras novas'} para $nome: mantemos o ritmo da semana pasada.';
      expEs =
          'Esta semana, ${_numEs(cupoFinal)} ${cupoFinal == 1 ? 'palabra nueva' : 'palabras nuevas'} para $nome: mantenemos el ritmo de la semana pasada.';
    }

    return ResultadoAxusteSemanal(
      cupoNovas: cupoFinal,
      pesoRepaso: pesoFinal,
      peldano: peldanoFinal,
      capa: capaFinal,
      taxaEntende: taxaEntende,
      taxaDi: taxaDi,
      consolidando: false,
      senMarcas: false,
      explicacionGl: expGl,
      explicacionEs: expEs,
      novasSemanasBaixas: novasBaixas,
      novasSemanasDiAlto: novasDiAlto >= 2 ? 0 : novasDiAlto,
    );
  }
}
