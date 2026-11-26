import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/features/criancas/axuste_semanal.dart';
import 'package:descubre_con_lua/features/criancas/criancas_store.dart';
import 'package:descubre_con_lua/features/familias/portal_familias_screen.dart';

import '../helpers/pasarela.dart';

void main() {
  final p = Pasarela();
  setUpAll(p.cargar);
  tearDownAll(p.limpar);

  test(
    'P11.4: simulación de 40 semanas con 4 niños (rápido, medio, lento y sin marcas)',
    () {
      // Curso 3-4: topes [2, 5], techo de peldaño 4.
      const curso = 'curso_3_4';
      final topes = AxusteSemanal.topesDe(curso);

      // Estado por niño simulado.
      var pelRap = 1;
      var cupRap = topes.base;
      var bxRap = 0;
      var diRap = 0;

      var pelMed = 1;
      var cupMed = topes.base;
      var bxMed = 0;
      var diMed = 0;

      var pelLen = 3;
      var cupLen = topes.base;
      var bxLen = 0;
      var diLen = 0;
      var consolidouLen = false;

      var pelSen = 2;
      var cupSen = topes.base;
      var bxSen = 0;
      var diSen = 0;

      for (var sem = 1; sem <= 40; sem++) {
        // 1) Niño rápido: entiende 100%, dice 100% con >=8 escuchas.
        final resRap = AxusteSemanal.calcular(
          nome: 'Brais',
          curso: curso,
          peldanoActual: pelRap,
          cupoActual: cupRap,
          marcasSemanaAnterior: const {
            'leaf': Observacion.di,
            'seed': Observacion.di,
            'cup': Observacion.di,
            'train': Observacion.di,
          },
          escoitasPorPalabra: const {
            'leaf': 10,
            'seed': 10,
            'cup': 10,
            'train': 10,
          },
          semanasBaixasSeguidas: bxRap,
          semanasDiAltoSeguidas: diRap,
        );
        expect(resRap.cupoNovas, inInclusiveRange(topes.min, topes.max));
        expect(resRap.peldano, lessThanOrEqualTo(topes.tectoPeldano));
        expect(resRap.capa, CapaSemana.mais);
        expect(resRap.explicacionGl, isNot(contains('%')));
        expect(resRap.explicacionEs, isNot(contains('%')));
        pelRap = resRap.peldano;
        cupRap = resRap.cupoNovas;
        bxRap = resRap.novasSemanasBaixas;
        diRap = resRap.novasSemanasDiAlto;

        // 2) Niño medio: 2/3 entiende (67%), 1/3 dice -> ni sube ni baja el cupo.
        final resMed = AxusteSemanal.calcular(
          nome: 'Uxía',
          curso: curso,
          peldanoActual: pelMed,
          cupoActual: cupMed,
          marcasSemanaAnterior: const {
            'leaf': Observacion.di,
            'seed': Observacion.entende,
            'cup': Observacion.aindaNon,
          },
          escoitasPorPalabra: const {'leaf': 9, 'seed': 9, 'cup': 9},
          semanasBaixasSeguidas: bxMed,
          semanasDiAltoSeguidas: diMed,
        );
        expect(resMed.cupoNovas, topes.base);
        expect(resMed.capa, CapaSemana.nucleo);
        pelMed = resMed.peldano;
        cupMed = resMed.cupoNovas;
        bxMed = resMed.novasSemanasBaixas;
        diMed = resMed.novasSemanasDiAlto;

        // 3) Niño lento: 0% (<30%): tras 3 semanas seguidas consolida (cupo 0, baja peldaño).
        final resLen = AxusteSemanal.calcular(
          nome: 'Mateo',
          curso: curso,
          peldanoActual: pelLen,
          cupoActual: cupLen,
          marcasSemanaAnterior: const {
            'leaf': Observacion.aindaNon,
            'seed': Observacion.aindaNon,
            'cup': Observacion.aindaNon,
            'train': Observacion.aindaNon,
          },
          escoitasPorPalabra: const {
            'leaf': 8,
            'seed': 8,
            'cup': 8,
            'train': 8,
          },
          semanasBaixasSeguidas: bxLen,
          semanasDiAltoSeguidas: diLen,
        );
        if (sem >= 3 && !consolidouLen) {
          expect(resLen.consolidando, isTrue);
          expect(resLen.cupoNovas, 0);
          expect(resLen.peldano, 2);
          consolidouLen = true;
        }
        pelLen = resLen.peldano;
        cupLen = resLen.cupoNovas > 0 ? resLen.cupoNovas : topes.min;
        bxLen = resLen.novasSemanasBaixas;
        diLen = resLen.novasSemanasDiAlto;

        // 4) Sin marcas: nunca cambia ni inventa avances.
        final resSen = AxusteSemanal.calcular(
          nome: 'Iria',
          curso: curso,
          peldanoActual: pelSen,
          cupoActual: cupSen,
          marcasSemanaAnterior: const {},
          semanasBaixasSeguidas: bxSen,
          semanasDiAltoSeguidas: diSen,
        );
        expect(resSen.senMarcas, isTrue);
        expect(resSen.cupoNovas, topes.base);
        expect(resSen.peldano, 2);
        expect(resSen.capa, CapaSemana.nucleo);
      }

      expect(pelRap, topes.tectoPeldano);
      expect(cupRap, topes.max);
      expect(consolidouLen, isTrue);
    },
  );

  test(
    'M4: una palabra con menos de minimoEscoitasParaFallo (8) no baja la tasa',
    () {
      expect(minimoEscoitasParaFallo, 8);
      // 2 palabras dichas y 2 con <8 escuchas marcadas como aindaNon: no cuentan como fallo de «la dice».
      final menosDe8 = AxusteSemanal.calcular(
        nome: 'Uxía',
        curso: 'curso_3_4',
        peldanoActual: 1,
        cupoActual: 3,
        marcasSemanaAnterior: const {
          'leaf': Observacion.di,
          'seed': Observacion.di,
          'cup': Observacion.aindaNon,
          'train': Observacion.aindaNon,
        },
        escoitasPorPalabra: const {
          'leaf': 8,
          'seed': 8,
          'cup': 3,
          'train': 7,
        },
      );
      expect(menosDe8.taxaDi, 1.0);

      // En cuanto llegan a 8 escuchas y siguen sin decirse, sí bajan la tasa a 0.50.
      final con8 = AxusteSemanal.calcular(
        nome: 'Uxía',
        curso: 'curso_3_4',
        peldanoActual: 1,
        cupoActual: 3,
        marcasSemanaAnterior: const {
          'leaf': Observacion.di,
          'seed': Observacion.di,
          'cup': Observacion.aindaNon,
          'train': Observacion.aindaNon,
        },
        escoitasPorPalabra: const {
          'leaf': 8,
          'seed': 8,
          'cup': 8,
          'train': 8,
        },
      );
      expect(con8.taxaDi, 0.5);
    },
  );

  testWidgets(
    'M5 + P11.4 en UI: Hoxe muestra explicación sin % y la ficha abre Tarxeta para a escola',
    (tester) async {
      final agora = DateTime(2026, 11, 16, 10);
      final store = CriancasStore.enMemoria(const [
        Crianza(
          id: 'c1',
          nome: 'Uxía',
          idade: 3,
          curso: 'curso_3_4',
          peldano: 4,
          cupo: 4,
        ),
      ]);
      await store.observar(
        'c1',
        CriancasStore.semana('curso_3_4', 11, 2),
        'Tower',
        Observacion.di,
        agora: agora,
      );
      await store.observar(
        'c1',
        CriancasStore.semana('curso_3_4', 11, 2),
        'Juice',
        Observacion.di,
        agora: agora,
      );

      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.temaFamilias,
          home: PortalFamiliasScreen(
            repository: p.contenido,
            audioService: p.audio,
            currentLanguage: AppLanguage.gl,
            onToggleLanguage: () {},
            premios: p.premios,
            calendario: p.store,
            criancas: store,
            agora: agora,
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await Pasarela.asentar(tester);

      final expl = find.byKey(const Key('axuste_semanal_explicacion'));
      expect(expl, findsOneWidget);
      final textExpl = tester.widget<Text>(expl).data!;
      expect(textExpl, isNot(contains('%')));
      expect(textExpl, contains('Uxía'));

      // Abrir hoja del chip y abrir «Tarxeta para a escola».
      await tester.tap(find.byKey(const Key('selector_idade')));
      await Pasarela.asentar(tester);
      await tester.tap(find.byKey(const Key('crianza_tarxeta_escola')));
      await Pasarela.asentar(tester);

      expect(find.byKey(const Key('tarxeta_escola_titulo')), findsOneWidget);
      expect(find.byKey(const Key('tarxeta_escola_nome')), findsOneWidget);
      expect(find.text('Uxía'), findsWidgets);
      expect(find.byKey(const Key('tarxeta_escola_curso')), findsOneWidget);
      expect(find.byKey(const Key('tarxeta_escola_peldano')), findsOneWidget);
      expect(find.byKey(const Key('tarxeta_escola_palabras')), findsOneWidget);
      expect(find.text('Tower'), findsOneWidget);
      expect(find.text('Juice'), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
      expect(find.byIcon(Icons.share), findsNothing);
      expect(find.byIcon(Icons.print), findsNothing);
    },
  );
}
