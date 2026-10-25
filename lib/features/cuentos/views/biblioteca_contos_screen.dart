import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../data/models/conto_dialogado_model.dart';
import '../../../data/models/unidade_curricular_model.dart';
import 'contos_dialogados_screen.dart';

/// Los 100 cuentos dialogados, por unidad del plan curricular (F10): la
/// biblioteca entera, para buscar uno fuera del día.
class BibliotecaContosScreen extends StatefulWidget {
  final AppLanguage language;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;

  const BibliotecaContosScreen({
    super.key,
    required this.language,
    this.onLanguageChanged,
    this.audioService,
  });

  @override
  State<BibliotecaContosScreen> createState() => _BibliotecaContosScreenState();
}

class _BibliotecaContosScreenState extends State<BibliotecaContosScreen> {
  late AppLanguage _lang = widget.language;
  late final Future<(PlanCurricular, BibliotecaDialogada)> _datos =
      Future.wait([PlanCurricular.cargar(), BibliotecaDialogada.cargar()])
          .then((r) => (r[0] as PlanCurricular, r[1] as BibliotecaDialogada));

  @override
  Widget build(BuildContext context) {
    final lang = _lang;
    final isGl = lang == AppLanguage.gl;
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: isGl ? 'Os 100 contos' : 'Los 100 cuentos',
        language: lang,
        onLanguageChanged: (l) {
          setState(() => _lang = l);
          widget.onLanguageChanged?.call(l);
        },
      ),
      body: SafeArea(
        child: FutureBuilder<(PlanCurricular, BibliotecaDialogada)>(
          future: _datos,
          builder: (context, snap) {
            final d = snap.data;
            if (d == null) {
              return Center(
                  child: snap.hasError
                      ? Text(isGl
                          ? 'Non se puideron abrir os contos.'
                          : 'No se pudieron abrir los cuentos.')
                      : const CircularProgressIndicator());
            }
            final (plan, biblioteca) = d;
            return ListView(
              key: const Key('biblioteca_contos'),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                Text(
                  isGl
                      ? 'Agrupados pola unidade do plan curricular. O de cada semana sae en Hoxe.'
                      : 'Agrupados por la unidad del plan curricular. El de cada semana sale en Hoy.',
                  style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      height: 1.35),
                ),
                const SizedBox(height: 12),
                for (final u in plan.unidades)
                  if (biblioteca.daUnidade(u.id) case final contos
                      when contos.isNotEmpty)
                    Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        key: ValueKey('biblioteca_unidade_${u.id}'),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        title: Text(u.titulo.resolve(lang),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                        subtitle: Text(
                            '${contos.length} ${isGl ? 'contos' : 'cuentos'}',
                            style: const TextStyle(fontSize: 14)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.of(context).push(RutaLua(
                          de: context,
                          builder: (_) => ContosDialogadosScreen(
                            unidade: u.id,
                            tituloUnidade: u.titulo.resolve(lang),
                            contos: contos,
                            language: lang,
                            audioService: widget.audioService,
                          ),
                        )),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}
