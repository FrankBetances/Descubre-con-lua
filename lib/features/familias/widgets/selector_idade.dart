import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../nomes_familias.dart';

/// La edad de la criatura, en un solo chip: «0-2 anos ▾».
///
/// Antes eran cinco pastillas en fila en cada pantalla, y la portada empezaba
/// por elegir. Se elige una vez, arriba, y vale para Hoxe, el calendario y
/// Explorar. No se guarda: dura mientras la app está abierta.
class SelectorIdade extends StatelessWidget {
  const SelectorIdade({
    super.key,
    required this.cursoId,
    required this.language,
    required this.onCambiar,
    this.paraAula = false,
  });

  final String cursoId;
  final AppLanguage language;
  final ValueChanged<String> onCambiar;

  /// En el aula se elige el grupo, no la edad de una criatura.
  final bool paraAula;

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final idade = NomesFamilias.idade(cursoId).resolve(language);
    return Semantics(
      button: true,
      label: paraAula
          ? 'Grupo: $idade. Cambiar'
          : (isGl ? 'Idade: $idade. Cambiar' : 'Edad: $idade. Cambiar'),
      // Excluir a los hijos quita también la acción del InkWell.
      onTap: () => _abrir(context),
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        shape: StadiumBorder(
          side: BorderSide(color: context.acento.withAlpha(110), width: 1.5),
        ),
        child: InkWell(
          key: const ValueKey('selector_idade'),
          customBorder: const StadiumBorder(),
          onTap: () => _abrir(context),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppTheme.touchMin),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.child_care_rounded,
                      size: 20, color: context.acento),
                  const SizedBox(width: 6),
                  Text(
                    idade,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: context.acento,
                    ),
                  ),
                  Icon(Icons.expand_more_rounded,
                      size: 22, color: context.acento),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _abrir(BuildContext context) async {
    final isGl = language == AppLanguage.gl;
    final elixido = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      // La hoja mide lo que pide su contenido. Con la altura por defecto
      // (9/16 de la pantalla) las cinco edades no cabían a 360 × 780, y con
      // la letra grande del sistema todavía menos: por eso además se desplaza.
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                paraAula
                    ? (isGl ? 'O teu grupo' : 'Tu grupo')
                    : (isGl ? 'Que idade ten?' : '¿Qué edad tiene?'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                paraAula
                    ? (isGl
                        ? 'A asemblea, as palabras e o conto son os do teu grupo. Non se garda.'
                        : 'La asamblea, las palabras y el cuento son los de tu grupo. No se guarda.')
                    : (isGl
                        ? 'O xogo, as palabras e o conto cambian coa idade. Non se garda.'
                        : 'El juego, las palabras y el cuento cambian con la edad. No se guarda.'),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              for (final (id, nome) in NomesFamilias.idades)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _OpcionIdade(
                    key: ValueKey('idade_$id'),
                    texto: nome.resolve(language),
                    elixida: id == cursoId,
                    onTap: () => Navigator.of(ctx).pop(id),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (elixido != null && elixido != cursoId) onCambiar(elixido);
  }
}

class _OpcionIdade extends StatelessWidget {
  const _OpcionIdade({
    super.key,
    required this.texto,
    required this.elixida,
    required this.onTap,
  });

  final String texto;
  final bool elixida;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: elixida ? context.acentoTint : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        side: BorderSide(
          color: elixida ? context.acento : AppTheme.border,
          width: elixida ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    texto,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: elixida ? FontWeight.w800 : FontWeight.w600,
                      color: elixida ? context.acento : AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (elixida)
                  Icon(Icons.check_rounded, color: context.acento, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
