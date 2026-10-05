import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';

import '../helpers/pasarela.dart';

/// Lote L6 de la revisión de interfaz: accesibilidad, hasta donde se puede
/// medir sin un aparato.
///
/// Recorre TODAS las pantallas de la pasarela, en gallego y en castellano, a
/// 360 × 780 y con la Nunito real, bajando de vista en vista hasta el final,
/// y en cada vista comprueba lo que pide la revisión:
///
/// - M6: ningún texto por debajo de 12 px —las etiquetas— y el texto de
///   lectura a 14 px como mínimo. «De lectura» es lo que ocupa dos líneas o
///   más, o una frase de cuarenta letras: lo que se lee, no lo que se mira de
///   reojo. Un antetítulo en mayúsculas es una etiqueta aunque sea largo;
/// - dianas de 48 × 48 dp en todo lo que se pulsa, con la regla de
///   `androidTapTargetGuideline` (ver [_dianas]);
/// - una etiqueta para TalkBack en todo lo que se pulsa
///   (`labeledTapTargetGuideline`).
///
/// Cada fallo de letra dice qué línea de `lib/` pinta ese texto.
///
/// Lo que un test no puede decir —cómo suena con TalkBack de verdad, o cómo
/// se ve con la letra del sistema de un móvil concreto— está en `STATUS.md`.
void main() {
  final p = Pasarela();
  setUpAll(p.cargar);
  tearDownAll(p.limpar);

  ThemeData temaDe(Portal portal) =>
      portal == Portal.familias ? AppTheme.temaFamilias : AppTheme.lightTheme;

  for (final def in p.pantallas) {
    for (final lang in AppLanguage.deInterfaz) {
      testWidgets('${def.nome} · ${lang.code}', (tester) async {
        final semantica = tester.ensureSemantics();
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        const marco = ValueKey('pantalla');
        await tester.pumpWidget(MaterialApp(
          theme: temaDe(def.portal),
          debugShowCheckedModeBanner: false,
          home: RepaintBoundary(key: marco, child: def.construir(lang)),
        ));
        await Pasarela.asentar(tester);

        final fallos = <String>{};
        final principal = _principal(tester);
        var desprazado = 0.0;
        for (var paso = 0; paso < 40; paso++) {
          final onde = paso == 0 ? '' : ' (bajando ${desprazado.round()} px)';
          for (final f in _letra(tester, marco)) {
            fallos.add('$f$onde');
          }
          fallos.addAll(_dianas(tester));
          final etiquetas = await labeledTapTargetGuideline.evaluate(tester);
          if (!etiquetas.passed) {
            for (final l in (etiquetas.reason ?? '').split('\n')) {
              if (l.trim().isNotEmpty) fallos.add(_limpar(l));
            }
          }
          if (principal == null) break;
          final pos = principal.position;
          if (pos.pixels >= pos.maxScrollExtent - 1) break;
          final novo = math.min(
              pos.pixels + pos.viewportDimension * 0.8, pos.maxScrollExtent);
          desprazado = novo;
          pos.jumpTo(novo);
          await tester.pump();
          await Pasarela.asentar(tester);
        }

        semantica.dispose();
        expect(fallos, isEmpty, reason: fallos.join('\n'));
      });
    }
  }

  // La revisión estática: ninguna letra por debajo de 12 en todo `lib/`,
  // también en lo que la pasarela no abre (hojas, diálogos, estados vacíos).
  test('ningún fontSize por debajo de 12 en lib/', () {
    final pequeno = RegExp(r'fontSize:\s*([0-9]+(?:\.[0-9]+)?)');
    final fallos = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final linas = f.readAsLinesSync();
      for (var i = 0; i < linas.length; i++) {
        for (final m in pequeno.allMatches(linas[i])) {
          if (double.parse(m.group(1)!) < 12) {
            fallos.add('${f.path}:${i + 1}: ${linas[i].trim()}');
          }
        }
      }
    }
    expect(fallos, isEmpty, reason: fallos.join('\n'));
  });
}

/// El tamaño de la letra en lo que se ve ahora mismo.
List<String> _letra(WidgetTester tester, Key marco) {
  final caja = tester.renderObject<RenderRepaintBoundary>(find.byKey(marco));
  final pantalla = Offset.zero & caja.size;
  final fallos = <String>[];
  final parrafos = <RenderParagraph>[];
  void visitar(RenderObject o) {
    if (o is RenderParagraph) parrafos.add(o);
    o.visitChildren(visitar);
  }

  caja.visitChildren(visitar);
  for (final p in parrafos) {
    final texto = p.text.toPlainText().trim();
    if (texto.isEmpty || !p.hasSize || p.size.isEmpty) continue;
    if (p.text.style?.fontFamily == 'MaterialIcons') continue;
    final rect = _visible(p, caja).intersect(pantalla);
    if (rect.width < 4 || rect.height < 4) continue;

    // La escala en el plano: `getMaxScaleOnAxis` cuenta también el eje z,
    // que nadie escala, y daba 1 en una página encogida a 0,8.
    final unidade = MatrixUtils.transformRect(
        p.getTransformTo(caja), const Rect.fromLTWH(0, 0, 1, 1));
    final escala = math.min(unidade.width, unidade.height);
    double? minimo;
    void span(InlineSpan s, TextStyle? herdado) {
      final estilo = herdado == null ? s.style : herdado.merge(s.style);
      if (s is TextSpan) {
        if (s.text?.trim().isNotEmpty ?? false) {
          // Lo que mide de verdad en la pantalla: un FittedBox que encoge el
          // texto para que quepa también baja la letra.
          final tamano = p.textScaler.scale(estilo?.fontSize ?? 14) * escala;
          minimo = math.min(minimo ?? tamano, tamano);
        }
        for (final c in s.children ?? const <InlineSpan>[]) {
          span(c, estilo);
        }
      }
    }

    span(p.text, null);
    final tamano = minimo;
    if (tamano == null) continue;
    final onde = _lugar(p);
    if (tamano < 12 - 0.01) {
      fallos.add('Letra a ${_n(tamano)} px (< 12): «${_corto(texto)}».$onde');
      continue;
    }
    if (tamano < 14 - 0.01 && _deLectura(p, texto)) {
      fallos.add('Lectura a ${_n(tamano)} px (< 14): «${_corto(texto)}».$onde');
    }
  }
  return fallos;
}

/// Lo que se lee: dos líneas o más, o una frase de cuarenta letras. Un
/// antetítulo en mayúsculas, el texto de un botón o de un chip son etiquetas.
bool _deLectura(RenderParagraph p, String texto) {
  final letras = texto.replaceAll(RegExp(r'[^A-Za-zÁÉÍÓÚÑÜáéíóúñü]'), '');
  if (letras.isNotEmpty && letras == letras.toUpperCase()) return false;
  if (_dentroDe(p, (w) => w is ButtonStyleButton || w is RawChip)) {
    return false;
  }
  final linea = p.getFullHeightForCaret(const TextPosition(offset: 0));
  final linas = linea > 0 ? (p.size.height / linea).round() : 1;
  final palabras = texto.split(RegExp(r'\s+')).length;
  return linas >= 2 || (texto.length >= 40 && palabras >= 6);
}

/// La línea de `lib/` que crea ese texto, con la localización que `flutter
/// test` guarda de cada widget.
String _lugar(RenderParagraph p) {
  final creador = p.debugCreator;
  if (creador is! DebugCreator) return '';
  String? lugar;
  creador.element.visitAncestorElements((a) {
    final json = a.toDiagnosticsNode().toJsonMap(InspectorSerializationDelegate(
        service: WidgetInspectorService.instance));
    final loc = json['creationLocation'];
    if (loc is Map && '${loc['file']}'.contains('/lib/')) {
      final file = '${loc['file']}';
      lugar = '${file.substring(file.indexOf('/lib/') + 1)}:${loc['line']}';
      return false;
    }
    return true;
  });
  return ' [${lugar ?? '?'}]';
}

bool _dentroDe(RenderParagraph p, bool Function(Widget) e) {
  final creador = p.debugCreator;
  if (creador is! DebugCreator) return false;
  var si = false;
  creador.element.visitAncestorElements((a) {
    if (e(a.widget)) {
      si = true;
      return false;
    }
    return true;
  });
  return si;
}

/// La lista de la pantalla, la que va de arriba abajo y más alta.
ScrollableState? _principal(WidgetTester tester) {
  ScrollableState? mellor;
  var alto = 0.0;
  for (final e in find.byType(Scrollable).evaluate()) {
    final estado = (e as StatefulElement).state as ScrollableState;
    if (estado.axisDirection != AxisDirection.down) continue;
    final caixa = e.renderObject as RenderBox?;
    if (caixa == null || !caixa.hasSize) continue;
    if (caixa.size.height > alto) {
      alto = caixa.size.height;
      mellor = estado;
    }
  }
  return mellor;
}

/// La parte de [p] que de verdad se pinta, recortada por cada antecesor que
/// recorta. Lo mismo que en `ux_l2_test.dart`.
Rect _visible(RenderBox p, RenderObject raiz) {
  var rect =
      MatrixUtils.transformRect(p.getTransformTo(raiz), Offset.zero & p.size);
  RenderObject hijo = p;
  var padre = p.parent;
  while (padre != null) {
    final clip = padre.describeApproximatePaintClip(hijo);
    if (clip != null) {
      rect = rect.intersect(
          MatrixUtils.transformRect(padre.getTransformTo(raiz), clip));
    }
    if (identical(padre, raiz)) break;
    hijo = padre;
    padre = padre.parent;
  }
  return rect;
}

/// Las dianas: todo lo que se pulsa, de 48 × 48 dp como mínimo.
///
/// Es la regla de `androidTapTargetGuideline`, recorriendo el mismo árbol de
/// semántica, con una diferencia: lo que una lista o un carrusel recorta en
/// esta vista —la tarjeta del mes de al lado, que asoma 23 px; la fila que
/// queda a medias al pie de la lista— no cuenta aquí. Se mide en la vista en
/// que se ve entero. La guía de `flutter_test` ya hace lo mismo con lo que
/// toca el borde de la pantalla, pero no con el borde de una lista.
List<String> _dianas(WidgetTester tester) {
  final fallos = <String>[];
  for (final vista in tester.binding.renderViews) {
    final raiz = vista.owner?.semanticsOwner?.rootSemanticsNode;
    if (raiz == null) continue;
    final pantalla = Offset.zero & vista.flutterView.physicalSize;
    void visitar(SemanticsNode n) {
      n.visitChildren((c) {
        visitar(c);
        return true;
      });
      if (n.isMergedIntoParent) return;
      final d = n.getSemanticsData();
      if (!d.hasAction(SemanticsAction.tap) &&
          !d.hasAction(SemanticsAction.longPress)) {
        return;
      }
      if (d.flagsCollection.isHidden || d.flagsCollection.isLink) {
        return;
      }
      for (final recorte in [
        n.parentSemanticsClipRect,
        n.parentPaintClipRect
      ]) {
        if (recorte != null && _tocaBorde(n.rect, recorte)) return;
      }
      var r = n.rect;
      for (SemanticsNode? c = n; c != null; c = c.parent) {
        final m = c.transform;
        if (m != null) r = MatrixUtils.transformRect(m, r);
      }
      if (_tocaBorde(r, pantalla)) return;
      final tamano = r.size / vista.flutterView.devicePixelRatio;
      if (tamano.width < 48 - 0.01 || tamano.height < 48 - 0.01) {
        final nome = d.label.isNotEmpty ? d.label : d.tooltip;
        fallos.add('Diana de ${tamano.width.toStringAsFixed(0)} × '
            '${tamano.height.toStringAsFixed(0)} dp (< 48): '
            '«${_corto(nome)}».');
      }
    }

    visitar(raiz);
  }
  return fallos;
}

bool _tocaBorde(Rect r, Rect caixa) {
  const d = 0.5;
  return (r.left - caixa.left).abs() <= d ||
      (r.top - caixa.top).abs() <= d ||
      (r.right - caixa.right).abs() <= d ||
      (r.bottom - caixa.bottom).abs() <= d;
}

/// Las guías de `flutter_test` nombran el nodo con su número, que cambia de
/// una vista a otra: sin él, el mismo fallo sale una sola vez.
String _limpar(String l) =>
    l.replaceAll(RegExp(r'SemanticsNode#\d+'), 'SemanticsNode').trim();

String _n(double v) =>
    v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1);

String _corto(String t) {
  final una = t.replaceAll('\n', ' ');
  return una.length > 40 ? '${una.substring(0, 40)}…' : una;
}
