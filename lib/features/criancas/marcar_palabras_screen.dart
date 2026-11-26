import 'package:flutter/material.dart';

import '../../core/audio/offline_audio_service.dart';
import '../../core/audio/widgets/boton_escuchar.dart';
import '../../core/brand/imaxe_escena.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/leccion_model.dart';
import 'criancas_store.dart';

/// M1 + M4: pantalla de diez segundos al acabar el juego del día (y base para
/// «Lúa pregunta» en domingo). Muestra de 2 a 4 palabras con su lámina,
/// cuántas veces la ha oído y los tres botones grandes para la persona adulta.
class MarcarEnDezSegundosScreen extends StatelessWidget {
  const MarcarEnDezSegundosScreen({
    super.key,
    required this.store,
    required this.crianza,
    required this.semana,
    required this.palabras,
    required this.language,
    this.audioService,
    this.agora,
    this.eDomingo = false,
  });

  final CriancasStore store;
  final Crianza crianza;
  final String semana;
  final List<PezaDaLeccion> palabras;
  final AppLanguage language;
  final OfflineAudioService? audioService;
  final DateTime? agora;
  final bool eDomingo;

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final vistas = palabras.take(4).toList(growable: false);
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: AppTheme.pageBg,
        elevation: 0,
        title: Text(
          eDomingo
              ? 'Lúa pregunta'
              : (isGl ? 'Como foi hoxe?' : '¿Cómo fue hoy?'),
          key: Key(eDomingo ? 'lua_pregunta_titulo' : 'marcar10_titulo'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            if (eDomingo)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  isGl
                      ? 'Tres palabras desta semana para ${crianza.nome}.'
                      : 'Tres palabras de esta semana para ${crianza.nome}.',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            for (final p in vistas) ...[
              TarxetaMarcarPalabra(
                key: ValueKey('marcar10_card_${p.en}'),
                peza: p,
                store: store,
                crianzaId: crianza.id,
                semana: semana,
                language: language,
                audioService: audioService,
                agora: agora,
                prefixoBoton: 'marcar10',
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: FilledButton(
                key: const Key('marcar10_listo'),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  isGl ? 'Listo' : 'Listo',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta reutilizable de palabra con lámina, audio, contador de escuchas (M4)
/// y tres botones grandes («aínda non / entende / dío») sin pantalla para el niño.
class TarxetaMarcarPalabra extends StatelessWidget {
  const TarxetaMarcarPalabra({
    super.key,
    required this.peza,
    required this.store,
    required this.crianzaId,
    required this.semana,
    required this.language,
    this.audioService,
    this.agora,
    this.prefixoBoton = 'marcar10',
  });

  final PezaDaLeccion peza;
  final CriancasStore store;
  final String crianzaId;
  final String semana;
  final AppLanguage language;
  final OfflineAudioService? audioService;
  final DateTime? agora;
  final String prefixoBoton;

  static String textoEscoitas(int n, AppLanguage lang) {
    final isGl = lang == AppLanguage.gl;
    if (isGl) return n == 1 ? 'Oíuna 1 vez' : 'Oíuna $n veces';
    return n == 1 ? 'La ha oído 1 vez' : 'La ha oído $n veces';
  }

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final actual = store.observacion(crianzaId, semana, peza.en);
    final escoitas = store.escoitasDe(crianzaId, peza.en);
    final clave = CriancasStore.claveRepaso(peza.en);
    final acento = context.acento;

    Widget boton(Observacion o, String texto) {
      final marcado = actual == o;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Semantics(
            button: true,
            selected: marcado,
            label: '${peza.en}: $texto',
            child: Material(
              key: ValueKey('${prefixoBoton}_${peza.en}_${o.name}'),
              color: marcado ? acento : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: marcado ? acento : AppTheme.border,
                  width: marcado ? 1.8 : 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => store.observar(
                  crianzaId,
                  semana,
                  peza.en,
                  o,
                  agora: agora,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 10,
                      ),
                      child: Text(
                        texto,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: marcado ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (peza.lamina case final lam?) ...[
                LaminaPalabra(
                  clave: lam,
                  significado: peza.significado?.resolve(language) ?? peza.en,
                  lang: language,
                  ancho: 56,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BotonEscuchar(
                      audioService: audioService,
                      texto: peza.en,
                      language: AppLanguage.en,
                      interfaz: language,
                      comoChip: true,
                      colorChip: acento,
                      descripcion: peza.en,
                      significado: peza.significado,
                      onEscoitar: () => store.rexistrarEscoita(
                        crianzaId,
                        peza.en,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      textoEscoitas(escoitas, language),
                      key: ValueKey('escoitas_$clave'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              boton(Observacion.aindaNon, isGl ? 'Aínda non' : 'Aún no'),
              boton(Observacion.entende, isGl ? 'Entende' : 'La entiende'),
              boton(Observacion.di, isGl ? 'Dío' : 'La dice'),
            ],
          ),
        ],
      ),
    );
  }
}
