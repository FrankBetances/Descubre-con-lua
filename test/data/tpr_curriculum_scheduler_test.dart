import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/data/models/tpr_curriculum_scheduler.dart';
import 'package:descubre_con_lua/data/validators/content_validator.dart';

/// El inglés del trayecto: cinco palabras nuevas al día, veinte por semana,
/// 800 por curso y 4.000 en los cinco cursos. Estos tests leen el contenido
/// REAL de `assets/content/tpr/`: si alguien quita una palabra, repite otra o rompe el reparto, se ve aquí y
/// no en la tarjeta de «Hoxe na aula» delante de una clase.
void main() {
  TprWord palabra(int i, {String categoria = 'noun'}) => TprWord(
        id: 'p$i',
        en: 'Word $i',
        gl: 'Palabra $i',
        es: 'Palabra $i',
        tprAction: const LocalizedString(gl: 'Xesto', es: 'Gesto'),
        category: categoria,
      );

  group('WeeklyTprScheduler: el reparto de una semana', () {
    final semana = List.generate(20, palabra);
    final dias = WeeklyTprScheduler.scheduleWeek(semana);

    test('cinco días: A, B, C, D y el reto del viernes', () {
      expect(dias.map((d) => d.dia), [1, 2, 3, 4, 5]);
      expect(dias.map((d) => d.bloque), ['A', 'B', 'C', 'D', '']);
    });

    test('carga acumulativa 5 · 10 · 15 · 20 · 20', () {
      expect(dias.map((d) => d.newWords.length), [5, 5, 5, 5, 0]);
      expect(dias.map((d) => d.reviewWords.length), [0, 5, 10, 15, 20]);
      expect(dias.map((d) => d.totalLoad), [5, 10, 15, 20, 20]);
    });

    test('cada día repasa exactamente los bloques anteriores, en orden', () {
      expect(dias[1].reviewWords, semana.sublist(0, 5));
      expect(dias[2].reviewWords, semana.sublist(0, 10));
      expect(dias[3].reviewWords, semana.sublist(0, 15));
      expect(dias[4].reviewWords, semana);
      expect(dias[4].eReto, isTrue);
      expect(dias[0].eReto, isFalse);
    });

    test('una semana que no son 20 palabras no se reparte', () {
      expect(() => WeeklyTprScheduler.scheduleWeek(semana.sublist(0, 19)),
          throwsArgumentError);
      expect(() => WeeklyTprScheduler.scheduleWeek([...semana, palabra(99)]),
          throwsArgumentError);
    });
  });

  group('ProgramaTpr: los cinco cursos que viajan en el paquete', () {
    late ProgramaTpr programa;
    final dir = Directory('assets/content/tpr');
    const ids = [
      'curso_0_2',
      'curso_2_3',
      'curso_3_4',
      'curso_4_5',
      'curso_5_6'
    ];

    setUpAll(() async {
      programa =
          await ProgramaTpr.cargar(stringLoader: (p) => File(p).readAsString());
    });

    test('cinco cursos, de 0-2 a 5-6 años, en ese orden', () {
      expect(programa.cursos.map((c) => c.id), ids);
      for (final c in programa.cursos) {
        expect(c.etiqueta.hasParity, isTrue, reason: c.id);
      }
      expect(programa.curso('curso_4_5')!.id, 'curso_4_5');
      expect(programa.curso('curso_9_9'), isNull);
    });

    test('cada grupo del aula apunta a un curso que existe', () {
      expect(cursoTprDoGrupo.values.toSet(), ids.toSet());
      for (final id in cursoTprDoGrupo.values) {
        expect(programa.curso(id), isNotNull, reason: id);
      }
    });

    test('en cada curso, diez meses de septiembre a junio, 4 semanas de 20',
        () {
      for (final curso in programa.cursos) {
        expect(curso.meses.map((m) => m.mesCalendario),
            [9, 10, 11, 12, 1, 2, 3, 4, 5, 6],
            reason: curso.id);
        expect(curso.meses.map((m) => m.orden), List.generate(10, (i) => i + 1),
            reason: curso.id);
        for (final m in curso.meses) {
          expect(m.semanas.map((s) => s.semana), [1, 2, 3, 4],
              reason: '${curso.id} mes ${m.mesCalendario}');
          for (final s in m.semanas) {
            expect(s.palabras, hasLength(20),
                reason:
                    '${curso.id} mes ${m.mesCalendario}, semana ${s.semana}');
            expect(s.tema.hasParity, isTrue);
          }
        }
        expect(curso.totalPalabras, 800, reason: curso.id);
      }
      expect(programa.totalPalabras, 4000);
    });

    test('200 días lectivos con palabras en cada curso: 160 con 5 nuevas', () {
      for (final curso in programa.cursos) {
        var dias = 0;
        var conNuevas = 0;
        for (final m in curso.meses) {
          for (final s in m.semanas) {
            for (var d = 1; d <= 5; d++) {
              final plan = s.planDoDia(d);
              dias++;
              if (plan.newWords.length == 5) conNuevas++;
            }
          }
        }
        expect(dias, 200, reason: curso.id);
        expect(conNuevas, 160, reason: curso.id);
      }
    });

    test('el reparto por categorías es el del modelo en CADA curso', () {
      for (final curso in programa.cursos) {
        expect(
            curso.porCategoria,
            {
              'noun': 280,
              'verb': 200,
              'adjective': 160,
              'phrase': 96,
              'complex': 64,
            },
            reason: curso.id);
      }
      expect(programa.porCategoria, {
        'noun': 1400,
        'verb': 1000,
        'adjective': 800,
        'phrase': 480,
        'complex': 320,
      });
    });

    test('los trimestres suman 320, 240 y 240 en cada curso', () {
      for (final curso in programa.cursos) {
        expect(curso.palabrasEnMeses([9, 10, 11, 12]), 320, reason: curso.id);
        expect(curso.palabrasEnMeses([1, 2, 3]), 240, reason: curso.id);
        expect(curso.palabrasEnMeses([4, 5, 6]), 240, reason: curso.id);
      }
    });

    test('ninguna palabra es nueva dos veces en las 4.000 del trayecto', () {
      final vistas = <String, String>{};
      final idsVistos = <String>{};
      for (final curso in programa.cursos) {
        for (final m in curso.meses) {
          for (final s in m.semanas) {
            for (final p in s.palabras) {
              final clave = p.en
                  .toLowerCase()
                  .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
                  .trim();
              expect(vistas.containsKey(clave), isFalse,
                  reason: '«${p.en}» ya estaba en ${vistas[clave]}');
              vistas[clave] =
                  '${curso.id}, mes ${m.mesCalendario}, semana ${s.semana}';
              expect(idsVistos.add(p.id), isTrue, reason: 'id ${p.id}');
            }
          }
        }
      }
      expect(vistas, hasLength(4000));
    });

    test('cada palabra tiene significado y gesto en gallego y castellano', () {
      for (final curso in programa.cursos) {
        for (final m in curso.meses) {
          for (final s in m.semanas) {
            for (final p in s.palabras) {
              expect(p.gl.trim(), isNotEmpty, reason: p.en);
              expect(p.es.trim(), isNotEmpty, reason: p.en);
              expect(p.tprAction.hasParity, isTrue, reason: p.en);
              expect(
                  ['noun', 'verb', 'adjective', 'phrase', 'complex']
                      .contains(p.category),
                  isTrue,
                  reason: '${p.en}: ${p.category}');
            }
          }
        }
      }
    });

    test('la semana 1 de octubre de 3-4 años es la de la rama UI, en su orden',
        () {
      final curso = programa.curso('curso_3_4')!;
      expect(curso.semana(10, 1)!.palabras.map((p) => p.en), [
        'Head', 'Shoulders', 'Knees', 'Toes', 'Freeze', //
        'Eyes', 'Ears', 'Mouth', 'Nose', 'Jump', //
        'Hands', 'Feet', 'Walk', 'Stop', 'Turn', //
        'Big', 'Small', 'Up', 'Down', 'Clap',
      ]);
      final lunes = curso.planDoDia(10, 1, 1)!;
      expect(lunes.newWords.map((p) => p.en),
          ['Head', 'Shoulders', 'Knees', 'Toes', 'Freeze']);
    });

    test('el mismo día, cursos distintos, palabras distintas', () {
      final lunes = {
        for (final c in programa.cursos)
          c.id: c.planDoDia(9, 1, 1)!.newWords.map((p) => p.en).join(','),
      };
      expect(lunes.values.toSet(), hasLength(5), reason: '$lunes');
    });

    test('el modelo trae los cinco días y las cinco categorías', () {
      final modelo = programa.modelo;
      expect(modelo.ritmoDiario, 5);
      expect(modelo.dias.map((d) => d.bloque), ['A', 'B', 'C', 'D', '']);
      for (final d in modelo.dias) {
        expect(d.dinamica.hasParity, isTrue);
        expect(d.dinamicaFogar.hasParity, isTrue);
      }
      expect(modelo.categorias.map((c) => c.clave),
          ['noun', 'verb', 'adjective', 'phrase', 'complex']);
      expect(modelo.fontes.hasParity, isTrue);
    });

    test('la nota de fuentes no atribuye a los inventarios lo que no dicen',
        () {
      // El CDI y la LDS describen el vocabulario temprano; no prescriben un
      // ritmo de enseñanza ni estos porcentajes. Si la nota dejara de decirlo,
      // la app volvería a citar como respaldo algo que no lo respalda.
      expect(
          programa.modelo.fontes.gl, contains('non normas deses inventarios'));
      expect(
          programa.modelo.fontes.es, contains('no normas de esos inventarios'));
    });

    test('todo fichero de los cursos está en el modelo, y al revés', () {
      final enDisco = dir
          .listSync(recursive: true)
          .whereType<File>()
          .map((f) => f.path.replaceAll('\\', '/'))
          .where((p) => p.split('/').last.startsWith('tpr.'))
          .toSet();
      final enModelo = {
        for (final c in programa.modelo.cursos) ...c.meses,
      };
      expect(enModelo, enDisco);
      expect(enModelo, hasLength(50));
    });

    test('paridad bilingüe y cero términos clínicos en los 51 ficheros', () {
      final validator = ContentValidator();
      final ficheros = dir.listSync(recursive: true).whereType<File>().toList();
      expect(ficheros, hasLength(51));
      for (final f in ficheros) {
        final json = jsonDecode(f.readAsStringSync());
        final erros = <String>[];
        validator.checkBilingualParity(json, path: f.path, errors: erros);
        validator.checkClinicalTerms(json, path: f.path, errors: erros);
        expect(erros, isEmpty, reason: erros.join('\n'));
      }
    });

    test('nada del léxico que el documento del modelo prohíbe', () {
      // La lista de `content_linter.py` del documento de arquitectura.
      const prohibidas = {
        'sick', 'disease', 'syndrome', 'trauma', 'disorder', 'infection', //
        'fever', 'pain', 'hospital', 'doctor', 'medicine', 'pill', //
        'scared', 'fear', 'danger', 'stranger', 'bad', 'ugly', 'kill', //
        'dead', 'die', 'punish', 'sad', 'depressed', 'anxiety', 'clinic',
      };
      for (final curso in programa.cursos) {
        for (final m in curso.meses) {
          for (final s in m.semanas) {
            for (final p in s.palabras) {
              final tokens = RegExp(r'[a-z]+')
                  .allMatches(p.en.toLowerCase())
                  .map((e) => e.group(0)!);
              expect(tokens.where(prohibidas.contains), isEmpty,
                  reason: '${curso.id}: ${p.en}');
            }
          }
        }
      }
    });

    test('el calendario ya no trae léxico mensual: lo lleva el curso', () {
      final meses = jsonDecode(
              File('assets/content/calendario/meses.json').readAsStringSync())
          as Map<String, dynamic>;
      for (final m in meses['meses'] as List) {
        expect((m['ingles'] as Map).containsKey('lexico'), isFalse,
            reason: 'mes ${m['mesCalendario']}');
      }
    });
  });

  group('CursoTpr.hoxe: el mismo día que la asamblea', () {
    test('un miércoles de la cuarta semana de septiembre', () {
      final h = CursoTpr.hoxe(agora: DateTime(2026, 9, 23))!;
      expect((h.mesCalendario, h.semana, h.dia), (9, 4, 3));
    });

    test('el fin de semana abre por el lunes', () {
      final h = CursoTpr.hoxe(agora: DateTime(2026, 10, 10))!; // sábado
      expect(h.dia, 1);
    });

    test('julio y agosto no son del curso', () {
      expect(CursoTpr.hoxe(agora: DateTime(2026, 7, 15)), isNull);
      expect(CursoTpr.hoxe(agora: DateTime(2026, 8, 3)), isNull);
    });

    test('el día 29 o 30 sigue en la semana 4, que es la última', () {
      final h = CursoTpr.hoxe(agora: DateTime(2026, 9, 30))!;
      expect(h.semana, 4);
    });
  });
}
