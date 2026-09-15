import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/capsula_model.dart';
import 'package:descubre_con_lua/data/models/curricular_model.dart';
import 'package:descubre_con_lua/data/models/unidad_model.dart' show Revision;
import 'package:descubre_con_lua/features/academy/views/capsula_detail_screen.dart';

/// El defecto que no se ve: en release un desborde no pinta franjas amarillas,
/// el texto simplemente se corta. Estas pantallas son las que más texto seguido
/// llevan de toda la app, y el galego estira más que el castellano.
void main() {
  Capsula capsulaLarga() => const Capsula(
        id: 'test.larga',
        bloqueId: 'desarrollo_comunicativo',
        orden: 1,
        titulo: LocalizedString(
          gl: 'Como se aprende a falar: o baño de lingua e as primeiras quendas',
          es: 'Cómo se aprende a hablar: el baño de lenguaje y los primeros '
              'turnos',
        ),
        subtitulo: LocalizedString(gl: 'Subtítulo', es: 'Subtítulo'),
        tiempoLecturaMinutos: 3,
        icono: 'ear_sparkles',
        ideaClave: LocalizedString(
          gl: 'A fala comeza moito antes da primeira palabra. O cerebro '
              'infantil constrúe a linguaxe a partir das conversas cálidas, '
              'miradas compartidas e palabras agarimosas que escoita acotío.',
          es: 'El habla comienza mucho antes de la primera palabra. El cerebro '
              'infantil construye el lenguaje a partir de las conversaciones '
              'cálidas, miradas compartidas y palabras afectuosas.',
        ),
        porQueImporta: LocalizedString(gl: 'Porque si.', es: 'Porque sí.'),
        queHacerEnCasa: LocalizedString(gl: 'Nomea.', es: 'Nombra.'),
        ejemploCotidiano: LocalizedString(gl: 'Mira.', es: 'Mira.'),
        luaDice: LocalizedString(
          gl: 'Son Lúa. Hoxe quédate cun só xesto: nomea o que estea a mirar '
              'e despois cala mentres contas ata cinco. Ese silencio é a súa '
              'quenda, e é o máis difícil de todo o que che pedín hoxe.',
          es: 'Soy Lúa. Hoy quédate con un solo gesto: nombra lo que esté '
              'mirando y después calla mientras cuentas hasta cinco. Ese '
              'silencio es su turno.',
        ),
        curriculo: CurricularReference(
          normativa: 'Decreto 150/2022',
          etapa: 'educacion_infantil',
          ciclo: 'primeiro_ciclo_0_3',
          areas: ['area_1_crecemento_harmonia'],
          criteriosEvaluacion: ['CA1.1'],
        ),
        revision: Revision(
          autor: 'Dr. Frank Betances',
          revisorPedagogico: 'Equipo Pedagóxico Vigo',
          fechaRevision: '2026-09-12',
          version: '1.0.0',
          aprobadoParaAula: true,
        ),
        afirmaciones: [
          Afirmacion(
            id: 'a1',
            enunciado: LocalizedString(
              gl: 'Esperar en silencio durante uns segundos despois de falar '
                  'axuda a que o neno tome a iniciativa comunicativa.',
              es: 'Esperar en silencio durante unos segundos después de hablar '
                  'ayuda a que el niño tome la iniciativa comunicativa.',
            ),
            esVerdadera: true,
            explicacion: LocalizedString(
              gl: 'Exacto: a pausa atenta é a invitación máis respectuosa para '
                  'que a crianza intente comunicarse cos seus recursos.',
              es: 'Exacto: la pausa atenta es la invitación más respetuosa.',
            ),
          ),
        ],
      );

  for (final lang in AppLanguage.deInterfaz) {
    testWidgets('el lector cabe con la escala de texto grande en ${lang.code}',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
          child: CapsulaDetailScreen(
            capsula: capsulaLarga(),
            initialLanguage: lang,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Se recorren TODAS las páginas: un desborde puede estar en cualquiera.
      //
      // El bucle CONTESTA la afirmación en vez de pararse ahí. Mientras no lo
      // hacía, el recorrido moría en la página de la reflexión —el botón está
      // apagado hasta responder— y ninguna página posterior se miraba nunca:
      // el cierre de Lúa, que va detrás, quedaba fuera del único test que caza
      // desbordes.
      for (var i = 0; i < 10; i++) {
        final errores = <Object>[];
        while (true) {
          final e = tester.takeException();
          if (e == null) break;
          errores.add(e);
        }
        expect(errores, isEmpty,
            reason: 'La página $i del lector desborda en ${lang.code}.');

        final siguiente =
            find.text(lang == AppLanguage.gl ? 'Seguinte' : 'Siguiente');
        if (siguiente.evaluate().isEmpty) break;

        var boton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        if (boton.onPressed == null) {
          final verdadero =
              find.text(lang == AppLanguage.gl ? 'Verdadeiro' : 'Verdadero');
          if (verdadero.evaluate().isEmpty) break;
          await tester.tap(verdadero);
          await tester.pumpAndSettle();
          boton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
          if (boton.onPressed == null) break;
        }
        await tester.tap(siguiente);
        await tester.pumpAndSettle();
      }
    });
  }
}
