import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/codigo_casa.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../data/models/unidade_do_mes_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../calendario/widgets/nucleo_do_mes.dart';
import '../widgets/reto_da_semana.dart';

/// Lo que abre el código que da la escuela (P10): el núcleo del mes, el reto
/// de esa semana y qué mirar. Es lo que antes iría en un imprimible.
///
/// El código no se guarda: al salir de la pantalla se olvida.
class CodigoDaEscolaScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage language;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;

  const CodigoDaEscolaScreen({
    super.key,
    required this.repository,
    required this.language,
    this.onLanguageChanged,
    this.audioService,
  });

  @override
  State<CodigoDaEscolaScreen> createState() => _CodigoDaEscolaScreenState();
}

class _CodigoDaEscolaScreenState extends State<CodigoDaEscolaScreen> {
  late AppLanguage _lang = widget.language;
  final _texto = TextEditingController();
  CodigoCasa? _codigo;
  Future<UnidadeDoMes?>? _unidade;
  bool _erro = false;

  void _cambiar(AppLanguage l) {
    setState(() => _lang = l);
    widget.onLanguageChanged?.call(l);
  }

  void _abrir() {
    final c = CodigoCasa.ler(_texto.text);
    setState(() {
      _erro = c == null;
      _codigo = c;
      _unidade = c == null
          ? null
          : widget.repository.loadUnidadeDoMes(c.cursoId, c.mesCalendario);
    });
  }

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGl = _lang == AppLanguage.gl;
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: isGl ? 'O código da escola' : 'El código de la escuela',
        language: _lang,
        onLanguageChanged: _cambiar,
      ),
      body: SafeArea(
        child: ListView(
          key: const Key('codigo_escola'),
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              isGl
                  ? 'Escribe o código que vén na nota da escola. Abre o núcleo do mes, o reto desa semana e que mirar. Non se garda.'
                  : 'Escribe el código que viene en la nota de la escuela. Abre el núcleo del mes, el reto de esa semana y qué mirar. No se guarda.',
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('codigo_campo'),
                    controller: _texto,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _abrir(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                    decoration: InputDecoration(
                      hintText: '45-11-1',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  key: const Key('codigo_abrir'),
                  onPressed: _abrir,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(64, 56),
                    backgroundColor: context.acento,
                  ),
                  child: Text(isGl ? 'Abrir' : 'Abrir'),
                ),
              ],
            ),
            if (_erro) ...[
              const SizedBox(height: 8),
              Text(
                isGl
                    ? 'Ese código non existe. Son cinco números: curso, mes e semana (por exemplo, 45-11-1).'
                    : 'Ese código no existe. Son cinco números: curso, mes y semana (por ejemplo, 45-11-1).',
                key: const Key('codigo_erro'),
                style: const TextStyle(
                  fontSize: 14.5,
                  color: AppTheme.errorInk,
                  height: 1.35,
                ),
              ),
            ],
            if (_unidade case final f?)
              FutureBuilder<UnidadeDoMes?>(
                future: f,
                builder: (context, snap) {
                  final u = snap.data;
                  final c = _codigo;
                  if (u == null || c == null) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    key: ValueKey('codigo_resultado_${c.texto}'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 18),
                      Text(
                        u.centroInteres.resolve(_lang),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      NucleoDoMes(
                        unidade: u,
                        nucleo: widget.repository.nucleoSync(u),
                        contraste: widget.repository.contrasteSync(u),
                        language: _lang,
                        audioService: widget.audioService,
                        enCasa: true,
                      ),
                      if (u.hogar case final h?) ...[
                        const SizedBox(height: 12),
                        RetoDaSemana(
                          hogar: h,
                          semana: c.semana,
                          language: _lang,
                          audioService: widget.audioService,
                        ),
                      ],
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
