import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/formacion_model.dart';
import '../../../core/widgets/boton_atras.dart';

/// La formación previa: lo que hay que saber ANTES de usar la app.
///
/// Un paso por pantalla, y se pasa de lado. Sin desplazamiento vertical, igual
/// que el resto de la app: si un paso no cupiera, se recorta el cuerpo y la
/// frase clave se queda, porque la frase clave es lo que hay que recordar.
class FormacionScreen extends StatefulWidget {
  final PerfilFormacion perfil;
  final AppLanguage language;

  /// Para las pruebas: permite inyectar la guía ya leída.
  final GuiaFormacion? guiaPrecargada;

  /// Para las pruebas: lector de assets alternativo.
  final Future<String> Function(String)? lector;

  const FormacionScreen({
    super.key,
    required this.perfil,
    required this.language,
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

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final isGl = widget.language == AppLanguage.gl;
    final guia = _guia;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        leading: const BotonAtras(),
        title: Text(
          guia?.titulo.resolve(widget.language) ??
              (isGl ? 'Antes de empezar' : 'Antes de empezar'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
                          guia.subtitulo.resolve(widget.language),
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
                            language: widget.language,
                          ),
                        ),
                      ),
                      _Pes(
                        indice: _indice,
                        total: guia.pasos.length,
                        isGl: isGl,
                        onAnterior: () => _ir(_indice - 1),
                        onSeguinte: () {
                          if (_indice < guia.pasos.length - 1) {
                            _ir(_indice + 1);
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
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
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryInk,
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
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusField),
              ),
              child: Text(
                paso.clave.resolve(language),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 15.5,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryInk,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pes extends StatelessWidget {
  final int indice;
  final int total;
  final bool isGl;
  final VoidCallback onAnterior;
  final VoidCallback onSeguinte;

  const _Pes({
    required this.indice,
    required this.total,
    required this.isGl,
    required this.onAnterior,
    required this.onSeguinte,
  });

  @override
  Widget build(BuildContext context) {
    final ultimo = indice >= total - 1;
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: AppTheme.touchMin,
              child: OutlinedButton(
                key: const ValueKey('formacion_anterior'),
                onPressed: indice > 0 ? onAnterior : null,
                child: Text(isGl ? 'Anterior' : 'Anterior'),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: AppTheme.touchMin,
              child: ElevatedButton(
                key: const ValueKey('formacion_seguinte'),
                onPressed: onSeguinte,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryInk,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  ultimo
                      ? (isGl ? 'Xa o teño' : 'Ya lo tengo')
                      : (isGl ? 'Seguinte' : 'Siguiente'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
