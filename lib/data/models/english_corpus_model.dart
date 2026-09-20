import 'package:flutter/foundation.dart';
import '../../core/localization/localized_string.dart';

/// Natural communicative contextualized phrase with bilingual translation.
@immutable
class EnglishNaturalPhrase {
  final String en;
  final LocalizedString translation;

  const EnglishNaturalPhrase({
    required this.en,
    required this.translation,
  });

  factory EnglishNaturalPhrase.fromJson(Map<String, dynamic> json) {
    return EnglishNaturalPhrase(
      en: json['en']?.toString().trim() ?? '',
      translation: LocalizedString.fromJson(
        json['translation'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'en': en,
        'translation': translation.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnglishNaturalPhrase &&
          runtimeType == other.runtimeType &&
          en == other.en &&
          translation == other.translation;

  @override
  int get hashCode => Object.hash(en, translation);

  @override
  String toString() => 'EnglishNaturalPhrase(en: "$en")';
}

/// Single vocabulary entry in the English immersion corpus.
///
/// Ported from `.studio_ref/src/types/englishImmersion.ts` and
/// `.studio_ref/src/data/englishCorpus.ts`.
@immutable
class EnglishWordEntry {
  final String id;
  final int rank; // Frequency rank 1 - 8000
  final String word;
  final String phonetic;
  final String partOfSpeech; // 'noun', 'verb', 'adjective', 'adverb', 'phrase', etc.
  final LocalizedString translation;
  final LocalizedString definition;
  final String category; // 'daily_life', 'actions_verbs', etc.
  final String cefr; // 'Pre-A1', 'A1', 'A2', 'B1', 'B2'
  final String targetAge; // '0-2', '2-3', '3-4', '4-5', '5-6', 'all'
  final EnglishNaturalPhrase naturalPhrase;
  final List<String> collocations;
  final LocalizedString? tprAction;
  final int frequencyTier; // 1000, 2000, 3000, 5000, 8000

  const EnglishWordEntry({
    required this.id,
    required this.rank,
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
    required this.translation,
    required this.definition,
    required this.category,
    required this.cefr,
    required this.targetAge,
    required this.naturalPhrase,
    required this.collocations,
    this.tprAction,
    required this.frequencyTier,
  });

  factory EnglishWordEntry.fromJson(Map<String, dynamic> json) {
    final rawCollocations = json['collocations'];
    final List<String> collocList;
    if (rawCollocations is List) {
      collocList = rawCollocations.map((e) => e.toString().trim()).toList();
    } else {
      collocList = const [];
    }

    final rawPhrase = json['naturalPhrase'] as Map<String, dynamic>? ??
        json['natural_phrase'] as Map<String, dynamic>? ??
        const {};

    final rawTpr = json['tprAction'] ?? json['tpr_action'];
    final LocalizedString? tpr = rawTpr is Map<String, dynamic>
        ? LocalizedString.fromJson(rawTpr)
        : (rawTpr is Map
            ? LocalizedString.fromJson(Map<String, dynamic>.from(rawTpr))
            : null);

    return EnglishWordEntry(
      id: json['id']?.toString().trim() ?? '',
      rank: (json['rank'] as num?)?.toInt() ?? 1,
      word: json['word']?.toString().trim() ?? '',
      phonetic: json['phonetic']?.toString().trim() ?? '',
      partOfSpeech: json['partOfSpeech']?.toString().trim() ??
          json['part_of_speech']?.toString().trim() ??
          'noun',
      translation: LocalizedString.fromJson(
        json['translation'] as Map<String, dynamic>? ?? const {},
      ),
      definition: LocalizedString.fromJson(
        json['definition'] as Map<String, dynamic>? ?? const {},
      ),
      category: json['category']?.toString().trim() ?? 'daily_life',
      cefr: json['cefr']?.toString().trim() ?? 'Pre-A1',
      targetAge: json['targetAge']?.toString().trim() ??
          json['target_age']?.toString().trim() ??
          '0-2',
      naturalPhrase: EnglishNaturalPhrase.fromJson(rawPhrase),
      collocations: List.unmodifiable(collocList),
      tprAction: tpr,
      frequencyTier: (json['frequencyTier'] as num?)?.toInt() ??
          (json['frequency_tier'] as num?)?.toInt() ??
          1000,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rank': rank,
        'word': word,
        'phonetic': phonetic,
        'partOfSpeech': partOfSpeech,
        'translation': translation.toJson(),
        'definition': definition.toJson(),
        'category': category,
        'cefr': cefr,
        'targetAge': targetAge,
        'naturalPhrase': naturalPhrase.toJson(),
        'collocations': collocations,
        if (tprAction != null) 'tprAction': tprAction!.toJson(),
        'frequencyTier': frequencyTier,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnglishWordEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          rank == other.rank &&
          word == other.word &&
          phonetic == other.phonetic &&
          partOfSpeech == other.partOfSpeech &&
          translation == other.translation &&
          definition == other.definition &&
          category == other.category &&
          cefr == other.cefr &&
          targetAge == other.targetAge &&
          naturalPhrase == other.naturalPhrase &&
          listEquals(collocations, other.collocations) &&
          tprAction == other.tprAction &&
          frequencyTier == other.frequencyTier;

  @override
  int get hashCode => Object.hash(
        id,
        rank,
        word,
        phonetic,
        partOfSpeech,
        translation,
        definition,
        category,
        cefr,
        targetAge,
        naturalPhrase,
        Object.hashAll(collocations),
        tprAction,
        frequencyTier,
      );

  @override
  String toString() => 'EnglishWordEntry(#$rank: "$word", $partOfSpeech)';
}

/// Turn in a communicative dialogue scenario.
@immutable
class DialogueTurn {
  final String speaker; // e.g. 'Adult', 'Child'
  final String en;
  final LocalizedString translation;
  final List<String> keyVocabulary;

  const DialogueTurn({
    required this.speaker,
    required this.en,
    required this.translation,
    required this.keyVocabulary,
  });

  factory DialogueTurn.fromJson(Map<String, dynamic> json) {
    final rawVocab = json['keyVocabulary'] ?? json['key_vocabulary'];
    final List<String> vocabList = rawVocab is List
        ? rawVocab.map((e) => e.toString().trim()).toList()
        : const [];

    return DialogueTurn(
      speaker: json['speaker']?.toString().trim() ?? 'Adult',
      en: json['en']?.toString().trim() ?? '',
      translation: LocalizedString.fromJson(
        json['translation'] as Map<String, dynamic>? ?? const {},
      ),
      keyVocabulary: List.unmodifiable(vocabList),
    );
  }

  Map<String, dynamic> toJson() => {
        'speaker': speaker,
        'en': en,
        'translation': translation.toJson(),
        'keyVocabulary': keyVocabulary,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DialogueTurn &&
          runtimeType == other.runtimeType &&
          speaker == other.speaker &&
          en == other.en &&
          translation == other.translation &&
          listEquals(keyVocabulary, other.keyVocabulary);

  @override
  int get hashCode => Object.hash(
        speaker,
        en,
        translation,
        Object.hashAll(keyVocabulary),
      );
}

/// Communicative dialogue scenario between adult and child.
@immutable
class EnglishDialogueScenario {
  final String id;
  final LocalizedString title;
  final String category;
  final String cefr;
  final LocalizedString context;
  final LocalizedString pedagogicalObjective;
  final List<DialogueTurn> turns;

  const EnglishDialogueScenario({
    required this.id,
    required this.title,
    required this.category,
    required this.cefr,
    required this.context,
    required this.pedagogicalObjective,
    required this.turns,
  });

  factory EnglishDialogueScenario.fromJson(Map<String, dynamic> json) {
    final rawTurns = json['turns'];
    final List<DialogueTurn> turnsList = [];
    if (rawTurns is List) {
      for (final t in rawTurns) {
        if (t is Map<String, dynamic>) {
          turnsList.add(DialogueTurn.fromJson(t));
        } else if (t is Map) {
          turnsList.add(DialogueTurn.fromJson(Map<String, dynamic>.from(t)));
        }
      }
    }

    return EnglishDialogueScenario(
      id: json['id']?.toString().trim() ?? '',
      title: LocalizedString.fromJson(
        json['title'] as Map<String, dynamic>? ?? const {},
      ),
      category: json['category']?.toString().trim() ?? 'daily_life',
      cefr: json['cefr']?.toString().trim() ?? 'Pre-A1',
      context: LocalizedString.fromJson(
        json['context'] as Map<String, dynamic>? ?? const {},
      ),
      pedagogicalObjective: LocalizedString.fromJson(
        json['pedagogicalObjective'] as Map<String, dynamic>? ??
            json['pedagogical_objective'] as Map<String, dynamic>? ??
            const {},
      ),
      turns: List.unmodifiable(turnsList),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title.toJson(),
        'category': category,
        'cefr': cefr,
        'context': context.toJson(),
        'pedagogicalObjective': pedagogicalObjective.toJson(),
        'turns': turns.map((t) => t.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnglishDialogueScenario &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          category == other.category &&
          cefr == other.cefr &&
          context == other.context &&
          pedagogicalObjective == other.pedagogicalObjective &&
          listEquals(turns, other.turns);

  @override
  int get hashCode => Object.hash(
        id,
        title,
        category,
        cefr,
        context,
        pedagogicalObjective,
        Object.hashAll(turns),
      );
}

/// Container for the full English immersion corpus data asset.
@immutable
class EnglishCorpus {
  final List<EnglishWordEntry> words;
  final List<EnglishDialogueScenario> scenarios;

  const EnglishCorpus({
    required this.words,
    required this.scenarios,
  });

  factory EnglishCorpus.fromJson(Map<String, dynamic> json) {
    final rawWords = json['words'] ?? json['lexicon'] ?? json['lexico'];
    final List<EnglishWordEntry> wordsList = [];
    if (rawWords is List) {
      for (final w in rawWords) {
        if (w is Map<String, dynamic>) {
          wordsList.add(EnglishWordEntry.fromJson(w));
        } else if (w is Map) {
          wordsList.add(EnglishWordEntry.fromJson(Map<String, dynamic>.from(w)));
        }
      }
    }

    final rawScenarios = json['scenarios'] ?? json['dialogues'];
    final List<EnglishDialogueScenario> scenariosList = [];
    if (rawScenarios is List) {
      for (final s in rawScenarios) {
        if (s is Map<String, dynamic>) {
          scenariosList.add(EnglishDialogueScenario.fromJson(s));
        } else if (s is Map) {
          scenariosList.add(
            EnglishDialogueScenario.fromJson(Map<String, dynamic>.from(s)),
          );
        }
      }
    }

    return EnglishCorpus(
      words: List.unmodifiable(wordsList),
      scenarios: List.unmodifiable(scenariosList),
    );
  }

  Map<String, dynamic> toJson() => {
        'words': words.map((w) => w.toJson()).toList(),
        'scenarios': scenarios.map((s) => s.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnglishCorpus &&
          runtimeType == other.runtimeType &&
          listEquals(words, other.words) &&
          listEquals(scenarios, other.scenarios);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(words),
        Object.hashAll(scenarios),
      );
}
