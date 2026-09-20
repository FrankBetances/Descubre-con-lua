import 'package:flutter/foundation.dart';
import '../../core/localization/localized_string.dart';

/// Total Physical Response (TPR) oral instruction in English with Galician/Spanish guidance.
@immutable
class CuentoTprOral {
  final String fraseEn;
  final String comandoGl;
  final String comandoEs;

  const CuentoTprOral({
    required this.fraseEn,
    required this.comandoGl,
    required this.comandoEs,
  });

  factory CuentoTprOral.fromJson(Map<String, dynamic> json) {
    return CuentoTprOral(
      fraseEn: json['fraseEn']?.toString().trim() ??
          json['frase_en']?.toString().trim() ??
          '',
      comandoGl: json['comandoGl']?.toString().trim() ??
          json['comando_gl']?.toString().trim() ??
          '',
      comandoEs: json['comandoEs']?.toString().trim() ??
          json['comando_es']?.toString().trim() ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
        'fraseEn': fraseEn,
        'comandoGl': comandoGl,
        'comandoEs': comandoEs,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CuentoTprOral &&
          runtimeType == other.runtimeType &&
          fraseEn == other.fraseEn &&
          comandoGl == other.comandoGl &&
          comandoEs == other.comandoEs;

  @override
  int get hashCode => Object.hash(fraseEn, comandoGl, comandoEs);

  @override
  String toString() => 'CuentoTprOral($fraseEn)';
}

/// Single page in a progressive pedagogical story.
@immutable
class CuentoPagina {
  final int numero;
  final LocalizedString? tituloPagina;
  final String lamina;
  final LocalizedString texto;
  final LocalizedString? preguntaImaxe;
  final LocalizedString? guiaAtencion;
  final List<String> vocabularioClave;

  const CuentoPagina({
    required this.numero,
    this.tituloPagina,
    required this.lamina,
    required this.texto,
    this.preguntaImaxe,
    this.guiaAtencion,
    required this.vocabularioClave,
  });

  factory CuentoPagina.fromJson(Map<String, dynamic> json) {
    final rawVocab = json['vocabularioClave'] ?? json['vocabulario_clave'];
    final List<String> vocabList;
    if (rawVocab is List) {
      vocabList = rawVocab.map((e) => e.toString().trim()).toList();
    } else {
      vocabList = const [];
    }

    final rawTitulo = json['tituloPagina'] ?? json['titulo_pagina'];
    final LocalizedString? titulo = rawTitulo is Map<String, dynamic>
        ? LocalizedString.fromJson(rawTitulo)
        : null;

    final rawPregunta = json['preguntaImaxe'] ??
        json['pregunta_imaxe'] ??
        json['preguntaComprension'] ??
        json['pregunta_comprension'];
    final LocalizedString? pregunta = rawPregunta is Map<String, dynamic>
        ? LocalizedString.fromJson(rawPregunta)
        : null;

    final rawGuia = json['guiaAtencion'] ?? json['guia_atencion'];
    final LocalizedString? guia = rawGuia is Map<String, dynamic>
        ? LocalizedString.fromJson(rawGuia)
        : null;

    return CuentoPagina(
      numero: (json['numero'] as num?)?.toInt() ??
          (json['orden'] as num?)?.toInt() ??
          1,
      tituloPagina: titulo,
      lamina: json['lamina']?.toString().trim() ?? '',
      texto: LocalizedString.fromJson(
        json['texto'] as Map<String, dynamic>? ?? const {},
      ),
      preguntaImaxe: pregunta,
      guiaAtencion: guia,
      vocabularioClave: List.unmodifiable(vocabList),
    );
  }

  Map<String, dynamic> toJson() => {
        'numero': numero,
        if (tituloPagina != null) 'tituloPagina': tituloPagina!.toJson(),
        'lamina': lamina,
        'texto': texto.toJson(),
        if (preguntaImaxe != null) 'preguntaImaxe': preguntaImaxe!.toJson(),
        if (guiaAtencion != null) 'guiaAtencion': guiaAtencion!.toJson(),
        'vocabularioClave': vocabularioClave,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CuentoPagina &&
          runtimeType == other.runtimeType &&
          numero == other.numero &&
          tituloPagina == other.tituloPagina &&
          lamina == other.lamina &&
          texto == other.texto &&
          preguntaImaxe == other.preguntaImaxe &&
          guiaAtencion == other.guiaAtencion &&
          listEquals(vocabularioClave, other.vocabularioClave);

  @override
  int get hashCode => Object.hash(
        numero,
        tituloPagina,
        lamina,
        texto,
        preguntaImaxe,
        guiaAtencion,
        Object.hashAll(vocabularioClave),
      );

  @override
  String toString() => 'CuentoPagina(p.$numero, lamina: $lamina)';
}

/// Comprehension question graduated by Bloom's cognitive taxonomy for early childhood.
@immutable
class PreguntaGraduada {
  final int nivel; // 1: Literal, 2: Inferencial, 3: Crítico/Creativo
  final String rangoIdade;
  final LocalizedString? tipo;
  final LocalizedString enunciado;
  final LocalizedString? obxectivo;
  final LocalizedString? respostaModelo;
  final LocalizedString? pistaEducadora;

  const PreguntaGraduada({
    required this.nivel,
    required this.rangoIdade,
    this.tipo,
    required this.enunciado,
    this.obxectivo,
    this.respostaModelo,
    this.pistaEducadora,
  });

  factory PreguntaGraduada.fromJson(Map<String, dynamic> json) {
    final rawTipo = json['tipo'];
    final LocalizedString? tipo = rawTipo is Map<String, dynamic>
        ? LocalizedString.fromJson(rawTipo)
        : null;

    final rawObj = json['obxectivo'] ?? json['objetivo'];
    final LocalizedString? obxectivo = rawObj is Map<String, dynamic>
        ? LocalizedString.fromJson(rawObj)
        : null;

    final rawResp = json['respostaModelo'] ?? json['respuesta_modelo'];
    final LocalizedString? resposta = rawResp is Map<String, dynamic>
        ? LocalizedString.fromJson(rawResp)
        : null;

    final rawPista = json['pistaEducadora'] ?? json['pista_educadora'];
    final LocalizedString? pista = rawPista is Map<String, dynamic>
        ? LocalizedString.fromJson(rawPista)
        : null;

    return PreguntaGraduada(
      nivel: (json['nivel'] as num?)?.toInt() ?? 1,
      rangoIdade: json['rangoIdade']?.toString().trim() ??
          json['rango_idade']?.toString().trim() ??
          '0 a 3 anos',
      tipo: tipo,
      enunciado: LocalizedString.fromJson(
        json['enunciado'] as Map<String, dynamic>? ?? const {},
      ),
      obxectivo: obxectivo,
      respostaModelo: resposta,
      pistaEducadora: pista,
    );
  }

  Map<String, dynamic> toJson() => {
        'nivel': nivel,
        'rangoIdade': rangoIdade,
        if (tipo != null) 'tipo': tipo!.toJson(),
        'enunciado': enunciado.toJson(),
        if (obxectivo != null) 'obxectivo': obxectivo!.toJson(),
        if (respostaModelo != null) 'respostaModelo': respostaModelo!.toJson(),
        if (pistaEducadora != null) 'pistaEducadora': pistaEducadora!.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreguntaGraduada &&
          runtimeType == other.runtimeType &&
          nivel == other.nivel &&
          rangoIdade == other.rangoIdade &&
          tipo == other.tipo &&
          enunciado == other.enunciado &&
          obxectivo == other.obxectivo &&
          respostaModelo == other.respostaModelo &&
          pistaEducadora == other.pistaEducadora;

  @override
  int get hashCode => Object.hash(
        nivel,
        rangoIdade,
        tipo,
        enunciado,
        obxectivo,
        respostaModelo,
        pistaEducadora,
      );

  @override
  String toString() => 'PreguntaGraduada(nivel: $nivel, $enunciado)';
}

/// Pedagogical story for Infant Education (0-6 years).
///
/// Corresponds to [HistoriaProgresiva] in `.studio_ref/src/data/banco200CuentosData.ts`
/// and `.studio_ref/src/types.ts`.
@immutable
class Cuento {
  final String id;
  final String cursoId; // 'curso_0_2', 'curso_2_3', 'curso_3_4', 'curso_4_5', 'curso_5_6'
  final int mesNumero; // 1..10
  final int semanaSugerida; // 1..4
  final LocalizedString? cursoEtiqueta;
  final LocalizedString? mesNome;
  final LocalizedString? centroInteres;
  final LocalizedString titulo;
  final LocalizedString sinopse;
  final int nivelLectura; // 1..5
  final String licenza;
  final String orixeOpenSource;
  final int tempoEsperaSegundos;
  final CuentoTprOral? tprOral;
  final List<CuentoPagina> paginas;
  final List<PreguntaGraduada> preguntasGraduadas;

  const Cuento({
    required this.id,
    required this.cursoId,
    required this.mesNumero,
    required this.semanaSugerida,
    this.cursoEtiqueta,
    this.mesNome,
    this.centroInteres,
    required this.titulo,
    required this.sinopse,
    this.nivelLectura = 1,
    this.licenza = 'Creative Commons CC BY 4.0',
    this.orixeOpenSource = 'Patrimonio Vigo Infantil',
    this.tempoEsperaSegundos = 5,
    this.tprOral,
    required this.paginas,
    required this.preguntasGraduadas,
  });

  factory Cuento.fromJson(Map<String, dynamic> json) {
    final rawPaginas = json['paginas'];
    final List<CuentoPagina> paginasList = [];
    if (rawPaginas is List) {
      for (final p in rawPaginas) {
        if (p is Map<String, dynamic>) {
          paginasList.add(CuentoPagina.fromJson(p));
        } else if (p is Map) {
          paginasList.add(CuentoPagina.fromJson(Map<String, dynamic>.from(p)));
        }
      }
    }

    final rawPreguntas = json['preguntasGraduadas'] ??
        json['preguntas_graduadas'] ??
        json['preguntas'];
    final List<PreguntaGraduada> preguntasList = [];
    if (rawPreguntas is List) {
      for (final p in rawPreguntas) {
        if (p is Map<String, dynamic>) {
          preguntasList.add(PreguntaGraduada.fromJson(p));
        } else if (p is Map) {
          preguntasList.add(PreguntaGraduada.fromJson(Map<String, dynamic>.from(p)));
        }
      }
    }

    final rawTpr = json['tprOral'] ?? json['tpr_oral'];
    final CuentoTprOral? tpr = rawTpr is Map<String, dynamic>
        ? CuentoTprOral.fromJson(rawTpr)
        : (rawTpr is Map ? CuentoTprOral.fromJson(Map<String, dynamic>.from(rawTpr)) : null);

    final rawCursoEtiqueta = json['cursoEtiqueta'] ?? json['curso_etiqueta'];
    final LocalizedString? cursoEtiqueta = rawCursoEtiqueta is Map<String, dynamic>
        ? LocalizedString.fromJson(rawCursoEtiqueta)
        : null;

    final rawMesNome = json['mesNome'] ?? json['mes_nome'];
    final LocalizedString? mesNome = rawMesNome is Map<String, dynamic>
        ? LocalizedString.fromJson(rawMesNome)
        : null;

    final rawCentro = json['centroInteres'] ?? json['centro_interes'];
    final LocalizedString? centro = rawCentro is Map<String, dynamic>
        ? LocalizedString.fromJson(rawCentro)
        : null;

    return Cuento(
      id: json['id']?.toString().trim() ?? '',
      cursoId: json['cursoId']?.toString().trim() ??
          json['curso_id']?.toString().trim() ??
          'curso_0_2',
      mesNumero: (json['mesNumero'] as num?)?.toInt() ??
          (json['mes_numero'] as num?)?.toInt() ??
          1,
      semanaSugerida: (json['semanaSugerida'] as num?)?.toInt() ??
          (json['semana_sugerida'] as num?)?.toInt() ??
          1,
      cursoEtiqueta: cursoEtiqueta,
      mesNome: mesNome,
      centroInteres: centro,
      titulo: LocalizedString.fromJson(
        json['titulo'] as Map<String, dynamic>? ?? const {},
      ),
      sinopse: LocalizedString.fromJson(
        json['sinopse'] as Map<String, dynamic>? ??
            json['descripcion'] as Map<String, dynamic>? ??
            const {},
      ),
      nivelLectura: (json['nivelLectura'] as num?)?.toInt() ??
          (json['nivel_lectura'] as num?)?.toInt() ??
          1,
      licenza: json['licenza']?.toString().trim() ?? 'Creative Commons CC BY 4.0',
      orixeOpenSource: json['orixeOpenSource']?.toString().trim() ??
          json['orixe_open_source']?.toString().trim() ??
          'Patrimonio Vigo Infantil',
      tempoEsperaSegundos: (json['tempoEsperaSegundos'] as num?)?.toInt() ??
          (json['tempo_espera_segundos'] as num?)?.toInt() ??
          5,
      tprOral: tpr,
      paginas: List.unmodifiable(paginasList),
      preguntasGraduadas: List.unmodifiable(preguntasList),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cursoId': cursoId,
        'mesNumero': mesNumero,
        'semanaSugerida': semanaSugerida,
        if (cursoEtiqueta != null) 'cursoEtiqueta': cursoEtiqueta!.toJson(),
        if (mesNome != null) 'mesNome': mesNome!.toJson(),
        if (centroInteres != null) 'centroInteres': centroInteres!.toJson(),
        'titulo': titulo.toJson(),
        'sinopse': sinopse.toJson(),
        'nivelLectura': nivelLectura,
        'licenza': licenza,
        'orixeOpenSource': orixeOpenSource,
        'tempoEsperaSegundos': tempoEsperaSegundos,
        if (tprOral != null) 'tprOral': tprOral!.toJson(),
        'paginas': paginas.map((p) => p.toJson()).toList(),
        'preguntasGraduadas':
            preguntasGraduadas.map((p) => p.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cuento &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cursoId == other.cursoId &&
          mesNumero == other.mesNumero &&
          semanaSugerida == other.semanaSugerida &&
          cursoEtiqueta == other.cursoEtiqueta &&
          mesNome == other.mesNome &&
          centroInteres == other.centroInteres &&
          titulo == other.titulo &&
          sinopse == other.sinopse &&
          nivelLectura == other.nivelLectura &&
          licenza == other.licenza &&
          orixeOpenSource == other.orixeOpenSource &&
          tempoEsperaSegundos == other.tempoEsperaSegundos &&
          tprOral == other.tprOral &&
          listEquals(paginas, other.paginas) &&
          listEquals(preguntasGraduadas, other.preguntasGraduadas);

  @override
  int get hashCode => Object.hash(
        id,
        cursoId,
        mesNumero,
        semanaSugerida,
        cursoEtiqueta,
        mesNome,
        centroInteres,
        titulo,
        sinopse,
        nivelLectura,
        licenza,
        orixeOpenSource,
        tempoEsperaSegundos,
        tprOral,
        Object.hashAll(paginas),
        Object.hashAll(preguntasGraduadas),
      );

  @override
  String toString() => 'Cuento($id, curso: $cursoId, mes: $mesNumero, $titulo)';
}
