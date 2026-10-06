import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../data/models/ponte_ao_dia_model.dart';
import '../../calendario/widgets/palabras_do_dia.dart' show PalabraConXesto;
import '../../juega/widgets/aula_ciclo_panel.dart' show nomeDoMes;
import '../nomes_familias.dart';
import '../widgets/selector_idade.dart';

/// Ponte ao día: para a crianza que chega nova a un curso xa empezado.
///
/// As palabras que as asembleas do mes dan por sabidas, porque o curso as
/// ensinou antes, repartidas en días de dúas ou tres, co seu xesto e a súa
/// voz. A familia elixe a idade e o mes, e nada diso se garda: a app non sabe
/// quen chegou novo, nin o pregunta.
class PonteAoDiaScreen extends StatefulWidget {
  const PonteAoDiaScreen({
    super.key,
    required this.ponte,
    required this.cursoId,
    required this.mes,
    required this.language,
    this.onLanguageChanged,
    this.onCambiarCurso,
    this.audioService,
  });

  final PonteAoDia ponte;

  /// A idade coa que se abre (`curso_4_5`…) e o mes do curso (1-12).
  final String cursoId;
  final int mes;

  final AppLanguage language;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  /// A idade é a mesma en todo o portal: cambiala aquí cámbiaa tamén fóra.
  final ValueChanged<String>? onCambiarCurso;
  final OfflineAudioService? audioService;

  /// Os meses do curso escolar, na súa orde.
  static const meses = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6];

  /// As palabras en días de dúas ou tres: os días que fagan falta para que
  /// ningún leve máis de tres, e os primeiros levan as que sobran. Así doce
  /// son catro días de tres, e oito son tres, tres e dúas.
  static List<List<T>> enDias<T>(List<T> palabras) {
    if (palabras.isEmpty) return const [];
    final dias = (palabras.length + 2) ~/ 3;
    final base = palabras.length ~/ dias;
    final sobran = palabras.length % dias;
    final saida = <List<T>>[];
    var desde = 0;
    for (var d = 0; d < dias; d++) {
      final cantas = base + (d < sobran ? 1 : 0);
      saida.add(palabras.sublist(desde, desde + cantas));
      desde += cantas;
    }
    return saida;
  }

  @override
  State<PonteAoDiaScreen> createState() => _PonteAoDiaScreenState();
}

class _PonteAoDiaScreenState extends State<PonteAoDiaScreen> {
  late AppLanguage _language = widget.language;
  late String _curso = widget.cursoId;
  late int _mes = widget.mes;

  void _cambiarLingua(AppLanguage lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged?.call(lang);
  }

  String _texto(String clave, [Map<String, String> valores = const {}]) {
    var t = widget.ponte.texto('casa', clave).resolve(_language);
    valores.forEach((k, v) => t = t.replaceAll('{$k}', v));
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    final palabras = widget.ponte.doMes(_curso, _mes);
    final dias = PonteAoDiaScreen.enDias(palabras);
    final nomeMes = nomeDoMes[_mes]?.resolve(lang).toLowerCase() ?? '';

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: _texto('titulo'),
        language: lang,
        onLanguageChanged: _cambiarLingua,
      ),
      body: SafeArea(
        child: ListView(
          key: const ValueKey('ponte_ao_dia'),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            Text(
              _texto('intro'),
              style: const TextStyle(
                fontSize: 15.5,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: SelectorIdade(
                cursoId: _curso,
                language: lang,
                onCambiar: (c) {
                  setState(() => _curso = c);
                  widget.onCambiarCurso?.call(c);
                },
              ),
            ),
            const SizedBox(height: 12),
            // Wrap e non fila con desprazamento: con letra grande os meses
            // baixan de liña e vense todos.
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final m in PonteAoDiaScreen.meses)
                  ChoiceChip(
                    key: ValueKey('ponte_mes_$m'),
                    label: Text(nomeDoMes[m]?.resolve(lang) ?? ''),
                    selected: m == _mes,
                    onSelected: (sel) {
                      if (sel && m != _mes) setState(() => _mes = m);
                    },
                    showCheckmark: false,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _texto('naoSeGarda'),
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            if (palabras.isEmpty)
              Container(
                key: const ValueKey('ponte_ao_dia_baleiro'),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  _texto('baleiro', {
                    'mes': nomeMes,
                    'idade': NomesFamilias.idade(_curso).resolve(lang),
                  }),
                  style: const TextStyle(
                    fontSize: 15.5,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              )
            else
              for (var d = 0; d < dias.length; d++) ...[
                Semantics(
                  header: true,
                  child: Text(
                    _texto('dia', {'n': '${d + 1}'}).toUpperCase(),
                    key: ValueKey('ponte_dia_${d + 1}'),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final p in dias[d])
                        PalabraConXesto(
                          key: ValueKey('ponte_palabra_${p.id}'),
                          palabra: p.comoPalabraTpr,
                          language: lang,
                          audioService: widget.audioService,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
          ],
        ),
      ),
    );
  }
}
