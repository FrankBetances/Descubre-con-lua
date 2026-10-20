import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../localization/localized_string.dart';
import '../theme/app_theme.dart';

/// La espera, vista y en silencio (M4.2): la adulta la toca después de decir
/// o preguntar, y un anillo se llena durante [segundos]. Es el primer tiempo
/// de la espera del apartado 7 de la arquitectura: decir y callar de 3 a 5 s.
///
/// **Sin sonido y sin vibración, a propósito.** Parte de las crianzas llevan
/// audiófono o implante, y el silencio es lo que se está midiendo: un pitido
/// lo rompería. Tampoco cuenta en alto ni enseña números que la criatura
/// pueda seguir: el móvil es de la adulta.
///
/// Una sola pieza para la asamblea, el cuento de la semana y, cuando exista,
/// el microcuento: si cada pantalla contara la espera a su manera, la
/// docente aprendería tres esperas distintas.
class EsperaVisible extends StatefulWidget {
  final int segundos;
  final AppLanguage language;

  /// Colores del sitio donde va: la asamblea es oscura y el cuento, claro.
  final Color color;
  final Color fondo;

  const EsperaVisible({
    super.key,
    required this.segundos,
    required this.language,
    required this.color,
    required this.fondo,
  });

  static const _agarda = LocalizedString(gl: 'Agarda', es: 'Espera');
  static const _agardando = LocalizedString(gl: 'Agardando…', es: 'Esperando…');

  @override
  State<EsperaVisible> createState() => _EsperaVisibleState();
}

class _EsperaVisibleState extends State<EsperaVisible>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anel = AnimationController(
    vsync: this,
    duration: Duration(seconds: widget.segundos),
  );

  @override
  void dispose() {
    _anel.dispose();
    super.dispose();
  }

  void _tocar() {
    // Tocarla mientras corre la reinicia: vuelve a empezar la espera.
    _anel.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    return Semantics(
      button: true,
      label: '${EsperaVisible._agarda.resolve(lang)} ${widget.segundos} s',
      child: Material(
        color: widget.fondo,
        shape: StadiumBorder(side: BorderSide(color: widget.color, width: 1.5)),
        child: InkWell(
          key: const ValueKey('espera_visible'),
          customBorder: const StadiumBorder(),
          onTap: _tocar,
          child: ConstrainedBox(
            // 48 px: el mínimo de diana táctil.
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: AnimatedBuilder(
                animation: _anel,
                builder: (context, _) {
                  final corre = _anel.isAnimating;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          key: const ValueKey('espera_visible_anel'),
                          value: corre ? _anel.value : 0,
                          strokeWidth: 4,
                          color: widget.color,
                          backgroundColor: widget.color.withValues(alpha: 0.2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          corre
                              ? EsperaVisible._agardando.resolve(lang)
                              : '${EsperaVisible._agarda.resolve(lang)} '
                                  '${widget.segundos} s',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: widget.color,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
