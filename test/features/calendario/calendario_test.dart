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

    test('mesActualParaFecha resolve correctamente o mes escolar', () {
      final setembro = DateTime(2026, 9, 15);
      expect(MesCurricular.mesActualParaFecha(setembro).mesCalendario, 9);

      final febreiro = DateTime(2027, 2, 20);
      expect(MesCurricular.mesActualParaFecha(febreiro).mesCalendario, 2);

      final xuño = DateTime(2027, 6, 10);
      expect(MesCurricular.mesActualParaFecha(xuño).mesCalendario, 6);
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

    test('inicia baleiro e rexistra aula e fogar correctamente', () async {
      final hoxe = DateTime(2026, 10, 15);
      expect(store.estadoParaFecha(hoxe), EstadoEstimulacion.sinRegistro);
      expect(store.totalDobleEstimulacion, 0);

      // Rexistrar aula
      await store.registrarAula(hoxe);
      expect(store.estadoParaFecha(hoxe), EstadoEstimulacion.soloAula);
      expect(store.totalSesionesAula, 1);
      expect(store.totalDobleEstimulacion, 0);

      // Rexistrar fogar
      await store.registrarHogar(hoxe);
      expect(store.estadoParaFecha(hoxe), EstadoEstimulacion.dobleEstimulacion);
      expect(store.totalSesionesHogar, 1);
      expect(store.totalDobleEstimulacion, 1);

      // Persistencia: novo store na mesma carpeta le os datos
      final store2 = CalendarioStore(overrideDirectory: tempDir.path);
      await store2.cargar();
      expect(store2.estadoParaFecha(hoxe), EstadoEstimulacion.dobleEstimulacion);
      expect(store2.totalDobleEstimulacion, 1);
    });
  });

  group('CalendarioScreen UI Widget Tests', () {
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

    testWidgets('renderiza correctamente o calendario e permite rexistrar',
        (tester) async {
      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      // Cabecera e título
      expect(find.text('Calendario Escola · Fogar'), findsOneWidget);
      expect(find.text('Aula (Docentes)'), findsOneWidget);
      expect(find.text('Fogar (Familias)'), findsOneWidget);

      // Rexistro como docente
      final botonAula = find.text('Rexistrar asemblea de hoxe na aula');
      expect(botonAula, findsOneWidget);
      await tester.tap(botonAula);
      await tester.pumpAndSettle();

      expect(store.totalSesionesAula, 1);
    });
  });

  group('GuiaAtencionScreen UI Widget Tests', () {
    testWidgets('mostra os tramos de idade e as tres regras de ouro',
        (tester) async {
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
