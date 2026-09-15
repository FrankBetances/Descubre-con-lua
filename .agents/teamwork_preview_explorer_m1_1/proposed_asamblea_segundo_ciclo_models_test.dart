import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/data/models/asamblea_segundo_ciclo_model.dart';
import 'package:descubre_con_lua/data/models/unidad_model.dart' show Revision;

void main() {
  group('Enums Segundo Ciclo Tests', () {
    test('NivelEducativoSegundoCiclo properties and parser', () {
      expect(NivelEducativoSegundoCiclo.infantil4.clave, equals('4_infantil'));
      expect(NivelEducativoSegundoCiclo.infantil4.tramoEtario, equals('3-4'));
      expect(NivelEducativoSegundoCiclo.infantil4.edadMinima, equals(3));
      expect(NivelEducativoSegundoCiclo.infantil4.edadMaxima, equals(4));
      expect(NivelEducativoSegundoCiclo.infantil4.metodologiaPorDefecto,
          equals(MetodologiaTPR.accionExpandida));
      expect(NivelEducativoSegundoCiclo.infantil4.etiqueta.resolve(AppLanguage.gl),
          contains('4.º de Infantil'));

      expect(NivelEducativoSegundoCiclo.infantil5.clave, equals('5_infantil'));
      expect(NivelEducativoSegundoCiclo.infantil5.metodologiaPorDefecto,
          equals(MetodologiaTPR.dramatizadoNarrativo));

      expect(NivelEducativoSegundoCiclo.infantil6.clave, equals('6_infantil'));
      expect(NivelEducativoSegundoCiclo.infantil6.metodologiaPorDefecto,
          equals(MetodologiaTPR.transaccionalPragmatico));

      expect(NivelEducativoSegundoCiclo.desdeClave('4_infantil'),
          equals(NivelEducativoSegundoCiclo.infantil4));
      expect(NivelEducativoSegundoCiclo.desdeClave('5_infantil'),
          equals(NivelEducativoSegundoCiclo.infantil5));
      expect(NivelEducativoSegundoCiclo.desdeClave('6_infantil'),
          equals(NivelEducativoSegundoCiclo.infantil6));
      expect(NivelEducativoSegundoCiclo.desdeClave('unknown'),
          equals(NivelEducativoSegundoCiclo.infantil4));
    });

    test('MetodologiaTPR properties and parser', () {
      expect(MetodologiaTPR.accionExpandida.clave, equals('accion_expandida'));
      expect(MetodologiaTPR.accionExpandida.usaSenalInhibicion, isFalse);
      expect(MetodologiaTPR.accionExpandida.usaTarjetasIconicas, isFalse);

      expect(MetodologiaTPR.dramatizadoNarrativo.clave,
          equals('dramatizado_narrativo'));
      expect(MetodologiaTPR.dramatizadoNarrativo.usaSenalInhibicion, isTrue);

      expect(MetodologiaTPR.transaccionalPragmatico.clave,
          equals('transaccional_pragmatico'));
      expect(MetodologiaTPR.transaccionalPragmatico.usaTarjetasIconicas, isTrue);

      expect(MetodologiaTPR.desdeClave('accion_expandida'),
          equals(MetodologiaTPR.accionExpandida));
      expect(MetodologiaTPR.desdeClave('dramatizado_narrativo'),
          equals(MetodologiaTPR.dramatizadoNarrativo));
      expect(MetodologiaTPR.desdeClave('transaccional_pragmatico'),
          equals(MetodologiaTPR.transaccionalPragmatico));
    });

    test('TipoFaseAsamblea 4 canonical durations and total sum of 600s', () {
      expect(TipoFaseAsamblea.aperturaSaudo.duracionCanonicoSegundos, equals(90));
      expect(TipoFaseAsamblea.movementRhythmFocus.duracionCanonicoSegundos,
          equals(120));
      expect(TipoFaseAsamblea.coreTprChallenge.duracionCanonicoSegundos,
          equals(270));
      expect(
          TipoFaseAsamblea.calmaTransicion.duracionCanonicoSegundos, equals(120));

      final int totalSeconds = TipoFaseAsamblea.aperturaSaudo.duracionCanonicoSegundos +
          TipoFaseAsamblea.movementRhythmFocus.duracionCanonicoSegundos +
          TipoFaseAsamblea.coreTprChallenge.duracionCanonicoSegundos +
          TipoFaseAsamblea.calmaTransicion.duracionCanonicoSegundos;
      expect(totalSeconds, equals(600)); // Exactly 10 minutes

      expect(TipoFaseAsamblea.porOrden(1), equals(TipoFaseAsamblea.aperturaSaudo));
      expect(TipoFaseAsamblea.porOrden(2),
          equals(TipoFaseAsamblea.movementRhythmFocus));
      expect(TipoFaseAsamblea.porOrden(3),
          equals(TipoFaseAsamblea.coreTprChallenge));
      expect(TipoFaseAsamblea.porOrden(4),
          equals(TipoFaseAsamblea.calmaTransicion));
    });
  });

  group('ComandoTPR & MaterialNatural Tests', () {
    test('ComandoTPR serialization and equality', () {
      final json = {
        'id': 'tpr.01',
        'textoIngles': 'Stand up and clap hands',
        'accionFisica': {
          'gl': 'Erguerse e dar palmas suaves',
          'es': 'Levantarse y dar palmas suaves'
        },
        'modeladoDocente': {
          'gl': 'Modelado sincrónico inicial',
          'es': 'Modelado sincrónico inicial'
        },
        'audioAsset': 'assets/voice/l3/stand_up_clap.m4a',
      };

      final cmd = ComandoTPR.fromJson(json);
      expect(cmd.id, equals('tpr.01'));
      expect(cmd.textoIngles, equals('Stand up and clap hands'));
      expect(cmd.audioAsset, equals('assets/voice/l3/stand_up_clap.m4a'));

      final serialized = cmd.toJson();
      expect(serialized['id'], equals('tpr.01'));
      expect(serialized['textoIngles'], equals('Stand up and clap hands'));
      expect(serialized['audioAsset'], equals('assets/voice/l3/stand_up_clap.m4a'));

      final cmd2 = ComandoTPR.fromJson(serialized);
      expect(cmd, equals(cmd2));
      expect(cmd.hashCode, equals(cmd2.hashCode));
    });

    test('MaterialNatural serialization and safety advisory', () {
      final json = {
        'id': 'vimbio_cesto',
        'nombre': {'gl': 'Cesto de vimbio', 'es': 'Cesto de mimbre'},
        'procedencia': {
          'gl': 'Cestería tradicional de Galicia',
          'es': 'Cestería tradicional de Galicia'
        },
        'pautaManipulacion': {
          'gl': 'Tocar os bordos entrelazados e sentir a flexibilidade',
          'es': 'Tocar los bordes entrelazados y sentir la flexibilidad'
        },
        'avisoSeguridad': {
          'gl': 'Pezas maiores de 10 cm, sen estelas cortantes',
          'es': 'Piezas mayores de 10 cm, sin astillas cortantes'
        },
      };

      final mat = MaterialNatural.fromJson(json);
      expect(mat.id, equals('vimbio_cesto'));
      expect(mat.avisoSeguridad, isNotNull);
      expect(mat.avisoSeguridad!.gl, contains('10 cm'));

      final serialized = mat.toJson();
      final mat2 = MaterialNatural.fromJson(serialized);
      expect(mat, equals(mat2));
    });
  });

  group('CurricularReferenceSegundoCiclo Tests', () {
    test('validates against Decreto 150/2022 Segundo Ciclo requirements', () {
      final json = {
        'normativa': 'Decreto 150/2022',
        'etapa': 'educacion_infantil',
        'ciclo': 'segundo_ciclo_3_6',
        'nivel': '4_infantil',
        'areas': [
          'area_1_crecemento_harmonia',
          'area_3_comunicacion_representacion',
        ],
        'competenciasClave': ['CCL', 'CPSAA'],
        'criteriosEvaluacion': ['CA1.1', 'CA3.1'],
      };

      final ref = CurricularReferenceSegundoCiclo.fromJson(json);
      expect(ref.isValidDecreto150SegundoCiclo, isTrue);
      expect(ref.hasArea('area_1_crecemento_harmonia'), isTrue);
      expect(ref.hasArea('area_2_descubrimento_contorna'), isFalse);
      expect(ref.hasCriterio('CA1.1'), isTrue);
      expect(ref.hasCriterio('CA2.1'), isFalse);
      expect(ref.hasCompetencia('CCL'), isTrue);
    });

    test('rejects mismatched cycle or criteria', () {
      final invalid = CurricularReferenceSegundoCiclo(
        nivel: '4_infantil',
        areas: const ['area_1_crecemento_harmonia'],
        criteriosEvaluacion: const ['CA99.9'],
      );
      expect(invalid.isValidDecreto150SegundoCiclo, isFalse);
    });
  });

  group('PautaRecast & MicroRutinaHogarSegundoCiclo Tests', () {
    test('models home micro-routine and recast guidelines', () {
      final json = {
        'id': 'micro.01',
        'titulo': {
          'gl': 'A percha máxica dos abrigos',
          'es': 'La percha mágica de los abrigos'
        },
        'nichoTiempoMinutos': 3,
        'momentoDelDia': {
          'gl': 'Ao chegar da escola',
          'es': 'Al llegar del colegio'
        },
        'objetivoAutonomia': {
          'gl': 'Colgar o abrigo na súa percha con axuda mínima',
          'es': 'Colgar el abrigo en su percha con ayuda mínima'
        },
        'pautasRecast': [
          {
            'expresionMenor': {'gl': 'Abrigo chan!', 'es': 'Abrigo suelo!'},
            'modeladoIndirecto': {
              'gl': 'Ai, o abrigo quere durmir na súa percha! Up on the hook, zip!',
              'es': 'Ay, el abrigo quiere dormir en su percha! Up on the hook, zip!'
            },
            'consejoEvitar': {
              'gl': 'Non digas: "Mal, non tires o abrigo, pona na percha"',
              'es': 'No digas: "Mal, no tires el abrigo, ponlo en la percha"'
            }
          }
        ],
        'escenaCotidiana': {
          'gl': 'Recibidor da casa xunto á porta principal',
          'es': 'Recibidor de la casa junto a la puerta principal'
        },
        'enlaceCapsulaAcademyId': 'academy.segundo_ciclo.setembro.01',
      };

      final rutina = MicroRutinaHogarSegundoCiclo.fromJson(json);
      expect(rutina.nichoTiempoMinutos, equals(3));
      expect(rutina.pautasRecast.length, equals(1));
      expect(rutina.pautasRecast.first.expresionMenor.gl, equals('Abrigo chan!'));
      expect(rutina.enlaceCapsulaAcademyId,
          equals('academy.segundo_ciclo.setembro.01'));

      final serialized = rutina.toJson();
      final rutina2 = MicroRutinaHogarSegundoCiclo.fromJson(serialized);
      expect(rutina, equals(rutina2));
    });
  });

  group('AsambleaSegundoCiclo Root Model Tests', () {
    test('instantiates and round-trips complete 4-phase assembly', () {
      final json = {
        'id': 'asamblea.segundo_ciclo.setembro.4_infantil',
        'nivel': '4_infantil',
        'mes': 9,
        'titulo': {
          'gl': 'Setembro: Acollida, espazos escolares e novas rutinas',
          'es': 'Septiembre: Acogida, espacios escolares y nuevas rutinas'
        },
        'centroInteres': {
          'gl': 'A alfombra da asemblea e as rutinas de saúdo',
          'es': 'La alfombra de la asamblea y las rutinas de saludo'
        },
        'metodologiaTpr': 'accion_expandida',
        'duracionTotalMinutos': 10,
        'fases': [
          {
            'orden': 1,
            'tipo': 'apertura_saudo',
            'titulo': {'gl': 'Apertura e saúdo', 'es': 'Apertura y saludo'},
            'duracionSegundos': 90,
            'consignaDocente': {
              'gl': 'Sentarse no círculo e saudar a Lúa',
              'es': 'Sentarse en el círculo y saludar a Lúa'
            },
            'comandosL3': [],
            'repertorioMateriales': [],
          },
          {
            'orden': 2,
            'tipo': 'movement_rhythm_focus',
            'titulo': {
              'gl': 'Foco rítmico e pulso',
              'es': 'Foco rítmico y pulso'
            },
            'duracionSegundos': 120,
            'consignaDocente': {
              'gl': 'Palmas nas pernas a 72 BPM',
              'es': 'Palmas en las piernas a 72 BPM'
            },
            'comandosL3': [],
            'repertorioMateriales': [],
          },
          {
            'orden': 3,
            'tipo': 'core_tpr_challenge',
            'titulo': {
              'gl': 'Reto Núcleo TPR',
              'es': 'Reto Núcleo TPR'
            },
            'duracionSegundos': 270,
            'consignaDocente': {
              'gl': 'Comandos de dúas fases con and e modelado',
              'es': 'Comandos de dos fases con and y modelado'
            },
            'comandosL3': [
              {
                'id': 'cmd.01',
                'textoIngles': 'Stand up and clap hands',
                'accionFisica': {
                  'gl': 'Erguerse e dar palmas',
                  'es': 'Levantarse y dar palmas'
                },
                'modeladoDocente': {
                  'gl': 'Modelado simultáneo',
                  'es': 'Modelado simultáneo'
                }
              }
            ],
            'repertorioMateriales': [],
          },
          {
            'orden': 4,
            'tipo': 'calma_transicion',
            'titulo': {
              'gl': 'Calma e transición',
              'es': 'Calma y transición'
            },
            'duracionSegundos': 120,
            'consignaDocente': {
              'gl': 'Respiración con gasas suaves',
              'es': 'Respiración con gasas suaves'
            },
            'comandosL3': [],
            'repertorioMateriales': [
              {
                'id': 'gasa_algodon',
                'nombre': {'gl': 'Gasa de algodón', 'es': 'Gasa de algodón'},
                'procedencia': {
                  'gl': 'Texido tradicional',
                  'es': 'Tejido tradicional'
                },
                'pautaManipulacion': {
                  'gl': 'Soplar suavemente',
                  'es': 'Soplar suavemente'
                }
              }
            ],
          }
        ],
        'curriculo': {
          'normativa': 'Decreto 150/2022',
          'etapa': 'educacion_infantil',
          'ciclo': 'segundo_ciclo_3_6',
          'nivel': '4_infantil',
          'areas': ['area_1_crecemento_harmonia', 'area_3_comunicacion_representacion'],
          'competenciasClave': ['CCL', 'CPSAA'],
          'criteriosEvaluacion': ['CA1.1', 'CA3.1'],
        },
        'materialesEntorno': [
          {
            'id': 'cesto_vimbio',
            'nombre': {'gl': 'Cesto de vimbio', 'es': 'Cesto de mimbre'},
            'procedencia': {
              'gl': 'Cestería galega',
              'es': 'Cestería gallega'
            },
            'pautaManipulacion': {
              'gl': 'Sentir o tacto orgánico',
              'es': 'Sentir el tacto orgánico'
            }
          }
        ],
        'microRutinaHogar': {
          'id': 'micro.01',
          'titulo': {'gl': 'A percha máxica', 'es': 'La percha mágica'},
          'nichoTiempoMinutos': 3,
          'momentoDelDia': {'gl': 'Tarde', 'es': 'Tarde'},
          'objetivoAutonomia': {
            'gl': 'Colgar o abrigo',
            'es': 'Colgar el abrigo'
          },
          'pautasRecast': [
            {
              'expresionMenor': {'gl': 'Abrigo chan!', 'es': 'Abrigo suelo!'},
              'modeladoIndirecto': {
                'gl': 'Up on the hook, zip!',
                'es': 'Up on the hook, zip!'
              },
              'consejoEvitar': {'gl': 'Non rifar', 'es': 'No regañar'}
            }
          ],
          'escenaCotidiana': {'gl': 'Entrada', 'es': 'Entrada'}
        },
        'revision': {
          'autor': 'Equipo Pedagóxico Lúa',
          'revisorPedagogico': 'Especialista en Educación Infantil',
          'fechaRevision': '2026-09-14',
          'version': '1.0.0',
          'aprobadoParaAula': true
        }
      };

      final asamblea = AsambleaSegundoCiclo.fromJson(json);
      expect(asamblea.id, equals('asamblea.segundo_ciclo.setembro.4_infantil'));
      expect(asamblea.nivel, equals(NivelEducativoSegundoCiclo.infantil4));
      expect(asamblea.mes, equals(9));
      expect(asamblea.metodologiaTpr, equals(MetodologiaTPR.accionExpandida));
      expect(asamblea.metodologia, equals(MetodologiaTPR.accionExpandida));
      expect(asamblea.duracionTotalMinutos, equals(10));
      expect(asamblea.duracionTotalSegundos, equals(600));
      expect(asamblea.hasCanonicalPhases, isTrue);
      expect(asamblea.fases.length, equals(4));

      final fase1 = asamblea.fasePorTipo(TipoFaseAsamblea.aperturaSaudo);
      expect(fase1, isNotNull);
      expect(fase1!.duracionSegundos, equals(90));

      final fase3 = asamblea.fasePorOrden(3);
      expect(fase3, isNotNull);
      expect(fase3!.tipo, equals(TipoFaseAsamblea.coreTprChallenge));
      expect(fase3.comandos.length, equals(1));
      expect(fase3.comandos.first.textoIngles, equals('Stand up and clap hands'));

      // Equality and Round-trip
      final serialized = asamblea.toJson();
      final asamblea2 = AsambleaSegundoCiclo.fromJson(serialized);
      expect(asamblea, equals(asamblea2));
      expect(asamblea.hashCode, equals(asamblea2.hashCode));
    });
  });
}
