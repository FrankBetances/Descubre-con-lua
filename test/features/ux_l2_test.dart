import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/main.dart' show DescubreConLuaApp;

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/core/widgets/cabecera.dart';
import 'package:descubre_con_lua/features/academy/widgets/selector_idioma_widget.dart';

import '../helpers/pasarela.dart';

/// Lote L2 de la revisión de interfaz: un sistema visual.
///
/// Recorre TODAS las pantallas de la app con barra superior —las de
/// `Pasarela`—, en gallego y en castellano, a 360 × 780 y con la tipografía
/// real, y en cada una comprueba lo que el lote promete:
///
/// - la cabecera común, con GL/ES;
/// - el título entero, sin cortar;
/// - la cabecera y el botón principal con el acento de su portal, y como
///   mucho un botón principal por pantalla;
/// - que cada texto pase AA (4,5:1, o 3:1 si es grande) contra el color que
///   de verdad tiene detrás, medido en la imagen pintada y no en el código;
/// - que todo el texto vaya en Nunito.
///
/// Un desborde de `RenderFlex` en cualquier pantalla también lo tumba: el
/// motor lanza el error durante el pintado.
void main() {
  final p = Pasarela();
  setUpAll(p.cargar);
  tearDownAll(p.limpar);

  ThemeData temaDe(Portal portal) =>
      portal == Portal.familias ? AppTheme.temaFamilias : AppTheme.lightTheme;
  Color acentoDe(Portal portal) =>
      portal == Portal.familias ? AppTheme.familias : AppTheme.docentes;

  for (final def in p.pantallas) {
    for (final lang in AppLanguage.deInterfaz) {
      testWidgets('${def.nome} · ${lang.code}', (tester) async {
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

        final fallos = <String>[];
        final acento = acentoDe(def.portal);

        // --- La cabecera. Dos pantallas llevan la suya a propósito: la
        // bienvenida, que es la portada de la app, y el reproductor de la
        // asamblea, que es la sesión a pantalla completa.
        if (def.nome != 'reprodutor' && def.nome != 'bienvenida') {
          final cab = find.byType(Cabecera);
          expect(cab, findsOneWidget, reason: 'Sin la cabecera común.');
          expect(
              find.descendant(
                  of: cab, matching: find.byType(SelectorIdiomaWidget)),
              findsOneWidget,
              reason: 'La cabecera no lleva GL/ES.');
          final titulo = tester.widget<Cabecera>(cab).titulo;
          final parrafo = tester.renderObject<RenderParagraph>(
              find.descendant(of: cab, matching: find.text(titulo)).first);
          if (parrafo.didExceedMaxLines) {
            fallos.add('Título cortado: «$titulo».');
          }
          final barra = tester.widget<AppBar>(
              find.descendant(of: cab, matching: find.byType(AppBar)));
          final fondo = barra.backgroundColor ??
              Theme.of(tester.element(cab)).appBarTheme.backgroundColor;
          if (fondo != acento) {
            fallos.add('Cabecera de color $fondo y no del acento $acento.');
          }
        }

        // --- Un botón principal y el contraste, en TODA la pantalla: se
        // mira lo que se ve al abrir y, después, bajando de pantalla en
        // pantalla hasta el final. Las listas solo construyen lo que está
        // cerca de la vista, así que mirar solo al abrir dejaba sin revisar
        // todo lo que hay debajo del pliegue. Pasó: el Portal Docentes tenía
        // un segundo botón relleno tres pantallas más abajo.
        const maximo = 1;
        final principal = _principal(tester);
        var desprazado = 0.0;
        for (var paso = 0; paso < 40; paso++) {
          final onde = paso == 0 ? '' : ' (bajando ${desprazado.round()} px)';
          fallos.addAll([
            for (final f
                in await _revisarVista(tester, def.nome, acento, maximo, marco))
              '$f$onde',
          ]);
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

        expect(fallos, isEmpty, reason: fallos.join('\n'));
      });
    }
  }

  testWidgets(
      'el color del portal viaja con cada pantalla que se abre desde él',
      (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // La app de verdad, con sus rutas: el color de cada portal lo pone la
    // ruta que lo abre, no la pantalla.
    await tester.pumpWidget(DescubreConLuaApp(
      contentRepository: p.contenido,
      premiosRepository: p.premios,
      calendarioStore: p.store,
      audioService: p.audio,
    ));
    await Pasarela.asentar(tester);

    Color cabecera() {
      final barra = tester.widget<AppBar>(find
          .descendant(of: find.byType(Cabecera), matching: find.byType(AppBar))
          .last);
      return barra.backgroundColor ??
          Theme.of(tester.element(find.byType(Cabecera).last))
              .appBarTheme
              .backgroundColor!;
    }

    // Inicio → Na casa: naranja.
    await tester.tap(find.byKey(const ValueKey('inicio_na_casa')));
    await Pasarela.asentar(tester);
    expect(cabecera(), AppTheme.familias);

    // Portal Familias → Explorar → Contos: sigue naranja aunque Contos no
    // sepa de quién es.
    await tester.tap(find.byKey(const Key('pestana_explorar')));
    await Pasarela.asentar(tester);
    expect(cabecera(), AppTheme.familias);
    await tester.tap(find.byKey(const ValueKey('explorar_contos')));
    await Pasarela.asentar(tester);
    expect(find.text('Contos'), findsWidgets);
    expect(cabecera(), AppTheme.familias);

    // Contos → un cuento: dos pantallas por debajo del portal, aún naranja.
    await tester.tap(find.byIcon(Icons.chevron_right_rounded).first);
    await Pasarela.asentar(tester);
    expect(find.text('Conto'), findsOneWidget);
    expect(cabecera(), AppTheme.familias);

    // Y de vuelta al inicio, el Portal Docentes es turquesa oscuro.
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const ValueKey('boton_atras')).last);
      await Pasarela.asentar(tester);
    }
    await tester.tap(find.byKey(const ValueKey('inicio_na_escola')));
    await Pasarela.asentar(tester);
    expect(cabecera(), AppTheme.docentes);
  });

  test('un solo estilo de icono: el redondeado', () {
    // `Icons.x` sin sufijo es el relleno de Material, y `_outlined`, el de
    // contorno: tres estilos que se mezclaban en la misma pantalla.
    final malos = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final lineas = f.readAsLinesSync();
      for (var i = 0; i < lineas.length; i++) {
        for (final m in RegExp(r'\bIcons\.(\w+)').allMatches(lineas[i])) {
          if (!m.group(1)!.endsWith('_rounded')) {
            malos.add('${f.path}:${i + 1} Icons.${m.group(1)}');
          }
        }
      }
    }
    expect(malos, isEmpty, reason: malos.join('\n'));
  });

  test('ningún color de letra escrito a mano por debajo de 4,5:1', () {
    // La auditoría de arriba mide lo que se pinta, pero solo en lo que se
    // abre: la fase 1 de una asamblea, el rol por defecto, lo plegado
    // plegado. Esto mira el código: cada color que va a `TextStyle`,
    // `copyWith` o `styleFrom` como letra, sobre blanco. Así salieron el
    // aviso de seguridad de la fase de exploración y la pauta de modelado,
    // en el amarillo de la estrella (1,53:1).
    final tema = File('lib/core/theme/app_theme.dart').readAsStringSync();
    final tokens = <String, int>{};
    for (final m
        in RegExp(r'static const Color (\w+) = Color\(0xFF([0-9A-Fa-f]{6})\)')
            .allMatches(tema)) {
      tokens[m.group(1)!] = int.parse(m.group(2)!, radix: 16);
    }
    for (var i = 0; i < 3; i++) {
      for (final m
          in RegExp(r'static const Color (\w+) = (\w+);').allMatches(tema)) {
        final v = tokens[m.group(2)!];
        if (v != null) tokens[m.group(1)!] = v;
      }
    }
    final bloque = RegExp(r'(copyWith|styleFrom|TextStyle)\(');
    final clave = RegExp(r'\b(?:color|foregroundColor):\s*');
    final valor = RegExp(r'Color\(0xFF([0-9A-Fa-f]{6})\)|AppTheme\.(\w+)\b');
    final malos = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final s = f.readAsStringSync();
      for (final m in bloque.allMatches(s)) {
        var fondo = 1, j = m.end;
        while (fondo > 0 && j < s.length) {
          if (s[j] == '(') fondo++;
          if (s[j] == ')') fondo--;
          j++;
        }
        final dentro = s.substring(m.end, j - 1);
        for (final c in clave.allMatches(dentro)) {
          // Un borde o un icono dentro del mismo bloque no son letra.
          final antes = dentro.substring(0, c.start);
          if (RegExp(r'(BorderSide|Border\.all|BoxDecoration|Icon)\([^()]*$')
              .hasMatch(antes)) {
            continue;
          }
          // El valor llega hasta la coma de su nivel: así entran los dos
          // lados de un `hecho ? verde : naranja`.
          var nivel = 0, k = c.end;
          while (k < dentro.length) {
            final ch = dentro[k];
            if (ch == '(' || ch == '[' || ch == '{') nivel++;
            if (ch == ')' || ch == ']' || ch == '}') {
              if (nivel == 0) break;
              nivel--;
            }
            if (ch == ',' && nivel == 0) break;
            k++;
          }
          final expr = dentro.substring(c.end, k);
          if (expr.contains('withValues') || expr.contains('withAlpha')) {
            continue;
          }
          // Texto grande —24 px, o 18,66 en negrita— pide 3:1 y no 4,5.
          final tamano = double.tryParse(RegExp(r'fontSize:\s*([0-9.]+)')
                      .firstMatch(dentro)
                      ?.group(1) ??
                  '') ??
              14;
          final negra =
              RegExp(r'FontWeight\.(bold|w700|w800|w900)\b').hasMatch(dentro);
          final minimo = tamano >= 24 || (tamano >= 18.66 && negra) ? 3.0 : 4.5;
          for (final v in valor.allMatches(expr)) {
            final rgb = v.group(1) != null
                ? int.parse(v.group(1)!, radix: 16)
                : tokens[v.group(2)!];
            if (rgb == null) continue;
            final luz = Color(0xFF000000 | rgb).computeLuminance();
            // Letra clara: va sobre el acento o sobre un fondo oscuro, y ahí
            // la mide la auditoría de la imagen, no esto.
            if (luz > 0.8) continue;
            final ratio = 1.05 / (luz + 0.05);
            if (ratio < minimo) {
              final linea = '\n'.allMatches(s.substring(0, m.start)).length + 1;
              malos.add('${f.path}:$linea · ${v.group(0)} · '
                  '${ratio.toStringAsFixed(2)}:1');
            }
          }
        }
      }
    }
    expect(malos, isEmpty, reason: malos.join('\n'));
  });

  test('los mismos verbos en toda la app', () {
    // Empezar es «Comezar / Comenzar»; terminar algo que va por pasos,
    // «Rematar / Terminar»; decir que el juego de casa ya está hecho, «Xa o
    // fixemos / Ya lo hicimos». Convivían «Iniciar», «Finalizar» y «Marcar
    // como feito» para lo mismo.
    final prohibidos = {
      RegExp(r"'¿?Finalizar\b"): '«Rematar» / «Terminar»',
      RegExp(r"'Iniciar (a )?asem?blea"): '«Comezar a asemblea»',
      RegExp(r"'Marcar como (Feito|Hecho)"): '«Xa o fixemos»',
    };
    final malos = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final lineas = f.readAsLinesSync();
      for (var i = 0; i < lineas.length; i++) {
        if (lineas[i].trimLeft().startsWith('//')) continue;
        for (final e in prohibidos.entries) {
          if (e.key.hasMatch(lineas[i])) {
            malos.add('${f.path}:${i + 1} → ${e.value}');
          }
        }
      }
    }
    expect(malos, isEmpty, reason: malos.join('\n'));
  });
}

/// La lista vertical que hace de página: la de mayor alto. Las tiras de
/// chips o de meses se desplazan en horizontal y no cuentan.
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

/// Lo que se ve ahora mismo: cuántos botones principales hay a la vista, de
/// qué color son y si cada texto pasa AA.
Future<List<String>> _revisarVista(WidgetTester tester, String nome,
    Color acento, int maximo, Key marco) async {
  final fallos = <String>[];
  final caja = tester.renderObject<RenderRepaintBoundary>(find.byKey(marco));
  final pantalla = Offset.zero & caja.size;
  final principales = find
      .byWidgetPredicate((w) => w is ElevatedButton && w.enabled)
      .evaluate()
      .where((e) {
    final r = e.renderObject;
    if (r is! RenderBox || !r.hasSize || !r.attached) return false;
    final v = _visible(r, caja).intersect(pantalla);
    return v.width > 4 && v.height > 4;
  }).toList();
  if (principales.length > maximo) {
    fallos.add('${principales.length} botones principales a la vista; '
        'como mucho $maximo: ${principales.map(_rotulo).join(', ')}.');
  }
  // El principal se lee de un golpe: en una línea. «Comenzar la asamblea» se
  // partía en dos en castellano y en gallego no.
  for (final e in principales) {
    void mirar(RenderObject o) {
      if (o is RenderParagraph && o.hasSize) {
        final linea = o.getFullHeightForCaret(const TextPosition(offset: 0));
        if (linea > 0 && o.size.height > linea * 1.5) {
          fallos.add('Botón principal en más de una línea: ${_rotulo(e)}.');
        }
      }
      o.visitChildren(mirar);
    }

    e.renderObject?.visitChildren(mirar);
  }
  // El reproductor es la sesión a pantalla completa sobre fondo oscuro, con
  // un turquesa claro que sí pasa ahí; y el inicio es la página de marca,
  // turquesa, con las dos respuestas en blanco. El contraste se mide igual.
  if (!{'reprodutor', 'bienvenida'}.contains(nome)) {
    for (final e in principales) {
      final material = tester.widget<Material>(find
          .descendant(
              of: find.byWidget(e.widget), matching: find.byType(Material))
          .first);
      if (material.color != acento) {
        fallos.add('Botón principal de color ${material.color} y no del '
            'acento $acento: ${_rotulo(e)}.');
      }
    }
  }
  fallos.addAll(await _auditarTexto(tester, marco));
  return fallos;
}

String _rotulo(Element e) {
  final textos = <String>[];
  void visitar(Element h) {
    final w = h.widget;
    if (w is Text && w.data != null) textos.add(w.data!);
    h.visitChildren(visitar);
  }

  e.visitChildren(visitar);
  return '«${textos.join(' ')}»';
}

/// Mide el contraste de cada texto de la pantalla contra lo que tiene detrás.
///
/// El color del texto sale de su estilo; el del fondo, de la imagen pintada:
/// el color más repetido dentro de la caja del texto, quitando los píxeles
/// que se parecen al propio texto. Así cuenta cualquier fondo —una tarjeta,
/// un degradado, una lámina, el chip elegido— sin tener que saber de qué
/// widget sale.
Future<List<String>> _auditarTexto(WidgetTester tester, Key marco) async {
  final caja = tester.renderObject<RenderRepaintBoundary>(find.byKey(marco));
  late ui.Image imaxe;
  late ByteData pixeles;
  await tester.runAsync(() async {
    imaxe = await caja.toImage();
    pixeles = (await imaxe.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  });
  final ancho = imaxe.width, alto = imaxe.height;

  Color pixel(int x, int y) {
    final i = (y * ancho + x) * 4;
    return Color.fromARGB(255, pixeles.getUint8(i), pixeles.getUint8(i + 1),
        pixeles.getUint8(i + 2));
  }

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
    final estilo = p.text.style;
    if (estilo?.fontFamily == 'MaterialIcons') continue;
    if (_desactivado(p)) continue;
    final rect = _visible(p, caja)
        .intersect(Rect.fromLTWH(0, 0, ancho.toDouble(), alto.toDouble()));
    if (rect.width < 4 || rect.height < 4) continue;

    final cores = <Color>{};
    p.text.visitChildren((span) {
      if (span is TextSpan &&
          (span.text?.trim().isNotEmpty ?? false) &&
          span.style?.foreground == null) {
        cores
            .add(span.style?.color ?? estilo?.color ?? const Color(0xFF000000));
      }
      return true;
    });
    if (cores.isEmpty) continue;

    final familia = estilo?.fontFamily;
    if (familia != AppTheme.fontFamily) {
      fallos.add('Fuera de Nunito ($familia): «${_corto(texto)}».');
    }

    final tamano = estilo?.fontSize ?? 14;
    final peso = estilo?.fontWeight ?? FontWeight.w400;
    final grande = tamano >= 24 || (tamano >= 18.66 && peso.value >= 700);
    final minimo = grande ? 3.0 : 4.5;

    for (final cor in cores) {
      final fondo = _fondo(rect, cor, pixel);
      if (fondo == null) continue;
      final opaca = Color.alphaBlend(cor, fondo);
      final ratio = _contraste(opaca, fondo);
      if (ratio + 0.005 < minimo) {
        fallos.add('${ratio.toStringAsFixed(2)}:1 < $minimo · '
            '${_hex(opaca)} sobre ${_hex(fondo)} · «${_corto(texto)}»');
      }
    }
  }
  return fallos;
}

/// La parte de [p] que de verdad se pinta: su caja recortada por cada
/// antecesor que recorta (una lista que se desplaza, un marco con techo). Un
/// texto escondido bajo el pliegue de una lista no se ve, y medir el color que
/// hay en su sitio sería medir el de otra cosa.
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

/// El texto de un botón o un chip apagado no tiene que pasar AA (WCAG 1.4.3
/// excluye los componentes inactivos).
bool _desactivado(RenderParagraph p) {
  final creador = p.debugCreator;
  if (creador is! DebugCreator) return false;
  var apagado = false;
  creador.element.visitAncestorElements((e) {
    final w = e.widget;
    if (w is ButtonStyleButton) {
      apagado = !w.enabled;
      return false;
    }
    if (w is ChoiceChip) {
      apagado = w.onSelected == null;
      return false;
    }
    return true;
  });
  return apagado;
}

Color? _fondo(Rect r, Color texto, Color Function(int, int) pixel) {
  final contas = <int, int>{};
  final paso = math.max(1, (r.width * r.height / 4000).sqrt().floor());
  for (var y = r.top.ceil(); y < r.bottom.floor(); y += paso) {
    for (var x = r.left.ceil(); x < r.right.floor(); x += paso) {
      final c = pixel(x, y);
      if (_distancia(c, texto) < 60) continue;
      contas.update(c.toARGB32(), (n) => n + 1, ifAbsent: () => 1);
    }
  }
  if (contas.isEmpty) return null;
  final mais = contas.entries.reduce((a, b) => a.value >= b.value ? a : b);
  return Color(mais.key);
}

double _distancia(Color a, Color b) {
  final dr = (a.r - b.r) * 255, dg = (a.g - b.g) * 255, db = (a.b - b.b) * 255;
  return math.sqrt(dr * dr + dg * dg + db * db);
}

double _contraste(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

String _corto(String t) {
  final una = t.replaceAll('\n', ' ');
  return una.length > 40 ? '${una.substring(0, 40)}…' : una;
}

extension on double {
  double sqrt() => math.sqrt(this);
}
