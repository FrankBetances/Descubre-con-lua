import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/steam_model.dart';
import 'package:descubre_con_lua/data/models/asamblea_primeiro_ciclo_model.dart';
import 'package:descubre_con_lua/data/models/asamblea_segundo_ciclo_model.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_screen.dart';
import 'package:descubre_con_lua/features/docentes/portal_docentes_screen.dart';
import 'package:descubre_con_lua/features/formacion/views/formacion_screen.dart';
import 'package:descubre_con_lua/features/juega/views/asamblea_player_screen.dart';
import 'package:descubre_con_lua/features/juega/views/capsulas_aula_screen.dart';
import 'package:descubre_con_lua/features/juega/views/unidades_list_screen.dart';
import 'package:descubre_con_lua/features/premios/widgets/lua_game_strip.dart';
import 'package:descubre_con_lua/features/steam/views/steam_sesion_guiada_screen.dart';

import '../helpers/pasarela.dart';

/// Lote L4 de la revisión de interfaz: «Hoxe» de la docente y el Modo Aula.
///
/// Lo que se arregla (A4): para empezar la asamblea había que pasar cinco
/// filtros, el nivel de la docente ocupaba lo alto y «Comezar a asemblea»
/// quedaba entre 1.755 y 2.035 px más abajo. Ahora la asamblea de hoy va
/// arriba con un botón, el grupo se elige en un chip, y el nivel y la racha
/// viven en «Eu».
///
/// Todo a 360 × 780 y con la Nunito de verdad: con la fuente de relleno de
/// los tests el texto es más ancho y estas medidas no dirían nada (regla 1c).
void main() {
  final p = Pasarela();
  setUpAll(p.cargar);
  tearDownAll(p.limpar);

  final venres = DateTime(2026, 10, 2, 10);
  final domingo = DateTime(2026, 10, 4, 10);

  Future<void> abrir(WidgetTester tester, Widget w) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.temaDocentes, home: w));
    await Pasarela.asentar(tester);
  }

  Widget portal(AppLanguage lang, DateTime agora) => PortalDocentesScreen(
        repository: p.contenido,
        audioService: p.audio,
        currentLanguage: lang,
        onToggleLanguage: () {},
        premios: p.premios,
        calendario: p.store,
        agora: agora,
        calendarioContenido: p.calendario,
      );

  String texto(WidgetTester tester, String clave) =>
      tester.widget<Text>(find.byKey(Key(clave))).data ?? '';

  /// Espera a que [f] aparezca. El calendario y la guía se leen del paquete
  /// con E/S de verdad: mientras tanto gira una rueda, y un `pumpAndSettle`
  /// a secas no termina nunca.
  Future<void> esperarA(WidgetTester tester, Finder f) async {
    for (var i = 0; i < 50 && f.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 60));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 60)));
    }
    expect(f, findsWidgets);
    await tester.pumpAndSettle();
  }

  for (final lang in AppLanguage.deInterfaz) {
    final gl = lang == AppLanguage.gl;

    testWidgets('Hoxe: a asemblea arriba e o botón sen baixar (${lang.code})',
        (tester) async {
      await abrir(tester, portal(lang, venres));

      expect(texto(tester, 'hoxe_aula_titulo'),
          gl ? 'A asemblea de hoxe' : 'La asamblea de hoy');
      expect(texto(tester, 'hoxe_aula_data'),
          gl ? 'VENRES, 2 DE OUTUBRO' : 'VIERNES, 2 DE OCTUBRE');

      // El botón, entero, por encima de la barra de pestañas: sin bajar.
      final boton = find.byKey(const Key('boton_asemblea_de_hoxe'));
      expect(boton, findsOneWidget);
      final barra = tester.getRect(find.byType(NavigationBar));
      expect(tester.getRect(boton).bottom, lessThanOrEqualTo(barra.top),
          reason: 'O botón queda baixo a barra de pestanas');

      // Las cuatro fases, con su nombre corto.
      for (final f in gl
          ? ['Saúdo', 'Enfoque', 'TPR', 'Calma']
          : ['Saludo', 'Enfoque', 'TPR', 'Calma']) {
        expect(
            find.descendant(
                of: find.byKey(const Key('hoxe_aula_fases')),
                matching: find.text(f)),
            findsOneWidget,
            reason: f);
      }

      // El nivel y la racha ya no están aquí: están en «Eu».
      expect(find.byType(LuaGameStrip), findsNothing);
      await tester.tap(find.byKey(const Key('pestana_eu')));
      await Pasarela.asentar(tester);
      expect(find.byType(LuaGameStrip), findsOneWidget);
    });

    testWidgets('as fases da tarxeta son as que abre o botón (${lang.code})',
        (tester) async {
      await abrir(tester, portal(lang, venres));
      final chips = tester
          .widgetList<Text>(find.descendant(
              of: find.byKey(const Key('hoxe_aula_fases')),
              matching: find.byType(Text)))
          .map((t) => t.data)
          .toList();
      await tester.tap(find.byKey(const Key('boton_asemblea_de_hoxe')));
      await Pasarela.asentar(tester);
      final player = tester
          .widget<AsambleaPlayerScreen>(find.byType(AsambleaPlayerScreen));
      // m:ss de cada fase, en el orden en que el reproductor las pasa.
      final duracions = [
        for (final f in player.fases)
          '${f.duracionSegundos ~/ 60}:'
              '${(f.duracionSegundos % 60).toString().padLeft(2, '0')}',
      ];
      expect(chips.where(duracions.contains).length, player.fases.length,
          reason: 'Tarxeta: $chips · reprodutor: $duracions');
      expect(player.dia?.semana, 1);
      expect(player.dia?.dia, 5);
    });

    testWidgets('a ciencia: cando toca, os días que non toca (${lang.code})',
        (tester) async {
      await abrir(tester, portal(lang, venres));
      final fila = find.byKey(const ValueKey('hoxe_aula_ciencia'));
      await tester.dragUntilVisible(
          fila, find.byKey(const Key('hoxe_docentes')), const Offset(0, -200));
      await tester.pumpAndSettle();
      // 0-2 años: «Brando e duro», el miércoles de la semana 2 de noviembre.
      expect(
          find.descendant(
              of: fila,
              matching: find.text(gl
                  ? 'Toca o mércores da semana 2 de novembro'
                  : 'Toca el miércoles de la semana 2 de noviembre')),
          findsOneWidget);
      await tester.tap(fila);
      await Pasarela.asentar(tester);
      final sesion = tester.widget<SteamSesionGuiadaScreen>(
          find.byType(SteamSesionGuiadaScreen));
      expect(sesion.unit.estadio, 'curso_0_2');
      expect(sesion.audiencia, SteamAudiencia.aula);
    });

    testWidgets('fin de semana: a asemblea do luns (${lang.code})',
        (tester) async {
      await abrir(tester, portal(lang, domingo));
      expect(texto(tester, 'hoxe_aula_titulo'),
          gl ? 'A asemblea do luns' : 'La asamblea del lunes');
    });

    testWidgets(
        'o grupo elixido en Hoxe abre o calendario dese curso '
        '(${lang.code})', (tester) async {
      await abrir(tester, portal(lang, venres));
      await tester.tap(find.byKey(const ValueKey('selector_idade')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('idade_curso_2_3')));
      await Pasarela.asentar(tester);
      await tester.tap(find.byKey(const Key('pestana_calendario')));
      await esperarA(tester, find.byKey(const Key('paginas_meses')));
      final calendario =
          tester.widget<CalendarioScreen>(find.byType(CalendarioScreen));
      expect(calendario.cursoInicial, 'curso_2_3');
      expect(calendario.esDocenteInicial, isTrue);
      // La tira de meses, a la vista: sin el párrafo de entrada ya no queda
      // por debajo del borde del marco.
      final meses = tester.getRect(find.byKey(const Key('selector_meses')));
      final paxinas = tester.getRect(find.byKey(const Key('paginas_meses')));
      expect(meses.bottom, lessThanOrEqualTo(paxinas.top),
          reason: 'A tira de meses queda cortada');
    });

    testWidgets('Recursos e Eu abren o que din (${lang.code})', (tester) async {
      await abrir(tester, portal(lang, venres));
      await tester.tap(find.byKey(const Key('pestana_recursos')));
      await Pasarela.asentar(tester);
      await tester.tap(find.byKey(const ValueKey('recurso_asembleas')));
      await Pasarela.asentar(tester);
      expect(find.byType(UnidadesListScreen), findsOneWidget);
      // El Modo Aula ya no lleva la tira de nivel encima de la asamblea.
      expect(find.byType(LuaGameStrip), findsNothing);
      await tester.tap(find.byKey(const ValueKey('boton_atras')).last);
      await Pasarela.asentar(tester);

      await tester.tap(find.byKey(const Key('pestana_eu')));
      await Pasarela.asentar(tester);
      await tester.tap(find.byKey(const ValueKey('eu_formacion')));
      // Las lecturas de formación del aula no tenían ninguna puerta.
      await esperarA(tester, find.byType(CapsulasAulaScreen));
      await tester.tap(find.byKey(const ValueKey('boton_atras')).last);
      await esperarA(tester, find.byKey(const ValueKey('eu_antes_de_entrar')));
      await tester.tap(find.byKey(const ValueKey('eu_antes_de_entrar')));
      // La guía se lee del paquete con E/S de verdad y, mientras, gira una
      // rueda: basta con ver que se abre la pantalla, sin esperar la calma.
      for (var i = 0;
          i < 10 && find.byType(FormacionScreen).evaluate().isEmpty;
          i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byType(FormacionScreen), findsOneWidget);
    });

    // El Modo Aula: «Comezar a asemblea» en la primera pantalla, con el
    // selector plegado, en los diez meses y en los cinco grupos. El contenido
    // cambia cada mes —el centro de interés, el material—, así que se mide
    // en todos y no solo en el de la captura.
    testWidgets(
        'Modo Aula: o botón na primeira pantalla, 10 meses × 5 grupos '
        '(${lang.code})', (tester) async {
      await abrir(
        tester,
        UnidadesListScreen(
          repository: p.contenido,
          audioService: p.audio,
          initialLanguage: lang,
          premios: p.premios,
          calendario: p.store,
          calendarioContenido: p.calendario,
        ),
      );
      const meses = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6];
      final lista = find.byType(Scrollable).first;

      Future<void> medir(String ciclo, String grupo, int mes) async {
        await tester.drag(lista, const Offset(0, 4000));
        await tester.pumpAndSettle();
        final resumo = texto(tester, 'resumo_aula_$ciclo');
        expect(resumo, startsWith('$grupo · '), reason: resumo);
        final boton = find.byKey(ValueKey('comezar_asemblea_$ciclo'));
        expect(boton, findsOneWidget, reason: '$ciclo $grupo mes $mes');
        expect(tester.getRect(boton).bottom, lessThanOrEqualTo(780),
            reason: '$ciclo $grupo mes $mes: o botón queda en '
                '${tester.getRect(boton).bottom}');
      }

      Future<void> elixir(String ciclo, Finder grupo, int mes) async {
        await tester.drag(lista, const Offset(0, 4000));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(ValueKey('selector_compacto_$ciclo')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(grupo);
        await tester.pumpAndSettle();
        await tester.tap(grupo);
        await tester.pumpAndSettle();
        // La tira de meses va de lado y solo construye lo que se ve: se
        // lleva al principio y se avanza hasta la pastilla.
        final tira = find.descendant(
            of: find.byKey(Key('tira_meses_$ciclo')),
            matching: find.byType(Scrollable));
        await tester.drag(tira, const Offset(3000, 0));
        await tester.pumpAndSettle();
        final pastilla =
            find.byKey(ValueKey(ciclo == '1c' ? '1c_mes_$mes' : 'mes_2c_$mes'));
        await tester.scrollUntilVisible(pastilla, 120, scrollable: tira);
        await tester.pumpAndSettle();
        await tester.tap(pastilla);
        await tester.pumpAndSettle();
        // Se pliega otra vez: la medida es con el selector cerrado.
        await tester
            .ensureVisible(find.byKey(ValueKey('selector_compacto_$ciclo')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(ValueKey('selector_compacto_$ciclo')));
        await tester.pumpAndSettle();
      }

      for (final tramo in TramoPrimeiroCiclo.values) {
        for (final mes in meses) {
          await elixir('1c', find.byKey(ValueKey('tramo_1c_$tramo')), mes);
          await medir('1c', tramo.etiquetaCorta.resolve(lang), mes);
        }
      }
      await tester.tap(find.byKey(const ValueKey('tab_segundo_ciclo')));
      await tester.pumpAndSettle();
      for (final nivel in NivelEducativoSegundoCiclo.values) {
        for (final mes in meses) {
          await elixir(
              '2c', find.byKey(ValueKey('clase_2c_${nivel.clave}')), mes);
          await medir('2c', nivel.etiquetaCorta.resolve(lang), mes);
        }
      }
    });
  }
}
