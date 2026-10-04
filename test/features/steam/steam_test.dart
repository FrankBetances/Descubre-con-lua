import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/audio/voice_id.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/steam_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/data/validators/content_validator.dart';
import 'package:descubre_con_lua/features/docentes/portal_docentes_screen.dart';
import 'package:descubre_con_lua/features/familias/portal_familias_screen.dart';
import 'package:descubre_con_lua/features/steam/views/steam_hub_screen.dart';
import 'package:descubre_con_lua/features/steam/views/steam_sesion_guiada_screen.dart';

/// STEAM · ciencia con las manos.
///
/// Nace de la primera versión del módulo, que llegó con un test que no
/// compilaba, un globo de látex y arroz crudo para criaturas de 3 años sin un
/// solo aviso, un «sin riesgo de asfixia» que se cortaba en pantalla y la
/// misma sesión de aula para las familias. Cada grupo de aquí comprueba que no
/// vuelva una de esas cosas.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fichero = File(ContentAssetLoader.steamAssetPath);
  final crudo = fichero.readAsStringSync();
  final validator = ContentValidator();

  List<dynamic> copia() => jsonDecode(crudo) as List<dynamic>;
  Map<String, dynamic> unidad(List<dynamic> banco, String nivel) =>
      banco.cast<Map<String, dynamic>>().firstWhere(
            (u) => u['nivelMadurativo'] == nivel,
          );
  List<SteamUnit> unidades() =>
      ContentAssetLoader(stringLoader: (_) async => crudo)
          .parseSteamUnits(crudo);

  group('Contenido', () {
    test('cinco unidades, una por curso, de I1 a I5', () {
      final u = unidades();
      expect(u.map((e) => e.nivelMadurativo), ['I1', 'I2', 'I3', 'I4', 'I5']);
      expect(u.map((e) => e.estadio), [
        'curso_0_2',
        'curso_2_3',
        'curso_3_4',
        'curso_4_5',
        'curso_5_6',
      ]);
    });

    test('el fichero real pasa el validador STEAM', () {
      final r = validator.validateSteamBankJson(copia(),
          sourcePath: ContentAssetLoader.steamAssetPath);
      expect(r.isValid, isTrue, reason: r.errors.join('\n'));
    });

    test('cada unidad trae la versión del aula y la de casa, distintas', () {
      for (final u in unidades()) {
        expect(u.aula.ciclo.consignaAdulto.gl, isNotEmpty);
        expect(u.hogar.ciclo.consignaAdulto.gl, isNotEmpty);
        expect(u.hogar.agrupamiento.gl, isNot(u.aula.agrupamiento.gl),
            reason: '${u.id}: la casa no es el aula con otro título');
      }
    });

    test('ningún material ni texto de la primera versión que era un riesgo',
        () {
      final todo = crudo.toLowerCase();
      for (final prohibido in [
        'látex',
        'arroz',
        'globo',
        'sin riesgo de asfixia',
        'sen risco de asfixia',
        'gorxa da criatura',
        'garganta de la criatura',
        'fonoarticula',
        'modelado fonador',
        'robot lúa',
      ]) {
        expect(todo.contains(prohibido), isFalse, reason: prohibido);
      }
    });

    test('ida y vuelta del modelo sin perder nada', () {
      final original = copia();
      final u = unidades();
      for (var i = 0; i < u.length; i++) {
        expect(jsonEncode(u[i].toJson()), jsonEncode(original[i]),
            reason: u[i].id);
      }
    });
  });

  group('El validador rechaza', () {
    ValidationResult validar(List<dynamic> banco) =>
        validator.validateSteamBankJson(banco);

    void rechaza(List<dynamic> banco, String contiene) {
      final r = validar(banco);
      expect(r.isValid, isFalse);
      expect(r.errors.join('\n'), contains(contiene));
    }

    test('un globo de látex en los materiales, a cualquier edad', () {
      final b = copia();
      final i3 = unidad(b, 'I3');
      (i3['aula']['materiales'] as List).add({
        'item': {
          'gl': 'Un globo de látex tensado',
          'es': 'Un globo de látex tensado',
        },
        'seguridadMayor4cm': true,
      });
      rechaza(b, 'forbidden material');
    });

    test('granos de arroz en la versión de casa', () {
      final b = copia();
      final i5 = unidad(b, 'I5');
      (i5['hogar']['materiales'] as List).add({
        'item': {'gl': 'Vinte grans de arroz', 'es': 'Veinte granos de arroz'},
        'seguridadMayor4cm': true,
      });
      rechaza(b, 'forbidden material');
    });

    test('un material pequeño aunque sea de 5 a 6 años', () {
      final b = copia();
      final i5 = unidad(b, 'I5');
      (i5['aula']['materiales'] as List).first['seguridadMayor4cm'] = false;
      rechaza(b, 'larger than 4 cm');
    });

    test('papeles cooperativos antes de los 3 años', () {
      final b = copia();
      final i1 = unidad(b, 'I1');
      i1['aula']['roles'] = [
        {
          'clave': 'exploradora',
          'nombre': {'gl': 'Exploradora', 'es': 'Exploradora'},
          'mision': {'gl': 'Aperta', 'es': 'Aprieta'},
        }
      ];
      rechaza(b, 'before 3 years');
    });

    test('una sesión de aula de 4 a 5 años sin papeles', () {
      final b = copia();
      unidad(b, 'I4')['aula']['roles'] = <dynamic>[];
      rechaza(b, 'at least two');
    });

    test('vocabulario de consulta', () {
      final b = copia();
      unidad(b, 'I3')['queObservar'][0]['gl'] =
          'Fonoarticula con vibración sostida';
      rechaza(b, 'clinical or assessment vocabulary');
    });

    test('una orden en inglés que la sesión no dice', () {
      final b = copia();
      (unidad(b, 'I2')['ordenesIngles'] as List).add({
        'en': 'Jump',
        'ipa': '/dʒʌmp/',
        'accion': {'gl': 'Saltar', 'es': 'Saltar'},
      });
      rechaza(b, 'is never said');
    });

    test('una orden que se dice en gallego y no en castellano', () {
      final b = copia();
      final i2 = unidad(b, 'I2');
      (i2['ordenesIngles'] as List).add({
        'en': 'Jump',
        'ipa': '/dʒʌmp/',
        'accion': {'gl': 'Saltar', 'es': 'Saltar'},
      });
      for (final v in ['aula', 'hogar']) {
        final t = i2[v]['ciclo']['experimenta']['consignaAdulto'];
        t['gl'] = '${t['gl']} Di “Jump”.';
      }
      final errores = validar(b).errors.join('\n');
      expect(errores, contains('is never said in the aula session in es'));
      expect(errores, contains('is never said in the hogar session in es'));
      expect(errores, isNot(contains('session in gl')));
    });

    test('una unidad sin la versión de casa', () {
      final b = copia();
      unidad(b, 'I1').remove('hogar');
      rechaza(b, 'hogar');
    });

    test('un ciclo curricular que no es el de la edad', () {
      final b = copia();
      unidad(b, 'I4')['curriculo']['ciclo'] = 'primeiro_ciclo_0_3';
      rechaza(b, 'does not match nivel I4');
    });

    test('una ruta de audio escrita a mano', () {
      final b = copia();
      unidad(b, 'I1')['ordenesIngles'][0]['audioAsset'] =
          'assets/voice/en_slow_a9a58d8c_4.m4a';
      rechaza(b, 'must not hard-code asset paths');
    });

    test('una unidad sin aviso de seguridad', () {
      final b = copia();
      unidad(b, 'I2').remove('seguridad');
      rechaza(b, 'seguridad.aviso');
    });
  });

  group('Voz', () {
    // Lo que la sesión pinta con altavoz tiene que estar en el corpus, con el
    // MISMO identificador que calcula la pantalla. Si no, el altavoz no sale
    // nunca y nadie sabe por qué.
    final corpus = jsonDecode(File('voice-corpus.json').readAsStringSync())
        as Map<String, dynamic>;
    final ids = {
      for (final e in corpus['corpus'] as List) (e as Map)['id'] as String
    };

    test('toda la prosa con altavoz está en el corpus, en gl y en es', () {
      for (final u in unidades()) {
        final textos = [
          u.avisoSeguridad,
          ...u.queObservar,
          for (final a in SteamAudiencia.values) ...[
            u.variante(a).agrupamiento,
            ...u.variante(a).ciclo.prosa,
          ],
        ];
        for (final t in textos) {
          for (final lang in AppLanguage.deInterfaz) {
            final id = voiceAssetId(VoiceStyle.tutor, t.resolve(lang), lang);
            expect(ids, contains(id), reason: '${u.id}: ${t.resolve(lang)}');
          }
        }
      }
    });

    test('cada orden en inglés está en el corpus con su estilo', () {
      for (final u in unidades()) {
        for (final o in u.ordenesIngles) {
          final id = voiceAssetId(estiloIngles(o.en), o.en, AppLanguage.en);
          expect(ids, contains(id), reason: '${u.id}: ${o.en}');
        }
      }
    });
  });

  group('Repositorio', () {
    ContentRepository repo() => ContentRepository(
        loader: ContentAssetLoader(stringLoader: (_) async => crudo));

    test('carga, busca por curso, por id y por nivel, y se vacía', () async {
      final r = repo();
      expect(r.steamUnits, isEmpty);
      await r.loadSteamUnits();
      expect(r.steamUnitCount, 5);
      expect(
          r.getSteamUnitsByEstadio('curso_3_4').single.id, 'I3-ACUSTICA-001');
      expect(r.getSteamUnitById('I4-OPTICA-001')?.nivelMadurativo, 'I4');
      expect(r.getSteamUnitByNivel('i5')?.id, 'I5-LOGICA-001');
      r.clear();
      expect(r.steamUnits, isEmpty);
    });

    test('initialize() también carga STEAM', () async {
      final r = repo();
      await r.initialize(
        unidadPaths: const [],
        capsulaPaths: const [],
        asambleaSegundoCicloPaths: const [],
      );
      expect(r.steamUnitCount, 5);
    });

    test('un fichero ilegible queda anotado, no se traga', () async {
      final r = ContentRepository(
        loader: ContentAssetLoader(
          stringLoader: (_) async => throw const FileSystemException('roto'),
        ),
      );
      expect(await r.loadSteamUnits(), isEmpty);
      expect(r.loadErrors.first.assetPath, ContentAssetLoader.steamAssetPath);
    });
  });

  group('Pantallas', () {
    late MockOfflineAudioService audio;
    late ContentRepository repo;

    setUp(() async {
      audio = MockOfflineAudioService();
      repo = ContentRepository(
          loader: ContentAssetLoader(stringLoader: (_) async => crudo));
      await repo.loadSteamUnits();
    });

    tearDown(() => audio.dispose());

    Future<void> pintar(WidgetTester tester, Widget w) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: w));
      await tester.pumpAndSettle();
    }

    Finder enLaLista(String key) => find.byKey(ValueKey(key));

    Future<void> verTexto(WidgetTester tester, String texto,
        {String lista = 'steam_sesion_lista'}) async {
      await tester.scrollUntilVisible(find.text(texto), 250,
          scrollable: find.descendant(
              of: enLaLista(lista), matching: find.byType(Scrollable)));
      expect(find.text(texto), findsOneWidget);
    }

    testWidgets('el hub del aula abre filtrado por el curso de hoy',
        (tester) async {
      await pintar(
        tester,
        SteamHubScreen(
          repository: repo,
          audioService: audio,
          initialLanguage: AppLanguage.gl,
          audiencia: SteamAudiencia.aula,
          initialCursoId: 'curso_3_4',
        ),
      );
      expect(find.text('Para a aula'), findsOneWidget);
      expect(find.text('O son fai bailar a auga'), findsOneWidget);
      expect(find.text('Brando e duro'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('steam_filtro_todas')));
      await tester.pumpAndSettle();
      await verTexto(tester, 'A cuadrícula: programamos un robot',
          lista: 'steam_hub_lista');
    });

    testWidgets('el hub de casa enseña la versión de casa', (tester) async {
      await pintar(
        tester,
        SteamHubScreen(
          repository: repo,
          audioService: audio,
          initialLanguage: AppLanguage.es,
          audiencia: SteamAudiencia.hogar,
          initialCursoId: 'curso_0_2',
        ),
      );
      expect(find.text('Para casa'), findsOneWidget);
      expect(find.text('Blando y duro'), findsOneWidget);
      expect(find.textContaining('Tú y la criatura, sentados en el suelo.'),
          findsOneWidget);

      final abrir = find.byKey(const ValueKey('abrir_steam_I1-MATERIA-001'));
      await tester.ensureVisible(abrir);
      await tester.pumpAndSettle();
      await tester.tap(abrir);
      await tester.pumpAndSettle();
      expect(find.byType(SteamSesionGuiadaScreen), findsOneWidget);
      await verTexto(tester, 'Una cesta o una caja de zapatos');
    });

    // Hoy hay una unidad por curso, pero nada impide añadir otra: el filtro
    // hacía un chip por unidad, y dos chips con la misma clave rompen la fila.
    testWidgets('un curso con dos unidades sigue teniendo un solo chip',
        (tester) async {
      final i3 = repo.getSteamUnitByNivel('I3')!;
      repo.addSteamUnit(
          SteamUnit.fromJson({...i3.toJson(), 'id': 'I3-ACUSTICA-002'}));
      await pintar(
        tester,
        SteamHubScreen(
          repository: repo,
          audioService: audio,
          initialLanguage: AppLanguage.gl,
          audiencia: SteamAudiencia.aula,
          initialCursoId: 'curso_3_4',
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
          find.byKey(const ValueKey('steam_filtro_curso_3_4')), findsOneWidget);
      await tester.scrollUntilVisible(
          find.byKey(const ValueKey('abrir_steam_I3-ACUSTICA-002')), 250,
          scrollable: find.descendant(
              of: enLaLista('steam_hub_lista'),
              matching: find.byType(Scrollable)));
      expect(find.byKey(const ValueKey('abrir_steam_I3-ACUSTICA-002')),
          findsOneWidget);
    });

    testWidgets('la sesión del aula: seguridad, papeles, pasos, pausa y pistas',
        (tester) async {
      final i3 = repo.getSteamUnitByNivel('I3')!;
      await pintar(
        tester,
        SteamSesionGuiadaScreen(
          unit: i3,
          audiencia: SteamAudiencia.aula,
          audioService: audio,
          initialLanguage: AppLanguage.gl,
        ),
      );

      // La seguridad va arriba, antes que nada.
      expect(find.byKey(const ValueKey('steam_seguridade')), findsOneWidget);
      expect(find.text(i3.avisoSeguridad.gl), findsOneWidget);

      await verTexto(tester, 'Tamborileira');
      await verTexto(tester, 'Observadora da auga');

      // La pausa de silencio cuenta de verdad.
      await tester.scrollUntilVisible(
          find.byKey(const ValueKey('steam_pausa')), 250,
          scrollable: find.descendant(
              of: enLaLista('steam_sesion_lista'),
              matching: find.byType(Scrollable)));
      await tester.tap(find.byKey(const ValueKey('steam_pausa')));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('En silencio… quedan 4 s'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      expect(find.textContaining('Feito.'), findsOneWidget);

      // Las pistas se abren una a una.
      expect(find.text(i3.aula.ciclo.pistaN1.gl), findsNothing);
      await tester.scrollUntilVisible(
          find.byKey(const ValueKey('steam_pista_1')), 250,
          scrollable: find.descendant(
              of: enLaLista('steam_sesion_lista'),
              matching: find.byType(Scrollable)));
      await tester.tap(find.byKey(const ValueKey('steam_pista_1')));
      await tester.pumpAndSettle();
      expect(find.text(i3.aula.ciclo.pistaN1.gl), findsOneWidget);

      // El currículo solo en el aula.
      await tester.scrollUntilVisible(
          find.byKey(const ValueKey('steam_curriculo')), 250,
          scrollable: find.descendant(
              of: enLaLista('steam_sesion_lista'),
              matching: find.byType(Scrollable)));
      expect(find.text('Decreto 150/2022'), findsOneWidget);

      // Nada de registro: ni botones ni la palabra.
      expect(find.text('Logrado'), findsNothing);
      expect(find.textContaining('1-Tap'), findsNothing);
      expect(find.textContaining('ZERO-SCREEN'), findsNothing);
    });

    testWidgets('la orden en inglés suena con su grabación', (tester) async {
      final i3 = repo.getSteamUnitByNivel('I3')!;
      await pintar(
        tester,
        SteamSesionGuiadaScreen(
          unit: i3,
          audiencia: SteamAudiencia.aula,
          audioService: audio,
          initialLanguage: AppLanguage.es,
        ),
      );
      await tester.scrollUntilVisible(
          find.byKey(const ValueKey('steam_ordes')), 250,
          scrollable: find.descendant(
              of: enLaLista('steam_sesion_lista'),
              matching: find.byType(Scrollable)));
      await tester.pumpAndSettle();
      final listen = find.descendant(
          of: find.byKey(const ValueKey('steam_ordes')),
          matching: find.text('Listen'));
      expect(listen, findsOneWidget);
      await tester.tap(listen);
      await tester.pumpAndSettle();
      expect(
        audio.callLog,
        contains(
            'playAsset:${englishVoiceAssetPath(VoiceStyle.slow, 'Listen')}'),
      );
    });

    testWidgets('la sesión de casa no trae currículo ni papeles de aula',
        (tester) async {
      final i4 = repo.getSteamUnitByNivel('I4')!;
      await pintar(
        tester,
        SteamSesionGuiadaScreen(
          unit: i4,
          audiencia: SteamAudiencia.hogar,
          audioService: audio,
          initialLanguage: AppLanguage.gl,
        ),
      );
      await verTexto(tester, i4.hogar.materiales.first.item.gl);
      expect(find.text('Titiriteira'), findsNothing);
      await tester.drag(find.byType(ListView), const Offset(0, -4000));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('steam_curriculo')), findsNothing);
    });

    testWidgets('Portal Docentes: la tarjeta abre la versión del aula',
        (tester) async {
      await pintar(
        tester,
        PortalDocentesScreen(
          repository: repo,
          audioService: audio,
          currentLanguage: AppLanguage.gl,
          onToggleLanguage: () {},
        ),
      );
      final boton = find.text('Abrir STEAM');
      await tester.scrollUntilVisible(boton, 250,
          scrollable: find.byType(Scrollable).first);
      await tester.ensureVisible(boton);
      await tester.pumpAndSettle();
      await tester.tap(boton);
      await tester.pumpAndSettle();
      final hub = tester.widget<SteamHubScreen>(find.byType(SteamHubScreen));
      expect(hub.audiencia, SteamAudiencia.aula);
      // El curso de «Hoxe na aula», que por defecto es el de 0 a 2 años.
      expect(hub.initialCursoId, 'curso_0_2');
      expect(find.text('Brando e duro'), findsOneWidget);
    });

    testWidgets('Portal Familias: la edad y la versión de casa',
        (tester) async {
      await pintar(
        tester,
        PortalFamiliasScreen(
          repository: repo,
          audioService: audio,
          currentLanguage: AppLanguage.es,
          onToggleLanguage: () {},
        ),
      );
      // La edad se elige una vez, arriba, en el chip de la portada…
      await tester.tap(find.byKey(const ValueKey('selector_idade')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('idade_curso_3_4')));
      await tester.pumpAndSettle();

      // …y viaja hasta «Ciencia con las manos», en Explorar.
      await tester.tap(find.byKey(const Key('pestana_explorar')));
      await tester.pumpAndSettle();
      expect(find.text('Ciencia con las manos'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('explorar_ciencia')));
      await tester.pumpAndSettle();
      final hub = tester.widget<SteamHubScreen>(find.byType(SteamHubScreen));
      expect(hub.audiencia, SteamAudiencia.hogar);
      expect(hub.initialCursoId, 'curso_3_4');
      expect(find.text('El sonido hace bailar el agua'), findsOneWidget);
      expect(find.text('Blando y duro'), findsNothing);
    });
  });
}
