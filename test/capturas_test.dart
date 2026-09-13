@Tags(['capturas'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/brand/lua_pixel.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/local_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/data/repositories/calendario_repository.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/academy/views/guia_atencion_screen.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_screen.dart';
import 'package:descubre_con_lua/features/academy/views/bloques_list_screen.dart';
import 'package:descubre_con_lua/features/academy/views/capsula_detail_screen.dart';
import 'package:descubre_con_lua/features/bienvenida/welcome_screen.dart';
import 'package:descubre_con_lua/features/creditos/credits_screen.dart';
import 'package:descubre_con_lua/features/juega/views/capsulas_aula_screen.dart';
import 'package:descubre_con_lua/features/juega/views/unidades_list_screen.dart';
import 'package:descubre_con_lua/features/premios/premios_model.dart';
import 'package:descubre_con_lua/features/premios/premios_repository.dart';
import 'package:descubre_con_lua/features/premios/premios_screen.dart';

/// Genera las imágenes de pantalla del manual.
///
/// LO QUE ESTO ES: el árbol de widgets REAL pintado por el motor de Flutter,
/// con la tipografía real de la app y con el contenido real de los JSON. La
/// disposición es la que la app calcula, no una maqueta.
///
/// LO QUE ESTO NO ES: una captura de un aparato. Aquí no hay muesca ni barra de
/// gestos, la densidad es la que se fija abajo y no la de un teléfono concreto,
/// la escala de texto del sistema es 1,0 y el audio no suena. La regla 1c de
/// CLAUDE.md dice exactamente esto. Sustituir estas imágenes por capturas de
/// verdad es cambiar los PNG de sitio, sin tocar el manual:
///
///     flutter run -d <dispositivo>
///     adb exec-out screencap -p > docs/capturas/<nombre>.png
///
/// Se corre a mano, no en los gates:
///     flutter test --tags capturas test/capturas_test.dart
void main() {
  final salida = Directory('docs/capturas');

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    if (!salida.existsSync()) salida.createSync(recursive: true);

    // Sin esto, Flutter pinta con la fuente de relleno y las imágenes no se
    // parecerían a la app. Es la diferencia entre un render útil y un cuadrado
    // con cajas negras.
    //
    // MaterialIcons hace falta aparte: sin ella TODOS los iconos salen como un
    // cuadrado vacío, y en la primera tanda de imágenes salieron así. La
    // fuente vive en la caché del SDK, no en el proyecto, así que se localiza
    // desde el ejecutable de Dart que está corriendo el test.
    // Se BUSCA hacia arriba en vez de contar carpetas: la profundidad del
    // ejecutable de Dart dentro del SDK cambió ya una vez y dejó el fichero
    // sin encontrar.
    File? iconos;
    var dir = File(Platform.resolvedExecutable).parent;
    for (var i = 0; i < 8 && iconos == null; i++) {
      final f = File(
        '${dir.path}/artifacts/material_fonts/MaterialIcons-Regular.otf',
      );
      if (f.existsSync()) iconos = f;
      dir = dir.parent;
    }
    if (iconos == null) {
      fail('No se encuentra MaterialIcons subiendo desde '
          '${Platform.resolvedExecutable}. Sin esa fuente los iconos salen '
          'como un cuadrado vacío y las imágenes no sirven para el manual.');
    }

    for (final entry in {
      'Nunito': [
        'assets/fonts/Nunito-Regular.ttf',
        'assets/fonts/Nunito-SemiBold.ttf',
        'assets/fonts/Nunito-Bold.ttf',
        'assets/fonts/Nunito-ExtraBold.ttf',
      ],
      'MaterialIcons': [iconos.path],
    }.entries) {
      final loader = FontLoader(entry.key);
      for (final path in entry.value) {
        loader.addFont(
          File(path).readAsBytes().then((b) => ByteData.view(b.buffer)),
        );
      }
      await loader.load();
    }
  });

  late ContentRepository contenido;
  late Directory tmp;

  setUp(() async {
    contenido = ContentRepository();
    await contenido.initialize();
    tmp = Directory.systemTemp.createTempSync('capturas');
  });

  tearDown(() {
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  Future<PremiosRepository> premiosConProgreso(WidgetTester tester) async {
    var reloj = DateTime(2026, 3, 1);
    final repo = PremiosRepository(
      store: LocalStore(fileName: 'premios.json', overrideDirectory: tmp.path),
      ahora: () => reloj,
    );
    await tester.runAsync(() async {
      await repo.cargar();
      // Progreso de muestra: sin él las imágenes enseñarían todo a cero y no
      // se vería ni la barra, ni la racha, ni una insignia ganada.
      for (var i = 0; i < 12; i++) {
        await repo.registrar(Perfil.docente, EventoPremio.asamblea);
        await repo.registrar(Perfil.familia, EventoPremio.capsula);
        reloj = reloj.add(const Duration(days: 1));
      }
    });
    return repo;
  }

  /// El contenido del calendario, leído del disco dentro de `runAsync`: bajo
  /// el reloj falso del test una lectura de fichero de verdad no termina.
  Future<CalendarioContenido> contenidoCalendario(WidgetTester tester) async {
    late CalendarioContenido contenido;
    await tester.runAsync(() async {
      contenido = await CalendarioContenido.cargar(
        stringLoader: (path) => File(path).readAsString(),
      );
    });
    return contenido;
  }

  /// Un calendario con días ya enlazados: sin esto la imagen enseñaría el
  /// curso entero a cero y no se vería ni un estado ni una medalla.
  Future<CalendarioStore> calendarioConProgreso(WidgetTester tester) async {
    final store = CalendarioStore(overrideDirectory: tmp.path);
    await tester.runAsync(() async {
      await store.cargar();
      var dia = DateTime(2026, 3, 1);
      for (var i = 0; i < 6; i++) {
        await store.registrarAula(dia);
        if (i % 2 == 0) await store.registrarHogar(dia);
        dia = dia.add(const Duration(days: 1));
      }
      await store.registrarAula(DateTime.now());
      await store.registrarHogar(DateTime.now());
    });
    return store;
  }

  /// Deja las dos rejillas de Lúa en la caché ANTES de pintar la pantalla.
  ///
  /// Sin esto, la pose `head` no llegaba a cargarse en esta tanda y salía el
  /// hueco vacío en créditos, en la tira de juego y en la cabecera de premios,
  /// mientras `sit` sí salía en la bienvenida. La carga es E/S real y bajo el
  /// reloj falso no avanza de forma fiable; aquí se monta cada pose suelta
  /// dentro de `runAsync`, que es donde la E/S sí corre, y a partir de ahí
  /// `LuaPixel` la lee de su caché estática en el primer build.
  ///
  /// Es un apaño DEL ARNÉS, no de la app: en un aparato no hay reloj falso.
  Future<void> calentarMascota(WidgetTester tester) async {
    for (final pose in LuaPose.values) {
      await tester.pumpWidget(
        MaterialApp(home: Center(child: LuaPixel(pose: pose, size: 64))),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(LuaPixel),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
        reason: 'La pose ${pose.name} no llegó a cargarse; las imágenes '
            'saldrían sin la gata.',
      );
    }
  }

  Future<void> capturar(
    WidgetTester tester,
    String nombre,
    Widget pantalla, {
    Size tamano = const Size(412, 915),
  }) async {
    await calentarMascota(tester);

    tester.view.physicalSize = tamano * 2;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: pantalla,
      ),
    );
    await tester.pumpAndSettle();

    // La gata y las insignias se leen del paquete, que es E/S REAL, y bajo el
    // reloj falso esa espera no avanza de forma fiable: en la primera tanda de
    // imágenes la gata salió a veces y a veces dejó la placa vacía. `runAsync`
    // le da al bucle de eventos la vuelta que le falta, y el pump de después
    // repinta ya con la rejilla cargada.
    await tester.runAsync(() => Future<void>.delayed(
          const Duration(milliseconds: 120),
        ));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../docs/capturas/$nombre.png'),
    );
  }

  for (final lang in AppLanguage.deInterfaz) {
    final l = lang.code;

    testWidgets('bienvenida · $l', (tester) async {
      await capturar(
          tester,
          'bienvenida-$l',
          WelcomeScreen(
            currentLanguage: lang,
            onToggleLanguage: () {},
            onStart: () {},
            onShowCredits: () {},
          ));
    });

    testWidgets('creditos · $l', (tester) async {
      await capturar(
        tester,
        'creditos-$l',
        CreditsScreen(currentLanguage: lang),
        tamano: const Size(412, 1500),
      );
    });

    testWidgets('aula · lista de unidades · $l', (tester) async {
      final premios = await premiosConProgreso(tester);
      await capturar(
          tester,
          'aula-unidades-$l',
          UnidadesListScreen(
            repository: contenido,
            premios: premios,
            audioService: MockOfflineAudioService(),
            initialLanguage: lang,
          ));
    });

    testWidgets('aula · formación docente · $l', (tester) async {
      final premios = await premiosConProgreso(tester);
      await capturar(
        tester,
        'aula-formacion-$l',
        CapsulasAulaScreen(
          repository: contenido,
          premios: premios,
          initialLanguage: lang,
        ),
        tamano: const Size(412, 1400),
      );
    });

    testWidgets('academy · bloques · $l', (tester) async {
      final premios = await premiosConProgreso(tester);
      await capturar(
        tester,
        'academy-bloques-$l',
        BloquesListScreen(
          repository: contenido,
          premios: premios,
          initialLanguage: lang,
        ),
        tamano: const Size(412, 1400),
      );
    });

    testWidgets('academy · lector de cápsula · $l', (tester) async {
      final capsula =
          contenido.getCapsulasByBloqueId('desarrollo_comunicativo').first;
      await capturar(
          tester,
          'academy-lector-$l',
          CapsulaDetailScreen(
            capsula: capsula,
            initialLanguage: lang,
            audioService: MockOfflineAudioService(),
          ));
    });

    testWidgets('premios · $l', (tester) async {
      final premios = await premiosConProgreso(tester);
      final calendario = await calendarioConProgreso(tester);
      await capturar(
        tester,
        'premios-$l',
        PremiosScreen(
          repository: premios,
          currentLanguage: lang,
          contadores: calendario.contadores,
        ),
        tamano: const Size(412, 2200),
      );
    });

    testWidgets('calendario escola-fogar · $l', (tester) async {
      final premios = await premiosConProgreso(tester);
      final calendario = await calendarioConProgreso(tester);
      final contenido = await contenidoCalendario(tester);
      await capturar(
        tester,
        'calendario-$l',
        CalendarioScreen(
          store: calendario,
          contenido: contenido,
          premios: premios,
          initialLanguage: lang,
          esDocenteInicial: true,
        ),
        tamano: const Size(412, 2000),
      );
    });

    testWidgets('guía de inglés en casa · $l', (tester) async {
      final contenido = await contenidoCalendario(tester);
      await capturar(
        tester,
        'guia-ingles-$l',
        GuiaAtencionScreen(contenido: contenido, initialLanguage: lang),
        tamano: const Size(412, 1500),
      );
    });
  }
}
