import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/calendario_model.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/repositories/calendario_repository.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/academy/views/guia_atencion_screen.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_screen.dart';
import 'package:descubre_con_lua/features/premios/premios_model.dart';

import '../../helpers/scroll_helpers.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: AppTheme.lightTheme, home: child);

/// El contenido real del repositorio, leído del disco.
///
/// Se lee el MISMO fichero que viaja en el paquete, no una copia de prueba: si
/// alguien rompe `meses.json`, estos tests se enteran. Es lo que hacen ya los
/// tests de unidades y cápsulas.
Future<CalendarioContenido> _contenidoDeDisco() => CalendarioContenido.cargar(
      stringLoader: (path) => File(path).readAsString(),
    );

void main() {
  late CalendarioContenido contenido;
  late ContentRepository repositorio;

  setUpAll(() async {
    contenido = await _contenidoDeDisco();
    // El contenido REAL del repositorio, leído del disco: si alguien borra la
    // unidad o le cambia el id, estos tests se enteran.
    repositorio = ContentRepository(
      loader: ContentAssetLoader(
        stringLoader: (path) => File(path).readAsString(),
      ),
    );
    // TODAS las unidades del disco, no una elegida a mano: el test hardcodeaba
    // `juega.mar.01.json` y por eso siguió en verde mientras el calendario
    // abría siempre la misma asamblea. Si alguien añade un mes sin unidad, o
    // le cambia el id a una, esto se entera.
    final unidades = Directory('assets/content/unidades')
        .listSync()
        .whereType<File>()
        .map((f) => f.path)
        .where((p) => p.endsWith('.json'))
        .toList()
      ..sort();
    await repositorio.initialize(
      unidadPaths: unidades,
      capsulaPaths: const [],
    );
  });
  group('CalendarioModel & 10 Meses Curriculares de Galicia', () {
    test('contén exactamente 10 meses de setembro a xunho', () {
      expect(contenido.meses.length, 10);
      expect(contenido.meses.first.orden, 1);
      expect(contenido.meses.first.mesCalendario, 9); // Setembro
      expect(contenido.meses.last.orden, 10);
      expect(contenido.meses.last.mesCalendario, 6); // Xuño
    });

    test('todos os meses teñen paridade lingüística e contidos TPR completos',
        () {
      for (final mes in contenido.meses) {
        expect(mes.nombreMes.hasParity, isTrue);
        expect(mes.centroInteres.hasParity, isTrue);
        expect(mes.objetivoPedagogico.hasParity, isTrue);
        expect(mes.actividadAula.hasParity, isTrue);
        expect(mes.actividadHogar.hasParity, isTrue);
        expect(mes.rutinaRecomendadaHogar.hasParity, isTrue);

        expect(mes.ingles.lexico, isNotEmpty);
        expect(mes.ingles.tpr, isNotEmpty);
        expect(mes.ingles.frase, isNotEmpty);
        expect(mes.minutosSugeridos, inInclusiveRange(2, 8));
        // El icono es un token de contenido, nunca un IconData.
        expect(mes.icono, isNotEmpty);
      }
    });

    test('mesActualParaFecha resolve correctamente o mes escolar regular', () {
      final setembro = DateTime(2026, 9, 15);
      expect(contenido.mesParaFecha(setembro).mesCalendario, 9);

      final febreiro = DateTime(2027, 2, 20);
      expect(contenido.mesParaFecha(febreiro).mesCalendario, 2);

      final xunho = DateTime(2027, 6, 10);
      expect(contenido.mesParaFecha(xunho).mesCalendario, 6);
    });

    // Edge case: Vacation months (Xullo e Agosto)
    test(
        'mesActualParaFecha xestiona meses de vacacións (xullo e agosto) con fallback a setembro',
        () {
      final xullo = DateTime(2026, 7, 20);
      final agosto = DateTime(2026, 8, 15);
      final agostoFin = DateTime(2026, 8, 31);

      expect(contenido.mesParaFecha(xullo).mesCalendario, 9);
      expect(contenido.mesParaFecha(xullo).orden, 1);

      expect(contenido.mesParaFecha(agosto).mesCalendario, 9);
      expect(contenido.mesParaFecha(agostoFin).mesCalendario, 9);
    });

    // Edge case: Boundary dates and Leap Year
    test('mesActualParaFecha resolve datas límite de curso e ano bisesto', () {
      final inicioCurso = DateTime(2026, 9, 1);
      expect(contenido.mesParaFecha(inicioCurso).mesCalendario, 9);

      final finCurso = DateTime(2027, 6, 30);
      expect(contenido.mesParaFecha(finCurso).mesCalendario, 6);

      final finAno = DateTime(2026, 12, 31);
      expect(contenido.mesParaFecha(finAno).mesCalendario, 12);

      final anoNovo = DateTime(2027, 1, 1);
      expect(contenido.mesParaFecha(anoNovo).mesCalendario, 1);

      final anoBisesto = DateTime(2028, 2, 29);
      expect(contenido.mesParaFecha(anoBisesto).mesCalendario, 2);
    });

    test('orde curricular e estritamente secuencial de 1 a 10', () {
      for (int i = 0; i < contenido.meses.length; i++) {
        expect(contenido.meses[i].orden, i + 1);
      }
    });
  });

  group('CalendarioStore - Persistencia Soberana e Doble Estimulación', () {
    late Directory tempDir;
    late CalendarioStore store;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('cal_test_');
      store = CalendarioStore(overrideDirectory: tempDir.path);
      await store.cargar();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
        'grafo completo de transición de estados e dobre estimulación reactiva',
        () async {
      final hoxe = DateTime(2026, 10, 15);
      expect(store.estadoParaFecha(hoxe), EstadoEstimulacion.sinRegistro);
      expect(store.totalDobleEstimulacion, 0);

      // Transición: sinRegistro -> soloAula
      final r1 = await store.registrarAula(hoxe);
      expect(r1, isTrue);
      expect(store.estadoParaFecha(hoxe), EstadoEstimulacion.soloAula);
      expect(store.totalSesionesAula, 1);
      expect(store.totalDobleEstimulacion, 0);

      // Transición: soloAula -> dobleEstimulacion
      final r2 = await store.registrarHogar(hoxe);
      expect(r2, isTrue);
      expect(store.estadoParaFecha(hoxe), EstadoEstimulacion.dobleEstimulacion);
      expect(store.totalSesionesHogar, 1);
      expect(store.totalDobleEstimulacion, 1);

      // Transición: toggle fogar desactiva dobre estimulación -> soloAula
      await store.toggleHogar(hoxe);
      expect(store.estadoParaFecha(hoxe), EstadoEstimulacion.soloAula);
      expect(store.totalDobleEstimulacion, 0);
      expect(store.totalSesionesHogar, 0);

      // Transición: toggle fogar reactiva dobre estimulación -> dobleEstimulacion
      await store.toggleHogar(hoxe);
      expect(store.estadoParaFecha(hoxe), EstadoEstimulacion.dobleEstimulacion);
      expect(store.totalDobleEstimulacion, 1);
      expect(store.totalSesionesHogar, 1);
    });

    test('transición inversa: rexistro primeiro en fogar e despois aula',
        () async {
      final data = DateTime(2026, 11, 20);
      expect(store.estadoParaFecha(data), EstadoEstimulacion.sinRegistro);

      // Rexistrar fogar primeiro
      await store.registrarHogar(data);
      expect(store.estadoParaFecha(data), EstadoEstimulacion.soloHogar);
      expect(store.totalDobleEstimulacion, 0);

      // Despois rexistrar aula -> Doble Estimulación
      await store.registrarAula(data);
      expect(store.estadoParaFecha(data), EstadoEstimulacion.dobleEstimulacion);
      expect(store.totalDobleEstimulacion, 1);
    });

    test(
        'idempotencia: chamadas repetidas a registrarAula non duplican contadores',
        () async {
      final data = DateTime(2026, 12, 5);
      expect(await store.registrarAula(data), isTrue); // Nova alta
      expect(await store.registrarAula(data), isFalse); // Xa existía
      expect(await store.registrarAula(data), isFalse); // Xa existía

      expect(store.totalSesionesAula, 1);
    });

    test('persistencia soberana roundtrip con múltiples datas independentes',
        () async {
      final d1 = DateTime(2026, 9, 15);
      final d2 = DateTime(2026, 9, 16);
      final d3 = DateTime(2026, 9, 17);
      final d4 = DateTime(2026, 9, 18);

      // d1: Doble Estimulación
      await store.registrarAula(d1);
      await store.registrarHogar(d1);

      // d2: Só Aula
      await store.registrarAula(d2);

      // d3: Só Fogar
      await store.registrarHogar(d3);

      // d4: Sen rexistro

      // Novo store le exactamente o mesmo estado do ficheiro en disco
      final storePersistido = CalendarioStore(overrideDirectory: tempDir.path);
      await storePersistido.cargar();

      expect(storePersistido.estadoParaFecha(d1),
          EstadoEstimulacion.dobleEstimulacion);
      expect(storePersistido.estadoParaFecha(d2), EstadoEstimulacion.soloAula);
      expect(storePersistido.estadoParaFecha(d3), EstadoEstimulacion.soloHogar);
      expect(
          storePersistido.estadoParaFecha(d4), EstadoEstimulacion.sinRegistro);

      expect(storePersistido.totalDobleEstimulacion, 1);
      expect(storePersistido.totalSesionesAula, 2);
      expect(storePersistido.totalSesionesHogar, 2);
    });

    test('recuperación limpa ante ficheiro JSON corrupto ou baleiro', () async {
      final file = File('${tempDir.path}/calendario_progreso.json');
      await file.writeAsString('{{{CORRUPT_JSON_DATA_INVALID_SYNTAX???');

      final storeCorrupto = CalendarioStore(overrideDirectory: tempDir.path);
      await storeCorrupto.cargar();

      // Debe abrir sen lanzar excepción e inicializar con mapa baleiro
      expect(storeCorrupto.totalDobleEstimulacion, 0);
      expect(storeCorrupto.totalSesionesAula, 0);

      // Pode seguir escribindo e gardando correctamente
      await storeCorrupto.registrarAula(DateTime(2026, 10, 1));
      expect(storeCorrupto.totalSesionesAula, 1);
    });
  });

  group('CalendarioScreen UI Widget Tests — 1-Touch Launch & Dual Flow', () {
    late Directory tempDir;
    late CalendarioStore store;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('cal_ui_test_');
      store = CalendarioStore(overrideDirectory: tempDir.path);
      await store.cargar();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    testWidgets('renderiza correctamente a cabeceira e o conmutador dual',
        (tester) async {
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        contenido: contenido,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Calendario Escola · Fogar'), findsOneWidget);
      expect(find.text('Aula (Docentes)'), findsOneWidget);
      expect(find.text('Fogar (Familias)'), findsOneWidget);
    });

    testWidgets('os dez meses teñen unidade e o de hoxe ábrese',
        (tester) async {
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Isto é o que Frank pedía: que o calendario sirva en setembro, non só
      // en xuño. Durante meses houbo UNHA unidade para dez meses.
      for (final mes in contenido.meses) {
        expect(mes.unidadId, isNotNull,
            reason: '${mes.nombreMes.gl} quedou sen unidade');
        expect(repositorio.getUnidadById(mes.unidadId!), isNotNull,
            reason:
                '${mes.nombreMes.gl} apunta a ${mes.unidadId}, que non existe');
      }

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        contenido: contenido,
        repository: repositorio,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('boton_iniciar_sesion_aula')), findsOneWidget);
      expect(find.byKey(const Key('aviso_mes_en_preparacion')), findsNothing);
    });

    testWidgets('o mes cámbiase deslizando a tarxeta de lado', (tester) async {
      // O que Frank pediu: tarxetas de desprazamento lateral. O que había era
      // unha tira de tarxetas de 160 px metida nunha páxina que medía 2,2
      // pantallas de alto, e o mes non se cambiaba deslizando: cambiábase
      // baixando ata as pastillas. Agora cada mes é unha páxina enteira.
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        contenido: contenido,
        repository: repositorio,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      // A pantalla abre polo mes que toca hoxe, non sempre por setembro.
      final indice = contenido.indiceParaFecha(DateTime.now());
      final aberto = contenido.meses[indice];
      final seguinte = contenido.meses[(indice + 1) % contenido.meses.length];
      expect(find.text(aberto.centroInteres.gl), findsWidgets);

      await tester.drag(
          find.byKey(const Key('paginas_meses')), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text(seguinte.centroInteres.gl), findsWidgets);
      // E o mes anterior XA NON ESTÁ na árbore. Non é un detalle: cando a
      // páxina veciña se construía había dous botóns «Iniciar asemblea» á vez,
      // un deles doutro mes e tocable polo canto.
      expect(find.text(aberto.centroInteres.gl), findsNothing);
    });

    testWidgets('a pastilla do mes aberto non se queda fóra da tira',
        (tester) async {
      // A tira de pastillas non se move soa. Deslizando ata o quinto mes, a
      // súa pastilla quedaba fóra da pantalla e a fila seguía a ensinar os
      // catro primeiros, ningún deles marcado.
      const ancho = 600.0;
      tester.view.physicalSize = const Size(ancho, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        contenido: contenido,
        repository: repositorio,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      final inicio = contenido.indiceParaFecha(DateTime.now());
      const saltos = 5;
      for (var i = 0; i < saltos; i++) {
        await tester.drag(
            find.byKey(const Key('paginas_meses')), const Offset(-500, 0));
        await tester.pumpAndSettle();
      }

      final destino =
          contenido.meses[(inicio + saltos) % contenido.meses.length];
      final pastilla = find.descendant(
        of: find.byType(ChoiceChip),
        matching: find.text(destino.nombreMes.gl),
      );
      expect(pastilla, findsOneWidget);

      final caixa = tester.getRect(pastilla);
      expect(caixa.left, greaterThanOrEqualTo(0.0),
          reason: '${destino.nombreMes.gl} quedou fóra pola esquerda');
      expect(caixa.right, lessThanOrEqualTo(ancho),
          reason: '${destino.nombreMes.gl} quedou fóra pola dereita');
    });

    testWidgets('cada mes leva á SÚA unidade, non todos á mesma',
        (tester) async {
      // O defecto orixinal: `unidades.first` como rede de seguridade facía que
      // os dez meses abrisen a asemblea do Mar de Vigo. Dez ids distintos é a
      // proba de que iso xa non pode pasar.
      final ids = contenido.meses.map((m) => m.unidadId).toSet();
      expect(ids.length, contenido.meses.length,
          reason: 'hai meses compartindo unidade: $ids');
    });

    testWidgets('un mes sen unidade escrita non abre nada, e dío',
        (tester) async {
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Hoxe todos os meses teñen unidade, así que este caso hai que fabricalo:
      // a rama segue viva e ten que seguir dicindo «en preparación» en vez de
      // caer noutra unidade calquera, que é o que facía antes.
      final senUnidade = CalendarioContenido(
        meses: contenido.meses
            .map((m) => MesCurricular(
                  orden: m.orden,
                  mesCalendario: m.mesCalendario,
                  icono: m.icono,
                  nombreMes: m.nombreMes,
                  centroInteres: m.centroInteres,
                  objetivoPedagogico: m.objetivoPedagogico,
                  actividadAula: m.actividadAula,
                  actividadHogar: m.actividadHogar,
                  rutinaRecomendadaHogar: m.rutinaRecomendadaHogar,
                  minutosSugeridos: m.minutosSugeridos,
                  ingles: m.ingles,
                  unidadId: null,
                ))
            .toList(),
        guia: contenido.guia,
      );

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        contenido: senUnidade,
        repository: repositorio,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('boton_iniciar_sesion_aula')), findsNothing);
      expect(find.byKey(const Key('aviso_mes_en_preparacion')), findsOneWidget);
    });

    testWidgets('o mes que si ten unidade lanza esa unidade, non outra',
        (tester) async {
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      MesCurricular? sesionRecibida;
      bool? esDocenteRecibido;

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        contenido: contenido,
        repository: repositorio,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
        onIniciarSesion: (mes, esDocente) {
          sesionRecibida = mes;
          esDocenteRecibido = esDocente;
        },
      )));
      await tester.pumpAndSettle();

      // O mes que a pantalla abre soa, que é o de hoxe: se lanzase outro, o
      // que a docente ten diante e o que se abre non coincidirían.
      final mesConUnidade = contenido.mesParaFecha(DateTime.now());

      // Xuño é o décimo: a fila de meses é horizontal e ese chip nin sequera
      // está construído ata que se empuxa cara alá.
      await tester.dragUntilVisible(
        find.descendant(
          of: find.byKey(const Key('selector_meses')),
          matching: find.text(mesConUnidade.nombreMes.gl),
        ),
        find.byKey(const Key('selector_meses')),
        const Offset(-220, 0),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.descendant(
        of: find.byKey(const Key('selector_meses')),
        matching: find.text(mesConUnidade.nombreMes.gl),
      ));
      await tester.pumpAndSettle();

      final botonLanzar = find.byKey(const Key('boton_iniciar_sesion_aula'));
      expect(botonLanzar, findsOneWidget);
      await tester.ensureVisible(botonLanzar);
      await tester.pumpAndSettle();
      await tester.tap(botonLanzar);
      await tester.pumpAndSettle();

      expect(esDocenteRecibido, isTrue);
      expect(sesionRecibida?.unidadId, mesConUnidade.unidadId);
    });

    testWidgets(
        'o lado da familia ensina a rutina do mes, non un botón que abre outra cousa',
        (tester) async {
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        contenido: contenido,
        repository: repositorio,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: false,
      )));
      await tester.pumpAndSettle();

      // Antes había aquí un botón que abría unha cápsula elixida por descarte
      // —sempre a mesma, sen relación co mes—. Agora o que hai é a rutina
      // dese mes, que si existe para os dez.
      expect(find.byKey(const Key('boton_iniciar_sesion_fogar')), findsNothing);

      // O que ten diante é a rutina DESE mes, coa súa frase en inglés.
      final hoxe = contenido.mesParaFecha(DateTime.now());
      await expectAfterScrolling(
        tester,
        find.textContaining(hoxe.actividadHogar.gl),
        matcher: findsWidgets,
      );
      await expectAfterScrolling(
        tester,
        find.text(hoxe.ingles.frase),
        matcher: findsWidgets,
      );
    });

    testWidgets(
        'conmutador dual de roles e temporizador sutil actualizan a interface de inmediato',
        (tester) async {
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        contenido: contenido,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      // En modo Aula: vese o temporizador sutil da asemblea e as instrucións breves
      expect(find.textContaining('ACTIVIDADE NA AULA'), findsOneWidget);
      expect(
          find.textContaining('Temporizador sutil: 5-8 min'), findsOneWidget);
      expect(find.textContaining('Instrucións breves para a asemblea:'),
          findsOneWidget);
      expect(find.textContaining('MICRO-RUTINA NO FOGAR'), findsNothing);

      // Conmutar a Fogar (Familias)
      final tabFogar = find.byKey(const Key('tab_rol_familia'));
      expect(tabFogar, findsOneWidget);
      await tester.tap(tabFogar);
      await tester.pumpAndSettle();

      // En modo Fogar: vese a micro-rutina, o temporizador sutil de fogar e a ligazón á guía
      expect(find.textContaining('MICRO-RUTINA NO FOGAR'), findsOneWidget);
      expect(find.textContaining('ACTIVIDADE NA AULA'), findsNothing);
      final mesDeHoxe = contenido.mesParaFecha(DateTime.now());
      final esperado = mesDeHoxe.minutosSugeridos == 3
          ? 'Temporizador sutil: 3 min'
          : 'Temporizador sutil: 3-${mesDeHoxe.minutosSugeridos} min';
      expect(find.textContaining(esperado), findsOneWidget);
      expect(find.byKey(const Key('boton_guia_atencion')), findsOneWidget);
      expect(find.text('Ver a guía de inglés na casa'), findsOneWidget);

      // Conmutar de volta a Aula (Docentes)
      final tabAula = find.byKey(const Key('tab_rol_docente'));
      expect(tabAula, findsOneWidget);
      await tester.tap(tabAula);
      await tester.pumpAndSettle();

      expect(find.textContaining('ACTIVIDADE NA AULA'), findsOneWidget);
      expect(
          find.textContaining('Temporizador sutil: 5-8 min'), findsOneWidget);
    });

    testWidgets(
        'o cartel de hoxe reacciona ao rexistrar, e só fala do lado propio',
        (tester) async {
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        contenido: contenido,
        repository: repositorio,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      // Nada rexistrado: a conta propia, e NUNCA unha promesa sobre o outro
      // lado. A app non ten rede: este aparato non sabe o que pasou na casa.
      await expectAfterScrolling(
        tester,
        find.textContaining('Asembleas rexistradas: 0'),
      );
      expect(find.textContaining('Dobre Estimulación'), findsNothing);

      final botonAula = find.byKey(const Key('boton_rexistrar_aula'));
      expect(botonAula, findsOneWidget);
      await tester.ensureVisible(botonAula);
      await tester.pumpAndSettle();
      await tester.tap(botonAula);
      await tester.pumpAndSettle();

      // Primeiro o feito: quedou rexistrado.
      expect(store.totalSesionesAula, 1);

      // E o cartel cambia sen saír da pantalla, dicindo o que esta docente ten
      // que facer agora: darlle a nota ás familias.
      await expectAfterScrolling(
        tester,
        find.textContaining('Lembra darlles a nota'),
      );

      // E o lado da familia segue a cero neste aparato: rexistrar no aula non
      // marca ningunha casa.
      expect(store.totalSesionesHogar, 0);
    });

    testWidgets(
        'cambio de chip de mes actualiza o detalle curricular e a sesión recomendada',
        (tester) async {
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        contenido: contenido,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      // Outubro sale dos veces: en su tarjeta del carrusel y en la pastilla
      // del selector. Se pulsa la primera —la tarjeta— que es lo que hace
      // cualquiera al ver el carrusel; antes el finder cogía las dos y el
      // test moría con «Bad state: Too many elements».
      final tarxetaOutubro = find.text('Outubro').first;
      expect(tarxetaOutubro, findsOneWidget);
      await tester.ensureVisible(tarxetaOutubro);
      await tester.pumpAndSettle();
      await tester.tap(tarxetaOutubro);
      await tester.pumpAndSettle();

      // El centro de interés de octubre aparece en la ficha del mes.
      await expectAfterScrolling(
        tester,
        find.textContaining('O meu pequeno corpo en movemento'),
        matcher: findsWidgets,
      );
    });

    testWidgets(
        'alternancia de idioma (gl/es) actualiza todos os textos sen fallos',
        (tester) async {
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        contenido: contenido,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Calendario Escola · Fogar'), findsOneWidget);

      // Cambiar idioma a castelán
      final botonEs = find.text('ES');
      if (botonEs.evaluate().isNotEmpty) {
        await tester.tap(botonEs);
        await tester.pumpAndSettle();

        expect(find.text('Calendario Escuela · Hogar'), findsOneWidget);
        expect(find.text('Hogar (Familias)'), findsOneWidget);
        expect(
            find.textContaining('Temporizador sutil: 5-8 min'), findsOneWidget);
      }
    });
  });

  group('GuiaAtencionScreen UI Widget Tests', () {
    testWidgets('mostra os tramos de idade e as tres regras da casa',
        (tester) async {
      await tester.pumpWidget(_wrap(GuiaAtencionScreen(
        initialLanguage: AppLanguage.gl,
        contenido: contenido,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Guía de inglés na casa'), findsOneWidget);
      // Cada tramo sale dos veces cuando está elegido —en su pastilla y en la
      // cabecera de la ficha—, así que se comprueba que está, no cuántas.
      expect(find.text('0 a 6 meses'), findsWidgets);
      expect(find.text('6 a 12 meses'), findsOneWidget);
      expect(find.text('12 a 18 meses'), findsOneWidget);
      expect(find.text('18 a 24 meses'), findsOneWidget);
      expect(find.text('24 a 36 meses'), findsOneWidget);

      // Las tres reglas de la casa, ya sin titularse como neurociencia.
      expect(find.text('1. Unha lingua, unha rutina'), findsOneWidget);
      expect(
          find.text('2. Entender vén moito antes que falar'), findsOneWidget);
      expect(
          find.text('3. A app é para ti, non para a crianza'), findsOneWidget);

      // Cambiar de tramo a 24-36 meses
      await tester.tap(find.text('24 a 36 meses'));
      await tester.pumpAndSettle();

      // Sugerencia de juego, no un umbral del desarrollo.
      expect(find.text('Xogo suxerido: arredor de 8 min'), findsOneWidget);
    });
  });

  group('Privacidad: lo que el calendario guarda, y nada más', () {
    late Directory tempDir;
    late CalendarioStore store;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('cal_priv_');
      store = CalendarioStore(overrideDirectory: tempDir.path);
      await store.cargar();
    });

    tearDown(() async {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('el fichero solo tiene fechas sin hora y dos casillas', () async {
      await store.registrarAula(DateTime(2026, 10, 15, 9, 30));
      await store.registrarHogar(DateTime(2026, 10, 15, 20, 45));

      final crudo =
          File('${tempDir.path}/calendario_progreso.json').readAsStringSync();

      // Si aparece una clave nueva, este test para el cambio: añadir un campo
      // obliga a actualizar docs/privacy.html y el formulario de Seguridad de
      // los datos de Play Console EN EL MISMO CAMBIO. Lo declarado y lo
      // compilado no pueden decir cosas distintas.
      const permitidas = {'registros', 'aula', 'hogar'};
      final fecha = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      final claves = RegExp(r'"([^"]+)"\s*:')
          .allMatches(crudo)
          .map((m) => m.group(1)!)
          .where((k) => !fecha.hasMatch(k))
          .toSet();

      expect(claves.difference(permitidas), isEmpty,
          reason: 'Apareció una clave nueva en calendario_progreso.json.');

      // La hora diría a qué hora trabaja una persona concreta, y para enlazar
      // aula y casa basta con el día.
      expect(crudo, isNot(contains('09:30')));
      expect(crudo, isNot(contains('T20:45')));
      expect(crudo, contains('2026-10-15'));
    });

    test('el estado de un mes es lo mejor que se logró en él', () async {
      // La tarjeta del carrusel enseña el estado del MES. Antes preguntaba por
      // el día 15 y un mes con media docena de días trabajados salía como «sen
      // rexistro» si el 15 estaba en blanco.
      expect(store.estadoParaMes(2026, 10), EstadoEstimulacion.sinRegistro);

      await store.registrarAula(DateTime(2026, 10, 3));
      expect(store.estadoParaMes(2026, 10), EstadoEstimulacion.soloAula);

      await store.registrarHogar(DateTime(2026, 10, 20));
      expect(store.estadoParaMes(2026, 10), EstadoEstimulacion.soloAula,
          reason: 'Aula un día y casa otro no es doble estimulación.');

      await store.registrarHogar(DateTime(2026, 10, 3));
      expect(
          store.estadoParaMes(2026, 10), EstadoEstimulacion.dobleEstimulacion);

      // Un mes vecino no se contagia.
      expect(store.estadoParaMes(2026, 11), EstadoEstimulacion.sinRegistro);
      expect(store.estadoParaMes(2025, 10), EstadoEstimulacion.sinRegistro);
    });

    test('dos registros el mismo día son un día, no dos', () async {
      await store.registrarAula(DateTime(2026, 10, 15, 9, 0));
      await store.registrarAula(DateTime(2026, 10, 15, 12, 0));
      expect(store.totalSesionesAula, 1);
    });
  });

  group('Medallas del calendario', () {
    late CatalogoPremios catalogo;

    setUpAll(() async {
      final crudo =
          await File('assets/content/premios/premios.json').readAsString();
      catalogo =
          CatalogoPremios.fromJson(json.decode(crudo) as Map<String, dynamic>);
    });

    test('el catálogo sale del JSON, no de un enum escrito a mano', () {
      expect(catalogo.medallas, isNotEmpty);
      for (final m in catalogo.medallas) {
        expect(m.titulo.hasParity, isTrue);
        expect(m.descripcion.hasParity, isTrue);
        expect(m.valor, greaterThan(0));
      }
    });

    test('cada medalla se gana con lo que el calendario mide de verdad', () {
      // Tres cuentas, y solo tres. Si alguna medalla dependiera de algo que la
      // app no mide —«toda la clase», por ejemplo— no habría forma de
      // calcularla aquí, y este test no compilaría.
      const nada = ContadoresCalendario();
      const mucho = ContadoresCalendario(
        diasAula: 99,
        diasFogar: 99,
        diasDobres: 99,
      );

      for (final m in catalogo.medallas) {
        expect(m.ganadaCon(nada), isFalse,
            reason: '${m.id} se gana sin haber hecho nada.');
        expect(m.ganadaCon(mucho), isTrue,
            reason: '${m.id} no se gana ni con el curso entero hecho.');
      }
    });

    test('el avance se lee de la cuenta que corresponde', () {
      const c = ContadoresCalendario(
        diasAula: 3,
        diasFogar: 7,
        diasDobres: 2,
      );
      for (final m in catalogo.medallas) {
        final esperado = switch (m.criterio) {
          CriterioCalendario.aula => 3,
          CriterioCalendario.fogar => 7,
          CriterioCalendario.dobre => 2,
        };
        expect(m.avanceCon(c), esperado);
      }
    });

    test('cada perfil ve sus medallas, y las de ambos las ven los dos', () {
      final docente = catalogo.medallasDe(Perfil.docente);
      final familia = catalogo.medallasDe(Perfil.familia);
      expect(docente, isNotEmpty);
      expect(familia, isNotEmpty);
      for (final m in catalogo.medallas.where((m) => m.perfil == null)) {
        expect(docente, contains(m));
        expect(familia, contains(m));
      }
    });
  });
}
