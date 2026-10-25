import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/conto_dialogado_model.dart';
import '../../../data/models/steam_do_mes_model.dart';
import '../../../data/models/unidade_curricular_model.dart';
import '../../cuentos/views/contos_dialogados_screen.dart';
import '../../steam/views/steam_do_mes_screen.dart';

/// El rótulo numerado de cada paso del día (F10): «1 · A asemblea de hoxe».
/// Con él la pantalla se lee de arriba abajo en el orden en que se usa.
class RotuloPaso extends StatelessWidget {
  final int numero;
  final String titulo;
  final String? subtitulo;

  const RotuloPaso(
      {super.key, required this.numero, required this.titulo, this.subtitulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Semantics(
        header: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: context.acento,
              child: Text('$numero',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          height: 1.2)),
                  if (subtitulo case final s?)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(s,
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              height: 1.35)),
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

/// Una fila grande que abre una pantalla: icono, qué es y su título.
class FilaPaso extends StatelessWidget {
  final Key? claveFila;
  final IconData icona;
  final String rotulo;
  final String titulo;
  final VoidCallback onTap;

  const FilaPaso({
    super.key,
    this.claveFila,
    required this.icona,
    required this.rotulo,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      key: claveFila,
      color: AppTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: context.acentoTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icona, color: context.acento),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rotulo,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: context.acento)),
                    const SizedBox(height: 2),
                    Text(titulo,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            height: 1.25)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Los pasos del mes que siguen a la asamblea (F10): el conto de la semana
/// de los 100 dialogados y el STEAM del mes. Fuera de la tarjeta del plan,
/// cada uno con su número, para que no quede nada escondido.
class PasosDoMes extends StatefulWidget {
  final String cursoId;
  final int mesCalendario;
  final int semana;
  final AppLanguage language;
  final OfflineAudioService? audioService;
  final bool enCasa;
  final int primeiroNumero;

  const PasosDoMes({
    super.key,
    required this.cursoId,
    required this.mesCalendario,
    required this.semana,
    required this.language,
    this.audioService,
    this.enCasa = false,
    this.primeiroNumero = 3,
  });

  @override
  State<PasosDoMes> createState() => _PasosDoMesState();
}

class _PasosDoMesState extends State<PasosDoMes> {
  late final Future<(PlanCurricular?, BibliotecaDialogada?, SteamDoMes?)>
      _datos = _cargar();

  Future<(PlanCurricular?, BibliotecaDialogada?, SteamDoMes?)> _cargar() async {
    Future<T?> seguro<T>(Future<T> f) =>
        f.then<T?>((v) => v, onError: (_) => null);
    final r = await Future.wait([
      seguro(PlanCurricular.cargar()),
      seguro(BibliotecaDialogada.cargar()),
      seguro(SteamDoMes.cargar()),
    ]);
    return (
      r[0] as PlanCurricular?,
      r[1] as BibliotecaDialogada?,
      r[2] as SteamDoMes?
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    return FutureBuilder<(PlanCurricular?, BibliotecaDialogada?, SteamDoMes?)>(
      future: _datos,
      builder: (context, snap) {
        final d = snap.data;
        if (d == null) return const SizedBox.shrink();
        final (plan, biblioteca, steam) = d;
        final unidade = plan?.para(widget.cursoId, widget.mesCalendario);
        final contos = unidade == null
            ? const <ContoDialogado>[]
            : biblioteca?.daUnidade(unidade.id) ?? const <ContoDialogado>[];
        final conto = contos.isEmpty
            ? null
            : contos[(widget.semana - 1).clamp(0, 99) % contos.length];
        final experimento = steam?.para(widget.cursoId, widget.mesCalendario);
        var n = widget.primeiroNumero;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (conto != null) ...[
              RotuloPaso(
                numero: n++,
                titulo: isGl ? 'O conto da semana' : 'El cuento de la semana',
                subtitulo: isGl
                    ? 'Cóntao ti, lámina a lámina. Lúa só fala inglés.'
                    : 'Cuéntalo tú, lámina a lámina. Lúa solo habla inglés.',
              ),
              FilaPaso(
                claveFila: ValueKey('paso_conto_${conto.id}'),
                icona: Icons.auto_stories_rounded,
                rotulo:
                    '${conto.id} · ${conto.laminas.length} ${isGl ? 'LÁMINAS' : 'LÁMINAS'}',
                titulo: conto.titulo.resolve(lang),
                onTap: () => Navigator.of(context).push(RutaLua(
                  de: context,
                  builder: (_) => ContoDialogadoScreen(
                    conto: conto,
                    language: lang,
                    audioService: widget.audioService,
                  ),
                )),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const Key('paso_todos_os_contos'),
                  onPressed: () => Navigator.of(context).push(RutaLua(
                    de: context,
                    builder: (_) => ContosDialogadosScreen(
                      unidade: unidade!.id,
                      tituloUnidade: unidade.titulo.resolve(lang),
                      contos: contos,
                      language: lang,
                      audioService: widget.audioService,
                    ),
                  )),
                  icon: const Icon(Icons.library_books_rounded),
                  label: Text(isGl
                      ? 'Os ${contos.length} contos desta unidade'
                      : 'Los ${contos.length} cuentos de esta unidad'),
                ),
              ),
            ],
            if (experimento != null) ...[
              RotuloPaso(
                numero: n++,
                titulo: isGl ? 'STEAM do mes' : 'STEAM del mes',
                subtitulo: isGl
                    ? 'Ciencia coas mans, co mesmo tema da unidade.'
                    : 'Ciencia con las manos, con el mismo tema de la unidad.',
              ),
              FilaPaso(
                claveFila: ValueKey('paso_steam_${experimento.id}'),
                icona: Icons.science_rounded,
                rotulo: experimento.nomeFenomeno.resolve(lang).toUpperCase(),
                titulo: experimento.titulo.resolve(lang),
                onTap: () => Navigator.of(context).push(RutaLua(
                  de: context,
                  builder: (_) => SteamDoMesScreen(
                    experimento: experimento,
                    language: lang,
                    audioService: widget.audioService,
                    enCasa: widget.enCasa,
                  ),
                )),
              ),
            ],
          ],
        );
      },
    );
  }
}
