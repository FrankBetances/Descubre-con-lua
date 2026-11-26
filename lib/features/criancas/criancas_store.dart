import 'package:flutter/foundation.dart';

import '../../core/fsrs_service.dart';
import '../../core/storage/local_store.dart';
import '../../data/models/fsrs_card_model.dart';
import 'axuste_semanal.dart';
import 'xogo_lua.dart';

/// Un niño o niña de la casa, tal como lo registra la persona adulta.
@immutable
class Crianza {
  final String id;
  final String nome;

  /// Años cumplidos, de 0 a 6.
  final int idade;

  /// Mes de nacimiento (1..12), opcional, sin día.
  final int? mesNacemento;

  /// Año de nacimiento (AAAA), opcional, sin día.
  final int? anoNacemento;

  /// Año del último septiembre en que la familia respondió a la propuesta
  /// de pasar al curso siguiente (evita volver a preguntar ese año).
  final int? promocionVistaAno;

  /// El curso de la app que sigue: `curso_0_2` … `curso_5_6`.
  final String curso;

  /// Una o dos rutinas de casa elegidas en el alta (M2):
  /// `bano`, `comida`, `coche`, `vestirse`, `durmir`, `parque`.
  final List<String> rutinas;

  /// Número de semanas del curso con alguna marca de la persona adulta (M1).
  final int semanasConMarcas;

  /// Última semana del curso con alguna marca (`curso_x_y/mes/semana`, sin fecha).
  final String? ultimaSemanaMarca;

  /// Semana del curso en que se registró (`curso_x_y/mes/semana`, sin fecha).
  final String? semanaAlta;

  /// Peldaño de inicio/progresión dentro de su curso (1..6, P11.3/P11.4).
  final int peldano;

  /// Si ya se completó o saltó el juego de entrada de Lúa (ALTA P11.3).
  final bool probaCompletada;

  /// Respuestas guardadas si la prueba de entrada se interrumpió a mitad (0..2).
  final List<int> probaRespostas;

  /// Cupo semanal de palabras nuevas (P11.4), opcional (null = base del curso).
  final int? cupo;

  /// Semanas seguidas por debajo del 30 % de comprensión y de >=80 % dicho (P11.4).
  final int semanasBaixas;
  final int semanasDiAlto;

  static const List<String> rutinasValidas = [
    'bano',
    'comida',
    'coche',
    'vestirse',
    'durmir',
    'parque',
  ];

  const Crianza({
    required this.id,
    required this.nome,
    required this.idade,
    required this.curso,
    this.mesNacemento,
    this.anoNacemento,
    this.promocionVistaAno,
    this.rutinas = const ['bano'],
    this.semanasConMarcas = 0,
    this.ultimaSemanaMarca,
    this.semanaAlta,
    this.peldano = 1,
    this.probaCompletada = true,
    this.probaRespostas = const [],
    this.cupo,
    this.semanasBaixas = 0,
    this.semanasDiAlto = 0,
  });

  /// Años cumplidos en [agora] a partir de [mesNacemento] y [anoNacemento] si
  /// existen; si no, [idade].
  int idadeEn(DateTime agora) {
    final ano = anoNacemento;
    final mes = mesNacemento;
    if (ano == null || mes == null) return idade;
    var anos = agora.year - ano;
    if (agora.month < mes) anos--;
    return anos.clamp(0, 6);
  }

  /// Meses de edad en [agora] cuando hay mes y año de nacimiento.
  int? mesesEn(DateTime agora) {
    final ano = anoNacemento;
    final mes = mesNacemento;
    if (ano == null || mes == null) return null;
    final m = (agora.year - ano) * 12 + (agora.month - mes);
    return m < 0 ? 0 : m;
  }

  Crianza copyWith({
    String? nome,
    int? idade,
    String? curso,
    int? mesNacemento,
    int? anoNacemento,
    int? promocionVistaAno,
    List<String>? rutinas,
    int? semanasConMarcas,
    String? ultimaSemanaMarca,
    String? semanaAlta,
    int? peldano,
    bool? probaCompletada,
    List<int>? probaRespostas,
    int? cupo,
    int? semanasBaixas,
    int? semanasDiAlto,
  }) =>
      Crianza(
        id: id,
        nome: nome ?? this.nome,
        idade: idade ?? this.idade,
        curso: curso ?? this.curso,
        mesNacemento: mesNacemento ?? this.mesNacemento,
        anoNacemento: anoNacemento ?? this.anoNacemento,
        promocionVistaAno: promocionVistaAno ?? this.promocionVistaAno,
        rutinas: rutinas ?? this.rutinas,
        semanasConMarcas: semanasConMarcas ?? this.semanasConMarcas,
        ultimaSemanaMarca: ultimaSemanaMarca ?? this.ultimaSemanaMarca,
        semanaAlta: semanaAlta ?? this.semanaAlta,
        peldano: (peldano ?? this.peldano).clamp(1, 6),
        probaCompletada: probaCompletada ?? this.probaCompletada,
        probaRespostas: probaRespostas ?? this.probaRespostas,
        cupo: cupo ?? this.cupo,
        semanasBaixas: semanasBaixas ?? this.semanasBaixas,
        semanasDiAlto: semanasDiAlto ?? this.semanasDiAlto,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'idade': idade,
        'curso': curso,
        if (mesNacemento != null) 'mesNacemento': mesNacemento,
        if (anoNacemento != null) 'anoNacemento': anoNacemento,
        if (promocionVistaAno != null) 'promocionVistaAno': promocionVistaAno,
        'rutinas': rutinas,
        if (semanasConMarcas > 0) 'semanasConMarcas': semanasConMarcas,
        if (ultimaSemanaMarca != null) 'ultimaSemanaMarca': ultimaSemanaMarca,
        if (semanaAlta != null) 'semanaAlta': semanaAlta,
        if (peldano != 1) 'peldano': peldano,
        if (!probaCompletada) 'probaCompletada': false,
        if (probaRespostas.isNotEmpty) 'probaRespostas': probaRespostas,
        if (cupo != null) 'cupo': cupo,
        if (semanasBaixas > 0) 'semanasBaixas': semanasBaixas,
        if (semanasDiAlto > 0) 'semanasDiAlto': semanasDiAlto,
      };

  static List<String> normalizarRutinas(Iterable<String> orixe) {
    final validas = [
      for (final r in orixe)
        if (rutinasValidas.contains(r)) r,
    ].take(2).toList(growable: false);
    return validas.isEmpty ? const ['bano'] : List.unmodifiable(validas);
  }

  static Crianza? fromJson(Object? j) {
    if (j is! Map) return null;
    final id = j['id']?.toString() ?? '';
    final nome = j['nome']?.toString().trim() ?? '';
    final curso = j['curso']?.toString() ?? '';
    final idade = j['idade'] is int ? j['idade'] as int : 0;
    final mes = j['mesNacemento'] is int ? j['mesNacemento'] as int : null;
    final ano = j['anoNacemento'] is int ? j['anoNacemento'] as int : null;
    final prom =
        j['promocionVistaAno'] is int ? j['promocionVistaAno'] as int : null;
    final rRaw = j['rutinas'] is List
        ? [for (final x in j['rutinas'] as List) x.toString()]
        : const <String>[];
    final semMarcas =
        j['semanasConMarcas'] is int ? j['semanasConMarcas'] as int : 0;
    final ultSem = j['ultimaSemanaMarca']?.toString();
    final semAlta = j['semanaAlta']?.toString();
    final pel = j['peldano'] is int ? j['peldano'] as int : 1;
    final comp =
        j['probaCompletada'] is bool ? j['probaCompletada'] as bool : true;
    final respRaw = j['probaRespostas'] is List
        ? [
            for (final x in j['probaRespostas'] as List)
              if (x is int && x >= 0 && x <= 2) x,
          ]
        : const <int>[];
    final cupo = j['cupo'] is int ? j['cupo'] as int : null;
    final baixas = j['semanasBaixas'] is int ? j['semanasBaixas'] as int : 0;
    final diAlto = j['semanasDiAlto'] is int ? j['semanasDiAlto'] as int : 0;
    if (id.isEmpty || nome.isEmpty || curso.isEmpty) return null;
    return Crianza(
      id: id,
      nome: nome,
      idade: idade.clamp(0, 6),
      curso: curso,
      mesNacemento: mes == null ? null : mes.clamp(1, 12),
      anoNacemento: ano,
      promocionVistaAno: prom,
      rutinas: normalizarRutinas(rRaw),
      semanasConMarcas: semMarcas < 0 ? 0 : semMarcas,
      ultimaSemanaMarca: ultSem,
      semanaAlta: semAlta,
      peldano: pel.clamp(1, 6),
      probaCompletada: comp,
      probaRespostas: List.unmodifiable(respRaw),
      cupo: cupo,
      semanasBaixas: baixas < 0 ? 0 : baixas,
      semanasDiAlto: diAlto < 0 ? 0 : diAlto,
    );
  }
}

/// Lo que la persona adulta ha visto de una palabra: aún no, la entiende o
/// la dice. Es su observación, no una prueba ni una evaluación.
enum Observacion { aindaNon, entende, di }

/// Los niños de la casa y lo que la persona adulta ha observado de cada uno.
///
/// **Lo que guarda** (O-20261109-1, decidido por Frank el 9/11/2026; D3,
/// 26/11/2026), en `criancas.json` de la carpeta privada de la app y en ningún
/// otro sitio:
/// - de cada niño, el nombre que escribió la persona adulta, la edad en años,
///   el mes y año de nacimiento (sin día), el año de la última revisión de
///   curso de septiembre y el curso de la app;
/// - qué niño se vio el último, para no volver a preguntarlo;
/// - por semana del curso (`curso/mes/semana`, sin fecha ni hora), qué
///   palabras inglesas la persona adulta marcó como «la entiende» o «la dice».
///
/// No sale del móvil: el APK no tiene permiso de INTERNET. Lo vigila
/// `test/core/criancas_privacidad_test.dart`, que falla si aparece una clave
/// nueva o una hora.
class CriancasStore extends ChangeNotifier {
  CriancasStore({LocalStore? store})
      : _store = store ?? LocalStore(fileName: nomeFicheiro);

  static const nomeFicheiro = 'criancas.json';

  static const List<String> cursosOrde = [
    'curso_0_2',
    'curso_2_3',
    'curso_3_4',
    'curso_4_5',
    'curso_5_6',
  ];

  static String cursoParaIdade(int idade) => switch (idade) {
        0 || 1 => 'curso_0_2',
        2 => 'curso_2_3',
        3 => 'curso_3_4',
        4 => 'curso_4_5',
        _ => 'curso_5_6',
      };

  static String? seguinteCurso(String curso) {
    final i = cursosOrde.indexOf(curso);
    if (i < 0 || i + 1 >= cursosOrde.length) return null;
    return cursosOrde[i + 1];
  }

  /// El que usa el Portal Familias si no se le pasa otro. Los tests lo
  /// cambian (`test/flutter_test_config.dart`) para entrar con un niño ya
  /// registrado y sin tocar disco.
  static CriancasStore Function() crear = CriancasStore.new;

  /// Ya cargado, en memoria: para los tests.
  CriancasStore.enMemoria(List<Crianza> criancas, {LocalStore? store})
      : _store = store {
    _criancas.addAll(criancas);
    _cargado = true;
  }

  final LocalStore? _store;
  final List<Crianza> _criancas = [];
  String? _activa;

  /// niño → semana (`curso/mes/semana`) → palabra → 1 entiende · 2 dice.
  final Map<String, Map<String, Map<String, int>>> _obs = {};

  /// niño → su juego con Lúa (O-20261109-3): XP, racha, insignias y armario.
  final Map<String, XogoLua> _xogo = {};

  /// niño → palabra normalizada → tarjeta FSRS de ese niño (sin hora).
  final Map<String, Map<String, FSRSCard>> _repaso = {};
  final Map<String, int> _repasoSeguinteId = {};
  final FsrsService _fsrs = const FsrsService();

  /// niño → palabra normalizada → número de veces que la ha oído/marcado (M4).
  final Map<String, Map<String, int>> _escoitas = {};

  /// niño → semana (`curso/mes/semana`) → estado semanal P11.4 (sin fecha).
  final Map<String, Map<String, RexistroAxusteSemanal>> _axustes = {};

  bool _cargado = false;
  bool get cargado => _cargado;

  List<Crianza> get criancas => List.unmodifiable(_criancas);

  Crianza? get activa {
    for (final c in _criancas) {
      if (c.id == _activa) return c;
    }
    return _criancas.isEmpty ? null : _criancas.first;
  }

  static String claveRepaso(String palabra) => palabra.trim().toLowerCase();

  static DateTime _soloDia(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> cargar() async {
    final store = _store;
    if (store == null) {
      _cargado = true;
      notifyListeners();
      return;
    }
    final j = await store.read();
    _criancas.clear();
    _obs.clear();
    _xogo.clear();
    _repaso.clear();
    _repasoSeguinteId.clear();
    _escoitas.clear();
    _axustes.clear();
    if (j != null) {
      if (j['xogo'] case final Map x) {
        for (final e in x.entries) {
          _xogo[e.key.toString()] = XogoLua.fromJson(e.value);
        }
      }
      for (final c in (j['criancas'] as List? ?? const [])) {
        final cr = Crianza.fromJson(c);
        if (cr != null) _criancas.add(cr);
      }
      _activa = j['activa']?.toString();
      final o = j['observacions'];
      if (o is Map) {
        for (final porNeno in o.entries) {
          final semanas = <String, Map<String, int>>{};
          if (porNeno.value is! Map) continue;
          for (final s in (porNeno.value as Map).entries) {
            if (s.value is! Map) continue;
            semanas[s.key.toString()] = {
              for (final p in (s.value as Map).entries)
                if (p.value == 1 || p.value == 2)
                  p.key.toString(): p.value as int,
            };
          }
          _obs[porNeno.key.toString()] = semanas;
        }
      }
      final r = j['repaso'];
      if (r is Map) {
        for (final porNeno in r.entries) {
          if (porNeno.value is! Map) continue;
          final nid = porNeno.key.toString();
          final tarjetas = <String, FSRSCard>{};
          var maxId = 0;
          for (final entry in (porNeno.value as Map).entries) {
            if (entry.value is! Map) continue;
            final card = FSRSCard.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
            );
            tarjetas[claveRepaso(entry.key.toString())] = card;
            if (card.id > maxId) maxId = card.id;
          }
          _repaso[nid] = tarjetas;
          _repasoSeguinteId[nid] = maxId + 1;
        }
      }
      final es = j['escoitas'];
      if (es is Map) {
        for (final porNeno in es.entries) {
          if (porNeno.value is! Map) continue;
          _escoitas[porNeno.key.toString()] = {
            for (final p in (porNeno.value as Map).entries)
              if (p.value is int && (p.value as int) > 0)
                claveRepaso(p.key.toString()): p.value as int,
          };
        }
      }
      final ax = j['axustes'];
      if (ax is Map) {
        for (final porNeno in ax.entries) {
          if (porNeno.value is! Map) continue;
          final sems = <String, RexistroAxusteSemanal>{};
          for (final e in (porNeno.value as Map).entries) {
            final reg = RexistroAxusteSemanal.fromJson(e.value);
            if (reg != null) sems[e.key.toString()] = reg;
          }
          _axustes[porNeno.key.toString()] = sems;
        }
      }
    }
    _cargado = true;
    notifyListeners();
  }

  Map<String, dynamic> _json() => {
        'criancas': [for (final c in _criancas) c.toJson()],
        if (activa != null) 'activa': activa!.id,
        'observacions': {
          for (final e in _obs.entries)
            if (_criancas.any((c) => c.id == e.key))
              e.key: {
                for (final s in e.value.entries)
                  if (s.value.isNotEmpty) s.key: s.value,
              },
        },
        'xogo': {
          for (final e in _xogo.entries)
            if (_criancas.any((c) => c.id == e.key)) e.key: e.value.toJson(),
        },
        'repaso': {
          for (final e in _repaso.entries)
            if (_criancas.any((c) => c.id == e.key) && e.value.isNotEmpty)
              e.key: {
                for (final c in e.value.entries) c.key: c.value.toJson(),
              },
        },
        'escoitas': {
          for (final e in _escoitas.entries)
            if (_criancas.any((c) => c.id == e.key) && e.value.isNotEmpty)
              e.key: e.value,
        },
        if (_axustes.values.any((m) => m.isNotEmpty))
          'axustes': {
            for (final e in _axustes.entries)
              if (_criancas.any((c) => c.id == e.key) && e.value.isNotEmpty)
                e.key: {
                  for (final s in e.value.entries) s.key: s.value.toJson(),
                },
          },
      };

  Future<void> _gardar() async {
    notifyListeners();
    await _store?.write(_json());
  }

  String _novoId() {
    var n = _criancas.length + 1;
    while (_criancas.any((c) => c.id == 'c$n')) {
      n++;
    }
    return 'c$n';
  }

  Future<Crianza> engadir({
    required String nome,
    required int idade,
    required String curso,
    int? mesNacemento,
    int? anoNacemento,
    int? promocionVistaAno,
    List<String>? rutinas,
    String? semanaAlta,
    bool? probaCompletada,
  }) async {
    final comp = probaCompletada ?? (idade < 2 || curso == 'curso_0_2');
    final c = Crianza(
      id: _novoId(),
      nome: nome.trim(),
      idade: idade.clamp(0, 6),
      curso: curso,
      mesNacemento: mesNacemento?.clamp(1, 12),
      anoNacemento: anoNacemento,
      promocionVistaAno: promocionVistaAno,
      rutinas: Crianza.normalizarRutinas(rutinas ?? const ['bano']),
      semanaAlta: semanaAlta,
      probaCompletada: comp,
    );
    _criancas.add(c);
    _activa = c.id;
    await _gardar();
    return c;
  }

  /// Guarda una respuesta incremental de la prueba de entrada para poder
  /// reanudarla si se interrumpe (Alta única, corrección 26/11/2026).
  Future<void> gardarRespostaProba(
    String id,
    Observacion obs, {
    Iterable<String> palabrasSemente = const [],
    DateTime? agora,
  }) async {
    final i = _criancas.indexWhere((c) => c.id == id);
    if (i < 0) return;
    final c = _criancas[i];
    if (c.probaCompletada) return;
    final novas = List<int>.unmodifiable([...c.probaRespostas, obs.index]);
    _criancas[i] = c.copyWith(probaRespostas: novas);
    if (obs != Observacion.aindaNon && palabrasSemente.isNotEmpty) {
      final dia = _soloDia(agora ?? DateTime.now());
      for (final raw in palabrasSemente) {
        final w = raw.trim();
        if (w.isEmpty) continue;
        final mapa = _repaso.putIfAbsent(id, () => {});
        if (!mapa.containsKey(claveRepaso(w))) {
          _actualizarTarxeta(id, w, obs, dia);
        }
      }
    }
    await _gardar();
  }

  /// Cierra la prueba de entrada, fija el peldaño de partida y siembra el repaso.
  Future<void> completarProba(
    String id, {
    required int peldano,
    Map<String, Observacion> semente = const {},
    DateTime? agora,
  }) async {
    final i = _criancas.indexWhere((c) => c.id == id);
    if (i < 0) return;
    final c = _criancas[i];
    _criancas[i] = c.copyWith(
      peldano: peldano.clamp(1, 6),
      probaCompletada: true,
      probaRespostas: const [],
    );
    final dia = _soloDia(agora ?? DateTime.now());
    final mapa = _repaso.putIfAbsent(id, () => {});
    for (final e in semente.entries) {
      if (e.value == Observacion.aindaNon) continue;
      final clave = claveRepaso(e.key);
      if (clave.isEmpty || mapa.containsKey(clave)) continue;
      _actualizarTarxeta(id, e.key, e.value, dia);
    }
    await _gardar();
  }

  Future<void> escoller(String id) async {
    if (!_criancas.any((c) => c.id == id) || id == activa?.id) return;
    _activa = id;
    await _gardar();
  }

  Future<void> actualizar(
    String id, {
    String? nome,
    int? idade,
    String? curso,
    int? mesNacemento,
    int? anoNacemento,
    int? promocionVistaAno,
    List<String>? rutinas,
  }) async {
    final i = _criancas.indexWhere((c) => c.id == id);
    if (i < 0) return;
    _criancas[i] = _criancas[i].copyWith(
      nome: nome?.trim(),
      idade: idade?.clamp(0, 6),
      curso: curso,
      mesNacemento: mesNacemento?.clamp(1, 12),
      anoNacemento: anoNacemento,
      promocionVistaAno: promocionVistaAno,
      rutinas: rutinas == null ? null : Crianza.normalizarRutinas(rutinas),
    );
    await _gardar();
  }

  /// En septiembre propone pasar al curso siguiente si por mes y año de
  /// nacimiento le corresponde un curso superior al actual y no se ha
  /// respondido ya este año.
  String? cursoPropostoEnSetembro(Crianza c, DateTime agora) {
    if (agora.month != 9) return null;
    if (c.promocionVistaAno == agora.year) return null;
    if (c.mesNacemento == null || c.anoNacemento == null) return null;
    final prox = seguinteCurso(c.curso);
    if (prox == null) return null;
    final esperado = cursoParaIdade(c.idadeEn(agora));
    if (cursosOrde.indexOf(esperado) > cursosOrde.indexOf(c.curso)) {
      return prox;
    }
    return null;
  }

  Future<void> responderPromocionSetembro(
    String id, {
    required int ano,
    required bool aceptar,
    DateTime? agora,
  }) async {
    final i = _criancas.indexWhere((c) => c.id == id);
    if (i < 0) return;
    final c = _criancas[i];
    final prox = aceptar ? seguinteCurso(c.curso) : null;
    _criancas[i] = c.copyWith(
      curso: prox ?? c.curso,
      idade: c.idadeEn(agora ?? DateTime(ano, 9)),
      promocionVistaAno: ano,
    );
    await _gardar();
  }

  /// Borra el niño y todo lo observado de él.
  Future<void> borrar(String id) async {
    _criancas.removeWhere((c) => c.id == id);
    _obs.remove(id);
    _xogo.remove(id);
    _repaso.remove(id);
    _repasoSeguinteId.remove(id);
    _escoitas.remove(id);
    _axustes.remove(id);
    if (_activa == id) _activa = _criancas.isEmpty ? null : _criancas.first.id;
    await _gardar();
  }

  static String semana(String curso, int mes, int semana) =>
      '$curso/$mes/$semana';

  static const List<int> _mesesCurso = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6];

  /// Semana escolar anterior dentro de [curso] (`curso/mes/semana`), o `null`
  /// si está en la semana 1 de septiembre.
  static String? semanaAnterior(String curso, int mes, int sem) {
    final idxMes = _mesesCurso.indexOf(mes);
    if (idxMes < 0) return null;
    if (sem > 1) return semana(curso, mes, sem - 1);
    if (idxMes == 0) return null;
    return semana(curso, _mesesCurso[idxMes - 1], 4);
  }

  /// Palabras distintas marcadas como «la dice» para [id] (M5).
  List<String> palabrasDitas(String id) {
    final mapa = _obs[id];
    if (mapa == null || mapa.isEmpty) return const [];
    final vistas = <String>{};
    final out = <String>[];
    for (final s in mapa.values) {
      for (final p in s.entries) {
        if (p.value == 2 && vistas.add(claveRepaso(p.key))) {
          out.add(p.key);
        }
      }
    }
    return List.unmodifiable(out);
  }

  Map<String, Observacion> marcasDaSemana(String id, String semanaKey) {
    final m = _obs[id]?[semanaKey];
    if (m == null || m.isEmpty) return const {};
    return {
      for (final e in m.entries)
        e.key: e.value == 2 ? Observacion.di : Observacion.entende,
    };
  }

  RexistroAxusteSemanal? axusteSemanalDe(String id, String semanaKey) =>
      _axustes[id]?[semanaKey];

  ResultadoAxusteSemanal calcularAxustePara(
    String id, {
    required int mesCalendario,
    required int semana,
    DateTime? agora,
  }) {
    final c = _criancas.where((x) => x.id == id).firstOrNull;
    if (c == null) {
      return const ResultadoAxusteSemanal(
        cupoNovas: 3,
        pesoRepaso: 0.5,
        peldano: 1,
        capa: CapaSemana.nucleo,
        taxaEntende: 0.0,
        taxaDi: 0.0,
        consolidando: false,
        senMarcas: true,
        explicacionGl: '',
        explicacionEs: '',
        novasSemanasBaixas: 0,
        novasSemanasDiAlto: 0,
      );
    }
    final prevKey = semanaAnterior(c.curso, mesCalendario, semana);
    final marcasPrev = prevKey == null
        ? const <String, Observacion>{}
        : marcasDaSemana(id, prevKey);
    final topes = AxusteSemanal.topesDe(c.curso);
    return AxusteSemanal.calcular(
      nome: c.nome,
      curso: c.curso,
      peldanoActual: c.peldano,
      cupoActual: c.cupo ?? topes.base,
      marcasSemanaAnterior: marcasPrev,
      escoitasPorPalabra: _escoitas[id] ?? const {},
      semanasBaixasSeguidas: c.semanasBaixas,
      semanasDiAltoSeguidas: c.semanasDiAlto,
      vencidas: tarxetasVencidas(id, agora: agora).length,
    );
  }

  /// Recalcula y persiste en `criancas.json` el ajuste semanal del lunes (P11.4).
  Future<ResultadoAxusteSemanal?> rexistrarAxusteSemanal(
    String id, {
    required int mesCalendario,
    required int semana,
    DateTime? agora,
    bool forzarRecalculo = false,
  }) async {
    final i = _criancas.indexWhere((x) => x.id == id);
    if (i < 0) return null;
    final c = _criancas[i];
    final key = CriancasStore.semana(c.curso, mesCalendario, semana);
    final res = calcularAxustePara(
      id,
      mesCalendario: mesCalendario,
      semana: semana,
      agora: agora,
    );
    final previa = _axustes[id]?[key];
    if (previa != null && !forzarRecalculo) {
      return res;
    }
    _axustes.putIfAbsent(id, () => {})[key] = res.rexistro;
    _criancas[i] = c.copyWith(
      cupo: res.cupoNovas > 0
          ? res.cupoNovas
          : (c.cupo ?? AxusteSemanal.topesDe(c.curso).min),
      peldano: res.peldano,
      semanasBaixas: res.novasSemanasBaixas,
      semanasDiAlto: res.novasSemanasDiAlto,
    );
    await _gardar();
    return res;
  }

  /// Índice 0..39 dentro del curso escolar a partir de `'curso_x_y/mes/semana'`.
  static int indiceSemanaCurso(String? semanaKey) {
    if (semanaKey == null) return -1;
    final partes = semanaKey.split('/');
    if (partes.length != 3) return -1;
    final mes = int.tryParse(partes[1]);
    final sem = int.tryParse(partes[2]);
    if (mes == null || sem == null) return -1;
    final idxMes = _mesesCurso.indexOf(mes);
    if (idxMes < 0) return -1;
    return idxMes * 4 + (sem.clamp(1, 4) - 1);
  }

  /// Cuántas semanas lleva este niño sin marcas desde la última marca o desde su alta.
  int semanasSenMarcas(
    String id, {
    required int mesCalendario,
    required int semana,
  }) {
    final i = _criancas.indexWhere((c) => c.id == id);
    if (i < 0) return 0;
    final c = _criancas[i];
    final ref = c.ultimaSemanaMarca ?? c.semanaAlta;
    if (ref == null) return 0;
    final actual = indiceSemanaCurso('${c.curso}/$mesCalendario/$semana');
    final previa = indiceSemanaCurso(ref);
    if (actual < 0 || previa < 0 || actual <= previa) return 0;
    return actual - previa;
  }

  int escoitasDe(String id, String palabra) =>
      _escoitas[id]?[claveRepaso(palabra)] ?? 0;

  void _incrementarEscoita(String id, String palabra) {
    final clave = claveRepaso(palabra);
    if (clave.isEmpty) return;
    final mapa = _escoitas.putIfAbsent(id, () => {});
    mapa[clave] = (mapa[clave] ?? 0) + 1;
  }

  Future<void> rexistrarEscoita(String id, String palabra) async {
    _incrementarEscoita(id, palabra);
    await _gardar();
  }

  void _marcarSemana(String id, String? semanaKey) {
    if (semanaKey == null) return;
    final i = _criancas.indexWhere((c) => c.id == id);
    if (i < 0) return;
    final c = _criancas[i];
    if (c.ultimaSemanaMarca == semanaKey) return;
    _criancas[i] = c.copyWith(
      semanasConMarcas: c.semanasConMarcas + 1,
      ultimaSemanaMarca: semanaKey,
    );
  }

  Observacion observacion(String id, String semana, String palabra) =>
      switch (_obs[id]?[semana]?[palabra]) {
        1 => Observacion.entende,
        2 => Observacion.di,
        _ => Observacion.aindaNon,
      };

  static int ratingParaObservacion(Observacion o) => switch (o) {
        Observacion.di => 3,
        Observacion.entende => 2,
        Observacion.aindaNon => 1,
      };

  FSRSCard _asegurarTarxeta(String id, String palabra, DateTime dia) {
    final clave = claveRepaso(palabra);
    final mapa = _repaso.putIfAbsent(id, () => {});
    final existente = mapa[clave];
    if (existente != null) return existente;
    final nextId = _repasoSeguinteId[id] ?? 1;
    _repasoSeguinteId[id] = nextId + 1;
    final creada = FSRSCard.initial(
      id: nextId,
      lemma: palabra.trim(),
      now: dia,
    );
    mapa[clave] = creada;
    return creada;
  }

  void _actualizarTarxeta(
    String id,
    String palabra,
    Observacion o,
    DateTime dia,
  ) {
    final clave = claveRepaso(palabra);
    final actual = _asegurarTarxeta(id, palabra, dia);
    _repaso.putIfAbsent(id, () => {})[clave] = _fsrs.repeat(
      card: actual,
      rating: ratingParaObservacion(o),
      now: dia,
    );
  }

  Future<void> observar(
    String id,
    String semana,
    String palabra,
    Observacion o, {
    DateTime? agora,
  }) async {
    final porSemana = _obs.putIfAbsent(id, () => {});
    final palabras = porSemana.putIfAbsent(semana, () => {});
    if (o == Observacion.aindaNon) {
      palabras.remove(palabra);
    } else {
      palabras[palabra] = o == Observacion.di ? 2 : 1;
    }
    _actualizarTarxeta(id, palabra, o, _soloDia(agora ?? DateTime.now()));
    _incrementarEscoita(id, palabra);
    _marcarSemana(id, semana);
    await _gardar();
  }

  /// Marca una palabra desde «Volven hoxe / Vuelven hoy» y actualiza su FSRS.
  Future<void> repasar(
    String id,
    String palabra,
    Observacion o, {
    String? semana,
    DateTime? agora,
  }) async {
    final dia = _soloDia(agora ?? DateTime.now());
    _actualizarTarxeta(id, palabra, o, dia);
    _incrementarEscoita(id, palabra);
    if (semana != null) {
      final porSemana = _obs.putIfAbsent(id, () => {});
      final palabras = porSemana.putIfAbsent(semana, () => {});
      if (o == Observacion.aindaNon) {
        palabras.remove(palabra);
      } else {
        palabras[palabra] = o == Observacion.di ? 2 : 1;
      }
      _marcarSemana(id, semana);
    }
    await _gardar();
  }

  /// Siembra tarjetas FSRS para un niño (por ejemplo tras la prueba de entrada
  /// o desde lecciones pasadas). No pisa tarjetas ya repasadas salvo que se pida.
  Future<void> sembrarRepaso(
    String id,
    Iterable<String> palabras, {
    DateTime? agora,
    Observacion nivel = Observacion.di,
    bool vencidasHoxe = false,
  }) async {
    final dia = _soloDia(agora ?? DateTime.now());
    final mapa = _repaso.putIfAbsent(id, () => {});
    var mudou = false;
    for (final raw in palabras) {
      final palabra = raw.trim();
      if (palabra.isEmpty) continue;
      final clave = claveRepaso(palabra);
      if (mapa.containsKey(clave)) continue;
      final tarxeta = _asegurarTarxeta(id, palabra, dia);
      mapa[clave] = vencidasHoxe
          ? tarxeta.copyWith(lastReviewDate: dia, nextDueDate: dia)
          : _fsrs.repeat(
              card: tarxeta,
              rating: ratingParaObservacion(nivel),
              now: dia,
            );
      mudou = true;
    }
    if (mudou) await _gardar();
  }

  Map<String, FSRSCard> tarxetasDe(String id) =>
      Map.unmodifiable(_repaso[id] ?? const {});

  FSRSCard? tarxetaDe(String id, String palabra) =>
      _repaso[id]?[claveRepaso(palabra)];

  List<FSRSCard> tarxetasVencidas(
    String id, {
    DateTime? agora,
    Set<String> excluir = const {},
  }) {
    final mapa = _repaso[id];
    if (mapa == null || mapa.isEmpty) return const [];
    final hoxe = _soloDia(agora ?? DateTime.now());
    final excl = {for (final w in excluir) claveRepaso(w)};
    final lista = [
      for (final e in mapa.entries)
        if (!excl.contains(e.key) &&
            !_soloDia(e.value.nextDueDate).isAfter(hoxe))
          e.value,
    ];
    lista.sort((a, b) {
      final cmpDate =
          _soloDia(a.nextDueDate).compareTo(_soloDia(b.nextDueDate));
      if (cmpDate != 0) return cmpDate;
      final cmpStab = a.stability.compareTo(b.stability);
      if (cmpStab != 0) return cmpStab;
      return a.id.compareTo(b.id);
    });
    return lista;
  }

  List<FSRSCard> volvenHoxe(
    String id, {
    DateTime? agora,
    Set<String> excluir = const {},
    int maximo = 4,
  }) =>
      tarxetasVencidas(id, agora: agora, excluir: excluir)
          .take(maximo)
          .toList(growable: false);

  bool haiMoitasVencidas(
    String id, {
    DateTime? agora,
    Set<String> excluir = const {},
  }) =>
      tarxetasVencidas(id, agora: agora, excluir: excluir).length > 6;

  /// Las semanas con alguna observación, en el orden del curso, y cuántas
  /// palabras entiende y dice en cada una.
  List<({String semana, int entende, int di})> evolucion(String id) {
    final c = _criancas.where((c) => c.id == id).firstOrNull;
    if (c == null) return const [];
    int orden(String s) {
      final p = s.split('/');
      if (p.length != 3) return 0;
      final mes = int.tryParse(p[1]) ?? 0;
      final mesCurso = mes >= 9 ? mes - 9 : mes + 3;
      return mesCurso * 10 + (int.tryParse(p[2]) ?? 0);
    }

    final semanas = (_obs[id] ?? const <String, Map<String, int>>{})
        .entries
        .where((e) => e.key.startsWith('${c.curso}/') && e.value.isNotEmpty)
        .toList()
      ..sort((a, b) => orden(a.key).compareTo(orden(b.key)));
    return [
      for (final e in semanas)
        (
          semana: e.key,
          entende: e.value.values.where((v) => v == 1).length,
          di: e.value.values.where((v) => v == 2).length,
        ),
    ];
  }

  /// Palabras distintas que entiende (o dice) y que dice, en todo lo
  /// observado. Una palabra que dice cuenta también como entendida.
  ({int entende, int di}) totais(String id) {
    final mellor = <String, int>{};
    for (final s in (_obs[id] ?? const <String, Map<String, int>>{}).values) {
      for (final p in s.entries) {
        if (p.value > (mellor[p.key] ?? 0)) mellor[p.key] = p.value;
      }
    }
    return (
      entende: mellor.length,
      di: mellor.values.where((v) => v == 2).length,
    );
  }

  // ── El juego con Lúa ──────────────────────────────────────────────────

  XogoLua xogo(String id) => _xogo[id] ?? const XogoLua();

  /// El juego del día, hecho: la persona adulta lo marca en nombre del niño.
  /// Cuentan las palabras nuevas de [semana] que ya marcó como «la entiende»
  /// (2) o «la dice» (3), sobre las [palabrasDaSemana] de la lección.
  Future<RecompensaLua> xogarHoxe(
    String id,
    CatalogoLua c, {
    required DateTime agora,
    required String semana,
    required List<String> palabrasDaSemana,
  }) async {
    final marcas = _obs[id]?[semana] ?? const <String, int>{};
    final vistas = [
      for (final p in palabrasDaSemana)
        if (marcas[p] != null) marcas[p]! + 1,
    ];
    final media =
        vistas.isEmpty ? 0.0 : vistas.reduce((a, b) => a + b) / vistas.length;
    final perfecta = palabrasDaSemana.isNotEmpty &&
        palabrasDaSemana.every((p) => marcas[p] == 2);
    final r = rexistrarSesion(
      xogo(id),
      c,
      agora: agora,
      palabras: vistas.length,
      media: media,
      perfecta: perfecta,
    );
    _xogo[id] = r.xogo;
    await _gardar();
    return r.recompensa;
  }

  Future<void> acariciar(String id) async {
    final g = xogo(id);
    _xogo[id] = g.copyWith(caricias: g.caricias + 1);
    await _gardar();
  }

  Future<void> darPeixe(String id, DateTime agora) async {
    _xogo[id] = xogo(id).copyWith(comeu: XogoLua.dia(agora));
    await _gardar();
  }

  /// Pone (o quita, si ya lo lleva) un accesorio desbloqueado.
  Future<void> porObxecto(String id, ObxectoLua o) async {
    final g = xogo(id);
    if (!g.obxectos.contains(o.id)) return;
    _xogo[id] = switch (o.slot) {
      'head' => g.copyWith(cabeza: () => g.cabeza == o.id ? null : o.id),
      'neck' => g.copyWith(pescozo: () => g.pescozo == o.id ? null : o.id),
      _ => g,
    };
    await _gardar();
  }
}
