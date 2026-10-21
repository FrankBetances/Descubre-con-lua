import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/storage/calendario_store.dart';
import '../../../core/theme/app_theme.dart';

/// Un punto de la lista de práctica.
class PuntoDePractica {
  final String id;
  final Set<String> perfis;
  final LocalizedString texto;

  const PuntoDePractica(this.id, this.perfis, this.texto);
}

/// La lista de práctica, leída de `assets/content/modelo/practica.json`.
class ContidoDePractica {
  final LocalizedString titulo;
  final LocalizedString nota;
  final List<PuntoDePractica> items;

  const ContidoDePractica(this.titulo, this.nota, this.items);

  static const assetPath = 'assets/content/modelo/practica.json';

  factory ContidoDePractica.fromRaw(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    LocalizedString t(Object? v) =>
        LocalizedString.fromJson(Map<String, dynamic>.from(v as Map));
    return ContidoDePractica(
      t(j['titulo']),
      t(j['nota']),
      [
        for (final i in (j['items'] as List).cast<Map>())
          PuntoDePractica(
            i['id'] as String,
            {...(i['perfis'] as List).cast<String>()},
            t(i['texto']),
          ),
      ],
    );
  }

  static Future<ContidoDePractica>? _enCurso;
  static Future<ContidoDePractica> cargar() => _enCurso ??=
      rootBundle.loadString(assetPath).then(ContidoDePractica.fromRaw);
}

/// «Hoxe fixen / Hoy hice»: al final de Hoy, lo que la persona adulta hizo
/// ella (P7). Se marca y se desmarca; se guarda el día sin hora y los ids.
class ListaDePracticaCard extends StatelessWidget {
  final CalendarioStore store;

  /// `aula` o `hogar`.
  final String perfil;
  final DateTime dia;
  final AppLanguage language;

  const ListaDePracticaCard({
    super.key,
    required this.store,
    required this.perfil,
    required this.dia,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ContidoDePractica>(
      future: ContidoDePractica.cargar(),
      builder: (context, snap) {
        final c = snap.data;
        if (c == null) return const SizedBox.shrink();
        return ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final feitos = store.practicaDoDia(dia, perfil);
            // Material y no Container: el CheckboxListTile pinta su toque en
            // el Material más cercano, y un fondo intermedio lo taparía.
            return Material(
              key: ValueKey('practica_$perfil'),
              color: AppTheme.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                side: const BorderSide(color: AppTheme.border),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        c.titulo.resolve(language).toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: context.acento,
                        ),
                      ),
                    ),
                    for (final p in c.items)
                      if (p.perfis.contains(perfil))
                        CheckboxListTile(
                          key: ValueKey('practica_${perfil}_${p.id}'),
                          value: feitos.contains(p.id),
                          onChanged: (_) =>
                              store.alternarPractica(dia, perfil, p.id),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          activeColor: context.acento,
                          title: Text(
                            p.texto.resolve(language),
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                      child: Text(
                        c.nota.resolve(language),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
