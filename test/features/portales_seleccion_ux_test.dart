import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/brand/ilustracion_portal.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/dia_calendario_dual_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_fogar_screen.dart';
import 'package:descubre_con_lua/features/docentes/portal_docentes_screen.dart';
import 'package:descubre_con_lua/features/familias/portal_familias_screen.dart';
import 'package:descubre_con_lua/features/familias/views/xogos_fogar_screen.dart';
import 'package:descubre_con_lua/features/lectura/views/aprender_a_ler_screen.dart';
import 'package:descubre_con_lua/features/premios/premios_repository.dart';
import 'package:descubre_con_lua/features/seleccion/seleccion_portal_screen.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: AppTheme.lightTheme, home: child);

void main() {
  late ContentRepository repository;
  late MockOfflineAudioService audioService;
  late CalendarioStore calendarioStore;
  late PremiosRepository premiosRepository;

  setUp(() {
    repository = ContentRepository();
    audioService = MockOfflineAudioService();
    calendarioStore = CalendarioStore();
    premiosRepository = PremiosRepository();
  });

  group('Pantalla de Selección de Portal Dual (Familias e Docentes)', () {
    testWidgets('amosa dúas tarxetas destacadas con ilustracións propias debuxadas',
        (tester) async {
      await tester.pumpWidget(_wrap(
        SeleccionPortalScreen(
          repository: repository,
          audioService: audioService,
          currentLanguage: AppLanguage.gl,
          onToggleLanguage: () {},
          premios: premiosRepository,
          calendario: calendarioStore,
        ),
      ));
      await tester.pumpAndSettle();

      // Debe amosar as dúas tarxetas con debuxos propios
      expect(find.text('Portal Familias'), findsOneWidget);
      expect(find.text('Portal Docentes'), findsOneWidget);

      expect(find.byType(IlustracionFamilia), findsOneWidget);
      expect(find.byType(IlustracionEscola), findsOneWidget);

      // Botóns de entrada independente
      expect(find.text('Entrar no Portal Familias'), findsOneWidget);
      expect(find.text('Entrar no Portal Docentes'), findsOneWidget);
    });

    testWidgets('paridade bilingüe galego e castelán na selección de portal',
        (tester) async {
      // Probar en Castelán
      await tester.pumpWidget(_wrap(
        SeleccionPortalScreen(
          repository: repository,
          audioService: audioService,
          currentLanguage: AppLanguage.es,
          onToggleLanguage: () {},
          premios: premiosRepository,
          calendario: calendarioStore,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Entrar en el Portal Familias'), findsOneWidget);
      expect(find.text('Entrar en el Portal Docentes'), findsOneWidget);
      expect(find.textContaining('CERO PANTALLAS'), findsOneWidget);
    });

    testWidgets('navega á pantalla independente do Portal Familias',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: SeleccionPortalScreen(
          repository: repository,
          audioService: audioService,
          currentLanguage: AppLanguage.gl,
          onToggleLanguage: () {},
          premios: premiosRepository,
          calendario: calendarioStore,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Entrar no Portal Familias'));
      await tester.pumpAndSettle();

      expect(find.byType(PortalFamiliasScreen), findsOneWidget);
      expect(find.text('Benvida ao fogar de Lúa'), findsOneWidget);
      expect(find.text('CERO PANTALLAS INFANTÍS'), findsOneWidget);
    });

    testWidgets('navega á pantalla independente do Portal Docentes',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: SeleccionPortalScreen(
          repository: repository,
          audioService: audioService,
          currentLanguage: AppLanguage.gl,
          onToggleLanguage: () {},
          premios: premiosRepository,
          calendario: calendarioStore,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Entrar no Portal Docentes'));
      await tester.pumpAndSettle();

      expect(find.byType(PortalDocentesScreen), findsOneWidget);
      expect(find.text('Escolas infantís de Vigo'), findsOneWidget);
      expect(find.text('MODO AULA · DOCENTES'), findsOneWidget);
    });
  });

  group('Portal Familias Independente', () {
    testWidgets('amosa todos os módulos de estimulación familiar sen pantallas',
        (tester) async {
      await tester.pumpWidget(_wrap(
        PortalFamiliasScreen(
          repository: repository,
          audioService: audioService,
          currentLanguage: AppLanguage.gl,
          onToggleLanguage: () {},
          premios: premiosRepository,
          calendario: calendarioStore,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Calendario Escolar no Fogar'), findsOneWidget);
      expect(find.text('Biblioteca de Contos Dialóxicos'), findsOneWidget);
      expect(find.text('Aprender a Ler · Fónica Manipulativa'), findsOneWidget);
      expect(find.text('Banco de Láminas e Vocabulario'), findsOneWidget);
      expect(find.text('Xogos e Dinámicas Corporais (TPR)'), findsOneWidget);
      expect(find.text('Academy · Pautas de Crianza'), findsOneWidget);
    });
  });

  group('Calendario Escolar no Fogar (Diferenciado por curso, mes, semanas e días)', () {
    testWidgets('renderiza selector de cursos, meses e días lectivos',
        (tester) async {
      await tester.pumpWidget(_wrap(
        CalendarioFogarScreen(
          repository: repository,
          store: calendarioStore,
          initialLanguage: AppLanguage.gl,
          audioService: audioService,
        ),
      ));
      await tester.pumpAndSettle();

      // Cursos dispoñibles
      expect(find.text('0-2 anos (Nido)'), findsOneWidget);
      expect(find.text('2-3 anos (Maternal)'), findsOneWidget);
      expect(find.text('3-4 anos (4.º Infantil)'), findsOneWidget);

      // Meses e semanas
      expect(find.text('Setembro'), findsOneWidget);
      expect(find.text('Semana 1'), findsOneWidget);
      expect(find.text('LUN'), findsOneWidget);
    });
  });

  group('Aprender a Ler · Fónica Manipulativa (/tangible-l2-parent-orchestrator)', () {
    testWidgets('renderiza as 4 pestanas e permite interacción táctil',
        (tester) async {
      await tester.pumpWidget(_wrap(
        AprenderALerScreen(
          repository: repository,
          initialLanguage: AppLanguage.gl,
          audioService: audioService,
        ),
      ));
      await tester.pumpAndSettle();

      // Pestanas
      expect(find.text('1. Conciencia Fonolóxica'), findsOneWidget);
      expect(find.text('2. Mesa Alphabot'), findsOneWidget);
      expect(find.text('3. Cubos CVC'), findsOneWidget);
      expect(find.text('4. Pares Mínimos'), findsOneWidget);

      // Cambiar a Mesa Alphabot
      await tester.tap(find.text('2. Mesa Alphabot'));
      await tester.pumpAndSettle();

      expect(find.text('LÚA'), findsOneWidget);
      expect(find.text('Animais'), findsOneWidget);

      // Tocar unha letra para marcala como colocada na mesa física
      expect(find.text('L'), findsWidgets);
      await tester.tap(find.text('L').first);
      await tester.pumpAndSettle();

      // Rexistro 1-toque
      expect(find.text('[L] Logrado'), findsWidgets);
      await tester.tap(find.text('[L] Logrado').first);
      await tester.pumpAndSettle();
    });

    testWidgets('pestana de cubos CVC e pares mínimos', (tester) async {
      await tester.pumpWidget(_wrap(
        AprenderALerScreen(
          repository: repository,
          initialLanguage: AppLanguage.gl,
          audioService: audioService,
        ),
      ));
      await tester.pumpAndSettle();

      // Pestana Cubos CVC
      await tester.tap(find.text('3. Cubos CVC'));
      await tester.pumpAndSettle();

      expect(find.text('CAT · /kæt/'), findsOneWidget);

      // Pestana Pares Mínimos
      await tester.tap(find.text('4. Pares Mínimos'));
      await tester.pumpAndSettle();

      expect(find.text('/b/ vs /p/'), findsOneWidget);
      expect(find.text('Bear'), findsOneWidget);
      expect(find.text('Pig'), findsOneWidget);
    });
  });

  group('Xogos Físicos e Dinámicas no Fogar (Zero-Screen TPR)', () {
    testWidgets('renderiza o catálogo de xogos corporais e rexistro observacional',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const XogosFogarScreen(
          initialLanguage: AppLanguage.gl,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('A Caza do Tesouro dos Sons'), findsOneWidget);
      expect(find.text('O Barquiño de Samil na Ría'), findsOneWidget);
      expect(find.text('XOGO 100% CORPORAL E FÍSICO'), findsOneWidget);

      // Rexistro 1-toque
      expect(find.text('[L] Logrado'), findsWidgets);
      await tester.tap(find.text('[L] Logrado').first);
      await tester.pumpAndSettle();
    });
  });
}
