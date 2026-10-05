import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Una fila que lleva a una pantalla: icono, nombre, qué hay dentro y flecha.
///
/// Es la misma en los dos portales —Guías de casa, Recursos y Eu del aula—
/// para que «esto abre algo» se lea igual en toda la app. El nombre dice qué
/// es; la línea de debajo, qué se encuentra dentro, en palabras de quien la
/// usa.
class FilaPortal extends StatelessWidget {
  const FilaPortal({
    super.key,
    required this.clave,
    required this.icona,
    required this.nome,
    required this.di,
    required this.onTap,
  });

  final String clave;
  final IconData icona;
  final String nome;
  final String di;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey(clave),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.acentoTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icona, color: context.acento, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      di,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
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

/// El rótulo de un grupo de filas: «PARA A ASEMBLEA», «INGLÉS»…
class RotuloGrupo extends StatelessWidget {
  const RotuloGrupo(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
        child: Text(
          texto.toUpperCase(),
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
