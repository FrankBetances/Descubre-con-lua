import 'package:descubre_con_lua/core/brand/lua_valeria.dart';
import 'package:descubre_con_lua/core/widgets/movimiento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// O-20261119-7: la app se mueve, pero se para del todo si el sistema pide
/// reducir movimiento.
void main() {
  // Aquí se prueba el movimiento de verdad: sin la Lúa quieta de los tests.
  setUp(() => luaQuieta = false);
  tearDown(() => luaQuieta = true);

  Widget app({required bool reducir, required Widget child}) => MediaQuery(
        data: MediaQueryData(disableAnimations: reducir),
        child: MaterialApp(home: Scaffold(body: Center(child: child))),
      );

  testWidgets('con movimiento, el nodo de hoy late', (t) async {
    await t.pumpWidget(
        app(reducir: false, child: const Latido(child: SizedBox(width: 10))));
    expect(
        find.descendant(
            of: find.byType(Latido), matching: find.byType(ScaleTransition)),
        findsOneWidget);
    await t.pump(const Duration(milliseconds: 700));
    final s = t.widget<ScaleTransition>(find.descendant(
        of: find.byType(Latido), matching: find.byType(ScaleTransition)));
    expect(s.scale.value, greaterThan(1.0));
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('reducir movimiento: nada late, flota ni cae confeti', (t) async {
    await t.pumpWidget(app(
      reducir: true,
      child: const Column(children: [
        Latido(child: Text('a')),
        Flotar(child: Text('b')),
        Entrada(orden: 3, child: Text('c')),
        SizedBox(width: 200, height: 200, child: Confeti(cores: [Colors.red])),
        ContadorAnimado(valor: 30),
      ]),
    ));
    // Todo en su estado final en el primer cuadro, sin reloj pendiente.
    expect(
        find.descendant(
            of: find.byType(Latido), matching: find.byType(ScaleTransition)),
        findsNothing);
    expect(
        find.descendant(
            of: find.byType(Confeti), matching: find.byType(CustomPaint)),
        findsNothing);
    expect(find.text('c'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    // Ningún reloj en marcha.
    await t.pump();
    expect(t.binding.transientCallbackCount, 0);
  });

  testWidgets('los puntos se cuentan hasta el total', (t) async {
    await t.pumpWidget(
        app(reducir: false, child: const ContadorAnimado(valor: 20)));
    expect(find.text('0'), findsOneWidget);
    await t.pumpAndSettle();
    expect(find.text('20'), findsOneWidget);
  });

  testWidgets('el confeti cae una vez y se acaba', (t) async {
    await t.pumpWidget(app(
        reducir: false,
        child: const SizedBox(
            width: 200, height: 200, child: Confeti(cores: [Colors.red]))));
    await t.pumpAndSettle();
    expect(t.binding.transientCallbackCount, 0);
  });
}
