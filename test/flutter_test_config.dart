import 'dart:async';

import 'dart:io';

import 'package:descubre_con_lua/core/brand/lua_valeria.dart';
import 'package:descubre_con_lua/features/criancas/criancas_store.dart';
import 'package:descubre_con_lua/features/criancas/xogo_lua.dart';
import 'package:descubre_con_lua/features/leccions/widgets/proxecto_0_2.dart';

/// En todos los tests, el Portal Familias entra con un niño ya registrado
/// (O-20261109-1) y en memoria, sin tocar disco: así cada test ve casa como
/// la ve una familia el segundo día. El registro de la primera vez lo prueba
/// `test/features/criancas_test.dart`, que vuelve a poner el de verdad.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Lúa quieta y ya leída: una animación infinita no deja terminar a
  // pumpAndSettle, y un futuro del paquete bajo el reloj falso no acaba.
  luaQuieta = true;
  ArteLua.sembrar(ArteLua.fromRaw(File(ArteLua.assetPath).readAsStringSync()));
  CatalogoLua.sembrar(
      CatalogoLua.fromRaw(File(CatalogoLua.assetPath).readAsStringSync()));
  Proxectos02.sembrar(
      Proxectos02.fromRaw(File(Proxectos02.assetPath).readAsStringSync()));
  CriancasStore.crear = () => CriancasStore.enMemoria(const [
        Crianza(id: 'c1', nome: 'Uxía', idade: 1, curso: 'curso_0_2'),
      ]);
  await testMain();
}
