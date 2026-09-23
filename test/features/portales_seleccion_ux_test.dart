import 'dart:convert';
import 'dart:io';

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
import 'package:descubre_con_lua/features/cuentos/views/cuento_viewer_screen.dart';
import 'package:descubre_con_lua/features/docentes/portal_docentes_screen.dart';
import 'package:descubre_con_lua/features/familias/portal_familias_screen.dart';
import 'package:descubre_con_lua/features/familias/views/xogos_fogar_screen.dart';
import 'package:descubre_con_lua/features/lectura/views/aprender_a_ler_screen.dart';
import 'package:descubre_con_lua/features/premios/premios_repository.dart';
import 'package:descubre_con_lua/features/seleccion/seleccion_portal_screen.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: AppTheme.lightTheme, home: child);

/// Ancho de teléfono e ALTO de sobra.
///
/// Estes tests comproban que o CONTIDO está, non que caiba: con 600 px de alto
/// —o que trae o test por defecto— os botóns dos portais caían fóra da árbore
/// de render (y=681) e `tap()` non chegaba a eles, así que fallaban sen que a
/// pantalla tivese nada malo.
///
/// Que caiba nun teléfono de verdade compróbase noutro sitio, e a propósito:
/// `test/features/portales_escala_test.dart`, co tamaño e a escala de texto
/// reais. Mesturar as dúas cousas nun só test fai que un fallo de disposición
/// se confunda cun fallo de contido.
void _pantallaDeTelefono(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Fai o posible por deixar [finder] visible antes de comprobalo.
///
/// O contido dos portais vive nun `ListView`: o que está debaixo do prego non
/// se constrúe, así que non se pode buscar sen desprazarse primeiro. Se xa
/// está, non fai nada; se non se alcanza desprazándose, tampouco falla AQUÍ:
/// falla o `expect` que vén despois, que é quen ten que dicir o que pasa.
Future<void> _ataVer(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    return;
  }
  final listas = find.byType(Scrollable);
  for (var i = 0; i < listas.evaluate().length; i++) {
    // Nas dúas direccións: un `expect` anterior pode ter baixado a lista, e o
    // `ListView` destrúe o que queda fóra, así que o de arriba xa non existe.
    for (final delta in [200.0, -200.0]) {
      try {
        await tester.scrollUntilVisible(finder, delta,
            scrollable: listas.at(i));
        await tester.pumpAndSettle();
        if (finder.evaluate().isNotEmpty) return;
      } catch (_) {
        // Nin nesta lista nin nesta dirección: próbase a seguinte.
      }
    }
  }
  await tester.pumpAndSettle();
}

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
      _pantallaDeTelefono(tester);
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
      await _ataVer(tester, find.text('Portal Familias'));
      expect(find.text('Portal Familias'), findsOneWidget);
      await _ataVer(tester, find.text('Portal Docentes'));
      expect(find.text('Portal Docentes'), findsOneWidget);

      expect(find.byType(IlustracionFamilia), findsOneWidget);
      expect(find.byType(IlustracionEscola), findsOneWidget);

      // Botóns de entrada independente
      await _ataVer(tester, find.text('Entrar no Portal Familias'));
      expect(find.text('Entrar no Portal Familias'), findsOneWidget);
      await _ataVer(tester, find.text('Entrar no Portal Docentes'));
      expect(find.text('Entrar no Portal Docentes'), findsOneWidget);
    });

    testWidgets('paridade bilingüe galego e castelán na selección de portal',
        (tester) async {
      _pantallaDeTelefono(tester);
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

      await _ataVer(tester, find.text('Entrar en el Portal Familias'));
      expect(find.text('Entrar en el Portal Familias'), findsOneWidget);
      await _ataVer(tester, find.text('Entrar en el Portal Docentes'));
      expect(find.text('Entrar en el Portal Docentes'), findsOneWidget);
      expect(find.textContaining('CERO PANTALLAS'), findsOneWidget);
    });

    testWidgets('navega á pantalla independente do Portal Familias',
        (tester) async {
      _pantallaDeTelefono(tester);
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

      final boton = find.text('Entrar no Portal Familias');
      await tester.ensureVisible(boton);
      await tester.pumpAndSettle();
      await tester.tap(boton);
      await tester.pumpAndSettle();

      expect(find.byType(PortalFamiliasScreen), findsOneWidget);
      await _ataVer(tester, find.text('Benvida ao fogar de Lúa'));
      expect(find.text('Benvida ao fogar de Lúa'), findsOneWidget);
      await _ataVer(tester, find.text('CERO PANTALLAS INFANTÍS'));
      expect(find.text('CERO PANTALLAS INFANTÍS'), findsOneWidget);
    });

    testWidgets('navega á pantalla independente do Portal Docentes',
        (tester) async {
      _pantallaDeTelefono(tester);
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

      final boton = find.text('Entrar no Portal Docentes');
      await tester.ensureVisible(boton);
      await tester.pumpAndSettle();
      await tester.tap(boton);
      await tester.pumpAndSettle();

      expect(find.byType(PortalDocentesScreen), findsOneWidget);
      await _ataVer(tester, find.text('Escolas infantís de Vigo'));
      expect(find.text('Escolas infantís de Vigo'), findsOneWidget);
      await _ataVer(tester, find.text('MODO AULA · DOCENTES'));
      expect(find.text('MODO AULA · DOCENTES'), findsOneWidget);
    });
  });

  group('Portal Familias Independente (Filtros, Chips e Selección)', () {
    testWidgets(
        'amosa módulos de estimulación familiar e permite filtrar por área e idade',
        (tester) async {
      _pantallaDeTelefono(tester);
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
      await _ataVer(tester, find.text('Calendario Escolar no Fogar'));
      expect(find.text('Calendario Escolar no Fogar'), findsOneWidget);
      await _ataVer(tester, find.text('Biblioteca de Contos Dialóxicos'));
      expect(find.text('Biblioteca de Contos Dialóxicos'), findsOneWidget);
      await _ataVer(tester, find.text('Aprender a Ler · Fónica Manipulativa'));
      expect(find.text('Aprender a Ler · Fónica Manipulativa'), findsOneWidget);
      await _ataVer(tester, find.text('Banco de Láminas e Vocabulario'));
      expect(find.text('Banco de Láminas e Vocabulario'), findsOneWidget);
      await _ataVer(tester, find.text('Xogos e Dinámicas Corporais (TPR)'));
      expect(find.text('Xogos e Dinámicas Corporais (TPR)'), findsOneWidget);
      await _ataVer(tester, find.text('Academy · Pautas de Crianza'));
      expect(find.text('Academy · Pautas de Crianza'), findsOneWidget);

      // Chips de idades dispoñibles
      await _ataVer(tester, find.text('Todas as idades'));
      expect(find.text('Todas as idades'), findsOneWidget);
      await _ataVer(tester, find.text('0-2 anos (Nido)'));
      expect(find.text('0-2 anos (Nido)'), findsOneWidget);
      await _ataVer(tester, find.text('2-3 anos (Maternal)'));
      expect(find.text('2-3 anos (Maternal)'), findsOneWidget);

      // Filtrar por categoría 'Xogos Físicos (TPR)'
      await tester.tap(find.text('Xogos Físicos (TPR)'));
      await tester.pumpAndSettle();

      await _ataVer(tester, find.text('Xogos e Dinámicas Corporais (TPR)'));
      expect(find.text('Xogos e Dinámicas Corporais (TPR)'), findsOneWidget);
      expect(find.text('Biblioteca de Contos Dialóxicos'), findsNothing);

      // Volver a Todas as Áreas
      await tester.tap(find.text('Todas as Áreas'));
      await tester.pumpAndSettle();

      await _ataVer(tester, find.text('Biblioteca de Contos Dialóxicos'));
      expect(find.text('Biblioteca de Contos Dialóxicos'), findsOneWidget);
    });
  });

  group('Portal Docentes Independente', () {
    testWidgets(
        'amosa recursos de aula municipal a 72 bpm e planificador curricular',
        (tester) async {
      _pantallaDeTelefono(tester);
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

      await _ataVer(tester, find.text('Juega con Lúa · Modo Aula'));
      expect(find.text('Juega con Lúa · Modo Aula'), findsOneWidget);
      await _ataVer(tester, find.text('Planificador curricular'));
      expect(find.text('Planificador curricular'), findsOneWidget);
      // Frank: «solo deja planificador curricular, elimina donde dice 50 meses».
      expect(find.textContaining('50 Meses'), findsNothing);
      expect(find.textContaining('50 meses'), findsNothing);
      await _ataVer(tester, find.text('Inmersión en Inglés · L3'));
      expect(find.text('Inmersión en Inglés · L3'), findsOneWidget);
      await _ataVer(tester, find.text('Estratexias Pedagóxicas de Aula'));
      expect(find.text('Estratexias Pedagóxicas de Aula'), findsOneWidget);
      await _ataVer(tester, find.text('Dinámicas de Aula Activa'));
      expect(find.text('Dinámicas de Aula Activa'), findsOneWidget);
      await _ataVer(tester, find.text('Corpus 8.000 Palabras (BNC/COCA)'));
      expect(find.text('Corpus 8.000 Palabras (BNC/COCA)'), findsOneWidget);
    });
  });

  group('Calendario Escolar no Fogar (Reixa de 20 días e 1-Tap Logging)', () {
    testWidgets(
        'renderiza reixa escolar de 20 días e permite alternar vista e marcar hoxe',
        (tester) async {
      _pantallaDeTelefono(tester);
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
      await _ataVer(tester, find.text('0-2 anos (Nido)'));
      expect(find.text('0-2 anos (Nido)'), findsOneWidget);
      await _ataVer(tester, find.text('2-3 anos (Maternal)'));
      expect(find.text('2-3 anos (Maternal)'), findsOneWidget);
      await _ataVer(tester, find.text('Setembro'));
      expect(find.text('Setembro'), findsOneWidget);

      // Reixa de 20 días lectivos
      await _ataVer(tester, find.text('REIXA ESCOLAR · 20 DÍAS LECTIVOS'));
      expect(find.text('REIXA ESCOLAR · 20 DÍAS LECTIVOS'), findsOneWidget);
      await _ataVer(tester, find.text('Primeiro día con Lúa'));
      expect(find.text('Primeiro día con Lúa'), findsOneWidget);
      // Pintase entre comiñas angulares, así que o texto exacto non casa.
      await _ataVer(tester, find.textContaining('Clap hands, touch ground!'));
      expect(find.textContaining('Clap hands, touch ground!'), findsWidgets);

      // Botón 1-tap para marcar como feito hoxe
      await _ataVer(tester, find.text('Marcar como Feito Hoxe'));
      expect(find.text('Marcar como Feito Hoxe'), findsOneWidget);
      await tester.tap(find.text('Marcar como Feito Hoxe'));
      await tester.pumpAndSettle();

      await _ataVer(tester, find.text('Xogo Feito Hoxe no Fogar'));
      expect(find.text('Xogo Feito Hoxe no Fogar'), findsOneWidget);

      // Alternar a vista de calendario para ver selector de semanas
      await tester.tap(find.byIcon(Icons.calendar_view_month_rounded));
      await tester.pumpAndSettle();

      await _ataVer(tester, find.text('Semana 1'));
      expect(find.text('Semana 1'), findsOneWidget);
    });
  });

  group('Aprender a Ler · Fónica Manipulativa con Botóns de Audio', () {
    testWidgets('renderiza as 4 pestanas con botóns de reprodución de son',
        (tester) async {
      _pantallaDeTelefono(tester);
      await tester.pumpWidget(_wrap(
        AprenderALerScreen(
          repository: repository,
          initialLanguage: AppLanguage.gl,
          audioService: audioService,
        ),
      ));
      await tester.pumpAndSettle();

      // Pestanas
      await _ataVer(tester, find.text('1. Conciencia Fonolóxica'));
      expect(find.text('1. Conciencia Fonolóxica'), findsOneWidget);
      await _ataVer(tester, find.text('2. Mesa Alphabot'));
      expect(find.text('2. Mesa Alphabot'), findsOneWidget);
      await _ataVer(tester, find.text('3. Cubos CVC'));
      expect(find.text('3. Cubos CVC'), findsOneWidget);
      await _ataVer(tester, find.text('4. Pares Mínimos'));
      expect(find.text('4. Pares Mínimos'), findsOneWidget);

      // Tab 2: Mesa Alphabot
      await tester.tap(find.text('2. Mesa Alphabot'));
      await tester.pumpAndSettle();

      await _ataVer(tester, find.text('LÚA'));
      expect(find.text('LÚA'), findsOneWidget);
      expect(find.byType(BotonEscuchar), findsWidgets);

      // Tocar unha letra para marcar colocada na mesa física
      expect(find.text('L'), findsWidgets);
      await tester.tap(find.text('L').first);
      await tester.pumpAndSettle();

      // Tab 3: Cubos CVC
      await tester.tap(find.text('3. Cubos CVC'));
      await tester.pumpAndSettle();

      await _ataVer(tester, find.text('CAT · /kæt/'));
      expect(find.text('CAT · /kæt/'), findsOneWidget);
      expect(find.byType(BotonEscuchar), findsWidgets);

      // Tab 4: Pares Mínimos
      await tester.tap(find.text('4. Pares Mínimos'));
      await tester.pumpAndSettle();

      await _ataVer(tester, find.text('/b/ vs /p/'));
      expect(find.text('/b/ vs /p/'), findsOneWidget);
      await _ataVer(tester, find.text('Bear'));
      expect(find.text('Bear'), findsOneWidget);
      await _ataVer(tester, find.text('Pig'));
      expect(find.text('Pig'), findsOneWidget);
      expect(find.byType(BotonEscuchar), findsWidgets);
    });
  });

  group('Banco de contos: narrativa propia no JSON, non xerada', () {
    // O que había aquí probaba un «motor de narrativa» que escribía tres
    // parágrafos fixos en tempo de execución. Ese motor xa non existe: os cen
    // contos levan a súa propia narrativa no JSON. Estes tests protexen
    // precisamente iso, que é o que se podía volver perder.

    late List<Cuento> contos;

    setUpAll(() {
      final raw = File('assets/content/cuentos/banco100_cuentos.json')
          .readAsStringSync();
      contos = (jsonDecode(raw) as List)
          .map((e) => Cuento.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    });

    test('os cen contos teñen tres páxinas e ningunha en branco', () {
      expect(contos, hasLength(100));
      for (final c in contos) {
        expect(c.paginas, hasLength(3), reason: c.id);
        for (final pg in c.paginas) {
          expect(pg.texto.gl.trim(), isNotEmpty,
              reason: '${c.id}/${pg.numero}');
          expect(pg.texto.es.trim(), isNotEmpty,
              reason: '${c.id}/${pg.numero}');
        }
      }
    });

    test('ningún texto de páxina se repite entre contos, nas dúas linguas', () {
      // Isto é o defecto que había: a páxina 2 e a 3 eran UN texto repetido
      // cen veces. Se alguén volve meter un xerador ou copiar e pegar, este
      // test cae.
      for (final numero in [1, 2, 3]) {
        for (final gl in [true, false]) {
          final textos = contos
              .map((c) => c.paginas.firstWhere((p) => p.numero == numero))
              .map((p) => gl ? p.texto.gl : p.texto.es)
              .toList();
          expect(textos.toSet(), hasLength(100),
              reason:
                  'páxina $numero, ${gl ? "gl" : "es"}: hai textos repetidos');
        }
      }
    });

    test('non queda ningunha fórmula modelo das que había', () {
      const formulas = [
        'Na escola infantil e no fogar, abrimos os ollos',
        'En la escuela infantil y en el hogar, abrimos los ojos',
        'De súpeto, algo marabilloso sucede',
        'De repente, algo maravilloso sucede',
        'Que ben se sinte o corazón tranquilo',
        'Qué bien se siente el corazón tranquilo',
        'Miau! Que cousas tan fermosas',
      ];
      for (final c in contos) {
        for (final pg in c.paginas) {
          for (final f in formulas) {
            expect(pg.texto.gl, isNot(contains(f)),
                reason: '${c.id}/${pg.numero}');
            expect(pg.texto.es, isNot(contains(f)),
                reason: '${c.id}/${pg.numero}');
          }
        }
      }
    });

    test('o vocabulario é propio de cada páxina e ten as dúas linguas', () {
      for (final numero in [1, 2, 3]) {
        final listas = contos
            .map((c) => c.paginas.firstWhere((p) => p.numero == numero))
            .map((p) => p.vocabularioClave.join('|'))
            .toList();
        expect(listas.toSet(), hasLength(100),
            reason: 'páxina $numero: o vocabulario repítese entre contos');
      }
      for (final c in contos) {
        for (final pg in c.paginas) {
          expect(pg.vocabularioClave, hasLength(4), reason: c.id);
          expect(pg.vocabularioClaveEs, hasLength(4), reason: c.id);
          expect(
              pg.vocabularioPara(AppLanguage.es), equals(pg.vocabularioClaveEs),
              reason: c.id);
          expect(
              pg.vocabularioPara(AppLanguage.gl), equals(pg.vocabularioClave),
              reason: c.id);
        }
      }
    });

    testWidgets('o visor pinta o texto do JSON, tal cal, e o botón do TPR',
        (tester) async {
      _pantallaDeTelefono(tester);
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
            vocabularioClaveEs: ['Mar', 'Samil'],
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

      await _ataVer(tester, find.text('A Cuncha de Lúa'));
      expect(find.text('A Cuncha de Lúa'), findsOneWidget);
      // O texto sae do JSON sen engadidos: nin unha palabra máis.
      await _ataVer(tester, find.text('Hoxe Lúa vai á praia de Samil.'));
      expect(find.text('Hoxe Lúa vai á praia de Samil.'), findsOneWidget);
      expect(
          find.textContaining('Giant waves, row your boat!'), findsOneWidget);
      expect(find.byType(BotonEscuchar), findsOneWidget);
    });
  });

  group('Xogos Físicos e Dinámicas no Fogar (Zero-Screen TPR)', () {
    testWidgets(
        'renderiza o catálogo de xogos corporais e rexistro observacional',
        (tester) async {
      _pantallaDeTelefono(tester);
      await tester.pumpWidget(_wrap(
        const XogosFogarScreen(
          initialLanguage: AppLanguage.gl,
        ),
      ));
      await tester.pumpAndSettle();

      await _ataVer(tester, find.text('A Caza do Tesouro dos Sons'));
      expect(find.text('A Caza do Tesouro dos Sons'), findsOneWidget);
      await _ataVer(tester, find.text('O Barquiño de Samil na Ría'));
      expect(find.text('O Barquiño de Samil na Ría'), findsOneWidget);
      await _ataVer(tester, find.text('XOGO 100% CORPORAL E FÍSICO'));
      expect(find.text('XOGO 100% CORPORAL E FÍSICO'), findsOneWidget);

      // Rexistro 1-toque
      expect(find.text('[L] Logrado'), findsWidgets);
      await tester.tap(find.text('[L] Logrado').first);
      await tester.pumpAndSettle();
    });
  });
}
