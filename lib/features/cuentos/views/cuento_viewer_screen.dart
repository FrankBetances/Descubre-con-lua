import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/brand/lamina_vector.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/vocabulario_contos.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/cuento_model.dart';

/// Visor interactivo y guiado del cuento para docentes y familias.
///
/// Orientado 100% al adulto mediador. Permite la lectura dialógica guiada,
/// formulación de preguntas graduadas y ejecución de retos TPR orales.
class CuentoViewerScreen extends StatefulWidget {
  final Cuento cuento;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const CuentoViewerScreen({
    super.key,
    required this.cuento,
    this.language = AppLanguage.gl,
    this.audioService,
  });

  @override
  State<CuentoViewerScreen> createState() => _CuentoViewerScreenState();
}

class _CuentoViewerScreenState extends State<CuentoViewerScreen> {
  int _currentPageIndex = 0;
  bool _mostrarPreguntas = false;

  @override
  void initState() {
    super.initState();
    // La tabla del vocabulario, una vez. Si tarda, la tarjeta se repinta al
    // llegar; si no está, el vocabulario se queda en gallego y no pasa nada.
    VocabularioContos.cargar().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final cuento = widget.cuento;
    final paginas = cuento.paginas;
    final hasPaginas = paginas.isNotEmpty;
    final paginaActual = hasPaginas && _currentPageIndex < paginas.length
        ? paginas[_currentPageIndex]
        : null;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cuento.titulo.resolve(lang),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${cuento.cursoId.toUpperCase()} · Semana ${cuento.semanaSugerida}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Sinopsis bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppTheme.primaryLight,
              child: Row(
                children: [
                  const Icon(Icons.auto_stories,
                      color: AppTheme.primaryDark, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cuento.sinopse.resolve(lang),
                      style: const TextStyle(
                        color: AppTheme.primaryInk,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Page Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (paginaActual != null) ...[
                      // Page Card
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusCard),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // La ilustración de ESTA página. Las 913 páginas
                            // del banco traen su clave de lámina y las 41
                            // láminas que nombran existen dibujadas en
                            // assets/brand/laminas/: el visor simplemente no
                            // las pintaba y el cuento llegaba al aula como un
                            // muro de texto.
                            if (paginaActual.lamina.trim().isNotEmpty)
                              LayoutBuilder(
                                builder: (context, limites) => LaminaEscena(
                                  clave: paginaActual.lamina.trim(),
                                  ancho: limites.maxWidth.isFinite
                                      ? limites.maxWidth
                                      : MediaQuery.of(context).size.width,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        lang == AppLanguage.gl
                                            ? 'Páxina ${paginaActual.numero} de ${paginas.length}'
                                            : 'Página ${paginaActual.numero} de ${paginas.length}',
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (VocabularioContos.lista(
                                              paginaActual.vocabularioClave,
                                              lang)
                                          .isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryLight,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            VocabularioContos.lista(
                                                    paginaActual
                                                        .vocabularioClave,
                                                    lang)
                                                .join(' · '),
                                            style: const TextStyle(
                                              color: AppTheme.primaryDark,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    paginaActual.texto.resolve(lang),
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 17,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if ((paginaActual.preguntaImaxe
                                              ?.resolve(lang) ??
                                          '')
                                      .trim()
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.warningBg,
                                        borderRadius: BorderRadius.circular(10),
                                        border:
                                            Border.all(color: AppTheme.star),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.help_outline,
                                              color: AppTheme.warning,
                                              size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              paginaActual.preguntaImaxe!
                                                  .resolve(lang),
                                              style: const TextStyle(
                                                color: AppTheme.warning,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Empty state or synopsis-only view
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            cuento.sinopse.resolve(lang),
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Reto TPR Oral en Inglés
                    if (cuento.tprOral != null)
                      Card(
                        color: AppTheme.primaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppTheme.primaryLight),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.sports_gymnastics,
                                      color: AppTheme.primaryDark, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    lang == AppLanguage.gl
                                        ? 'Reto TPR Oral (L3 Inglés)'
                                        : 'Reto TPR Oral (L3 Inglés)',
                                    style: const TextStyle(
                                      color: AppTheme.primaryDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cuento.tprOral!.fraseEn,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lang == AppLanguage.gl
                                    ? cuento.tprOral!.comandoGl
                                    : cuento.tprOral!.comandoEs,
                                style: const TextStyle(
                                  color: AppTheme.primaryInk,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Graduated Questions Collapsible
                    if (cuento.preguntasGraduadas.isNotEmpty) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _mostrarPreguntas = !_mostrarPreguntas;
                          });
                        },
                        icon: Icon(_mostrarPreguntas
                            ? Icons.expand_less
                            : Icons.expand_more),
                        label: Text(
                          lang == AppLanguage.gl
                              ? 'Preguntas graduadas (${cuento.preguntasGraduadas.length} niveis)'
                              : 'Preguntas graduadas (${cuento.preguntasGraduadas.length} niveles)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryDark,
                          side: const BorderSide(color: AppTheme.primaryDark),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      if (_mostrarPreguntas)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            // Sen isto cada tarxeta colle o ancho do seu propio
                            // texto e queda centrada: as preguntas curtas saen
                            // máis estreitas e metidas cara a dentro, coma se
                            // fosen subapartados das longas.
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: cuento.preguntasGraduadas.map((preg) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      preg.tipo != null
                                          ? 'Nivel ${preg.nivel}: ${preg.tipo!.resolve(lang)}'
                                          : 'Nivel ${preg.nivel}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: AppTheme.primaryInk,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      preg.enunciado.resolve(lang),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textPrimary),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Navigation Stepper
            if (hasPaginas && paginas.length > 1)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _currentPageIndex > 0
                          ? () => setState(() => _currentPageIndex--)
                          : null,
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: Text(
                          lang == AppLanguage.gl ? 'Anterior' : 'Anterior'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.pageBg,
                        foregroundColor: AppTheme.textPrimary,
                        elevation: 0,
                      ),
                    ),
                    Text(
                      '${_currentPageIndex + 1} / ${paginas.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _currentPageIndex < paginas.length - 1
                          ? () => setState(() => _currentPageIndex++)
                          : null,
                      label: Text(
                          lang == AppLanguage.gl ? 'Seguinte' : 'Siguiente'),
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
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
