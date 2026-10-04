import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/cuento_model.dart';
import 'package:descubre_con_lua/data/models/dia_calendario_dual_model.dart';
import 'package:descubre_con_lua/data/models/lectura_model.dart';
import 'package:descubre_con_lua/data/models/tpr_curriculum_scheduler.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_fogar_screen.dart';
import 'package:descubre_con_lua/features/cuentos/views/cuento_viewer_screen.dart';
import 'package:descubre_con_lua/features/docentes/portal_docentes_screen.dart';
import 'package:descubre_con_lua/features/familias/portal_familias_screen.dart';
import 'package:descubre_con_lua/features/familias/views/xogos_fogar_screen.dart';
import 'package:descubre_con_lua/features/lectura/views/aprender_a_ler_screen.dart';
import 'package:descubre_con_lua/features/premios/premios_repository.dart';
import 'package:descubre_con_lua/features/seleccion/seleccion_portal_screen.dart';
import 'package:descubre_con_lua/core/brand/lamina_vector.dart';
import 'package:descubre_con_lua/features/laminas/views/laminas_gallery_screen.dart';
import 'package:descubre_con_lua/data/models/xogos_fogar_observar_model.dart';

/// Que as pantallas novas CAIBAN nun teléfono, nas dúas linguas e coa escala de
/// texto grande do sistema.
///
/// Isto non está aquí para completar a cuadrícula: a rama chegou con dez
/// desbordes reais de `RenderFlex` que ninguén vira, porque o test de widgets
/// trae unha ventá de 800x600 e a 800 px de ancho non se nota nada. A 400
/// desbordaban a tarxeta do portal (95 px), o rexistro de 1 toque (273), a
/// cabeceira da reixa do calendario (271) e seis sitios máis.
///
/// En depuración un desborde pinta as franxas amarelas e negras. **En release
/// non se ve nada: o texto córtase e xa.** E o galego é máis longo que o
/// castelán, así que unha pantalla correcta nunha lingua pode romper na outra.
///
/// O que un widget test NON demostra: as fontes reais, os recortes da pantalla
/// (moesca, barra de xestos), as densidades reais e que o audio soe. Para iso
/// fai falta un aparato.
void main() {
  late ContentRepository repository;
  late MockOfflineAudioService audioService;
  late CalendarioStore store;
  late PremiosRepository premios;
  late Directory dir;

  late ContidoLectura contidoLectura;
  late ProgramaTpr programaTpr;
  late List<Cuento> contosDaSemana;

  setUpAll(() async {
    // O inglés do traxecto e os contos da semana, do disco e AQUÍ, polo mesmo
    // motivo ca «Aprender a Ler».
    programaTpr = await ProgramaTpr.cargar(
      stringLoader: (path) => File(path).readAsString(),
    );
    contosDaSemana = (jsonDecode(
            File('assets/content/cuentos/historias_progresivas.json')
                .readAsStringSync()) as List)
        .map((e) => Cuento.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((c) => c.paginas.any((p) => p.palabras.isNotEmpty))
        .toList();

    // O contido de «Aprender a Ler» lese do disco AQUÍ e non dentro de
    // `testWidgets`: alí o reloxo é falso e unha lectura de disco de verdade
    // non remata nunca. Pásaselle feito á pantalla, igual que fai
    // `calendario_escala_test.dart` co calendario.
    contidoLectura = await ContidoLectura.cargar(
      stringLoader: (path) => File(path).readAsString(),
    );

    // Os debuxos das láminas, AQUÍ e non dentro de `testWidgets`: alí a
    // lectura do paquete non remata, a tarxeta pintábase co marcador —máis
    // baixo ca o debuxo— e o desborde de 22 px da reixa vella non se vía.
    TestWidgetsFlutterBinding.ensureInitialized();
    final laminas = jsonDecode(
        File('assets/content/laminas/banco200_laminas.json')
            .readAsStringSync()) as List;
    for (final l in laminas) {
      final clave = (l as Map)['lamina'];
      if (clave is String && clave.isNotEmpty) {
        await LaminasVectoriales.cargar(clave);
      }
    }
  });

  setUp(() async {
    repository = ContentRepository();
    audioService = MockOfflineAudioService();
    premios = PremiosRepository();
    dir = await Directory.systemTemp.createTemp('portais_escala_');
    store = CalendarioStore(overrideDirectory: dir.path);
    await store.cargar();
    // O Banco de Láminas lee as súas 205 do repositorio; lidas aquí, dentro
    // do test xa están.
    await repository.loadLaminas();

    repository.addCalendarioDia(const DiaCalendarioDual(
      dia: 1,
      diaSemana: 0,
      diaSemanaNumero: 1,
      nombreDiaSemana: LocalizedString(gl: 'Luns', es: 'Lunes'),
      semanaNumero: 1,
      semanaCursoNumero: 1,
      semanaGlobalNumero: 1,
      diaCursoNumero: 1,
      diaGlobalNumero: 1,
      mesNumero: 1,
      mesGlobalNumero: 1,
      fechaClave: 'curso_0_2-mes-1-dia-1',
      temaDia: LocalizedString(
        gl: 'Primeiro día con Lúa',
        es: 'Primer día con Lúa',
      ),
      profesorado: DiaProfesorado(
        actividadAula: LocalizedString(
          gl: 'Asemblea de acollemento con canción a pulso.',
          es: 'Asamblea de acogida con canción a pulso.',
        ),
        dinamica: LocalizedString(
          gl: 'Reto motor de mans e pés no círculo.',
          es: 'Reto motor de manos y pies en el círculo.',
        ),
        duracionMin: 12,
        tprIngles: 'Clap hands, touch ground!',
        consignaDocente: LocalizedString(
          gl: 'Agarda cinco segundos antes de intervir.',
          es: 'Espera cinco segundos antes de intervenir.',
        ),
      ),
      familias: DiaFamilias(
        rutinaFogar: LocalizedString(
          gl: 'Xogo suave con Lúa sen pantallas antes de durmir.',
          es: 'Juego suave con Lúa sin pantallas antes de dormir.',
        ),
        momento: LocalizedString(gl: 'Antes de durmir', es: 'Antes de dormir'),
        consignaFamilia: LocalizedString(
          gl: 'Pausa de cinco segundos antes de intervir.',
          es: 'Pausa de cinco segundos antes de intervenir.',
        ),
        fraseConexion: LocalizedString(
          gl: 'Hoxe na escola xogamos coas mans.',
          es: 'Hoy en la escuela jugamos con las manos.',
        ),
      ),
    ));
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  // Os erros saen de `takeException()`, que é o que o binding garda. Esta
  // lista recollíase antes cun `FlutterError.onError` posto en `setUp`, e iso
  // NON serve: `testWidgets` substitúe ese manexador mentres corre o test, a
  // lista saía sempre baleira e `takeException()` tragábase o desborde. Así
  // pasaban en verde os portais con 10, 134 e 232 px de desborde. O test do
  // final deste ficheiro comproba que agora si se ve un. O ficheiro e a liña
  // do desborde imprímeos o propio binding na consola.
  List<String> erroresDe(WidgetTester tester) {
    final fuera = <String>[];
    for (var e = tester.takeException();
        e != null;
        e = tester.takeException()) {
      fuera.add(e.toString().split('\n').first);
    }
    return fuera;
  }

  Future<void> pintar(
    WidgetTester tester,
    Widget pantalla,
    double escala,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      // `copyWith` sobre o MediaQuery real: un MediaQueryData novo trae tamaño
      // 0x0 e a pantalla disponse contra unha ventá inexistente.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(escala)),
        child: child!,
      ),
      home: pantalla,
    ));
    await tester.pumpAndSettle();
  }

  /// Baixa por toda a pantalla: un desborde pode estar en calquera tarxeta, non
  /// só na primeira que se ve.
  Future<void> recorrer(WidgetTester tester) async {
    final listas = find.byType(Scrollable);
    if (listas.evaluate().isEmpty) return;
    for (var i = 0; i < 8; i++) {
      await tester.drag(listas.first, const Offset(0, -400));
      await tester.pumpAndSettle();
    }
  }

  for (final lang in AppLanguage.deInterfaz) {
    for (final escala in [1.0, 1.8]) {
      final etiqueta = '${lang.code} a escala $escala';

      testWidgets('a selección de portal cabe en $etiqueta', (tester) async {
        await pintar(
          tester,
          SeleccionPortalScreen(
            repository: repository,
            premios: premios,
            calendario: store,
            audioService: audioService,
            currentLanguage: lang,
            onToggleLanguage: () {},
          ),
          escala,
        );
        await recorrer(tester);
        expect(erroresDe(tester), isEmpty,
            reason: 'A selección de portal desborda en $etiqueta.');
      });

      testWidgets('o Portal Familias cabe en $etiqueta', (tester) async {
        await pintar(
          tester,
          PortalFamiliasScreen(
            repository: repository,
            premios: premios,
            calendario: store,
            audioService: audioService,
            currentLanguage: lang,
            onToggleLanguage: () {},
          ),
          escala,
        );
        await recorrer(tester);
        expect(erroresDe(tester), isEmpty,
            reason: 'O Portal Familias desborda en $etiqueta.');
      });

      testWidgets('o Portal Docentes cabe en $etiqueta', (tester) async {
        await pintar(
          tester,
          PortalDocentesScreen(
            repository: repository,
            premios: premios,
            calendario: store,
            audioService: audioService,
            currentLanguage: lang,
            onToggleLanguage: () {},
          ),
          escala,
        );
        await recorrer(tester);
        expect(erroresDe(tester), isEmpty,
            reason: 'O Portal Docentes desborda en $etiqueta.');
      });

      testWidgets('o Calendario no Fogar cabe en $etiqueta', (tester) async {
        await pintar(
          tester,
          CalendarioFogarScreen(
            repository: repository,
            store: store,
            initialLanguage: lang,
            audioService: audioService,
            // Fixo: se non, o que se mide cambia co día no que corre o test.
            agora: DateTime(2026, 9, 7),
          ),
          escala,
        );
        await recorrer(tester);
        expect(erroresDe(tester), isEmpty,
            reason: 'O Calendario no Fogar desborda en $etiqueta.');
      });

      testWidgets('o Banco de Láminas cabe en $etiqueta', (tester) async {
        await pintar(
          tester,
          LaminasGalleryScreen(
            repository: repository,
            initialLanguage: lang,
            audioService: audioService,
          ),
          escala,
        );
        // Debuxadas de verdade, non co marcador: se non, a tarxeta mide menos
        // ca na app.
        expect(find.byType(CustomPaint), findsWidgets);
        await recorrer(tester);
        expect(erroresDe(tester), isEmpty,
            reason: 'O Banco de Láminas desborda en $etiqueta.');
      });

      testWidgets('os Xogos no Fogar caben en $etiqueta', (tester) async {
        await pintar(
          tester,
          XogosFogarScreen(
            observacions: ObservacionsXogosFogar.fromRaw(
                File(ObservacionsXogosFogar.assetPath).readAsStringSync()),
            initialLanguage: lang,
            audioService: audioService,
          ),
          escala,
        );
        await recorrer(tester);
        expect(erroresDe(tester), isEmpty,
            reason: 'Os Xogos no Fogar desbordan en $etiqueta.');
      });

      testWidgets('Aprender a Ler cabe en $etiqueta, nas catro pestanas',
          (tester) async {
        await pintar(
          tester,
          AprenderALerScreen(
            repository: repository,
            initialLanguage: lang,
            audioService: audioService,
            contido: contidoLectura,
          ),
          escala,
        );

        // As catro pestanas, unha por unha: a que desborda pode ser calquera.
        final pestanas = find.byType(Tab);
        for (var i = 0; i < pestanas.evaluate().length; i++) {
          await tester.tap(pestanas.at(i));
          await tester.pumpAndSettle();
          await recorrer(tester);
          expect(erroresDe(tester), isEmpty,
              reason: 'Aprender a Ler desborda na pestana $i, $etiqueta.');
        }
      });

      testWidgets('o visor de contos cabe en $etiqueta', (tester) async {
        // Un conto REAL do banco, non un inventado: os textos do banco son os
        // que de verdade teñen que caber.
        final contos = (jsonDecode(
                File('assets/content/cuentos/banco100_cuentos.json')
                    .readAsStringSync()) as List)
            .map((e) => Cuento.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();

        // O primeiro de cada curso: cinco rexistros distintos de texto.
        for (final curso in [
          'curso_0_2',
          'curso_2_3',
          'curso_3_4',
          'curso_4_5',
          'curso_5_6',
        ]) {
          final conto = contos.firstWhere((c) => c.cursoId == curso);
          await pintar(
            tester,
            CuentoViewerScreen(
              cuento: conto,
              language: lang,
              audioService: audioService,
            ),
            escala,
          );
          await recorrer(tester);
          expect(erroresDe(tester), isEmpty,
              reason: 'O visor desborda con ${conto.id}, $etiqueta.');
        }
      });

      testWidgets('un conto da semana aberto dende o día cabe en $etiqueta',
          (tester) async {
        // Coas palabras do día dentro: a cabeceira coas cinco de hoxe e, en
        // cada páxina, as súas palabras co significado, o xesto e a voz. O
        // conto de cada curso coa páxina máis longa, que é o peor caso, e
        // TODAS as súas páxinas, porque cada unha trae palabras distintas.
        int longo(Cuento c) => c.paginas
            .map((p) => p.texto.resolve(lang).length)
            .reduce((a, b) => a > b ? a : b);
        for (final curso in [
          'curso_0_2',
          'curso_2_3',
          'curso_3_4',
          'curso_4_5',
          'curso_5_6',
        ]) {
          final conto = contosDaSemana
              .where((c) => c.cursoId == curso)
              .reduce((a, b) => longo(a) >= longo(b) ? a : b);
          await pintar(
            tester,
            CuentoViewerScreen(
              cuento: conto,
              language: lang,
              audioService: audioService,
              semanaTpr: programaTpr
                  .curso(curso)!
                  .semanaPorOrden(conto.mesNumero, conto.semanaSugerida!),
              dia: 1,
            ),
            escala,
          );
          for (var i = 0; i < conto.paginas.length; i++) {
            await recorrer(tester);
            expect(erroresDe(tester), isEmpty,
                reason: 'O visor desborda con ${conto.id}, páxina ${i + 1}, '
                    '$etiqueta.');
            if (i < conto.paginas.length - 1) {
              await tester.tap(
                  find.text(lang == AppLanguage.gl ? 'Seguinte' : 'Siguiente'));
              await tester.pumpAndSettle();
            }
          }
        }
      });
    }
  }

  // Se isto non ve un desborde feito a propósito, todo o de arriba sae verde
  // sen comprobar nada. Pasou.
  testWidgets('o medidor ve un desborde feito a propósito', (tester) async {
    await pintar(
      tester,
      const Scaffold(body: Row(children: [SizedBox(width: 500, height: 10)])),
      1.0,
    );
    expect(erroresDe(tester), isNotEmpty);
  });
}
