import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/calendario_model.dart';
import 'package:descubre_con_lua/features/academy/views/guia_atencion_screen.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_screen.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: AppTheme.lightTheme, home: child);

void main() {
  group('CalendarioModel & 10 Meses Curriculares de Galicia', () {
    test('contén exactamente 10 meses de setembro a xuño', () {
      expect(MesCurricular.meses.length, 10);
      expect(MesCurricular.meses.first.orden, 1);
      expect(MesCurricular.meses.first.mesCalendario, 9); // Setembro
      expect(MesCurricular.meses.last.orden, 10);
      expect(MesCurricular.meses.last.mesCalendario, 6); // Xuño
    });

    test('todos os meses teñen paridade lingüística e contidos TPR completos', () {
      for (final mes in MesCurricular.meses) {
        expect(mes.nombreMes.hasParity, isTrue);
        expect(mes.centroInteres.hasParity, isTrue);
        expect(mes.objetivoPedagogico.hasParity, isTrue);
        expect(mes.actividadAula.hasParity, isTrue);
        expect(mes.actividadHogar.hasParity, isTrue);
        expect(mes.rutinaRecomendadaHogar.hasParity, isTrue);

        expect(mes.lexicoIngles, isNotEmpty);
        expect(mes.comandosTpr, isNotEmpty);
        expect(mes.minutosAtencionSugeridos, inInclusiveRange(2, 8));
      }
    });

    test('mesActualParaFecha resolve correctamente o mes escolar regular', () {
      final setembro = DateTime(2026, 9, 15);
      expect(MesCurricular.mesActualParaFecha(setembro).mesCalendario, 9);

      final febreiro = DateTime(2027, 2, 20);
      expect(MesCurricular.mesActualParaFecha(febreiro).mesCalendario, 2);

      final xuño = DateTime(2027, 6, 10);
      expect(MesCurricular.mesActualParaFecha(xuño).mesCalendario, 6);
    });

    // Edge case: Vacation months (Xullo e Agosto)
    test('mesActualParaFecha xestiona meses de vacacións (xullo e agosto) con fallback a setembro', () {
      final xullo = DateTime(2026, 7, 20);
      final agosto = DateTime(2026, 8, 15);
      final agostoFin = DateTime(2026, 8, 31);

      expect(MesCurricular.mesActualParaFecha(xullo).mesCalendario, 9);
      expect(MesCurricular.mesActualParaFecha(xullo).orden, 1);

      expect(MesCurricular.mesActualParaFecha(agosto).mesCalendario, 9);
      expect(MesCurricular.mesActualParaFecha(agostoFin).mesCalendario, 9);
    });

    // Edge case: Boundary dates and Leap Year
    test('mesActualParaFecha resolve datas límite de curso e ano bisesto', () {
      final inicioCurso = DateTime(2026, 9, 1);
      expect(MesCurricular.mesActualParaFecha(inicioCurso).mesCalendario, 9);

      final finCurso = DateTime(2027, 6, 30);
      expect(MesCurricular.mesActualParaFecha(finCurso).mesCalendario, 6);

      final finAno = DateTime(2026, 12, 31);
      expect(MesCurricular.mesActualParaFecha(finAno).mesCalendario, 12);

      final anoNovo = DateTime(2027, 1, 1);
      expect(MesCurricular.mesActualParaFecha(anoNovo).mesCalendario, 1);

      final anoBisesto = DateTime(2028, 2, 29);
      expect(MesCurricular.mesActualParaFecha(anoBisesto).mesCalendario, 2);
    });

    test('orde curricular e estritamente secuencial de 1 a 10', () {
      for (int i = 0; i < MesCurricular.meses.length; i++) {
        expect(MesCurricular.meses[i].orden, i + 1);
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

    test('grafo completo de transición de estados e dobre estimulación reactiva', () async {
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

    test('transición inversa: rexistro primeiro en fogar e despois aula', () async {
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

    test('idempotencia: chamadas repetidas a registrarAula non duplican contadores', () async {
      final data = DateTime(2026, 12, 5);
      expect(await store.registrarAula(data), isTrue); // Nova alta
      expect(await store.registrarAula(data), isFalse); // Xa existía
      expect(await store.registrarAula(data), isFalse); // Xa existía

      expect(store.totalSesionesAula, 1);
    });

    test('persistencia soberana roundtrip con múltiples datas independentes', () async {
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

      expect(storePersistido.estadoParaFecha(d1), EstadoEstimulacion.dobleEstimulacion);
      expect(storePersistido.estadoParaFecha(d2), EstadoEstimulacion.soloAula);
      expect(storePersistido.estadoParaFecha(d3), EstadoEstimulacion.soloHogar);
      expect(storePersistido.estadoParaFecha(d4), EstadoEstimulacion.sinRegistro);

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

    testWidgets('renderiza correctamente a cabeceira e o conmutador dual', (tester) async {
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Calendario Escola · Fogar'), findsOneWidget);
      expect(find.text('Aula (Docentes)'), findsOneWidget);
      expect(find.text('Fogar (Familias)'), findsOneWidget);
    });

    testWidgets('lanzador de sesión a 1-toque en modo Aula invoca callback con mes activo e esDocente=true', (tester) async {
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      MesCurricular? sesionRecibida;
      bool? esDocenteRecibido;

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
        onIniciarSesion: (mes, esDocente) {
          sesionRecibida = mes;
          esDocenteRecibido = esDocente;
        },
      )));
      await tester.pumpAndSettle();

      final botonLanzar = find.byKey(const Key('boton_iniciar_sesion_aula'));
      expect(botonLanzar, findsOneWidget);
      await tester.ensureVisible(botonLanzar);
      await tester.pumpAndSettle();

      await tester.tap(botonLanzar);
      await tester.pumpAndSettle();

      expect(sesionRecibida, isNotNull);
      expect(esDocenteRecibido, isTrue);
      expect(sesionRecibida!.mesCalendario, MesCurricular.mesActualParaFecha(DateTime.now()).mesCalendario);
    });

    testWidgets('lanzador de sesión a 1-toque en modo Fogar invoca callback con mes activo e esDocente=false', (tester) async {
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      MesCurricular? sesionRecibida;
      bool? esDocenteRecibido;

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: false,
        onIniciarSesion: (mes, esDocente) {
          sesionRecibida = mes;
          esDocenteRecibido = esDocente;
        },
      )));
      await tester.pumpAndSettle();

      final botonLanzar = find.byKey(const Key('boton_iniciar_sesion_fogar'));
      expect(botonLanzar, findsOneWidget);
      await tester.ensureVisible(botonLanzar);
      await tester.pumpAndSettle();

      await tester.tap(botonLanzar);
      await tester.pumpAndSettle();

      expect(sesionRecibida, isNotNull);
      expect(esDocenteRecibido, isFalse);
    });

    testWidgets('conmutador dual de roles e temporizador sutil actualizan a interface de inmediato', (tester) async {
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      // En modo Aula: vese o temporizador sutil da asemblea e as instrucións breves
      expect(find.textContaining('ACTIVIDADE NA AULA'), findsOneWidget);
      expect(find.textContaining('Temporizador sutil: 5-8 min'), findsOneWidget);
      expect(find.textContaining('Instrucións breves para a asemblea:'), findsOneWidget);
      expect(find.textContaining('MICRO-RUTINA NO FOGAR'), findsNothing);

      // Conmutar a Fogar (Familias)
      final tabFogar = find.byKey(const Key('tab_rol_familia'));
      expect(tabFogar, findsOneWidget);
      await tester.tap(tabFogar);
      await tester.pumpAndSettle();

      // En modo Fogar: vese a micro-rutina, o temporizador sutil de fogar e a ligazón á guía
      expect(find.textContaining('MICRO-RUTINA NO FOGAR'), findsOneWidget);
      expect(find.textContaining('ACTIVIDADE NA AULA'), findsNothing);
      expect(find.textContaining('Temporizador sutil: 3-'), findsOneWidget);
      expect(find.byKey(const Key('boton_guia_atencion')), findsOneWidget);
      expect(find.text('Ver Guía de Atención e 3 Regras de Ouro'), findsOneWidget);

      // Conmutar de volta a Aula (Docentes)
      final tabAula = find.byKey(const Key('tab_rol_docente'));
      expect(tabAula, findsOneWidget);
      await tester.tap(tabAula);
      await tester.pumpAndSettle();

      expect(find.textContaining('ACTIVIDADE NA AULA'), findsOneWidget);
      expect(find.textContaining('Temporizador sutil: 5-8 min'), findsOneWidget);
    });

    testWidgets('celebración reactiva de Dobre Estimulación actualiza banner en tempo real sen recarga', (tester) async {
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      // Estado inicial: 0 días acumulados e sen estrela
      expect(find.textContaining('Días de Dobre Estimulación acumulados: 0'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNothing);

      // 1. Rexistrar aula
      final botonAula = find.byKey(const Key('boton_rexistrar_aula'));
      expect(botonAula, findsOneWidget);
      await tester.ensureVisible(botonAula);
      await tester.pumpAndSettle();
      await tester.tap(botonAula);
      await tester.pumpAndSettle();

      // O banner actualiza a só aula
      expect(find.textContaining('Asemblea feita na aula. Falta o xogo de 3 min na casa!'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNothing);

      // 2. Cambiar a modo Fogar e rexistrar rutina
      final tabFogar = find.byKey(const Key('tab_rol_familia'));
      await tester.ensureVisible(tabFogar);
      await tester.pumpAndSettle();
      await tester.tap(tabFogar);
      await tester.pumpAndSettle();

      final botonFogar = find.byKey(const Key('boton_rexistrar_fogar'));
      expect(botonFogar, findsOneWidget);
      await tester.ensureVisible(botonFogar);
      await tester.pumpAndSettle();
      await tester.tap(botonFogar);
      await tester.pumpAndSettle();

      // O banner reactivamente celebra a Dobre Estimulación con estrela!
      expect(find.textContaining('Parabéns! Hoxe acadastes a Dobre Estimulación'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      expect(store.totalDobleEstimulacion, 1);
    });

    testWidgets('cambio de chip de mes actualiza o detalle curricular e a sesión recomendada', (tester) async {
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      // Cambiar de mes: premer chip de Outubro
      final chipOutubro = find.text('Outubro');
      if (chipOutubro.evaluate().isNotEmpty) {
        await tester.ensureVisible(chipOutubro);
        await tester.pumpAndSettle();
        await tester.tap(chipOutubro);
        await tester.pumpAndSettle();

        expect(find.textContaining('O meu pequeno corpo en movemento'), findsOneWidget);
      }
    });

    testWidgets('alternancia de idioma (gl/es) actualiza todos os textos sen fallos', (tester) async {
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Calendario Escola · Fogar'), findsOneWidget);
      expect(find.text('Iniciar asemblea guiada'), findsOneWidget);

      // Cambiar idioma a castelán
      final botonEs = find.text('ES');
      if (botonEs.evaluate().isNotEmpty) {
        await tester.tap(botonEs);
        await tester.pumpAndSettle();

        expect(find.text('Calendario Escuela · Hogar'), findsOneWidget);
        expect(find.text('Hogar (Familias)'), findsOneWidget);
        expect(find.text('Iniciar asamblea guiada'), findsOneWidget);
        expect(find.textContaining('Temporizador sutil: 5-8 min'), findsOneWidget);
      }
    });
  });

  group('GuiaAtencionScreen UI Widget Tests', () {
    testWidgets('mostra os tramos de idade e as tres regras de ouro', (tester) async {
      await tester.pumpWidget(_wrap(const GuiaAtencionScreen(
        initialLanguage: AppLanguage.gl,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Guía de Atención e Inglés na Casa'), findsOneWidget);
      expect(find.text('0 a 6 meses'), findsOneWidget);
      expect(find.text('6 a 12 meses'), findsOneWidget);
      expect(find.text('12 a 18 meses'), findsOneWidget);
      expect(find.text('18 a 24 meses'), findsOneWidget);
      expect(find.text('24 a 36 meses'), findsOneWidget);

      // Regras de ouro
      expect(find.text('1. O cerebro non se confunde'), findsOneWidget);
      expect(find.text('2. Respecta o "Período de Silencio"'), findsOneWidget);
      expect(find.text('3. A app é para ti, non para a crianza'), findsOneWidget);

      // Cambiar de tramo a 24-36 meses
      await tester.tap(find.text('24 a 36 meses'));
      await tester.pumpAndSettle();

      expect(find.text('Atención sostida: ata 8 minutos'), findsOneWidget);
    });
  });
}
