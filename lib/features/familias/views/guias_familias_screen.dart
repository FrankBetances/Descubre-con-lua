import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/storage/calendario_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../data/models/formacion_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../academy/views/bloques_list_screen.dart';
import '../../academy/views/guia_atencion_screen.dart';
import '../../formacion/views/formacion_screen.dart';
import '../../premios/premios_model.dart';
import '../../premios/premios_repository.dart';
import '../../premios/premios_screen.dart';
import '../nomes_familias.dart';

/// «Guías»: lo que es para la persona adulta, no para hacer hoy.
///
/// La guía de dos minutos, las lecturas de Academy, la guía de inglés en casa
/// y los premios. Antes estaban repartidos: Academy era el sexto de siete
/// módulos, la guía de inglés vivía dentro de Academy y los premios eran un
/// botón suelto al final del portal.
class GuiasFamiliasScreen extends StatelessWidget {
  const GuiasFamiliasScreen({
    super.key,
    required this.repository,
    required this.language,
    required this.onLanguageChanged,
    this.premios,
    this.calendario,
    this.audioService,
  });

  final ContentRepository repository;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final PremiosRepository? premios;
  final CalendarioStore? calendario;
  final OfflineAudioService? audioService;

  void _abrir(BuildContext context, WidgetBuilder builder) {
    Navigator.of(context).push(RutaLua(de: context, builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    final guias =
        <(String, IconData, LocalizedString, LocalizedString, WidgetBuilder)>[
      (
        'guia_antes_de_empezar',
        Icons.school_rounded,
        NomesFamilias.antesDeEmpezar,
        NomesFamilias.antesDeEmpezarDi,
        (_) => FormacionScreen(
              perfil: PerfilFormacion.familia,
              language: language,
              onLanguageChanged: onLanguageChanged,
            ),
      ),
      (
        'guia_familia',
        Icons.menu_book_rounded,
        NomesFamilias.guiasFamilia,
        NomesFamilias.guiasFamiliaDi,
        (_) => BloquesListScreen(
              repository: repository,
              premios: premios,
              calendario: calendario,
              audioService: audioService,
              initialLanguage: language,
              onLanguageChanged: onLanguageChanged,
            ),
      ),
      (
        'guia_ingles_casa',
        Icons.record_voice_over_rounded,
        NomesFamilias.inglesNaCasa,
        NomesFamilias.inglesNaCasaDi,
        (_) => GuiaAtencionScreen(
              initialLanguage: language,
              onLanguageChanged: onLanguageChanged,
              audioService: audioService,
            ),
      ),
      if (premios != null)
        (
          'guia_premios',
          Icons.military_tech_rounded,
          NomesFamilias.premios,
          NomesFamilias.premiosDi,
          (_) => PremiosScreen(
                repository: premios!,
                currentLanguage: language,
                onLanguageChanged: onLanguageChanged,
                contadores: calendario?.contadores,
                perfilInicial: Perfil.familia,
              ),
        ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: NomesFamilias.guias.resolve(language),
        language: language,
        onLanguageChanged: onLanguageChanged,
      ),
      body: SafeArea(
        child: ListView(
          key: const Key('guias_familias'),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            Text(
              language == AppLanguage.gl
                  ? 'Para ti, sen présa: o que axuda a facer o de cada día.'
                  : 'Para ti, sin prisa: lo que ayuda a hacer lo de cada día.',
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            for (final (clave, icona, nome, di, abrir) in guias) ...[
              _FilaGuia(
                clave: clave,
                icona: icona,
                nome: nome.resolve(language),
                di: di.resolve(language),
                onTap: () => _abrir(context, abrir),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilaGuia extends StatelessWidget {
  const _FilaGuia({
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
