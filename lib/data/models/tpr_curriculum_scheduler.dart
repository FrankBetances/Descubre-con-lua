import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/localization/app_language.dart';
import '../../core/localization/localized_string.dart';
import 'progresion_model.dart';

/// Una palabra (o frase) inglesa del curso, con su significado y su gesto.
///
/// El inglés es CONTENIDO que la persona adulta escucha y dice, no una lengua
/// de interfaz: por eso [en] no se traduce, y [gl] y [es] son lo que la palabra
/// significa, no una etiqueta.
class TprWord {
  final String id;
  final String en;
  final String gl;
  final String es;

  /// Qué se hace con el cuerpo al decirla. En las dos lenguas: la docente lee
  /// el gesto en la lengua de la app mientras dice la palabra en inglés.
  final LocalizedString tprAction;

  /// `noun`, `verb`, `adjective`, `phrase` o `complex`.
  final String category;

  const TprWord({
    required this.id,
    required this.en,
    required this.gl,
    required this.es,
    required this.tprAction,
    required this.category,
  });

  factory TprWord.fromJson(Map<String, dynamic> json) {
    final accion = json['tprAction'];
    return TprWord(
      id: json['id'] as String,
      en: json['en'] as String,
      gl: json['gl'] as String,
      es: json['es'] as String,
      tprAction: accion is Map
          ? LocalizedString.fromJson(Map<String, dynamic>.from(accion))
          : const LocalizedString(gl: '', es: ''),
      category: json['category'] as String? ?? 'noun',
    );
  }

  /// Lo que la palabra significa, en la lengua en que se lee la app.
  String significado(AppLanguage lang) => lang == AppLanguage.gl ? gl : es;
}

/// Lo que toca un día: las palabras nuevas y las que se repasan.
class DailyTprPlan {
  /// 1 (lunes) a 5 (viernes).
  final int dia;

  /// `A`, `B`, `C` o `D`; vacío el viernes, que no trae palabras nuevas.
  final String bloque;
  final List<TprWord> newWords;
  final List<TprWord> reviewWords;

  const DailyTprPlan({
    required this.dia,
    required this.bloque,
    required this.newWords,
    required this.reviewWords,
  });

  int get totalLoad => newWords.length + reviewWords.length;

  List<TprWord> get allWords => [...newWords, ...reviewWords];

  /// El viernes: cero nuevas y el reto con las veinte de la semana.
  bool get eReto => newWords.isEmpty;
}

/// El reparto de una semana de veinte palabras en cinco días.
///
/// Es el algoritmo del documento del modelo, tal cual: el lunes el bloque A;
/// el martes el B y se repasa el A; el miércoles el C con A y B; el jueves el
/// D con A, B y C; el viernes ninguna nueva y las veinte en repaso. Los
/// bloques salen del ORDEN de las palabras en el JSON: las cinco primeras son
/// el lunes, y así.
class WeeklyTprScheduler {
  static const int palabrasPorDia = 5;
  static const int diasConPalabrasNovas = 4;
  static const int palabrasPorSemana = palabrasPorDia * diasConPalabrasNovas;
  static const List<String> bloques = ['A', 'B', 'C', 'D'];

  /// Los cinco días, de lunes (índice 0) a viernes (índice 4).
  static List<DailyTprPlan> scheduleWeek(List<TprWord> week20Words) {
    if (week20Words.length != palabrasPorSemana) {
      throw ArgumentError(
          'Una semana son $palabrasPorSemana palabras; llegaron ${week20Words.length}.');
    }
    List<TprWord> bloque(int i) =>
        week20Words.sublist(i * palabrasPorDia, (i + 1) * palabrasPorDia);

    return [
      for (var i = 0; i < diasConPalabrasNovas; i++)
        DailyTprPlan(
          dia: i + 1,
          bloque: bloques[i],
          newWords: bloque(i),
          reviewWords: week20Words.sublist(0, i * palabrasPorDia),
        ),
      DailyTprPlan(
        dia: 5,
        bloque: '',
        newWords: const [],
        reviewWords: List.unmodifiable(week20Words),
      ),
    ];
  }
}

/// Una semana del curso: su tema y sus veinte palabras en orden de bloque.
class SemanaTpr {
  final int semana;
  final LocalizedString tema;
  final List<TprWord> palabras;

  const SemanaTpr({
    required this.semana,
    required this.tema,
    required this.palabras,
  });

  factory SemanaTpr.fromJson(Map<String, dynamic> json) => SemanaTpr(
        semana: (json['semana'] as num).toInt(),
        tema: LocalizedString.fromJson(
            Map<String, dynamic>.from(json['tema'] as Map)),
        palabras: List.unmodifiable([
          for (final p in json['palabras'] as List)
            TprWord.fromJson(Map<String, dynamic>.from(p as Map)),
        ]),
      );

  List<DailyTprPlan> get plan => WeeklyTprScheduler.scheduleWeek(palabras);

  /// El plan de un día, de 1 (lunes) a 5 (viernes).
  DailyTprPlan planDoDia(int dia) => plan[(dia.clamp(1, 5)) - 1];
}

/// Un mes del curso: cuatro semanas.
class MesTpr {
  /// 1 es septiembre: el orden del CURSO, no el del calendario.
  final int orden;

  /// 9 es septiembre, 6 es junio: el mes del calendario.
  final int mesCalendario;
  final List<SemanaTpr> semanas;

  const MesTpr({
    required this.orden,
    required this.mesCalendario,
    required this.semanas,
  });

  factory MesTpr.fromJson(Map<String, dynamic> json) => MesTpr(
        orden: (json['orden'] as num).toInt(),
        mesCalendario: (json['mesCalendario'] as num).toInt(),
        semanas: List.unmodifiable([
          for (final s in json['semanas'] as List)
            SemanaTpr.fromJson(Map<String, dynamic>.from(s as Map)),
        ]),
      );

  int get totalPalabras =>
      semanas.fold(0, (total, s) => total + s.palabras.length);

  SemanaTpr? semana(int numero) {
    for (final s in semanas) {
      if (s.semana == numero) return s;
    }
    return null;
  }
}

/// Lo que no cambia de semana a semana: qué se hace cada día.
class DiaDoModeloTpr {
  final int dia;
  final String bloque;
  final LocalizedString dinamica;
  final LocalizedString dinamicaFogar;

  const DiaDoModeloTpr({
    required this.dia,
    required this.bloque,
    required this.dinamica,
    required this.dinamicaFogar,
  });

  factory DiaDoModeloTpr.fromJson(Map<String, dynamic> json) => DiaDoModeloTpr(
        dia: (json['dia'] as num).toInt(),
        bloque: json['bloque'] as String? ?? '',
        dinamica: LocalizedString.fromJson(
            Map<String, dynamic>.from(json['dinamica'] as Map)),
        dinamicaFogar: LocalizedString.fromJson(
            Map<String, dynamic>.from(json['dinamicaFogar'] as Map)),
      );
}

/// El nombre y la descripción de una categoría gramatical.
class CategoriaTpr {
  final String clave;
  final LocalizedString nome;
  final LocalizedString descricion;

  const CategoriaTpr({
    required this.clave,
    required this.nome,
    required this.descricion,
  });

  factory CategoriaTpr.fromJson(Map<String, dynamic> json) => CategoriaTpr(
        clave: json['clave'] as String,
        nome: LocalizedString.fromJson(
            Map<String, dynamic>.from(json['nome'] as Map)),
        descricion: LocalizedString.fromJson(
            Map<String, dynamic>.from(json['descricion'] as Map)),
      );
}

/// Un curso del trayecto tal como lo declara el modelo: su id, su etiqueta de
/// edad y los diez ficheros de mes.
class CursoDoModeloTpr {
  final String id;
  final LocalizedString etiqueta;
  final List<String> meses;

  const CursoDoModeloTpr({
    required this.id,
    required this.etiqueta,
    required this.meses,
  });

  factory CursoDoModeloTpr.fromJson(Map<String, dynamic> json) =>
      CursoDoModeloTpr(
        id: json['id'] as String,
        etiqueta: LocalizedString.fromJson(
            Map<String, dynamic>.from(json['etiqueta'] as Map)),
        meses: List.unmodifiable(
            (json['meses'] as List? ?? const []).map((e) => e.toString())),
      );
}

/// El modelo: el ritmo, los cinco días, las categorías y los cinco cursos.
class ModeloTpr {
  final int ritmoDiario;

  /// De 0-2 a 5-6 años, en orden.
  final List<CursoDoModeloTpr> cursos;
  final List<DiaDoModeloTpr> dias;
  final List<CategoriaTpr> categorias;

  /// De dónde sale la ORDEN de las categorías, y qué no sale de ahí.
  final LocalizedString fontes;

  const ModeloTpr({
    required this.ritmoDiario,
    required this.cursos,
    required this.dias,
    required this.categorias,
    required this.fontes,
  });

  factory ModeloTpr.fromJson(Map<String, dynamic> json) => ModeloTpr(
        ritmoDiario: (json['ritmoDiario'] as num?)?.toInt() ?? 5,
        cursos: List.unmodifiable([
          for (final c in json['cursos'] as List? ?? const [])
            CursoDoModeloTpr.fromJson(Map<String, dynamic>.from(c as Map)),
        ]),
        dias: List.unmodifiable([
          for (final d in json['dias'] as List? ?? const [])
            DiaDoModeloTpr.fromJson(Map<String, dynamic>.from(d as Map)),
        ]),
        categorias: List.unmodifiable([
          for (final c in json['categorias'] as List? ?? const [])
            CategoriaTpr.fromJson(Map<String, dynamic>.from(c as Map)),
        ]),
        fontes: LocalizedString.fromJson(
            Map<String, dynamic>.from(json['fontes'] as Map? ?? const {})),
      );

  DiaDoModeloTpr? dia(int numero) {
    for (final d in dias) {
      if (d.dia == numero) return d;
    }
    return null;
  }
}

/// El día del curso al que apunta una fecha: mes, semana (1-4) y día (1-5).
typedef DiaDoCursoTpr = ({int mesCalendario, int semana, int dia});

/// El inglés de UN curso: los diez meses de un grupo de edad.
///
/// Aquí no hay ni una palabra: si algo de esta clase se puede leer en
/// pantalla, viene del JSON. Y los totales —20 por semana, 80 por mes, 800
/// por curso, el reparto por categorías— se CUENTAN, no se escriben, para que
/// no puedan discrepar de lo que el curso trae.
class CursoTpr {
  static const String modeloAsset = 'assets/content/tpr/modelo.json';

  /// `curso_0_2` … `curso_5_6`.
  final String id;
  final LocalizedString etiqueta;
  final ModeloTpr modelo;

  /// De septiembre a junio.
  final List<MesTpr> meses;

  const CursoTpr({
    required this.id,
    required this.etiqueta,
    required this.modelo,
    required this.meses,
  });

  MesTpr? mes(int mesCalendario) {
    for (final m in meses) {
      if (m.mesCalendario == mesCalendario) return m;
    }
    return null;
  }

  SemanaTpr? semana(int mesCalendario, int semana) =>
      mes(mesCalendario)?.semana(semana);

  DailyTprPlan? planDoDia(int mesCalendario, int semana, int dia) =>
      this.semana(mesCalendario, semana)?.planDoDia(dia);

  int get totalPalabras => meses.fold(0, (t, m) => t + m.totalPalabras);

  /// Cuántas palabras hay de cada categoría, contadas en el contenido.
  Map<String, int> get porCategoria {
    final cuenta = <String, int>{};
    for (final m in meses) {
      for (final s in m.semanas) {
        for (final p in s.palabras) {
          cuenta[p.category] = (cuenta[p.category] ?? 0) + 1;
        }
      }
    }
    return cuenta;
  }

  /// Las palabras de los meses del calendario que se pidan (un trimestre).
  int palabrasEnMeses(Iterable<int> mesesCalendario) {
    final pedidos = mesesCalendario.toSet();
    return meses
        .where((m) => pedidos.contains(m.mesCalendario))
        .fold(0, (t, m) => t + m.totalPalabras);
  }

  /// El día que toca hoy, o `null` en julio y agosto, que no son del curso.
  ///
  /// La semana y el día salen de [ProgresionDoMes.hoxe], la MISMA regla que la
  /// asamblea del día: si cada tarjeta calculara el día a su manera, la
  /// palabra de «hoxe» y la asamblea de «hoxe» podrían no ser del mismo día.
  static DiaDoCursoTpr? hoxe({DateTime? agora}) {
    final d = agora ?? DateTime.now();
    if (d.month == 7 || d.month == 8) return null;
    final h = ProgresionDoMes.hoxe(agora: d);
    return (mesCalendario: d.month, semana: h.semana, dia: h.dia);
  }
}

/// El grupo del aula y el curso de inglés que le corresponde.
///
/// 1.º ciclo: 0-2 y 2-3. 2.º ciclo: 4.º es 3-4 años, 5.º es 4-5 y 6.º es 5-6.
/// Si cada pantalla hiciera su propia cuenta, la docente de 5.º podría ver en
/// el calendario las palabras de un curso y en la tarjeta de hoy las de otro.
///
/// La clave es la del grupo de la asamblea (`GrupoDaAsemblea.clave`).
const Map<String, String> cursoTprDoGrupo = {
  '1c_0_2': 'curso_0_2',
  '1c_2_3': 'curso_2_3',
  '2c_4_infantil': 'curso_3_4',
  '2c_5_infantil': 'curso_4_5',
  '2c_6_infantil': 'curso_5_6',
};

/// El trayecto entero: el modelo y los cinco cursos, de 0-2 a 5-6 años.
///
/// Sale de `assets/content/tpr/`. Cinco palabras nuevas al día en cada curso:
/// 800 por curso y 4.000 en el trayecto, sin repetir ninguna.
class ProgramaTpr {
  final ModeloTpr modelo;

  /// De 0-2 a 5-6 años, en el orden del modelo.
  final List<CursoTpr> cursos;

  const ProgramaTpr({required this.modelo, required this.cursos});

  static Future<ProgramaTpr> cargar({
    Future<String> Function(String path)? stringLoader,
  }) async {
    final ler = stringLoader ?? rootBundle.loadString;
    final modelo = ModeloTpr.fromJson(Map<String, dynamic>.from(
        jsonDecode(await ler(CursoTpr.modeloAsset)) as Map));
    final cursos = <CursoTpr>[];
    for (final c in modelo.cursos) {
      final meses = <MesTpr>[
        for (final ruta in c.meses)
          MesTpr.fromJson(
              Map<String, dynamic>.from(jsonDecode(await ler(ruta)) as Map)),
      ]..sort((a, b) => a.orden.compareTo(b.orden));
      cursos.add(CursoTpr(
        id: c.id,
        etiqueta: c.etiqueta,
        modelo: modelo,
        meses: List.unmodifiable(meses),
      ));
    }
    return ProgramaTpr(modelo: modelo, cursos: List.unmodifiable(cursos));
  }

  /// El curso con ese id, o `null` si el modelo no lo trae.
  CursoTpr? curso(String id) {
    for (final c in cursos) {
      if (c.id == id) return c;
    }
    return null;
  }

  int get totalPalabras => cursos.fold(0, (t, c) => t + c.totalPalabras);

  /// Cuántas palabras hay de cada categoría en todo el trayecto.
  Map<String, int> get porCategoria {
    final cuenta = <String, int>{};
    for (final c in cursos) {
      c.porCategoria.forEach((k, v) => cuenta[k] = (cuenta[k] ?? 0) + v);
    }
    return cuenta;
  }
}
