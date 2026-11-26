import 'package:flutter/material.dart';

import '../../core/audio/offline_audio_service.dart';
import '../../core/localization/app_language.dart';
import '../../core/navigation/ruta_lua.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/leccion_model.dart';
import '../familias/nomes_familias.dart';
import 'criancas_store.dart';
import 'rexistro_crianza_screen.dart';
import 'tarxeta_escola_screen.dart';

/// Los niños de la casa, para todo el Portal Familias. El chip de arriba
/// ([SelectorIdade]) lo lee: con él dice «Uxía · 2-3 anos» y abre
/// [abrirFollaCrianza] en vez de la lista de edades. En el aula no existe.
class CrianzaDaCasa extends InheritedNotifier<CriancasStore> {
  const CrianzaDaCasa({
    super.key,
    required CriancasStore store,
    required this.onLanguageChanged,
    required this.abrirResultados,
    this.agora,
    this.audioService,
    required super.child,
  }) : super(notifier: store);

  final ValueChanged<AppLanguage> onLanguageChanged;
  final void Function(BuildContext context) abrirResultados;
  final DateTime? agora;
  final OfflineAudioService? audioService;

  CriancasStore get store => notifier!;

  static CrianzaDaCasa? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CrianzaDaCasa>();
}

/// La hoja del chip: los resultados del niño, la tarjeta para la escuela (M5),
/// los demás niños y editar/borrar.
///
/// P11.1: la lista de cursos sale de esta hoja; el curso solo se cambia dentro
/// de «Editar a …», con confirmación.
Future<void> abrirFollaCrianza(
  BuildContext context, {
  required AppLanguage language,
  required ValueChanged<String> onCambiarCurso,
}) async {
  final casa = CrianzaDaCasa.maybeOf(context);
  if (casa == null) return;
  final store = casa.store;
  final activa = store.activa;
  if (activa == null) return;
  final isGl = language == AppLanguage.gl;

  final accion = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    builder: (ctx) {
      final acento = ctx.acento;
      Widget fila({
        required Key key,
        required IconData icono,
        required String texto,
        required VoidCallback onTap,
        bool marcada = false,
        Color? cor,
      }) =>
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: marcada ? ctx.acentoTint : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusField),
                side: BorderSide(
                  color: marcada ? acento : AppTheme.border,
                  width: marcada ? 1.5 : 1,
                ),
              ),
              child: InkWell(
                key: key,
                borderRadius: BorderRadius.circular(AppTheme.radiusField),
                onTap: onTap,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 52),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Icon(icono, size: 22, color: cor ?? acento),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            texto,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  marcada ? FontWeight.w800 : FontWeight.w600,
                              color: cor ??
                                  (marcada ? acento : AppTheme.textPrimary),
                            ),
                          ),
                        ),
                        if (marcada)
                          Icon(Icons.check_rounded, color: acento, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );

      Text seccion(String t) => Text(
            t,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.textSecondary,
            ),
          );

      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            key: const Key('folla_crianza'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${activa.nome} · ${NomesFamilias.idade(activa.curso).resolve(language)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isGl
                    ? 'O xogo, as palabras e o conto son os do seu curso. Para cambiar de curso, entra en «Editar a ${activa.nome}».'
                    : 'El juego, las palabras y el cuento son los de su curso. Para cambiar de curso, entra en «Editar a ${activa.nome}».',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('crianza_resultados'),
                style: FilledButton.styleFrom(
                  backgroundColor: acento,
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.insights_rounded),
                label: Text(
                  isGl
                      ? 'Ver os resultados de ${activa.nome}'
                      : 'Ver los resultados de ${activa.nome}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                onPressed: () => Navigator.of(ctx).pop('resultados'),
              ),
              const SizedBox(height: 10),
              fila(
                key: const Key('crianza_tarxeta_escola'),
                icono: Icons.badge_rounded,
                texto:
                    isGl ? 'Tarxeta para a escola' : 'Tarjeta para la escuela',
                onTap: () => Navigator.of(ctx).pop('tarxeta_escola'),
              ),
              const SizedBox(height: 8),
              seccion(isGl ? 'NENOS DA CASA' : 'NIÑOS DE LA CASA'),
              const SizedBox(height: 8),
              for (final c in store.criancas)
                fila(
                  key: ValueKey('crianza_${c.id}'),
                  icono: Icons.child_care_rounded,
                  texto:
                      '${c.nome} · ${NomesFamilias.idade(c.curso).resolve(language)}',
                  marcada: c.id == activa.id,
                  onTap: () => Navigator.of(ctx).pop('escoller:${c.id}'),
                ),
              fila(
                key: const Key('crianza_engadir'),
                icono: Icons.person_add_alt_1_rounded,
                texto: isGl ? 'Engadir outro neno' : 'Añadir otro niño',
                onTap: () => Navigator.of(ctx).pop('engadir'),
              ),
              fila(
                key: const Key('crianza_editar'),
                icono: Icons.edit_rounded,
                texto: isGl
                    ? 'Editar a ${activa.nome}'
                    : 'Editar a ${activa.nome}',
                onTap: () => Navigator.of(ctx).pop('editar'),
              ),
              fila(
                key: const Key('crianza_borrar'),
                icono: Icons.delete_outline_rounded,
                texto: isGl
                    ? 'Borrar a ${activa.nome} deste móbil'
                    : 'Borrar a ${activa.nome} de este móvil',
                cor: AppTheme.errorInk,
                onTap: () => Navigator.of(ctx).pop('borrar'),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (accion == null || !context.mounted) return;

  Future<void> rexistro({Crianza? crianza}) => Navigator.of(context).push(
        RutaLua(
          de: context,
          builder: (_) => RexistroCrianzaScreen(
            store: store,
            language: language,
            onLanguageChanged: casa.onLanguageChanged,
            crianza: crianza,
            cursoInicial: crianza == null ? activa.curso : null,
            agora: casa.agora,
            audioService: casa.audioService,
          ),
        ),
      );

  switch (accion.split(':')) {
    case ['escoller', final id]:
      await store.escoller(id);
    case ['resultados']:
      casa.abrirResultados(context);
    case ['tarxeta_escola']:
      final lec = Leccions.lidas;
      final laminas = <String, String>{};
      if (lec != null) {
        for (final lista in lec.unidades.values) {
          for (final u in lista) {
            for (final l in u.leccions) {
              for (final p in [...l.novas, ...l.repasa]) {
                if (p.lamina != null) {
                  laminas[CriancasStore.claveRepaso(p.en)] = p.lamina!;
                }
              }
            }
          }
        }
      }
      await Navigator.of(context).push(
        RutaLua(
          de: context,
          builder: (_) => TarxetaEscolaScreen(
            store: store,
            crianza: activa,
            language: language,
            laminasPorPalabra: laminas,
          ),
        ),
      );
    case ['engadir']:
      await rexistro();
    case ['editar']:
      await rexistro(crianza: activa);
    case ['borrar']:
      final si = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            isGl ? 'Borrar a ${activa.nome}?' : '¿Borrar a ${activa.nome}?',
          ),
          content: Text(
            isGl
                ? 'Bórranse o seu nome, a idade, o curso e todo o que marcaches del. Non se pode desfacer.'
                : 'Se borran su nombre, la edad, el curso y todo lo que marcaste de él. No se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(isGl ? 'Cancelar' : 'Cancelar'),
            ),
            TextButton(
              key: const Key('crianza_borrar_si'),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                isGl ? 'Borrar' : 'Borrar',
                style: const TextStyle(color: AppTheme.errorInk),
              ),
            ),
          ],
        ),
      );
      if (si == true) await store.borrar(activa.id);
  }
}
