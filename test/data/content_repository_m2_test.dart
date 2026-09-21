import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/corpus_palabra_model.dart';
import 'package:descubre_con_lua/data/models/cuento_model.dart';
import 'package:descubre_con_lua/data/models/dia_calendario_dual_model.dart';
import 'package:descubre_con_lua/data/models/dinamica_model.dart';
import 'package:descubre_con_lua/data/models/english_corpus_model.dart';
import 'package:descubre_con_lua/data/models/estrategia_model.dart';
import 'package:descubre_con_lua/data/models/lamina_model.dart';
import 'package:descubre_con_lua/data/models/phonics_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';

void main() {
  group('ContentRepository Milestone 2 Extensions', () {
    test('in-memory addition and query for Cuentos', () async {
      final repo = ContentRepository();
      const cuento1 = Cuento(
        id: 'conto_001_s1',
        cursoId: 'curso_0_2',
        mesNumero: 1,
        semanaSugerida: 1,
        titulo: LocalizedString(gl: 'Mans que saúdan', es: 'Manos que saludan'),
        sinopse: LocalizedString(gl: 'Descrición', es: 'Descripción'),
        paginas: [],
        preguntasGraduadas: [],
      );
      const cuento2 = Cuento(
        id: 'conto_002_s2',
        cursoId: 'curso_0_2',
        mesNumero: 1,
        semanaSugerida: 2,
        titulo: LocalizedString(gl: 'Ollos curiosos', es: 'Ojos curiosos'),
        sinopse: LocalizedString(gl: 'Descrición 2', es: 'Descripción 2'),
        paginas: [],
        preguntasGraduadas: [],
      );
      const cuento3 = Cuento(
        id: 'conto_041_s1',
        cursoId: 'curso_2_3',
        mesNumero: 1,
        semanaSugerida: 1,
        titulo: LocalizedString(gl: 'Pasos firmes', es: 'Pasos firmes'),
        sinopse: LocalizedString(gl: 'Descrición 3', es: 'Descripción 3'),
        paginas: [],
        preguntasGraduadas: [],
      );

      repo.addCuento(cuento1);
      repo.addCuento(cuento2);
      repo.addCuento(cuento3);

      expect(repo.getCuentoByIdSync('conto_001_s1'), equals(cuento1));
      final byId = await repo.getCuentoById('conto_002_s2');
      expect(byId, equals(cuento2));

      final all02 = await repo.loadCuentos(cursoId: 'curso_0_2');
      expect(all02.length, equals(2));
      expect(all02.map((c) => c.id),
          containsAll(['conto_001_s1', 'conto_002_s2']));

      final mes1Curso2 =
          await repo.loadCuentos(cursoId: 'curso_2_3', mesNumero: 1);
      expect(mes1Curso2.length, equals(1));
      expect(mes1Curso2.first.id, equals('conto_041_s1'));
    });

    test('in-memory addition and query for Laminas', () async {
      final repo = ContentRepository();
      const lamina1 = Lamina(
        id: 'flashcard_a_apple',
        numero: 1,
        categoria: 'alfabeto',
        gl: 'A · Mazá',
        es: 'A · Manzana',
        en: 'A · Apple',
        cefr: 'Pre-A1',
        ratio: '3:5',
      );
      const lamina2 = Lamina(
        id: 'lamina_castrelos_outono',
        numero: 50,
        categoria: 'vigo_natureza',
        gl: 'Parque de Castrelos',
        es: 'Parque de Castrelos',
        en: 'Castrelos Park',
        cefr: 'A1',
        ratio: '16:10',
      );

      repo.addLamina(lamina1);
      repo.addLamina(lamina2);

      expect(repo.getLaminaByIdSync('flashcard_a_apple'), equals(lamina1));
      final byId = await repo.getLaminaById('lamina_castrelos_outono');
      expect(byId, equals(lamina2));

      final alfabeto = await repo.loadLaminas(categoria: 'alfabeto');
      expect(alfabeto.length, equals(1));
      expect(alfabeto.first.id, equals('flashcard_a_apple'));

      final nivelA1 = await repo.loadLaminas(nivel: 'A1');
      expect(nivelA1.length, equals(1));
      expect(nivelA1.first.id, equals('lamina_castrelos_outono'));
    });

    test('in-memory addition and smart search for CorpusPalabras', () async {
      final repo = ContentRepository();
      const p1 = CorpusPalabra(
        id: 1,
        lemma: 'water',
        banda: '1k',
        nivelCefr: 'A1/A2',
      );
      const p2 = CorpusPalabra(
        id: 2,
        lemma: 'watermelon',
        banda: '3k',
        nivelCefr: 'B1',
      );
      const p3 = CorpusPalabra(
        id: 3,
        lemma: 'drink',
        banda: '1k',
        nivelCefr: 'A1/A2',
        pos: 'VERB',
        frase: 'Drink your milk before the story.',
      );
      const p4 = CorpusPalabra(
        id: 4,
        lemma: 'splash',
        banda: '3k',
        nivelCefr: 'B1/B2',
        // Con el filtro por igualdad, «B1» ya no arrastra «B1/B2»: esta
        // palabra está aquí justo para comprobarlo.
        pos: 'NOUN',
        onomatopeya: true,
      );

      repo.addCorpusPalabra(p1);
      repo.addCorpusPalabra(p2);
      repo.addCorpusPalabra(p3);
      repo.addCorpusPalabra(p4);

      final banda1 = await repo.loadCorpusPalabras(banda: 1);
      expect(banda1.length, equals(2));
      expect(banda1.map((p) => p.lemma), containsAll(['water', 'drink']));

      final cefrB1 = await repo.loadCorpusPalabras(cefr: 'B1');
      expect(cefrB1.length, equals(1));
      expect(cefrB1.first.lemma, equals('watermelon'));

      final cefrB1B2 = await repo.loadCorpusPalabras(cefr: 'B1/B2');
      expect(cefrB1B2.map((p) => p.lemma), equals(['splash']));

      final verbos = await repo.loadCorpusPalabras(pos: 'VERB');
      expect(verbos.map((p) => p.lemma), equals(['drink']));

      final onomatopeias =
          await repo.loadCorpusPalabras(soloOnomatopeias: true);
      expect(onomatopeias.map((p) => p.lemma), equals(['splash']));

      final searchResults = await repo.searchPalabras('water');
      expect(searchResults.length, equals(2));
      // Exact match 'water' must rank ahead of 'watermelon'
      expect(searchResults.first.lemma, equals('water'));
      expect(searchResults.last.lemma, equals('watermelon'));
    });

    test('in-memory addition and query for Calendario 1000 Dias', () async {
      final repo = ContentRepository();
      const dia1 = DiaCalendarioDual(
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
        temaDia: LocalizedString(gl: 'Benvida', es: 'Bienvenida'),
        profesorado: DiaProfesorado(
          actividadAula: LocalizedString(gl: 'Pulso', es: 'Pulso'),
          dinamica: LocalizedString(gl: 'Círculo', es: 'Círculo'),
          duracionMin: 15,
          consignaDocente: LocalizedString(gl: 'Contacto', es: 'Contacto'),
        ),
        familias: DiaFamilias(
          rutinaFogar: LocalizedString(gl: 'Acordar', es: 'Despertar'),
          momento: LocalizedString(gl: 'Maniñas', es: 'Manitas'),
          consignaFamilia: LocalizedString(gl: 'Calma', es: 'Calma'),
          fraseConexion: LocalizedString(gl: 'Ola', es: 'Hola'),
        ),
      );
      const dia2 = DiaCalendarioDual(
        dia: 1,
        diaSemana: 0,
        diaSemanaNumero: 1,
        nombreDiaSemana: LocalizedString(gl: 'Luns', es: 'Lunes'),
        semanaNumero: 1,
        semanaCursoNumero: 1,
        semanaGlobalNumero: 41,
        diaCursoNumero: 1,
        diaGlobalNumero: 201,
        mesNumero: 1,
        mesGlobalNumero: 11,
        fechaClave: 'curso_2_3-mes-1-dia-1',
        temaDia: LocalizedString(gl: 'Explosión', es: 'Explosión'),
        profesorado: DiaProfesorado(
          actividadAula: LocalizedString(gl: 'Pulso', es: 'Pulso'),
          dinamica: LocalizedString(gl: 'Movemento', es: 'Movimiento'),
          duracionMin: 15,
          consignaDocente: LocalizedString(gl: 'Modelado', es: 'Modelado'),
        ),
        familias: DiaFamilias(
          rutinaFogar: LocalizedString(gl: 'Xogo', es: 'Juego'),
          momento: LocalizedString(gl: 'Pés', es: 'Pies'),
          consignaFamilia: LocalizedString(gl: 'Palabras', es: 'Palabras'),
          fraseConexion: LocalizedString(gl: 'Imos', es: 'Vamos'),
        ),
      );

      repo.addCalendarioDia(dia1);
      repo.addCalendarioDia(dia2);

      final curso02 =
          await repo.loadCalendarioDias(cursoId: 'curso_0_2', mes: 1);
      expect(curso02.length, equals(1));
      expect(curso02.first.fechaClave, equals('curso_0_2-mes-1-dia-1'));

      final curso23 = await repo.loadCalendarioDias(cursoId: 'curso_2_3');
      expect(curso23.length, equals(1));
      expect(curso23.first.fechaClave, equals('curso_2_3-mes-1-dia-1'));
    });

    test(
        'EnglishCorpus, Phonics, Estrategias, Dinamicas, and Curriculo50 loaders',
        () async {
      final repo = ContentRepository();

      const corpus = EnglishCorpus(
        words: [
          EnglishWordEntry(
            id: 'en_hello',
            rank: 1,
            word: 'hello',
            phonetic: '/həˈloʊ/',
            partOfSpeech: 'phrase',
            translation: LocalizedString(gl: 'ola', es: 'hola'),
            definition: LocalizedString(gl: 'Saúdo', es: 'Saludo'),
            category: 'social_phrases',
            cefr: 'Pre-A1',
            targetAge: '0-2',
            naturalPhrase: EnglishNaturalPhrase(
              en: 'Hello friend!',
              translation:
                  LocalizedString(gl: 'Ola amigo!', es: '¡Hola amigo!'),
            ),
            collocations: ['say hello'],
            frequencyTier: 1000,
          )
        ],
        scenarios: [],
      );
      repo.setEnglishCorpus(corpus);
      final loadedCorpus = await repo.loadEnglishCorpus();
      expect(loadedCorpus.words.length, equals(1));
      expect(loadedCorpus.words.first.word, equals('hello'));

      const taxonomy = PhonicsTaxonomy(
        phonemes: [
          PhonemeDef(
            id: 'ph_a',
            symbolIpa: '/æ/',
            grapheme: 'a',
            category: 'short_vowel',
            name: LocalizedString(gl: 'A', es: 'A'),
            exampleWord:
                PhonemeExampleWord(en: 'apple', gl: 'mazá', es: 'manzana'),
            audioCue: '/æ/ in apple',
            articulationGuide: LocalizedString(gl: 'Guía', es: 'Guía'),
            frequencyRank: 1,
            readingLevel: 1,
          )
        ],
        decodableWords: [],
        wordFamilies: [],
        missions: [],
      );
      repo.setPhonicsTaxonomy(taxonomy);
      final loadedTax = await repo.loadPhonicsTaxonomy();
      expect(loadedTax.phonemes.length, equals(1));
      expect(loadedTax.phonemes.first.grapheme, equals('a'));

      const est = EstrategiaPedagogica(
        id: 'est-1',
        clave: 'espera_5s',
        nome: LocalizedString(gl: '5s', es: '5s'),
        subtitulo: LocalizedString(gl: 'Sub', es: 'Sub'),
        baseNeurobioloxica: LocalizedString(gl: 'Base', es: 'Base'),
        comoAplicarNaAula: LocalizedString(gl: 'Aula', es: 'Aula'),
        exemploDialogoAula: LocalizedString(gl: 'Dialogo', es: 'Diálogo'),
        erroComunAEvitar: LocalizedString(gl: 'Erro', es: 'Error'),
        consignaDocente: LocalizedString(gl: 'Docente', es: 'Docente'),
      );
      repo.addEstrategia(est);
      final ests = await repo.loadEstrategias();
      expect(ests.length, equals(1));
      expect(ests.first.clave, equals('espera_5s'));

      const din = DinamicaPedagogica(
        id: 'din-1',
        clave: 'asemblea_pulso',
        diaSemana: 'luns',
        titulo: LocalizedString(gl: 'Benvida', es: 'Bienvenida'),
        subtitulo: LocalizedString(gl: 'Sub', es: 'Sub'),
        duracionMinutos: 15,
        ritmoBpm: 72,
        obxectivo: LocalizedString(gl: 'Obj', es: 'Obj'),
        procedementoPasoAPaso: LocalizedString(gl: 'Pasos', es: 'Pasos'),
        materialSensorial: LocalizedString(gl: 'Alfombra', es: 'Alfombra'),
        fraseDocente: LocalizedString(gl: 'Frase', es: 'Frase'),
      );
      repo.addDinamica(din);
      final dins = await repo.loadDinamicas();
      expect(dins.length, equals(1));
      expect(dins.first.ritmoBpm, equals(72));

      const mesCurricular = MesCurricular50(
        id: 'c1_m1',
        cursoId: 'curso_0_2',
        cursoNumero: 1,
        mesNumero: 1,
        nombreMes: LocalizedString(gl: 'Setembro', es: 'Septiembre'),
        icono: 'acollemento',
        centroInteres: LocalizedString(gl: 'Apego', es: 'Apego'),
        objetivoPedagogico: LocalizedString(gl: 'Obxectivo', es: 'Objetivo'),
        actividadAula: LocalizedString(gl: 'Aula', es: 'Aula'),
        actividadHogar: LocalizedString(gl: 'Fogar', es: 'Hogar'),
        rutinaRecomendadaHogar: LocalizedString(gl: 'Rutina', es: 'Rutina'),
        minutosSugeridos: 3,
        ingles: InglesMesCurricular(
            lexico: ['Hello'], tpr: ['Clap'], frase: 'Hello!'),
        dinamicaEvolutiva: LocalizedString(gl: 'Evolutiva', es: 'Evolutiva'),
        ponteCasaEscola: LocalizedString(gl: 'Ponte', es: 'Puente'),
      );
      repo.addMesCurricular50(mesCurricular);
      final meses = await repo.loadCurriculo50Meses();
      expect(meses.length, equals(1));
      expect(meses.first.id, equals('c1_m1'));
    });

    test('clear resets all caches across all content domains', () async {
      final repo = ContentRepository();
      repo.addCuento(
        const Cuento(
          id: 'conto_001',
          cursoId: 'curso_0_2',
          mesNumero: 1,
          semanaSugerida: 1,
          titulo: LocalizedString(gl: 'A', es: 'A'),
          sinopse: LocalizedString(gl: 'B', es: 'B'),
          paginas: [],
          preguntasGraduadas: [],
        ),
      );
      repo.addLamina(
        const Lamina(
          id: 'lamina_1',
          numero: 1,
          categoria: 'alfabeto',
          gl: 'A',
          es: 'A',
          en: 'A',
          cefr: 'Pre-A1',
          ratio: '3:5',
        ),
      );
      expect(repo.getCuentoByIdSync('conto_001'), isNotNull);
      expect(repo.getLaminaByIdSync('lamina_1'), isNotNull);

      repo.clear();

      expect(repo.getCuentoByIdSync('conto_001'), isNull);
      expect(repo.getLaminaByIdSync('lamina_1'), isNull);
    });

    test('loading from mocked asset bundle loader parses successfully',
        () async {
      final mockAssets = <String, String>{
        ContentRepository.historiasProgresivasAssetPath: jsonEncode([
          {
            'id': 'conto_mock_01',
            'cursoId': 'curso_0_2',
            'mesNumero': 1,
            'semanaSugerida': 1,
            'titulo': {'gl': 'Conto Mock', 'es': 'Cuento Mock'},
            'sinopse': {'gl': 'Sinopse', 'es': 'Sinopsis'},
            'paginas': [],
            'preguntasGraduadas': [],
          }
        ]),
        ContentRepository.laminas200AssetPath: jsonEncode([
          {
            'id': 'lamina_mock_01',
            'numero': 1,
            'categoria': 'vocabulario',
            'gl': 'auga',
            'es': 'agua',
            'en': 'water',
            'cefr': 'Pre-A1',
            'ratio': '3:5',
          }
        ]),
      };

      final loader = ContentAssetLoader(
        stringLoader: (path) async {
          if (mockAssets.containsKey(path)) {
            return mockAssets[path]!;
          }
          throw Exception('Asset not found: $path');
        },
      );

      final repo = ContentRepository(loader: loader);

      final cuentos = await repo.loadCuentos();
      expect(cuentos.length, equals(1));
      expect(cuentos.first.id, equals('conto_mock_01'));

      final laminas = await repo.loadLaminas();
      expect(laminas.length, equals(1));
      expect(laminas.first.id, equals('lamina_mock_01'));
      expect(laminas.first.en, equals('water'));
    });
  });
}
