// Lote L5 de la revisión de interfaz: un inicio, los nombres en JSON y una
// puerta por destino.
//
// - TalkBack puede pulsar los controles que agrupan su etiqueta: las dos
//   respuestas del inicio, GL/ES, la edad y el selector del aula.
// - Cada puerta de los dos portales abre una pantalla que se llama como ella:
//   el nombre del diccionario, o su forma corta si no cabe a 360 px. Antes
//   «Guías para a familia» abría «Academy», «Sons do inglés» abría «Phonix
//   Quest» y «Láminas», «Banco de Láminas».
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/core/widgets/cabecera.dart';
import 'package:descubre_con_lua/features/academy/widgets/selector_idioma_widget.dart';
import 'package:descubre_con_lua/features/bienvenida/welcome_screen.dart';
import 'package:descubre_con_lua/features/docentes/nomes_docentes.dart';
import 'package:descubre_con_lua/features/familias/nomes_familias.dart';
import 'package:descubre_con_lua/features/familias/widgets/selector_idade.dart';
import 'package:descubre_con_lua/features/juega/widgets/selector_compacto_aula.dart';
import 'package:descubre_con_lua/features/premios/widgets/lua_game_strip.dart';

import '../helpers/pasarela.dart';

Widget _app(Widget filla) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: Center(child: filla)),
    );

/// Lo que hace TalkBack con el doble toque: la acción `tap` del nodo, no un
/// toque en la pantalla. Si el nodo no la tiene, no pasa nada.
Future<void> _premerComoTalkBack(WidgetTester tester, Pattern etiqueta) async {
  final nodo = find.semantics.byLabel(etiqueta);
  expect(nodo, findsOneWidget, reason: 'No hay un nodo «$etiqueta».');
  final datos = nodo.evaluate().single.getSemanticsData();
  expect(datos.hasAction(SemanticsAction.tap), isTrue,
      reason: '«$etiqueta» se anuncia, pero TalkBack no lo puede pulsar.');
  tester.semantics.tap(nodo);
  await tester.pumpAndSettle();
}

void main() {
  group('TalkBack puede pulsar los controles que agrupan su etiqueta', () {
    testWidgets('las dos respuestas del inicio', (tester) async {
      final semantica = tester.ensureSemantics();
      var casa = 0;
      var escola = 0;
      await tester.binding.setSurfaceSize(const Size(360, 780));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: WelcomeScreen(
          currentLanguage: AppLanguage.gl,
          onToggleLanguage: () {},
          onCasa: () => casa++,
          onEscola: () => escola++,
          onShowCredits: () {},
        ),
      ));
      await tester.pumpAndSettle();

      await _premerComoTalkBack(tester, RegExp(r'^Na casa\.'));
      await _premerComoTalkBack(tester, RegExp(r'^Na escola\.'));
      expect((casa, escola), (1, 1));
      semantica.dispose();
    });

    testWidgets('GL/ES', (tester) async {
      final semantica = tester.ensureSemantics();
      final elixidas = <AppLanguage>[];
      await tester.pumpWidget(_app(Container(
        color: AppTheme.familias,
        child: SelectorIdiomaWidget(
          currentLanguage: AppLanguage.gl,
          onLanguageChanged: elixidas.add,
          compact: true,
        ),
      )));
      await _premerComoTalkBack(tester, AppLanguage.es.displayName);
      expect(elixidas, [AppLanguage.es]);
      semantica.dispose();
    });

    testWidgets('la edad de la criatura', (tester) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(_app(SelectorIdade(
        cursoId: 'curso_0_2',
        language: AppLanguage.gl,
        onCambiar: (_) {},
      )));
      await _premerComoTalkBack(tester, RegExp(r'^Idade: 0-2 anos'));
      expect(find.text('Que idade ten?'), findsOneWidget,
          reason: 'No se abre la hoja de las edades.');
      semantica.dispose();
    });

    testWidgets('el selector del aula', (tester) async {
      final semantica = tester.ensureSemantics();
      var veces = 0;
      await tester.pumpWidget(_app(SelectorCompactoDoAula(
        prefixoClave: '1c',
        resumo: '0-2 anos · outubro · semana 1 · luns',
        aberto: false,
        onAlternar: () => veces++,
        language: AppLanguage.gl,
        selectores: const SizedBox.shrink(),
      )));
      await _premerComoTalkBack(tester, RegExp(r'^Grupo e día:'));
      expect(veces, 1);
      semantica.dispose();
    });
  });

  group('Cada puerta abre una pantalla que se llama como ella', () {
    final p = Pasarela();
    setUpAll(p.cargar);
    tearDownAll(p.limpar);

    PantallaDaApp portal(String nome) =>
        p.pantallas.firstWhere((e) => e.nome == nome);

    // La puerta, por su clave, y el título que tiene que llevar la pantalla
    // que abre. `null` en la clave: la tira de Lúa, que no lleva una.
    final portas = <(String, String?, LocalizedString)>[
      ('explorar_familias', 'explorar_contos', NomesFamilias.contos),
      ('explorar_familias', 'explorar_ingles', NomesFamilias.ingles),
      (
        'explorar_familias',
        'explorar_movemento',
        NomesFamilias.movementoCabeceira
      ),
      ('explorar_familias', 'explorar_ler', NomesFamilias.ler),
      ('explorar_familias', 'explorar_laminas', NomesFamilias.laminas),
      ('explorar_familias', 'explorar_ciencia', NomesFamilias.cienciaCabeceira),
      ('guias_familias', 'guia_antes_de_empezar', NomesFamilias.antesDeEmpezar),
      ('guias_familias', 'guia_familia', NomesFamilias.guiasFamiliaCabeceira),
      ('guias_familias', 'guia_ingles_casa', NomesFamilias.inglesNaCasa),
      ('guias_familias', 'guia_premios', NomesFamilias.premios),
      (
        'recursos_docentes',
        'recurso_asembleas',
        NomesDocentes.asembleasCabeceira
      ),
      ('recursos_docentes', 'recurso_dinamicas', NomesDocentes.dinamicas),
      ('recursos_docentes', 'recurso_ciencia', NomesDocentes.cienciaCabeceira),
      (
        'recursos_docentes',
        'recurso_programacion',
        NomesDocentes.programacionCabeceira
      ),
      ('recursos_docentes', 'recurso_palabras', NomesDocentes.palabrasCurso),
      ('recursos_docentes', 'recurso_repaso', NomesDocentes.repaso),
      ('recursos_docentes', 'recurso_escoita', NomesDocentes.escoita),
      ('recursos_docentes', 'recurso_colocacions', NomesDocentes.colocacions),
      ('recursos_docentes', 'recurso_sons', NomesDocentes.sons),
      (
        'recursos_docentes',
        'recurso_vocabulario',
        NomesDocentes.vocabularioCabeceira
      ),
      (
        'recursos_docentes',
        'recurso_estratexias',
        NomesDocentes.estratexiasCabeceira
      ),
      (
        'eu_docente',
        'eu_antes_de_entrar',
        NomesDocentes.antesDeEntrarCabeceira
      ),
      ('eu_docente', 'eu_formacion', NomesDocentes.formacionCabeceira),
      ('eu_docente', null, NomesDocentes.premios),
    ];

    for (final lang in AppLanguage.deInterfaz) {
      for (final (pantalla, porta, titulo) in portas) {
        testWidgets('$pantalla · ${porta ?? 'tira de Lúa'} · ${lang.code}',
            (tester) async {
          tester.view.physicalSize = const Size(360, 780);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);
          final def = portal(pantalla);
          await tester.pumpWidget(MaterialApp(
            theme: def.portal == Portal.familias
                ? AppTheme.temaFamilias
                : AppTheme.lightTheme,
            home: def.construir(lang),
          ));
          await Pasarela.asentar(tester);

          final boton = porta == null
              ? find.byType(LuaGameStrip)
              : find.byKey(ValueKey(porta), skipOffstage: false);
          await tester.scrollUntilVisible(boton, 200,
              scrollable: find.byType(Scrollable).first);
          // `scrollUntilVisible` para en cuanto asoma: entera, para que el
          // toque caiga dentro.
          await tester.ensureVisible(boton);
          await tester.pumpAndSettle();
          await tester.tap(boton);
          // Fotogramas contados, no `pumpAndSettle`: varias de estas pantallas
          // leen un JSON del paquete y, mientras, gira un indicador que no
          // para nunca. La cabecera ya está desde el primer fotograma.
          for (var i = 0; i < 12; i++) {
            await tester.pump(const Duration(milliseconds: 100));
            await tester.runAsync(
                () => Future<void>.delayed(const Duration(milliseconds: 20)));
          }

          // La cabecera que se ve es la de la pantalla nueva: la del portal
          // queda debajo, fuera de escena.
          final cab = find.byType(Cabecera);
          expect(cab, findsOneWidget);
          final esperado = titulo.resolve(lang);
          expect(tester.widget<Cabecera>(cab).titulo, esperado);
          final parrafo = tester.renderObject<RenderParagraph>(
              find.descendant(of: cab, matching: find.text(esperado)).first);
          expect(parrafo.didExceedMaxLines, isFalse,
              reason: '«$esperado» no cabe en la cabecera a 360 px.');
        });
      }
    }
  });
}
