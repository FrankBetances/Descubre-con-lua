import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/data/models/tpr_curriculum_scheduler.dart';

void main() {
  group('TprWord & WeeklyTprScheduler Tests', () {
    late List<TprWord> banco20;

    setUp(() {
      banco20 = List.generate(20, (i) {
        return TprWord(
          id: 'word_$i',
          en: 'Word $i',
          gl: 'Palabra $i gl',
          es: 'Palabra $i es',
          tprAction: 'Acción motriz $i',
          category: i % 2 == 0 ? 'noun' : 'verb',
        );
      });
    });

    test('scheduleWeek genera matriz acumulativa de lunes a viernes exacta', () {
      final plan = WeeklyTprScheduler.scheduleWeek(banco20);

      expect(plan.keys, containsAll(['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes']));

      // Lunes: 5 nuevas, 0 repaso, carga 5
      final lunes = plan['Lunes']!;
      expect(lunes.newWords.length, 5);
      expect(lunes.reviewWords.length, 0);
      expect(lunes.totalLoad, 5);
      expect(lunes.tprDynamic, contains('Presentación motriz directa'));

      // Martes: 5 nuevas, 5 repaso (Bloque A), carga 10
      final martes = plan['Martes']!;
      expect(martes.newWords.length, 5);
      expect(martes.reviewWords.length, 5);
      expect(martes.totalLoad, 10);
      expect(martes.tprDynamic, contains('Contraste motriz'));

      // Miércoles: 5 nuevas, 10 repaso (Bloques A y B), carga 15
      final miercoles = plan['Miércoles']!;
      expect(miercoles.newWords.length, 5);
      expect(miercoles.reviewWords.length, 10);
      expect(miercoles.totalLoad, 15);
      expect(miercoles.tprDynamic, contains('Circuito TPR'));

      // Jueves: 5 nuevas, 15 repaso (Bloques A, B y C), carga 20
      final jueves = plan['Jueves']!;
      expect(jueves.newWords.length, 5);
      expect(jueves.reviewWords.length, 15);
      expect(jueves.totalLoad, 20);
      expect(jueves.tprDynamic, contains('Cuento motor'));

      // Viernes: 0 nuevas, 20 repaso acumulativo, carga 20
      final viernes = plan['Viernes']!;
      expect(viernes.newWords.length, 0);
      expect(viernes.reviewWords.length, 20);
      expect(viernes.totalLoad, 20);
      expect(viernes.tprDynamic, contains('¡GRAN RETO TPR ACUMULATIVO!'));
    });

    test('scheduleWeekBilingual genera las claves en gallego correctamente', () {
      final planGl = WeeklyTprScheduler.scheduleWeekBilingual(banco20, AppLanguage.gl);
      expect(planGl.keys, containsAll(['Luns', 'Martes', 'Mércores', 'Xoves', 'Venres']));
      expect(planGl['Venres']!.totalLoad, 20);
      expect(planGl['Venres']!.tprDynamic, contains('Freeze'));
    });

    test('TprSemanaContenido carga desde assets/content/semana_01.json correctamente', () {
      final file = File('assets/content/semana_01.json');
      expect(file.existsSync(), isTrue);

      final jsonMap = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final semana = TprSemanaContenido.fromJson(jsonMap);

      expect(semana.unidadId, 'juega.octubre.semana1');
      expect(semana.ritmoDiario, 5);
      expect(semana.totalSemana, 20);
      expect(semana.palabras.length, 20);

      // Verificación de palabras clave
      expect(semana.palabras.first.en, 'Head');
      expect(semana.palabras.first.category, 'noun');
      expect(semana.palabras[4].en, 'Freeze');
      expect(semana.palabras[4].category, 'verb');

      final plan = semana.getPlanSemanal(AppLanguage.gl);
      expect(plan.length, 5);
      expect(plan['Luns']!.totalLoad, 5);
      expect(plan['Venres']!.totalLoad, 20);

      // getPlanParaDia testing
      final planDia1 = semana.getPlanParaDia(1, AppLanguage.gl);
      expect(planDia1, isNotNull);
      expect(planDia1!.dayName, 'Luns');
      expect(planDia1.newWords.length, 5);
      expect(planDia1.reviewWords.length, 0);

      final planDia5 = semana.getPlanParaDia(5, AppLanguage.gl);
      expect(planDia5, isNotNull);
      expect(planDia5!.dayName, 'Venres');
      expect(planDia5.newWords.length, 0);
      expect(planDia5.reviewWords.length, 20);

      expect(semana.getPlanParaDia(0, AppLanguage.gl), isNull);
      expect(semana.getPlanParaDia(6, AppLanguage.gl), isNull);
    });

    test('scheduleWeek e scheduleWeekBilingual lanzan ArgumentError con menos de 20 palabras', () {
      final palabrasInsuficientes = banco20.sublist(0, 10);
      expect(
        () => WeeklyTprScheduler.scheduleWeek(palabrasInsuficientes),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => WeeklyTprScheduler.scheduleWeekBilingual(palabrasInsuficientes, AppLanguage.gl),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}

