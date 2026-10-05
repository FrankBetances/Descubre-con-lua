import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/tpr_curriculum_scheduler.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/data/models/asamblea_segundo_ciclo_model.dart';
import 'package:descubre_con_lua/data/models/cuento_model.dart';
import 'package:descubre_con_lua/data/models/estrategia_model.dart';
import 'package:descubre_con_lua/data/models/lectura_model.dart';
import 'package:descubre_con_lua/data/models/xogos_fogar_observar_model.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_fogar_screen.dart';
import 'package:descubre_con_lua/features/cuentos/views/cuento_viewer_screen.dart';
import 'package:descubre_con_lua/features/cuentos/views/cuentos_list_screen.dart';
import 'package:descubre_con_lua/features/docentes/portal_docentes_screen.dart';
import 'package:descubre_con_lua/features/familias/views/xogos_fogar_screen.dart';
import 'package:descubre_con_lua/features/juega/views/asamblea_player_screen.dart';
import 'package:descubre_con_lua/features/lectura/views/aprender_a_ler_screen.dart';
import 'package:descubre_con_lua/features/seleccion/seleccion_portal_screen.dart';

/// Lote L0 de la revisión de interfaz: los errores que una familia o una
/// docente ven hoy. Un test por error, que falla con el código de antes.
void main() {
  late ContentRepository repo;
  late CalendarioStore store;
  late Directory dir;

  setUpAll(() async {
    Future<String> ler(String p) => File(p).readAsString();
    final loader = ContentAssetLoader(stringLoader: ler);
    repo = ContentRepository(loader: loader);
    await repo.initialize(unidadPaths: const [], capsulaPaths: const []);
    repo.addProgramaTpr(await ProgramaTpr.cargar(stringLoader: ler));
    // Todo lo que se lee de disco, aquí: dentro de un `testWidgets` el reloj
    // es falso y una lectura de disco no termina.
    await repo.loadCalendarioDias(cursoId: '');
    await repo.loadCuentos();
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('ux_l0_');
    store = CalendarioStore(overrideDirectory: dir.path);
    await store.cargar();
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  Future<void> pintar(WidgetTester tester, Widget w,
      {Size tamano = const Size(400, 2600)}) async {
    tester.view.physicalSize = tamano;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: w));
    await tester.pumpAndSettle();
  }

  group('C1 · el calendario de casa abre en el día que toca', () {
    // Abría siempre en septiembre: el 2 de octubre una familia leía el juego
    // de la semana 1 de septiembre sin ningún aviso.
    final casos = <({DateTime agora, String mes, String dia})>[
      (agora: DateTime(2026, 10, 2), mes: 'Outubro', dia: 'Venres · Semana 1'),
      (agora: DateTime(2027, 3, 17), mes: 'Marzo', dia: 'Mércores · Semana 3'),
      // Julio y agosto no son del curso: se prepara septiembre.
      (agora: DateTime(2027, 7, 15), mes: 'Setembro', dia: 'Luns · Semana 1'),
    ];
    for (final c in casos) {
      testWidgets('${c.agora.day}/${c.agora.month}: ${c.mes}, ${c.dia}',
          (tester) async {
        await pintar(
          tester,
          CalendarioFogarScreen(
            repository: repo,
            store: store,
            initialLanguage: AppLanguage.gl,
            initialCursoId: 'curso_0_2',
            audioService: MockOfflineAudioService(),
            agora: c.agora,
          ),
        );
        final chip = tester.widget<ChoiceChip>(find
            .ancestor(of: find.text(c.mes), matching: find.byType(ChoiceChip))
            .first);
        expect(chip.selected, isTrue, reason: 'el mes elegido');
        expect(find.text(c.dia), findsOneWidget, reason: 'el día elegido');
        // La pastilla del mes, a la vista: abrir en marzo con la tira parada
        // en septiembre-diciembre es abrir en marzo sin que se vea.
        final caja = tester.getRect(find.text(c.mes));
        expect(caja.left, greaterThanOrEqualTo(0));
        expect(caja.right, lessThanOrEqualTo(400));
      });
    }
  });

  Widget portalDocentes() => PortalDocentesScreen(
        repository: repo,
        audioService: MockOfflineAudioService(),
        currentLanguage: AppLanguage.gl,
        onToggleLanguage: () {},
        calendario: store,
      );

  group('C2 · la tarjeta del vocabulario dice lo que hay', () {
    // Prometía «Corpus 8.000 Palabras (BNC/COCA)», «bandas 1k-8k» y «CEFR
    // (A1-C2)»: son 3.995, de la banda 1k a la 4k, y el nivel no es del MCER.
    testWidgets('sin 8.000, sin BNC/COCA y sin CEFR', (tester) async {
      await pintar(tester, portalDocentes(), tamano: const Size(400, 6000));
      // Con L4 el vocabulario vive en la pestaña «Recursos».
      await tester.tap(find.byKey(const Key('pestana_recursos')));
      await tester.pumpAndSettle();
      expect(find.text('Vocabulario de uso habitual'), findsOneWidget);
      expect(find.textContaining('3.995 palabras'), findsOneWidget);
      for (final falso in ['8.000', 'BNC', 'CEFR']) {
        expect(find.textContaining(falso), findsNothing, reason: falso);
      }
    });
  });

  group('M2 · «Xoga con Lúa» en la interfaz gallega', () {
    testWidgets('el Portal Docentes y la elección de portal', (tester) async {
      await pintar(tester, portalDocentes(), tamano: const Size(400, 6000));
      await tester.tap(find.byKey(const Key('pestana_recursos')));
      await tester.pumpAndSettle();
      expect(find.text('Xoga con Lúa · Modo Aula'), findsOneWidget);
      expect(find.textContaining('Juega con Lúa'), findsNothing);

      await pintar(
        tester,
        SeleccionPortalScreen(
          repository: repo,
          audioService: MockOfflineAudioService(),
          currentLanguage: AppLanguage.gl,
          onToggleLanguage: () {},
        ),
        tamano: const Size(400, 4000),
      );
      expect(find.textContaining('Juega con Lúa'), findsNothing);
      // «asambleas» es castellano dentro de la frase gallega.
      expect(find.textContaining('asambleas'), findsNothing);
      expect(find.textContaining('Xoga con Lúa: asembleas guiadas'),
          findsOneWidget);
    });
  });

  group('M7 · el reproductor de la asamblea a 360 px', () {
    late ContentRepository completo;
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      completo = ContentRepository();
      await completo.initialize();
      // La tipografía real: con la de relleno de los tests, más ancha, se
      // parte cualquier etiqueta y el test no mide la app (regla 1c).
      final nunito = FontLoader('Nunito');
      for (final peso in ['Regular', 'SemiBold', 'Bold', 'ExtraBold']) {
        nunito.addFont(File('assets/fonts/Nunito-$peso.ttf')
            .readAsBytes()
            .then((b) => ByteData.view(b.buffer)));
      }
      await nunito.load();
    });

    testWidgets('ningún texto de la barra se parte, y volver tiene nombre',
        (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final a = completo.getAsambleaByMesYNivelSync(
          9, NivelEducativoSegundoCiclo.infantil4)!;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: AsambleaPlayerScreen(
          fases: a.fases,
          subtitulo: 'proba',
          language: AppLanguage.gl,
          audioService: MockOfflineAudioService(),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('player_fase_seguinte')));
      await tester.pumpAndSettle();

      // A 360 px, con un tercio de la fila, salía «Anteri / or».
      final barra = find
          .ancestor(
              of: find.byKey(const ValueKey('player_fase_seguinte')),
              matching: find.byType(Row))
          .first;
      final textos =
          find.descendant(of: barra, matching: find.byType(RichText));
      expect(textos, findsWidgets);
      for (final e in textos.evaluate()) {
        final p = e.renderObject! as RenderParagraph;
        // El mismo texto, al ancho que le tocó: ¿cuántas líneas ocupa?
        final medida = TextPainter(
          text: p.text,
          textDirection: TextDirection.ltr,
          textScaler: p.textScaler,
        )..layout(maxWidth: p.size.width + 0.5);
        expect(medida.computeLineMetrics(), hasLength(1),
            reason: p.text.toPlainText());
        medida.dispose();
      }
      // Volver sigue teniendo nombre, para quien no ve la flecha.
      expect(find.byTooltip('Fase anterior'), findsOneWidget);
      // Y se ve: el tema da fondo blanco a los OutlinedButton y el botón
      // pintaba encima su color de texto casi blanco (1,09:1). WCAG pide 3:1
      // para un control.
      final estilo = tester
          .widget<OutlinedButton>(
              find.byKey(const ValueKey('player_fase_anterior')))
          .style!;
      final fondo = estilo.backgroundColor?.resolve(const {}) ??
          AppTheme.lightTheme.outlinedButtonTheme.style!.backgroundColor!
              .resolve(const {})!;
      final frecha = estilo.foregroundColor!.resolve(const {})!;
      double luz(Color c) => c.computeLuminance();
      final contraste = (math.max(luz(fondo), luz(frecha)) + 0.05) /
          (math.min(luz(fondo), luz(frecha)) + 0.05);
      expect(contraste, greaterThanOrEqualTo(3.0));
      await tester.tap(find.byKey(const ValueKey('player_fase_anterior')));
      await tester.pumpAndSettle();
      final volver = tester.widget<OutlinedButton>(
          find.byKey(const ValueKey('player_fase_anterior')));
      expect(volver.onPressed, isNull, reason: 'de vuelta en la primera fase');
    });
  });

  group('C3 · «Que observar» en lugar de los botones de calificar', () {
    final lectura = ContidoLectura.fromRaw(
        File(ContidoLectura.assetPath).readAsStringSync());
    final xogos = ObservacionsXogosFogar.fromRaw(
        File(ObservacionsXogosFogar.assetPath).readAsStringSync());
    const calificar = ['[L] Logrado', '[A] Asistido', '[E] Explorando'];

    void comprobaPistas(List<dynamic> pistas, String onde) {
      expect(pistas.length, inInclusiveRange(2, 4), reason: onde);
      for (final p in pistas) {
        expect(p.gl.trim(), isNotEmpty, reason: onde);
        expect(p.es.trim(), isNotEmpty, reason: onde);
      }
    }

    test('cada actividad y cada juego trae de 2 a 4 pistas, en gl y es', () {
      for (final a in lectura.actividadesConciencia) {
        comprobaPistas(a.queObservar, a.id);
      }
      comprobaPistas(lectura.queObservarAlphabot, 'alphabot');
      comprobaPistas(lectura.queObservarCvc, 'cvc');
      comprobaPistas(lectura.queObservarPares, 'pares');
      expect(xogos.porXogo.keys, hasLength(10));
      for (final e in xogos.porXogo.entries) {
        comprobaPistas(e.value, e.key);
      }
    });

    testWidgets('Aprender a Ler: las cuatro pestañas, sin calificar',
        (tester) async {
      await pintar(
        tester,
        AprenderALerScreen(
          repository: repo,
          initialLanguage: AppLanguage.gl,
          contido: lectura,
        ),
        tamano: const Size(400, 3000),
      );
      final pestanas = find.byType(Tab);
      expect(pestanas, findsNWidgets(4));
      for (var i = 0; i < 4; i++) {
        await tester.tap(pestanas.at(i));
        await tester.pumpAndSettle();
        expect(find.text('Que observar'), findsWidgets, reason: 'pestana $i');
        for (final t in calificar) {
          expect(find.text(t), findsNothing, reason: 'pestana $i: $t');
        }
      }
    });

    testWidgets('Xogos no Fogar: sin calificar', (tester) async {
      await pintar(
        tester,
        XogosFogarScreen(initialLanguage: AppLanguage.gl, observacions: xogos),
        tamano: const Size(400, 12000),
      );
      expect(find.text('Que observar'), findsNWidgets(10));
      for (final t in calificar) {
        expect(find.text(t), findsNothing, reason: t);
      }
    });
  });

  group('C5 · los cuentos sin semana no dicen «Semana 1»', () {
    test('el modelo no inventa la semana', () {
      final c = Cuento.fromJson(const {
        'id': 'x',
        'cursoId': 'curso_0_2',
        'mesNumero': 2,
        'titulo': {'gl': 'T', 'es': 'T'},
        'paginas': [],
      });
      expect(c.semanaSugerida, isNull);
      expect(c.eDaSemana, isFalse);
      expect(c.mesCalendario, 10);
    });

    test('en cada mes, los cuentos de la semana van primero', () async {
      final lista = await repo.loadCuentos(cursoId: 'curso_0_2', mesNumero: 2);
      final semanais = lista.where((c) => c.eDaSemana).length;
      expect(semanais, greaterThan(0));
      expect(lista.take(semanais).every((c) => c.eDaSemana), isTrue,
          reason: lista.map((c) => c.id).join(', '));
    });

    testWidgets(
        'la biblioteca: el mes por su nombre y la semana solo donde la hay',
        (tester) async {
      await pintar(
        tester,
        CuentosListScreen(
          repository: repo,
          initialLanguage: AppLanguage.gl,
          audioService: MockOfflineAudioService(),
        ),
      );
      await tester.enterText(find.byType(TextField), 'cóxegas');
      await tester.pumpAndSettle();
      final carta = find.ancestor(
          of: find.text('Onde están as cóxegas de Lúa?'),
          matching: find.byType(Card));
      expect(carta, findsOneWidget);
      expect(find.descendant(of: carta, matching: find.text('Outubro')),
          findsOneWidget);
      expect(find.descendant(of: carta, matching: find.textContaining('emana')),
          findsNothing);
      expect(find.textContaining('Mes '), findsNothing);

      await tester.enterText(find.byType(TextField), 'Martiño e o nariz');
      await tester.pumpAndSettle();
      expect(find.text('Conto da semana 1'), findsWidgets);
    });

    testWidgets('el visor: la edad y el mes, sin CURSO_0_2 ni semana inventada',
        (tester) async {
      final conto = (await tester.runAsync(() => repo.loadCuentos()))!
          .firstWhere((c) => c.id == 'conto_003_onde_est_n_as_c_xega');
      await pintar(
        tester,
        CuentoViewerScreen(
          cuento: conto,
          language: AppLanguage.gl,
          audioService: MockOfflineAudioService(),
        ),
      );
      expect(find.text('0-2 anos · Outubro'), findsOneWidget);
      expect(find.textContaining('CURSO_'), findsNothing);
    });
  });

  group('A5 · nada de mecanismos cerebrales sin fuente', () {
    // «Sincronización vagal», «baixar o cortisol», «dar tempo ao córtex
    // prefrontal», «teoría da mente no lóbulo frontal»: sin fuente, rozando la
    // finalidad sanitaria que la app excluye. «Corteza» sola no: en los
    // cuentos es la de los árboles.
    final prohibido = RegExp(
      r'vagal|nervio vago|cortisol|c[óo]rtex|corteza prefrontal|prefrontal|'
      r'l[óo]bulo frontal|am[íi]gdala|dopamina|hipocamp|sinapto|neurobiol|'
      r'parasimp|cl[íi]nic',
      caseSensitive: false,
    );
    for (final f in [
      'assets/content/dinamicas_aula.json',
      'assets/content/estrategias_pedagogicas.json',
      'assets/content/calendario/calendario_dias.json',
      'assets/content/calendario/curriculo_50_meses.json',
    ]) {
      test(f, () {
        final halladas = prohibido
            .allMatches(File(f).readAsStringSync())
            .map((m) => m[0]!.toLowerCase())
            .toSet();
        expect(halladas, isEmpty);
      });
    }

    test('cada estrategia dice por qué funciona; la fuente, donde la hay', () {
      final lista = (jsonDecode(
              File('assets/content/estrategias_pedagogicas.json')
                  .readAsStringSync()) as List)
          .map((e) =>
              EstrategiaPedagogica.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      expect(lista, hasLength(5));
      for (final e in lista) {
        expect(e.porQueFunciona.gl.trim(), isNotEmpty, reason: e.id);
        expect(e.porQueFunciona.es.trim(), isNotEmpty, reason: e.id);
      }
      expect(lista.where((e) => e.fonte != null).map((e) => e.id).toSet(), {
        'est-espera-5s',
        'est-andamiaxe-bloom',
        'est-cero-pantallas',
        'est-bano-linguaxe',
      });
    });

    testWidgets('los juegos de casa, sin «clínico» ni «parasimpática»',
        (tester) async {
      for (final lang in AppLanguage.deInterfaz) {
        await pintar(
          tester,
          XogosFogarScreen(initialLanguage: lang),
          tamano: const Size(400, 12000),
        );
        expect(find.textContaining(prohibido), findsNothing, reason: lang.code);
      }
    });
  });
}
