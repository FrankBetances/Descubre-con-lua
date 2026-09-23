import '../../../core/localization/app_language.dart';

/// Modelo inmutable de palabra/comando TPR.
class TprWord {
  final String id;
  final String en;
  final String gl;
  final String es;
  final String tprAction;
  final String category; // 'noun', 'verb', 'adjective', 'phrase', 'question'

  const TprWord({
    required this.id,
    required this.en,
    required this.gl,
    required this.es,
    required this.tprAction,
    required this.category,
  });

  factory TprWord.fromJson(Map<String, dynamic> json) {
    return TprWord(
      id: json['id'] as String,
      en: json['en'] as String,
      gl: json['gl'] as String,
      es: json['es'] as String,
      tprAction: json['tprAction'] as String,
      category: json['category'] as String? ?? 'noun',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'en': en,
        'gl': gl,
        'es': es,
        'tprAction': tprAction,
        'category': category,
      };

  String palabraEn(AppLanguage lang) => lang == AppLanguage.gl ? gl : es;
}

/// Plan diario con refuerzo acumulativo.
class DailyTprPlan {
  final String dayName;
  final List<TprWord> newWords;
  final List<TprWord> reviewWords;
  final String tprDynamic;

  const DailyTprPlan({
    required this.dayName,
    required this.newWords,
    required this.reviewWords,
    required this.tprDynamic,
  });

  int get totalLoad => newWords.length + reviewWords.length;

  List<TprWord> get allWords => [...newWords, ...reviewWords];
}

/// Planificador semanal TPR (20 palabras / semana).
class WeeklyTprScheduler {
  /// Planificador en castellano conforme a la especificación nativa.
  static Map<String, DailyTprPlan> scheduleWeek(List<TprWord> week20Words) {
    if (week20Words.length < 20) {
      throw ArgumentError('Se requieren al menos 20 palabras.');
    }

    final blockA = week20Words.sublist(0, 5);
    final blockB = week20Words.sublist(5, 10);
    final blockC = week20Words.sublist(10, 15);
    final blockD = week20Words.sublist(15, 20);

    return {
      'Lunes': DailyTprPlan(
        dayName: 'Lunes',
        newWords: blockA,
        reviewWords: const [],
        tprDynamic: 'Presentación motriz directa con modelado docente.',
      ),
      'Martes': DailyTprPlan(
        dayName: 'Martes',
        newWords: blockB,
        reviewWords: blockA,
        tprDynamic: 'Contraste motriz: 5 nuevas + juego rápido con Bloque A.',
      ),
      'Miércoles': DailyTprPlan(
        dayName: 'Miércoles',
        newWords: blockC,
        reviewWords: [...blockA, ...blockB],
        tprDynamic: 'Circuito TPR encadenando Bloque C con comandos A y B.',
      ),
      'Jueves': DailyTprPlan(
        dayName: 'Jueves',
        newWords: blockD,
        reviewWords: [...blockA, ...blockB, ...blockC],
        tprDynamic: 'Cuento motor integrado combinando las 20 palabras.',
      ),
      'Viernes': DailyTprPlan(
        dayName: 'Viernes',
        newWords: const [],
        reviewWords: week20Words.sublist(0, 20),
        tprDynamic: '¡GRAN RETO TPR ACUMULATIVO!: Juegos de inhibición (Freeze).',
      ),
    };
  }

  /// Planificador bilingüe adaptable a la lengua de la interfaz (Galego / Castelán).
  static Map<String, DailyTprPlan> scheduleWeekBilingual(
    List<TprWord> week20Words,
    AppLanguage language,
  ) {
    if (week20Words.length < 20) {
      throw ArgumentError('Se requieren al menos 20 palabras.');
    }
    final isGl = language == AppLanguage.gl;

    final blockA = week20Words.sublist(0, 5);
    final blockB = week20Words.sublist(5, 10);
    final blockC = week20Words.sublist(10, 15);
    final blockD = week20Words.sublist(15, 20);

    if (isGl) {
      return {
        'Luns': DailyTprPlan(
          dayName: 'Luns',
          newWords: blockA,
          reviewWords: const [],
          tprDynamic: 'Presentación motriz directa con modelado docente.',
        ),
        'Martes': DailyTprPlan(
          dayName: 'Martes',
          newWords: blockB,
          reviewWords: blockA,
          tprDynamic: 'Contraste motriz: 5 novas + xogo rápido con Bloque A.',
        ),
        'Mércores': DailyTprPlan(
          dayName: 'Mércores',
          newWords: blockC,
          reviewWords: [...blockA, ...blockB],
          tprDynamic: 'Circuíto TPR encadeando Bloque C con comandos A e B.',
        ),
        'Xoves': DailyTprPlan(
          dayName: 'Xoves',
          newWords: blockD,
          reviewWords: [...blockA, ...blockB, ...blockC],
          tprDynamic: 'Conto motor integrado combinando as 20 palabras.',
        ),
        'Venres': DailyTprPlan(
          dayName: 'Venres',
          newWords: const [],
          reviewWords: week20Words.sublist(0, 20),
          tprDynamic: '¡GRAN RETO TPR ACUMULATIVO!: Xogos de inhibición (Freeze).',
        ),
      };
    }

    return scheduleWeek(week20Words);
  }
}

/// Contenedor de unidad semanal TPR con metadatos.
class TprSemanaContenido {
  final String unidadId;
  final int ritmoDiario;
  final int totalSemana;
  final String metodo;
  final List<TprWord> palabras;

  const TprSemanaContenido({
    required this.unidadId,
    required this.ritmoDiario,
    required this.totalSemana,
    required this.metodo,
    required this.palabras,
  });

  factory TprSemanaContenido.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    final palabrasList = (json['palabras'] as List<dynamic>? ?? [])
        .map((p) => TprWord.fromJson(Map<String, dynamic>.from(p as Map)))
        .toList();

    return TprSemanaContenido(
      unidadId: json['unidadId'] as String? ?? 'semana_default',
      ritmoDiario: meta['ritmoDiario'] as int? ?? 5,
      totalSemana: meta['totalSemana'] as int? ?? 20,
      metodo: meta['metodo'] as String? ?? 'refuerzo_acumulativo',
      palabras: palabrasList,
    );
  }

  Map<String, DailyTprPlan> getPlanSemanal([AppLanguage lang = AppLanguage.gl]) {
    if (palabras.length >= 20) {
      return WeeklyTprScheduler.scheduleWeekBilingual(palabras, lang);
    }
    return {};
  }

  DailyTprPlan? getPlanParaDia(int diaSemanaNumero, [AppLanguage lang = AppLanguage.gl]) {
    final plan = getPlanSemanal(lang);
    if (plan.isEmpty) return null;
    final plans = plan.values.toList();
    if (diaSemanaNumero >= 1 && diaSemanaNumero <= plans.length) {
      return plans[diaSemanaNumero - 1];
    }
    return null;
  }
}
