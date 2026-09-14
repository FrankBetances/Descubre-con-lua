import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/brand/lua_pixel.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/capsula_model.dart';
import 'package:descubre_con_lua/data/models/curricular_model.dart';
import 'package:descubre_con_lua/data/models/unidad_model.dart';
import 'package:descubre_con_lua/features/academy/views/capsula_detail_screen.dart';
import 'package:descubre_con_lua/features/juega/views/nota_para_casas_screen.dart';

/// Dónde aparece la gata dentro de una ACTIVIDAD, y dónde no.
///
/// Antes de esto, Lúa se pintaba en la bienvenida, en los premios, en el
/// calendario y en los créditos: los cuatro sitios, fuera de lo que la docente
/// y la familia están haciendo. Aquí se fija que entra en los dos sitios
/// elegidos —el cierre de la cápsula y la nota que cruza a las casas— y que no
/// se cuela donde el contenido no la pide.
void main() {
  const cierre = LocalizedString(
    gl: 'Son Lúa. Hoxe quédate cun só xesto.',
    es: 'Soy Lúa. Hoy quédate con un solo gesto.',
  );

  Capsula capsula({LocalizedString? luaDice}) => Capsula(
        id: 'test.capsula.01',
        bloqueId: 'desarrollo_comunicativo',
        orden: 1,
        titulo: const LocalizedString(gl: 'Título', es: 'Título'),
        subtitulo: const LocalizedString(gl: 'Subtítulo', es: 'Subtítulo'),
        tiempoLecturaMinutos: 3,
        icono: 'ear_sparkles',
        ideaClave: const LocalizedString(gl: 'Idea.', es: 'Idea.'),
        porQueImporta: const LocalizedString(gl: 'Porque.', es: 'Porque.'),
        queHacerEnCasa: const LocalizedString(gl: 'Nomea.', es: 'Nombra.'),
        ejemploCotidiano: const LocalizedString(gl: 'Mira.', es: 'Mira.'),
        luaDice: luaDice,
        afirmaciones: const [
          Afirmacion(
            id: 'a1',
            enunciado:
                LocalizedString(gl: 'Agardar axuda.', es: 'Esperar ayuda.'),
            esVerdadera: true,
            explicacion: LocalizedString(gl: 'Exacto.', es: 'Exacto.'),
          ),
        ],
        curriculo: const CurricularReference(
          normativa: 'Decreto 150/2022',
          etapa: 'educacion_infantil',
          ciclo: 'primeiro_ciclo_0_3',
          areas: ['area_1_crecemento_harmonia'],
          criteriosEvaluacion: ['CA1.1'],
        ),
        revision: const Revision(
          autor: 'Equipo Pedagóxico',
          revisorPedagogico: 'Revisor',
          fechaRevision: '2026-09-14',
          version: '1.0.0',
          aprobadoParaAula: true,
        ),
      );

  Future<void> montarLector(WidgetTester tester, Capsula c, AppLanguage lang) =>
      tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: CapsulaDetailScreen(capsula: c, initialLanguage: lang),
      ));

  group('el cierre de Lúa en el lector de cápsulas', () {
    testWidgets('va el ÚLTIMO, detrás de la reflexión', (tester) async {
      await montarLector(tester, capsula(luaDice: cierre), AppLanguage.gl);
      await tester.pumpAndSettle();

      // Las cuatro secciones: la gata no está en ninguna.
      for (var i = 0; i < 4; i++) {
        expect(find.byType(LuaPixel), findsNothing,
            reason: 'Lúa no pinta en la sección $i.');
        await tester.tap(find.text('Seguinte'));
        await tester.pumpAndSettle();
      }

      // La reflexión. La cápsula se cuenta como leída al responderla, así que
      // el cierre tiene que ir DESPUÉS: al revés, la gata despediría una
      // cápsula todavía sin terminar.
      expect(find.text('PARA PENSAR'), findsOneWidget);
      expect(find.byType(LuaPixel), findsNothing);
      await tester.tap(find.text('Verdadeiro'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Seguinte'));
      await tester.pumpAndSettle();

      expect(find.text('LÚA DI'), findsOneWidget);
      expect(find.byType(LuaPixel), findsOneWidget);
      expect(find.text(cierre.gl), findsOneWidget);
      // Es la última: el botón ya no invita a seguir.
      expect(find.text('Rematar'), findsOneWidget);
    });

    testWidgets('el cierre habla en la lengua elegida', (tester) async {
      await montarLector(tester, capsula(luaDice: cierre), AppLanguage.es);
      await tester.pumpAndSettle();

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Siguiente'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Verdadero'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      expect(find.text('LÚA DICE'), findsOneWidget);
      expect(find.text(cierre.es), findsOneWidget);
    });

    testWidgets('sin luaDice no se inventa una página', (tester) async {
      // Las cápsulas del aula todavía no traen cierre. Una página vacía con la
      // gata y sin nada que decir sería peor que no tener página.
      await montarLector(tester, capsula(), AppLanguage.gl);
      await tester.pumpAndSettle();

      for (var i = 0; i < 4; i++) {
        expect(find.text('Rematar'), findsNothing);
        await tester.tap(find.text('Seguinte'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Verdadeiro'));
      await tester.pumpAndSettle();

      // La reflexión es ya la última: no hay nada detrás.
      expect(find.text('Rematar'), findsOneWidget);
      expect(find.byType(LuaPixel), findsNothing);
      expect(find.text('LÚA DI'), findsNothing);
    });
  });

  group('la nota que cruza a las casas', () {
    /// Se lee del árbol de trabajo y no del paquete a propósito: aquí el
    /// contenido es el decorado —hace falta una unidad válida para montar la
    /// pantalla—, y quien comprueba que el contenido VIAJA en el APK es
    /// `test/data/bundle_real_test.dart`.
    Unidad unidadReal() => Unidad.fromJson(
          jsonDecode(File('assets/content/unidades/juega.mar.01.json')
              .readAsStringSync()) as Map<String, dynamic>,
        );

    for (final lang in AppLanguage.deInterfaz) {
      testWidgets('Lúa encabeza la nota en ${lang.code}', (tester) async {
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          home: NotaParaCasasScreen(unidad: unidadReal(), language: lang),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(LuaPixel), findsOneWidget,
            reason: 'La nota nombra a la gata y tiene que enseñarla.');
        // Y sigue siendo la nota: el mensaje para las familias manda.
        expect(find.text(NotaParaCasasScreen.titulo.resolve(lang)),
            findsOneWidget);
      });
    }
  });
}
