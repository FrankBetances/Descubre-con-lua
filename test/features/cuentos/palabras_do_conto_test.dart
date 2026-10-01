import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/cuento_model.dart';
import 'package:descubre_con_lua/data/models/tpr_curriculum_scheduler.dart';
import 'package:descubre_con_lua/features/cuentos/views/cuento_viewer_screen.dart';
import 'package:descubre_con_lua/features/cuentos/widgets/palabras_do_conto.dart';

/// Que o conto da semana e as palabras do día vaian da man.
///
/// Frank: «no tiene sentido un cuento que no tenga las palabras del dia». O
/// conto de cada semana leva as vinte palabras da súa semana; estes tests
/// comproban que o visor as atopa, que marca as de hoxe e que leva a docente
/// á páxina onde está cada unha. Co contido REAL, non cun inventado.
void main() {
  late ProgramaTpr programa;
  late List<Cuento> semanais;
  late List<Cuento> banco;

  setUpAll(() async {
    // Do disco AQUÍ, non dentro de testWidgets: alí o reloxo é falso e unha
    // lectura de disco de verdade non remata.
    programa = await ProgramaTpr.cargar(
      stringLoader: (path) => File(path).readAsString(),
    );
    List<Cuento> ler(String ruta) =>
        (jsonDecode(File(ruta).readAsStringSync()) as List)
            .map((e) => Cuento.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
    semanais = ler('assets/content/cuentos/historias_progresivas.json')
        .where((c) => c.paginas.any((p) => p.palabras.isNotEmpty))
        .toList();
    banco = ler('assets/content/cuentos/banco100_cuentos.json');
  });

  SemanaTpr semanaDe(Cuento c) =>
      programa.curso(c.cursoId)!.semanaPorOrden(c.mesNumero, c.semanaSugerida)!;

  test('o texto pártese polas comiñas inglesas, coas comiñas dentro', () {
    final t = PalabrasNoConto.trozos('Di “Hello!” e “Bye”.');
    expect(t.map((x) => x.texto), ['Di ', '“Hello!”', ' e ', '“Bye”', '.']);
    expect(t.map((x) => x.ingles), [false, true, false, true, false]);
    expect(PalabrasNoConto.trozos('Sen inglés.').single.ingles, isFalse);
    expect(PalabrasNoConto.clave(' Bee rhymes with tree! '),
        'bee rhymes with tree');
    expect(PalabrasNoConto.clave('I think so because…'), 'i think so because');
    expect(PalabrasNoConto.clave('How would you feel if...?'),
        'how would you feel if');
  });

  test(
      'os 200 contos da semana levan as súas 20 palabras, e cada día atopa as '
      'súas', () {
    expect(semanais, hasLength(200));
    for (final c in semanais) {
      final semana = semanaDe(c);
      expect(
          PalabrasNoConto(cuento: c, semana: semana).conPaxina(), hasLength(20),
          reason: '${c.id}: a semana trae 20 palabras');
      for (var d = 1; d <= 4; d++) {
        expect(PalabrasNoConto(cuento: c, semana: semana, dia: d).conPaxina(),
            hasLength(5),
            reason: '${c.id}, día $d: as cinco novas do día');
      }
      expect(PalabrasNoConto(cuento: c, semana: semana, dia: 5).conPaxina(),
          hasLength(20),
          reason: '${c.id}: o venres é o reto coas vinte');

      final palabras = PalabrasNoConto(cuento: c, semana: semana);
      for (final p in c.paginas) {
        expect(p.palabras.length, inInclusiveRange(1, 4),
            reason: '${c.id} p${p.numero}');
        for (final en in p.palabras) {
          // Do curso, co seu xesto: non a palabra de reserva da páxina.
          expect(palabras.palabraDaPaxina(p, en).id, isNotEmpty,
              reason: '${c.id} p${p.numero}: «$en»');
        }
        for (final lang in [AppLanguage.gl, AppLanguage.es]) {
          final ingles = PalabrasNoConto.trozos(p.texto.resolve(lang))
              .where((t) => t.ingles)
              .map((t) => PalabrasNoConto.clave(
                  t.texto.substring(1, t.texto.length - 1)))
              .toSet();
          expect(ingles, p.palabras.map(PalabrasNoConto.clave).toSet(),
              reason: '${c.id} p${p.numero} ${lang.code}: o inglés do texto '
                  'é o declarado na páxina');
        }
      }
    }
  });

  // As pastillas da cabeceira, unha por palabra: levan a chave
  // «ir_a_paxina_<palabra>».
  final pastillas = find.byWidgetPredicate((w) =>
      w.key is ValueKey<String> &&
      (w.key as ValueKey<String>).value.startsWith('ir_a_paxina_'));

  Future<void> abrir(WidgetTester tester, Widget pantalla) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: pantalla),
    );
    await tester.pumpAndSettle();
  }

  for (final lang in [AppLanguage.gl, AppLanguage.es]) {
    final isGl = lang == AppLanguage.gl;

    testWidgets(
        'aberto dende o día (${lang.code}): as cinco de hoxe, a súa páxina e '
        'a súa marca', (tester) async {
      final c = semanais.firstWhere((c) =>
          c.cursoId == 'curso_5_6' &&
          c.mesNumero == 8 &&
          c.semanaSugerida == 2);
      final semana = semanaDe(c);
      await abrir(
        tester,
        CuentoViewerScreen(
          cuento: c,
          language: lang,
          audioService: MockOfflineAudioService(),
          semanaTpr: semana,
          dia: 1,
        ),
      );

      expect(find.byKey(const Key('palabras_do_conto')), findsOneWidget);
      expect(
          find.text(isGl
              ? 'AS 5 PALABRAS DE HOXE ESTÁN NESTE CONTO'
              : 'LAS 5 PALABRAS DE HOY ESTÁN EN ESTE CUENTO'),
          findsOneWidget);
      final deHoxe =
          PalabrasNoConto(cuento: c, semana: semana, dia: 1).conPaxina();
      for (final item in deHoxe) {
        expect(find.byKey(ValueKey('ir_a_paxina_${item.palabra.en}')),
            findsOneWidget);
      }

      // Tocar unha leva á páxina onde está, e a vista vai con ela. A
      // primeira pastilla vese sen desprazar nada: se a vista non se move ao
      // tocala, a cabeceira segue á vista e o texto da páxina, fóra.
      final escollida = deHoxe.first;
      final chip = find.byKey(ValueKey('ir_a_paxina_${escollida.palabra.en}'));
      final cabeceira = find.byKey(const Key('palabras_do_conto'));
      expect(tester.getTopLeft(cabeceira).dy, greaterThan(0));
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(find.text('${escollida.paxina} / ${c.paginas.length}'),
          findsOneWidget);
      expect(tester.getTopLeft(cabeceira).dy, lessThan(0),
          reason: 'despois do salto vese a páxina, non a cabeceira');

      // Na páxina: a palabra coa súa voz, o seu significado e a marca de hoxe.
      final daPaxina = find.byKey(const Key('palabras_da_paxina'));
      await tester.ensureVisible(daPaxina);
      expect(
          find.descendant(
              of: daPaxina, matching: find.text(escollida.palabra.en)),
          findsOneWidget);
      expect(
          find.descendant(
              of: daPaxina,
              matching: find.textContaining(escollida.palabra.significado(lang),
                  findRichText: true)),
          findsWidgets);
      expect(
          find.descendant(
              of: daPaxina, matching: find.text(isGl ? 'Hoxe' : 'Hoy')),
          findsWidgets);
    });

    testWidgets(
        'dende a biblioteca (${lang.code}): as vinte da semana, pechadas ata '
        'que se pide', (tester) async {
      final c = semanais.firstWhere((c) => c.cursoId == 'curso_0_2');
      final semana = semanaDe(c);
      await abrir(
        tester,
        CuentoViewerScreen(
          cuento: c,
          language: lang,
          audioService: MockOfflineAudioService(),
          semanaTpr: semana,
        ),
      );

      expect(
          find.text(isGl
              ? 'AS 20 PALABRAS DA SEMANA ESTÁN NESTE CONTO'
              : 'LAS 20 PALABRAS DE LA SEMANA ESTÁN EN ESTE CUENTO'),
          findsOneWidget);
      // Vinte pastillas taparían o conto: empezan pechadas.
      expect(pastillas, findsNothing);
      await tester.tap(find.byKey(const Key('palabras_do_conto_abrir')));
      await tester.pumpAndSettle();
      expect(pastillas, findsNWidgets(20));
      // Sen día non hai «hoxe».
      expect(find.text(isGl ? 'Hoxe' : 'Hoy'), findsNothing);
    });
  }

  for (final escala in [1.0, 1.8]) {
    testWidgets(
        'a cabeceira non corta unha frase longa (5-6, a escala $escala)',
        (tester) async {
      // «We smell with our nose and taste with our tongue»: nove palabras. Un
      // ActionChip pintábaa nunha liña e cortábaa na app.
      final c = semanais.firstWhere((c) =>
          c.cursoId == 'curso_5_6' &&
          c.mesNumero == 2 &&
          c.semanaSugerida == 1);
      final semana = semanaDe(c);
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(escala)),
          child: child!,
        ),
        home: CuentoViewerScreen(
          cuento: c,
          language: AppLanguage.es,
          audioService: MockOfflineAudioService(),
          semanaTpr: semana,
          dia: 4,
        ),
      ));
      await tester.pumpAndSettle();

      final longa = PalabrasNoConto(cuento: c, semana: semana, dia: 4)
          .conPaxina()
          .firstWhere((i) => i.palabra.en.startsWith('We smell'));
      final etiqueta = find.text('${longa.palabra.en} · pág. ${longa.paxina}');
      expect(etiqueta, findsOneWidget);
      final paragrafo = tester.renderObject<RenderParagraph>(etiqueta);
      // O chip difuminaba o final nunha soa liña: iso é o «overflow shader».
      expect(paragrafo.debugHasOverflowShader, isFalse,
          reason: 'a etiqueta vese enteira, sen cortar');
      expect(paragrafo.didExceedMaxLines, isFalse,
          reason: 'a etiqueta vese enteira, sen cortar');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('un conto do banco, sen semana, lese coma sempre',
      (tester) async {
    final c = banco.first;
    expect(c.paginas.every((p) => p.palabras.isEmpty), isTrue);
    await abrir(
      tester,
      CuentoViewerScreen(
        cuento: c,
        language: AppLanguage.gl,
        audioService: MockOfflineAudioService(),
      ),
    );
    expect(find.byKey(const Key('palabras_do_conto')), findsNothing);
    expect(find.byKey(const Key('palabras_da_paxina')), findsNothing);
    expect(find.byKey(const Key('texto_do_conto')), findsOneWidget);
  });
}
