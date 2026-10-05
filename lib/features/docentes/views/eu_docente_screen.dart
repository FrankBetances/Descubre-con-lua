import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/storage/calendario_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../core/widgets/fila_portal.dart';
import '../../../data/models/formacion_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../formacion/views/formacion_screen.dart';
import '../../juega/views/capsulas_aula_screen.dart';
import '../../premios/premios_model.dart';
import '../../premios/premios_repository.dart';
import '../../premios/widgets/lua_game_strip.dart';
import '../nomes_docentes.dart';

/// «Eu»: lo que es de la persona docente, no del aula.
///
/// Su nivel y su racha —la tira de Lúa, con su puerta a los premios—, la guía
/// de dos minutos y las lecturas de formación. Antes la tira ocupaba lo alto
/// del Modo Aula, por encima de la asamblea, y las lecturas de formación no
/// tenían ninguna puerta.
class EuDocenteScreen extends StatelessWidget {
  const EuDocenteScreen({
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
    final isGl = language == AppLanguage.gl;
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: NomesDocentes.eu.resolve(language),
        language: language,
        onLanguageChanged: onLanguageChanged,
      ),
      body: SafeArea(
        child: ListView(
          key: const Key('eu_docente'),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            if (premios case final premios?) ...[
              LuaGameStrip(
                repository: premios,
                perfil: Perfil.docente,
                language: language,
                onLanguageChanged: onLanguageChanged,
                contadores: calendario?.contadores,
              ),
              const SizedBox(height: 22),
            ],
            const RotuloGrupo('Para ti'),
            FilaPortal(
              clave: 'eu_antes_de_entrar',
              icona: Icons.school_rounded,
              nome: NomesDocentes.antesDeEntrar.resolve(language),
              di: NomesDocentes.antesDeEntrarDi.resolve(language),
              onTap: () => _abrir(
                context,
                (_) => FormacionScreen(
                  perfil: PerfilFormacion.docente,
                  language: language,
                  onLanguageChanged: onLanguageChanged,
                ),
              ),
            ),
            const SizedBox(height: 10),
            FilaPortal(
              clave: 'eu_formacion',
              icona: Icons.menu_book_rounded,
              nome: NomesDocentes.formacion.resolve(language),
              di: NomesDocentes.formacionDi.resolve(language),
              onTap: () => _abrir(
                context,
                (_) => CapsulasAulaScreen(
                  repository: repository,
                  initialLanguage: language,
                  onLanguageChanged: onLanguageChanged,
                  premios: premios,
                  audioService: audioService,
                ),
              ),
            ),
            const SizedBox(height: 22),
            // Lo que la app guarda de verdad, dicho donde la docente mira lo
            // suyo: su cuenta de uso y nada de ninguna criatura.
            Container(
              key: const Key('eu_privacidade'),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.acentoTint,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_rounded, color: context.acento, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isGl
                          ? 'Sen conexión e sen datos persoais. O único que se garda neste aparello é a túa propia conta de uso.'
                          : 'Sin conexión y sin datos personales. Lo único que se guarda en este aparato es tu propia cuenta de uso.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        height: 1.35,
                      ),
                    ),
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
