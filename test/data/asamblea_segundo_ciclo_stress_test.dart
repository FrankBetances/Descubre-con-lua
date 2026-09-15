import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/asamblea_segundo_ciclo_model.dart';
import 'package:descubre_con_lua/data/models/unidad_model.dart' show Revision;
import 'package:descubre_con_lua/data/repositories/content_repository.dart';

void main() {
  final loader = ContentAssetLoader();

  // Reference fixture for deep nesting tests
  Map<String, dynamic> buildCanonicalFixture({
    String id = 'asamblea.setembro.4_infantil',
    String nivel = '4_infantil',
    int mes = 9,
    String? audioAssetCmd = 'assets/voice/l3/stand_up_clap.m4a',
    String? cueAcustica,
    String? avisoSeguridadMat = 'Pezas maiores de 4.0 cm',
    String? enlaceCapsula = 'academy.como_se_aprende_a_hablar.01',
  }) {
    return {
      'id': id,
      'nivel': nivel,
      'mes': mes,
      'titulo': {
        'gl': 'Setembro: Acollida e espazos',
        'es': 'Septiembre: Acogida y espacios',
        'en': 'September: Welcome and spaces'
      },
      'centroInteres': {
        'gl': 'A alfombra da asemblea',
        'es': 'La alfombra de la asamblea',
        'en': 'The assembly carpet'
      },
      'metodologiaTpr': 'accion_expandida',
      'duracionTotalMinutos': 10,
      'fases': [
        {
          'orden': 1,
          'tipo': 'apertura_saudo',
          'titulo': {'gl': 'Apertura', 'es': 'Apertura', 'en': 'Opening'},
          'duracionSegundos': 90,
          'consignaDocente': {
            'gl': 'Saúdo a Lúa',
            'es': 'Saludo a Lúa',
            'en': 'Greeting to Lúa'
          },
          'comandosL3': [],
          'repertorioMateriales': [],
        },
        {
          'orden': 2,
          'tipo': 'movement_rhythm_focus',
          'titulo': {'gl': 'Ritmo', 'es': 'Ritmo', 'en': 'Rhythm'},
          'duracionSegundos': 120,
          'consignaDocente': {
            'gl': 'Palmas a 72 BPM',
            'es': 'Palmas a 72 BPM',
            'en': 'Claps at 72 BPM'
          },
          'comandosL3': [],
          'repertorioMateriales': [],
        },
        {
          'orden': 3,
          'tipo': 'core_tpr_challenge',
          'titulo': {'gl': 'Reto TPR', 'es': 'Reto TPR', 'en': 'Core TPR'},
          'duracionSegundos': 270,
          'consignaDocente': {
            'gl': 'Comandos de 2 fases',
            'es': 'Comandos de 2 fases',
            'en': '2-phase commands'
          },
          if (cueAcustica != null) 'cueAcustica': cueAcustica,
          'comandosL3': [
            {
              'id': 'cmd.4i.01',
              'textoIngles': 'Stand up and clap hands',
              'accionFisica': {
                'gl': 'Erguerse e dar palmas',
                'es': 'Levantarse y dar palmas',
                'en': 'Stand up and clap'
              },
              'modeladoDocente': {
                'gl': 'Modelado sincrónico',
                'es': 'Modelado sincrónico',
                'en': 'Synchronous modeling'
              },
              if (audioAssetCmd != null) 'audioAsset': audioAssetCmd,
            }
          ],
          'repertorioMateriales': [],
        },
        {
          'orden': 4,
          'tipo': 'calma_transicion',
          'titulo': {'gl': 'Calma', 'es': 'Calma', 'en': 'Calm'},
          'duracionSegundos': 120,
          'consignaDocente': {
            'gl': 'Respiración',
            'es': 'Respiración',
            'en': 'Breathing'
          },
          'comandosL3': [],
          'repertorioMateriales': [
            {
              'id': 'gasa_algodon',
              'nombre': {
                'gl': 'Gasa de algodón',
                'es': 'Gasa de algodón',
                'en': 'Cotton gauze'
              },
              'procedencia': {
                'gl': 'Tecido tradicional',
                'es': 'Tejido tradicional',
                'en': 'Traditional fabric'
              },
              'pautaManipulacion': {
                'gl': 'Soplar suave',
                'es': 'Soplar suave',
                'en': 'Blow gently'
              },
              if (avisoSeguridadMat != null)
                'avisoSeguridad': {
                  'gl': avisoSeguridadMat,
                  'es': avisoSeguridadMat,
                  'en': avisoSeguridadMat
                },
            }
          ],
        }
      ],
      'curriculo': {
        'normativa': 'Decreto 150/2022',
        'etapa': 'educacion_infantil',
        'ciclo': 'segundo_ciclo_3_6',
        'nivel': '4_infantil',
        'areas': [
          'area_1_crecemento_harmonia',
          'area_3_comunicacion_representacion'
        ],
        'competenciasClave': ['CCL', 'CPSAA'],
        'criteriosEvaluacion': ['CA1.1', 'CA3.1'],
      },
      'materialesEntorno': [
        {
          'id': 'vimbio_cesto',
          'nombre': {
            'gl': 'Cesto de vimbio',
            'es': 'Cesto de mimbre',
            'en': 'Wicker basket'
          },
          'procedencia': {
            'gl': 'Cestería tradicional',
            'es': 'Cestería tradicional',
            'en': 'Traditional basketry'
          },
          'pautaManipulacion': {
            'gl': 'Tocar fibras',
            'es': 'Tocar fibras',
            'en': 'Touch fibers'
          },
        }
      ],
      'microRutinaHogar': {
        'id': 'micro.01',
        'titulo': {
          'gl': 'A percha máxica',
          'es': 'La percha mágica',
          'en': 'The magic hook'
        },
        'nichoTiempoMinutos': 3,
        'momentoDelDia': {
          'gl': 'Ao chegar da escola',
          'es': 'Al llegar del colegio',
          'en': 'When arriving home'
        },
        'objetivoAutonomia': {
          'gl': 'Colgar o abrigo',
          'es': 'Colgar el abrigo',
          'en': 'Hang the coat'
        },
        'pautasRecast': [
          {
            'expresionMenor': {
              'gl': 'Abrigo chan!',
              'es': 'Abrigo suelo!',
              'en': 'Coat floor!'
            },
            'modeladoIndirecto': {
              'gl': 'Up on the hook, zip!',
              'es': 'Up on the hook, zip!',
              'en': 'Up on the hook, zip!'
            },
            'consejoEvitar': {
              'gl': 'Non rifar',
              'es': 'No regañar',
              'en': 'Do not scold'
            }
          }
        ],
        'escenaCotidiana': {
          'gl': 'Entrada da casa',
          'es': 'Entrada de la casa',
          'en': 'Home entrance'
        },
        if (enlaceCapsula != null) 'enlaceCapsulaAcademyId': enlaceCapsula,
      },
      'revision': {
        'autor': 'Equipo Pedagóxico Lúa',
        'revisorPedagogico': 'Especialista en Educación Infantil',
        'fechaRevision': '2026-09-14',
        'version': '1.0.0',
        'aprobadoParaAula': true
      }
    };
  }

  group('Adversarial Suite 1: Malformed & Corrupted JSON Root & Structure Payloads', () {
    test('strictly rejects non-map roots via FormatException', () {
      final invalidRoots = [
        '""',
        '   ',
        '[]',
        '["item1", "item2"]',
        '12345',
        'true',
        'false',
        'null',
        '{"unterminated_json": ',
        '{"id": "test", missing_bracket',
      ];

      for (final payload in invalidRoots) {
        expect(
          () => loader.parseAsambleaSegundoCiclo(payload),
          throwsFormatException,
          reason: 'Payload should have been rejected as malformed: $payload',
        );
      }
    });

    test('strictly rejects JSON missing required root "id" key', () {
      final missingIdPayloads = [
        '{}',
        '{"mes": 9, "nivel": "4_infantil"}',
        '{"titulo": {"gl": "T", "es": "T"}}',
        '{"id": null}',
      ];

      for (final payload in missingIdPayloads) {
        expect(
          () => loader.parseAsambleaSegundoCiclo(payload),
          throwsFormatException,
          reason: 'Should reject payload without root "id": $payload',
        );
      }
    });

    test('tolerates non-list and corrupted list contents in child arrays', () {
      final corruptedPayload = {
        'id': 'asamblea.corrupted.arrays',
        'fases': 'this is a string not a list',
        'materialesEntorno': 42,
        'curriculo': {
          'areas': 'not a list',
          'competenciasClave': null,
          'criteriosEvaluacion': 123.45,
        },
        'microRutinaHogar': {
          'pautasRecast': false,
        }
      };

      final asamblea = AsambleaSegundoCiclo.fromJson(corruptedPayload);
      expect(asamblea.id, equals('asamblea.corrupted.arrays'));
      expect(asamblea.fases, isEmpty);
      expect(asamblea.materialesEntorno, isEmpty);
      expect(asamblea.curriculo.areas, isEmpty);
      expect(asamblea.curriculo.competenciasClave, equals(['CCL', 'CPSAA', 'CCEC']));
      expect(asamblea.curriculo.criteriosEvaluacion, isEmpty);
      expect(asamblea.microRutinaHogar.pautasRecast, isEmpty);
    });

    test('filters out nulls and corrupted non-map primitives inside array collections', () {
      final payload = {
        'id': 'asamblea.dirty.list',
        'fases': [
          null,
          'invalid_primitive',
          42,
          true,
          [1, 2, 3],
          {
            'orden': 1,
            'tipo': 'apertura_saudo',
            'titulo': {'gl': 'A', 'es': 'A'},
            'duracionSegundos': 90,
            'consignaDocente': {'gl': 'C', 'es': 'C'},
            'comandosL3': [null, 99, 'bad_command'],
            'repertorioMateriales': [null, false, 'bad_material'],
          }
        ],
        'materialesEntorno': [null, 100, 'dirty'],
      };

      final asamblea = AsambleaSegundoCiclo.fromJson(payload);
      expect(asamblea.fases.length, equals(1));
      expect(asamblea.fases.first.orden, equals(1));
      expect(asamblea.fases.first.comandosL3, isEmpty);
      expect(asamblea.fases.first.repertorioMateriales, isEmpty);
      expect(asamblea.materialesEntorno, isEmpty);
    });

    test('safely handles non-string elements inside string lists by stringifying', () {
      final payload = {
        'normativa': 'Decreto 150/2022',
        'etapa': 'educacion_infantil',
        'ciclo': 'segundo_ciclo_3_6',
        'nivel': '4_infantil',
        'areas': [123, true, 'area_1_crecemento_harmonia'],
        'competenciasClave': [999, 'CCL'],
        'criteriosEvaluacion': [45.6, 'CA1.1'],
      };

      final ref = CurricularReferenceSegundoCiclo.fromJson(payload);
      expect(ref.areas, contains('123'));
      expect(ref.areas, contains('true'));
      expect(ref.areas, contains('area_1_crecemento_harmonia'));
      expect(ref.competenciasClave, contains('999'));
      expect(ref.criteriosEvaluacion, contains('45.6'));
    });
  });

  group('Adversarial Suite 2: Minimal Inputs, Missing Optional Fields & Key Formats', () {
    test('minimal valid JSON with only "id" produces fully initialized immutable tree', () {
      final json = {'id': 'asamblea.minimal.valid'};
      final asamblea = AsambleaSegundoCiclo.fromJson(json);

      expect(asamblea.id, equals('asamblea.minimal.valid'));
      expect(asamblea.nivel, equals(NivelEducativoSegundoCiclo.infantil4));
      expect(asamblea.mes, equals(9));
      expect(asamblea.titulo.gl, isEmpty);
      expect(asamblea.centroInteres.gl, isEmpty);
      expect(asamblea.metodologiaTpr, equals(MetodologiaTPR.accionExpandida));
      expect(asamblea.duracionTotalMinutos, equals(10));
      expect(asamblea.fases, isEmpty);
      expect(asamblea.materialesEntorno, isEmpty);
      expect(asamblea.curriculo.normativa, equals('Decreto 150/2022'));
      expect(asamblea.curriculo.etapa, equals('educacion_infantil'));
      expect(asamblea.curriculo.ciclo, equals('segundo_ciclo_3_6'));
      expect(asamblea.microRutinaHogar.nichoTiempoMinutos, equals(3));
      expect(asamblea.microRutinaHogar.pautasRecast, isEmpty);
      expect(asamblea.revision.version, equals('1.0.0'));
      expect(asamblea.revision.aprobadoParaAula, isFalse);
    });

    test('full parity between snake_case and camelCase serialization keys', () {
      final snakeCaseJson = {
        'id': 'asamblea.snake.test',
        'nivel': '5_infantil',
        'mes': 9,
        'titulo': {'gl': 'Título', 'es': 'Título'},
        'centro_interes': {'gl': 'Centro', 'es': 'Centro'},
        'metodologia_tpr': 'dramatizado_narrativo',
        'duracion_total_minutos': 10,
        'fases': [
          {
            'orden': 1,
            'tipo': 'apertura_saudo',
            'titulo': {'gl': 'A', 'es': 'A'},
            'duracion_segundos': 90,
            'consigna_docente': {'gl': 'CD', 'es': 'CD'},
            'comandos_l3': [
              {
                'id': 'c1',
                'texto_ingles': 'Freeze!',
                'accion_fisica': {'gl': 'Parar', 'es': 'Parar'},
                'modelado_docente': {'gl': 'Mod', 'es': 'Mod'},
                'audio_asset': 'assets/voice/freeze.m4a'
              }
            ],
            'cue_acustica': 'Freeze!',
            'audio_asset': 'assets/audio/opening.m4a',
            'repertorio_materiales': [
              {
                'id': 'm1',
                'nombre': {'gl': 'N', 'es': 'N'},
                'procedencia': {'gl': 'P', 'es': 'P'},
                'pauta_manipulacion': {'gl': 'PM', 'es': 'PM'},
                'aviso_seguridad': {'gl': 'AS', 'es': 'AS'}
              }
            ]
          }
        ],
        'curricular': {
          'normativa': 'Decreto 150/2022',
          'etapa': 'educacion_infantil',
          'ciclo': 'segundo_ciclo_3_6',
          'nivel': '5_infantil',
          'areas': ['area_1_crecemento_harmonia'],
          'competencias_clave': ['CCL'],
          'criterios_evaluacion': ['CA1.3']
        },
        'materiales_entorno': [
          {
            'id': 'm2',
            'nombre': {'gl': 'N2', 'es': 'N2'},
            'procedencia': {'gl': 'P2', 'es': 'P2'},
            'pauta_manipulacion': {'gl': 'PM2', 'es': 'PM2'},
          }
        ],
        'micro_rutina_hogar': {
          'id': 'micro.snake',
          'titulo': {'gl': 'M', 'es': 'M'},
          'nicho_tiempo_minutos': 4,
          'momento_del_dia': {'gl': 'MD', 'es': 'MD'},
          'objetivo_autonomia': {'gl': 'OA', 'es': 'OA'},
          'pautas_recast': [
            {
              'expresion_menor': {'gl': 'EM', 'es': 'EM'},
              'modelado_indirecto': {'gl': 'MI', 'es': 'MI'},
              'consejo_evitar': {'gl': 'CE', 'es': 'CE'}
            }
          ],
          'escena_cotidiana': {'gl': 'EC', 'es': 'EC'},
          'enlace_capsula_academy_id': 'capsula.01'
        },
        'revision': {
          'autor': 'A',
          'revisor_pedagogico': 'R',
          'fecha_revision': '2026-09-14',
          'version': '1.1.0',
          'aprobado_para_aula': true
        }
      };

      final asamblea = AsambleaSegundoCiclo.fromJson(snakeCaseJson);
      expect(asamblea.centroInteres.gl, equals('Centro'));
      expect(asamblea.metodologiaTpr, equals(MetodologiaTPR.dramatizadoNarrativo));
      expect(asamblea.fases.first.duracionSegundos, equals(90));
      expect(asamblea.fases.first.consignaDocente.gl, equals('CD'));
      expect(asamblea.fases.first.comandosL3.first.textoIngles, equals('Freeze!'));
      expect(asamblea.fases.first.comandosL3.first.audioAsset, equals('assets/voice/freeze.m4a'));
      expect(asamblea.fases.first.cueAcustica, equals('Freeze!'));
      expect(asamblea.fases.first.audioAsset, equals('assets/audio/opening.m4a'));
      expect(asamblea.fases.first.repertorioMateriales.first.pautaManipulacion.gl, equals('PM'));
      expect(asamblea.fases.first.repertorioMateriales.first.avisoSeguridad?.gl, equals('AS'));
      expect(asamblea.curriculo.competenciasClave, equals(['CCL']));
      expect(asamblea.curriculo.criteriosEvaluacion, equals(['CA1.3']));
      expect(asamblea.materialesEntorno.first.id, equals('m2'));
      expect(asamblea.microRutinaHogar.nichoTiempoMinutos, equals(4));
      expect(asamblea.microRutinaHogar.pautasRecast.first.expresionMenor.gl, equals('EM'));
      expect(asamblea.microRutinaHogar.enlaceCapsulaAcademyId, equals('capsula.01'));
      expect(asamblea.revision.revisorPedagogico, equals('R'));
      expect(asamblea.revision.aprobadoParaAula, isTrue);
    });

    test('omits null optional fields in serialized JSON map', () {
      const cmdWithoutAudio = ComandoTPR(
        id: 'cmd1',
        textoIngles: 'Clap hands',
        accionFisica: LocalizedString(gl: 'Palmas', es: 'Palmas'),
        modeladoDocente: LocalizedString(gl: 'Modelado', es: 'Modelado'),
        audioAsset: null,
      );
      final jsonCmd = cmdWithoutAudio.toJson();
      expect(jsonCmd.containsKey('audioAsset'), isFalse);

      const matWithoutAviso = MaterialNatural(
        id: 'mat1',
        nombre: LocalizedString(gl: 'N', es: 'N'),
        procedencia: LocalizedString(gl: 'P', es: 'P'),
        pautaManipulacion: LocalizedString(gl: 'M', es: 'M'),
        avisoSeguridad: null,
      );
      final jsonMat = matWithoutAviso.toJson();
      expect(jsonMat.containsKey('avisoSeguridad'), isFalse);

      const faseWithoutOptionals = FaseAsamblea(
        orden: 1,
        tipo: TipoFaseAsamblea.aperturaSaudo,
        titulo: LocalizedString(gl: 'T', es: 'T'),
        duracionSegundos: 90,
        consignaDocente: LocalizedString(gl: 'C', es: 'C'),
        cueAcustica: null,
        audioAsset: null,
      );
      final jsonFase = faseWithoutOptionals.toJson();
      expect(jsonFase.containsKey('cueAcustica'), isFalse);
      expect(jsonFase.containsKey('audioAsset'), isFalse);

      const microWithoutLink = MicroRutinaHogarSegundoCiclo(
        id: 'micro1',
        titulo: LocalizedString(gl: 'T', es: 'T'),
        nichoTiempoMinutos: 3,
        momentoDelDia: LocalizedString(gl: 'M', es: 'M'),
        objetivoAutonomia: LocalizedString(gl: 'O', es: 'O'),
        pautasRecast: [],
        escenaCotidiana: LocalizedString(gl: 'E', es: 'E'),
        enlaceCapsulaAcademyId: null,
      );
      final jsonMicro = microWithoutLink.toJson();
      expect(jsonMicro.containsKey('enlaceCapsulaAcademyId'), isFalse);
    });
  });

  group('Adversarial Suite 3: Deep Structural Equality (==), Symmetry, Transitivity & HashCode', () {
    test('identical structure produces true equality, symmetry, and hash equality', () {
      final a = AsambleaSegundoCiclo.fromJson(buildCanonicalFixture());
      final b = AsambleaSegundoCiclo.fromJson(buildCanonicalFixture());
      final c = AsambleaSegundoCiclo.fromJson(buildCanonicalFixture());

      // Not same heap identity
      expect(identical(a, b), isFalse);

      // Reflexive
      expect(a == a, isTrue);

      // Symmetric
      expect(a == b, isTrue);
      expect(b == a, isTrue);

      // Transitive
      expect(b == c, isTrue);
      expect(a == c, isTrue);

      // Hash code equality
      expect(a.hashCode, equals(b.hashCode));
      expect(b.hashCode, equals(c.hashCode));

      // Collection behavior in Set
      final set = <AsambleaSegundoCiclo>{a, b, c};
      expect(set.length, equals(1));

      // Map key behavior
      final map = <AsambleaSegundoCiclo, String>{a: 'canonical'};
      expect(map[b], equals('canonical'));
      expect(map[c], equals('canonical'));
    });

    test('equality fails when collection order is permuted', () {
      final base = AsambleaSegundoCiclo.fromJson(buildCanonicalFixture());

      // Permuting phases list: swap phase 1 and phase 2
      final permutedPhases = [
        base.fases[1],
        base.fases[0],
        base.fases[2],
        base.fases[3],
      ];
      final mutatedAsamblea = base.copyWith(fases: permutedPhases);
      expect(base == mutatedAsamblea, isFalse);
      expect(base.hashCode == mutatedAsamblea.hashCode, isFalse);

      // Permuting curricular areas
      final permutedCurriculo = base.curriculo.copyWith(
        areas: base.curriculo.areas.reversed.toList(),
      );
      final mutatedCurriculoAsamblea = base.copyWith(curriculo: permutedCurriculo);
      expect(base == mutatedCurriculoAsamblea, isFalse);
      expect(base.hashCode == mutatedCurriculoAsamblea.hashCode, isFalse);
    });
  });

  group('Adversarial Suite 4: Mutation Sensitivity Matrix (23 Individual Mutated Nodes)', () {
    final original = AsambleaSegundoCiclo.fromJson(buildCanonicalFixture());

    void assertMutationBreaksEquality(
      String description,
      AsambleaSegundoCiclo mutated,
    ) {
      expect(
        original == mutated,
        isFalse,
        reason: 'Mutation failed to break equality: $description',
      );
    }

    test('Mutation 1: id change', () {
      assertMutationBreaksEquality(
        'id',
        original.copyWith(id: 'asamblea.setembro.4_infantil.mutated'),
      );
    });

    test('Mutation 2: nivel change', () {
      assertMutationBreaksEquality(
        'nivel',
        original.copyWith(nivel: NivelEducativoSegundoCiclo.infantil5),
      );
    });

    test('Mutation 3: mes change', () {
      assertMutationBreaksEquality(
        'mes',
        original.copyWith(mes: 10),
      );
    });

    test('Mutation 4: titulo localized string change', () {
      assertMutationBreaksEquality(
        'titulo',
        original.copyWith(
          titulo: const LocalizedString(gl: 'Outro Título', es: 'Otro Título'),
        ),
      );
    });

    test('Mutation 5: centroInteres localized string change', () {
      assertMutationBreaksEquality(
        'centroInteres',
        original.copyWith(
          centroInteres: const LocalizedString(gl: 'Outro Centro', es: 'Otro Centro'),
        ),
      );
    });

    test('Mutation 6: metodologiaTpr change', () {
      assertMutationBreaksEquality(
        'metodologiaTpr',
        original.copyWith(metodologiaTpr: MetodologiaTPR.transaccionalPragmatico),
      );
    });

    test('Mutation 7: duracionTotalMinutos change', () {
      assertMutationBreaksEquality(
        'duracionTotalMinutos',
        original.copyWith(duracionTotalMinutos: 15),
      );
    });

    test('Mutation 8: curriculo normativa change', () {
      assertMutationBreaksEquality(
        'curriculo.normativa',
        original.copyWith(
          curriculo: original.curriculo.copyWith(normativa: 'Decreto 200/2024'),
        ),
      );
    });

    test('Mutation 9: curriculo etapa change', () {
      assertMutationBreaksEquality(
        'curriculo.etapa',
        original.copyWith(
          curriculo: original.curriculo.copyWith(etapa: 'primaria'),
        ),
      );
    });

    test('Mutation 10: curriculo ciclo change', () {
      assertMutationBreaksEquality(
        'curriculo.ciclo',
        original.copyWith(
          curriculo: original.curriculo.copyWith(ciclo: 'primeiro_ciclo'),
        ),
      );
    });

    test('Mutation 11: curriculo nivel change', () {
      assertMutationBreaksEquality(
        'curriculo.nivel',
        original.copyWith(
          curriculo: original.curriculo.copyWith(nivel: '5_infantil'),
        ),
      );
    });

    test('Mutation 12: curriculo areas addition', () {
      assertMutationBreaksEquality(
        'curriculo.areas',
        original.copyWith(
          curriculo: original.curriculo.copyWith(
            areas: [...original.curriculo.areas, 'area_2_descubrimento_contorna'],
          ),
        ),
      );
    });

    test('Mutation 13: curriculo competenciasClave change', () {
      assertMutationBreaksEquality(
        'curriculo.competenciasClave',
        original.copyWith(
          curriculo: original.curriculo.copyWith(competenciasClave: ['STEM']),
        ),
      );
    });

    test('Mutation 14: curriculo criteriosEvaluacion addition', () {
      assertMutationBreaksEquality(
        'curriculo.criteriosEvaluacion',
        original.copyWith(
          curriculo: original.curriculo.copyWith(
            criteriosEvaluacion: [...original.curriculo.criteriosEvaluacion, 'CA2.1'],
          ),
        ),
      );
    });

    test('Mutation 15: fase orden change', () {
      final mutatedFases = [
        original.fases[0].copyWith(orden: 9),
        original.fases[1],
        original.fases[2],
        original.fases[3],
      ];
      assertMutationBreaksEquality('fases[0].orden', original.copyWith(fases: mutatedFases));
    });

    test('Mutation 16: fase duracionSegundos change', () {
      final mutatedFases = [
        original.fases[0].copyWith(duracionSegundos: 100),
        original.fases[1],
        original.fases[2],
        original.fases[3],
      ];
      assertMutationBreaksEquality('fases[0].duracionSegundos', original.copyWith(fases: mutatedFases));
    });

    test('Mutation 17: deeply nested comando TPR text change', () {
      final cmdMutated = original.fases[2].comandosL3[0].copyWith(
        textoIngles: 'Jump up and touch toes',
      );
      final faseMutated = original.fases[2].copyWith(comandosL3: [cmdMutated]);
      final mutatedFases = [
        original.fases[0],
        original.fases[1],
        faseMutated,
        original.fases[3],
      ];
      assertMutationBreaksEquality('deep comando text', original.copyWith(fases: mutatedFases));
    });

    test('Mutation 18: deeply nested comando TPR audioAsset change', () {
      final cmdMutated = original.fases[2].comandosL3[0].copyWith(
        audioAsset: 'assets/voice/mutated.m4a',
      );
      final faseMutated = original.fases[2].copyWith(comandosL3: [cmdMutated]);
      final mutatedFases = [
        original.fases[0],
        original.fases[1],
        faseMutated,
        original.fases[3],
      ];
      assertMutationBreaksEquality('deep comando audio', original.copyWith(fases: mutatedFases));
    });

    test('Mutation 19: deeply nested material natural pauta change', () {
      final matMutated = original.fases[3].repertorioMateriales[0].copyWith(
        pautaManipulacion: const LocalizedString(gl: 'Mutada', es: 'Mutada'),
      );
      final faseMutated = original.fases[3].copyWith(repertorioMateriales: [matMutated]);
      final mutatedFases = [
        original.fases[0],
        original.fases[1],
        original.fases[2],
        faseMutated,
      ];
      assertMutationBreaksEquality('deep material natural', original.copyWith(fases: mutatedFases));
    });

    test('Mutation 20: microRutinaHogar nichoTiempoMinutos change', () {
      assertMutationBreaksEquality(
        'microRutinaHogar.nicho',
        original.copyWith(
          microRutinaHogar: original.microRutinaHogar.copyWith(nichoTiempoMinutos: 5),
        ),
      );
    });

    test('Mutation 21: microRutinaHogar pautaRecast expresionMenor change', () {
      final pautaMutated = original.microRutinaHogar.pautasRecast[0].copyWith(
        expresionMenor: const LocalizedString(gl: 'Abrigo roto!', es: 'Abrigo roto!'),
      );
      assertMutationBreaksEquality(
        'pautaRecast.expresionMenor',
        original.copyWith(
          microRutinaHogar: original.microRutinaHogar.copyWith(pautasRecast: [pautaMutated]),
        ),
      );
    });

    test('Mutation 22: microRutinaHogar enlaceCapsulaAcademyId change', () {
      assertMutationBreaksEquality(
        'enlaceCapsula',
        original.copyWith(
          microRutinaHogar: original.microRutinaHogar.copyWith(enlaceCapsulaAcademyId: 'other.capsula'),
        ),
      );
    });

    test('Mutation 23: revision version change', () {
      final revisionMutated = Revision(
        autor: original.revision.autor,
        revisorPedagogico: original.revision.revisorPedagogico,
        fechaRevision: original.revision.fechaRevision,
        version: '2.0.0',
        aprobadoParaAula: original.revision.aprobadoParaAula,
      );
      assertMutationBreaksEquality(
        'revision.version',
        original.copyWith(revision: revisionMutated),
      );
    });
  });

  group('Adversarial Suite 5: Immutability Defense & CopyWith Scaffolding Resilience', () {
    final asamblea = AsambleaSegundoCiclo.fromJson(buildCanonicalFixture());

    test('all collections throw UnsupportedError on modification attempts', () {
      expect(() => asamblea.fases.add(asamblea.fases.first), throwsUnsupportedError);
      expect(() => asamblea.fases.removeAt(0), throwsUnsupportedError);
      expect(() => asamblea.fases.clear(), throwsUnsupportedError);

      expect(() => asamblea.materialesEntorno.add(asamblea.materialesEntorno.first), throwsUnsupportedError);
      expect(() => asamblea.curriculo.areas.add('area_test'), throwsUnsupportedError);
      expect(() => asamblea.curriculo.competenciasClave.add('COMP'), throwsUnsupportedError);
      expect(() => asamblea.curriculo.criteriosEvaluacion.add('CRIT'), throwsUnsupportedError);

      expect(() => asamblea.fases[2].comandosL3.add(asamblea.fases[2].comandosL3.first), throwsUnsupportedError);
      expect(() => asamblea.fases[3].repertorioMateriales.add(asamblea.fases[3].repertorioMateriales.first), throwsUnsupportedError);
      expect(() => asamblea.microRutinaHogar.pautasRecast.add(asamblea.microRutinaHogar.pautasRecast.first), throwsUnsupportedError);
    });

    test('external mutable list mutation does not bleed into copyWith instances', () {
      final mutableCmds = <ComandoTPR>[
        const ComandoTPR(
          id: 'ext.cmd',
          textoIngles: 'Jump',
          accionFisica: LocalizedString(gl: 'Saltar', es: 'Saltar'),
          modeladoDocente: LocalizedString(gl: 'Salto', es: 'Salto'),
        )
      ];

      final fase = asamblea.fases[2].copyWith(comandosL3: mutableCmds);
      expect(fase.comandosL3.length, equals(1));

      // External caller mutates original list
      mutableCmds.add(const ComandoTPR(
        id: 'bleeding.cmd',
        textoIngles: 'Run',
        accionFisica: LocalizedString(gl: 'Correr', es: 'Correr'),
        modeladoDocente: LocalizedString(gl: 'Carreira', es: 'Carrera'),
      ));

      // Fase remains safe and isolated
      expect(fase.comandosL3.length, equals(1));
      expect(fase.comandosL3.first.id, equals('ext.cmd'));
    });

    test('calling copyWith() with zero arguments produces identical clone', () {
      final clone = asamblea.copyWith();
      expect(clone == asamblea, isTrue);
      expect(clone.hashCode, equals(asamblea.hashCode));
    });
  });

  group('Adversarial Suite 6: Durations, Mathematical Summation, and Clock Formatter', () {
    test('duracionFormateada formats various integer edge cases accurately', () {
      FaseAsamblea makeFase(int seconds) {
        return FaseAsamblea(
          orden: 1,
          tipo: TipoFaseAsamblea.aperturaSaudo,
          titulo: const LocalizedString(gl: 'T', es: 'T'),
          duracionSegundos: seconds,
          consignaDocente: const LocalizedString(gl: 'C', es: 'C'),
        );
      }

      expect(makeFase(0).duracionFormateada, equals('0:00'));
      expect(makeFase(0).duracionMinutosEnteros, equals(0));

      expect(makeFase(5).duracionFormateada, equals('0:05'));
      expect(makeFase(59).duracionFormateada, equals('0:59'));
      expect(makeFase(59).duracionMinutosEnteros, equals(1));

      expect(makeFase(90).duracionFormateada, equals('1:30'));
      expect(makeFase(90).duracionMinutosEnteros, equals(2)); // round(1.5) = 2

      expect(makeFase(120).duracionFormateada, equals('2:00'));
      expect(makeFase(120).duracionMinutosEnteros, equals(2));

      expect(makeFase(270).duracionFormateada, equals('4:30'));
      expect(makeFase(270).duracionMinutosEnteros, equals(5)); // round(4.5) = 5

      expect(makeFase(600).duracionFormateada, equals('10:00'));
      expect(makeFase(600).duracionMinutosEnteros, equals(10));
    });

    test('hasCanonicalPhases checks permutations and counts exhaustively', () {
      final valid = AsambleaSegundoCiclo.fromJson(buildCanonicalFixture());
      expect(valid.hasCanonicalPhases, isTrue);

      // Too few phases
      expect(valid.copyWith(fases: valid.fases.sublist(0, 3)).hasCanonicalPhases, isFalse);

      // Too many phases
      expect(valid.copyWith(fases: [...valid.fases, valid.fases.first]).hasCanonicalPhases, isFalse);

      // Swapped phase types
      final swapped = [
        valid.fases[1], // rhythm first
        valid.fases[0],
        valid.fases[2],
        valid.fases[3],
      ];
      expect(valid.copyWith(fases: swapped).hasCanonicalPhases, isFalse);

      // Duplicate phase type
      final dup = [
        valid.fases[0],
        valid.fases[0],
        valid.fases[2],
        valid.fases[3],
      ];
      expect(valid.copyWith(fases: dup).hasCanonicalPhases, isFalse);
    });

    test('fasePorTipo and fasePorOrden lookup methods', () {
      final asamblea = AsambleaSegundoCiclo.fromJson(buildCanonicalFixture());

      expect(asamblea.fasePorTipo(TipoFaseAsamblea.aperturaSaudo)?.orden, equals(1));
      expect(asamblea.fasePorTipo(TipoFaseAsamblea.movementRhythmFocus)?.orden, equals(2));
      expect(asamblea.fasePorTipo(TipoFaseAsamblea.coreTprChallenge)?.orden, equals(3));
      expect(asamblea.fasePorTipo(TipoFaseAsamblea.calmaTransicion)?.orden, equals(4));

      expect(asamblea.fasePorOrden(1)?.tipo, equals(TipoFaseAsamblea.aperturaSaudo));
      expect(asamblea.fasePorOrden(2)?.tipo, equals(TipoFaseAsamblea.movementRhythmFocus));
      expect(asamblea.fasePorOrden(3)?.tipo, equals(TipoFaseAsamblea.coreTprChallenge));
      expect(asamblea.fasePorOrden(4)?.tipo, equals(TipoFaseAsamblea.calmaTransicion));
      expect(asamblea.fasePorOrden(99), isNull);
    });
  });

  group('Adversarial Suite 7: Curricular Invariants & Negative Rejection (Decreto 150/2022)', () {
    test('isValidDecreto150SegundoCiclo validates all required regulatory constraints', () {
      const validRef = CurricularReferenceSegundoCiclo(
        normativa: 'Decreto 150/2022',
        etapa: 'educacion_infantil',
        ciclo: 'segundo_ciclo_3_6',
        nivel: '4_infantil',
        areas: ['area_1_crecemento_harmonia', 'area_3_comunicacion_representacion'],
        criteriosEvaluacion: ['CA1.1', 'CA3.1'],
      );
      expect(validRef.isValidDecreto150SegundoCiclo, isTrue);

      // Invalid normativa
      expect(validRef.copyWith(normativa: 'LOMLOE').isValidDecreto150SegundoCiclo, isFalse);

      // Invalid etapa
      expect(validRef.copyWith(etapa: 'primaria').isValidDecreto150SegundoCiclo, isFalse);

      // Invalid ciclo
      expect(validRef.copyWith(ciclo: 'primeiro_ciclo_0_3').isValidDecreto150SegundoCiclo, isFalse);

      // Invalid nivel
      expect(validRef.copyWith(nivel: '3_infantil').isValidDecreto150SegundoCiclo, isFalse);
      expect(validRef.copyWith(nivel: '1_primaria').isValidDecreto150SegundoCiclo, isFalse);

      // Empty areas
      expect(validRef.copyWith(areas: []).isValidDecreto150SegundoCiclo, isFalse);

      // Illegal area injected
      expect(
        validRef.copyWith(areas: ['area_1_crecemento_harmonia', 'area_ficticia_inventada']).isValidDecreto150SegundoCiclo,
        isFalse,
      );

      // Empty criterios
      expect(validRef.copyWith(criteriosEvaluacion: []).isValidDecreto150SegundoCiclo, isFalse);

      // Illegal criterio injected
      expect(
        validRef.copyWith(criteriosEvaluacion: ['CA1.1', 'CA9.9_inventado']).isValidDecreto150SegundoCiclo,
        isFalse,
      );
    });

    test('NivelEducativoSegundoCiclo bounds and tolerant parser', () {
      expect(NivelEducativoSegundoCiclo.desdeClave('  4_INFANTIL  '), equals(NivelEducativoSegundoCiclo.infantil4));
      expect(NivelEducativoSegundoCiclo.desdeClave('4'), equals(NivelEducativoSegundoCiclo.infantil4));
      expect(NivelEducativoSegundoCiclo.desdeClave('3-4'), equals(NivelEducativoSegundoCiclo.infantil4));
      expect(NivelEducativoSegundoCiclo.desdeClave('infantil4'), equals(NivelEducativoSegundoCiclo.infantil4));

      expect(NivelEducativoSegundoCiclo.desdeClave('5_infantil'), equals(NivelEducativoSegundoCiclo.infantil5));
      expect(NivelEducativoSegundoCiclo.desdeClave('5'), equals(NivelEducativoSegundoCiclo.infantil5));
      expect(NivelEducativoSegundoCiclo.desdeClave('4-5'), equals(NivelEducativoSegundoCiclo.infantil5));
      expect(NivelEducativoSegundoCiclo.desdeClave('infantil5'), equals(NivelEducativoSegundoCiclo.infantil5));

      expect(NivelEducativoSegundoCiclo.desdeClave('6_infantil'), equals(NivelEducativoSegundoCiclo.infantil6));
      expect(NivelEducativoSegundoCiclo.desdeClave('6'), equals(NivelEducativoSegundoCiclo.infantil6));
      expect(NivelEducativoSegundoCiclo.desdeClave('5-6'), equals(NivelEducativoSegundoCiclo.infantil6));
      expect(NivelEducativoSegundoCiclo.desdeClave('infantil6'), equals(NivelEducativoSegundoCiclo.infantil6));

      expect(NivelEducativoSegundoCiclo.desdeClave(null), equals(NivelEducativoSegundoCiclo.infantil4));
      expect(NivelEducativoSegundoCiclo.desdeClave('unknown_fallback'), equals(NivelEducativoSegundoCiclo.infantil4));
    });

    test('MetodologiaTPR parser tolerances', () {
      expect(MetodologiaTPR.desdeClave('accion_expandida'), equals(MetodologiaTPR.accionExpandida));
      expect(MetodologiaTPR.desdeClave('ACCIONEXPANDIDA'), equals(MetodologiaTPR.accionExpandida));
      expect(MetodologiaTPR.desdeClave('dramatizado_narrativo'), equals(MetodologiaTPR.dramatizadoNarrativo));
      expect(MetodologiaTPR.desdeClave('DRAMATIZADONARRATIVO'), equals(MetodologiaTPR.dramatizadoNarrativo));
      expect(MetodologiaTPR.desdeClave('transaccional_pragmatico'), equals(MetodologiaTPR.transaccionalPragmatico));
      expect(MetodologiaTPR.desdeClave('TRANSACCIONALPRAGMATICO'), equals(MetodologiaTPR.transaccionalPragmatico));
      expect(MetodologiaTPR.desdeClave('inexistente'), equals(MetodologiaTPR.accionExpandida));
      expect(MetodologiaTPR.desdeClave(null), equals(MetodologiaTPR.accionExpandida));
    });
  });

  group('Adversarial Suite 8: ContentAssetLoader & ContentRepository Under Adversarial Stress', () {
    test('round-trip serialization with unicode and Galician diacritics', () {
      final fixture = buildCanonicalFixture();
      final asamblea = AsambleaSegundoCiclo.fromJson(fixture);

      final encoded = jsonEncode(asamblea.toJson());
      final decodedAsamblea = loader.parseAsambleaSegundoCiclo(encoded);

      expect(asamblea, equals(decodedAsamblea));
      expect(asamblea.hashCode, equals(decodedAsamblea.hashCode));
      expect(decodedAsamblea.titulo.resolve(AppLanguage.gl), contains('Acollida'));
    });

    test('ContentRepository handles rapid state resets, empty queries, and duplicate keys', () {
      final repo = ContentRepository();
      expect(repo.asambleaSegundoCicloCount, equals(0));
      expect(repo.getAllAsambleasSegundoCicloSync(), isEmpty);
      expect(repo.getAsambleaSegundoCicloByIdSync('any'), isNull);
      expect(repo.getAsambleasByNivelSync(NivelEducativoSegundoCiclo.infantil4), isEmpty);
      expect(repo.getAsambleaByMesYNivelSync(9, NivelEducativoSegundoCiclo.infantil4), isNull);

      final a1 = AsambleaSegundoCiclo.fromJson(buildCanonicalFixture(id: 'same.id', mes: 9));
      final a2 = AsambleaSegundoCiclo.fromJson(buildCanonicalFixture(id: 'same.id', mes: 10));

      // Overwriting by same ID replaces cleanly in repository
      repo.addAsambleaSegundoCiclo(a1);
      expect(repo.asambleaSegundoCicloCount, equals(1));
      expect(repo.getAsambleaSegundoCicloByIdSync('same.id')?.mes, equals(9));

      repo.addAsambleaSegundoCiclo(a2);
      expect(repo.asambleaSegundoCicloCount, equals(1));
      expect(repo.getAsambleaSegundoCicloByIdSync('same.id')?.mes, equals(10));

      // Clear returns repository to pristine initial state
      repo.clear();
      expect(repo.asambleaSegundoCicloCount, equals(0));
      expect(repo.isInitialized, isFalse);
    });
  });
}
