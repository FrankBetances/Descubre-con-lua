import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/progress_service.dart';
import 'package:descubre_con_lua/core/storage/local_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/phonics_model.dart';
import 'package:descubre_con_lua/data/models/tpr_curriculum_scheduler.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/data/validators/content_validator.dart';
import 'package:descubre_con_lua/features/english/views/collocations_screen.dart';
import 'package:descubre_con_lua/features/english/views/english_hub_screen.dart';
import 'package:descubre_con_lua/features/english/views/fsrs_trainer_screen.dart';
import 'package:descubre_con_lua/features/english/views/listening_screen.dart';
import 'package:descubre_con_lua/features/english/views/palabras_do_traxecto_screen.dart';
import 'package:descubre_con_lua/features/lectura/views/phonix_quest_screen.dart';

/// El almacenamiento del repaso, en memoria: dentro de `testWidgets` el reloj
/// es falso y una escritura de disco de verdad no termina nunca.
class _AlmacenEnMemoria extends LocalStore {
  Map<String, dynamic>? gardado;

  _AlmacenEnMemoria() : super(fileName: ProgressService.defaultStoreFileName);

  @override
  Future<Map<String, dynamic>?> read() async => gardado == null
      ? null
      : jsonDecode(jsonEncode(gardado)) as Map<String, dynamic>;

  @override
  Future<bool> write(Map<String, dynamic> data) async {
    gardado = jsonDecode(jsonEncode(data)) as Map<String, dynamic>;
    return true;
  }

  @override
  Future<bool> clear() async {
    gardado = null;
    return true;
  }
}

/// Inmersión en inglés: que trabaje LAS PALABRAS DEL CURSO, no unas propias.
///
/// Lo que un widget test NO demuestra: las fuentes reales, la muesca, la
/// densidad del aparato y que el audio suene.
void main() {
  late ProgramaTpr programa;
  late String colocacionsJson;
  late PhonicsTaxonomy fonemas;
  late ContentRepository repo;

  // Un miércoles de la cuarta semana de septiembre: bloque C.
  final miercoles = DateTime(2026, 9, 23);

  setUpAll(() async {
    Future<String> ler(String p) => File(p).readAsString();
    programa = await ProgramaTpr.cargar(stringLoader: ler);
    colocacionsJson = await ler(CollocationsScreen.asset);
    repo = ContentRepository(loader: ContentAssetLoader(stringLoader: ler));
    repo.addProgramaTpr(programa);
    // Leída aquí, con E/S de verdad; la pantalla la encuentra ya en caché.
    fonemas = await repo.loadPhonicsTaxonomy();
  });

  /// Lleva el botón a la vista y lo toca. `scrollUntilVisible` solo garantiza
  /// que esté construido: al borde de la pantalla el toque caía fuera.
  Future<void> tocar(WidgetTester tester, Finder boton) async {
    // Con texto grande el botón puede quedar fuera de lo construido: primero
    // se baja hasta que exista, después se centra.
    if (boton.evaluate().isEmpty) {
      await tester.scrollUntilVisible(boton, 120,
          scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(boton);
    await tester.pumpAndSettle();
    await tester.tap(boton);
    await tester.pumpAndSettle();
  }

  /// Baja por la lista hasta que [f] esté construido y lo centra. Sin
  /// `skipOffstage`, una tarjeta que asoma por el borde no cuenta como
  /// encontrada y el arrastre se la salta.
  Future<void> irA(WidgetTester tester, Finder f, {double paso = 150}) async {
    await tester.scrollUntilVisible(f, paso,
        scrollable: find.byType(Scrollable).first, maxScrolls: 200);
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
  }

  /// Un texto por su clave, aunque quede por debajo del borde de la pantalla.
  Text texto(WidgetTester tester, String clave) =>
      tester.widget<Text>(find.byKey(Key(clave), skipOffstage: false));

  List<String> erroresDe(WidgetTester tester) {
    final fora = <String>[];
    for (var e = tester.takeException();
        e != null;
        e = tester.takeException()) {
      fora.add(e.toString().split('\n').first);
    }
    return fora;
  }

  Future<void> pintar(WidgetTester tester, Widget pantalla,
      {double escala = 1.0, Size tamano = const Size(360, 640)}) async {
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
      home: pantalla,
    ));
    await tester.pumpAndSettle();
  }

  Future<ProgressService> progresoBaleiro() async {
    final p = ProgressService(store: _AlmacenEnMemoria());
    await p.initialize();
    return p;
  }

  group('Os datos do repaso', () {
    test('o número da tarxeta é FNV-1a de 32 bits sen signo, e estable', () {
      // FNV-1a("a") = 0xe40c292c; sen o bit de signo, 0x640c292c.
      expect(idDaTarxetaDeRepaso('a'), 0x640c292c);
      expect(idDaTarxetaDeRepaso('a'), idDaTarxetaDeRepaso('a'));
    });

    test('as 4.000 palabras teñen 4.000 números distintos', () {
      final numeros = <int>{};
      for (final c in programa.cursos) {
        for (final p in c.palabrasEnOrde) {
          expect(numeros.add(idDaTarxetaDeRepaso(p.palabra.id)), isTrue,
              reason: p.palabra.id);
        }
      }
      expect(numeros, hasLength(4000));
    });

    test('palabrasEnOrde: as 800 de cada curso, de luns a xoves', () {
      for (final c in programa.cursos) {
        final todas = c.palabrasEnOrde;
        expect(todas, hasLength(800), reason: c.id);
        expect(todas.map((p) => p.dia).toSet(), {1, 2, 3, 4}, reason: c.id);
        expect(todas.first.mesCalendario, 9);
        expect(todas.last.mesCalendario, 6);
      }
    });

    test('introducidasAta: só as que xa saíron, nunca as do futuro', () {
      final c = programa.curso('curso_4_5')!;
      expect(c.introducidasAta((mesCalendario: 9, semana: 1, dia: 1)),
          hasLength(5));
      expect(c.introducidasAta((mesCalendario: 9, semana: 1, dia: 5)),
          hasLength(20));
      expect(c.introducidasAta((mesCalendario: 10, semana: 1, dia: 1)),
          hasLength(85));
      expect(c.introducidasAta((mesCalendario: 6, semana: 4, dia: 5)),
          hasLength(800));
      final mercores = c.introducidasAta((mesCalendario: 9, semana: 4, dia: 3));
      expect(mercores, hasLength(75));
      expect(mercores.last.palabra.id, c.planDoDia(9, 4, 3)!.newWords.last.id);
    });
  });

  group('Os 44 fonemas', () {
    test('24 consoantes e 20 vogais, cada un coa súa ficha', () {
      final inv = fonemas.inventario!;
      expect(inv.consoantes, hasLength(24));
      expect(inv.vogais, hasLength(20));
      expect(inv.total, 44);
      final ids = {for (final p in fonemas.phonemes) p.id};
      final usados = <String>{};
      final simbolos = <String>{};
      for (final f in [...inv.consoantes, ...inv.vogais]) {
        expect(ids.contains(f.fonema), isTrue, reason: f.fonema);
        expect(usados.add(f.fonema), isTrue, reason: 'repetido ${f.fonema}');
        expect(simbolos.add(f.ipa), isTrue, reason: 'repetido ${f.ipa}');
      }
      expect(inv.nota.hasParity, isTrue);
      // As fichas de máis son as que o texto di: ck, oa/ow e u_e.
      expect(ids.difference(usados), {'ph_ck', 'ph_oa_ow', 'ph_magic_u'});
      expect(inv.nota.gl, contains('${fonemas.phonemes.length} fichas'));
    });

    test('cada ficha ten exemplo, nome e guía nas dúas linguas', () {
      for (final p in fonemas.phonemes) {
        expect(p.exampleWord.en, isNotEmpty, reason: p.id);
        expect(p.exampleWord.gl, isNotEmpty, reason: p.id);
        expect(p.exampleWord.es, isNotEmpty, reason: p.id);
        expect(p.name.hasParity, isTrue, reason: p.id);
        expect(p.articulationGuide.hasParity, isTrue, reason: p.id);
      }
    });

    test('paridade e cero termos clínicos no ficheiro', () {
      final json = jsonDecode(
          File('assets/content/english/phonics_taxonomy.json')
              .readAsStringSync());
      final erros = <String>[];
      ContentValidator()
        ..checkBilingualParity(json, path: 'phonics', errors: erros)
        ..checkClinicalTerms(json, path: 'phonics', errors: erros);
      expect(erros, isEmpty, reason: erros.join('\n'));
    });
  });

  group('As colocacións', () {
    late List<Map<String, dynamic>> lista;
    setUpAll(() {
      lista = [
        for (final c
            in (jsonDecode(colocacionsJson) as Map)['collocations'] as List)
          Map<String, dynamic>.from(c as Map),
      ];
    });

    test('63, sen repetir ningunha, coa tradución nas dúas linguas', () {
      expect(lista, hasLength(63));
      expect(lista.map((c) => c['id']).toSet(), hasLength(63));
      expect(
          lista
              .map((c) => (c['fullCollocation'] as String).toLowerCase())
              .toSet(),
          hasLength(63));
      for (final c in lista) {
        expect((c['translation'] as Map)['gl'], isNotEmpty, reason: c['id']);
        expect((c['translation'] as Map)['es'], isNotEmpty, reason: c['id']);
        expect((c['typeLabel'] as Map)['gl'], isNotEmpty, reason: c['id']);
        expect(c['naturalContext'], isNotEmpty, reason: c['id']);
      }
    });

    test('nada de enfermidades nin do léxico que o modelo prohibe', () {
      const prohibidas = {
        'sick', 'cold', 'disease', 'fever', 'pain', 'hospital', 'doctor', //
        'medicine', 'scared', 'fear', 'bad', 'ugly', 'sad',
      };
      for (final c in lista) {
        // «cold» é válido como temperatura; o que non vale é «catch a cold».
        final texto =
            '${c['fullCollocation']} ${c['naturalContext']}'.toLowerCase();
        expect(texto.contains('catch a cold'), isFalse, reason: c['id']);
        final tokens = RegExp('[a-z]+')
            .allMatches(texto)
            .map((m) => m.group(0)!)
            .where((t) => t != 'cold');
        expect(tokens.where(prohibidas.contains), isEmpty, reason: c['id']);
      }
      final erros = <String>[];
      ContentValidator()
        ..checkBilingualParity(jsonDecode(colocacionsJson),
            path: 'colocacions', errors: erros)
        ..checkClinicalTerms(jsonDecode(colocacionsJson),
            path: 'colocacions', errors: erros);
      expect(erros, isEmpty, reason: erros.join('\n'));
    });
  });

  for (final lang in AppLanguage.deInterfaz) {
    for (final escala in [1.0, 1.8]) {
      final etiqueta = '${lang.code} a escala $escala';

      testWidgets('Repaso: primeiro as cinco de hoxe, e gárdase, en $etiqueta',
          (tester) async {
        final progreso = await progresoBaleiro();
        await pintar(
          tester,
          FsrsTrainerScreen(
            programa: programa,
            progreso: progreso,
            language: lang,
            agora: miercoles,
          ),
          escala: escala,
        );
        expect(erroresDe(tester), isEmpty, reason: 'desborda en $etiqueta');
        final curso = programa.curso('curso_0_2')!;
        final deHoxe = curso.planDoDia(9, 4, 3)!.newWords;
        // Cinco de hoxe + cinco das que saíron antes: dez na rolda.
        for (var i = 0; i < 10; i++) {
          final palabra = texto(tester, 'fsrs_palabra');
          if (i < 5) expect(palabra.data, deHoxe[i].en, reason: 'posto $i');
          await tocar(tester, find.byKey(const Key('fsrs_amosar')));
          expect(erroresDe(tester), isEmpty, reason: 'revelada, $etiqueta');
          await tocar(tester, find.byKey(const ValueKey('fsrs_nota_3')));
        }
        expect(find.byKey(const Key('fsrs_fin')), findsOneWidget);
        // As dez tarxetas están gardadas, coa palabra do catálogo.
        expect(progreso.getAllCards(), hasLength(10));
        for (final p in deHoxe) {
          final c = progreso.getCard(idDaTarxetaDeRepaso(p.id));
          expect(c?.lemma, p.en);
        }
        expect(erroresDe(tester), isEmpty);
      });
    }
  }

  testWidgets('Repaso: «Outra vez» vólvea ensinar ao final, unha vez',
      (tester) async {
    final progreso = await progresoBaleiro();
    await pintar(
      tester,
      FsrsTrainerScreen(
        programa: programa,
        progreso: progreso,
        agora: miercoles,
      ),
      tamano: const Size(400, 1400),
    );
    final primeira = texto(tester, 'fsrs_palabra').data;
    await tocar(tester, find.byKey(const Key('fsrs_amosar')));
    await tocar(tester, find.byKey(const ValueKey('fsrs_nota_1')));
    final vistas = <String?>[];
    while (find.byKey(const Key('fsrs_palabra')).evaluate().isNotEmpty) {
      vistas.add(texto(tester, 'fsrs_palabra').data);
      await tocar(tester, find.byKey(const Key('fsrs_amosar')));
      // Outra vez de novo: non volve unha terceira.
      await tocar(
          tester,
          find.byKey(ValueKey(
              vistas.last == primeira ? 'fsrs_nota_1' : 'fsrs_nota_3')));
    }
    expect(vistas, hasLength(10));
    expect(vistas.last, primeira);
    expect(vistas.where((v) => v == primeira), hasLength(1));
  });

  testWidgets('Repaso: ao día seguinte, as de onte xa non son novas',
      (tester) async {
    final progreso = await progresoBaleiro();
    Future<void> rolda(DateTime dia) async {
      await pintar(
        tester,
        FsrsTrainerScreen(
          key: ValueKey(dia),
          programa: programa,
          progreso: progreso,
          agora: dia,
        ),
        tamano: const Size(400, 1400),
      );
      while (find.byKey(const Key('fsrs_palabra')).evaluate().isNotEmpty) {
        await tocar(tester, find.byKey(const Key('fsrs_amosar')));
        await tocar(tester, find.byKey(const ValueKey('fsrs_nota_4')));
      }
    }

    await rolda(miercoles);
    expect(progreso.getAllCards(), hasLength(10));
    // O xoves: as cinco novas do xoves e outras cinco que nunca se viron.
    final xoves = DateTime(2026, 9, 24);
    await pintar(
      tester,
      FsrsTrainerScreen(
        key: const ValueKey('xoves'),
        programa: programa,
        progreso: progreso,
        agora: xoves,
      ),
      tamano: const Size(400, 1400),
    );
    final deXoves = programa.curso('curso_0_2')!.planDoDia(9, 4, 4)!.newWords;
    expect(texto(tester, 'fsrs_palabra').data, deXoves.first.en);
    expect(
        find.textContaining(
            RegExp('^80 palabras xa saíron neste curso · 10 xa repasadas')),
        findsOneWidget);
  });

  testWidgets('Repaso: outro curso trae as palabras DESE curso',
      (tester) async {
    final progreso = await progresoBaleiro();
    await pintar(
      tester,
      FsrsTrainerScreen(
        programa: programa,
        progreso: progreso,
        agora: miercoles,
      ),
      tamano: const Size(400, 1400),
    );
    for (final id in ['curso_5_6', 'curso_2_3']) {
      await tocar(tester, find.byKey(ValueKey('fsrs_curso_$id')));
      expect(texto(tester, 'fsrs_palabra').data,
          programa.curso(id)!.planDoDia(9, 4, 3)!.newWords.first.en,
          reason: id);
    }
  });

  for (final lang in AppLanguage.deInterfaz) {
    for (final escala in [1.0, 1.8]) {
      final etiqueta = '${lang.code} a escala $escala';

      testWidgets(
          'Escoita: as 16 frases do mes, e cambia co curso, en $etiqueta',
          (tester) async {
        await pintar(
          tester,
          ListeningScreen(
            programa: programa,
            language: lang,
            agora: miercoles,
          ),
          escala: escala,
        );
        expect(erroresDe(tester), isEmpty, reason: etiqueta);
        final curso = programa.curso('curso_0_2')!;
        final frases = [
          for (final p in curso.palabrasEnOrde)
            if (p.mesCalendario == 9 &&
                ListeningScreen.categorias.contains(p.palabra.category))
              p.palabra,
        ];
        expect(frases, hasLength(16));
        final contador = texto(tester, 'escoita_contador').data!;
        expect(contador, startsWith('Frase 1 de 16'));

        await tocar(tester, find.byKey(const Key('escoita_amosar')));
        expect(texto(tester, 'escoita_texto').data, '"${frases.first.en}"');
        expect(erroresDe(tester), isEmpty, reason: 'revelada, $etiqueta');

        await tocar(tester, find.byKey(const Key('escoita_seguinte')));
        expect(texto(tester, 'escoita_contador').data,
            startsWith('Frase 2 de 16'));
        expect(erroresDe(tester), isEmpty);
      });
    }
  }

  testWidgets('Escoita: outro curso e outro mes, outras frases',
      (tester) async {
    await pintar(
      tester,
      ListeningScreen(programa: programa, agora: miercoles),
      tamano: const Size(400, 1600),
    );
    await tocar(tester, find.byKey(const ValueKey('escoita_curso_curso_4_5')));
    await tocar(tester, find.byKey(const ValueKey('escoita_mes_3')));
    final esperada = programa
        .curso('curso_4_5')!
        .palabrasEnOrde
        .where((p) =>
            p.mesCalendario == 3 &&
            ListeningScreen.categorias.contains(p.palabra.category))
        .first
        .palabra;
    await tocar(tester, find.byKey(const Key('escoita_amosar')));
    expect(texto(tester, 'escoita_texto').data, '"${esperada.en}"');
  });

  for (final lang in AppLanguage.deInterfaz) {
    for (final escala in [1.0, 1.8]) {
      final etiqueta = '${lang.code} a escala $escala';
      testWidgets('Palabras do traxecto: a semana de hoxe, en $etiqueta',
          (tester) async {
        await pintar(
          tester,
          PalabrasDoTraxectoScreen(
            programa: programa,
            language: lang,
            agora: miercoles,
          ),
          escala: escala,
        );
        expect(erroresDe(tester), isEmpty, reason: etiqueta);
        final semana = programa.curso('curso_0_2')!.semana(9, 4)!;
        await irA(tester,
            find.byKey(const Key('traxecto_tema'), skipOffstage: false));
        expect(texto(tester, 'traxecto_tema').data, semana.tema.resolve(lang));
        for (final p in semana.palabras) {
          final fila = find.byKey(ValueKey('traxecto_palabra_${p.id}'),
              skipOffstage: false);
          await irA(tester, fila);
          expect(fila, findsOneWidget, reason: p.en);
        }
        expect(erroresDe(tester), isEmpty);
      });
    }
  }

  testWidgets('Palabras do traxecto: o buscador atopa en todos os cursos',
      (tester) async {
    await pintar(
      tester,
      PalabrasDoTraxectoScreen(programa: programa, agora: miercoles),
      tamano: const Size(400, 1600),
    );
    // Unha palabra de 5-6 anos, buscada desde o curso de 0-2.
    final obxectivo = programa.curso('curso_5_6')!.palabrasEnOrde[123].palabra;
    await tester.enterText(
        find.byKey(const Key('traxecto_busca')), obxectivo.en);
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('traxecto_palabra_${obxectivo.id}')),
        findsOneWidget);
    expect(find.textContaining('5-6 anos · '), findsWidgets);

    await tester.enterText(find.byKey(const Key('traxecto_busca')), 'zzzqx');
    await tester.pumpAndSettle();
    expect(texto(tester, 'traxecto_resultados').data,
        'Ningunha palabra coincide.');
  });

  for (final lang in AppLanguage.deInterfaz) {
    testWidgets('Fonemas: a conta sae do inventario, en ${lang.code}',
        (tester) async {
      await pintar(
        tester,
        PhonixQuestScreen(repository: repo, initialLanguage: lang),
        escala: 1.8,
      );
      expect(
          texto(tester, 'fonemas_total').data,
          lang == AppLanguage.gl
              ? '44 fonemas: 24 consoantes e 20 vogais · 47 fichas'
              : '44 fonemas: 24 consonantes y 20 vocales · 47 fichas');
      for (final id in ['ph_zh', 'ph_schwa', 'ph_ure', 'ph_magic_u']) {
        final ficha = find.byKey(ValueKey('fonema_$id'), skipOffstage: false);
        await irA(tester, ficha, paso: 400);
        expect(ficha, findsOneWidget, reason: id);
      }
      expect(erroresDe(tester), isEmpty);
    });

    testWidgets('Colocacións: as 63 do JSON, en ${lang.code}', (tester) async {
      await pintar(
        tester,
        CollocationsScreen(
          repository: repo,
          initialLanguage: lang,
          stringLoader: (_) => Future.value(colocacionsJson),
        ),
        escala: 1.8,
      );
      expect(texto(tester, 'colocacions_total').data, startsWith('63 '));
      // No orden en que se pintan: por tipo, co tipo na orde da súa primeira aparición.
      for (final id in ['col-1', 'col-11', 'col-63', 'col-40']) {
        final c = find.byKey(ValueKey('colocacion_$id'), skipOffstage: false);
        await irA(tester, c, paso: 400);
        expect(c, findsOneWidget, reason: id);
      }
      expect(erroresDe(tester), isEmpty);
    });

    testWidgets('O hub: os seis módulos e as cifras contadas, en ${lang.code}',
        (tester) async {
      await pintar(
        tester,
        EnglishHubScreen(repository: repo, initialLanguage: lang),
        escala: 1.8,
      );
      expect(
          texto(tester, 'ingles_cifras').data,
          lang == AppLanguage.gl
              ? '5 palabras novas ao día · 800 por curso · 4.000 de 0 a 6 anos'
              : '5 palabras nuevas al día · 800 por curso · 4.000 de 0 a 6 años');
      final lista = find.byType(Scrollable).first;
      for (final k in [
        'ingles_modulo_palabras',
        'ingles_modulo_repaso',
        'ingles_modulo_escoita',
        'ingles_modulo_colocacions',
        'ingles_modulo_fonemas',
        'ingles_modulo_frecuencia',
      ]) {
        final m = find.byKey(ValueKey(k), skipOffstage: false);
        await irA(tester, m);
        expect(m, findsOneWidget, reason: k);
      }
      expect(erroresDe(tester), isEmpty);

      // O módulo de escoita abre a pantalla nova, co programa.
      final escoita = find.byKey(const ValueKey('ingles_modulo_escoita'),
          skipOffstage: false);
      await tester.scrollUntilVisible(escoita, -150, scrollable: lista);
      await tocar(tester, escoita);
      expect(find.byType(ListeningScreen), findsOneWidget);
      expect(
          tester.widget<ListeningScreen>(find.byType(ListeningScreen)).programa,
          same(programa));
    });
  }
}
