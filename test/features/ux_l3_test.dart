import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/calendario_model.dart';
import 'package:descubre_con_lua/features/cuentos/views/cuentos_list_screen.dart';
import 'package:descubre_con_lua/features/familias/portal_familias_screen.dart';
import 'package:descubre_con_lua/features/familias/views/hoxe_familias_screen.dart';
import 'package:descubre_con_lua/features/familias/views/xogo_de_hoxe_screen.dart';

import '../helpers/pasarela.dart';

/// Lote L3 de la revisión de interfaz: «Hoxe», la portada de casa.
///
/// Lo de hoy, entero, en una pantalla: el juego de tres minutos con su título
/// de casa y un solo botón, sus palabras en inglés con voz y el cuento de la
/// semana. Todo con el viernes 2 de octubre de 0-2 años, el ejemplo de la
/// revisión: allí el juego se titulaba «Asemblea de Outubro: O Círculo dos
/// Amigos de Lúa · Venres (Ponte á casa e celebración coral)».
void main() {
  final p = Pasarela();
  setUpAll(p.cargar);
  tearDownAll(p.limpar);

  final venres = DateTime(2026, 10, 2, 10);
  final domingo = DateTime(2026, 10, 4, 10);

  Future<CalendarioStore> storeBaleiro() async {
    final dir = Directory.systemTemp.createTempSync('ux_l3_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final s = CalendarioStore(overrideDirectory: dir.path);
    await s.cargar();
    return s;
  }

  Future<void> abrirPortal(WidgetTester tester, AppLanguage lang,
      {required DateTime agora, CalendarioStore? store}) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.temaFamilias,
      home: PortalFamiliasScreen(
        repository: p.contenido,
        audioService: p.audio,
        currentLanguage: lang,
        onToggleLanguage: () {},
        premios: p.premios,
        calendario: store ?? p.store,
        agora: agora,
      ),
    ));
    await Pasarela.asentar(tester);
  }

  String texto(WidgetTester tester, String clave) =>
      tester.widget<Text>(find.byKey(Key(clave))).data ?? '';

  // O-20261109-5: arriba va la pantalla «Learn» de Duolingo; debajo, la
  // lección de la semana para consultar.
  // En 0-2 (O-20261109-4, ACOPROS) la lección es el proyecto del mes.
  final leccion = find.byWidgetPredicate((w) =>
      w.key == const Key('leccion_cabeceira') ||
      w.key == const Key('proxecto_0_2'));
  Future<void> verLeccion(WidgetTester tester) async {
    await tester.scrollUntilVisible(leccion, 300,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
  }

  // P11: el juego de tres minutos, en el material complementario.
  Future<void> irAoXogo(WidgetTester tester) async {
    await Pasarela.abrirMaisParaCasa(tester);
    final comezar = find.byKey(const Key('hoxe_comezar'));
    await tester.scrollUntilVisible(comezar, 300,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(comezar);
    await tester.pumpAndSettle();
  }

  for (final lang in AppLanguage.deInterfaz) {
    final gl = lang == AppLanguage.gl;

    testWidgets('Hoxe, un venres: o xogo co título de casa (${lang.code})',
        (tester) async {
      await abrirPortal(tester, lang, agora: venres);

      expect(texto(tester, 'hoxe_titulo'),
          gl ? 'A lección desta semana' : 'La lección de esta semana');
      expect(texto(tester, 'hoxe_data'),
          gl ? 'VENRES, 2 DE OUTUBRO' : 'VIERNES, 2 DE OCTUBRE');
      await verLeccion(tester);
      expect(leccion, findsOneWidget);
      await irAoXogo(tester);

      // El título es el momento del día, no el nombre de la asamblea (A6).
      expect(texto(tester, 'hoxe_xogo_titulo'),
          gl ? 'Antes de durmir' : 'Antes de dormir');
      final xogo = texto(tester, 'hoxe_xogo_texto');
      expect(xogo, isNot(contains('Asemblea de')));
      expect(xogo, isNot(contains('Asamblea de')));
      // Y cita el cuento de la semana, el mismo que está debajo.
      final conto =
          gl ? 'Martiño e o nariz escondido' : 'Martiño y la nariz escondida';
      expect(xogo, contains('«$conto»'));
      // Un solo botón principal: «Comezar».
      expect(find.byKey(const Key('hoxe_comezar')), findsOneWidget);
      await tester.scrollUntilVisible(
          find.byKey(const Key('hoxe_conto_da_semana')), 200,
          scrollable: find.byType(Scrollable).first);
      expect(
          find.descendant(
              of: find.byKey(const Key('hoxe_conto_da_semana')),
              matching: find.text(conto)),
          findsOneWidget);
    });

    testWidgets('Learn de Duolingo, sen baixar, a 412×915 (${lang.code})',
        (tester) async {
      // O-20261109-5: como en duolingo-clone, la primera pantalla es la
      // unidad en su caja y el camino con los nodos de la semana.
      await abrirPortal(tester, lang, agora: venres);
      tester.view.physicalSize = const Size(412, 915);
      await Pasarela.asentar(tester);
      final barra = tester.getRect(find.byType(NavigationBar)).top;
      for (final k in [
        'learn_banner',
        'learn_nodo_0',
        'learn_nodo_3',
        // O-20261110-1: el camino entero, con el viernes y «Empezar».
        'learn_nodo_4',
        'learn_empezar',
      ]) {
        expect(
            tester.getRect(find.byKey(Key(k))).bottom, lessThanOrEqualTo(barra),
            reason: k);
      }
      // Debajo, la lección de la semana entera.
      await verLeccion(tester);
      expect(leccion, findsOneWidget);
    });

    testWidgets(
        'os nodos dos días responden sempre, sen tocar o banner (${lang.code})',
        (tester) async {
      // O-20261111-2 (B): mércores 11/11/2026. O luns e o mércores abren a
      // súa lección; o xoves aínda non chegou e avisa, nunca cala.
      await abrirPortal(tester, lang, agora: DateTime(2026, 11, 11, 18));
      expect(find.byType(HoxeFamiliasScreen), findsOneWidget);
      for (final i in [0, 2]) {
        final nodo = find.byKey(ValueKey('learn_nodo_$i'));
        expect(tester.getSize(nodo).height, greaterThanOrEqualTo(48));
        expect(tester.getSize(nodo).width, greaterThanOrEqualTo(48));
        await Scrollable.ensureVisible(tester.element(nodo), alignment: 0.5);
        await Pasarela.asentar(tester);
        await tester.tap(nodo);
        await Pasarela.asentar(tester);
        expect(find.byKey(const Key('leccion_progreso')), findsOneWidget,
            reason: 'nodo $i');
        Navigator.of(tester.element(find.byKey(const Key('leccion_progreso'))))
            .pop();
        await Pasarela.asentar(tester);
        expect(find.byKey(const Key('leccion_progreso')), findsNothing);
      }
      final xoves = find.byKey(const ValueKey('learn_nodo_3'));
      expect(tester.getSize(xoves).height, greaterThanOrEqualTo(48));
      await Scrollable.ensureVisible(tester.element(xoves), alignment: 0.5);
      await Pasarela.asentar(tester);
      // No texto da etiqueta, non só no círculo.
      await tester
          .tapAt(tester.getRect(xoves).bottomCenter - const Offset(0, 6));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const Key('leccion_progreso')), findsNothing);
      expect(
          find.text(
              gl ? 'Este día ábrese o xoves' : 'Este día se abre el jueves'),
          findsOneWidget);
    });

    testWidgets('«Máis para casa» vai pregado, ao final (${lang.code})',
        (tester) async {
      await abrirPortal(tester, lang, agora: venres);
      final mais = find.byKey(const Key('hoxe_complementario'));
      await tester.scrollUntilVisible(mais, 300,
          scrollable: find.byType(Scrollable).first);
      // Debajo de la lección (en 0-2, el proyecto del mes): lo último de Hoy.
      final guia = find.byKey(const Key('proxecto_0_2'));
      expect(
          tester.getTopLeft(mais).dy, greaterThan(tester.getTopLeft(guia).dy));
      // Plegado: el juego y el código no están hasta que se abre.
      for (final k in ['hoxe_comezar', 'hoxe_codigo_escola']) {
        expect(find.byKey(Key(k), skipOffstage: false), findsNothing,
            reason: k);
      }
      await Pasarela.abrirMaisParaCasa(tester);
      expect(find.byKey(const Key('hoxe_codigo_escola'), skipOffstage: false),
          findsOneWidget);
    });

    testWidgets(
        'o venres en 0-2: as do proxecto, sen o reto das 20 (${lang.code})',
        (tester) async {
      // O-20261109-4 (ACOPROS): 0-2 no usa el banco diario ni su reto de los
      // viernes; en «Máis para casa» salen las palabras de la semana del
      // proyecto.
      await abrirPortal(tester, lang, agora: venres);
      await Pasarela.abrirMaisParaCasa(tester);
      final tarxeta = find.byKey(const Key('tarxeta_ingles_de_hoxe_fogar'));
      await tester.scrollUntilVisible(tarxeta, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(
          find.byKey(const Key('palabras_proxecto_0_2'), skipOffstage: false),
          findsOneWidget);
      expect(find.byKey(const Key('reto_con_voz'), skipOffstage: false),
          findsNothing);
    });

    testWidgets('fin de semana: o xogo do luns, sen marcalo (${lang.code})',
        (tester) async {
      await abrirPortal(tester, lang, agora: domingo);
      expect(texto(tester, 'hoxe_titulo'),
          gl ? 'A lección desta semana' : 'La lección de esta semana');
      await irAoXogo(tester);
      await tester.tap(find.byKey(const Key('hoxe_comezar')));
      await Pasarela.asentar(tester);
      expect(find.byType(XogoDeHoxeScreen), findsOneWidget);
      // No se marca hecho un juego que es para el lunes.
      expect(find.byKey(const Key('xogo_xa_o_fixemos')), findsNothing);
      expect(find.byKey(const Key('xogo_non_e_hoxe')), findsOneWidget);
    });

    testWidgets('«Xa o fixemos» suma o día da persoa adulta (${lang.code})',
        (tester) async {
      // Con E/S de verdad: dentro del reloj falso una lectura de disco no
      // termina nunca.
      final store = (await tester.runAsync(storeBaleiro))!;
      await abrirPortal(tester, lang, agora: venres, store: store);

      await irAoXogo(tester);
      await tester.tap(find.byKey(const Key('hoxe_comezar')));
      await Pasarela.asentar(tester);
      expect(find.byType(XogoDeHoxeScreen), findsOneWidget);
      expect(texto(tester, 'xogo_momento'),
          gl ? 'Antes de durmir' : 'Antes de dormir');

      // El porqué, plegado hasta que se pide.
      final consigna = p.diaDeCasa.familias.consignaFamilia.resolve(lang);
      expect(find.text(consigna), findsNothing);
      await tester.tap(find.byKey(const Key('xogo_por_que')));
      await tester.pumpAndSettle();
      expect(find.text(consigna), findsOneWidget);

      await tester.tap(find.byKey(const Key('xogo_xa_o_fixemos')));
      await Pasarela.asentar(tester);
      expect(find.byKey(const Key('xogo_feito')), findsOneWidget);
      expect(store.estadoParaFecha(venres), EstadoEstimulacion.soloHogar);

      // De vuelta en Hoxe, la tarjeta dice que ya está hecho.
      await tester.tap(find.byKey(const ValueKey('boton_atras')).last);
      await Pasarela.asentar(tester);
      expect(find.byKey(const Key('hoxe_feito')), findsOneWidget);
      expect(find.byKey(const Key('hoxe_comezar')), findsNothing);
    });

    testWidgets('a idade cámbiase arriba e vale para todo (${lang.code})',
        (tester) async {
      await abrirPortal(tester, lang, agora: venres);
      bool leccionDe(String curso) => find
          .byWidgetPredicate((w) =>
              w.key is ValueKey<String> &&
              (w.key as ValueKey<String>).value.startsWith('leccion_$curso.'))
          .evaluate()
          .isNotEmpty;
      await verLeccion(tester);
      expect(find.byKey(const Key('proxecto_0_2')), findsOneWidget);
      await irAoXogo(tester);
      final antes = texto(tester, 'hoxe_xogo_texto');
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 30000));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('selector_idade')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('idade_curso_5_6')));
      await Pasarela.asentar(tester);
      // P11: la lección es la del curso elegido.
      await verLeccion(tester);
      expect(leccionDe('curso_5_6'), isTrue);
      await irAoXogo(tester);
      final despois = texto(tester, 'hoxe_xogo_texto');
      expect(despois, isNot(antes));
      final esperado =
          (await p.contenido.loadCalendarioDias(cursoId: 'curso_5_6', mes: 2))
              .firstWhere((d) => d.semanaNumero == 1 && d.diaSemanaNumero == 5)
              .familias
              .rutinaFogar
              .resolve(lang);
      expect(esperado, startsWith(despois));

      // Explorar → Contos abre en esa edad, con el cuento de la semana
      // delante.
      await tester.tap(find.byKey(const Key('pestana_explorar')));
      await Pasarela.asentar(tester);
      await tester.tap(find.byKey(const ValueKey('explorar_contos')));
      await Pasarela.asentar(tester);
      final lista =
          tester.widget<CuentosListScreen>(find.byType(CuentosListScreen));
      expect(lista.initialCursoId, 'curso_5_6');
      expect(lista.semanaDestacada, (mes: 2, semana: 1));
    });
  }

  test('as 1.000 rutinas citan o conto da súa semana, non a asemblea', () {
    // A6: el texto de casa nombraba la asamblea por su nombre interno.
    final dias = jsonDecode(
        File('assets/content/calendario/calendario_dias.json')
            .readAsStringSync()) as List;
    final contos = (jsonDecode(
            File('assets/content/cuentos/historias_progresivas.json')
                .readAsStringSync()) as List)
        .cast<Map>()
        .where((c) => c['semanaSugerida'] != null);
    final titulo = {
      for (final c in contos)
        '${c['cursoId']}-${c['mesNumero']}-${c['semanaSugerida']}':
            c['titulo'] as Map,
    };
    final malos = <String>[];
    for (final d in dias.cast<Map>()) {
      final clave = d['fechaClave'] as String;
      final curso = clave.substring(0, clave.indexOf('-mes'));
      final t = titulo['$curso-${d['mesNumero']}-${d['semanaNumero']}'];
      for (final l in ['gl', 'es']) {
        final r = (d['familias']['rutinaFogar'] as Map)[l] as String;
        if (t == null || !r.contains('«${t[l]}»')) {
          malos.add('$clave $l');
        }
        if (r.contains('Asemblea de') || r.contains('Asamblea de')) {
          malos.add('$clave $l: cita a asemblea');
        }
      }
    }
    expect(malos, isEmpty, reason: malos.take(10).join('\n'));
  });
}
