import 'package:flutter/foundation.dart';

import '../../core/storage/local_store.dart';

/// Una criatura de la casa, tal como la registra la persona adulta.
@immutable
class Crianza {
  final String id;
  final String nome;

  /// Años cumplidos, de 0 a 6.
  final int idade;

  /// El curso de la app que sigue: `curso_0_2` … `curso_5_6`.
  final String curso;

  const Crianza({
    required this.id,
    required this.nome,
    required this.idade,
    required this.curso,
  });

  Crianza copyWith({String? nome, int? idade, String? curso}) => Crianza(
        id: id,
        nome: nome ?? this.nome,
        idade: idade ?? this.idade,
        curso: curso ?? this.curso,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'nome': nome, 'idade': idade, 'curso': curso};

  static Crianza? fromJson(Object? j) {
    if (j is! Map) return null;
    final id = j['id']?.toString() ?? '';
    final nome = j['nome']?.toString().trim() ?? '';
    final curso = j['curso']?.toString() ?? '';
    final idade = j['idade'] is int ? j['idade'] as int : 0;
    if (id.isEmpty || nome.isEmpty || curso.isEmpty) return null;
    return Crianza(id: id, nome: nome, idade: idade.clamp(0, 6), curso: curso);
  }
}

/// Lo que la persona adulta ha visto de una palabra: aún no, la entiende o
/// la dice. Es su observación, no una prueba ni una evaluación.
enum Observacion { aindaNon, entende, di }

/// Los niños de la casa y lo que la persona adulta ha observado de cada uno.
///
/// **Lo que guarda** (O-20261109-1, decidido por Frank el 9/11/2026), en
/// `criancas.json` de la carpeta privada de la app y en ningún otro sitio:
/// - de cada niño, el nombre que escribió la persona adulta, la edad en años
///   y el curso de la app;
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

  /// El que usa el Portal Familias si no se le pasa otro. Los tests lo
  /// cambian (`test/flutter_test_config.dart`) para entrar con un niño ya
  /// registrado y sin tocar disco.
  static CriancasStore Function() crear = CriancasStore.new;

  /// Ya cargado, en memoria: para los tests.
  CriancasStore.enMemoria(List<Crianza> criancas, {LocalStore? store})
      : _store = store ?? LocalStore(fileName: nomeFicheiro) {
    _criancas.addAll(criancas);
    _cargado = true;
  }

  final LocalStore _store;
  final List<Crianza> _criancas = [];
  String? _activa;

  /// niño → semana (`curso/mes/semana`) → palabra → 1 entiende · 2 dice.
  final Map<String, Map<String, Map<String, int>>> _obs = {};

  bool _cargado = false;
  bool get cargado => _cargado;

  List<Crianza> get criancas => List.unmodifiable(_criancas);

  Crianza? get activa {
    for (final c in _criancas) {
      if (c.id == _activa) return c;
    }
    return _criancas.isEmpty ? null : _criancas.first;
  }

  Future<void> cargar() async {
    final j = await _store.read();
    _criancas.clear();
    _obs.clear();
    if (j != null) {
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
      };

  Future<void> _gardar() async {
    notifyListeners();
    await _store.write(_json());
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
  }) async {
    final c = Crianza(
      id: _novoId(),
      nome: nome.trim(),
      idade: idade.clamp(0, 6),
      curso: curso,
    );
    _criancas.add(c);
    _activa = c.id;
    await _gardar();
    return c;
  }

  Future<void> escoller(String id) async {
    if (!_criancas.any((c) => c.id == id) || id == activa?.id) return;
    _activa = id;
    await _gardar();
  }

  Future<void> actualizar(String id,
      {String? nome, int? idade, String? curso}) async {
    final i = _criancas.indexWhere((c) => c.id == id);
    if (i < 0) return;
    _criancas[i] = _criancas[i].copyWith(
      nome: nome?.trim(),
      idade: idade?.clamp(0, 6),
      curso: curso,
    );
    await _gardar();
  }

  /// Borra el niño y todo lo observado de él.
  Future<void> borrar(String id) async {
    _criancas.removeWhere((c) => c.id == id);
    _obs.remove(id);
    if (_activa == id) _activa = _criancas.isEmpty ? null : _criancas.first.id;
    await _gardar();
  }

  static String semana(String curso, int mes, int semana) =>
      '$curso/$mes/$semana';

  Observacion observacion(String id, String semana, String palabra) =>
      switch (_obs[id]?[semana]?[palabra]) {
        1 => Observacion.entende,
        2 => Observacion.di,
        _ => Observacion.aindaNon,
      };

  Future<void> observar(
      String id, String semana, String palabra, Observacion o) async {
    final porSemana = _obs.putIfAbsent(id, () => {});
    final palabras = porSemana.putIfAbsent(semana, () => {});
    if (o == Observacion.aindaNon) {
      palabras.remove(palabra);
    } else {
      palabras[palabra] = o == Observacion.di ? 2 : 1;
    }
    await _gardar();
  }

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
}
