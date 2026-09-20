import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/fsrs_service.dart';
import 'package:descubre_con_lua/data/models/fsrs_card_model.dart';

void main() {
  group('FsrsService Core Algorithm Tests (FSRS v4.5)', () {
    late FsrsService service;

    setUp(() {
      service = const FsrsService();
    });

    test('default 17 weights conform strictly to FSRS v4.5 canonical configuration', () {
      expect(FsrsService.defaultWeights.length, equals(17));
      expect(
        FsrsService.defaultWeights,
        equals([
          0.4, 0.6, 2.4, 5.8, // w[0..3]
          4.93, 0.94, // w[4..5]
          0.86, // w[6]
          0.01, // w[7]
          1.49, // w[8]
          0.14, // w[9]
          0.94, // w[10]
          2.18, // w[11]
          0.05, 0.34, 1.26, 0.29, // w[12..15]
          2.61, // w[16]
        ]),
      );
    });

    test('retrievability formula R(t, S) = (1 + factor * t / S)^decay behaves predictably', () {
      // At t = 0, R must be 100%
      expect(service.calculateRetrievability(0.0, 10.0), equals(1.0));

      // At t = S, by construction factor = 19/81 and decay = -0.5:
      // R = (1 + 19/81)^(-0.5) = (100/81)^(-0.5) = (10/9)^(-1) = 9/10 = 0.90
      final rAtS = service.calculateRetrievability(10.0, 10.0);
      expect(rAtS, closeTo(0.90, 0.0001));

      // As time increases beyond S, R must decay strictly below 0.90
      final rAt2S = service.calculateRetrievability(20.0, 10.0);
      expect(rAt2S, lessThan(0.90));
      expect(rAt2S, greaterThan(0.0));

      // Stability <= 0 must yield 0.0
      expect(service.calculateRetrievability(5.0, 0.0), equals(0.0));
      expect(service.calculateRetrievability(5.0, -1.0), equals(0.0));
    });

    test('initStability maps ratings 1..4 directly to initial weight tiers', () {
      expect(service.initStability(1), equals(0.4)); // Again
      expect(service.initStability(2), equals(0.6)); // Hard
      expect(service.initStability(3), equals(2.4)); // Good
      expect(service.initStability(4), equals(5.8)); // Easy
    });

    test('initDifficulty computes initial difficulty correctly clamped in [1.0, 10.0]', () {
      // Rating 3 (Good): baseline w[4] = 4.93
      expect(service.initDifficulty(3), equals(4.93));

      // Rating 1 (Again): w[4] - (1 - 3) * w[5] = 4.93 - (-2 * 0.94) = 4.93 + 1.88 = 6.81
      expect(service.initDifficulty(1), equals(6.81));

      // Rating 4 (Easy): w[4] - (4 - 3) * w[5] = 4.93 - 0.94 = 3.99
      expect(service.initDifficulty(4), equals(3.99));
    });

    test('nextInterval calculates days correctly for stability at 90% retrievability', () {
      // At stability = 10 days and targetR = 0.90, next interval must equal 10 days
      expect(service.nextInterval(stability: 10.0, targetR: 0.90), equals(10));
      expect(service.nextInterval(stability: 1.0, targetR: 0.90), equals(1));
      expect(service.nextInterval(stability: 0.0), equals(1));
      expect(service.nextInterval(stability: -5.0), equals(1));
    });

    test('nextDifficulty applies continuous regression to the mean', () {
      // Starting from hard difficulty 8.0, rating 3 (Good) should regress towards mean (4.93)
      final nextD = service.nextDifficulty(currentDifficulty: 8.0, rating: 3);
      expect(nextD, lessThan(8.0));
      expect(nextD, greaterThan(4.93));

      // Starting from easy difficulty 2.0, rating 3 should regress upwards towards mean (4.93)
      final nextDEasy = service.nextDifficulty(currentDifficulty: 2.0, rating: 3);
      expect(nextDEasy, greaterThan(2.0));
      expect(nextDEasy, lessThan(4.93));
    });

    test('nextStability increases on success and penalizes on lapse', () {
      const d = 5.0;
      const s = 10.0;
      const r = 0.90;

      // Rating 1: Lapse
      final lapseS = service.nextStability(difficulty: d, stability: s, retrievability: r, rating: 1);
      expect(lapseS, lessThan(s));
      expect(lapseS, greaterThanOrEqualTo(0.3));

      // Rating 3: Good (Success)
      final goodS = service.nextStability(difficulty: d, stability: s, retrievability: r, rating: 3);
      expect(goodS, greaterThan(s));

      // Rating 4: Easy gives larger stability gain than Rating 2: Hard
      final hardS = service.nextStability(difficulty: d, stability: s, retrievability: r, rating: 2);
      final easyS = service.nextStability(difficulty: d, stability: s, retrievability: r, rating: 4);
      expect(easyS, greaterThan(goodS));
      expect(goodS, greaterThan(hardS));
    });

    test('repeat transitions card state properly on new card review', () {
      final now = DateTime(2026, 9, 20, 10, 0);
      final card = FSRSCard.initial(id: 42, lemma: 'water', now: now);
      expect(card.state, equals(FSRSCardState.newCard));
      expect(card.reps, equals(0));

      // Review turn with rating 3 (Good)
      final reviewed = service.repeat(card: card, rating: 3, now: now);
      expect(reviewed.state, equals(FSRSCardState.review));
      expect(reviewed.reps, equals(1));
      expect(reviewed.lapses, equals(0));
      expect(reviewed.stability, equals(2.4)); // w[2]
      expect(reviewed.difficulty, equals(4.93)); // w[4]
      expect(reviewed.scheduledDays, greaterThan(0));
      expect(reviewed.nextDueDate.isAfter(now), isTrue);
    });

    test('repeat handles lapse by incrementing lapses and setting relearning state', () {
      final now = DateTime(2026, 9, 20, 10, 0);
      final initialCard = FSRSCard(
        id: 10,
        lemma: 'apple',
        difficulty: 5.0,
        stability: 15.0,
        retrievability: 0.90,
        reps: 4,
        lapses: 0,
        lastReviewDate: now.subtract(const Duration(days: 15)),
        nextDueDate: now,
        scheduledDays: 15,
        state: FSRSCardState.review,
      );

      final lapsed = service.repeat(card: initialCard, rating: 1, now: now);
      expect(lapsed.state, equals(FSRSCardState.relearning));
      expect(lapsed.lapses, equals(1));
      expect(lapsed.reps, equals(5));
      expect(lapsed.stability, lessThan(initialCard.stability));
    });
  });
}
