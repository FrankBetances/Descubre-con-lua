import 'package:flutter/foundation.dart';
import '../../core/localization/localized_string.dart';

/// Pedagogical strategy for classroom teachers and families.
///
/// Ported from `.studio_ref/src/data/estrategiasPedagogicasData.ts`.
@immutable
class EstrategiaPedagogica {
  final String id;
  final String clave;
  final LocalizedString nome;
  final LocalizedString subtitulo;
  final LocalizedString baseNeurobioloxica;
  final LocalizedString comoAplicarNaAula;
  final LocalizedString exemploDialogoAula;
  final LocalizedString erroComunAEvitar;
  final LocalizedString consignaDocente;

  const EstrategiaPedagogica({
    required this.id,
    required this.clave,
    required this.nome,
    required this.subtitulo,
    required this.baseNeurobioloxica,
    required this.comoAplicarNaAula,
    required this.exemploDialogoAula,
    required this.erroComunAEvitar,
    required this.consignaDocente,
  });

  factory EstrategiaPedagogica.fromJson(Map<String, dynamic> json) {
    return EstrategiaPedagogica(
      id: json['id']?.toString().trim() ?? '',
      clave: json['clave']?.toString().trim() ?? '',
      nome: LocalizedString.fromJson(
        json['nome'] as Map<String, dynamic>? ??
            json['nombre'] as Map<String, dynamic>? ??
            json['titulo'] as Map<String, dynamic>? ??
            const {},
      ),
      subtitulo: LocalizedString.fromJson(
        json['subtitulo'] as Map<String, dynamic>? ?? const {},
      ),
      baseNeurobioloxica: LocalizedString.fromJson(
        json['baseNeurobioloxica'] as Map<String, dynamic>? ??
            json['base_neurobioloxica'] as Map<String, dynamic>? ??
            json['base_neurobiologica'] as Map<String, dynamic>? ??
            const {},
      ),
      comoAplicarNaAula: LocalizedString.fromJson(
        json['comoAplicarNaAula'] as Map<String, dynamic>? ??
            json['como_aplicar_na_aula'] as Map<String, dynamic>? ??
            const {},
      ),
      exemploDialogoAula: LocalizedString.fromJson(
        json['exemploDialogoAula'] as Map<String, dynamic>? ??
            json['exemplo_dialogo_aula'] as Map<String, dynamic>? ??
            json['ejemplo_dialogo_aula'] as Map<String, dynamic>? ??
            const {},
      ),
      erroComunAEvitar: LocalizedString.fromJson(
        json['erroComunAEvitar'] as Map<String, dynamic>? ??
            json['erro_comun_a_evitar'] as Map<String, dynamic>? ??
            json['error_comun_a_evitar'] as Map<String, dynamic>? ??
            const {},
      ),
      consignaDocente: LocalizedString.fromJson(
        json['consignaDocente'] as Map<String, dynamic>? ??
            json['consigna_docente'] as Map<String, dynamic>? ??
            const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clave': clave,
        'nome': nome.toJson(),
        'subtitulo': subtitulo.toJson(),
        'baseNeurobioloxica': baseNeurobioloxica.toJson(),
        'comoAplicarNaAula': comoAplicarNaAula.toJson(),
        'exemploDialogoAula': exemploDialogoAula.toJson(),
        'erroComunAEvitar': erroComunAEvitar.toJson(),
        'consignaDocente': consignaDocente.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EstrategiaPedagogica &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clave == other.clave &&
          nome == other.nome &&
          subtitulo == other.subtitulo &&
          baseNeurobioloxica == other.baseNeurobioloxica &&
          comoAplicarNaAula == other.comoAplicarNaAula &&
          exemploDialogoAula == other.exemploDialogoAula &&
          erroComunAEvitar == other.erroComunAEvitar &&
          consignaDocente == other.consignaDocente;

  @override
  int get hashCode => Object.hash(
        id,
        clave,
        nome,
        subtitulo,
        baseNeurobioloxica,
        comoAplicarNaAula,
        exemploDialogoAula,
        erroComunAEvitar,
        consignaDocente,
      );

  @override
  String toString() => 'EstrategiaPedagogica($clave, $nome)';
}
