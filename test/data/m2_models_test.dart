import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/data/models/corpus_palabra_model.dart';
import 'package:descubre_con_lua/data/models/cuento_model.dart';
import 'package:descubre_con_lua/data/models/dia_calendario_dual_model.dart';
import 'package:descubre_con_lua/data/models/dinamica_model.dart';
import 'package:descubre_con_lua/data/models/english_corpus_model.dart';
import 'package:descubre_con_lua/data/models/estrategia_model.dart';
import 'package:descubre_con_lua/data/models/fsrs_card_model.dart';
import 'package:descubre_con_lua/data/models/lamina_model.dart';
import 'package:descubre_con_lua/data/models/phonics_model.dart';

void main() {
  group('Milestone 2 Dart Data Models Tests', () {
    test('Cuento model serializes and deserializes correctly', () {
      final json = {
        'id': 'conto_001_s1',
        'cursoId': 'curso_0_2',
        'mesNumero': 1,
        'semanaSugerida': 1,
        'cursoEtiqueta': {'gl': '0 a 2 anos', 'es': '0 a 2 años'},
        'mesNome': {'gl': 'Setembro', 'es': 'Septiembre'},
        'centroInteres': {'gl': 'Mans', 'es': 'Manos'},
        'titulo': {'gl': 'Mans que Saúdan', 'es': 'Manos que Saludan'},
        'sinopse': {'gl': 'O primeiro día...', 'es': 'El primer día...'},
        'nivelLectura': 1,
        'licenza': 'Creative Commons CC BY 4.0',
        'orixeOpenSource': 'Patrimonio Vigo Infantil',
        'tempoEsperaSegundos': 5,
        'tprOral': {
          'fraseEn': 'Wave hello',
          'comandoGl': 'Acena',
          'comandoEs': 'Saluda',
        },
        'paginas': [
          {
            'numero': 1,
            'tituloPagina': {'gl': 'Páxina 1', 'es': 'Página 1'},
            'lamina': 'conto_vigo_2',
            'texto': {'gl': 'Comeza en Vigo.', 'es': 'Comienza en Vigo.'},
            'preguntaImaxe': {'gl': 'Que ves?', 'es': '¿Qué ves?'},
            'guiaAtencion': {'gl': 'Espera 5s', 'es': 'Espera 5s'},
            'vocabularioClave': ['Ollos', 'Man'],
          }
        ],
        'preguntasGraduadas': [
          {
            'nivel': 1,
            'rangoIdade': '0 a 3 anos',
            'tipo': {'gl': 'Literal', 'es': 'Literal'},
            'enunciado': {
              'gl': 'Onde están as mans?',
              'es': '¿Dónde están las manos?'
            },
            'obxectivo': {'gl': 'Sinalar', 'es': 'Señalar'},
            'respostaModelo': {'gl': 'Alí', 'es': 'Allí'},
            'pistaEducadora': {
              'gl': 'Amosa as mans',
              'es': 'Muestra las manos'
            },
          }
        ],
      };

      final cuento = Cuento.fromJson(json);
      expect(cuento.id, equals('conto_001_s1'));
      expect(cuento.cursoId, equals('curso_0_2'));
      expect(cuento.mesNumero, equals(1));
      expect(cuento.semanaSugerida, equals(1));
      expect(cuento.titulo.gl, equals('Mans que Saúdan'));
      expect(cuento.titulo.es, equals('Manos que Saludan'));
      expect(cuento.tprOral?.fraseEn, equals('Wave hello'));
      expect(cuento.paginas.length, equals(1));
      expect(cuento.paginas.first.lamina, equals('conto_vigo_2'));
      expect(cuento.preguntasGraduadas.length, equals(1));
      expect(cuento.preguntasGraduadas.first.nivel, equals(1));

      final serialized = cuento.toJson();
      expect(serialized['id'], equals('conto_001_s1'));
      expect(serialized['paginas'], isA<List>());
      expect(serialized['preguntasGraduadas'], isA<List>());

      final cuento2 = Cuento.fromJson(serialized);
      expect(cuento2, equals(cuento));
      expect(cuento2.hashCode, equals(cuento.hashCode));
    });

    test('Lamina model serializes and deserializes correctly', () {
      final json = {
        'id': 'flashcard_a_apple',
        'numero': 1,
        'categoria': 'alfabeto',
        'gl': 'A · Mazá',
        'es': 'A · Manzana',
        'en': 'A · Apple',
        'cefr': 'Pre-A1',
        'ratio': '3:5',
        'lamina': 'mazan',
        'corHex': '#dc2626',
        'bgHex': '#fef2f2',
        'preguntaSugerida': {'gl': 'Ves a mazá?', 'es': '¿Ves la manzana?'},
        'obxectivo': {
          'gl': 'Recoñecemento fónico',
          'es': 'Reconocimiento fónico'
        },
        'tprAccion': {
          'en': 'Bite apple',
          'gl': 'Morde a mazá',
          'es': 'Muerde la manzana'
        },
      };

      final lamina = Lamina.fromJson(json);
      expect(lamina.id, equals('flashcard_a_apple'));
      expect(lamina.numero, equals(1));
      expect(lamina.categoria, equals('alfabeto'));
      expect(lamina.ratio, equals('3:5'));
      // La clave del dibujo: sin ella la galería no tiene qué pintar.
      expect(lamina.lamina, equals('mazan'));
      expect(lamina.tprAccion?.en, equals('Bite apple'));

      final serialized = lamina.toJson();
      expect(serialized['numero'], equals(1));
      expect(serialized['ratio'], equals('3:5'));

      final lamina2 = Lamina.fromJson(serialized);
      expect(lamina2, equals(lamina));
      expect(lamina2.hashCode, equals(lamina.hashCode));
    });

    test('CorpusPalabra model handles both frequency and CEFR formats', () {
      final jsonCefr = {
        'id_global': 101,
        'lemma': 'water',
        'banda_frecuencia': '1k',
        'nivel_cefr': 'A1/A2',
      };

      final palabra = CorpusPalabra.fromJson(jsonCefr);
      expect(palabra.id, equals(101));
      expect(palabra.lemma, equals('water'));
      expect(palabra.banda, equals('1k'));
      expect(palabra.bandaNumero, equals(1));
      expect(palabra.nivelCefr, equals('A1/A2'));

      final jsonBasic = {
        'id': 202,
        'word': 'beautiful',
        'band': '2k',
      };
      final palabraBasic = CorpusPalabra.fromJson(jsonBasic);
      expect(palabraBasic.id, equals(202));
      expect(palabraBasic.lemma, equals('beautiful'));
      expect(palabraBasic.banda, equals('2k'));
      expect(palabraBasic.bandaNumero, equals(2));
    });

    test('DiaCalendarioDual model handles aula and fogar submodels', () {
      final json = {
        'dia': 1,
        'diaSemana': 0,
        'diaSemanaNumero': 1,
        'nombreDiaSemana': {'gl': 'Luns', 'es': 'Lunes'},
        'semanaNumero': 1,
        'semanaCursoNumero': 1,
        'semanaGlobalNumero': 1,
        'diaCursoNumero': 1,
        'diaGlobalNumero': 1,
        'mesNumero': 1,
        'mesGlobalNumero': 1,
        'fechaClave': 'curso_0_2-mes-1-dia-1',
        'esFinDeSemana': false,
        'temaDia': {'gl': 'Benvida', 'es': 'Bienvenida'},
        'profesorado': {
          'actividadAula': {'gl': 'Pulso 72 bpm', 'es': 'Pulso 72 bpm'},
          'dinamica': {'gl': 'Círculo', 'es': 'Círculo'},
          'duracionMin': 15,
          'tprIngles': 'Sit in circle',
          'consignaDocente': {'gl': 'Contacto visual', 'es': 'Contacto visual'},
        },
        'familias': {
          'rutinaFogar': {'gl': 'Ao espertar', 'es': 'Al despertar'},
          'momento': {'gl': 'Maniñas', 'es': 'Manitas'},
          'senPantallas': true,
          'consignaFamilia': {'gl': 'Calma', 'es': 'Calma'},
          'fraseConexion': {'gl': 'Bos días', 'es': 'Buenos días'},
        }
      };

      final dia = DiaCalendarioDual.fromJson(json);
      expect(dia.dia, equals(1));
      expect(dia.diaSemanaNumero, equals(1));
      expect(dia.diaGlobalNumero, equals(1));
      expect(dia.profesorado.duracionMin, equals(15));
      expect(dia.profesorado.tprIngles, equals('Sit in circle'));
      expect(dia.familias.senPantallas, isTrue);

      final serialized = dia.toJson();
      final dia2 = DiaCalendarioDual.fromJson(serialized);
      expect(dia2, equals(dia));
      expect(dia2.hashCode, equals(dia.hashCode));
    });

    test('MesCurricular50 model parses 50-month curricular units', () {
      final json = {
        'id': 'c1_m1',
        'cursoId': 'curso_0_2',
        'cursoNumero': 1,
        'mesNumero': 1,
        'nombreMes': {'gl': 'Setembro', 'es': 'Septiembre'},
        'icono': 'acollemento',
        'centroInteres': {'gl': 'Acollemento', 'es': 'Acogida'},
        'objetivoPedagogico': {'gl': 'Apego seguro', 'es': 'Apego seguro'},
        'actividadAula': {'gl': 'Saúdo', 'es': 'Saludo'},
        'actividadHogar': {'gl': 'Palmas', 'es': 'Palmas'},
        'rutinaRecomendadaHogar': {'gl': 'Almorzo', 'es': 'Desayuno'},
        'minutosSugeridos': 3,
        'ingles': {
          'lexico': ['Hello', 'Baby'],
          'tpr': ['Clap hands'],
          'frase': 'Hello baby!',
          'audio_id': 'en_c1_m1_hello',
        },
        'dinamicaEvolutiva': {'gl': 'Apego', 'es': 'Apego'},
        'ponteCasaEscola': {'gl': 'Ponte', 'es': 'Puente'},
      };

      final mes = MesCurricular50.fromJson(json);
      expect(mes.id, equals('c1_m1'));
      expect(mes.cursoId, equals('curso_0_2'));
      expect(mes.mesNumero, equals(1));
      expect(mes.ingles.lexico, contains('Hello'));
      expect(mes.ingles.audioId, equals('en_c1_m1_hello'));
    });

    test('FSRSCard model parses and formats timestamps correctly', () {
      final now = DateTime(2026, 9, 20, 10, 0);
      final card = FSRSCard(
        id: 5,
        lemma: 'listen',
        difficulty: 4.5,
        stability: 2.4,
        retrievability: 0.9,
        reps: 1,
        lapses: 0,
        lastReviewDate: now,
        nextDueDate: now.add(const Duration(days: 2)),
        scheduledDays: 2,
        state: FSRSCardState.review,
      );

      final json = card.toJson();
      expect(json['id'], equals(5));
      expect(json['lemma'], equals('listen'));
      expect(json['state'], equals('review'));

      final fromJson = FSRSCard.fromJson(json);
      expect(fromJson.id, equals(card.id));
      expect(fromJson.lemma, equals(card.lemma));
      expect(fromJson.state, equals(card.state));
    });

    test('EnglishCorpus model parses lexicon and dialogue scenarios', () {
      final json = {
        'words': [
          {
            'id': 'en_hello',
            'rank': 1,
            'word': 'hello',
            'phonetic': '/həˈloʊ/',
            'partOfSpeech': 'phrase',
            'translation': {'gl': 'ola', 'es': 'hola'},
            'definition': {'gl': 'Saúdo', 'es': 'Saludo'},
            'category': 'social_phrases',
            'cefr': 'Pre-A1',
            'targetAge': '0-2',
            'naturalPhrase': {
              'en': 'Hello friend!',
              'translation': {'gl': 'Ola amigo!', 'es': '¡Hola amigo!'},
            },
            'collocations': ['say hello', 'wave hello'],
            'tprAction': {'gl': 'Acenar coa man', 'es': 'Saludar con la mano'},
            'frequencyTier': 1000,
          }
        ],
        'scenarios': [
          {
            'id': 'sc_water_break',
            'title': {'gl': 'Auga', 'es': 'Agua'},
            'category': 'daily_life',
            'cefr': 'Pre-A1',
            'context': {'gl': 'Merenda', 'es': 'Merienda'},
            'pedagogicalObjective': {'gl': 'Pedir auga', 'es': 'Pedir agua'},
            'turns': [
              {
                'speaker': 'Adult',
                'en': 'Do you want water?',
                'translation': {'gl': 'Queres auga?', 'es': '¿Quieres agua?'},
                'keyVocabulary': ['water'],
              }
            ],
          }
        ],
      };

      final corpus = EnglishCorpus.fromJson(json);
      expect(corpus.words.length, equals(1));
      expect(corpus.words.first.word, equals('hello'));
      expect(corpus.words.first.collocations, contains('say hello'));
      expect(corpus.scenarios.length, equals(1));
      expect(
          corpus.scenarios.first.turns.first.en, equals('Do you want water?'));
    });

    test(
        'PhonicsTaxonomy model parses 44 phonemes, decodable words, and missions',
        () {
      final json = {
        'phonemes': [
          {
            'id': 'ph_short_a',
            'symbolIpa': '/æ/',
            'grapheme': 'a',
            'category': 'short_vowel',
            'name': {'gl': 'A curta', 'es': 'A corta'},
            'exampleWord': {'en': 'apple', 'gl': 'mazá', 'es': 'manzana'},
            'audioCue': '/æ/ as in apple',
            'articulationGuide': {'gl': 'Boca aberta', 'es': 'Boca abierta'},
            'frequencyRank': 1,
            'readingLevel': 1,
            'nfcUid': '04:A1:7E:11',
          }
        ],
        'decodableWords': [
          {
            'id': 'dw_cat',
            'word': 'cat',
            'letters': ['c', 'a', 't'],
            'phonemes': ['ph_c', 'ph_short_a', 'ph_t'],
            'phonemeIpa': ['/k/', '/æ/', '/t/'],
            'wordFamily': '-at',
            'category': 'cvc',
            'level': 1,
            'gl': 'gato',
            'es': 'gato',
            'en': 'cat',
            'sampleSentence': {'gl': 'O gato salta', 'es': 'El gato salta'},
            'audioTrack': 101,
          }
        ],
        'wordFamilies': [
          {
            'id': 'wf_at',
            'rime': '-at',
            'vowelType': 'short_a',
            'level': 1,
            'words': ['cat', 'bat', 'hat'],
          }
        ],
        'missions': [
          {
            'id': 'mis_find_a',
            'title': {'gl': 'Atopa o son A', 'es': 'Encuentra el sonido A'},
            'missionType': 'find_phoneme',
            'targetPhonemeId': 'ph_short_a',
            'expectedInput': ['a'],
            'level': 1,
            'xpReward': 25,
          }
        ],
      };

      final taxonomy = PhonicsTaxonomy.fromJson(json);
      expect(taxonomy.phonemes.length, equals(1));
      expect(taxonomy.phonemes.first.grapheme, equals('a'));
      expect(taxonomy.decodableWords.length, equals(1));
      expect(taxonomy.decodableWords.first.word, equals('cat'));
      expect(taxonomy.wordFamilies.length, equals(1));
      expect(taxonomy.wordFamilies.first.words, contains('cat'));
      expect(taxonomy.missions.length, equals(1));
      expect(taxonomy.missions.first.xpReward, equals(25));
    });

    test(
        'EstrategiaPedagogica and DinamicaPedagogica models serialize correctly',
        () {
      final jsonEst = {
        'id': 'est-espera-5s',
        'clave': 'espera_5s',
        'nome': {'gl': 'Regra dos 5 Segundos', 'es': 'Regla de los 5 Segundos'},
        'subtitulo': {
          'gl': 'Tempo de procesamento',
          'es': 'Tiempo de procesamiento'
        },
        'baseNeurobioloxica': {
          'gl': 'Córtex prefrontal',
          'es': 'Corteza prefrontal'
        },
        'comoAplicarNaAula': {
          'gl': 'Gardar silencio',
          'es': 'Guardar silencio'
        },
        'exemploDialogoAula': {'gl': 'Docente agarda', 'es': 'Docente espera'},
        'erroComunAEvitar': {'gl': 'Présas', 'es': 'Prisas'},
        'consignaDocente': {'gl': 'Silencio fértil', 'es': 'Silencio fértil'},
      };

      final est = EstrategiaPedagogica.fromJson(jsonEst);
      expect(est.id, equals('est-espera-5s'));
      expect(est.clave, equals('espera_5s'));
      expect(est.nome.gl, equals('Regra dos 5 Segundos'));

      final jsonDin = {
        'id': 'din-luns-pulso',
        'clave': 'asemblea_pulso',
        'diaSemana': 'luns',
        'titulo': {'gl': 'Asemblea de Benvida', 'es': 'Asamblea de Bienvenida'},
        'subtitulo': {'gl': 'Pulso 72 bpm', 'es': 'Pulso 72 bpm'},
        'duracionMinutos': 15,
        'ritmoBpm': 72,
        'obxectivo': {'gl': 'Regulación', 'es': 'Regulación'},
        'procedementoPasoAPaso': {'gl': '1. Círculo', 'es': '1. Círculo'},
        'materialSensorial': {'gl': 'Alfombra', 'es': 'Alfombra'},
        'fraseDocente': {'gl': 'Mans abertas', 'es': 'Manos abiertas'},
        'tprIngles': {
          'comando': 'Welcome friends',
          'accion': {'gl': 'Abrir brazos', 'es': 'Abrir brazos'},
        },
      };

      final din = DinamicaPedagogica.fromJson(jsonDin);
      expect(din.id, equals('din-luns-pulso'));
      expect(din.ritmoBpm, equals(72));
      expect(din.tprIngles?.comando, equals('Welcome friends'));
    });
  });
}
