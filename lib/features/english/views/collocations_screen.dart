import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../core/widgets/cabecera.dart';

/// Explorador de colocaciones y patrones sintácticos de inglés.
///
/// Las colocaciones salen de `assets/content/english/collocations_grammar.json`.
/// Antes eran trece escritas DENTRO de este widget —fuera del alcance de los
/// gates de contenido y sin grabación— mientras el JSON, con otras diez, no lo
/// leía ninguna pantalla.
class CollocationsScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;

  /// Avisa a quien la abrió de que se cambió de lengua aquí.
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;

  /// Para los tests: lee el JSON del disco en vez del paquete.
  final Future<String> Function(String path)? stringLoader;

  const CollocationsScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.audioService,
    this.stringLoader,
  });

  static const String asset =
      'assets/content/english/collocations_grammar.json';

  @override
  State<CollocationsScreen> createState() => _CollocationsScreenState();
}

class _CollocationsScreenState extends State<CollocationsScreen> {
  void _cambiarLingua(AppLanguage lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged?.call(lang);
  }

  late AppLanguage _language;
  List<Map<String, dynamic>>? _colocacions;

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _cargar();
  }

  Future<void> _cargar() async {
    final ler = widget.stringLoader ?? rootBundle.loadString;
    List<Map<String, dynamic>> lista;
    try {
      final data = jsonDecode(await ler(CollocationsScreen.asset)) as Map;
      lista = [
        for (final c in data['collocations'] as List? ?? const [])
          if (c is Map) Map<String, dynamic>.from(c),
      ];
    } catch (_) {
      lista = const [];
    }
    if (mounted) setState(() => _colocacions = lista);
  }

  String _txt(Object? m) {
    if (m is! Map) return '';
    return (_language == AppLanguage.gl ? m['gl'] : m['es'])?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    final isGl = lang == AppLanguage.gl;
    final colocacions = _colocacions;

    // Por tipo, en el orden en que aparece cada tipo por primera vez.
    final porTipo = <String, List<Map<String, dynamic>>>{};
    for (final c in colocacions ?? const <Map<String, dynamic>>[]) {
      porTipo.putIfAbsent(c['type']?.toString() ?? '', () => []).add(c);
    }

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: isGl ? 'Colocacións' : 'Colocaciones',
        language: _language,
        onLanguageChanged: _cambiarLingua,
      ),
      body: colocacions == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              key: const Key('colocacions_lista'),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  isGl
                      ? '${colocacions.length} combinacións que o inglés di sempre xuntas: dilas enteiras, non palabra a palabra.'
                      : '${colocacions.length} combinaciones que el inglés dice siempre juntas: dilas enteras, no palabra a palabra.',
                  key: const Key('colocacions_total'),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                for (final entrada in porTipo.entries) ...[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Text(
                      '${_txt(entrada.value.first['typeLabel'])} · ${entrada.value.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: context.acento,
                      ),
                    ),
                  ),
                  for (final c in entrada.value) _tarxeta(c),
                  const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }

  Widget _tarxeta(Map<String, dynamic> c) {
    final full = c['fullCollocation']?.toString() ?? '';
    final contexto = c['naturalContext']?.toString() ?? '';
    final consello = _txt(c['tip']);
    return Card(
      key: ValueKey('colocacion_${c['id']}'),
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // La colocación en pastilla: se ve lo que se va a decir y se oye
            // en el mismo gesto. Sin grabación, queda el texto sin altavoz.
            BotonEscuchar(
              audioService: widget.audioService,
              texto: full,
              language: AppLanguage.en,
              interfaz: _language,
              style: estiloIngles(full),
              comoChip: true,
              colorChip: context.acento,
              descripcion: full,
            ),
            const SizedBox(height: 6),
            Text(
              _txt(c['translation']),
              style: TextStyle(
                fontSize: 13.5,
                color: context.acento,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (contexto.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '"$contexto"',
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  BotonEscuchar(
                    audioService: widget.audioService,
                    texto: contexto,
                    language: AppLanguage.en,
                    interfaz: _language,
                    style: estiloIngles(contexto),
                    compacto: true,
                  ),
                ],
              ),
            ],
            if (consello.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                consello,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
