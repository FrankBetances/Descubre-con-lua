import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/phonics_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../core/widgets/cabecera.dart';
import '../../docentes/nomes_docentes.dart';

/// Motor de misións fonémicas e conciencia fonolóxica (Phonix Quest).
class PhonixQuestScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;

  /// Avisa a quien la abrió de que se cambió de lengua aquí.
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;

  const PhonixQuestScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.audioService,
  });

  @override
  State<PhonixQuestScreen> createState() => _PhonixQuestScreenState();
}

class _PhonixQuestScreenState extends State<PhonixQuestScreen> {
  late AppLanguage _language = widget.initialLanguage;

  // Si quien la abrió la vuelve a pintar en otra lengua, se cambia; si no,
  // se quedaba en la de la primera vez.
  @override
  void didUpdateWidget(covariant PhonixQuestScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLanguage != widget.initialLanguage) {
      _language = widget.initialLanguage;
    }
  }

  void _cambiarLingua(AppLanguage lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged?.call(lang);
  }

  PhonicsTaxonomy? _taxonomy;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTaxonomy();
  }

  Future<void> _loadTaxonomy() async {
    setState(() => _isLoading = true);
    final tax = await widget.repository.loadPhonicsTaxonomy();
    if (mounted) {
      setState(() {
        _taxonomy = tax;
        _isLoading = false;
      });
    }
  }

  /// La categoría del fonema llega como clave de máquina —`short_vowel`,
  /// `magic_e`— y se enseñaba tal cual, en inglés y con guion bajo, dentro de
  /// una pantalla en galego.
  static String _categoria(String clave, AppLanguage lang) {
    const nombres = <String, List<String>>{
      'short_vowel': ['vogal curta', 'vocal corta'],
      'vowel_team': ['parella de vogais', 'pareja de vocales'],
      'r_controlled': ['vogal con r', 'vocal con r'],
      'magic_e': ['e muda final', 'e muda final'],
      'digraph': ['dígrafo', 'dígrafo'],
      'consonant': ['consoante', 'consonante'],
      'schwa': ['vogal neutra', 'vocal neutra'],
    };
    final par = nombres[clave];
    if (par == null) return clave.replaceAll('_', ' ');
    return lang == AppLanguage.gl ? par[0] : par[1];
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    final phonemes = _taxonomy?.phonemes ?? [];
    final inventario = _taxonomy?.inventario;
    final porId = {for (final p in phonemes) p.id: p};
    // Con inventario, las fichas van por fonema: primero las 24 consonantes,
    // después las 20 vocales y al final las grafías que repiten un sonido.
    final List<Widget> fichas;
    if (inventario == null) {
      fichas = [for (final ph in phonemes) _ficha(ph, lang)];
    } else {
      final enInventario = {
        for (final f in [...inventario.consoantes, ...inventario.vogais])
          f.fonema,
      };
      final outras =
          phonemes.where((p) => !enInventario.contains(p.id)).toList();
      fichas = [
        _rotulo(
            lang == AppLanguage.gl
                ? 'CONSOANTES · ${inventario.consoantes.length}'
                : 'CONSONANTES · ${inventario.consoantes.length}',
            'fonemas_consoantes'),
        for (final f in inventario.consoantes)
          if (porId[f.fonema] case final ph?) _ficha(ph, lang),
        _rotulo(
            lang == AppLanguage.gl
                ? 'VOGAIS · ${inventario.vogais.length}'
                : 'VOCALES · ${inventario.vogais.length}',
            'fonemas_vogais'),
        for (final f in inventario.vogais)
          if (porId[f.fonema] case final ph?) _ficha(ph, lang),
        if (outras.isNotEmpty) ...[
          _rotulo(
              lang == AppLanguage.gl
                  ? 'OUTRAS GRAFÍAS DUN SON XA VISTO · ${outras.length}'
                  : 'OTRAS GRAFÍAS DE UN SONIDO YA VISTO · ${outras.length}',
              'fonemas_outras'),
          for (final ph in outras) _ficha(ph, lang),
        ],
      ];
    }

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: NomesDocentes.sons.resolve(_language),
        language: _language,
        onLanguageChanged: _cambiarLingua,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.acentoTint,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.acentoTint),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.mic_rounded, color: context.acento, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang == AppLanguage.gl
                                  ? 'Guía de articulación para docentes e nais/pais'
                                  : 'Guía de articulación para docentes y madres/padres',
                              style: TextStyle(
                                color: context.acento,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lang == AppLanguage.gl
                                  ? 'Conciencia fonolóxica sintética: o adulto pronuncia o son e o neno imita sen pantallas.'
                                  : 'Conciencia fonológica sintética: el adulto pronuncia el sonido y el niño imita sin pantallas.',
                              style: TextStyle(
                                color: context.acento,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (inventario != null) ...[
                  Text(
                    lang == AppLanguage.gl
                        ? '${inventario.total} fonemas: ${inventario.consoantes.length} consoantes e ${inventario.vogais.length} vogais · ${phonemes.length} fichas'
                        : '${inventario.total} fonemas: ${inventario.consoantes.length} consonantes y ${inventario.vogais.length} vocales · ${phonemes.length} fichas',
                    key: const Key('fonemas_total'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    inventario.nota.resolve(lang),
                    key: const Key('fonemas_nota'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                ...fichas,
              ],
            ),
    );
  }

  Widget _rotulo(String texto, String clave) => Padding(
        key: Key(clave),
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: context.acento,
          ),
        ),
      );

  Widget _ficha(PhonemeDef ph, AppLanguage lang) {
    return Card(
      key: ValueKey('fonema_${ph.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.acentoTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  ph.symbolIpa,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.acento,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wrap y no fila: «OUR/URE» con la categoría al lado no cabe
                  // con el texto grande del sistema, y la fila se cortaba.
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Grafema: "${ph.grapheme.toUpperCase()}"',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.pageBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _categoria(ph.category, lang),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${lang == AppLanguage.gl ? "Exemplo" : "Ejemplo"}: '
                          '${ph.exampleWord.en} '
                          '(${lang == AppLanguage.gl ? ph.exampleWord.gl : ph.exampleWord.es})',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.acento,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Una guía de articulación sin la palabra
                      // dicha obliga a leer «abre a boca ampla» y
                      // adivinar el resultado.
                      BotonEscuchar(
                        audioService: widget.audioService,
                        texto: ph.exampleWord.en,
                        language: AppLanguage.en,
                        interfaz: lang,
                        style: estiloIngles(ph.exampleWord.en),
                        compacto: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ph.articulationGuide.resolve(lang),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
