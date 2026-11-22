import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';

class MesEstimulacionUi {
  final int mes;
  final int mesCalendario;
  final LocalizedString nome;
  final LocalizedString curto;

  const MesEstimulacionUi({
    required this.mes,
    required this.mesCalendario,
    required this.nome,
    required this.curto,
  });

  factory MesEstimulacionUi.fromJson(Map<String, dynamic> j) =>
      MesEstimulacionUi(
        mes: j['mes'] as int,
        mesCalendario: j['mes_calendario'] as int,
        nome: LocalizedString.fromJson(j),
        curto: LocalizedString(
          gl: j['curto_gl'] as String,
          es: j['curto_es'] as String,
        ),
      );
}

class BloqueEscoitaUi {
  final String numero;
  final LocalizedString titulo;
  final LocalizedString subtituloCasa;
  final LocalizedString subtituloAula;
  final LocalizedString fonemaRotulo;

  const BloqueEscoitaUi({
    required this.numero,
    required this.titulo,
    required this.subtituloCasa,
    required this.subtituloAula,
    required this.fonemaRotulo,
  });
}

class BloqueProgresionUi {
  final String numero;
  final LocalizedString titulo;
  final LocalizedString subtituloCasa;
  final LocalizedString subtituloAula;
  final Map<String, LocalizedString> fases;

  const BloqueProgresionUi({
    required this.numero,
    required this.titulo,
    required this.subtituloCasa,
    required this.subtituloAula,
    required this.fases,
  });
}

class BloqueModeloUi {
  final String numero;
  final LocalizedString titulo;
  final LocalizedString subtituloCasa;
  final LocalizedString subtituloAula;
  final LocalizedString seDi;

  const BloqueModeloUi({
    required this.numero,
    required this.titulo,
    required this.subtituloCasa,
    required this.subtituloAula,
    required this.seDi,
  });
}

class MomentoPensamosUi {
  final String orde;
  final LocalizedString nome;
  final LocalizedString aula;

  const MomentoPensamosUi({
    required this.orde,
    required this.nome,
    required this.aula,
  });
}

class BloquePensamosUi {
  final String numero;
  final LocalizedString titulo;
  final LocalizedString subtituloCasa;
  final LocalizedString subtituloAula;
  final LocalizedString significado;
  final LocalizedString guia;
  final LocalizedString observar;
  final LocalizedString modeloAdulto;
  final Map<String, LocalizedString> idadeModo;
  final Map<String, MomentoPensamosUi> momentos;

  const BloquePensamosUi({
    required this.numero,
    required this.titulo,
    required this.subtituloCasa,
    required this.subtituloAula,
    required this.significado,
    required this.guia,
    required this.observar,
    required this.modeloAdulto,
    required this.idadeModo,
    required this.momentos,
  });
}

class BloqueRaUi {
  final String numero;
  final LocalizedString titulo;
  final LocalizedString subtituloCasa;
  final LocalizedString subtituloAula;
  final LocalizedString abrirMesa;
  final LocalizedString abrirEspello;
  final LocalizedString modoSenCamara;
  final LocalizedString avisoSenArcore;
  final LocalizedString avisoPrivacidade;

  const BloqueRaUi({
    required this.numero,
    required this.titulo,
    required this.subtituloCasa,
    required this.subtituloAula,
    required this.abrirMesa,
    required this.abrirEspello,
    required this.modoSenCamara,
    required this.avisoSenArcore,
    required this.avisoPrivacidade,
  });
}

class EstimulacionUi {
  static const asset = 'assets/content/escoita/estimulacion_ui.json';
  static EstimulacionUi? _cache;

  final LocalizedString titulo;
  final LocalizedString subtituloCasa;
  final LocalizedString subtituloAula;
  final LocalizedString etiquetaCasa;
  final LocalizedString etiquetaAula;
  final LocalizedString guiaAsemblea;
  final LocalizedString experimentoMes;
  final LocalizedString mesActual;
  final LocalizedString mesesNav;
  final LocalizedString irASeccion;
  final BloqueEscoitaUi escoita;
  final BloqueProgresionUi progresion;
  final BloqueModeloUi modelo;
  final BloquePensamosUi pensamos;
  final BloqueRaUi ra;
  final LocalizedString zeroDousEtiqueta;
  final LocalizedString zeroDousSenPreguntas;
  final LocalizedString zeroDousAulaNota;
  final LocalizedString zeroDousPalabras;
  final List<MesEstimulacionUi> meses;

  const EstimulacionUi({
    required this.titulo,
    required this.subtituloCasa,
    required this.subtituloAula,
    required this.etiquetaCasa,
    required this.etiquetaAula,
    required this.guiaAsemblea,
    required this.experimentoMes,
    required this.mesActual,
    required this.mesesNav,
    required this.irASeccion,
    required this.escoita,
    required this.progresion,
    required this.modelo,
    required this.pensamos,
    required this.ra,
    required this.zeroDousEtiqueta,
    required this.zeroDousSenPreguntas,
    required this.zeroDousAulaNota,
    required this.zeroDousPalabras,
    required this.meses,
  });

  static int mesDeCalendario(int mesCalendario) {
    if (mesCalendario >= 9 && mesCalendario <= 12) return mesCalendario - 8;
    if (mesCalendario >= 1 && mesCalendario <= 6) return mesCalendario + 4;
    return 1;
  }

  static int calendarioDeMes(int mes) => mes <= 4 ? mes + 8 : mes - 4;

  MesEstimulacionUi mesUi(int mes) => meses.firstWhere(
        (m) => m.mes == mes,
        orElse: () => meses.first,
      );

  static EstimulacionUi? get lido => _cache;

  static Future<EstimulacionUi> cargar({AssetBundle? bundle}) async {
    final c = _cache;
    if (c != null && bundle == null) return c;
    final b = bundle ?? rootBundle;
    final j = jsonDecode(await b.loadString(asset)) as Map<String, dynamic>;
    final bl = j['bloques'] as Map<String, dynamic>;
    final be = bl['escoita'] as Map<String, dynamic>;
    final bp = bl['progresion'] as Map<String, dynamic>;
    final bm = bl['modelo'] as Map<String, dynamic>;
    final bpe = bl['pensamos'] as Map<String, dynamic>;
    final bra = bl['ra'] as Map<String, dynamic>;
    final zd = j['zero_dous'] as Map<String, dynamic>;
    final parsed = EstimulacionUi(
      titulo: LocalizedString.fromJson(j['titulo']),
      subtituloCasa: LocalizedString.fromJson(j['subtitulo_casa']),
      subtituloAula: LocalizedString.fromJson(j['subtitulo_aula']),
      etiquetaCasa: LocalizedString.fromJson(j['etiqueta_casa']),
      etiquetaAula: LocalizedString.fromJson(j['etiqueta_aula']),
      guiaAsemblea: LocalizedString.fromJson(j['guia_asemblea']),
      experimentoMes: LocalizedString.fromJson(j['experimento_mes']),
      mesActual: LocalizedString.fromJson(j['mes_actual']),
      mesesNav: LocalizedString.fromJson(j['meses_nav']),
      irASeccion: LocalizedString.fromJson(j['ir_a_seccion']),
      escoita: BloqueEscoitaUi(
        numero: be['numero'] as String,
        titulo: LocalizedString.fromJson(be['titulo']),
        subtituloCasa: LocalizedString.fromJson(be['subtitulo_casa']),
        subtituloAula: LocalizedString.fromJson(be['subtitulo_aula']),
        fonemaRotulo: LocalizedString.fromJson(be['fonema_rotulo']),
      ),
      progresion: BloqueProgresionUi(
        numero: bp['numero'] as String,
        titulo: LocalizedString.fromJson(bp['titulo']),
        subtituloCasa: LocalizedString.fromJson(bp['subtitulo_casa']),
        subtituloAula: LocalizedString.fromJson(bp['subtitulo_aula']),
        fases: {
          for (final e in (bp['fases'] as Map<String, dynamic>).entries)
            e.key: LocalizedString.fromJson(e.value),
        },
      ),
      modelo: BloqueModeloUi(
        numero: bm['numero'] as String,
        titulo: LocalizedString.fromJson(bm['titulo']),
        subtituloCasa: LocalizedString.fromJson(bm['subtitulo_casa']),
        subtituloAula: LocalizedString.fromJson(bm['subtitulo_aula']),
        seDi: LocalizedString.fromJson(bm['se_di']),
      ),
      pensamos: BloquePensamosUi(
        numero: bpe['numero'] as String,
        titulo: LocalizedString.fromJson(bpe['titulo']),
        subtituloCasa: LocalizedString.fromJson(bpe['subtitulo_casa']),
        subtituloAula: LocalizedString.fromJson(bpe['subtitulo_aula']),
        significado: LocalizedString.fromJson(bpe['significado']),
        guia: LocalizedString.fromJson(bpe['guia']),
        observar: LocalizedString.fromJson(bpe['observar']),
        modeloAdulto: LocalizedString.fromJson(bpe['modelo_adulto']),
        idadeModo: {
          for (final e in (bpe['idade_modo'] as Map<String, dynamic>).entries)
            e.key: LocalizedString.fromJson(e.value),
        },
        momentos: {
          for (final e in (bpe['momentos'] as Map<String, dynamic>).entries)
            e.key: MomentoPensamosUi(
              orde: (e.value as Map<String, dynamic>)['orde'] as String,
              nome: LocalizedString.fromJson(e.value['nome']),
              aula: LocalizedString.fromJson(e.value['aula']),
            ),
        },
      ),
      ra: BloqueRaUi(
        numero: bra['numero'] as String,
        titulo: LocalizedString.fromJson(bra['titulo']),
        subtituloCasa: LocalizedString.fromJson(bra['subtitulo_casa']),
        subtituloAula: LocalizedString.fromJson(bra['subtitulo_aula']),
        abrirMesa: LocalizedString.fromJson(bra['abrir_mesa']),
        abrirEspello: LocalizedString.fromJson(bra['abrir_espello']),
        modoSenCamara: LocalizedString.fromJson(bra['modo_sen_camara']),
        avisoSenArcore: LocalizedString.fromJson(bra['aviso_sen_arcore']),
        avisoPrivacidade: LocalizedString.fromJson(bra['aviso_privacidade']),
      ),
      zeroDousEtiqueta: LocalizedString.fromJson(zd['etiqueta']),
      zeroDousSenPreguntas: LocalizedString.fromJson(zd['sen_preguntas']),
      zeroDousAulaNota: LocalizedString.fromJson(zd['aula_nota']),
      zeroDousPalabras: LocalizedString.fromJson(zd['palabras']),
      meses: [
        for (final m in (j['meses'] as List).cast<Map<String, dynamic>>())
          MesEstimulacionUi.fromJson(m),
      ],
    );
    if (bundle == null) _cache = parsed;
    return parsed;
  }

  static String? resolvedMesName(
          EstimulacionUi ui, int mes, AppLanguage lang) =>
      ui.mesUi(mes).nome.resolve(lang);
}
