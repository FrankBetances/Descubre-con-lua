import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/audio/widgets/boton_escuchar.dart';
import 'package:descubre_con_lua/core/brand/ilustracion_portal.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/cuento_model.dart';
import 'package:descubre_con_lua/data/models/dia_calendario_dual_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_fogar_screen.dart';
import 'package:descubre_con_lua/features/cuentos/services/cuento_narrativa_engine.dart';
import 'package:descubre_con_lua/features/cuentos/views/cuento_viewer_screen.dart';
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

    // Rexistramos un día dual de proba para garantir renderizado completo do
    // calendario. Os campos son os REAIS de DiaCalendarioDual: o test anterior
    // inventaba `ContenidoProfesorado` e `ContenidoFamilia`, que non existen.
    repository.addCalendarioDia(const DiaCalendarioDual(
      dia: 1,
      diaSemana: 0,
      diaSemanaNumero: 1,
      nombreDiaSemana: LocalizedString(gl: 'Luns', es: 'Lunes'),
      semanaNumero: 1,
      semanaCursoNumero: 1,
      semanaGlobalNumero: 1,
      diaCursoNumero: 1,
      diaGlobalNumero: 1,
      mesNumero: 1,
      mesGlobalNumero: 1,
      fechaClave: 'curso_0_2-mes-1-dia-1',
      temaDia: LocalizedString(
        gl: 'Primeiro día con Lúa',
        es: 'Primer día con Lúa',
      ),
      profesorado: DiaProfesorado(
        actividadAula: LocalizedString(gl: 'Asamblea 1', es: 'Asamblea 1'),
        dinamica: LocalizedString(gl: 'Reto motor 1', es: 'Reto motor 1'),
        duracionMin: 12,
        tprIngles: 'Clap hands, touch ground!',
        consignaDocente: LocalizedString(
          gl: 'Agarda cinco segundos antes de intervir.',
          es: 'Espera cinco segundos antes de intervenir.',
        ),
      ),
      familias: DiaFamilias(
        rutinaFogar: LocalizedString(
          gl: 'Xogo suave con Lúa sen pantallas.',
          es: 'Juego suave con Lúa sin pantallas.',
        ),
        momento: LocalizedString(gl: 'Antes de durmir', es: 'Antes de dormir'),
        consignaFamilia: LocalizedString(
          gl: 'Pausa de 5 segundos antes de intervir.',
          es: 'Pausa de 5 segundos antes de intervenir.',
        ),
        fraseConexion: LocalizedString(
          gl: 'Hoxe na escola xogamos coas mans.',
          es: 'Hoy en la escuela jugamos con las manos.',
        ),
      ),
    ));
  });

  group('Pantalla de Selección de Portal Dual (Familias e Docentes)', () {
    testWidgets(
        'amosa dúas tarxetas destacadas con ilustracións propias debuxadas',
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

  group('Portal Familias Independente (Filtros, Chips e Selección)', () {
    testWidgets(
        'amosa módulos de estimulación familiar e permite filtrar por área e idade',
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

      // Módulos visibles por defecto
      expect(find.text('Calendario Escolar no Fogar'), findsOneWidget);
      expect(find.text('Biblioteca de Contos Dialóxicos'), findsOneWidget);
      expect(find.text('Aprender a Ler · Fónica Manipulativa'), findsOneWidget);
      expect(find.text('Banco de Láminas e Vocabulario'), findsOneWidget);
      expect(find.text('Xogos e Dinámicas Corporais (TPR)'), findsOneWidget);
      expect(find.text('Academy · Pautas de Crianza'), findsOneWidget);

      // Chips de idades dispoñibles
      expect(find.text('Todas as idades'), findsOneWidget);
      expect(find.text('0-2 anos (Nido)'), findsOneWidget);
      expect(find.text('2-3 anos (Maternal)'), findsOneWidget);

      // Filtrar por categoría 'Xogos Físicos (TPR)'
      await tester.tap(find.text('Xogos Físicos (TPR)'));
      await tester.pumpAndSettle();

      expect(find.text('Xogos e Dinámicas Corporais (TPR)'), findsOneWidget);
      expect(find.text('Biblioteca de Contos Dialóxicos'), findsNothing);

      // Volver a Todas as Áreas
      await tester.tap(find.text('Todas as Áreas'));
      await tester.pumpAndSettle();

      expect(find.text('Biblioteca de Contos Dialóxicos'), findsOneWidget);
    });
  });

  group('Portal Docentes Independente', () {
    testWidgets(
        'amosa recursos de aula municipal a 72 bpm e planificador curricular',
        (tester) async {
      await tester.pumpWidget(_wrap(
        PortalDocentesScreen(
          repository: repository,
          audioService: audioService,
          currentLanguage: AppLanguage.gl,
          onToggleLanguage: () {},
          premios: premiosRepository,
          calendario: calendarioStore,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Juega con Lúa · Modo Aula'), findsOneWidget);
      expect(find.text('Planificador Curricular (50 Meses)'), findsOneWidget);
      expect(find.text('Inmersión en Inglés · L3'), findsOneWidget);
      expect(find.text('Estratexias Pedagóxicas de Aula'), findsOneWidget);
      expect(find.text('Dinámicas de Aula Activa'), findsOneWidget);
      expect(find.text('Corpus 8.000 Palabras (BNC/COCA)'), findsOneWidget);
    });
  });

  group('Calendario Escolar no Fogar (Reixa de 20 días e 1-Tap Logging)', () {
    testWidgets(
        'renderiza reixa escolar de 20 días e permite alternar vista e marcar hoxe',
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
      expect(find.text('Setembro'), findsOneWidget);

      // Reixa de 20 días lectivos
      expect(find.text('REIXA ESCOLAR · 20 DÍAS LECTIVOS'), findsOneWidget);
      expect(find.text('Primeiro día con Lúa'), findsOneWidget);
      expect(find.text('Clap hands, touch ground!'), findsOneWidget);

      // Botón 1-tap para marcar como feito hoxe
      expect(find.text('Marcar como Feito Hoxe'), findsOneWidget);
      await tester.tap(find.text('Marcar como Feito Hoxe'));
      await tester.pumpAndSettle();

      expect(find.text('Xogo Feito Hoxe no Fogar'), findsOneWidget);

      // Alternar a vista de calendario para ver selector de semanas
      await tester.tap(find.byIcon(Icons.calendar_view_month_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Semana 1'), findsOneWidget);
    });
  });

  group('Aprender a Ler · Fónica Manipulativa con Botóns de Audio', () {
    testWidgets('renderiza as 4 pestanas con botóns de reprodución de son',
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

      // Tab 2: Mesa Alphabot
      await tester.tap(find.text('2. Mesa Alphabot'));
      await tester.pumpAndSettle();

      expect(find.text('LÚA'), findsOneWidget);
      expect(find.byType(BotonEscuchar), findsWidgets);

      // Tocar unha letra para marcar colocada na mesa física
      expect(find.text('L'), findsWidgets);
      await tester.tap(find.text('L').first);
      await tester.pumpAndSettle();

      // Tab 3: Cubos CVC
      await tester.tap(find.text('3. Cubos CVC'));
      await tester.pumpAndSettle();

      expect(find.text('CAT · /kæt/'), findsOneWidget);
      expect(find.byType(BotonEscuchar), findsWidgets);

      // Tab 4: Pares Mínimos
      await tester.tap(find.text('4. Pares Mínimos'));
      await tester.pumpAndSettle();

      expect(find.text('/b/ vs /p/'), findsOneWidget);
      expect(find.text('Bear'), findsOneWidget);
      expect(find.text('Pig'), findsOneWidget);
      expect(find.byType(BotonEscuchar), findsWidgets);
    });
  });

  group('CuentoNarrativaEngine e Visor de Contos Dialóxicos', () {
    test(
        'preserva contos xenuínos artesanais sen mutilalos nin engadir fórmulas',
        () {
      const genuineText =
          'Hoxe Lúa vai á praia de Samil. O sol de Vigo brilla dourado no ceo. Ao lonxe vense as Illas Cíes e un barquiño de madeira que baila amodo sobre a auga azul.';

      const cuento = Cuento(
        id: 'conto_mar_test',
        cursoId: 'curso_0_2',
        mesNumero: 10,
        semanaSugerida: 1,
        titulo: LocalizedString(gl: 'Lúa en Samil', es: 'Lúa en Samil'),
        sinopse: LocalizedString(gl: 'Un día no mar.', es: 'Un día en el mar.'),
        nivelLectura: 1,
        licenza: 'CC BY',
        orixeOpenSource: 'Vigo',
        tempoEsperaSegundos: 5,
        tprOral: CuentoTprOral(
          fraseEn: 'Row the boat!',
          comandoGl: 'Remar',
          comandoEs: 'Remar',
        ),
        paginas: [
          CuentoPagina(
            numero: 1,
            lamina: 'conto_mar_1',
            texto: LocalizedString(gl: genuineText, es: genuineText),
            vocabularioClave: ['Mar', 'Sol'],
          ),
        ],
        preguntasGraduadas: [],
      );

      final resultado = CuentoNarrativaEngine.obterTextoNarrativoRico(
        cuento,
        cuento.paginas.first,
        AppLanguage.gl,
      );

      // Debe devolver exactamente o texto xenuíno sen engadidos
      expect(resultado, equals(genuineText));
    });

    test('enriquece contos con fórmulas modelo con narrativa rica en 3 escenas',
        () {
      const templateText =
          'Lúa atopa unha cuncha branca na beira de Samil. Na escola infantil e no fogar, abrimos os ollos e respiramos con calma o pulso da mañá.';

      const cuento = Cuento(
        id: 'conto_cuncha_test',
        cursoId: 'curso_0_2',
        mesNumero: 1,
        semanaSugerida: 1,
        mesNome: LocalizedString(gl: 'Setembro', es: 'Septiembre'),
        centroInteres: LocalizedString(gl: 'Acollemento', es: 'Acogida'),
        titulo: LocalizedString(gl: 'A Cuncha Branca', es: 'La Concha Blanca'),
        sinopse: LocalizedString(
          gl: 'Lúa escoita o murmurio do mar nunha cuncha.',
          es: 'Lúa escucha el murmullo del mar en una concha.',
        ),
        nivelLectura: 1,
        licenza: 'CC BY',
        orixeOpenSource: 'Vigo',
        tempoEsperaSegundos: 5,
        tprOral: CuentoTprOral(
          fraseEn: 'Giant waves, row your boat!',
          comandoGl: 'Remar',
          comandoEs: 'Remar',
        ),
        paginas: [
          CuentoPagina(
            numero: 1,
            lamina: 'conto_mar_1',
            texto: LocalizedString(gl: templateText, es: templateText),
            vocabularioClave: ['Cuncha', 'Mar'],
          ),
        ],
        preguntasGraduadas: [],
      );

      final resultado = CuentoNarrativaEngine.obterTextoNarrativoRico(
        cuento,
        cuento.paginas.first,
        AppLanguage.gl,
      );

      // Debe conter a frase principal limpa, a ambientación de Vigo e o diálogo de Lúa
      expect(resultado,
          contains('Lúa atopa unha cuncha branca na beira de Samil'));
      expect(resultado, contains('Vigo'));
      expect(resultado, contains('Miau! Que cousas tan fermosas'));
      // Non debe conter a fórmula modelo repetitiva
      expect(resultado, isNot(contains('abrimos os ollos e respiramos')));
    });

    testWidgets(
        'CuentoViewerScreen renderiza narrativa rica e botón de son TPR',
        (tester) async {
      const cuento = Cuento(
        id: 'conto_viewer_test',
        cursoId: 'curso_0_2',
        mesNumero: 1,
        semanaSugerida: 1,
        mesNome: LocalizedString(gl: 'Setembro', es: 'Septiembre'),
        centroInteres: LocalizedString(gl: 'Acollemento', es: 'Acogida'),
        titulo: LocalizedString(gl: 'A Cuncha de Lúa', es: 'La Concha de Lúa'),
        sinopse: LocalizedString(
          gl: 'Un conto acolledor na ría de Vigo.',
          es: 'Un cuento acogedor en la ría de Vigo.',
        ),
        nivelLectura: 1,
        licenza: 'CC BY',
        orixeOpenSource: 'Vigo',
        tempoEsperaSegundos: 5,
        tprOral: CuentoTprOral(
          fraseEn: 'Giant waves, row your boat!',
          comandoGl: 'Remar',
          comandoEs: 'Remar',
        ),
        paginas: [
          CuentoPagina(
            numero: 1,
            lamina: 'conto_mar_1',
            texto: LocalizedString(
              gl: 'Hoxe Lúa vai á praia de Samil.',
              es: 'Hoy Lúa va a la playa de Samil.',
            ),
            vocabularioClave: ['Mar', 'Samil'],
          ),
        ],
        preguntasGraduadas: [],
      );

      await tester.pumpWidget(_wrap(
        CuentoViewerScreen(
          cuento: cuento,
          language: AppLanguage.gl,
          audioService: audioService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('A Cuncha de Lúa'), findsOneWidget);
      expect(
          find.textContaining('Giant waves, row your boat!'), findsOneWidget);
      expect(find.byType(BotonEscuchar), findsOneWidget);
    });
  });

  group('Xogos Físicos e Dinámicas no Fogar (Zero-Screen TPR)', () {
    testWidgets(
        'renderiza o catálogo de xogos corporais e rexistro observacional',
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
