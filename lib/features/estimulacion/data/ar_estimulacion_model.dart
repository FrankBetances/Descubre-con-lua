import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';

class ArEventoEscena {
  final String id;
  final LocalizedString label;
  final LocalizedString prompt;
  final String englishPhrase;

  const ArEventoEscena({
    required this.id,
    required this.label,
    required this.prompt,
    required this.englishPhrase,
  });

  factory ArEventoEscena.fromJson(Map<String, dynamic> j) => ArEventoEscena(
        id: j['id'] as String,
        label: LocalizedString(
          gl: j['label_gl'] as String,
          es: j['label_es'] as String,
        ),
        prompt: LocalizedString(
          gl: j['prompt_gl'] as String,
          es: j['prompt_es'] as String,
        ),
        englishPhrase: j['englishPhrase'] as String,
      );
}

class ArActividadFacial {
  final String id;
  final String code;
  final String modelAsset;
  final String animation;
  final String gestureMode;
  final LocalizedString titulo;
  final LocalizedString guia;
  final String fraseEn;
  final LocalizedString sig;
  final String? lamina;

  const ArActividadFacial({
    required this.id,
    required this.code,
    required this.modelAsset,
    required this.animation,
    required this.gestureMode,
    required this.titulo,
    required this.guia,
    required this.fraseEn,
    required this.sig,
    this.lamina,
  });

  factory ArActividadFacial.fromJson(Map<String, dynamic> j) =>
      ArActividadFacial(
        id: j['id'] as String,
        code: j['code'] as String,
        modelAsset: j['modelAsset'] as String,
        animation: j['animation'] as String,
        gestureMode: j['gestureMode'] as String,
        titulo: LocalizedString(
          gl: j['titulo_gl'] as String,
          es: j['titulo_es'] as String,
        ),
        guia: LocalizedString(
          gl: j['guia_gl'] as String,
          es: j['guia_es'] as String,
        ),
        fraseEn: j['frase_en'] as String,
        sig: LocalizedString.fromJson(j['sig'] as Map<String, dynamic>),
        lamina: j['lamina'] as String?,
      );

  String toNativeSpecJson(AppLanguage lang) => jsonEncode({
        'title': titulo.resolve(lang),
        'adultHint': guia.resolve(lang),
        'englishPhrase': fraseEn,
        'closeLabel': lang == AppLanguage.gl ? 'Pechar' : 'Cerrar',
        'gestureMode': gestureMode,
        'modelAsset': modelAsset,
        'animation': animation,
      });
}

class ArEscenaMensual {
  final String id;
  final String curso;
  final int mes;
  final String fenomeno;
  final String steamId;
  final LocalizedString steamTitulo;
  final String valeriaSceneId;
  final LocalizedString titulo;
  final LocalizedString guiaAdulto;
  final String parA;
  final String parB;
  final String fonema;
  final String fraseCenaEn;
  final LocalizedString fraseCenaSig;
  final List<String> palabrasEn;
  final List<String> frasesEn;
  final String faceId;
  final LocalizedString fallbackInstrucion;
  final List<String> laminasSuporte;
  final Map<String, dynamic> rawSceneSpec;
  final List<ArEventoEscena> eventos;

  const ArEscenaMensual({
    required this.id,
    required this.curso,
    required this.mes,
    required this.fenomeno,
    required this.steamId,
    required this.steamTitulo,
    required this.valeriaSceneId,
    required this.titulo,
    required this.guiaAdulto,
    required this.parA,
    required this.parB,
    required this.fonema,
    required this.fraseCenaEn,
    required this.fraseCenaSig,
    required this.palabrasEn,
    required this.frasesEn,
    required this.faceId,
    required this.fallbackInstrucion,
    required this.laminasSuporte,
    required this.rawSceneSpec,
    required this.eventos,
  });

  factory ArEscenaMensual.fromJson(Map<String, dynamic> j) {
    final par = j['par'] as Map<String, dynamic>;
    final fb = j['fallback'] as Map<String, dynamic>;
    final spec = j['scene_spec'] as Map<String, dynamic>;
    return ArEscenaMensual(
      id: j['id'] as String,
      curso: j['curso'] as String,
      mes: j['mes'] as int,
      fenomeno: j['fenomeno'] as String,
      steamId: j['steam_id'] as String,
      steamTitulo:
          LocalizedString.fromJson(j['steam_titulo'] as Map<String, dynamic>),
      valeriaSceneId: j['valeria_scene_id'] as String,
      titulo: LocalizedString.fromJson(j['titulo'] as Map<String, dynamic>),
      guiaAdulto:
          LocalizedString.fromJson(j['guia_adulto'] as Map<String, dynamic>),
      parA: par['a'] as String,
      parB: par['b'] as String,
      fonema: (par['fonema'] ?? '') as String,
      fraseCenaEn: j['frase_cena_en'] as String,
      fraseCenaSig:
          LocalizedString.fromJson(j['frase_cena_sig'] as Map<String, dynamic>),
      palabrasEn: [
        for (final x in (j['palabras_en'] as List)) x.toString(),
      ],
      frasesEn: [
        for (final x in (j['frases_en'] as List)) x.toString(),
      ],
      faceId: j['face_id'] as String,
      fallbackInstrucion:
          LocalizedString.fromJson(fb['instrucion'] as Map<String, dynamic>),
      laminasSuporte: [
        for (final x in (fb['laminas_suporte'] as List))
          if (x.toString().isNotEmpty) x.toString(),
      ],
      rawSceneSpec: spec,
      eventos: [
        for (final e in (spec['events'] as List))
          ArEventoEscena.fromJson(e as Map<String, dynamic>),
      ],
    );
  }

  String toNativeSpecJson(AppLanguage lang) {
    return jsonEncode({
      'title': LocalizedString.fromJson(
              rawSceneSpec['title'] as Map<String, dynamic>)
          .resolve(lang),
      'placeHint': LocalizedString.fromJson(
              rawSceneSpec['placeHint'] as Map<String, dynamic>)
          .resolve(lang),
      'searchHint': LocalizedString.fromJson(
              rawSceneSpec['searchHint'] as Map<String, dynamic>)
          .resolve(lang),
      'closeLabel': LocalizedString.fromJson(
              rawSceneSpec['closeLabel'] as Map<String, dynamic>)
          .resolve(lang),
      'replaceLabel': LocalizedString.fromJson(
              rawSceneSpec['replaceLabel'] as Map<String, dynamic>)
          .resolve(lang),
      'luaPrefix': rawSceneSpec['luaPrefix'] ?? 'Lúa: ',
      'events': [
        for (final ev in eventos)
          {
            'id': ev.id,
            'label': ev.label.resolve(lang),
            'prompt': ev.prompt.resolve(lang),
            'englishPhrase': ev.englishPhrase,
          },
      ],
      'shapes': rawSceneSpec['shapes'] ?? const [],
    });
  }
}

class ArEstimulacionPlan {
  static const asset = 'assets/content/escoita/ar_estimulacion.json';
  static ArEstimulacionPlan? _cache;

  final List<ArActividadFacial> actividadesFaciais;
  final List<ArEscenaMensual> escenas;

  const ArEstimulacionPlan({
    required this.actividadesFaciais,
    required this.escenas,
  });

  static Future<ArEstimulacionPlan> cargar({AssetBundle? bundle}) async {
    final c = _cache;
    if (c != null && bundle == null) return c;
    final b = bundle ?? rootBundle;
    final j = jsonDecode(await b.loadString(asset)) as Map<String, dynamic>;
    final parsed = ArEstimulacionPlan(
      actividadesFaciais: [
        for (final x in (j['actividades_faciais'] as List))
          ArActividadFacial.fromJson(x as Map<String, dynamic>),
      ],
      escenas: [
        for (final x in (j['escenas'] as List))
          ArEscenaMensual.fromJson(x as Map<String, dynamic>),
      ],
    );
    if (bundle == null) _cache = parsed;
    return parsed;
  }

  ArEscenaMensual? escenaDe(String cursoId, int mes) {
    final effectiveCurso = cursoId == 'curso_0_2' ? 'curso_2_3' : cursoId;
    for (final e in escenas) {
      if (e.curso == effectiveCurso && e.mes == mes) return e;
    }
    return escenas.isNotEmpty ? escenas.first : null;
  }

  ArActividadFacial? facialDe(String id) {
    for (final f in actividadesFaciais) {
      if (f.id == id) return f;
    }
    return actividadesFaciais.isNotEmpty ? actividadesFaciais.first : null;
  }
}
