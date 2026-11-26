import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/localization/app_language.dart';
import '../../core/localization/localized_string.dart';
import 'criancas_store.dart';

@immutable
class DescricionPeldano {
  const DescricionPeldano({
    required this.nivel,
    required this.comprension,
    required this.titulo,
  });

  final int nivel;
  final bool comprension;
  final LocalizedString titulo;

  factory DescricionPeldano.fromJson(Map<String, dynamic> j) =>
      DescricionPeldano(
        nivel: j['nivel'] is int ? j['nivel'] as int : 1,
        comprension: j['tipo']?.toString() == 'comprension',
        titulo: LocalizedString.fromJson(j['titulo']),
      );
}

@immutable
class ItemProba {
  const ItemProba({
    required this.id,
    required this.peldano,
    required this.steamId,
    required this.steamTitulo,
    required this.experimentoParte,
    required this.en,
    required this.enSignificado,
    required this.instrucion,
    required this.obxectoCasa,
    required this.lamina,
    required this.palabrasSemente,
  });

  final String id;
  final int peldano;
  final String steamId;
  final LocalizedString steamTitulo;
  final LocalizedString experimentoParte;
  final String en;
  final LocalizedString enSignificado;
  final LocalizedString instrucion;
  final LocalizedString obxectoCasa;
  final String lamina;
  final List<String> palabrasSemente;

  bool get esExpresion => peldano >= 4;

  bool contaAcerto(Observacion o) => esExpresion
      ? o == Observacion.di
      : (o == Observacion.entende || o == Observacion.di);

  factory ItemProba.fromJson(Map<String, dynamic> j) => ItemProba(
        id: j['id']?.toString() ?? '',
        peldano: j['peldano'] is int ? j['peldano'] as int : 1,
        steamId: j['steamId']?.toString() ?? '',
        steamTitulo: LocalizedString.fromJson(j['steamTitulo']),
        experimentoParte: LocalizedString.fromJson(j['experimentoParte']),
        en: j['en']?.toString() ?? '',
        enSignificado: LocalizedString.fromJson(j['enSignificado']),
        instrucion: LocalizedString.fromJson(j['instrucion']),
        obxectoCasa: LocalizedString.fromJson(j['obxectoCasa']),
        lamina: j['lamina']?.toString() ?? '',
        palabrasSemente: [
          for (final w in (j['palabrasSemente'] as List? ?? const []))
            w.toString(),
        ],
      );
}

@immutable
class ResultadoProbaEntrada {
  const ResultadoProbaEntrada({
    required this.peldano,
    required this.terminada,
    required this.parouPorTresFallos,
    required this.acertosPorPeldano,
    required this.semente,
  });

  final int peldano;
  final bool terminada;
  final bool parouPorTresFallos;
  final Map<int, int> acertosPorPeldano;
  final Map<String, Observacion> semente;
}

class CatalogoProbaEntrada {
  CatalogoProbaEntrada({
    required this.peldanos,
    required this.cursos,
  });

  static const assetPath = 'assets/content/nivel/proba_entrada.json';
  static CatalogoProbaEntrada? _cache;
  static CatalogoProbaEntrada? get lido => _cache;

  static void sembrar(CatalogoProbaEntrada c) => _cache = c;

  final List<DescricionPeldano> peldanos;
  final Map<String, List<ItemProba>> cursos;

  static Future<CatalogoProbaEntrada> cargar({AssetBundle? bundle}) async {
    if (_cache != null && bundle == null) return _cache!;
    final raw = await (bundle ?? rootBundle).loadString(assetPath);
    final cat = fromJsonString(raw);
    if (bundle == null) _cache = cat;
    return cat;
  }

  static CatalogoProbaEntrada fromJsonString(String raw) {
    final doc = json.decode(raw) as Map<String, dynamic>;
    final pels = [
      for (final p in (doc['peldanos'] as List? ?? const []))
        DescricionPeldano.fromJson(p as Map<String, dynamic>),
    ];
    final cursosMap = <String, List<ItemProba>>{};
    final rawCursos = doc['cursos'] as Map<String, dynamic>? ?? const {};
    for (final e in rawCursos.entries) {
      cursosMap[e.key] = List.unmodifiable([
        for (final it in (e.value as List))
          ItemProba.fromJson(it as Map<String, dynamic>),
      ]);
    }
    return CatalogoProbaEntrada(
      peldanos: List.unmodifiable(pels),
      cursos: Map.unmodifiable(cursosMap),
    );
  }

  List<ItemProba> itemsDoCurso(String curso) =>
      cursos[curso] ?? cursos['curso_2_3'] ?? const [];

  DescricionPeldano? descricionDe(int peldano) {
    for (final p in peldanos) {
      if (p.nivel == peldano) return p;
    }
    return null;
  }

  /// True si el niño tiene 2 años o más y aún no completó su prueba de alta.
  static bool debeFacerProba(Crianza c) =>
      c.idade >= 2 && c.curso != 'curso_0_2' && !c.probaCompletada;

  static String textoPeldano(int peldano, AppLanguage lang) {
    final p = peldano.clamp(1, 6);
    final isGl = lang == AppLanguage.gl;
    return switch (p) {
      1 => isGl
          ? 'Paso 1: comprende ordes con xesto'
          : 'Paso 1: comprende órdenes con gesto',
      2 => isGl ? 'Paso 2: sinala obxectos' : 'Paso 2: señala objetos',
      3 =>
        isGl ? 'Paso 3: distingue contrastes' : 'Paso 3: distingue contrastes',
      4 =>
        isGl ? 'Paso 4: di palabras soltas' : 'Paso 4: dice palabras sueltas',
      5 => isGl ? 'Paso 5: xunta dúas palabras' : 'Paso 5: junta dos palabras',
      _ => isGl ? 'Paso 6: di frases curtas' : 'Paso 6: dice frases cortas',
    };
  }

  /// Regla de decisión (P11.3):
  /// - se detiene tras 3 fallos seguidos (`parouPorTresFallos = true`);
  /// - el peldaño de partida es el último con al menos 2 aciertos de 3 (mín. 1);
  /// - lo que entiende o dice entra para sembrar el repaso FSRS.
  static ResultadoProbaEntrada avaliar(
    List<ItemProba> items,
    List<Observacion> respostas,
  ) {
    final acertos = <int, int>{for (var p = 1; p <= 6; p++) p: 0};
    final semente = <String, Observacion>{};
    var fallosSeguidos = 0;
    var parou = false;

    final limite =
        respostas.length < items.length ? respostas.length : items.length;
    for (var i = 0; i < limite; i++) {
      final item = items[i];
      final o = respostas[i];
      if (item.contaAcerto(o)) {
        acertos[item.peldano] = (acertos[item.peldano] ?? 0) + 1;
        fallosSeguidos = 0;
      } else {
        fallosSeguidos++;
      }
      if (o != Observacion.aindaNon) {
        for (final raw in item.palabrasSemente) {
          final w = CriancasStore.claveRepaso(raw);
          if (w.isEmpty) continue;
          final previa = semente[w];
          if (previa == null || o == Observacion.di) {
            semente[w] = o;
          }
        }
      }
      if (fallosSeguidos >= 3) {
        parou = true;
        break;
      }
    }

    var mellorPeldano = 1;
    for (var p = 1; p <= 6; p++) {
      if ((acertos[p] ?? 0) >= 2) {
        mellorPeldano = p;
      }
    }

    return ResultadoProbaEntrada(
      peldano: mellorPeldano,
      terminada: parou || limite >= items.length,
      parouPorTresFallos: parou,
      acertosPorPeldano: Map.unmodifiable(acertos),
      semente: Map.unmodifiable(semente),
    );
  }
}
