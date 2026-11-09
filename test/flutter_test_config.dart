import 'dart:async';

import 'package:descubre_con_lua/features/criancas/criancas_store.dart';

/// En todos los tests, el Portal Familias entra con un niño ya registrado
/// (O-20261109-1) y en memoria, sin tocar disco: así cada test ve casa como
/// la ve una familia el segundo día. El registro de la primera vez lo prueba
/// `test/features/criancas_test.dart`, que vuelve a poner el de verdad.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  CriancasStore.crear = () => CriancasStore.enMemoria(const [
        Crianza(id: 'c1', nome: 'Uxía', idade: 1, curso: 'curso_0_2'),
      ]);
  await testMain();
}
