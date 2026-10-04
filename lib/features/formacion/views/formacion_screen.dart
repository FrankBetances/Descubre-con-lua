import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../core/widgets/pasos_navegacion.dart';
import '../../../data/models/formacion_model.dart';

/// La formación previa: lo que hay que saber ANTES de usar la app.
///
/// Un paso por pantalla, y se pasa de lado. Sin desplazamiento vertical, igual
/// que el resto de la app: si un paso no cupiera, se recorta el cuerpo y la
/// frase clave se queda, porque la frase clave es lo que hay que recordar.
class FormacionScreen extends StatefulWidget {
  final PerfilFormacion perfil;
  final AppLanguage language;

  /// Avisa a quien la abrió de que se cambió de lengua aquí.
  final ValueChanged<AppLanguage>? onLanguageChanged;

  /// Para las pruebas: permite inyectar la guía ya leída.
  final GuiaFormacion? guiaPrecargada;

  /// Para las pruebas: lector de assets alternativo.
  final Future<String> Function(String)? lector;

  const FormacionScreen({
    super.key,
    required this.perfil,
    required this.language,
    this.onLanguageChanged,
    this.guiaPrecargada,
    this.lector,
  });

  @override
  State<FormacionScreen> createState() => _FormacionScreenState();
}

class _FormacionScreenState extends State<FormacionScreen> {
  final PageController _paxinas = PageController();
  GuiaFormacion? _guia;
  bool _fallo = false;
  int _indice = 0;
  late AppLanguage _language;

  @override
  void initState() {
    super.initState();
    _language = widget.language;
    final precargada = widget.guiaPrecargada;
    if (precargada != null) {
      _guia = precargada;
      return;
    }
    GuiaFormacion.cargar(widget.perfil, lector: widget.lector).then((g) {
      if (!mounted) return;
      setState(() => _guia = g);
    }).catchError((Object _) {
      if (!mounted) return;
      setState(() => _fallo = true);
    });
  }

  @override
  void didUpdateWidget(covariant FormacionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) _language = widget.language;
  }

  @override
  void dispose() {
    _paxinas.dispose();
    super.dispose();
  }

  void _ir(int i) {
    final guia = _guia;
    if (guia == null) return;
    final destino = i.clamp(0, guia.pasos.length - 1);
    if (destino == _indice) return;
    _paxinas.animateToPage(
      destino,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _cambiarLingua(AppLanguage lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged?.call(lang);
  }

  @override
  Widget build(BuildContext context) {
    final isGl = _language == AppLanguage.gl;
    final guia = _guia;
    final naCasa = widget.perfil == PerfilFormacion.familia;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      // «Antes de empezar na casa» no cabe en la cabecera a 360 px: el
      // título dice qué es y la segunda línea, para quién.
      appBar: Cabecera(
        titulo: isGl ? 'Antes de empezar' : 'Antes de empezar',
        subtitulo: naCasa
            ? (isGl ? 'Na casa · 2 min' : 'En casa · 2 min')
            : (isGl ? 'Na aula · 2 min' : 'En el aula · 2 min'),
        language: _language,
        onLanguageChanged: _cambiarLingua,
      ),
      body: SafeArea(
        child: _fallo
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceXl),
                  child: Text(
                    isGl
                        ? 'Non se puido ler a formación. Reinstala a app para recuperala.'
                        : 'No se ha podido leer la formación. Reinstala la app para recuperarla.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              )
            : guia == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppTheme.spaceLg, 0, AppTheme.spaceLg, 0),
                        child: Text(
                          guia.subtitulo.resolve(_language),
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      Expanded(
                        child: PageView.builder(
                          controller: _paxinas,
                          itemCount: guia.pasos.length,
                          onPageChanged: (i) => setState(() => _indice = i),
                          itemBuilder: (context, i) => _TarxetaDePaso(
                            numero: i + 1,
                            total: guia.pasos.length,
                            paso: guia.pasos[i],
                            language: _language,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppTheme.spaceLg),
                        child: PasosNavegacion(
                          chaveAnterior: const ValueKey('formacion_anterior'),
                          chaveSeguinte: const ValueKey('formacion_seguinte'),
                          anterior: _indice > 0 ? () => _ir(_indice - 1) : null,
                          etiquetaAnterior: isGl ? 'Anterior' : 'Anterior',
                          etiquetaSeguinte: _indice >= guia.pasos.length - 1
                              ? (isGl ? 'Xa o teño' : 'Ya lo tengo')
                              : (isGl ? 'Seguinte' : 'Siguiente'),
                          iconaSeguinte: _indice >= guia.pasos.length - 1
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          seguinte: () {
                            if (_indice < guia.pasos.length - 1) {
                              _ir(_indice + 1);
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _TarxetaDePaso extends StatelessWidget {
  final int numero;
  final int total;
  final PasoFormacion paso;
  final AppLanguage language;

  const _TarxetaDePaso({
    required this.numero,
    required this.total,
    required this.paso,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
      child: Container(
        key: ValueKey('paso_formacion_$numero'),
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spaceXl),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: AppTheme.border, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$numero / $total',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: context.acento,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              paso.titulo.resolve(language),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 22,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Expanded(
              child: Text(
                paso.corpo.resolve(language),
                overflow: TextOverflow.ellipsis,
                maxLines: 12,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 16,
                  height: 1.45,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            // La frase que queda cuando se olvida el resto.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: context.acentoTint,
                borderRadius: BorderRadius.circular(AppTheme.radiusField),
              ),
              child: Text(
                paso.clave.resolve(language),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 15.5,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                  color: context.acento,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
