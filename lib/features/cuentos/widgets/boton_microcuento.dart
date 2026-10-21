import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/microcuento_model.dart';
import '../../../data/models/rexistro_frases_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../views/microcuento_screen.dart';

/// La puerta al microcuento de la unidad de un curso y un mes (M5.8).
///
/// La misma en el aula (Modo Aula, debajo de «Comezar a asemblea») y en casa
/// (Explorar → Cuentos, delante de la lista). No pinta nada si la unidad no
/// tiene microcuento —0-2 años no lo tiene— o si a alguna de sus láminas le
/// falta el dibujo: sin lámina, el microcuento no entra (arquitectura,
/// apartado 5).
class BotonMicrocuento extends StatefulWidget {
  final ContentRepository repository;
  final String cursoId;
  final int mesCalendario;
  final ModoMicrocuento modo;
  final AppLanguage language;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;

  const BotonMicrocuento({
    super.key,
    required this.repository,
    required this.cursoId,
    required this.mesCalendario,
    required this.modo,
    required this.language,
    this.onLanguageChanged,
    this.audioService,
  });

  @override
  State<BotonMicrocuento> createState() => _BotonMicrocuentoState();
}

class _BotonMicrocuentoState extends State<BotonMicrocuento> {
  Microcuento? _mc;
  RexistroDeFrases? _rexistro;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void didUpdateWidget(BotonMicrocuento old) {
    super.didUpdateWidget(old);
    if (old.cursoId != widget.cursoId ||
        old.mesCalendario != widget.mesCalendario) {
      _cargar();
    }
  }

  Future<void> _cargar() async {
    final repo = widget.repository;
    // Lo que ya esté leído se usa sin esperar.
    final ya = repo.unidadeDoMesSync(widget.cursoId, widget.mesCalendario);
    if (ya != null && repo.rexistroFrasesSync != null) {
      setState(() {
        _mc = ya.microcuento;
        _rexistro = repo.rexistroFrasesSync;
      });
      return;
    }
    final unidade =
        await repo.loadUnidadeDoMes(widget.cursoId, widget.mesCalendario);
    final rexistro = await repo.loadRexistroFrases();
    if (!mounted) return;
    setState(() {
      _mc = unidade?.microcuento;
      _rexistro = rexistro;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mc = _mc;
    if (mc == null || !mc.debuxado || _rexistro == null) {
      return const SizedBox.shrink();
    }
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spaceSm),
      child: OutlinedButton.icon(
        key: ValueKey('microcuento_${widget.modo.name}'),
        onPressed: () => Navigator.of(context).push(RutaLua(
          de: context,
          builder: (_) => MicrocuentoScreen(
            microcuento: mc,
            modo: widget.modo,
            rexistro: _rexistro,
            language: lang,
            onLanguageChanged: widget.onLanguageChanged,
            audioService: widget.audioService,
          ),
        )),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppTheme.touchMin),
          foregroundColor: context.acento,
          side: BorderSide(color: context.acento),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        icon: const Icon(Icons.forum_rounded),
        label: Text(
          '${isGl ? 'Microconto do mes' : 'Microcuento del mes'}: '
          '${mc.titulo.resolve(lang)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
