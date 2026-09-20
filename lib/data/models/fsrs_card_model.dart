import 'package:flutter/foundation.dart';

/// Card learning state according to the FSRS spaced repetition model.
enum FSRSCardState {
  newCard,
  learning,
  review,
  relearning;

  String get label {
    switch (this) {
      case FSRSCardState.newCard:
        return 'new';
      case FSRSCardState.learning:
        return 'learning';
      case FSRSCardState.review:
        return 'review';
      case FSRSCardState.relearning:
        return 'relearning';
    }
  }

  static FSRSCardState fromString(String? val) {
    switch (val?.trim().toLowerCase()) {
      case 'learning':
        return FSRSCardState.learning;
      case 'review':
        return FSRSCardState.review;
      case 'relearning':
        return FSRSCardState.relearning;
      case 'new':
      default:
        return FSRSCardState.newCard;
    }
  }
}

/// Immutable state of an FSRS (Free Spaced Repetition Scheduler) card.
///
/// Ported from `.studio_ref/src/utils/fsrsAlgorithm.ts` based on the DSR
/// (Difficulty, Stability, Retrievability) memory model.
@immutable
class FSRSCard {
  final int id;
  final String lemma;
  final double difficulty; // D in [1, 10]
  final double stability; // S in days
  final double retrievability; // R in [0, 1]
  final int reps;
  final int lapses;
  final DateTime lastReviewDate;
  final DateTime nextDueDate;
  final int scheduledDays;
  final FSRSCardState state;

  const FSRSCard({
    required this.id,
    required this.lemma,
    required this.difficulty,
    required this.stability,
    required this.retrievability,
    required this.reps,
    required this.lapses,
    required this.lastReviewDate,
    required this.nextDueDate,
    required this.scheduledDays,
    required this.state,
  });

  /// Creates a brand new FSRS Card initialized for a given lemma.
  factory FSRSCard.initial({
    required int id,
    required String lemma,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    return FSRSCard(
      id: id,
      lemma: lemma,
      difficulty: 5.0,
      stability: 0.0,
      retrievability: 1.0,
      reps: 0,
      lapses: 0,
      lastReviewDate: current,
      nextDueDate: current,
      scheduledDays: 0,
      state: FSRSCardState.newCard,
    );
  }

  /// Factory constructor to parse JSON into [FSRSCard].
  factory FSRSCard.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val, DateTime fallback) {
      if (val is int) {
        return DateTime.fromMillisecondsSinceEpoch(val);
      } else if (val is String) {
        final parsed = DateTime.tryParse(val);
        if (parsed != null) return parsed;
        final asNum = int.tryParse(val);
        if (asNum != null) return DateTime.fromMillisecondsSinceEpoch(asNum);
      }
      return fallback;
    }

    final now = DateTime.now();
    final lastReview = parseDate(
      json['lastReviewDate'] ?? json['last_review_date'],
      now,
    );
    final nextDue = parseDate(
      json['nextDueDate'] ?? json['next_due_date'],
      now,
    );

    return FSRSCard(
      id: (json['id'] as num?)?.toInt() ?? 0,
      lemma: json['lemma']?.toString().trim() ?? '',
      difficulty: (json['difficulty'] as num?)?.toDouble() ?? 5.0,
      stability: (json['stability'] as num?)?.toDouble() ?? 0.0,
      retrievability: (json['retrievability'] as num?)?.toDouble() ?? 1.0,
      reps: (json['reps'] as num?)?.toInt() ?? 0,
      lapses: (json['lapses'] as num?)?.toInt() ?? 0,
      lastReviewDate: lastReview,
      nextDueDate: nextDue,
      scheduledDays: (json['scheduledDays'] as num?)?.toInt() ??
          (json['scheduled_days'] as num?)?.toInt() ??
          0,
      state: FSRSCardState.fromString(json['state']?.toString()),
    );
  }

  /// `aaaa-mm-dd` de una fecha, sin hora ni zona.
  static String _soloDia(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'lemma': lemma,
        'difficulty': difficulty,
        'stability': stability,
        'retrievability': retrievability,
        'reps': reps,
        'lapses': lapses,
        // aaaa-mm-dd, SIN hora. Guardar el instante en milisegundos diría a
        // qué hora trabaja la persona adulta, y la política de privacidad
        // promete lo contrario. FSRS programa en días enteros: la hora no le
        // hace falta a nadie. Lo vigila test/core/progreso_privacidad_test.dart.
        'lastReviewDate': _soloDia(lastReviewDate),
        'nextDueDate': _soloDia(nextDueDate),
        'scheduledDays': scheduledDays,
        'state': state.label,
      };

  /// Returns a copy with updated properties.
  FSRSCard copyWith({
    int? id,
    String? lemma,
    double? difficulty,
    double? stability,
    double? retrievability,
    int? reps,
    int? lapses,
    DateTime? lastReviewDate,
    DateTime? nextDueDate,
    int? scheduledDays,
    FSRSCardState? state,
  }) {
    return FSRSCard(
      id: id ?? this.id,
      lemma: lemma ?? this.lemma,
      difficulty: difficulty ?? this.difficulty,
      stability: stability ?? this.stability,
      retrievability: retrievability ?? this.retrievability,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      state: state ?? this.state,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FSRSCard &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          lemma == other.lemma &&
          difficulty == other.difficulty &&
          stability == other.stability &&
          retrievability == other.retrievability &&
          reps == other.reps &&
          lapses == other.lapses &&
          lastReviewDate == other.lastReviewDate &&
          nextDueDate == other.nextDueDate &&
          scheduledDays == other.scheduledDays &&
          state == other.state;

  @override
  int get hashCode => Object.hash(
        id,
        lemma,
        difficulty,
        stability,
        retrievability,
        reps,
        lapses,
        lastReviewDate,
        nextDueDate,
        scheduledDays,
        state,
      );

  @override
  String toString() =>
      'FSRSCard(id: $id, lemma: "$lemma", D: $difficulty, S: $stability, R: $retrievability, state: ${state.label})';
}
