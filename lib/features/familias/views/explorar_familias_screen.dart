import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../data/models/steam_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../cuentos/views/cuentos_list_screen.dart';
import '../../docentes/widgets/hoxe_na_aula.dart' show DiaQueToca;
import '../../english/views/palabras_do_traxecto_screen.dart';
import '../../laminas/views/laminas_gallery_screen.dart';
import '../../lectura/views/aprender_a_ler_screen.dart';
import '../../steam/views/steam_hub_screen.dart';
import '../nomes_familias.dart';
import '../widgets/selector_idade.dart';
import 'xogos_fogar_screen.dart';

/// «Explorar»: los seis módulos de casa de un vistazo, con su nombre de casa.
///
/// Eran siete tarjetas de cuatro líneas, con dos filas de filtros delante, y
/// la de ciencia quedaba en la cuarta pantalla. Ahora son seis, en dos
/// columnas, y caben sin bajar. Cada una dice en una línea qué hay dentro.
class ExplorarFamiliasScreen extends StatelessWidget {
  const ExplorarFamiliasScreen({
    super.key,
    required this.repository,
    required this.language,
    required this.onLanguageChanged,
    required this.cursoId,
    required this.onCambiarCurso,
    required this.audioService,
    this.agora,
  });

  final ContentRepository repository;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final String cursoId;
  final ValueChanged<String> onCambiarCurso;
  final OfflineAudioService audioService;
  final DateTime? agora;

  void _abrir(BuildContext context, WidgetBuilder builder) {
    Navigator.of(context).push(RutaLua(de: context, builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    final toca = DiaQueToca.para(agora: agora);
    final modulos = <_Modulo>[
      _Modulo(
        clave: 'explorar_contos',
        icona: Icons.auto_stories_rounded,
        nome: NomesFamilias.contos,
        di: NomesFamilias.contosDi,
        abrir: (_) => CuentosListScreen(
          repository: repository,
          initialLanguage: language,
          onLanguageChanged: onLanguageChanged,
          audioService: audioService,
          initialCursoId: cursoId,
          semanaDestacada: (mes: toca.mesDoCurso, semana: toca.dia.semana),
        ),
      ),
      _Modulo(
        clave: 'explorar_ingles',
        icona: Icons.record_voice_over_rounded,
        nome: NomesFamilias.ingles,
        di: NomesFamilias.inglesDi,
        abrir: (_) => PalabrasDoTraxectoScreen(
          programa: repository.programaTprSync,
          cursoInicial: cursoId,
          language: language,
          onLanguageChanged: onLanguageChanged,
          audioService: audioService,
          agora: agora,
          titulo: NomesFamilias.ingles,
        ),
      ),
      _Modulo(
        clave: 'explorar_movemento',
        icona: Icons.directions_run_rounded,
        nome: NomesFamilias.movemento,
        di: NomesFamilias.movementoDi,
        abrir: (_) => XogosFogarScreen(
          initialLanguage: language,
          onLanguageChanged: onLanguageChanged,
          audioService: audioService,
        ),
      ),
      _Modulo(
        clave: 'explorar_ler',
        icona: Icons.abc_rounded,
        nome: NomesFamilias.ler,
        di: NomesFamilias.lerDi,
        abrir: (_) => AprenderALerScreen(
          repository: repository,
          initialLanguage: language,
          onLanguageChanged: onLanguageChanged,
          audioService: audioService,
        ),
      ),
      _Modulo(
        clave: 'explorar_laminas',
        icona: Icons.photo_library_rounded,
        nome: NomesFamilias.laminas,
        di: NomesFamilias.laminasDi,
        abrir: (_) => LaminasGalleryScreen(
          repository: repository,
          initialLanguage: language,
          onLanguageChanged: onLanguageChanged,
          audioService: audioService,
        ),
      ),
      _Modulo(
        clave: 'explorar_ciencia',
        icona: Icons.science_rounded,
        nome: NomesFamilias.ciencia,
        di: NomesFamilias.cienciaDi,
        abrir: (_) => SteamHubScreen(
          repository: repository,
          audioService: audioService,
          initialLanguage: language,
          onLanguageChanged: onLanguageChanged,
          audiencia: SteamAudiencia.hogar,
          initialCursoId: cursoId,
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: NomesFamilias.explorar.resolve(language),
        language: language,
        onLanguageChanged: onLanguageChanged,
      ),
      body: SafeArea(
        child: ListView(
          key: const Key('explorar_familias'),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SelectorIdade(
                cursoId: cursoId,
                language: language,
                onCambiar: onCambiarCurso,
              ),
            ),
            const SizedBox(height: 16),
            // Filas de dos que miden lo que pide su tarjeta más alta: con una
            // rejilla de proporción fija, la letra grande del sistema se
            // salía de la tarjeta (pasó con las láminas).
            for (var i = 0; i < modulos.length; i += 2) ...[
              if (i > 0) const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _Tesela(
                        modulo: modulos[i],
                        language: language,
                        onTap: () => _abrir(context, modulos[i].abrir),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Tesela(
                        modulo: modulos[i + 1],
                        language: language,
                        onTap: () => _abrir(context, modulos[i + 1].abrir),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Modulo {
  const _Modulo({
    required this.clave,
    required this.icona,
    required this.nome,
    required this.di,
    required this.abrir,
  });

  final String clave;
  final IconData icona;
  final LocalizedString nome;
  final LocalizedString di;
  final WidgetBuilder abrir;
}

class _Tesela extends StatelessWidget {
  const _Tesela({
    required this.modulo,
    required this.language,
    required this.onTap,
  });

  final _Modulo modulo;
  final AppLanguage language;
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
        key: ValueKey(modulo.clave),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: context.acentoTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(modulo.icona, color: context.acento, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                modulo.nome.resolve(language),
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                modulo.di.resolve(language),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
