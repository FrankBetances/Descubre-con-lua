import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/data/models/asamblea_segundo_ciclo_model.dart';
import 'package:descubre_con_lua/data/models/unidad_model.dart' show Revision;

void main() {
  group('1. Enums and Canonical Phase Specifications', () {
    test('NivelEducativoSegundoCiclo properties, bounds, and string parsers', () {
      expect(NivelEducativoSegundoCiclo.infantil4.clave, equals('4_infantil'));
      expect(NivelEducativoSegundoCiclo.infantil4.tramoEtario, equals('3-4'));
      expect(NivelEducativoSegundoCiclo.infantil4.edadMinima, equals(3));
      expect(NivelEducativoSegundoCiclo.infantil4.edadMaxima, equals(4));
      expect(NivelEducativoSegundoCiclo.infantil4.metodologiaPorDefecto,
          equals(MetodologiaTPR.accionExpandida));
      expect(
        NivelEducativoSegundoCiclo.infantil4.etiqueta.resolve(AppLanguage.gl),
        contains('4.º de Infantil'),
      );

      expect(NivelEducativoSegundoCiclo.infantil5.clave, equals('5_infantil'));
      expect(NivelEducativoSegundoCiclo.infantil5.tramoEtario, equals('4-5'));
      expect(NivelEducativoSegundoCiclo.infantil5.edadMinima, equals(4));
      expect(NivelEducativoSegundoCiclo.infantil5.edadMaxima, equals(5));
      expect(NivelEducativoSegundoCiclo.infantil5.metodologiaPorDefecto,
          equals(MetodologiaTPR.dramatizadoNarrativo));

      expect(NivelEducativoSegundoCiclo.infantil6.clave, equals('6_infantil'));
      expect(NivelEducativoSegundoCiclo.infantil6.tramoEtario, equals('5-6'));
      expect(NivelEducativoSegundoCiclo.infantil6.edadMinima, equals(5));
      expect(NivelEducativoSegundoCiclo.infantil6.edadMaxima, equals(6));
      expect(NivelEducativoSegundoCiclo.infantil6.metodologiaPorDefecto,
          equals(MetodologiaTPR.transaccionalPragmatico));

      expect(NivelEducativoSegundoCiclo.desdeClave('4_infantil'),
          equals(NivelEducativoSegundoCiclo.infantil4));
      expect(NivelEducativoSegundoCiclo.desdeClave('5_infantil'),
          equals(NivelEducativoSegundoCiclo.infantil5));
      expect(NivelEducativoSegundoCiclo.desdeClave('6_infantil'),
          equals(NivelEducativoSegundoCiclo.infantil6));
      expect(NivelEducativoSegundoCiclo.desdeClave('unknown_fallback'),
          equals(NivelEducativoSegundoCiclo.infantil4));
    });

    test('MetodologiaTPR enum and neurocognitive capabilities', () {
      expect(MetodologiaTPR.accionExpandida.clave, equals('accion_expandida'));
      expect(MetodologiaTPR.accionExpandida.usaSenalInhibicion, isFalse);
      expect(MetodologiaTPR.accionExpandida.usaTarjetasIconicas, isFalse);
      expect(MetodologiaTPR.accionExpandida.nivelCorrespondiente,
          equals(NivelEducativoSegundoCiclo.infantil4));

      expect(MetodologiaTPR.dramatizadoNarrativo.clave,
          equals('dramatizado_narrativo'));
      expect(MetodologiaTPR.dramatizadoNarrativo.usaSenalInhibicion, isTrue);
      expect(MetodologiaTPR.dramatizadoNarrativo.usaTarjetasIconicas, isFalse);
      expect(MetodologiaTPR.dramatizadoNarrativo.nivelCorrespondiente,
          equals(NivelEducativoSegundoCiclo.infantil5));

      expect(MetodologiaTPR.transaccionalPragmatico.clave,
          equals('transaccional_pragmatico'));
      expect(MetodologiaTPR.transaccionalPragmatico.usaSenalInhibicion, isFalse);
      expect(MetodologiaTPR.transaccionalPragmatico.usaTarjetasIconicas, isTrue);
      expect(MetodologiaTPR.transaccionalPragmatico.nivelCorrespondiente,
          equals(NivelEducativoSegundoCiclo.infantil6));

      expect(MetodologiaTPR.desdeClave('accion_expandida'),
          equals(MetodologiaTPR.accionExpandida));
      expect(MetodologiaTPR.desdeClave('dramatizado_narrativo'),
          equals(MetodologiaTPR.dramatizadoNarrativo));
      expect(MetodologiaTPR.desdeClave('transaccional_pragmatico'),
          equals(MetodologiaTPR.transaccionalPragmatico));
    });

    test('TipoFaseAsamblea enforces exact 4 canonical durations summing to 600s', () {
      expect(TipoFaseAsamblea.aperturaSaudo.orden, equals(1));
      expect(TipoFaseAsamblea.aperturaSaudo.duracionCanonicoSegundos, equals(90));
      expect(TipoFaseAsamblea.aperturaSaudo.duracionMinutosDecimal, equals(1.5));

      expect(TipoFaseAsamblea.movementRhythmFocus.orden, equals(2));
      expect(TipoFaseAsamblea.movementRhythmFocus.duracionCanonicoSegundos, equals(120));
      expect(TipoFaseAsamblea.movementRhythmFocus.duracionMinutosDecimal, equals(2.0));

      expect(TipoFaseAsamblea.coreTprChallenge.orden, equals(3));
      expect(TipoFaseAsamblea.coreTprChallenge.duracionCanonicoSegundos, equals(270));
      expect(TipoFaseAsamblea.coreTprChallenge.duracionMinutosDecimal, equals(4.5));

      expect(TipoFaseAsamblea.calmaTransicion.orden, equals(4));
      expect(TipoFaseAsamblea.calmaTransicion.duracionCanonicoSegundos, equals(120));
      expect(TipoFaseAsamblea.calmaTransicion.duracionMinutosDecimal, equals(2.0));

      final int totalSeconds = TipoFaseAsamblea.aperturaSaudo.duracionCanonicoSegundos +
          TipoFaseAsamblea.movementRhythmFocus.duracionCanonicoSegundos +
          TipoFaseAsamblea.coreTprChallenge.duracionCanonicoSegundos +
          TipoFaseAsamblea.calmaTransicion.duracionCanonicoSegundos;
      expect(totalSeconds, equals(600), reason: 'Assembly duration must sum to exactly 600s (10 min)');

      expect(TipoFaseAsamblea.porOrden(1), equals(TipoFaseAsamblea.aperturaSaudo));
      expect(TipoFaseAsamblea.porOrden(2), equals(TipoFaseAsamblea.movementRhythmFocus));
      expect(TipoFaseAsamblea.porOrden(3), equals(TipoFaseAsamblea.coreTprChallenge));
      expect(TipoFaseAsamblea.porOrden(4), equals(TipoFaseAsamblea.calmaTransicion));
    });
  });

  group('2. Component Models Serialization and Invariants', () {
    test('ComandoTPR serializes and round-trips correctly', () {
      final json = {
        'id': 'cmd.4i.01',
        'textoIngles': 'Stand up and clap hands',
        'accionFisica': {
          'gl': 'Erguerse amodo e dar palmas',
          'es': 'Levantarse despacio y dar palmas'
        },
        'modeladoDocente': {
          'gl': 'Modelado sincrónico inicial da mestra',
          'es': 'Modelado sincrónico inicial de la maestra'
        },
        'audioAsset': 'assets/voice/l3/stand_up_clap.m4a',
      };

      final cmd = ComandoTPR.fromJson(json);
      expect(cmd.id, equals('cmd.4i.01'));
      expect(cmd.textoIngles, equals('Stand up and clap hands'));
      expect(cmd.accionFisica.gl, equals('Erguerse amodo e dar palmas'));
      expect(cmd.audioAsset, equals('assets/voice/l3/stand_up_clap.m4a'));

      final serialized = cmd.toJson();
      expect(serialized['id'], equals('cmd.4i.01'));
      expect(serialized['textoIngles'], equals('Stand up and clap hands'));

      final cmd2 = ComandoTPR.fromJson(serialized);
      expect(cmd, equals(cmd2));
      expect(cmd.hashCode, equals(cmd2.hashCode));
    });

    test('MaterialNatural serializes with Galician origin and safety advisory', () {
      final json = {
        'id': 'castanas_autoctonas',
        'nombre': {'gl': 'Castañas autóctonas', 'es': 'Castañas autóctonas'},
        'procedencia': {
          'gl': 'Soutos e bosques de Galicia',
          'es': 'Sotos y bosques de Galicia'
        },
        'pautaManipulacion': {
          'gl': 'Sentir o peso e a textura satinada na palma',
          'es': 'Sentir el peso y la textura satinada en la palma'
        },
        'avisoSeguridad': {
          'gl': 'Pezas maiores de 4.0 cm, sen arestas cortantes',
          'es': 'Piezas mayores de 4.0 cm, sin aristas cortantes'
        },
      };

      final mat = MaterialNatural.fromJson(json);
      expect(mat.id, equals('castanas_autoctonas'));
      expect(mat.avisoSeguridad, isNotNull);
      expect(mat.avisoSeguridad!.gl, contains('4.0 cm'));

      final serialized = mat.toJson();
      final mat2 = MaterialNatural.fromJson(serialized);
      expect(mat, equals(mat2));
    });

    test('FaseAsamblea exposes formatted duration and canonical accessors', () {
      final fase = FaseAsamblea(
        orden: 3,
        tipo: TipoFaseAsamblea.coreTprChallenge,
        titulo: const LocalizedString(gl: 'Reto TPR', es: 'Reto TPR'),
        duracionSegundos: 270,
        consignaDocente: const LocalizedString(gl: 'Consigna docente', es: 'Consigna docente'),
        comandosL3: const [
          ComandoTPR(
            id: 'cmd1',
            textoIngles: 'Walk to the circle and sit down',
            accionFisica: LocalizedString(gl: 'Camiñar e sentar', es: 'Caminar y sentarse'),
            modeladoDocente: LocalizedString(gl: 'Fading a 2s', es: 'Fading a 2s'),
          )
        ],
      );

      expect(fase.duracionFormateada, equals('4:30'));
      expect(fase.duracionMinutosEnteros, equals(5)); // round(270/60) = 5
      expect(fase.comandos.length, equals(1));
      expect(fase.comandos.first.textoIngles, equals('Walk to the circle and sit down'));

      final serialized = fase.toJson();
      expect(serialized['orden'], equals(3));
      expect(serialized['duracionSegundos'], equals(270));

      final deserialized = FaseAsamblea.fromJson(serialized);
      expect(fase, equals(deserialized));
    });

    test('CurricularReferenceSegundoCiclo validates Decreto 150/2022 areas and criteria', () {
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
      expect(ref.hasCriterio('CA3.1'), isTrue);
      expect(ref.hasCriterio('CA2.2'), isFalse);

      final serialized = ref.toJson();
      final ref2 = CurricularReferenceSegundoCiclo.fromJson(serialized);
      expect(ref, equals(ref2));
    });

    test('MicroRutinaHogarSegundoCiclo and PautaRecast model home Time & Place (3-5 min)', () {
      final json = {
        'id': 'micro.percha.01',
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
              'gl': 'Ai, o abrigo quere durmir na percha! "Up on the hook, zip!"',
              'es': 'Ay, el abrigo quiere dormir en la percha! "Up on the hook, zip!"'
            },
            'consejoEvitar': {
              'gl': 'Non digas: "Mal, non tires o abrigo ao chan"',
              'es': 'No digas: "Mal, no tires el abrigo al suelo"'
            }
          }
        ],
        'escenaCotidiana': {
          'gl': 'Recibidor xunto á porta',
          'es': 'Recibidor junto a la puerta'
        },
        'enlaceCapsulaAcademyId': 'academy.como_se_aprende_a_hablar.01',
      };

      final rutina = MicroRutinaHogarSegundoCiclo.fromJson(json);
      expect(rutina.nichoTiempoMinutos, inInclusiveRange(3, 5));
      expect(rutina.pautasRecast.length, equals(1));
      expect(rutina.pautasRecast.first.expresionMenor.gl, equals('Abrigo chan!'));
      expect(rutina.pautasRecast.first.consejoEvitar.es, contains('No digas'));

      final serialized = rutina.toJson();
      final rutina2 = MicroRutinaHogarSegundoCiclo.fromJson(serialized);
      expect(rutina, equals(rutina2));
    });
  });

  group('3. Deserialization and Serialization Round-Trip of 4.º, 5.º, and 6.º Models', () {
    test('Round-trip 4.º Infantil: Action-Expanded TPR with 2-clause commands and silent period', () {
      final json4i = {
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
            'titulo': {'gl': 'Apertura e Saúdo', 'es': 'Apertura y Saludo'},
            'duracionSegundos': 90,
            'consignaDocente': {
              'gl': 'Reunión no círculo e saúdo a Lúa',
              'es': 'Reunión en el círculo y saludo a Lúa'
            },
            'comandosL3': [],
            'repertorioMateriales': [],
          },
          {
            'orden': 2,
            'tipo': 'movement_rhythm_focus',
            'titulo': {'gl': 'Foco Rítmico e Pulso', 'es': 'Foco Rítmico y Pulso'},
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
            'titulo': {'gl': 'Reto Núcleo TPR', 'es': 'Reto Núcleo TPR'},
            'duracionSegundos': 270,
            'consignaDocente': {
              'gl': 'Comandos de dúas fases con "and" e modelado decrecente',
              'es': 'Comandos de dos fases con "and" y modelado decreciente'
            },
            'comandosL3': [
              {
                'id': 'cmd.4i.01',
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
              },
              {
                'id': 'cmd.4i.02',
                'textoIngles': 'Walk to the circle and sit down',
                'accionFisica': {
                  'gl': 'Camiñar ao círculo e sentarse',
                  'es': 'Caminar al círculo y sentarse'
                },
                'modeladoDocente': {
                  'gl': 'Fading a 2 segundos',
                  'es': 'Fading a 2 segundos'
                },
              }
            ],
            'repertorioMateriales': [],
          },
          {
            'orden': 4,
            'tipo': 'calma_transicion',
            'titulo': {'gl': 'Calma e Transición', 'es': 'Calma y Transición'},
            'duracionSegundos': 120,
            'consignaDocente': {
              'gl': 'Respiración con gasas de algodón suaves',
              'es': 'Respiración con gasas de algodón suaves'
            },
            'comandosL3': [],
            'repertorioMateriales': [
              {
                'id': 'gasa_algodon',
                'nombre': {'gl': 'Gasa de algodón', 'es': 'Gasa de algodón'},
                'procedencia': {'gl': 'Texido tradicional', 'es': 'Tejido tradicional'},
                'pautaManipulacion': {'gl': 'Soplar suavemente', 'es': 'Soplar suavemente'},
                'avisoSeguridad': {'gl': 'Dimensión 30x30 cm', 'es': 'Dimensión 30x30 cm'},
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
            'id': 'vimbio_cesto',
            'nombre': {'gl': 'Cesto de vimbio', 'es': 'Cesto de mimbre'},
            'procedencia': {'gl': 'Cestería tradicional', 'es': 'Cestería tradicional'},
            'pautaManipulacion': {'gl': 'Tocar fibras', 'es': 'Tocar fibras'},
          }
        ],
        'microRutinaHogar': {
          'id': 'micro.01',
          'titulo': {'gl': 'A percha máxica', 'es': 'La percha mágica'},
          'nichoTiempoMinutos': 3,
          'momentoDelDia': {'gl': 'Tarde', 'es': 'Tarde'},
          'objetivoAutonomia': {'gl': 'Colgar o abrigo', 'es': 'Colgar el abrigo'},
          'pautasRecast': [
            {
              'expresionMenor': {'gl': 'Abrigo chan!', 'es': 'Abrigo suelo!'},
              'modeladoIndirecto': {'gl': 'Up on the hook, zip!', 'es': 'Up on the hook, zip!'},
              'consejoEvitar': {'gl': 'Non rifar', 'es': 'No regañar'}
            }
          ],
          'escenaCotidiana': {'gl': 'Entrada da casa', 'es': 'Entrada de la casa'},
        },
        'revision': {
          'autor': 'Equipo Pedagóxico Lúa',
          'revisorPedagogico': 'Especialista en Educación Infantil',
          'fechaRevision': '2026-09-14',
          'version': '1.0.0',
          'aprobadoParaAula': true
        }
      };

      final asamblea = AsambleaSegundoCiclo.fromJson(json4i);
      expect(asamblea.id, equals('asamblea.segundo_ciclo.setembro.4_infantil'));
      expect(asamblea.nivel, equals(NivelEducativoSegundoCiclo.infantil4));
      expect(asamblea.metodologia, equals(MetodologiaTPR.accionExpandida));
      expect(asamblea.duracionTotalSegundos, equals(600));
      expect(asamblea.hasCanonicalPhases, isTrue);

      final fase3 = asamblea.fasePorTipo(TipoFaseAsamblea.coreTprChallenge)!;
      expect(fase3.comandos.length, equals(2));
      expect(fase3.comandos.first.textoIngles, contains(' and '));

      final serialized = asamblea.toJson();
      final roundTripped = AsambleaSegundoCiclo.fromJson(serialized);
      expect(asamblea, equals(roundTripped));
    });

    test('Round-trip 5.º Infantil: Dramatized & Narrative TPR with Backpack Story and Stop-Signal', () {
      final json5i = {
        'id': 'asamblea.segundo_ciclo.setembro.5_infantil',
        'nivel': '5_infantil',
        'mes': 9,
        'titulo': {
          'gl': 'Setembro: A mochila viaxeira e o camiño á escola',
          'es': 'Septiembre: La mochila viajera y el camino al colegio'
        },
        'centroInteres': {
          'gl': 'A mochila máxica e o control inhibitorio',
          'es': 'La mochila mágica y el control inhibitorio'
        },
        'metodologiaTpr': 'dramatizado_narrativo',
        'duracionTotalMinutos': 10,
        'fases': [
          {
            'orden': 1,
            'tipo': 'apertura_saudo',
            'titulo': {'gl': 'Apertura', 'es': 'Apertura'},
            'duracionSegundos': 90,
            'consignaDocente': {'gl': 'Saúdo', 'es': 'Saludo'},
            'comandosL3': [],
            'repertorioMateriales': [],
          },
          {
            'orden': 2,
            'tipo': 'movement_rhythm_focus',
            'titulo': {'gl': 'Foco Rítmico e Praxias', 'es': 'Foco Rítmico y Praxias'},
            'duracionSegundos': 120,
            'consignaDocente': {
              'gl': 'Rimas dactilares e sons orofaciais: Pitter-patter rain, click-clack shoes',
              'es': 'Rimas dactilares y sonidos orofaciales: Pitter-patter rain, click-clack shoes'
            },
            'comandosL3': [],
            'repertorioMateriales': [],
          },
          {
            'orden': 3,
            'tipo': 'core_tpr_challenge',
            'titulo': {'gl': 'Micro-narrativa da mochila e Freeze', 'es': 'Micro-narrativa de la mochila y Freeze'},
            'duracionSegundos': 270,
            'consignaDocente': {
              'gl': 'Secuencia motriz de causa-efecto con sinal Stop-signal',
              'es': 'Secuencia motriz de causa-efecto con señal Stop-signal'
            },
            'cueAcustica': 'Freeze!',
            'comandosL3': [
              {
                'id': 'cmd.5i.01',
                'textoIngles': 'Put on your backpack and zip it up',
                'accionFisica': {
                  'gl': 'Subir os brazos e pechar a cremalleira cos dedos',
                  'es': 'Subir los brazos y cerrar la cremallera con los dedos'
                },
                'modeladoDocente': {
                  'gl': 'Docente escenifica a carga da mochila',
                  'es': 'Docente escenifica la carga de la mochila'
                }
              },
              {
                'id': 'cmd.5i.02',
                'textoIngles': 'Freeze!',
                'accionFisica': {
                  'gl': 'Parada motriz instantánea como estátuas',
                  'es': 'Parada motriz instantánea como estatuas'
                },
                'modeladoDocente': {
                  'gl': 'Inmobilidade total inmediata',
                  'es': 'Inmovilidad total inmediata'
                }
              }
            ],
            'repertorioMateriales': [],
          },
          {
            'orden': 4,
            'tipo': 'calma_transicion',
            'titulo': {'gl': 'Calma con Castañas', 'es': 'Calma con Castañas'},
            'duracionSegundos': 120,
            'consignaDocente': {
              'gl': 'Rodar as castañas suaves polas palmas das mans',
              'es': 'Rodar las castañas suaves por las palmas de las manos'
            },
            'comandosL3': [],
            'repertorioMateriales': [
              {
                'id': 'castanas_vigo',
                'nombre': {'gl': 'Castañas autóctonas', 'es': 'Castañas autóctonas'},
                'procedencia': {'gl': 'Soutos galegos', 'es': 'Sotos gallegos'},
                'pautaManipulacion': {'gl': 'Rodar polas palmas', 'es': 'Rodar por las palmas'},
                'avisoSeguridad': {'gl': 'Diámetro > 4.0 cm', 'es': 'Diámetro > 4.0 cm'}
              }
            ],
          }
        ],
        'curriculo': {
          'normativa': 'Decreto 150/2022',
          'etapa': 'educacion_infantil',
          'ciclo': 'segundo_ciclo_3_6',
          'nivel': '5_infantil',
          'areas': ['area_1_crecemento_harmonia', 'area_3_comunicacion_representacion'],
          'competenciasClave': ['CCL', 'CPSAA'],
          'criteriosEvaluacion': ['CA1.3', 'CA3.2'],
        },
        'materialesEntorno': [],
        'microRutinaHogar': {
          'id': 'micro.5i.01',
          'titulo': {'gl': 'A mochila preparada', 'es': 'La mochila preparada'},
          'nichoTiempoMinutos': 4,
          'momentoDelDia': {'gl': 'Noite antes de durmir', 'es': 'Noche antes de dormir'},
          'objetivoAutonomia': {'gl': 'Gardar a botella de auga', 'es': 'Guardar la botella de agua'},
          'pautasRecast': [
            {
              'expresionMenor': {'gl': 'Botella dentro!', 'es': 'Botella dentro!'},
              'modeladoIndirecto': {
                'gl': 'Moi ben, a botella xa está dentro da mochila!',
                'es': 'Muy bien, la botella ya está dentro de la mochila!'
              },
              'consejoEvitar': {'gl': 'Non dicir "Así non"', 'es': 'No decir "Así no"'}
            }
          ],
          'escenaCotidiana': {'gl': 'Habitación', 'es': 'Habitación'},
        },
        'revision': {
          'autor': 'Equipo Pedagóxico Lúa',
          'revisorPedagogico': 'Especialista en Educación Infantil',
          'fechaRevision': '2026-09-14',
          'version': '1.0.0',
          'aprobadoParaAula': true
        }
      };

      final asamblea = AsambleaSegundoCiclo.fromJson(json5i);
      expect(asamblea.nivel, equals(NivelEducativoSegundoCiclo.infantil5));
      expect(asamblea.metodologia, equals(MetodologiaTPR.dramatizadoNarrativo));
      expect(asamblea.metodologia.usaSenalInhibicion, isTrue);

      final fase3 = asamblea.fasePorTipo(TipoFaseAsamblea.coreTprChallenge)!;
      expect(fase3.cueAcustica, equals('Freeze!'));
      expect(fase3.comandos.any((c) => c.textoIngles == 'Freeze!'), isTrue);

      final serialized = asamblea.toJson();
      final roundTripped = AsambleaSegundoCiclo.fromJson(serialized);
      expect(asamblea, equals(roundTripped));
    });

    test('Round-trip 6.º Infantil: Transactional TPR with Peer-to-Peer and Scallop Shells', () {
      final json6i = {
        'id': 'asamblea.segundo_ciclo.setembro.6_infantil',
        'nivel': '6_infantil',
        'mes': 9,
        'titulo': {
          'gl': 'Setembro: Axudámonos cos abrigos e asemblea cooperativa',
          'es': 'Septiembre: Nos ayudamos con los abrigos y asamblea cooperativa'
        },
        'centroInteres': {
          'gl': 'Xogos transaccionais entre iguais con tarxetas icónicas',
          'es': 'Juegos transaccionales entre iguales con tarjetas icónicas'
        },
        'metodologiaTpr': 'transaccional_pragmatico',
        'duracionTotalMinutos': 10,
        'fases': [
          {
            'orden': 1,
            'tipo': 'apertura_saudo',
            'titulo': {'gl': 'Saúdo en Parellas', 'es': 'Saludo en Parejas'},
            'duracionSegundos': 90,
            'consignaDocente': {'gl': 'High five en parellas', 'es': 'High five en parejas'},
            'comandosL3': [],
            'repertorioMateriales': [],
          },
          {
            'orden': 2,
            'tipo': 'movement_rhythm_focus',
            'titulo': {'gl': 'Compás Rítmico Cruzado', 'es': 'Compás Rítmico Cruzado'},
            'duracionSegundos': 120,
            'consignaDocente': {'gl': 'Palmas cruzadas entre iguais', 'es': 'Palmas cruzadas entre iguales'},
            'comandosL3': [],
            'repertorioMateriales': [],
          },
          {
            'orden': 3,
            'tipo': 'core_tpr_challenge',
            'titulo': {'gl': 'Reto Transaccional con Tarxeta Icónica', 'es': 'Reto Transaccional con Tarjeta Icónica'},
            'duracionSegundos': 270,
            'consignaDocente': {
              'gl': 'A crianza A amosa a tarxeta sen texto e a crianza B executa o comando',
              'es': 'El menor A muestra la tarjeta sin texto y el menor B ejecuta el comando'
            },
            'comandosL3': [
              {
                'id': 'cmd.6i.01',
                'textoIngles': 'Walk to the yellow peg and hang the coat',
                'accionFisica': {
                  'gl': 'Guiar ao compañeiro ata a percha amarela e colgar o abrigo',
                  'es': 'Guiar al compañero hasta la percha amarilla y colgar el abrigo'
                },
                'modeladoDocente': {
                  'gl': 'Acompañamento discreto sen interrupción',
                  'es': 'Acompañamiento discreto sin interrupción'
                }
              }
            ],
            'repertorioMateriales': [],
          },
          {
            'orden': 4,
            'tipo': 'calma_transicion',
            'titulo': {'gl': 'Calma con Cunchas da Ría de Vigo', 'es': 'Calma con Conchas de la Ría de Vigo'},
            'duracionSegundos': 120,
            'consignaDocente': {
              'gl': 'Escoitar o eco do mar coas cunchas e deixalas no cesto de vimbio',
              'es': 'Escuchar el eco del mar con las conchas y dejarlas en el cesto de mimbre'
            },
            'comandosL3': [],
            'repertorioMateriales': [
              {
                'id': 'cunchas_ria_vigo',
                'nombre': {'gl': 'Cunchas de vieira da Ría de Vigo', 'es': 'Conchas de vieira de la Ría de Vigo'},
                'procedencia': {'gl': 'Praias e bateas da ría', 'es': 'Playas y bateas de la ría'},
                'pautaManipulacion': {
                  'gl': 'Tocar a textura acanalada e o nácar liso',
                  'es': 'Tocar la textura acanalada y el nácar liso'
                },
                'avisoSeguridad': {
                  'gl': 'Diámetro > 5.0 cm, esterilizadas e sen bordos cortantes',
                  'es': 'Diámetro > 5.0 cm, esterilizadas y sin bordes cortantes'
                }
              }
            ],
          }
        ],
        'curriculo': {
          'normativa': 'Decreto 150/2022',
          'etapa': 'educacion_infantil',
          'ciclo': 'segundo_ciclo_3_6',
          'nivel': '6_infantil',
          'areas': ['area_2_descubrimento_contorna', 'area_3_comunicacion_representacion'],
          'competenciasClave': ['CCL', 'STEM'],
          'criteriosEvaluacion': ['CA2.2', 'CA3.3'],
        },
        'materialesEntorno': [],
        'microRutinaHogar': {
          'id': 'micro.6i.01',
          'titulo': {'gl': 'A zapateira autónoma', 'es': 'El zapatero autónomo'},
          'nichoTiempoMinutos': 5,
          'momentoDelDia': {'gl': 'Entrada na casa', 'es': 'Entrada en la casa'},
          'objetivoAutonomia': {'gl': 'Colocar os zapatos no seu andel', 'es': 'Colocar los zapatos en su estante'},
          'pautasRecast': [
            {
              'expresionMenor': {'gl': 'Zapatos gardados!', 'es': 'Zapatos guardados!'},
              'modeladoIndirecto': {
                'gl': 'Que ben! Gardaches os zapatos no andel azul ti soa!',
                'es': '¡Qué bien! ¡Has guardado los zapatos en el estante azul tú sola!'
              },
              'consejoEvitar': {'gl': 'Evitar esixencia de rapidez', 'es': 'Evitar exigencia de rapidez'}
            }
          ],
          'escenaCotidiana': {'gl': 'Entrada', 'es': 'Entrada'},
        },
        'revision': {
          'autor': 'Equipo Pedagóxico Lúa',
          'revisorPedagogico': 'Especialista en Educación Infantil',
          'fechaRevision': '2026-09-14',
          'version': '1.0.0',
          'aprobadoParaAula': true
        }
      };

      final asamblea = AsambleaSegundoCiclo.fromJson(json6i);
      expect(asamblea.nivel, equals(NivelEducativoSegundoCiclo.infantil6));
      expect(asamblea.metodologia, equals(MetodologiaTPR.transaccionalPragmatico));
      expect(asamblea.metodologia.usaTarjetasIconicas, isTrue);

      final fase4 = asamblea.fasePorTipo(TipoFaseAsamblea.calmaTransicion)!;
      expect(fase4.materiaisNaturais.length, equals(1));
      expect(fase4.materiaisNaturais.first.id, equals('cunchas_ria_vigo'));
      expect(fase4.materiaisNaturais.first.avisoSeguridad!.gl, contains('5.0 cm'));

      final serialized = asamblea.toJson();
      final roundTripped = AsambleaSegundoCiclo.fromJson(serialized);
      expect(asamblea, equals(roundTripped));
    });
  });

  group('4. Invariant Enforcement and Edge Cases Tests', () {
    test('enforces that total duration is exactly 600s (10 minutes)', () {
      final asambleaValida = AsambleaSegundoCiclo.fromJson({
        'id': 'test.duracion',
        'nivel': '4_infantil',
        'mes': 9,
        'titulo': {'gl': 'T', 'es': 'T'},
        'centroInteres': {'gl': 'C', 'es': 'C'},
        'metodologiaTpr': 'accion_expandida',
        'duracionTotalMinutos': 10,
        'fases': [
          {'orden': 1, 'tipo': 'apertura_saudo', 'titulo': {'gl': '1', 'es': '1'}, 'duracionSegundos': 90, 'consignaDocente': {'gl': 'C', 'es': 'C'}},
          {'orden': 2, 'tipo': 'movement_rhythm_focus', 'titulo': {'gl': '2', 'es': '2'}, 'duracionSegundos': 120, 'consignaDocente': {'gl': 'C', 'es': 'C'}},
          {'orden': 3, 'tipo': 'core_tpr_challenge', 'titulo': {'gl': '3', 'es': '3'}, 'duracionSegundos': 270, 'consignaDocente': {'gl': 'C', 'es': 'C'}},
          {'orden': 4, 'tipo': 'calma_transicion', 'titulo': {'gl': '4', 'es': '4'}, 'duracionSegundos': 120, 'consignaDocente': {'gl': 'C', 'es': 'C'}},
        ],
        'curriculo': {
          'normativa': 'Decreto 150/2022',
          'etapa': 'educacion_infantil',
          'ciclo': 'segundo_ciclo_3_6',
          'nivel': '4_infantil',
          'areas': ['area_1_crecemento_harmonia', 'area_3_comunicacion_representacion'],
          'criteriosEvaluacion': ['CA1.1', 'CA3.1']
        },
        'revision': {'autor': 'A', 'revisorPedagogico': 'R', 'fechaRevision': '2026-09-14', 'version': '1.0.0', 'aprobadoParaAula': true}
      });

      expect(asambleaValida.duracionTotalSegundos, equals(600));
      expect(asambleaValida.hasCanonicalPhases, isTrue);

      // Mutating one phase duration violates canonical phase configuration
      final faseInvalida = asambleaValida.fases[0].copyWith(duracionSegundos: 60);
      final List<FaseAsamblea> fasesMutadas = [
        faseInvalida,
        asambleaValida.fases[1],
        asambleaValida.fases[2],
        asambleaValida.fases[3],
      ];

      final asambleaInvalida = asambleaValida.copyWith(fases: fasesMutadas);
      expect(asambleaInvalida.duracionTotalSegundos, equals(570));
      expect(asambleaInvalida.hasCanonicalPhases, isFalse);
    });

    test('rejects assemblies with fewer than 4 phases or wrong sequence', () {
      final asambleaIncompleta = AsambleaSegundoCiclo.fromJson({
        'id': 'test.incompleta',
        'nivel': '4_infantil',
        'mes': 9,
        'titulo': {'gl': 'T', 'es': 'T'},
        'centroInteres': {'gl': 'C', 'es': 'C'},
        'metodologiaTpr': 'accion_expandida',
        'duracionTotalMinutos': 8,
        'fases': [
          {'orden': 1, 'tipo': 'apertura_saudo', 'titulo': {'gl': '1', 'es': '1'}, 'duracionSegundos': 90, 'consignaDocente': {'gl': 'C', 'es': 'C'}},
          {'orden': 2, 'tipo': 'movement_rhythm_focus', 'titulo': {'gl': '2', 'es': '2'}, 'duracionSegundos': 120, 'consignaDocente': {'gl': 'C', 'es': 'C'}},
          {'orden': 3, 'tipo': 'core_tpr_challenge', 'titulo': {'gl': '3', 'es': '3'}, 'duracionSegundos': 270, 'consignaDocente': {'gl': 'C', 'es': 'C'}},
        ],
        'curriculo': {
          'normativa': 'Decreto 150/2022',
          'etapa': 'educacion_infantil',
          'ciclo': 'segundo_ciclo_3_6',
          'nivel': '4_infantil',
          'areas': ['area_3_comunicacion_representacion'],
          'criteriosEvaluacion': ['CA3.1']
        },
        'revision': {'autor': 'A', 'revisorPedagogico': 'R', 'fechaRevision': '2026-09-14', 'version': '1.0.0', 'aprobadoParaAula': true}
      });

      expect(asambleaIncompleta.fases.length, equals(3));
      expect(asambleaIncompleta.hasCanonicalPhases, isFalse);
    });

    test('handles missing or blank optional fields defensively without throwing', () {
      final jsonDefensivo = {
        'id': 'test.defensivo',
        'nivel': '4_infantil',
        'mes': 9,
        'titulo': {'gl': 'T', 'es': 'T'},
        'centroInteres': {'gl': 'C', 'es': 'C'},
        'metodologiaTpr': 'accion_expandida',
        'duracionTotalMinutos': 10,
        'fases': [],
        'curriculo': {
          'normativa': 'Decreto 150/2022',
          'etapa': 'educacion_infantil',
          'ciclo': 'segundo_ciclo_3_6',
          'nivel': '4_infantil',
          'areas': [],
          'criteriosEvaluacion': []
        },
        'revision': {
          'autor': 'A',
          'revisorPedagogico': 'R',
          'fechaRevision': '2026-09-14',
          'version': '1.0.0',
          'aprobadoParaAula': false
        }
      };

      final asamblea = AsambleaSegundoCiclo.fromJson(jsonDefensivo);
      expect(asamblea.id, equals('test.defensivo'));
      expect(asamblea.fases, isEmpty);
      expect(asamblea.materialesEntorno, isEmpty);
      expect(asamblea.microRutinaHogar, isNull);
    });
  });
}
