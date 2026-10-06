import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/core/widgets/aviso_contenido_ilegible.dart';
import 'package:descubre_con_lua/data/models/asamblea_primeiro_ciclo_model.dart';
import 'package:descubre_con_lua/data/models/asamblea_segundo_ciclo_model.dart';
import 'package:descubre_con_lua/data/models/como_funciona_o_conto_model.dart';
import 'package:descubre_con_lua/data/models/cuento_model.dart';
import 'package:descubre_con_lua/data/models/ponte_ao_dia_model.dart';
import 'package:descubre_con_lua/features/cuentos/views/cuento_viewer_screen.dart';
import 'package:descubre_con_lua/features/familias/portal_familias_screen.dart';
import 'package:descubre_con_lua/features/familias/views/ponte_ao_dia_screen.dart';
import 'package:descubre_con_lua/features/juega/views/asamblea_player_screen.dart';

import '../helpers/pasarela.dart';

/// Lote L8: lo que Frank pidió tras probar la build de L7.
///
/// 1. Para la criatura que llega nueva a 4-5 o 5-6 (eligió la opción A): lo
///    que cada orden de la asamblea da por sabido, en el reproductor («Antes
///    da orde») y en casa («Ponte ao día»).
/// 2. Una explicación breve de cómo funciona el cuento, para quien lo abre por
///    primera vez.
void main() {
  final p = Pasarela();
  setUpAll(p.cargar);
  tearDownAll(p.limpar);

  late PonteAoDia ponte;
  setUpAll(() {
    ponte = PonteAoDia.fromRaw(File(PonteAoDia.assetPath).readAsStringSync());
  });

  group('Ponte ao día: os datos', () {
    const cursos = [
      'curso_0_2',
      'curso_2_3',
      'curso_3_4',
      'curso_4_5',
      'curso_5_6'
    ];
    const meses = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6];
    const cursoDe = {
      '0_2': 'curso_0_2',
      '2_3': 'curso_2_3',
      '4_infantil': 'curso_3_4',
      '5_infantil': 'curso_4_5',
      '6_infantil': 'curso_5_6',
    };

    test('ningunha orde dá por sabida unha palabra do seu mes ou de despois',
        () {
      final fallos = <String>[];
      var ordes = 0;
      for (final f in Directory('assets/content')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) =>
              f.path.contains('asambleas_') && f.path.endsWith('.json'))) {
        final a = jsonDecode(f.readAsStringSync()) as Map;
        final curso = cursoDe[a['tramo'] ?? a['nivel']]!;
        final cando = (cursos.indexOf(curso), meses.indexOf(a['mes'] as int));
        for (final fase in a['fases'] as List) {
          for (final c in (fase as Map)['comandosL3'] as List? ?? const []) {
            final palabras = ponte.daOrde((c as Map)['id'] as String);
            if (palabras.isNotEmpty) ordes++;
            for (final w in palabras) {
              final dela = (cursos.indexOf(w.cursoId), meses.indexOf(w.mes));
              final antes = dela.$1 < cando.$1 ||
                  (dela.$1 == cando.$1 && dela.$2 < cando.$2);
              if (!antes) fallos.add('${c['id']}: ${w.en} (${w.cursoId})');
            }
          }
        }
      }
      expect(fallos, isEmpty, reason: fallos.join('\n'));
      expect(ordes, greaterThan(80), reason: 'o cruce quedou baleiro');
    });

    test('a revisión a man está aplicada', () {
      Iterable<String> ids(String orde) => ponte.daOrde(orde).map((w) => w.id);
      // Coinciden na letra e non no sentido.
      expect(ids('cmd.outubro.6i.01'), isNot(contains('ring')));
      expect(ids('cmd.outubro.6i.01'), isNot(contains('rough')));
      expect(ids('cmd.outubro.6i.03'), isNot(contains('ring')));
      expect(ids('cmd.xaneiro.5i.03'), isNot(contains('back')));
      expect(ids('cmd.maio.4i.03'), isNot(contains('high')));
      expect(ids('cmd.maio.4i.03'), isNot(contains('low')));
      expect(ids('cmd.maio.6i.01'), isNot(contains('tap')));
      expect(ids('cmd.maio.6i.03'), isNot(contains('stick')));
      expect(ids('cmd.marzo.6i.01'), isNot(contains('plant')));
      expect(ponte.palabras.keys, isNot(contains('4_5.novembro.s1.steps')));
      // Os xestos de 0-2 fanse co bebé: aquí non pode quedar ningún.
      for (final w in ponte.palabras.values) {
        expect(w.xesto.gl, isNot(contains('bebé')), reason: w.id);
        expect(w.xesto.es, isNot(contains('bebé')), reason: w.id);
      }
      // E o exemplo da propuesta, na orde en que se di.
      expect(ponte.daOrde('cmd.outubro.5i.01').map((w) => w.en),
          ['Hop', 'Squirrel', 'Collect', 'Chestnut']);
    });

    test('cada palabra leva o seu xesto en galego e castelán', () {
      for (final w in ponte.palabras.values) {
        expect(w.xesto.gl.trim(), isNotEmpty, reason: w.id);
        expect(w.xesto.es.trim(), isNotEmpty, reason: w.id);
        expect(w.gl.trim(), isNotEmpty, reason: w.id);
        expect(w.es.trim(), isNotEmpty, reason: w.id);
      }
    });

    test('en días de dúas ou tres', () {
      List<int> tamanos(int n) => PonteAoDiaScreen.enDias(List.filled(n, 0))
          .map((d) => d.length)
          .toList();
      expect(tamanos(0), isEmpty);
      expect(tamanos(1), [1]);
      expect(tamanos(4), [2, 2]);
      expect(tamanos(8), [3, 3, 2]);
      expect(tamanos(11), [3, 3, 3, 2]);
      expect(tamanos(12), [3, 3, 3, 3]);
    });
  });

  group('Antes da orde, no reprodutor', () {
    Future<void> abrir(
        WidgetTester tester, List<FaseAsamblea> fases, AppLanguage lang,
        {Size tamano = const Size(360, 780),
        double escala = 1.0,
        PonteAoDia? ponteAoDia}) async {
      tester.view.physicalSize = tamano;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(escala)),
          child: child!,
        ),
        // Unha clave nova cada vez: sen ela, a asemblea seguinte herdaría o
        // estado da anterior (as súas pantallas e por onde ía).
        home: AsambleaPlayerScreen(
          key: UniqueKey(),
          fases: fases,
          subtitulo: 'proba',
          language: lang,
          audioService: p.audio,
          ponteAoDia: ponteAoDia,
        ),
      ));
      await tester.pumpAndSettle();
    }

    Future<void> seguinteFase(WidgetTester tester) async {
      await tester.tap(find.byKey(const ValueKey('player_fase_seguinte')));
      await tester.pumpAndSettle();
    }

    for (final lang in AppLanguage.deInterfaz) {
      final gl = lang == AppLanguage.gl;

      testWidgets('vai xusto antes do núcleo, palabra a palabra (${lang.code})',
          (tester) async {
        final a = p.contenido.getAsambleaByMesYNivelSync(
            10, NivelEducativoSegundoCiclo.infantil5)!;
        // O martes da primeira semana: só a primeira orde.
        final dia =
            p.contenido.getProgresionSync('segundo_ciclo.5')!.dia(1, 2)!;
        await abrir(tester, dia.aplicarA(a.fases), lang, ponteAoDia: ponte);

        await seguinteFase(tester);
        expect(find.byKey(const ValueKey('antes_da_orde')), findsNothing);
        await seguinteFase(tester);
        expect(find.byKey(const ValueKey('antes_da_orde')), findsOneWidget);
        expect(find.text(gl ? 'Antes da orde' : 'Antes de la orden'),
            findsOneWidget);
        expect(find.text(ponte.texto('reprodutor', 'guia').resolve(lang)),
            findsOneWidget);

        // Hop, Squirrel, Collect, Chestnut: unha cada vez, coas frechas.
        String conta() => tester
            .widget<Text>(find.byKey(const ValueKey('antes_da_orde_conta')))
            .data!;
        expect(conta(), '1 / 4');
        expect(find.text('Hop'), findsOneWidget);
        expect(
            tester
                .widget<IconButton>(
                    find.byKey(const ValueKey('antes_da_orde_anterior')))
                .onPressed,
            isNull);
        for (final en in ['Squirrel', 'Collect', 'Chestnut']) {
          await tester
              .tap(find.byKey(const ValueKey('antes_da_orde_seguinte')));
          await tester.pumpAndSettle();
          expect(find.text(en), findsOneWidget);
        }
        expect(conta(), '4 / 4');
        expect(
            tester
                .widget<IconButton>(
                    find.byKey(const ValueKey('antes_da_orde_seguinte')))
                .onPressed,
            isNull);
        // O significado e o xesto, na lingua da app.
        final castana = ponte.daOrde('cmd.outubro.5i.01').last;
        expect(find.text(gl ? castana.gl : castana.es), findsOneWidget);
        expect(
            find.textContaining(castana.xesto.resolve(lang)), findsOneWidget);

        // E despois, o núcleo coa orde.
        await seguinteFase(tester);
        expect(find.byKey(const ValueKey('antes_da_orde')), findsNothing);
        expect(find.text('Hop like a squirrel and collect the chestnuts'),
            findsOneWidget);
      });

      testWidgets('sen palabras de antes non aparece (${lang.code})',
          (tester) async {
        // 0-2 anos: o primeiro curso, nada que dar por sabido.
        final a = p.contenido
            .getAsambleaPrimeiroCicloSync(10, TramoPrimeiroCiclo.lactantes0a2)!;
        expect(ponte.dasFases(a.fases), isEmpty);
        await abrir(tester, a.fases, lang, ponteAoDia: ponte);
        for (var i = 0; i < a.fases.length - 1; i++) {
          expect(find.byKey(const ValueKey('antes_da_orde')), findsNothing);
          await seguinteFase(tester);
        }
        expect(find.byKey(const ValueKey('antes_da_orde')), findsNothing);
      });
    }

    // A pantalla non ten desprazamento: ten que caber, en todas as
    // asembleas que dan algo por sabido —as de 2.º ciclo e as cinco ordes de
    // 2-3 anos— e coas palabras todas, no móbil de 360 x 640 e coa letra do
    // sistema a 1,3. E ningunha letra por baixo de 12.
    for (final lang in AppLanguage.deInterfaz) {
      for (final escala in [1.0, 1.3]) {
        testWidgets(
            'cabe a 360 x 640 en ${lang.code} a $escala, palabra por palabra',
            (tester) async {
          const mesesDoCurso = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6];
          final asembleas = <(String, List<FaseAsamblea>)>[
            for (final nivel in NivelEducativoSegundoCiclo.values)
              for (final mes in mesesDoCurso)
                if (p.contenido.getAsambleaByMesYNivelSync(mes, nivel)
                    case final a?)
                  (a.id, a.fases),
            for (final tramo in TramoPrimeiroCiclo.values)
              for (final mes in mesesDoCurso)
                if (p.contenido.getAsambleaPrimeiroCicloSync(mes, tramo)
                    case final a?)
                  (a.id, a.fases),
          ];
          expect(asembleas, hasLength(50), reason: '30 de 2.º e 20 de 1.º');
          final fallos = <String>[];
          var vistas = 0;
          var de2a3 = 0;
          for (final (id, fases) in asembleas) {
            final palabras = ponte.dasFases(fases);
            if (palabras.isEmpty) continue;
            if (id.contains('2_3')) de2a3 += palabras.length;
            await abrir(tester, fases, lang,
                tamano: const Size(360, 640),
                escala: escala,
                ponteAoDia: ponte);
            final nucleo = fases
                .indexWhere((f) => f.tipo == TipoFaseAsamblea.coreTprChallenge);
            for (var i = 0; i < nucleo; i++) {
              await seguinteFase(tester);
            }
            expect(find.byKey(const ValueKey('antes_da_orde')), findsOneWidget,
                reason: id);
            for (var i = 0; i < palabras.length; i++) {
              final erro = tester.takeException();
              if (erro != null) {
                fallos.add('$id ${palabras[i].en}: $erro');
              }
              final minima = _letraMinima(
                  tester, find.byKey(const ValueKey('antes_da_orde')));
              if (minima < 12) {
                fallos.add('$id ${palabras[i].en}: letra '
                    '${minima.toStringAsFixed(1)} px');
              }
              vistas++;
              if (i < palabras.length - 1) {
                await tester
                    .tap(find.byKey(const ValueKey('antes_da_orde_seguinte')));
                await tester.pumpAndSettle();
              }
            }
          }
          expect(fallos, isEmpty, reason: fallos.join('\n'));
          expect(vistas, greaterThan(200));
          // As cinco ordes de 2-3 anos, unha palabra cada unha.
          expect(de2a3, 5);
        });
      }
    }
  });

  group('Ponte ao día, na casa', () {
    Future<void> abrirPortal(WidgetTester tester, AppLanguage lang) async {
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
          calendario: p.store,
          agora: Pasarela.agora,
        ),
      ));
      await Pasarela.asentar(tester);
    }

    Future<void> idade(WidgetTester tester, String curso) async {
      await tester.tap(find.byKey(const ValueKey('selector_idade')).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('idade_$curso')));
      await Pasarela.asentar(tester);
    }

    for (final lang in AppLanguage.deInterfaz) {
      final gl = lang == AppLanguage.gl;

      testWidgets(
          'a porta en Hoxe, só se hai algo que poñer ao día '
          '(${lang.code})', (tester) async {
        await abrirPortal(tester, lang);
        // 0-2 anos: o primeiro curso. Non hai porta.
        expect(find.byKey(const Key('hoxe_ponte_ao_dia')), findsNothing);

        await idade(tester, 'curso_4_5');
        final porta = find.byKey(const Key('hoxe_ponte_ao_dia'));
        await tester.scrollUntilVisible(porta, 200,
            scrollable: find.byType(Scrollable).first);
        final cantas = ponte.doMes('curso_4_5', 10).length;
        expect(
            find.descendant(
                of: porta,
                matching: find.textContaining(
                    '$cantas palabras de antes que ${gl ? 'as asembleas de outubro' : 'las asambleas de octubre'}')),
            findsOneWidget);

        await tester.tap(porta);
        await Pasarela.asentar(tester);
        expect(find.byType(PonteAoDiaScreen), findsOneWidget);
        expect(find.text(gl ? 'Ponte ao día' : 'Ponte al día'), findsOneWidget);
        // Os días de dúas ou tres, coas palabras de outubro.
        final dias = PonteAoDiaScreen.enDias(ponte.doMes('curso_4_5', 10));
        final lista = find.descendant(
            of: find.byKey(const ValueKey('ponte_ao_dia')),
            matching: find.byType(Scrollable));
        for (var d = 1; d <= dias.length; d++) {
          await tester.scrollUntilVisible(
              find.byKey(ValueKey('ponte_dia_$d')), 200,
              scrollable: lista);
          expect(find.byKey(ValueKey('ponte_dia_$d')), findsOneWidget);
        }
        // E nada máis: o último día remata a lista.
        await tester.drag(lista, const Offset(0, -3000));
        await tester.pumpAndSettle();
        expect(
            find.byKey(ValueKey('ponte_dia_${dias.length + 1}')), findsNothing);
      });

      testWidgets(
          'cambian o mes e a idade, e sen nada que poñer ao día '
          'dío (${lang.code})', (tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.temaFamilias,
          home: PonteAoDiaScreen(
            ponte: ponte,
            cursoId: 'curso_5_6',
            mes: 10,
            language: lang,
            audioService: p.audio,
          ),
        ));
        await tester.pumpAndSettle();
        final outubro = ponte.doMes('curso_5_6', 10);
        expect(find.byKey(ValueKey('ponte_palabra_${outubro.first.id}')),
            findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('ponte_mes_4')));
        await tester.pumpAndSettle();
        final abril = ponte.doMes('curso_5_6', 4);
        expect(find.byKey(ValueKey('ponte_palabra_${abril.first.id}')),
            findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('selector_idade')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('idade_curso_0_2')));
        await tester.pumpAndSettle();
        expect(
            find.byKey(const ValueKey('ponte_ao_dia_baleiro')), findsOneWidget);
        expect(
            find.textContaining(gl
                ? 'En abril, as asembleas de 0-2 anos'
                : 'En abril, las asambleas de 0-2 años'),
            findsOneWidget);
      });
    }
  });

  group('Como funciona o conto', () {
    late Cuento semPalabras;
    setUpAll(() {
      final banco = (jsonDecode(
              File('assets/content/cuentos/banco100_cuentos.json')
                  .readAsStringSync()) as List)
          .map((e) => Cuento.fromJson(Map<String, dynamic>.from(e as Map)));
      semPalabras =
          banco.firstWhere((c) => c.paginas.every((x) => x.palabras.isEmpty));
    });
    setUp(CuentoViewerScreen.despregarExplicacion);
    tearDown(() {
      CuentoViewerScreen.despregarExplicacion();
      ComoFuncionaOConto.olvidar();
    });

    String paso(CandoPaso cando, AppLanguage lang) => p.comoFunciona.pasos
        .firstWhere((x) => x.cando == cando)
        .texto
        .resolve(lang);

    Future<void> abrir(WidgetTester tester, Cuento conto, AppLanguage lang,
        {int? dia, bool conSemana = true, bool inxectar = true}) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final semana = conSemana && conto.semanaSugerida != null
          ? p.programa
              .curso(conto.cursoId)
              ?.semanaPorOrden(conto.mesNumero, conto.semanaSugerida!)
          : null;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.temaFamilias,
        home: CuentoViewerScreen(
          cuento: conto,
          language: lang,
          audioService: p.audio,
          semanaTpr: semana,
          dia: dia,
          comoFunciona: inxectar ? p.comoFunciona : null,
        ),
      ));
      await tester.pump();
      await tester.pump();
    }

    for (final lang in AppLanguage.deInterfaz) {
      testWidgets('desde un día: os pasos do día (${lang.code})',
          (tester) async {
        await abrir(tester, p.contoDaSemana, lang, dia: 2);
        expect(find.byKey(const ValueKey('como_funciona_o_conto')),
            findsOneWidget);
        expect(find.text(paso(CandoPaso.sempre, lang)), findsOneWidget);
        expect(find.text(paso(CandoPaso.conPalabras, lang)), findsOneWidget);
        expect(find.text(paso(CandoPaso.conDia, lang)), findsOneWidget);
        expect(find.text(paso(CandoPaso.senDia, lang)), findsNothing);
      });

      testWidgets('desde a biblioteca: as vinte da semana (${lang.code})',
          (tester) async {
        await abrir(tester, p.contoDaSemana, lang);
        expect(find.text(paso(CandoPaso.senDia, lang)), findsOneWidget);
        expect(find.text(paso(CandoPaso.conDia, lang)), findsNothing);
      });

      testWidgets(
          'un conto sen palabras en inglés non fala delas '
          '(${lang.code})', (tester) async {
        await abrir(tester, semPalabras, lang, conSemana: false);
        expect(find.text(paso(CandoPaso.sempre, lang)), findsOneWidget);
        expect(find.text(paso(CandoPaso.conPalabras, lang)), findsNothing);
        expect(find.text(paso(CandoPaso.conDia, lang)), findsNothing);
        expect(find.text(paso(CandoPaso.senDia, lang)), findsNothing);
      });

      testWidgets(
          'ocúltase, só na primeira páxina e sen gardar nada '
          '(${lang.code})', (tester) async {
        await abrir(tester, p.contoDaSemana, lang, dia: 2);
        await tester.tap(find.byKey(const ValueKey('como_funciona_ocultar')));
        await tester.pumpAndSettle();
        expect(find.text(paso(CandoPaso.sempre, lang)), findsNothing);
        expect(
            find.byKey(const ValueKey('como_funciona_abrir')), findsOneWidget);

        // Na seguinte páxina non está; ao volver, segue pregada.
        await tester.tap(find.byKey(const ValueKey('conto_seguinte')));
        await tester.pumpAndSettle();
        expect(
            find.byKey(const ValueKey('como_funciona_o_conto')), findsNothing);
        await tester.tap(find.byKey(const ValueKey('conto_anterior')));
        await tester.pumpAndSettle();
        expect(
            find.byKey(const ValueKey('como_funciona_abrir')), findsOneWidget);

        // Tocándoa, ábrese outra vez.
        await tester.tap(find.byKey(const ValueKey('como_funciona_abrir')));
        await tester.pumpAndSettle();
        expect(find.text(paso(CandoPaso.sempre, lang)), findsOneWidget);
      });

      testWidgets(
          'despois do primeiro conto, os seguintes ábrense pregados '
          '(${lang.code})', (tester) async {
        await abrir(tester, p.contoDaSemana, lang, dia: 2);
        expect(find.text(paso(CandoPaso.sempre, lang)), findsOneWidget);
        // Péchase o conto (sae da árbore) e ábrese outro.
        await tester.pumpWidget(const SizedBox());
        await abrir(tester, p.contoDaSemana, lang);
        expect(
            find.byKey(const ValueKey('como_funciona_abrir')), findsOneWidget);
        expect(find.text(paso(CandoPaso.sempre, lang)), findsNothing);
      });

      testWidgets('se non se pode ler, o visor dío (${lang.code})',
          (tester) async {
        ComoFuncionaOConto.sembrarFallo(Exception('asset ausente'));
        await abrir(tester, p.contoDaSemana, lang, inxectar: false);
        await tester.pump();
        expect(find.byType(AvisoContenidoIlegible), findsOneWidget);
        // E o conto lese igual.
        expect(find.byKey(const Key('texto_do_conto')), findsOneWidget);
      });
    }
  });
}

/// A letra máis pequena que se pinta dentro de [onde], xa coa escala do
/// sistema e co que encolle o FittedBox.
double _letraMinima(WidgetTester tester, Finder onde) {
  var minima = double.infinity;
  void visitar(RenderObject o) {
    if (o is RenderParagraph) {
      final texto = o.text.toPlainText().trim();
      if (texto.isNotEmpty && o.hasSize && !o.size.isEmpty) {
        final unidade = MatrixUtils.transformRect(
            o.getTransformTo(null), const Rect.fromLTWH(0, 0, 1, 1));
        final escala = math.min(unidade.width, unidade.height);
        void span(InlineSpan s, TextStyle? herdado) {
          final estilo = herdado == null ? s.style : herdado.merge(s.style);
          if (s is TextSpan) {
            if ((s.text ?? '').trim().isNotEmpty &&
                estilo?.fontFamily != 'MaterialIcons') {
              minima = math.min(
                  minima, o.textScaler.scale(estilo?.fontSize ?? 14) * escala);
            }
            for (final c in s.children ?? const <InlineSpan>[]) {
              span(c, estilo);
            }
          }
        }

        span(o.text, null);
      }
    }
    o.visitChildren(visitar);
  }

  visitar(tester.renderObject(onde));
  return minima;
}
