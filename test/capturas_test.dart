@Tags(['capturas'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/brand/lamina_pixel.dart';
import 'package:descubre_con_lua/core/brand/lua_pixel.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/local_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/data/repositories/calendario_repository.dart';
import 'package:descubre_con_lua/data/models/unidad_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/data/repositories/ritual_repository.dart';
import 'package:descubre_con_lua/features/academy/views/guia_atencion_screen.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_screen.dart';
import 'package:descubre_con_lua/features/juega/views/asamblea_guiada_screen.dart';
import 'package:descubre_con_lua/features/juega/views/nota_para_casas_screen.dart';
import 'package:descubre_con_lua/features/academy/views/bloques_list_screen.dart';
import 'package:descubre_con_lua/features/academy/views/capsula_detail_screen.dart';
import 'package:descubre_con_lua/features/bienvenida/welcome_screen.dart';
import 'package:descubre_con_lua/features/creditos/credits_screen.dart';
import 'package:descubre_con_lua/features/juega/views/capsulas_aula_screen.dart';
import 'package:descubre_con_lua/features/juega/views/backstage_asamblea_screen.dart';
import 'package:descubre_con_lua/features/juega/views/unidades_list_screen.dart';
import 'package:descubre_con_lua/features/academy/views/micro_rutina_setembro_screen.dart';
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

  /// La unidad del mes en curso: la que una docente abriría hoy. Antes se
  /// retrataba `getAllUnidades().first`, que con diez unidades es la primera
  /// por orden alfabético y no tiene nada que ver con el mes.
  Future<Unidad> unidadDeHoxe(WidgetTester tester) async {
    final cal = await contenidoCalendario(tester);
    final id = cal.mesParaFecha(DateTime.now()).unidadId;
    return contenido.getUnidadById(id!)!;
  }

  /// Las láminas del vocabulario se leen del paquete, que es E/S real, y bajo
  /// el reloj falso del test esa espera no avanza: en la primera tanda las
  /// palabras salieron sin dibujo. Igual que la gata, hay que calentarlas
  /// antes, y comprobar que de verdad llegaron.
  Future<void> calentarLaminas(WidgetTester tester) async {
    final claves = <String>{
      for (final unidad in contenido.getAllUnidades()) ...[
        for (final item in unidad.vocabulario)
          if (item.lamina.isNotEmpty) item.lamina,
        // También las escenas del cuento. Sin calentarlas, la captura de la
        // fase 2 retrata el aviso de «lámina pendente» y no la ilustración:
        // la lectura del paquete es E/S real y el reloj falso del test no la
        // hace avanzar.
        for (final pagina in unidad.cuento.paginas)
          if (pagina.lamina.isNotEmpty) pagina.lamina,
      ],
    };
    for (final clave in claves) {
      await tester.pumpWidget(
        MaterialApp(home: Center(child: LaminaPixel(clave: clave, size: 64))),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(LaminaPixel),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
        reason: 'A lámina $clave non chegou a cargarse.',
      );
    }
  }

  /// El ritual de la asamblea —la consigna de cada fase y sus minutos— también
  /// se lee del paquete, y también hay que calentarlo.
  ///
  /// Sin esto, las capturas de la asamblea en CASTELLANO salían SIN la caja de
  /// la consigna y sin los minutos totales, que es justo lo que define el modo
  /// asamblea. En gallego sí aparecían. No era el idioma: el ritual se cachea
  /// en un `static`, y el futuro que quedaba guardado lo había creado el test
  /// anterior, en SU zona de reloj falso. Un `.then` sobre ese futuro se
  /// encola en una zona que ya está muerta y no se ejecuta nunca.
  ///
  /// Por eso se OLVIDA primero y se vuelve a cargar dentro de `runAsync`, que
  /// es tiempo de verdad, y se comprueba que llegaron las seis fases. Sin la
  /// comprobación esto sería otra espera que se salta en silencio.
  Future<void> calentarRitual(WidgetTester tester) async {
    RitualAsamblea.olvidar();
    RitualAsamblea? cargado;
    await tester.runAsync(() async {
      cargado = await RitualAsamblea.cargar();
    });
    expect(cargado?.fases.length, 6,
        reason: 'O ritual da asemblea non chegou a cargarse: as capturas '
            'sairían sen a consigna de cada fase.');
  }

  Future<void> capturar(
    WidgetTester tester,
    String nombre,
    Widget pantalla, {
    Size tamano = const Size(412, 915),

    /// Lo que hay que hacer sobre la pantalla ya montada antes de retratarla:
    /// pulsar hasta una página concreta, responder una reflexión. Sin esto,
    /// una pantalla paginada solo se puede retratar por su primera página.
    Future<void> Function(WidgetTester tester)? antesDeRetratar,
  }) async {
    await calentarMascota(tester);
    await calentarLaminas(tester);
    // También aquí: `asamblea-ingles-{gl,es}` pasa por este ayudante, y sin el
    // ritual retrataba la asamblea sin su consigna.
    await calentarRitual(tester);

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

    if (antesDeRetratar != null) {
      await antesDeRetratar(tester);
      await tester.pumpAndSettle();
    }

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
      // El calendario, ya leído. Si se deja que lo lea la propia sección, la
      // lectura puede no llegar antes del retrato y la imagen sale con un
      // hueco en blanco donde va el calendario.
      final cal = await contenidoCalendario(tester);
      await capturar(
          tester,
          'aula-unidades-$l',
          UnidadesListScreen(
            repository: contenido,
            premios: premios,
            audioService: MockOfflineAudioService(),
            initialLanguage: lang,
            calendarioContenido: cal,
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

    testWidgets('aula · lista, pestana de 2.º ciclo · $l', (tester) async {
      final premios = await premiosConProgreso(tester);
      final cal = await contenidoCalendario(tester);
      await capturar(
        tester,
        'aula-lista-2ciclo-$l',
        UnidadesListScreen(
          repository: contenido,
          premios: premios,
          audioService: MockOfflineAudioService(),
          initialLanguage: lang,
          calendarioContenido: cal,
        ),
        tamano: const Size(412, 900),
        antesDeRetratar: (tester) async {
          await tester.tap(find.byKey(const ValueKey('tab_segundo_ciclo')));
          await tester.pumpAndSettle();
        },
      );
    });

    testWidgets('aula · backstage da asemblea de 2.º ciclo · $l',
        (tester) async {
      await capturar(
        tester,
        'aula-backstage-$l',
        BackstageAsambleaScreen(
          repository: contenido,
          audioService: MockOfflineAudioService(),
          initialLanguage: lang,
        ),
        tamano: const Size(412, 1200),
      );
    });

    testWidgets('academy · micro-rutina de setembro · $l', (tester) async {
      await capturar(
        tester,
        'academy-micro-rutina-$l',
        MicroRutinaSetembroScreen(
          initialLanguage: lang,
          curriculo: contenido
              .getCapsulaById('academy.segundo_ciclo.setembro.01')
              ?.curriculo,
        ),
        tamano: const Size(412, 2000),
      );
    });

    testWidgets('academy · bloques · $l', (tester) async {
      final premios = await premiosConProgreso(tester);
      final cal = await contenidoCalendario(tester);
      await capturar(
        tester,
        'academy-bloques-$l',
        BloquesListScreen(
          repository: contenido,
          premios: premios,
          initialLanguage: lang,
          calendarioContenido: cal,
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

    testWidgets('academy · o peche de Lúa · $l', (tester) async {
      // La página de la gata es la ÚLTIMA del lector, así que para retratarla
      // hay que recorrer la cápsula entera: cuatro secciones y la reflexión,
      // que no deja pasar sin respuesta.
      final capsula =
          contenido.getCapsulasByBloqueId('desarrollo_comunicativo').first;
      expect(capsula.luaDice, isNotNull,
          reason: 'Esta cápsula ya no trae el cierre de Lúa: la captura '
              'retrataría otra pantalla sin avisar.');
      await capturar(
        tester,
        'academy-lua-peche-$l',
        CapsulaDetailScreen(
          capsula: capsula,
          initialLanguage: lang,
          audioService: MockOfflineAudioService(),
        ),
        antesDeRetratar: (t) async {
          final siguiente = lang == AppLanguage.gl ? 'Seguinte' : 'Siguiente';
          final verdadero = lang == AppLanguage.gl ? 'Verdadeiro' : 'Verdadero';
          for (var i = 0; i < 12; i++) {
            if (find.text(siguiente).evaluate().isEmpty) break;
            final boton = t.widget<ElevatedButton>(find.byType(ElevatedButton));
            if (boton.onPressed == null) {
              if (find.text(verdadero).evaluate().isEmpty) break;
              await t.tap(find.text(verdadero));
              await t.pumpAndSettle();
              continue;
            }
            await t.tap(find.text(siguiente));
            await t.pumpAndSettle();
          }
          expect(find.text(capsula.luaDice!.resolve(lang)), findsOneWidget,
              reason: 'La captura no llegó a la página del cierre de Lúa.');
        },
      );
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

    testWidgets('asamblea · o inglés na fase · $l', (tester) async {
      await capturar(
        tester,
        'asamblea-ingles-$l',
        AsambleaGuiadaScreen(
          unidad: await unidadDeHoxe(tester),
          initialLanguage: lang,
          audioService: MockOfflineAudioService(),
        ),
        tamano: const Size(412, 1400),
      );
    });

    testWidgets('asamblea · o conto e as palabras · $l', (tester) async {
      // La fase 2, que es donde estrena la tarjeta del vocabulario con las
      // tres lenguas. `capturar` monta la fase 1, así que hay que avanzar y
      // volver a retratar: por eso esta no usa el ayudante tal cual.
      final unidad = await unidadDeHoxe(tester);
      await calentarMascota(tester);
      await calentarLaminas(tester);
      await calentarRitual(tester);
      tester.view.physicalSize = const Size(412, 1800) * 2;
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: AsambleaGuiadaScreen(
          unidad: unidad,
          initialLanguage: lang,
          audioService: MockOfflineAudioService(),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('boton_seguinte_fase')));
      await tester.pumpAndSettle();
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 120)));
      await tester.pumpAndSettle();

      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('../docs/capturas/asamblea-conto-$l.png'));
    });

    testWidgets('asamblea · o protocolo de seguridade · $l', (tester) async {
      // La fase 4, que es donde vive el AVISO DE SEGURIDAD. Ninguna captura
      // llegaba hasta aquí, así que el aviso que la docente lee antes de sacar
      // material —castañas, cascabeles, caretas— no estaba retratado en ningún
      // sitio. Es justo la pantalla donde un fallo visual tiene consecuencias
      // fuera de la pantalla.
      final unidad = await unidadDeHoxe(tester);
      await calentarMascota(tester);
      await calentarLaminas(tester);
      await calentarRitual(tester);
      tester.view.physicalSize = const Size(412, 1500) * 2;
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: AsambleaGuiadaScreen(
          unidad: unidad,
          initialLanguage: lang,
          audioService: MockOfflineAudioService(),
        ),
      ));
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const Key('boton_seguinte_fase')));
        await tester.pumpAndSettle();
      }
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 120)));
      await tester.pumpAndSettle();

      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('../docs/capturas/asamblea-seguridade-$l.png'));
    });

    testWidgets('a nota para as casas · $l', (tester) async {
      await capturar(
        tester,
        'nota-casas-$l',
        NotaParaCasasScreen(
          unidad: await unidadDeHoxe(tester),
          language: lang,
          audioService: MockOfflineAudioService(),
        ),
        tamano: const Size(412, 1200),
      );
    });

    testWidgets('calendario · lado familia · $l', (tester) async {
      final calendario = await calendarioConProgreso(tester);
      final cal = await contenidoCalendario(tester);
      await capturar(
        tester,
        'calendario-familia-$l',
        CalendarioScreen(
          store: calendario,
          contenido: cal,
          repository: contenido,
          initialLanguage: lang,
          esDocenteInicial: false,
        ),
        // Un móvil de verdad, no un lienzo de 1800 px. El Calendario ya no es
        // una página larga: cabe en una pantalla y el mes se pasa de lado.
      );
    });

    testWidgets('calendario escola-fogar · $l', (tester) async {
      final premios = await premiosConProgreso(tester);
      final calendario = await calendarioConProgreso(tester);
      final contenidoCal = await contenidoCalendario(tester);
      await capturar(
        tester,
        'calendario-$l',
        CalendarioScreen(
          store: calendario,
          contenido: contenidoCal,
          repository: contenido,
          premios: premios,
          initialLanguage: lang,
          esDocenteInicial: true,
        ),
        // Un móvil de verdad, no un lienzo de 2000 px: esa altura era la
        // prueba de que la pantalla medía 2,2 pantallas de alto.
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
