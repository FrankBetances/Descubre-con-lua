import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../data/models/o_modelo_model.dart';

/// «O modelo / El modelo»: cómo habla la adulta (F2). Parentese, compuerta
/// social, las técnicas una a una, las etapas por edad y qué no mide la app.
///
/// La misma pantalla en Eu (aula) y en Guías (casa); solo cambia el ejemplo.
class OModeloScreen extends StatefulWidget {
  final bool paraAula;
  final AppLanguage language;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;

  const OModeloScreen({
    super.key,
    required this.paraAula,
    required this.language,
    this.onLanguageChanged,
    this.audioService,
  });

  static const nome = LocalizedString(gl: 'O modelo', es: 'El modelo');
  static const di = LocalizedString(
    gl: 'Como se fala: parentese, espera, expansión, recast e o que cabe esperar en cada idade.',
    es: 'Cómo se habla: parentese, espera, expansión, recast y lo que cabe esperar en cada edad.',
  );

  @override
  State<OModeloScreen> createState() => _OModeloScreenState();
}

class _OModeloScreenState extends State<OModeloScreen> {
  late AppLanguage _lang = widget.language;
  late final Future<OModelo> _modelo = OModelo.cargar();

  void _cambiar(AppLanguage l) {
    setState(() => _lang = l);
    widget.onLanguageChanged?.call(l);
  }

  @override
  Widget build(BuildContext context) {
    final isGl = _lang == AppLanguage.gl;
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: OModeloScreen.nome.resolve(_lang),
        language: _lang,
        onLanguageChanged: _cambiar,
      ),
      body: SafeArea(
        child: FutureBuilder<OModelo>(
          future: _modelo,
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    isGl
                        ? 'Non se puido abrir o modelo.'
                        : 'No se pudo abrir el modelo.',
                    key: const Key('modelo_erro'),
                  ),
                ),
              );
            }
            final m = snap.data;
            if (m == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              key: const Key('o_modelo'),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                Text(
                  m.intro.resolve(_lang),
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                for (final s in m.seccions) ...[
                  _Seccion(
                    seccion: s,
                    lang: _lang,
                    paraAula: widget.paraAula,
                    audioService: widget.audioService,
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final SeccionDoModelo seccion;
  final AppLanguage lang;
  final bool paraAula;
  final OfflineAudioService? audioService;

  const _Seccion({
    required this.seccion,
    required this.lang,
    required this.paraAula,
    required this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = lang == AppLanguage.gl;
    final s = seccion;
    final exemplo = paraAula ? s.exemploAula : s.exemploCasa;
    return Material(
      color: AppTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: PageStorageKey('modelo_${s.clave}'),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        iconColor: context.acento,
        title: Text(
          s.titulo.resolve(lang),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            s.que.resolve(lang),
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),
        ),
        children: [
          _Rotulo(isGl ? 'Por que funciona' : 'Por qué funciona'),
          _Corpo(s.porque.resolve(lang)),
          if (s.fonte case final f?)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${isGl ? 'Fonte' : 'Fuente'}: ${f.resolve(lang)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          if (s.como.isNotEmpty) ...[
            _Rotulo(isGl ? 'Como se fai' : 'Cómo se hace'),
            for (final (i, p) in s.como.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _Corpo('${i + 1}. ${p.resolve(lang)}'),
              ),
          ],
          if (exemplo != null) ...[
            _Rotulo(paraAula
                ? (isGl ? 'Na aula' : 'En el aula')
                : (isGl ? 'Na casa' : 'En casa')),
            _Corpo(exemplo.situacion.resolve(lang)),
            const SizedBox(height: 6),
            // La frase se ve siempre; el altavoz sale solo si hay grabación.
            Row(
              children: [
                Expanded(
                  child: Text(
                    exemplo.adulta,
                    key: ValueKey('modelo_frase_${s.clave}'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: context.acento,
                    ),
                  ),
                ),
                BotonEscuchar(
                  key: ValueKey('modelo_voz_${s.clave}'),
                  audioService: audioService,
                  texto: exemplo.adulta,
                  language: AppLanguage.en,
                  interfaz: lang,
                  compacto: true,
                ),
              ],
            ),
          ],
          for (final t in s.tramos) _Tramo(tramo: t, lang: lang),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.errorBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${isGl ? 'O que se evita' : 'Lo que se evita'}: ${s.erro.resolve(lang)}',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.errorInk,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tramo extends StatelessWidget {
  final TramoDoModelo tramo;
  final AppLanguage lang;

  const _Tramo({required this.tramo, required this.lang});

  @override
  Widget build(BuildContext context) {
    final isGl = lang == AppLanguage.gl;
    Widget lista(String rotulo, List<LocalizedString> items) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Rotulo(rotulo),
            for (final x in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: _Corpo('· ${x.resolve(lang)}'),
              ),
          ],
        );
    return Container(
      key: ValueKey('modelo_tramo_${tramo.clave}'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.acentoTint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tramo.nome.resolve(lang),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          lista(isGl ? 'Cabe esperar' : 'Cabe esperar', tramo.cabeEsperar),
          lista(isGl ? 'Non cabe esperar' : 'No cabe esperar',
              tramo.nonCabeEsperar),
          lista(isGl ? 'Que fai a adulta' : 'Qué hace la adulta',
              tramo.aAdultaFai),
        ],
      ),
    );
  }
}

class _Rotulo extends StatelessWidget {
  final String texto;
  const _Rotulo(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: context.acento,
          ),
        ),
      );
}

class _Corpo extends StatelessWidget {
  final String texto;
  const _Corpo(this.texto);

  @override
  Widget build(BuildContext context) => Text(
        texto,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.textPrimary,
          height: 1.4,
        ),
      );
}
