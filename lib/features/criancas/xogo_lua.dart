import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/brand/pixel_award.dart';
import '../../core/localization/localized_string.dart';

/// Los premios de Lúa, copiados de Valeria (O-20261109-3): 12 niveles de 100
/// XP, 18 insignias en familias con rango y 5 coleccionables. Los gana EL
/// NIÑO (decisión de Frank, 9/11/2026); la persona adulta actúa en su nombre
/// marcando el juego del día y lo que entiende o dice.
///
/// Fuente: FrankBetances/Valeria:src/valeriaGamification.ts y
/// src/types/valeriaLua.ts. El catálogo y sus textos viven en
/// `assets/content/premios/premios_lua.json` (tools/port_premios_valeria.py).
class CatalogoLua {
  final int xpPorNivel;
  final List<LocalizedString> niveis;
  final List<InsigniaLua> insignias;
  final List<ObxectoLua> obxectos;
  final Map<String, LocalizedString> textos;
  final Map<String, LocalizedString> humor;

  const CatalogoLua({
    required this.xpPorNivel,
    required this.niveis,
    required this.insignias,
    required this.obxectos,
    required this.textos,
    required this.humor,
  });

  static const assetPath = 'assets/content/premios/premios_lua.json';
  static CatalogoLua? _lido;
  static Future<CatalogoLua>? _enCurso;
  static CatalogoLua? get lido => _lido;

  static Future<CatalogoLua> cargar() => _enCurso ??=
      rootBundle.loadString(assetPath).then((r) => _lido = fromRaw(r));

  @visibleForTesting
  static void sembrar(CatalogoLua c) {
    _lido = c;
    _enCurso = SynchronousFuture(c);
  }

  static LocalizedString _t(Object? v) => LocalizedString.fromJson(
      Map<String, dynamic>.from(v is Map ? v : const {}));

  static CatalogoLua fromRaw(String raw) {
    final j = json.decode(raw) as Map<String, dynamic>;
    return CatalogoLua(
      xpPorNivel: j['xpPorNivel'] as int? ?? 100,
      niveis: [for (final n in j['niveis'] as List) _t(n)],
      insignias: [
        for (final i in j['insignias'] as List)
          InsigniaLua(
            id: i['id'] as String,
            glyph: AwardGlyph.desdeClave(i['glyph'] as String),
            tier: AwardTier.desdeClave(i['tier'] as String),
            nome: _t(i['nome']),
            di: _t(i['di']),
          ),
      ],
      obxectos: [
        for (final o in j['obxectos'] as List)
          ObxectoLua(
            id: o['id'] as String,
            slot: o['slot'] as String,
            require: o['require'] as String,
            n: o['n'] as int,
            nome: _t(o['nome']),
            condicion: _t(o['condicion']),
          ),
      ],
      textos: {
        for (final e in (j['textos'] as Map).entries)
          e.key.toString(): _t(e.value),
      },
      humor: {
        for (final e in (j['humor'] as Map).entries)
          e.key.toString(): _t(e.value),
      },
    );
  }

  int nivel(int xp) => xp ~/ xpPorNivel + 1;
  int get nivelMaximo => niveis.length;
  double progreso(int xp) => (xp % xpPorNivel) / xpPorNivel;
  int xpParaSeguinte(int xp) => xpPorNivel - (xp % xpPorNivel);
  LocalizedString nomeNivel(int nivel) =>
      niveis[(nivel - 1).clamp(0, niveis.length - 1)];
  ObxectoLua? obxecto(String id) =>
      obxectos.where((o) => o.id == id).firstOrNull;
  InsigniaLua? insignia(String id) =>
      insignias.where((i) => i.id == id).firstOrNull;
}

@immutable
class InsigniaLua {
  final String id;
  final AwardGlyph glyph;
  final AwardTier tier;
  final LocalizedString nome;
  final LocalizedString di;
  const InsigniaLua({
    required this.id,
    required this.glyph,
    required this.tier,
    required this.nome,
    required this.di,
  });
}

@immutable
class ObxectoLua {
  final String id;

  /// `head`, `neck` o `snack`.
  final String slot;

  /// `sesions`, `racha` o `nivel`.
  final String require;
  final int n;
  final LocalizedString nome;
  final LocalizedString condicion;
  const ObxectoLua({
    required this.id,
    required this.slot,
    required this.require,
    required this.n,
    required this.nome,
    required this.condicion,
  });
}

/// El juego de un niño: lo que en Valeria es `GameState` más el inventario
/// de Lúa. Fechas en día (`aaaa-mm-dd`), nunca con hora.
@immutable
class XogoLua {
  final int xp;
  final int racha;
  final int mellorRacha;
  final String ultimoDia;
  final int sesions;
  final int perfectas;
  final List<String> insignias;
  final List<String> obxectos;
  final String? cabeza;
  final String? pescozo;
  final int caricias;

  /// Último día en que Lúa comió el pescadito. En Valeria era la hora exacta;
  /// aquí el día, porque no se guarda ninguna hora: tiene antojo si no ha
  /// comido hoy.
  final String comeu;

  const XogoLua({
    this.xp = 0,
    this.racha = 0,
    this.mellorRacha = 0,
    this.ultimoDia = '',
    this.sesions = 0,
    this.perfectas = 0,
    this.insignias = const [],
    this.obxectos = const ['snack_fish'],
    this.cabeza,
    this.pescozo,
    this.caricias = 0,
    this.comeu = '',
  });

  static const claves = {
    'xp',
    'racha',
    'mellorRacha',
    'ultimoDia',
    'sesions',
    'perfectas',
    'insignias',
    'obxectos',
    'cabeza',
    'pescozo',
    'caricias',
    'comeu',
  };

  Map<String, dynamic> toJson() => {
        'xp': xp,
        'racha': racha,
        'mellorRacha': mellorRacha,
        'ultimoDia': ultimoDia,
        'sesions': sesions,
        'perfectas': perfectas,
        'insignias': insignias,
        'obxectos': obxectos,
        if (cabeza != null) 'cabeza': cabeza,
        if (pescozo != null) 'pescozo': pescozo,
        'caricias': caricias,
        'comeu': comeu,
      };

  static XogoLua fromJson(Object? v) {
    if (v is! Map) return const XogoLua();
    int n(String k) => v[k] is int ? v[k] as int : 0;
    String s(String k) => v[k] is String ? v[k] as String : '';
    List<String> l(String k, List<String> d) =>
        v[k] is List ? [for (final x in v[k] as List) x.toString()] : d;
    return XogoLua(
      xp: n('xp'),
      racha: n('racha'),
      mellorRacha: n('mellorRacha'),
      ultimoDia: s('ultimoDia'),
      sesions: n('sesions'),
      perfectas: n('perfectas'),
      insignias: l('insignias', const []),
      obxectos: l('obxectos', const ['snack_fish']),
      cabeza: v['cabeza'] is String ? v['cabeza'] as String : null,
      pescozo: v['pescozo'] is String ? v['pescozo'] as String : null,
      caricias: n('caricias'),
      comeu: s('comeu'),
    );
  }

  XogoLua copyWith({
    int? xp,
    int? racha,
    int? mellorRacha,
    String? ultimoDia,
    int? sesions,
    int? perfectas,
    List<String>? insignias,
    List<String>? obxectos,
    String? Function()? cabeza,
    String? Function()? pescozo,
    int? caricias,
    String? comeu,
  }) =>
      XogoLua(
        xp: xp ?? this.xp,
        racha: racha ?? this.racha,
        mellorRacha: mellorRacha ?? this.mellorRacha,
        ultimoDia: ultimoDia ?? this.ultimoDia,
        sesions: sesions ?? this.sesions,
        perfectas: perfectas ?? this.perfectas,
        insignias: insignias ?? this.insignias,
        obxectos: obxectos ?? this.obxectos,
        cabeza: cabeza != null ? cabeza() : this.cabeza,
        pescozo: pescozo != null ? pescozo() : this.pescozo,
        caricias: caricias ?? this.caricias,
        comeu: comeu ?? this.comeu,
      );

  static String dia(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Racha viva: si el último día no es hoy ni ayer, la racha visible es 0.
  int rachaViva(DateTime agora) {
    if (ultimoDia.isEmpty) return 0;
    final hoxe = dia(agora);
    final onte = dia(agora.subtract(const Duration(days: 1)));
    return ultimoDia == hoxe || ultimoDia == onte ? racha : 0;
  }

  bool xogouHoxe(DateTime agora) => ultimoDia == dia(agora);

  /// Tiene antojo si tiene pescadito y hoy no ha comido.
  bool antollo(DateTime agora) =>
      obxectos.contains('snack_fish') && comeu != dia(agora);
}

/// Lo que se gana al terminar el juego del día.
@immutable
class RecompensaLua {
  final int xpGanado;
  final int nivel;
  final bool subeNivel;
  final List<InsigniaLua> insigniasNovas;
  final List<ObxectoLua> obxectosNovos;
  final bool xaXogouHoxe;
  const RecompensaLua({
    required this.xpGanado,
    required this.nivel,
    required this.subeNivel,
    required this.insigniasNovas,
    required this.obxectosNovos,
    this.xaXogouHoxe = false,
  });
}

/// La sesión de Valeria (`registerSession`), con las cuentas de aquí:
/// [palabras] son las palabras nuevas de la semana que la persona adulta ha
/// marcado; [media] su valor medio (2 «la entiende», 3 «la dice»), y la
/// sesión es perfecta si todas las de la semana las dice. Una sesión por día:
/// marcar dos veces el mismo día no suma, porque el juego del día es uno.
({XogoLua xogo, RecompensaLua recompensa}) rexistrarSesion(
  XogoLua g,
  CatalogoLua c, {
  required DateTime agora,
  required int palabras,
  required double media,
  required bool perfecta,
}) {
  final hoxe = XogoLua.dia(agora);
  if (g.ultimoDia == hoxe) {
    return (
      xogo: g,
      recompensa: RecompensaLua(
        xpGanado: 0,
        nivel: c.nivel(g.xp),
        subeNivel: false,
        insigniasNovas: const [],
        obxectosNovos: const [],
        xaXogouHoxe: true,
      ),
    );
  }
  final onte = XogoLua.dia(agora.subtract(const Duration(days: 1)));
  final hueco = g.ultimoDia.isEmpty
      ? 0
      : DateTime.parse(hoxe).difference(DateTime.parse(g.ultimoDia)).inDays;
  final racha = g.ultimoDia == onte ? g.racha + 1 : 1;

  // XP como en Valeria: base + precisión + racha + perfecta.
  final xpGanado = 20 +
      palabras * 5 +
      (media * 10).round() +
      (racha < 7 ? racha : 7) * 2 +
      (perfecta ? 15 : 0);
  final xp = g.xp + xpGanado;
  final sesions = g.sesions + 1;
  final perfectas = g.perfectas + (perfecta ? 1 : 0);
  final nivel = c.nivel(xp);

  final insignias = [...g.insignias];
  final novas = <InsigniaLua>[];
  void proba(String id, bool cond) {
    if (!cond || insignias.contains(id)) return;
    insignias.add(id);
    if (c.insignia(id) case final i?) novas.add(i);
  }

  proba('primera', sesions >= 1);
  proba('ses10', sesions >= 10);
  proba('ses25', sesions >= 25);
  proba('ses50', sesions >= 50);
  proba('ses100', sesions >= 100);
  proba('racha3', racha >= 3);
  proba('racha7', racha >= 7);
  proba('racha14', racha >= 14);
  proba('racha30', racha >= 30);
  proba('perfecta', perfecta);
  proba('perf5', perfectas >= 5);
  proba('perf10', perfectas >= 10);
  // La hora se mira en el momento y no se guarda.
  proba('madrugadora', agora.hour < 10);
  proba('nocturna', agora.hour >= 20);
  proba('finde', agora.weekday >= 6);
  proba('maraton', palabras >= 6);
  proba('regreso', hueco >= 7);
  proba('nivel10', nivel >= 10);

  final obxectos = [...g.obxectos];
  final novos = <ObxectoLua>[];
  for (final o in c.obxectos) {
    if (obxectos.contains(o.id)) continue;
    final ok = switch (o.require) {
      'sesions' => sesions >= o.n,
      'racha' => racha >= o.n,
      'nivel' => nivel >= o.n,
      _ => false,
    };
    if (ok) {
      obxectos.add(o.id);
      novos.add(o);
    }
  }

  return (
    xogo: g.copyWith(
      xp: xp,
      racha: racha,
      mellorRacha: racha > g.mellorRacha ? racha : g.mellorRacha,
      ultimoDia: hoxe,
      sesions: sesions,
      perfectas: perfectas,
      insignias: insignias,
      obxectos: obxectos,
    ),
    recompensa: RecompensaLua(
      xpGanado: xpGanado,
      nivel: nivel,
      subeNivel: nivel > c.nivel(g.xp),
      insigniasNovas: novas,
      obxectosNovos: novos,
    ),
  );
}
