import 'package:flutter/foundation.dart';
import '../../core/localization/localized_string.dart';
import 'curricular_model.dart';
import 'unidad_model.dart' show Revision;

/// Niveis educativos do Segundo Ciclo de Educación Infantil (3-6 anos).
///
/// Diferenciación curricular segundo o Decreto 150/2022 de Galicia:
/// - [infantil4]: 4.º de Infantil (3-4 anos)
/// - [infantil5]: 5.º de Infantil (4-5 anos)
/// - [infantil6]: 6.º de Infantil (5-6 anos)
enum NivelEducativoSegundoCiclo {
  infantil4,
  infantil5,
  infantil6;

  /// Clave canónica empregada nos esquemas JSON e assets.
  String get clave => switch (this) {
        NivelEducativoSegundoCiclo.infantil4 => '4_infantil',
        NivelEducativoSegundoCiclo.infantil5 => '5_infantil',
        NivelEducativoSegundoCiclo.infantil6 => '6_infantil',
      };

  /// Tramo de idade en formato curto.
  String get tramoEtario => switch (this) {
        NivelEducativoSegundoCiclo.infantil4 => '3-4',
        NivelEducativoSegundoCiclo.infantil5 => '4-5',
        NivelEducativoSegundoCiclo.infantil6 => '5-6',
      };

  /// Idade mínima en anos cumpridos.
  int get edadMinima => switch (this) {
        NivelEducativoSegundoCiclo.infantil4 => 3,
        NivelEducativoSegundoCiclo.infantil5 => 4,
        NivelEducativoSegundoCiclo.infantil6 => 5,
      };

  /// Idade máxima en anos cumpridos.
  int get edadMaxima => switch (this) {
        NivelEducativoSegundoCiclo.infantil4 => 4,
        NivelEducativoSegundoCiclo.infantil5 => 5,
        NivelEducativoSegundoCiclo.infantil6 => 6,
      };

  /// Etiqueta localizada de alto contraste para a interface do docente.
  LocalizedString get etiqueta => switch (this) {
        NivelEducativoSegundoCiclo.infantil4 => const LocalizedString(
            gl: '4.º de Infantil (3-4 anos)',
            es: '4.º de Infantil (3-4 años)',
            en: '4th Preschool (3-4 years)',
          ),
        NivelEducativoSegundoCiclo.infantil5 => const LocalizedString(
            gl: '5.º de Infantil (4-5 anos)',
            es: '5.º de Infantil (4-5 años)',
            en: '5th Preschool (4-5 years)',
          ),
        NivelEducativoSegundoCiclo.infantil6 => const LocalizedString(
            gl: '6.º de Infantil (5-6 anos)',
            es: '6.º de Infantil (5-6 años)',
            en: '6th Preschool (5-6 years)',
          ),
      };

  /// Metodoloxía pedagóxica TPR asignada de xeito canónico a este nivel.
  MetodologiaTPR get metodologiaPorDefecto => switch (this) {
        NivelEducativoSegundoCiclo.infantil4 => MetodologiaTPR.accionExpandida,
        NivelEducativoSegundoCiclo.infantil5 =>
          MetodologiaTPR.dramatizadoNarrativo,
        NivelEducativoSegundoCiclo.infantil6 =>
          MetodologiaTPR.transaccionalPragmatico,
      };

  /// Parsea un texto no enum correspondente de xeito seguro e tolerante.
  static NivelEducativoSegundoCiclo desdeClave(String? valor) {
    final v = valor?.trim().toLowerCase();
    return switch (v) {
      '4_infantil' || '4' || 'infantil4' || '3-4' =>
        NivelEducativoSegundoCiclo.infantil4,
      '5_infantil' || '5' || 'infantil5' || '4-5' =>
        NivelEducativoSegundoCiclo.infantil5,
      '6_infantil' || '6' || 'infantil6' || '5-6' =>
        NivelEducativoSegundoCiclo.infantil6,
      _ => NivelEducativoSegundoCiclo.infantil4,
    };
  }
}

/// Alias para paridade con nomenclatura internacional.
typedef TPRLevel = NivelEducativoSegundoCiclo;

/// Metodoloxías neurocognitivas de Resposta Física Total (TPR) diferenciadas por nivel.
enum MetodologiaTPR {
  /// 4.º de Infantil (3-4 anos): Comandos de dúas fases unidos por "and",
  /// andamiaxe decrecente con modelado e desvanecemento (fading), e respecto
  /// estrito ao período de silencio fónico (sen esixencia de fala en L3).
  accionExpandida,

  /// 5.º de Infantil (4-5 anos): Micro-narrativas de causa e efecto físico,
  /// xogos de inhibición selectiva ante claves acústicas (Stop-signal / Freeze!),
  /// e praxias orofaciais vinculadas a rimas dactilares.
  dramatizadoNarrativo,

  /// 6.º de Infantil (5-6 anos): Dinámica transaccional e cooperativa entre
  /// iguais (peer-to-peer), uso de tarxetas de apoio icónico sen texto (cue cards),
  /// categorización espacial e resolución cinestésica de problemas.
  transaccionalPragmatico;

  /// Clave canónica empregada nos esquemas JSON.
  String get clave => switch (this) {
        MetodologiaTPR.accionExpandida => 'accion_expandida',
        MetodologiaTPR.dramatizadoNarrativo => 'dramatizado_narrativo',
        MetodologiaTPR.transaccionalPragmatico => 'transaccional_pragmatico',
      };

  /// Nome amigable bilingüe da metodoloxía.
  LocalizedString get nombre => switch (this) {
        MetodologiaTPR.accionExpandida => const LocalizedString(
            gl: 'TPR de Acción Expandida e Modelado',
            es: 'TPR de Acción Expandida y Modelado',
            en: 'Action-Expanded TPR & Modeling',
          ),
        MetodologiaTPR.dramatizadoNarrativo => const LocalizedString(
            gl: 'TPR Dramatizado e Narrativo con Inhibición',
            es: 'TPR Dramatizado y Narrativo con Inhibición',
            en: 'Dramatized & Narrative TPR with Inhibition',
          ),
        MetodologiaTPR.transaccionalPragmatico => const LocalizedString(
            gl: 'TPR Transaccional e Xogos entre Iguais',
            es: 'TPR Transaccional y Juegos entre Iguales',
            en: 'Transactional & Peer-to-Peer TPR',
          ),
      };

  /// Nivel educativo ao que corresponde esta metodoloxía.
  NivelEducativoSegundoCiclo get nivelCorrespondiente => switch (this) {
        MetodologiaTPR.accionExpandida => NivelEducativoSegundoCiclo.infantil4,
        MetodologiaTPR.dramatizadoNarrativo =>
          NivelEducativoSegundoCiclo.infantil5,
        MetodologiaTPR.transaccionalPragmatico =>
          NivelEducativoSegundoCiclo.infantil6,
      };

  /// Indica se a metodoloxía esixe tarxetas icónicas sen texto.
  bool get usaTarjetasIconicas => this == MetodologiaTPR.transaccionalPragmatico;

  /// Indica se a metodoloxía inclúe sinais acústicos de parada inmediata (Freeze).
  bool get usaSenalInhibicion => this == MetodologiaTPR.dramatizadoNarrativo;

  /// Parsea a metodoloxía dende unha cadea JSON.
  static MetodologiaTPR desdeClave(String? valor) {
    final v = valor?.trim().toLowerCase();
    return switch (v) {
      'accion_expandida' ||
      'accionexpandida' =>
        MetodologiaTPR.accionExpandida,
      'dramatizado_narrativo' ||
      'dramatizadonarrativo' =>
        MetodologiaTPR.dramatizadoNarrativo,
      'transaccional_pragmatico' ||
      'transaccionalpragmatico' =>
        MetodologiaTPR.transaccionalPragmatico,
      _ => MetodologiaTPR.accionExpandida,
    };
  }
}

/// As 4 fases rítmicas canónicas dunha sesión de asemblea matinal no Segundo Ciclo (8-10 min).
enum TipoFaseAsamblea {
  /// Fase 1: Apertura e Saúdo (90 segundos = 1:30 min).
  /// Reunión no círculo, contacto visual, ancoraxe afectiva coa mascota Lúa e activación auditiva.
  aperturaSaudo,

  /// Fase 2: Foco Rítmico e Movemento (120 segundos = 2:00 min).
  /// Sincronización motriz rítmica, rimas dactilares, pulso constante e activación proprioceptiva.
  movementRhythmFocus,

  /// Fase 3: Reto Núcleo TPR en L3 (270 segundos = 4:30 min).
  /// Desafío central de movemento e comprensión oral en inglés, graduado segundo o nivel.
  coreTprChallenge,

  /// Fase 4: Calma e Transición (120 segundos = 2:00 min).
  /// Desaceleración psicomotriz, contacto con materiais naturais galegos, respiración e paso a recantos.
  calmaTransicion;

  /// Orde secuencial canónica (1..4).
  int get orden => switch (this) {
        TipoFaseAsamblea.aperturaSaudo => 1,
        TipoFaseAsamblea.movementRhythmFocus => 2,
        TipoFaseAsamblea.coreTprChallenge => 3,
        TipoFaseAsamblea.calmaTransicion => 4,
      };

  /// Clave canónica empregada nos esquemas JSON.
  String get clave => switch (this) {
        TipoFaseAsamblea.aperturaSaudo => 'apertura_saudo',
        TipoFaseAsamblea.movementRhythmFocus => 'movement_rhythm_focus',
        TipoFaseAsamblea.coreTprChallenge => 'core_tpr_challenge',
        TipoFaseAsamblea.calmaTransicion => 'calma_transicion',
      };

  /// Duración canónica exacta en segundos (Total: 90 + 120 + 270 + 120 = 600 segundos / 10 minutos).
  int get duracionCanonicoSegundos => switch (this) {
        TipoFaseAsamblea.aperturaSaudo => 90,
        TipoFaseAsamblea.movementRhythmFocus => 120,
        TipoFaseAsamblea.coreTprChallenge => 270,
        TipoFaseAsamblea.calmaTransicion => 120,
      };

  /// Duración en minutos decimais para visualizacións analíticas.
  double get duracionMinutosDecimal => switch (this) {
        TipoFaseAsamblea.aperturaSaudo => 1.5,
        TipoFaseAsamblea.movementRhythmFocus => 2.0,
        TipoFaseAsamblea.coreTprChallenge => 4.5,
        TipoFaseAsamblea.calmaTransicion => 2.0,
      };

  /// Nome localizado para cabeceiras da pantalla docente.
  LocalizedString get nombre => switch (this) {
        TipoFaseAsamblea.aperturaSaudo => const LocalizedString(
            gl: 'Apertura e Saúdo',
            es: 'Apertura y Saludo',
            en: 'Opening & Greeting',
          ),
        TipoFaseAsamblea.movementRhythmFocus => const LocalizedString(
            gl: 'Foco Rítmico e Movemento',
            es: 'Foco Rítmico y Movimiento',
            en: 'Movement & Rhythmic Focus',
          ),
        TipoFaseAsamblea.coreTprChallenge => const LocalizedString(
            gl: 'Reto Núcleo TPR en L3',
            es: 'Reto Núcleo TPR en L3',
            en: 'Core TPR Challenge',
          ),
        TipoFaseAsamblea.calmaTransicion => const LocalizedString(
            gl: 'Calma e Transición',
            es: 'Calma y Transición',
            en: 'Calm & Transition Out',
          ),
      };

  /// Parsea o tipo de fase dende a súa clave textual.
  static TipoFaseAsamblea desdeClave(String? valor) {
    final v = valor?.trim().toLowerCase();
    return switch (v) {
      'apertura_saudo' || 'aperturasaudo' || 'opening' =>
        TipoFaseAsamblea.aperturaSaudo,
      'movement_rhythm_focus' ||
      'movementrhythmfocus' ||
      'rhythm' =>
        TipoFaseAsamblea.movementRhythmFocus,
      'core_tpr_challenge' ||
      'coretprchallenge' ||
      'tpr' =>
        TipoFaseAsamblea.coreTprChallenge,
      'calma_transicion' || 'calmatransicion' || 'calm' =>
        TipoFaseAsamblea.calmaTransicion,
      _ => TipoFaseAsamblea.aperturaSaudo,
    };
  }

  /// Retorna a fase correspondente polo seu número de orde (1..4).
  static TipoFaseAsamblea porOrden(int orden) => switch (orden) {
        1 => TipoFaseAsamblea.aperturaSaudo,
        2 => TipoFaseAsamblea.movementRhythmFocus,
        3 => TipoFaseAsamblea.coreTprChallenge,
        4 => TipoFaseAsamblea.calmaTransicion,
        _ => TipoFaseAsamblea.aperturaSaudo,
      };
}

/// Comando de Resposta Física Total (TPR) en L3 (inglés) con indicacións motrices e modelado docente.
@immutable
class ComandoTPR {
  /// Identificador único do comando (ex: "tpr.setembro.4i.01").
  final String id;

  /// Texto do comando en L3 (inglés) (ex: "Stand up and clap hands").
  final String textoIngles;

  /// Descrición do movemento corporal esperado dos escolares.
  final LocalizedString accionFisica;

  /// Pauta pedagóxica para a docente (modelado sincrónico, fading ou guía entre iguais).
  final LocalizedString modeladoDocente;

  /// Ruta opcional ao ficheiro de son con pronunciación modelo (LJSpeech · piper).
  final String? audioAsset;

  const ComandoTPR({
    required this.id,
    required this.textoIngles,
    required this.accionFisica,
    required this.modeladoDocente,
    this.audioAsset,
  });

  factory ComandoTPR.fromJson(Map<String, dynamic> json) {
    return ComandoTPR(
      id: json['id']?.toString().trim() ?? '',
      textoIngles: json['textoIngles']?.toString().trim() ??
          json['texto_ingles']?.toString().trim() ??
          '',
      accionFisica: LocalizedString.fromJson(
        (json['accionFisica'] ?? json['accion_fisica'])
                as Map<String, dynamic>? ??
            {},
      ),
      modeladoDocente: LocalizedString.fromJson(
        (json['modeladoDocente'] ?? json['modelado_docente'])
                as Map<String, dynamic>? ??
            {},
      ),
      audioAsset: json['audioAsset']?.toString().trim() ??
          json['audio_asset']?.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'textoIngles': textoIngles,
        'accionFisica': accionFisica.toJson(),
        'modeladoDocente': modeladoDocente.toJson(),
        if (audioAsset != null) 'audioAsset': audioAsset,
      };

  ComandoTPR copyWith({
    String? id,
    String? textoIngles,
    LocalizedString? accionFisica,
    LocalizedString? modeladoDocente,
    String? audioAsset,
  }) {
    return ComandoTPR(
      id: id ?? this.id,
      textoIngles: textoIngles ?? this.textoIngles,
      accionFisica: accionFisica ?? this.accionFisica,
      modeladoDocente: modeladoDocente ?? this.modeladoDocente,
      audioAsset: audioAsset ?? this.audioAsset,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComandoTPR &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          textoIngles == other.textoIngles &&
          accionFisica == other.accionFisica &&
          modeladoDocente == other.modeladoDocente &&
          audioAsset == other.audioAsset;

  @override
  int get hashCode => Object.hash(
        id,
        textoIngles,
        accionFisica,
        modeladoDocente,
        audioAsset,
      );

  @override
  String toString() => 'ComandoTPR(id: "$id", textoIngles: "$textoIngles")';
}

/// Material analóxico non estruturado procedente da contorna natural galega (mimbre, castañas, cunchas, gasas).
@immutable
class MaterialNatural {
  /// Identificador do material (ex: "vimbio_cesto", "castanas_autoctonas").
  final String id;

  /// Nome común bilingüe do material natural.
  final LocalizedString nombre;

  /// Orixe tradicional e sustentabilidade en Galicia (ex: cestería tradicional, soutos do interior, praias da ría).
  final LocalizedString procedencia;

  /// Pauta de exploración sensorial e propiocepción na alfombra.
  final LocalizedString pautaManipulacion;

  /// Aviso de seguridade e dimensións mínimas (ex: tamaño >= 4 cm, sen arestas cortantes).
  final LocalizedString? avisoSeguridad;

  const MaterialNatural({
    required this.id,
    required this.nombre,
    required this.procedencia,
    required this.pautaManipulacion,
    this.avisoSeguridad,
  });

  factory MaterialNatural.fromJson(Map<String, dynamic> json) {
    final rawAviso = json['avisoSeguridad'] ?? json['aviso_seguridad'];
    return MaterialNatural(
      id: json['id']?.toString().trim() ?? '',
      nombre: LocalizedString.fromJson(
        json['nombre'] as Map<String, dynamic>? ?? {},
      ),
      procedencia: LocalizedString.fromJson(
        json['procedencia'] as Map<String, dynamic>? ?? {},
      ),
      pautaManipulacion: LocalizedString.fromJson(
        (json['pautaManipulacion'] ?? json['pauta_manipulacion'])
                as Map<String, dynamic>? ??
            {},
      ),
      avisoSeguridad: rawAviso is Map<String, dynamic>
          ? LocalizedString.fromJson(rawAviso)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre.toJson(),
        'procedencia': procedencia.toJson(),
        'pautaManipulacion': pautaManipulacion.toJson(),
        if (avisoSeguridad != null) 'avisoSeguridad': avisoSeguridad!.toJson(),
      };

  MaterialNatural copyWith({
    String? id,
    LocalizedString? nombre,
    LocalizedString? procedencia,
    LocalizedString? pautaManipulacion,
    LocalizedString? avisoSeguridad,
  }) {
    return MaterialNatural(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      procedencia: procedencia ?? this.procedencia,
      pautaManipulacion: pautaManipulacion ?? this.pautaManipulacion,
      avisoSeguridad: avisoSeguridad ?? this.avisoSeguridad,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialNatural &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nombre == other.nombre &&
          procedencia == other.procedencia &&
          pautaManipulacion == other.pautaManipulacion &&
          avisoSeguridad == other.avisoSeguridad;

  @override
  int get hashCode => Object.hash(
        id,
        nombre,
        procedencia,
        pautaManipulacion,
        avisoSeguridad,
      );

  @override
  String toString() => 'MaterialNatural(id: "$id", nombre: $nombre)';
}

/// Representación estruturada dunha das 4 fases canónicas da asemblea guiada.
@immutable
class FaseAsamblea {
  /// Número de orde da fase (1..4).
  final int orden;

  /// Tipoloxía rítmica canónica da fase.
  final TipoFaseAsamblea tipo;

  /// Título descritivo localizado da fase.
  final LocalizedString titulo;

  /// Duración asignada en segundos (canónico: 90, 120, 270, 120).
  final int duracionSegundos;

  /// Consigna ou guía textual concisa orientada exclusivamente á docente (backstage).
  final LocalizedString consignaDocente;

  /// Lista de comandos TPR en L3 asociados a esta fase (principalmente no reto núcleo).
  final List<ComandoTPR> comandosL3;

  /// Indicación de clave acústica (ex: "Freeze!", son de campá, pulso 72 BPM).
  final String? cueAcustica;

  /// Pista de son offline para ambientación ou fade suave.
  final String? audioAsset;

  /// Repertorio analóxico de materiais naturais asociados a esta fase.
  final List<MaterialNatural> repertorioMateriales;

  const FaseAsamblea({
    required this.orden,
    required this.tipo,
    required this.titulo,
    required this.duracionSegundos,
    required this.consignaDocente,
    this.comandosL3 = const [],
    this.cueAcustica,
    this.audioAsset,
    this.repertorioMateriales = const [],
  });

  /// Alias de compatibilidade con contratos alternativos.
  List<ComandoTPR> get comandos => comandosL3;

  /// Alias de compatibilidade con contratos alternativos.
  List<MaterialNatural> get materiaisNaturais => repertorioMateriales;

  /// Duración en minutos enteiros aproximados.
  int get duracionMinutosEnteros => (duracionSegundos / 60).round();

  /// Duración formateada no formato MM:SS para o temporizador.
  String get duracionFormateada {
    final m = duracionSegundos ~/ 60;
    final s = (duracionSegundos % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  factory FaseAsamblea.fromJson(Map<String, dynamic> json) {
    final rawComandos = json['comandosL3'] ??
        json['comandos_l3'] ??
        json['comandos'];
    final List<ComandoTPR> cmds = [];
    if (rawComandos is List) {
      for (final c in rawComandos) {
        if (c is Map<String, dynamic>) {
          cmds.add(ComandoTPR.fromJson(c));
        }
      }
    }

    final rawMats = json['repertorioMateriales'] ??
        json['repertorio_materiales'] ??
        json['materiaisNaturais'] ??
        json['materiales'];
    final List<MaterialNatural> mats = [];
    if (rawMats is List) {
      for (final m in rawMats) {
        if (m is Map<String, dynamic>) {
          mats.add(MaterialNatural.fromJson(m));
        }
      }
    }

    final int rawOrden = (json['orden'] as num?)?.toInt() ?? 1;
    final tipo = json.containsKey('tipo')
        ? TipoFaseAsamblea.desdeClave(json['tipo']?.toString())
        : TipoFaseAsamblea.porOrden(rawOrden);

    return FaseAsamblea(
      orden: rawOrden,
      tipo: tipo,
      titulo: LocalizedString.fromJson(
        json['titulo'] as Map<String, dynamic>? ?? {},
      ),
      duracionSegundos: (json['duracionSegundos'] ??
                  json['duracion_segundos'] as num?)
              ?.toInt() ??
          tipo.duracionCanonicoSegundos,
      consignaDocente: LocalizedString.fromJson(
        (json['consignaDocente'] ?? json['consigna_docente'])
                as Map<String, dynamic>? ??
            {},
      ),
      comandosL3: List.unmodifiable(cmds),
      cueAcustica: json['cueAcustica']?.toString().trim() ??
          json['cue_acustica']?.toString().trim(),
      audioAsset: json['audioAsset']?.toString().trim() ??
          json['audio_asset']?.toString().trim(),
      repertorioMateriales: List.unmodifiable(mats),
    );
  }

  Map<String, dynamic> toJson() => {
        'orden': orden,
        'tipo': tipo.clave,
        'titulo': titulo.toJson(),
        'duracionSegundos': duracionSegundos,
        'consignaDocente': consignaDocente.toJson(),
        'comandosL3': comandosL3.map((c) => c.toJson()).toList(),
        if (cueAcustica != null) 'cueAcustica': cueAcustica,
        if (audioAsset != null) 'audioAsset': audioAsset,
        'repertorioMateriales':
            repertorioMateriales.map((m) => m.toJson()).toList(),
      };

  FaseAsamblea copyWith({
    int? orden,
    TipoFaseAsamblea? tipo,
    LocalizedString? titulo,
    int? duracionSegundos,
    LocalizedString? consignaDocente,
    List<ComandoTPR>? comandosL3,
    String? cueAcustica,
    String? audioAsset,
    List<MaterialNatural>? repertorioMateriales,
  }) {
    return FaseAsamblea(
      orden: orden ?? this.orden,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      duracionSegundos: duracionSegundos ?? this.duracionSegundos,
      consignaDocente: consignaDocente ?? this.consignaDocente,
      comandosL3: comandosL3 != null
          ? List.unmodifiable(comandosL3)
          : this.comandosL3,
      cueAcustica: cueAcustica ?? this.cueAcustica,
      audioAsset: audioAsset ?? this.audioAsset,
      repertorioMateriales: repertorioMateriales != null
          ? List.unmodifiable(repertorioMateriales)
          : this.repertorioMateriales,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FaseAsamblea &&
          runtimeType == other.runtimeType &&
          orden == other.orden &&
          tipo == other.tipo &&
          titulo == other.titulo &&
          duracionSegundos == other.duracionSegundos &&
          consignaDocente == other.consignaDocente &&
          listEquals(comandosL3, other.comandosL3) &&
          cueAcustica == other.cueAcustica &&
          audioAsset == other.audioAsset &&
          listEquals(repertorioMateriales, other.repertorioMateriales);

  @override
  int get hashCode => Object.hashAll([
        orden,
        tipo,
        titulo,
        duracionSegundos,
        consignaDocente,
        Object.hashAll(comandosL3),
        cueAcustica,
        audioAsset,
        Object.hashAll(repertorioMateriales),
      ]);

  @override
  String toString() =>
      'FaseAsamblea(orden: $orden, tipo: ${tipo.clave}, duracion: ${duracionSegundos}s)';
}

/// Referencia curricular ao Decreto 150/2022 de Galicia para o Segundo Ciclo (3-6 anos).
@immutable
class CurricularReferenceSegundoCiclo {
  /// Norma reguladora: estrictamente "Decreto 150/2022".
  final String normativa;

  /// Etapa educativa: estrictamente "educacion_infantil".
  final String etapa;

  /// Ciclo educativo: estrictamente "segundo_ciclo_3_6".
  final String ciclo;

  /// Nivel do segundo ciclo ("4_infantil", "5_infantil", "6_infantil").
  final String nivel;

  /// Áreas curriculares cubertas (Áreas 1, 2, 3).
  final List<String> areas;

  /// Competencias clave do perfil de saída (CCL, CPSAA, CCEC).
  final List<String> competenciasClave;

  /// Criterios de avaliación específicos para o Segundo Ciclo.
  final List<String> criteriosEvaluacion;

  const CurricularReferenceSegundoCiclo({
    this.normativa = normativaDecreto150,
    this.etapa = etapaInfantil,
    this.ciclo = cicloSegundo,
    required this.nivel,
    required this.areas,
    this.competenciasClave = const ['CCL', 'CPSAA', 'CCEC'],
    required this.criteriosEvaluacion,
  });

  /// Nome canónico da normativa galega.
  static const String normativaDecreto150 = 'Decreto 150/2022';

  /// Identificador da etapa.
  static const String etapaInfantil = 'educacion_infantil';

  /// Identificador oficial do segundo ciclo de infantil (3-6 anos).
  static const String cicloSegundo = 'segundo_ciclo_3_6';

  // Áreas oficiais do Decreto 150/2022
  static const String area1CrecementoHarmonia =
      CurricularReference.area1CrecementoHarmonia;
  static const String area2DescubrimentoContorna =
      CurricularReference.area2DescubrimentoContorna;
  static const String area3ComunicacionRepresentacion =
      CurricularReference.area3ComunicacionRepresentacion;

  /// Conxunto de áreas válidas no currículo galego de infantil.
  static const Set<String> validAreas = {
    area1CrecementoHarmonia,
    area2DescubrimentoContorna,
    area3ComunicacionRepresentacion,
  };

  // Criterios de avaliación oficiais para o Segundo Ciclo (3-6 anos)
  static const String criterioControlCorpoCoord = 'CA1.1';
  static const String criterioAutonomiaRutinas = 'CA1.2';
  static const String criterioRegulacionEmocional = 'CA1.3';
  static const String criterioCooperacionXogo = 'CA1.4';

  static const String criterioCuriosidadeMateriaisNaturais = 'CA2.1';
  static const String criterioOrientacionEspacial = 'CA2.2';
  static const String criterioRespectoContorna = 'CA2.3';

  static const String criterioComprensionL3Motora = 'CA3.1';
  static const String criterioDiscriminacionRitmoStopSignal = 'CA3.2';
  static const String criterioInteraccionPeerToPeer = 'CA3.3';

  /// Conxunto de criterios válidos para o Segundo Ciclo.
  static const Set<String> validCriteriosSegundoCiclo = {
    criterioControlCorpoCoord,
    criterioAutonomiaRutinas,
    criterioRegulacionEmocional,
    criterioCooperacionXogo,
    criterioCuriosidadeMateriaisNaturais,
    criterioOrientacionEspacial,
    criterioRespectoContorna,
    criterioComprensionL3Motora,
    criterioDiscriminacionRitmoStopSignal,
    criterioInteraccionPeerToPeer,
  };

  factory CurricularReferenceSegundoCiclo.fromJson(Map<String, dynamic> json) {
    final rawAreas = json['areas'];
    final List<String> parsedAreas = rawAreas is List
        ? rawAreas.map((e) => e.toString().trim()).toList()
        : const [];

    final rawComps = json['competenciasClave'] ?? json['competencias_clave'];
    final List<String> parsedComps = rawComps is List
        ? rawComps.map((e) => e.toString().trim()).toList()
        : const ['CCL', 'CPSAA', 'CCEC'];

    final rawCriterios =
        json['criteriosEvaluacion'] ?? json['criterios_evaluacion'];
    final List<String> parsedCriterios = rawCriterios is List
        ? rawCriterios.map((e) => e.toString().trim()).toList()
        : const [];

    return CurricularReferenceSegundoCiclo(
      normativa: json['normativa']?.toString().trim() ?? normativaDecreto150,
      etapa: json['etapa']?.toString().trim() ?? etapaInfantil,
      ciclo: json['ciclo']?.toString().trim() ?? cicloSegundo,
      nivel: json['nivel']?.toString().trim() ?? '4_infantil',
      areas: List.unmodifiable(parsedAreas),
      competenciasClave: List.unmodifiable(parsedComps),
      criteriosEvaluacion: List.unmodifiable(parsedCriterios),
    );
  }

  Map<String, dynamic> toJson() => {
        'normativa': normativa,
        'etapa': etapa,
        'ciclo': ciclo,
        'nivel': nivel,
        'areas': areas,
        'competenciasClave': competenciasClave,
        'criteriosEvaluacion': criteriosEvaluacion,
      };

  /// Valida o cumprimento estrito do Decreto 150/2022 para o Segundo Ciclo.
  bool get isValidDecreto150SegundoCiclo {
    if (normativa != normativaDecreto150) return false;
    if (etapa != etapaInfantil) return false;
    if (ciclo != cicloSegundo) return false;
    if (nivel != '4_infantil' &&
        nivel != '5_infantil' &&
        nivel != '6_infantil') {
      return false;
    }
    if (areas.isEmpty) return false;
    for (final a in areas) {
      if (!validAreas.contains(a)) return false;
    }
    if (criteriosEvaluacion.isEmpty) return false;
    for (final c in criteriosEvaluacion) {
      if (!validCriteriosSegundoCiclo.contains(c)) return false;
    }
    return true;
  }

  /// Comproba se se referencia unha área específica.
  bool hasArea(String areaCode) => areas.contains(areaCode);

  /// Comproba se se referencia un criterio específico.
  bool hasCriterio(String criterioCode) =>
      criteriosEvaluacion.contains(criterioCode);

  /// Comproba se se referencia unha competencia clave específica.
  bool hasCompetencia(String compCode) =>
      competenciasClave.contains(compCode);

  CurricularReferenceSegundoCiclo copyWith({
    String? normativa,
    String? etapa,
    String? ciclo,
    String? nivel,
    List<String>? areas,
    List<String>? competenciasClave,
    List<String>? criteriosEvaluacion,
  }) {
    return CurricularReferenceSegundoCiclo(
      normativa: normativa ?? this.normativa,
      etapa: etapa ?? this.etapa,
      ciclo: ciclo ?? this.ciclo,
      nivel: nivel ?? this.nivel,
      areas: areas != null ? List.unmodifiable(areas) : this.areas,
      competenciasClave: competenciasClave != null
          ? List.unmodifiable(competenciasClave)
          : this.competenciasClave,
      criteriosEvaluacion: criteriosEvaluacion != null
          ? List.unmodifiable(criteriosEvaluacion)
          : this.criteriosEvaluacion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurricularReferenceSegundoCiclo &&
          runtimeType == other.runtimeType &&
          normativa == other.normativa &&
          etapa == other.etapa &&
          ciclo == other.ciclo &&
          nivel == other.nivel &&
          listEquals(areas, other.areas) &&
          listEquals(competenciasClave, other.competenciasClave) &&
          listEquals(criteriosEvaluacion, other.criteriosEvaluacion);

  @override
  int get hashCode => Object.hash(
        normativa,
        etapa,
        ciclo,
        nivel,
        Object.hashAll(areas),
        Object.hashAll(competenciasClave),
        Object.hashAll(criteriosEvaluacion),
      );

  @override
  String toString() =>
      'CurricularReferenceSegundoCiclo(nivel: "$nivel", areas: $areas, criterios: $criteriosEvaluacion)';
}

/// Alias para paridade con nomenclatura galega.
typedef CurriculoSegundoCiclo = CurricularReferenceSegundoCiclo;

/// Pauta de modelado correctivo indirecto (recast) sen avaliación frontal nin reprobación.
@immutable
class PautaRecast {
  /// Expresión espontánea, incompleta ou titubeante habitual da crianza.
  final LocalizedString expresionMenor;

  /// Reformulación agarimosa, correcta e natural polo adulto, respectando a intención comunicativa.
  final LocalizedString modeladoIndirecto;

  /// Consello explícito sobre a conduta verbal que a familia debe evitar (cero "mal", cero reproches).
  final LocalizedString consejoEvitar;

  const PautaRecast({
    required this.expresionMenor,
    required this.modeladoIndirecto,
    required this.consejoEvitar,
  });

  factory PautaRecast.fromJson(Map<String, dynamic> json) {
    return PautaRecast(
      expresionMenor: LocalizedString.fromJson(
        (json['expresionMenor'] ?? json['expresion_menor'])
                as Map<String, dynamic>? ??
            {},
      ),
      modeladoIndirecto: LocalizedString.fromJson(
        (json['modeladoIndirecto'] ?? json['modelado_indirecto'])
                as Map<String, dynamic>? ??
            {},
      ),
      consejoEvitar: LocalizedString.fromJson(
        (json['consejoEvitar'] ?? json['consejo_evitar'])
                as Map<String, dynamic>? ??
            {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'expresionMenor': expresionMenor.toJson(),
        'modeladoIndirecto': modeladoIndirecto.toJson(),
        'consejoEvitar': consejoEvitar.toJson(),
      };

  PautaRecast copyWith({
    LocalizedString? expresionMenor,
    LocalizedString? modeladoIndirecto,
    LocalizedString? consejoEvitar,
  }) {
    return PautaRecast(
      expresionMenor: expresionMenor ?? this.expresionMenor,
      modeladoIndirecto: modeladoIndirecto ?? this.modeladoIndirecto,
      consejoEvitar: consejoEvitar ?? this.consejoEvitar,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PautaRecast &&
          runtimeType == other.runtimeType &&
          expresionMenor == other.expresionMenor &&
          modeladoIndirecto == other.modeladoIndirecto &&
          consejoEvitar == other.consejoEvitar;

  @override
  int get hashCode => Object.hash(
        expresionMenor,
        modeladoIndirecto,
        consejoEvitar,
      );

  @override
  String toString() =>
      'PautaRecast(expresion: ${expresionMenor.gl}, modelado: ${modeladoIndirecto.gl})';
}

/// Micro-rutina doméstica do Segundo Ciclo baixo o principio "Time and Place" (3 a 5 minutos) vinculada a Academy.
@immutable
class MicroRutinaHogarSegundoCiclo {
  /// Identificador único da micro-rutina (ex: "micro_rutina.setembro.01").
  final String id;

  /// Título evocador e cálido da micro-rutina para as familias.
  final LocalizedString titulo;

  /// Nicho temporal estrito en minutos (3..5 min) sen sobrecargar tarefas administrativas no fogar.
  final int nichoTiempoMinutos;

  /// Momento natural do día no que ocorre o hábito (ex: ao chegar da escola, ao erguerse, antes de durmir).
  final LocalizedString momentoDelDia;

  /// Obxectivo pedagóxico de autonomía física e seguridade emocional.
  final LocalizedString objetivoAutonomia;

  /// Conxunto de pautas dialogadas de modelado indirecto (recast) con 5 segundos de espera activa.
  final List<PautaRecast> pautasRecast;

  /// Descrición do contexto e escena cotiá do fogar.
  final LocalizedString escenaCotidiana;

  /// Identificador opcional da cápsula de Academy coa que sincroniza.
  final String? enlaceCapsulaAcademyId;

  const MicroRutinaHogarSegundoCiclo({
    required this.id,
    required this.titulo,
    required this.nichoTiempoMinutos,
    required this.momentoDelDia,
    required this.objetivoAutonomia,
    required this.pautasRecast,
    required this.escenaCotidiana,
    this.enlaceCapsulaAcademyId,
  });

  factory MicroRutinaHogarSegundoCiclo.fromJson(Map<String, dynamic> json) {
    final rawPautas = json['pautasRecast'] ?? json['pautas_recast'];
    final List<PautaRecast> pautas = [];
    if (rawPautas is List) {
      for (final p in rawPautas) {
        if (p is Map<String, dynamic>) {
          pautas.add(PautaRecast.fromJson(p));
        }
      }
    }

    return MicroRutinaHogarSegundoCiclo(
      id: json['id']?.toString().trim() ?? '',
      titulo: LocalizedString.fromJson(
        json['titulo'] as Map<String, dynamic>? ?? {},
      ),
      nichoTiempoMinutos: (json['nichoTiempoMinutos'] ??
                  json['nicho_tiempo_minutos'] as num?)
              ?.toInt() ??
          3,
      momentoDelDia: LocalizedString.fromJson(
        (json['momentoDelDia'] ?? json['momento_del_dia'])
                as Map<String, dynamic>? ??
            {},
      ),
      objetivoAutonomia: LocalizedString.fromJson(
        (json['objetivoAutonomia'] ?? json['objetivo_autonomia'])
                as Map<String, dynamic>? ??
            {},
      ),
      pautasRecast: List.unmodifiable(pautas),
      escenaCotidiana: LocalizedString.fromJson(
        (json['escenaCotidiana'] ?? json['escena_cotidiana'])
                as Map<String, dynamic>? ??
            {},
      ),
      enlaceCapsulaAcademyId: json['enlaceCapsulaAcademyId']?.toString().trim() ??
          json['enlace_capsula_academy_id']?.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo.toJson(),
        'nichoTiempoMinutos': nichoTiempoMinutos,
        'momentoDelDia': momentoDelDia.toJson(),
        'objetivoAutonomia': objetivoAutonomia.toJson(),
        'pautasRecast': pautasRecast.map((p) => p.toJson()).toList(),
        'escenaCotidiana': escenaCotidiana.toJson(),
        if (enlaceCapsulaAcademyId != null)
          'enlaceCapsulaAcademyId': enlaceCapsulaAcademyId,
      };

  MicroRutinaHogarSegundoCiclo copyWith({
    String? id,
    LocalizedString? titulo,
    int? nichoTiempoMinutos,
    LocalizedString? momentoDelDia,
    LocalizedString? objetivoAutonomia,
    List<PautaRecast>? pautasRecast,
    LocalizedString? escenaCotidiana,
    String? enlaceCapsulaAcademyId,
  }) {
    return MicroRutinaHogarSegundoCiclo(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      nichoTiempoMinutos: nichoTiempoMinutos ?? this.nichoTiempoMinutos,
      momentoDelDia: momentoDelDia ?? this.momentoDelDia,
      objetivoAutonomia: objetivoAutonomia ?? this.objetivoAutonomia,
      pautasRecast: pautasRecast != null
          ? List.unmodifiable(pautasRecast)
          : this.pautasRecast,
      escenaCotidiana: escenaCotidiana ?? this.escenaCotidiana,
      enlaceCapsulaAcademyId:
          enlaceCapsulaAcademyId ?? this.enlaceCapsulaAcademyId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MicroRutinaHogarSegundoCiclo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          titulo == other.titulo &&
          nichoTiempoMinutos == other.nichoTiempoMinutos &&
          momentoDelDia == other.momentoDelDia &&
          objetivoAutonomia == other.objetivoAutonomia &&
          listEquals(pautasRecast, other.pautasRecast) &&
          escenaCotidiana == other.escenaCotidiana &&
          enlaceCapsulaAcademyId == other.enlaceCapsulaAcademyId;

  @override
  int get hashCode => Object.hash(
        id,
        titulo,
        nichoTiempoMinutos,
        momentoDelDia,
        objetivoAutonomia,
        Object.hashAll(pautasRecast),
        escenaCotidiana,
        enlaceCapsulaAcademyId,
      );

  @override
  String toString() =>
      'MicroRutinaHogarSegundoCiclo(id: "$id", nicho: ${nichoTiempoMinutos}min)';
}

/// Modelo de datos raíz inmutable para asambleas de Segundo Ciclo (3-6 anos).
///
/// Estrutura canónica para as sesións matinais de colexio orientadas exclusivamente
/// ao docente (backstage), garantindo cero exposición de pantallas ás crianzas.
@immutable
class AsambleaSegundoCiclo {
  /// Identificador canónico (ex: "asamblea.segundo_ciclo.setembro.4_infantil").
  final String id;

  /// Nivel do segundo ciclo (4.º, 5.º ou 6.º de Educación Infantil).
  final NivelEducativoSegundoCiclo nivel;

  /// Mes do calendario escolar (1..10, 9 para setembro).
  final int mes;

  /// Título bilingüe da unidade temática mensual.
  final LocalizedString titulo;

  /// Centro de interese ou núcleo temático da contorna galega.
  final LocalizedString centroInteres;

  /// Metodoloxía TPR diferenciada correspondente ao nivel.
  final MetodologiaTPR metodologiaTpr;

  /// Duración total canónica da asemblea en minutos (canónico: 10 minutos).
  final int duracionTotalMinutos;

  /// As 4 fases canónicas secuenciadas (Apertura, Ritmo, Reto TPR, Calma).
  final List<FaseAsamblea> fases;

  /// Aliñamento curricular co Decreto 150/2022 de Galicia.
  final CurricularReferenceSegundoCiclo curriculo;

  /// Repertorio de materiais naturais da contorna atlántica (mimbre, castañas, cunchas, gasas).
  final List<MaterialNatural> materialesEntorno;

  /// Micro-rutina de transferencia ecolóxica ao fogar baseada en recast e Time and Place.
  final MicroRutinaHogarSegundoCiclo microRutinaHogar;

  /// Metadatos de auditoría e revisión pedagóxica da unidade.
  final Revision revision;

  const AsambleaSegundoCiclo({
    required this.id,
    required this.nivel,
    required this.mes,
    required this.titulo,
    required this.centroInteres,
    required this.metodologiaTpr,
    this.duracionTotalMinutos = 10,
    required this.fases,
    required this.curriculo,
    required this.materialesEntorno,
    required this.microRutinaHogar,
    required this.revision,
  });

  // Getters de paridade e conveniencia contractual
  MetodologiaTPR get metodologia => metodologiaTpr;
  CurricularReferenceSegundoCiclo get curricular => curriculo;
  List<MaterialNatural> get materiaisNaturais => materialesEntorno;

  /// Calcula a duración real total acumulada en segundos sumando as 4 fases.
  int get duracionTotalSegundos =>
      fases.fold<int>(0, (sum, f) => sum + f.duracionSegundos);

  /// Valida que a sesión contén exactamente as 4 fases canónicas na orde precisa.
  bool get hasCanonicalPhases {
    if (fases.length != 4) return false;
    return fases[0].tipo == TipoFaseAsamblea.aperturaSaudo &&
        fases[1].tipo == TipoFaseAsamblea.movementRhythmFocus &&
        fases[2].tipo == TipoFaseAsamblea.coreTprChallenge &&
        fases[3].tipo == TipoFaseAsamblea.calmaTransicion;
  }

  /// Recupera unha fase concreta polo seu tipo rítmico.
  FaseAsamblea? fasePorTipo(TipoFaseAsamblea tipo) {
    for (final f in fases) {
      if (f.tipo == tipo) return f;
    }
    return null;
  }

  /// Recupera unha fase polo seu número de orde (1..4).
  FaseAsamblea? fasePorOrden(int orden) {
    for (final f in fases) {
      if (f.orden == orden) return f;
    }
    return null;
  }

  factory AsambleaSegundoCiclo.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('id') || json['id'] == null) {
      throw const FormatException(
          'AsambleaSegundoCiclo missing required root key: "id"');
    }

    final rawFases = json['fases'];
    final List<FaseAsamblea> parsedFases = [];
    if (rawFases is List) {
      for (final f in rawFases) {
        if (f is Map<String, dynamic>) {
          parsedFases.add(FaseAsamblea.fromJson(f));
        }
      }
    }

    final rawMats = json['materialesEntorno'] ??
        json['materiales_entorno'] ??
        json['materiaisNaturais'] ??
        json['materiales'];
    final List<MaterialNatural> parsedMats = [];
    if (rawMats is List) {
      for (final m in rawMats) {
        if (m is Map<String, dynamic>) {
          parsedMats.add(MaterialNatural.fromJson(m));
        }
      }
    }

    final curriculoData = (json['curriculo'] ?? json['curricular'])
            as Map<String, dynamic>? ??
        {};
    final microData = (json['microRutinaHogar'] ?? json['micro_rutina_hogar'])
            as Map<String, dynamic>? ??
        {};
    final revisionData = json['revision'] as Map<String, dynamic>? ?? {};

    return AsambleaSegundoCiclo(
      id: json['id']?.toString().trim() ?? '',
      nivel: NivelEducativoSegundoCiclo.desdeClave(json['nivel']?.toString()),
      mes: (json['mes'] as num?)?.toInt() ?? 9,
      titulo: LocalizedString.fromJson(
        json['titulo'] as Map<String, dynamic>? ?? {},
      ),
      centroInteres: LocalizedString.fromJson(
        (json['centroInteres'] ?? json['centro_interes'])
                as Map<String, dynamic>? ??
            {},
      ),
      metodologiaTpr: MetodologiaTPR.desdeClave(
        (json['metodologiaTpr'] ??
                json['metodologia_tpr'] ??
                json['metodologia'])
            ?.toString(),
      ),
      duracionTotalMinutos: (json['duracionTotalMinutos'] ??
                  json['duracion_total_minutos'] as num?)
              ?.toInt() ??
          10,
      fases: List.unmodifiable(parsedFases),
      curriculo: CurricularReferenceSegundoCiclo.fromJson(curriculoData),
      materialesEntorno: List.unmodifiable(parsedMats),
      microRutinaHogar: MicroRutinaHogarSegundoCiclo.fromJson(microData),
      revision: Revision.fromJson(revisionData),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nivel': nivel.clave,
        'mes': mes,
        'titulo': titulo.toJson(),
        'centroInteres': centroInteres.toJson(),
        'metodologiaTpr': metodologiaTpr.clave,
        'duracionTotalMinutos': duracionTotalMinutos,
        'fases': fases.map((f) => f.toJson()).toList(),
        'curriculo': curriculo.toJson(),
        'materialesEntorno':
            materialesEntorno.map((m) => m.toJson()).toList(),
        'microRutinaHogar': microRutinaHogar.toJson(),
        'revision': revision.toJson(),
      };

  AsambleaSegundoCiclo copyWith({
    String? id,
    NivelEducativoSegundoCiclo? nivel,
    int? mes,
    LocalizedString? titulo,
    LocalizedString? centroInteres,
    MetodologiaTPR? metodologiaTpr,
    int? duracionTotalMinutos,
    List<FaseAsamblea>? fases,
    CurricularReferenceSegundoCiclo? curriculo,
    List<MaterialNatural>? materialesEntorno,
    MicroRutinaHogarSegundoCiclo? microRutinaHogar,
    Revision? revision,
  }) {
    return AsambleaSegundoCiclo(
      id: id ?? this.id,
      nivel: nivel ?? this.nivel,
      mes: mes ?? this.mes,
      titulo: titulo ?? this.titulo,
      centroInteres: centroInteres ?? this.centroInteres,
      metodologiaTpr: metodologiaTpr ?? this.metodologiaTpr,
      duracionTotalMinutos: duracionTotalMinutos ?? this.duracionTotalMinutos,
      fases: fases != null ? List.unmodifiable(fases) : this.fases,
      curriculo: curriculo ?? this.curriculo,
      materialesEntorno: materialesEntorno != null
          ? List.unmodifiable(materialesEntorno)
          : this.materialesEntorno,
      microRutinaHogar: microRutinaHogar ?? this.microRutinaHogar,
      revision: revision ?? this.revision,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsambleaSegundoCiclo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nivel == other.nivel &&
          mes == other.mes &&
          titulo == other.titulo &&
          centroInteres == other.centroInteres &&
          metodologiaTpr == other.metodologiaTpr &&
          duracionTotalMinutos == other.duracionTotalMinutos &&
          listEquals(fases, other.fases) &&
          curriculo == other.curriculo &&
          listEquals(materialesEntorno, other.materialesEntorno) &&
          microRutinaHogar == other.microRutinaHogar &&
          revision == other.revision;

  @override
  int get hashCode => Object.hashAll([
        id,
        nivel,
        mes,
        titulo,
        centroInteres,
        metodologiaTpr,
        duracionTotalMinutos,
        Object.hashAll(fases),
        curriculo,
        Object.hashAll(materialesEntorno),
        microRutinaHogar,
        revision,
      ]);

  @override
  String toString() =>
      'AsambleaSegundoCiclo(id: "$id", nivel: ${nivel.clave}, mes: $mes, titulo: $titulo)';
}

/// Aliases de compatibilidade e sincronización de contratos.
typedef SegundoCicloUnidad = AsambleaSegundoCiclo;
typedef UnidadSegundoCiclo = AsambleaSegundoCiclo;
