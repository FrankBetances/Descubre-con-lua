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
import 'package:descubre_con_lua/main.dart' show DescubreConLuaApp;
import 'package:descubre_con_lua/data/models/xogos_fogar_observar_model.dart';

import '../helpers/pasarela.dart';

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

  // L5: a benvida e a elección de portal son unha soa pantalla. Unha
  // pregunta e dúas respostas grandes, cada unha co seu debuxo; antes eran
  // dúas pantallas e a elección ocupaba 2,4.
  group('O inicio: unha pregunta e dúas respostas', () {
    Widget app(AppLanguage lang) => DescubreConLuaApp(
          contentRepository: repository,
          premiosRepository: premiosRepository,
          calendarioStore: calendarioStore,
          audioService: audioService,
          initialLanguage: lang,
        );

    testWidgets('as dúas respostas, co seu debuxo e sen baixar',
        (tester) async {
      _pantallaDeTelefono(tester);
      await tester.pumpWidget(app(AppLanguage.gl));
      await tester.pumpAndSettle();

      expect(find.text('Onde vas usala?'), findsOneWidget);
      expect(find.text('Na casa'), findsOneWidget);
      expect(find.text('Na escola'), findsOneWidget);
      expect(find.byType(IlustracionFamilia), findsOneWidget);
      expect(find.byType(IlustracionEscola), findsOneWidget);
      // As dúas enteiras na primeira pantalla.
      final alto =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      for (final k in ['inicio_na_casa', 'inicio_na_escola']) {
        expect(tester.getRect(find.byKey(ValueKey(k))).bottom,
            lessThanOrEqualTo(alto),
            reason: k);
      }
      // Xa non hai pantalla intermedia nin botón «Comezar».
      expect(find.text('Comezar'), findsNothing);
    });

    testWidgets('paridade bilingüe galego e castelán no inicio',
        (tester) async {
      _pantallaDeTelefono(tester);
      await tester.pumpWidget(app(AppLanguage.es));
      await tester.pumpAndSettle();
      expect(find.text('¿Dónde la vas a usar?'), findsOneWidget);
      expect(find.text('En casa'), findsOneWidget);
      expect(find.text('Tres minutos al día con tu criatura'), findsOneWidget);
      expect(find.text('En la escuela'), findsOneWidget);
      expect(find.text('La asamblea de cada día'), findsOneWidget);
    });

    testWidgets('«Na casa» abre o Portal Familias por Hoxe', (tester) async {
      _pantallaDeTelefono(tester);
      await tester.pumpWidget(app(AppLanguage.gl));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('inicio_na_casa')));
      // Ábrese por Hoxe: o que toca hoxe, co xogo diante, e as catro
      // pestanas abaixo. O día lese do paquete: E/S de verdade.
      await Pasarela.asentar(tester);
      expect(find.byType(PortalFamiliasScreen), findsOneWidget);
      expect(find.byKey(const Key('hoxe_titulo')), findsOneWidget);
      for (final p in ['Hoxe', 'Calendario', 'Explorar', 'Guías']) {
        expect(
            find.descendant(
                of: find.byType(NavigationBar), matching: find.text(p)),
            findsOneWidget,
            reason: p);
      }
    });

    testWidgets('«Na escola» abre o Portal Docentes por Hoxe', (tester) async {
      _pantallaDeTelefono(tester);
      await tester.pumpWidget(app(AppLanguage.gl));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('inicio_na_escola')));
      await Pasarela.asentar(tester);
      expect(find.byType(PortalDocentesScreen), findsOneWidget);
      // Abre en «Hoxe»: a asemblea do día, arriba e cun só botón.
      expect(find.byKey(const Key('hoxe_aula_titulo')), findsOneWidget);
      for (final p in ['Hoxe', 'Calendario', 'Recursos', 'Eu']) {
        expect(
            find.descendant(
                of: find.byKey(const Key('pestanas_docentes')),
                matching: find.text(p)),
            findsOneWidget,
            reason: p);
      }
    });
  });

  group('Portal Familias Independente (Filtros, Chips e Selección)', () {
    testWidgets('catro pestanas, cada módulo nunha soa e co seu nome de casa',
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

      // Explorar: os seis módulos de casa, sen filtros diante.
      await tester.tap(find.byKey(const Key('pestana_explorar')));
      await tester.pumpAndSettle();
      for (final m in [
        'Contos',
        'Palabras en inglés',
        'Xogos de movemento',
        'Ler xogando',
        'Láminas',
        'Ciencia coas mans',
      ]) {
        expect(find.text(m), findsOneWidget, reason: m);
      }
      // Os nomes de manual xa non están.
      expect(find.text('Biblioteca de Contos Dialóxicos'), findsNothing);
      expect(find.text('Aprender a Ler · Fónica Manipulativa'), findsNothing);

      // Guías: o que é para a persoa adulta.
      await tester.tap(find.byKey(const Key('pestana_guias')));
      await tester.pumpAndSettle();
      for (final g in [
        'Antes de empezar',
        'Guías para a familia',
        'O inglés na casa',
        'Os teus premios',
      ]) {
        expect(find.text(g), findsOneWidget, reason: g);
      }
      expect(find.text('Academy · Pautas de Crianza'), findsNothing);

      // Calendario: o curso mes a mes, nunha pestana.
      await tester.tap(find.byKey(const Key('pestana_calendario')));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarioFogarScreen), findsOneWidget);
    });
  });

  group('Portal Docentes Independente', () {
    testWidgets(
        'Recursos: os módulos agrupados polo que se vai facer, co planificador curricular',
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
      await tester.tap(find.byKey(const Key('pestana_recursos')));
      await tester.pumpAndSettle();

      // Os grupos din para que serven; antes eran «1. ASEMBLEA E AULA ACTIVA
      // (72 BPM)», «3. INMERSIÓN L3…».
      for (final g in [
        'PARA A ASEMBLEA',
        'PARA PLANIFICAR',
        'INGLÉS',
        'PARA SABER MÁIS',
      ]) {
        await _ataVer(tester, find.text(g));
        expect(find.text(g), findsOneWidget, reason: g);
      }
      expect(find.textContaining('72 BPM'), findsNothing);
      expect(find.textContaining('INMERSIÓN L3'), findsNothing);

      for (final m in [
        'Xoga con Lúa · Modo Aula',
        'Dinámicas de aula',
        'Ciencia coas mans',
        'Planificador curricular',
        'Palabras do curso',
        'O repaso',
        'Frases do curso',
        'Colocacións',
        'Sons do inglés',
        'Vocabulario de uso habitual',
        'Estratexias de aula',
      ]) {
        await _ataVer(tester, find.text(m));
        expect(find.text(m), findsOneWidget, reason: m);
      }
      // Frank: «solo deja planificador curricular, elimina donde dice 50 meses».
      expect(find.textContaining('50 Meses'), findsNothing);
      expect(find.textContaining('50 meses'), findsNothing);
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
          // Un luns de setembro: o test le o primeiro día do curso.
          agora: DateTime(2026, 9, 7),
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

      // Un toque para dicir que o xogo de hoxe xa está feito
      await _ataVer(tester, find.text('Xa o fixemos'));
      expect(find.text('Xa o fixemos'), findsOneWidget);
      await tester.tap(find.text('Xa o fixemos'));
      await tester.pumpAndSettle();

      await _ataVer(tester, find.text('Feito hoxe'));
      expect(find.text('Feito hoxe'), findsOneWidget);

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
      await _ataVer(tester, find.text('1. Conciencia fonolóxica'));
      expect(find.text('1. Conciencia fonolóxica'), findsOneWidget);
      await _ataVer(tester, find.text('2. Mesa Alphabot'));
      expect(find.text('2. Mesa Alphabot'), findsOneWidget);
      await _ataVer(tester, find.text('3. Cubos CVC'));
      expect(find.text('3. Cubos CVC'), findsOneWidget);
      await _ataVer(tester, find.text('4. Pares mínimos'));
      expect(find.text('4. Pares mínimos'), findsOneWidget);

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
      await tester.tap(find.text('4. Pares mínimos'));
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
    // parágrafos fixos en tempo de execución. Ese motor xa non existe: cada
    // conto leva a súa propia historia no JSON. Estes tests protexen
    // precisamente iso, que é o que se podía volver perder.

    late List<Cuento> contos;

    setUpAll(() {
      contos = [
        for (final f in ['historias_progresivas.json', 'banco100_cuentos.json'])
          ...(jsonDecode(File('assets/content/cuentos/$f').readAsStringSync())
                  as List)
              .map((e) => Cuento.fromJson(Map<String, dynamic>.from(e as Map))),
      ];
    });

    // Un conto ten personaxes, un desexo, un problema, intentos e un final:
    // iso non cabe en tres páxinas. E medra coa crianza.
    const paxinasPorCurso = {
      'curso_0_2': (5, 5),
      'curso_2_3': (6, 6),
      'curso_3_4': (6, 7),
      'curso_4_5': (7, 8),
      'curso_5_6': (8, 8),
    };

    test('cada conto ten as páxinas da súa idade e ningunha en branco', () {
      expect(contos, hasLength(303));
      for (final c in contos) {
        final (min, max) = paxinasPorCurso[c.cursoId]!;
        expect(c.paginas.length, inInclusiveRange(min, max), reason: c.id);
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
      for (final gl in [true, false]) {
        final textos = [
          for (final c in contos)
            for (final p in c.paginas) gl ? p.texto.gl : p.texto.es,
        ];
        expect(textos.toSet(), hasLength(textos.length),
            reason: '${gl ? "gl" : "es"}: hai textos de páxina repetidos');
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

    test('o vocabulario é o de cada conto e vai nas dúas linguas á vez', () {
      // As palabras clave saen do propio conto e só se ensinan na páxina
      // onde aparecen. Se volve un xerador que pon as mesmas catro palabras
      // en todos, a primeira comprobación cae.
      final listas = contos
          .map((c) => c.paginas.expand((p) => p.vocabularioClave).toSet())
          .map((s) => (s.toList()..sort()).join('|'))
          .toList();
      expect(listas.toSet().length, greaterThan(contos.length * 9 ~/ 10));
      for (final c in contos) {
        expect(c.paginas.any((p) => p.vocabularioClave.isNotEmpty), isTrue,
            reason: c.id);
        for (final pg in c.paginas) {
          expect(pg.vocabularioClave.length, lessThanOrEqualTo(4),
              reason: c.id);
          // Mesmo número nas dúas linguas: se a lista castelá quedase
          // baleira, o visor en castelán ensinaría as palabras en galego.
          expect(pg.vocabularioClaveEs, hasLength(pg.vocabularioClave.length),
              reason: '${c.id}/${pg.numero}');
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
        'renderiza o catálogo de xogos corporais e o «Que observar» de cada un',
        (tester) async {
      _pantallaDeTelefono(tester);
      await tester.pumpWidget(_wrap(
        XogosFogarScreen(
          initialLanguage: AppLanguage.gl,
          // Lido de forma síncrona: dentro de `testWidgets` unha lectura
          // asíncrona do disco non remata.
          observacions: ObservacionsXogosFogar.fromRaw(
              File(ObservacionsXogosFogar.assetPath).readAsStringSync()),
        ),
      ));
      await tester.pumpAndSettle();

      await _ataVer(tester, find.text('A Caza do Tesouro dos Sons'));
      expect(find.text('A Caza do Tesouro dos Sons'), findsOneWidget);
      await _ataVer(tester, find.text('O Barquiño de Samil na Ría'));
      expect(find.text('O Barquiño de Samil na Ría'), findsOneWidget);
      await _ataVer(tester, find.text('XOGO 100% CORPORAL E FÍSICO'));
      expect(find.text('XOGO 100% CORPORAL E FÍSICO'), findsOneWidget);

      // Que observar, que se le e non se marca: xa non hai botóns para
      // avaliar a criatura.
      expect(find.text('[L] Logrado'), findsNothing);
      await _ataVer(tester, find.text('Que observar').first);
      expect(find.text('Que observar'), findsWidgets);
      expect(find.text('Busca coa mirada antes de moverse.'), findsOneWidget);
    });
  });
}
