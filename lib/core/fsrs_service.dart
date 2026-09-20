import 'dart:math' as math;
import '../data/models/fsrs_card_model.dart';

/// Pure Dart implementation of the Free Spaced Repetition Scheduler (FSRS) v4.5.
///
/// Ported directly from `.studio_ref/src/utils/fsrsAlgorithm.ts` based on the
/// DSR (Difficulty, Stability, Retrievability) memory model.
///
/// Operates completely offline with zero network or external dependencies.
class FsrsService {
  /// Default 17 weights for FSRS v4.5
  static const List<double> defaultWeights = [
    0.4, 0.6, 2.4, 5.8, // Initial stabilities for rating 1, 2, 3, 4 (w[0..3])
    4.93, 0.94, // Initial difficulty baseline & rating modifier (w[4..5])
    0.86, // Mean reversion weight (w[6])
    0.01, // Retrievability factor power (w[7])
    1.49, // Hard penalty (w[8])
    0.14, // Easy reward (w[9])
    0.94, // Stability saturation power (w[10])
    2.18, // Difficulty penalty power (w[11])
    0.05, 0.34, 1.26, 0.29, // Post-lapse stability parameters (w[12..15])
    2.61, // Additional transition parameter (w[16])
  ];

  static const double factor = 19.0 / 81.0; // ~0.2345679
  static const double decay = -0.5;
  static const double defaultTargetRetrieval = 0.90;

  final List<double> weights;
  final double targetRetrieval;

  const FsrsService({
    List<double>? customWeights,
    this.targetRetrieval = defaultTargetRetrieval,
  }) : weights = customWeights ?? defaultWeights;

  /// Calculates Retrievability:
  /// R(t, S) = (1 + factor * t / S)^decay
  ///
  /// At t = S, R = (1 + 19/81)^(-0.5) = (100/81)^(-0.5) = 9/10 = 0.90.
  double calculateRetrievability(double elapsedDays, double stability) {
    if (stability <= 0.0) return 0.0;
    if (elapsedDays <= 0.0) return 1.0;
    final r = math.pow(1.0 + (factor * elapsedDays) / stability, decay);
    final clamped = r.toDouble().clamp(0.0, 1.0);
    return clamped;
  }

  /// Calculates initial stability for a brand new card based on the rating (1..4).
  double initStability(int rating) {
    final idx = (rating - 1).clamp(0, 3);
    return weights[idx];
  }

  /// Calculates initial difficulty for a brand new card based on the rating (1..4).
  /// D in [1.0, 10.0].
  double initDifficulty(int rating) {
    final clampedRating = rating.clamp(1, 4);
    final d = weights[4] - (clampedRating - 3) * weights[5];
    final clamped = d.clamp(1.0, 10.0);
    return (clamped * 100).round() / 100.0;
  }

  /// Calculates the next interval in days for a given stability and target retrievability.
  int nextInterval({
    required double stability,
    double? targetR,
  }) {
    if (stability <= 0.0) return 1;
    final r = targetR ?? targetRetrieval;
    // Invert R = (1 + factor * (I / S))^decay => I = (S / factor) * (R^(1/decay) - 1)
    final interval = (stability / factor) * (math.pow(r, 1.0 / decay) - 1.0);
    return math.max(1, interval.round());
  }

  /// Alias for [nextInterval] matching reference ts naming.
  int calculateNextInterval(double stability, [double? targetR]) =>
      nextInterval(stability: stability, targetR: targetR);

  /// Updates difficulty with continuous regression to the mean (mitigating "Ease Hell").
  double nextDifficulty({
    required double currentDifficulty,
    required int rating,
  }) {
    final clampedRating = rating.clamp(1, 4);
    final deltaD = -weights[5] * (clampedRating - 3);
    final rawD = currentDifficulty + deltaD;
    final meanD = weights[4]; // Starting baseline difficulty
    final nextD = weights[6] * meanD + (1.0 - weights[6]) * rawD;
    final clamped = nextD.clamp(1.0, 10.0);
    return (clamped * 100).round() / 100.0;
  }

  /// Alias for [nextDifficulty] matching reference ts naming.
  double updateDifficulty(double currentD, int grade) =>
      nextDifficulty(currentDifficulty: currentD, rating: grade);

  /// Calculates the next stability for either successful recall (rating >= 2)
  /// or lapse/failure (rating == 1).
  double nextStability({
    required double difficulty,
    required double stability,
    required double retrievability,
    required int rating,
  }) {
    final clampedRating = rating.clamp(1, 4);
    if (clampedRating == 1) {
      return _updateStabilityLapse(difficulty, stability, retrievability);
    } else {
      return _updateStabilitySuccess(
        difficulty,
        stability,
        retrievability,
        clampedRating,
      );
    }
  }

  /// Updates stability upon successful recall (rating 2: Hard, 3: Good, 4: Easy).
  double _updateStabilitySuccess(
    double d,
    double s,
    double r,
    int rating,
  ) {
    if (s <= 0.0) {
      return initStability(rating);
    }
    final hardPenalty = rating == 2 ? weights[8] : 1.0;
    final easyReward = rating == 4 ? weights[9] : 1.0;

    // Desirable difficulty: lower R at review gives bigger boost
    final retrievabilityBonus = math.exp(weights[7] * (1.0 - r));

    // Stability saturation: consolidating already large stability requires more effort
    final saturationModifier = math.pow(s, -weights[10]);

    // Difficulty penalty: harder cards gain stability more slowly
    final difficultyPenalty = math.pow(11.0 - d, weights[11]);

    final gainMultiplier = 1.0 +
        difficultyPenalty *
            saturationModifier *
            retrievabilityBonus *
            hardPenalty *
            easyReward;

    final nextS = s * math.max(1.05, gainMultiplier);
    return (nextS * 10).round() / 10.0;
  }

  /// Updates stability upon lapse/failure (rating 1: Again).
  double _updateStabilityLapse(
    double d,
    double s,
    double r,
  ) {
    if (s <= 0.0) {
      return initStability(1);
    }
    final postLapseS = weights[12] *
        math.pow(d, -weights[13]) *
        (math.pow(s + 1.0, weights[14]) - 1.0) *
        math.exp((1.0 - r) * weights[15]);

    final rounded = (postLapseS * 10).round() / 10.0;
    final clamped = math.max(0.3, math.min(s * 0.8, rounded));
    return (clamped * 10).round() / 10.0;
  }

  /// Schedules a review turn for an [FSRSCard].
  ///
  /// [rating]:
  /// - 1: Again (Lapso/Fallo)
  /// - 2: Hard
  /// - 3: Good
  /// - 4: Easy
  FSRSCard repeat({
    required FSRSCard card,
    required int rating,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final elapsedDays = card.state == FSRSCardState.newCard
        ? 0.0
        : math.max(
            0.0,
            currentTime
                    .difference(card.lastReviewDate)
                    .inMilliseconds
                    .toDouble() /
                (1000.0 * 60 * 60 * 24),
          );

    final currentR = card.stability > 0.0
        ? calculateRetrievability(elapsedDays, card.stability)
        : 0.0;

    final double nextD;
    final double nextS;
    final FSRSCardState nextState;
    int lapses = card.lapses;

    if (card.state == FSRSCardState.newCard) {
      nextD = initDifficulty(rating);
      nextS = initStability(rating);
      nextState = rating == 1 ? FSRSCardState.learning : FSRSCardState.review;
    } else if (rating == 1) {
      nextD = nextDifficulty(currentDifficulty: card.difficulty, rating: 1);
      nextS = nextStability(
        difficulty: nextD,
        stability: card.stability,
        retrievability: currentR,
        rating: 1,
      );
      nextState = FSRSCardState.relearning;
      lapses += 1;
    } else {
      nextD = nextDifficulty(currentDifficulty: card.difficulty, rating: rating);
      nextS = nextStability(
        difficulty: nextD,
        stability: card.stability,
        retrievability: currentR,
        rating: rating,
      );
      nextState = FSRSCardState.review;
    }

    final nextIntervalDays = nextInterval(
      stability: nextS,
      targetR: targetRetrieval,
    );
    final nextDueDate = currentTime.add(Duration(days: nextIntervalDays));

    return card.copyWith(
      difficulty: nextD,
      stability: nextS,
      retrievability: calculateRetrievability(0.0, nextS),
      reps: card.reps + 1,
      lapses: lapses,
      lastReviewDate: currentTime,
      nextDueDate: nextDueDate,
      scheduledDays: nextIntervalDays,
      state: nextState,
    );
  }

  /// Alias matching reference ts review turn function.
  FSRSCard reviewFSRSCard(FSRSCard card, int grade, [DateTime? now]) =>
      repeat(card: card, rating: grade, now: now);

  /// Creates a brand new initial card.
  FSRSCard createInitialFSRSCard(int id, String lemma, [DateTime? now]) =>
      FSRSCard.initial(id: id, lemma: lemma, now: now);
}
