import 'package:flutter/foundation.dart';
import '../../core/localization/localized_string.dart';

/// Trilingual example word for a phoneme.
@immutable
class PhonemeExampleWord {
  final String en;
  final String gl;
  final String es;

  const PhonemeExampleWord({
    required this.en,
    required this.gl,
    required this.es,
  });

  factory PhonemeExampleWord.fromJson(Map<String, dynamic> json) {
    return PhonemeExampleWord(
      en: json['en']?.toString().trim() ?? '',
      gl: json['gl']?.toString().trim() ?? '',
      es: json['es']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'en': en,
        'gl': gl,
        'es': es,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhonemeExampleWord &&
          runtimeType == other.runtimeType &&
          en == other.en &&
          gl == other.gl &&
          es == other.es;

  @override
  int get hashCode => Object.hash(en, gl, es);

  @override
  String toString() => 'PhonemeExampleWord(en: $en, gl: $gl, es: $es)';
}

/// Definition of an English phoneme from the 44-phoneme taxonomy.
///
/// Ported from `.studio_ref/src/data/phonicsTaxonomyData.ts`.
@immutable
class PhonemeDef {
  final String id;
  final String symbolIpa;
  final String grapheme;
  final String category; // 'short_vowel', 'consonant', 'digraph', 'magic_e', etc.
  final LocalizedString name;
  final PhonemeExampleWord exampleWord;
  final String audioCue;
  final LocalizedString articulationGuide;
  final int frequencyRank;
  final int readingLevel; // 1..5
  final String? nfcUid;

  const PhonemeDef({
    required this.id,
    required this.symbolIpa,
    required this.grapheme,
    required this.category,
    required this.name,
    required this.exampleWord,
    required this.audioCue,
    required this.articulationGuide,
    required this.frequencyRank,
    required this.readingLevel,
    this.nfcUid,
  });

  factory PhonemeDef.fromJson(Map<String, dynamic> json) {
    final rawExample = json['exampleWord'] as Map<String, dynamic>? ??
        json['example_word'] as Map<String, dynamic>? ??
        const {};

    return PhonemeDef(
      id: json['id']?.toString().trim() ?? '',
      symbolIpa: json['symbolIpa']?.toString().trim() ??
          json['symbol_ipa']?.toString().trim() ??
          '',
      grapheme: json['grapheme']?.toString().trim() ?? '',
      category: json['category']?.toString().trim() ?? 'short_vowel',
      name: LocalizedString.fromJson(
        json['name'] as Map<String, dynamic>? ?? const {},
      ),
      exampleWord: PhonemeExampleWord.fromJson(rawExample),
      audioCue: json['audioCue']?.toString().trim() ??
          json['audio_cue']?.toString().trim() ??
          '',
      articulationGuide: LocalizedString.fromJson(
        json['articulationGuide'] as Map<String, dynamic>? ??
            json['articulation_guide'] as Map<String, dynamic>? ??
            const {},
      ),
      frequencyRank: (json['frequencyRank'] as num?)?.toInt() ??
          (json['frequency_rank'] as num?)?.toInt() ??
          1,
      readingLevel: (json['readingLevel'] as num?)?.toInt() ??
          (json['reading_level'] as num?)?.toInt() ??
          1,
      nfcUid: json['nfcUid']?.toString().trim() ??
          json['nfc_uid']?.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'symbolIpa': symbolIpa,
        'grapheme': grapheme,
        'category': category,
        'name': name.toJson(),
        'exampleWord': exampleWord.toJson(),
        'audioCue': audioCue,
        'articulationGuide': articulationGuide.toJson(),
        'frequencyRank': frequencyRank,
        'readingLevel': readingLevel,
        if (nfcUid != null) 'nfcUid': nfcUid,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhonemeDef &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          symbolIpa == other.symbolIpa &&
          grapheme == other.grapheme &&
          category == other.category &&
          name == other.name &&
          exampleWord == other.exampleWord &&
          audioCue == other.audioCue &&
          articulationGuide == other.articulationGuide &&
          frequencyRank == other.frequencyRank &&
          readingLevel == other.readingLevel &&
          nfcUid == other.nfcUid;

  @override
  int get hashCode => Object.hash(
        id,
        symbolIpa,
        grapheme,
        category,
        name,
        exampleWord,
        audioCue,
        articulationGuide,
        frequencyRank,
        readingLevel,
        nfcUid,
      );

  @override
  String toString() => 'PhonemeDef($id, grapheme: "$grapheme", IPA: $symbolIpa)';
}

/// Decodable word entry for early phonics blending practice.
@immutable
class DecodableWord {
  final String id;
  final String word;
  final List<String> letters;
  final List<String> phonemes;
  final List<String> phonemeIpa;
  final String wordFamily;
  final String category; // 'cvc', 'ccvc', 'cvcc', 'magic_e', etc.
  final int level; // 1..5
  final String gl;
  final String es;
  final String en;
  final LocalizedString sampleSentence;
  final int? audioTrack;
  final String? nfcUid;

  const DecodableWord({
    required this.id,
    required this.word,
    required this.letters,
    required this.phonemes,
    required this.phonemeIpa,
    required this.wordFamily,
    required this.category,
    required this.level,
    required this.gl,
    required this.es,
    required this.en,
    required this.sampleSentence,
    this.audioTrack,
    this.nfcUid,
  });

  factory DecodableWord.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => e.toString().trim()).toList();
      }
      return const [];
    }

    final rawSentence = json['sampleSentence'] ?? json['sample_sentence'];
    final LocalizedString sentence = rawSentence is Map<String, dynamic>
        ? LocalizedString.fromJson(rawSentence)
        : (rawSentence is Map
            ? LocalizedString.fromJson(Map<String, dynamic>.from(rawSentence))
            : const LocalizedString(gl: '', es: ''));

    return DecodableWord(
      id: json['id']?.toString().trim() ?? '',
      word: json['word']?.toString().trim() ?? '',
      letters: List.unmodifiable(parseStringList(json['letters'])),
      phonemes: List.unmodifiable(parseStringList(json['phonemes'])),
      phonemeIpa: List.unmodifiable(
        parseStringList(json['phonemeIpa'] ?? json['phoneme_ipa']),
      ),
      wordFamily: json['wordFamily']?.toString().trim() ??
          json['word_family']?.toString().trim() ??
          '',
      category: json['category']?.toString().trim() ?? 'cvc',
      level: (json['level'] as num?)?.toInt() ?? 1,
      gl: json['gl']?.toString().trim() ?? '',
      es: json['es']?.toString().trim() ?? '',
      en: json['en']?.toString().trim() ?? '',
      sampleSentence: sentence,
      audioTrack: (json['audioTrack'] as num?)?.toInt() ??
          (json['audio_track'] as num?)?.toInt(),
      nfcUid: json['nfcUid']?.toString().trim() ??
          json['nfc_uid']?.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'word': word,
        'letters': letters,
        'phonemes': phonemes,
        'phonemeIpa': phonemeIpa,
        'wordFamily': wordFamily,
        'category': category,
        'level': level,
        'gl': gl,
        'es': es,
        'en': en,
        'sampleSentence': sampleSentence.toJson(),
        if (audioTrack != null) 'audioTrack': audioTrack,
        if (nfcUid != null) 'nfcUid': nfcUid,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecodableWord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          word == other.word &&
          listEquals(letters, other.letters) &&
          listEquals(phonemes, other.phonemes) &&
          listEquals(phonemeIpa, other.phonemeIpa) &&
          wordFamily == other.wordFamily &&
          category == other.category &&
          level == other.level &&
          gl == other.gl &&
          es == other.es &&
          en == other.en &&
          sampleSentence == other.sampleSentence &&
          audioTrack == other.audioTrack &&
          nfcUid == other.nfcUid;

  @override
  int get hashCode => Object.hash(
        id,
        word,
        Object.hashAll(letters),
        Object.hashAll(phonemes),
        Object.hashAll(phonemeIpa),
        wordFamily,
        category,
        level,
        gl,
        es,
        en,
        sampleSentence,
        audioTrack,
        nfcUid,
      );

  @override
  String toString() => 'DecodableWord($id, word: "$word", family: $wordFamily)';
}

/// Word family grouping decodable words sharing a common rime (e.g. "-at").
@immutable
class WordFamily {
  final String id;
  final String rime; // e.g. "-at", "-en"
  final String vowelType; // 'short_a', 'short_e', etc.
  final int level; // 1..5
  final List<String> words;

  const WordFamily({
    required this.id,
    required this.rime,
    required this.vowelType,
    required this.level,
    required this.words,
  });

  factory WordFamily.fromJson(Map<String, dynamic> json) {
    final rawWords = json['words'];
    final List<String> wordsList = rawWords is List
        ? rawWords.map((e) => e.toString().trim()).toList()
        : const [];

    return WordFamily(
      id: json['id']?.toString().trim() ?? '',
      rime: json['rime']?.toString().trim() ?? '',
      vowelType: json['vowelType']?.toString().trim() ??
          json['vowel_type']?.toString().trim() ??
          'short_a',
      level: (json['level'] as num?)?.toInt() ?? 1,
      words: List.unmodifiable(wordsList),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rime': rime,
        'vowelType': vowelType,
        'level': level,
        'words': words,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordFamily &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          rime == other.rime &&
          vowelType == other.vowelType &&
          level == other.level &&
          listEquals(words, other.words);

  @override
  int get hashCode => Object.hash(
        id,
        rime,
        vowelType,
        level,
        Object.hashAll(words),
      );

  @override
  String toString() => 'WordFamily($id, rime: "$rime", ${words.length} words)';
}

/// Gamified phonics challenge or blending mission.
@immutable
class PhonicsMission {
  final String id;
  final LocalizedString title;
  final String missionType; // 'find_phoneme', 'blend_cvc', 'rhyme_match', etc.
  final String? targetPhonemeId;
  final String? targetWordId;
  final LocalizedString? audioPrompt;
  final LocalizedString? hint;
  final List<String> expectedInput;
  final int level; // 1..5
  final int xpReward;

  const PhonicsMission({
    required this.id,
    required this.title,
    required this.missionType,
    this.targetPhonemeId,
    this.targetWordId,
    this.audioPrompt,
    this.hint,
    required this.expectedInput,
    required this.level,
    this.xpReward = 20,
  });

  factory PhonicsMission.fromJson(Map<String, dynamic> json) {
    final rawExpected = json['expectedInput'] ?? json['expected_input'];
    final List<String> expectedList = rawExpected is List
        ? rawExpected.map((e) => e.toString().trim()).toList()
        : const [];

    final rawPrompt = json['audioPrompt'] ?? json['audio_prompt'];
    final LocalizedString? prompt = rawPrompt is Map<String, dynamic>
        ? LocalizedString.fromJson(rawPrompt)
        : (rawPrompt is Map
            ? LocalizedString.fromJson(Map<String, dynamic>.from(rawPrompt))
            : null);

    final rawHint = json['hint'];
    final LocalizedString? hint = rawHint is Map<String, dynamic>
        ? LocalizedString.fromJson(rawHint)
        : (rawHint is Map
            ? LocalizedString.fromJson(Map<String, dynamic>.from(rawHint))
            : null);

    return PhonicsMission(
      id: json['id']?.toString().trim() ?? '',
      title: LocalizedString.fromJson(
        json['title'] as Map<String, dynamic>? ?? const {},
      ),
      missionType: json['missionType']?.toString().trim() ??
          json['mission_type']?.toString().trim() ??
          'find_phoneme',
      targetPhonemeId: json['targetPhonemeId']?.toString().trim() ??
          json['target_phoneme_id']?.toString().trim(),
      targetWordId: json['targetWordId']?.toString().trim() ??
          json['target_word_id']?.toString().trim(),
      audioPrompt: prompt,
      hint: hint,
      expectedInput: List.unmodifiable(expectedList),
      level: (json['level'] as num?)?.toInt() ?? 1,
      xpReward: (json['xpReward'] as num?)?.toInt() ??
          (json['xp_reward'] as num?)?.toInt() ??
          20,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title.toJson(),
        'missionType': missionType,
        if (targetPhonemeId != null) 'targetPhonemeId': targetPhonemeId,
        if (targetWordId != null) 'targetWordId': targetWordId,
        if (audioPrompt != null) 'audioPrompt': audioPrompt!.toJson(),
        if (hint != null) 'hint': hint!.toJson(),
        'expectedInput': expectedInput,
        'level': level,
        'xpReward': xpReward,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhonicsMission &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          missionType == other.missionType &&
          targetPhonemeId == other.targetPhonemeId &&
          targetWordId == other.targetWordId &&
          audioPrompt == other.audioPrompt &&
          hint == other.hint &&
          listEquals(expectedInput, other.expectedInput) &&
          level == other.level &&
          xpReward == other.xpReward;

  @override
  int get hashCode => Object.hash(
        id,
        title,
        missionType,
        targetPhonemeId,
        targetWordId,
        audioPrompt,
        hint,
        Object.hashAll(expectedInput),
        level,
        xpReward,
      );

  @override
  String toString() => 'PhonicsMission($id, type: $missionType, level: $level)';
}

/// Full Phonics Taxonomy container data model.
@immutable
class PhonicsTaxonomy {
  final List<PhonemeDef> phonemes;
  final List<DecodableWord> decodableWords;
  final List<WordFamily> wordFamilies;
  final List<PhonicsMission> missions;

  const PhonicsTaxonomy({
    required this.phonemes,
    required this.decodableWords,
    required this.wordFamilies,
    required this.missions,
  });

  factory PhonicsTaxonomy.fromJson(Map<String, dynamic> json) {
    final rawPhonemes = json['phonemes'] ?? json['phonemes44'];
    final List<PhonemeDef> phonemesList = [];
    if (rawPhonemes is List) {
      for (final p in rawPhonemes) {
        if (p is Map<String, dynamic>) {
          phonemesList.add(PhonemeDef.fromJson(p));
        } else if (p is Map) {
          phonemesList.add(PhonemeDef.fromJson(Map<String, dynamic>.from(p)));
        }
      }
    }

    final rawDecodable = json['decodableWords'] ?? json['decodable_words'];
    final List<DecodableWord> decodableList = [];
    if (rawDecodable is List) {
      for (final d in rawDecodable) {
        if (d is Map<String, dynamic>) {
          decodableList.add(DecodableWord.fromJson(d));
        } else if (d is Map) {
          decodableList.add(
            DecodableWord.fromJson(Map<String, dynamic>.from(d)),
          );
        }
      }
    }

    final rawFamilies = json['wordFamilies'] ?? json['word_families'];
    final List<WordFamily> familiesList = [];
    if (rawFamilies is List) {
      for (final f in rawFamilies) {
        if (f is Map<String, dynamic>) {
          familiesList.add(WordFamily.fromJson(f));
        } else if (f is Map) {
          familiesList.add(WordFamily.fromJson(Map<String, dynamic>.from(f)));
        }
      }
    }

    final rawMissions = json['missions'] ?? json['phonics_missions'];
    final List<PhonicsMission> missionsList = [];
    if (rawMissions is List) {
      for (final m in rawMissions) {
        if (m is Map<String, dynamic>) {
          missionsList.add(PhonicsMission.fromJson(m));
        } else if (m is Map) {
          missionsList.add(PhonicsMission.fromJson(Map<String, dynamic>.from(m)));
        }
      }
    }

    return PhonicsTaxonomy(
      phonemes: List.unmodifiable(phonemesList),
      decodableWords: List.unmodifiable(decodableList),
      wordFamilies: List.unmodifiable(familiesList),
      missions: List.unmodifiable(missionsList),
    );
  }

  Map<String, dynamic> toJson() => {
        'phonemes': phonemes.map((p) => p.toJson()).toList(),
        'decodableWords': decodableWords.map((d) => d.toJson()).toList(),
        'wordFamilies': wordFamilies.map((w) => w.toJson()).toList(),
        'missions': missions.map((m) => m.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhonicsTaxonomy &&
          runtimeType == other.runtimeType &&
          listEquals(phonemes, other.phonemes) &&
          listEquals(decodableWords, other.decodableWords) &&
          listEquals(wordFamilies, other.wordFamilies) &&
          listEquals(missions, other.missions);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(phonemes),
        Object.hashAll(decodableWords),
        Object.hashAll(wordFamilies),
        Object.hashAll(missions),
      );
}
