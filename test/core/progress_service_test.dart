import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/progress_service.dart';
import 'package:descubre_con_lua/data/models/fsrs_card_model.dart';

void main() {
  group('ProgressService Tests (Offline LocalStore Persistence & XP Engine)', () {
    late Directory tempDir;
    late ProgressService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('progress_test_');
      service = ProgressService(overrideDirectory: tempDir.path);
      await service.initialize();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('initial state has zero XP, empty records, and sound enabled', () {
      expect(service.isInitialized, isTrue);
      expect(service.xp, equals(0));
      expect(service.currentStreak, equals(0));
      expect(service.bestStreak, equals(0));
      expect(service.lastActiveDate, isNull);
      expect(service.asambleasCompletadas, isEmpty);
      expect(service.capsulasCompletadas, isEmpty);
      expect(service.registrosAula, isEmpty);
      expect(service.registrosFogar, isEmpty);
      expect(service.fsrsCards, isEmpty);
      expect(service.soundEnabled, isTrue);
    });

    test('addXp increments XP and persists across service instances', () async {
      await service.addXp(150);
      expect(service.xp, equals(150));

      // Reload in a fresh service instance pointing to the same storage
      final reloaded = ProgressService(overrideDirectory: tempDir.path);
      await reloaded.initialize();
      expect(reloaded.xp, equals(150));
    });

    test('recordAssemblyCompleted logs assembly, adds XP, marks aula, and updates streak', () async {
      final today = DateTime(2026, 9, 20);
      await service.recordAssemblyCompleted('juega.mar.01', date: today, xpReward: 50);

      expect(service.xp, equals(50));
      expect(service.asambleasCompletadas, contains('juega.mar.01'));
      expect(service.registrosAula['2026-09-20'], isTrue);
      expect(service.currentStreak, equals(1));
      expect(service.bestStreak, equals(1));
      expect(service.lastActiveDate, equals('2026-09-20'));

      // Re-running same day should not increment streak
      await service.recordAssemblyCompleted('juega.auga.01', date: today, xpReward: 50);
      expect(service.xp, equals(100));
      expect(service.currentStreak, equals(1));
    });

    test('recordCapsulaCompleted logs capsule, adds XP, marks fogar, and updates streak', () async {
      final today = DateTime(2026, 9, 20);
      await service.recordCapsulaCompleted('academy.hablar.01', date: today, xpReward: 30);

      expect(service.xp, equals(30));
      expect(service.capsulasCompletadas, contains('academy.hablar.01'));
      expect(service.registrosFogar['2026-09-20'], isTrue);
      expect(service.currentStreak, equals(1));
    });

    test('streak progression updates on consecutive days and resets on missed days', () async {
      // Day 1
      await service.recordRegistroAula('2026-09-20');
      expect(service.currentStreak, equals(1));
      expect(service.bestStreak, equals(1));

      // Day 2 (Consecutive)
      await service.recordRegistroFogar('2026-09-21');
      expect(service.currentStreak, equals(2));
      expect(service.bestStreak, equals(2));

      // Day 5 (3 days skipped -> broken streak)
      await service.recordRegistroAula('2026-09-25');
      expect(service.currentStreak, equals(1));
      expect(service.bestStreak, equals(2)); // Best streak preserved
    });

    test('recordFsrsReview updates card state and stores in collection', () async {
      final now = DateTime(2026, 9, 20, 12, 0);
      final initialCard = FSRSCard.initial(id: 1, lemma: 'water', now: now);
      await service.saveCard(initialCard);

      expect(service.getCard(1), isNotNull);
      expect(service.getCard(1)!.state, equals(FSRSCardState.newCard));

      // Review card with rating 3 (Good)
      final reviewed = await service.recordFsrsReview(initialCard, 3, now: now, xpReward: 10);
      expect(reviewed.state, equals(FSRSCardState.review));
      expect(reviewed.reps, equals(1));
      expect(service.xp, equals(10));

      final stored = service.getCard(1);
      expect(stored, isNotNull);
      expect(stored!.reps, equals(1));
      expect(stored.state, equals(FSRSCardState.review));

      // Persistence check
      final reloaded = ProgressService(overrideDirectory: tempDir.path);
      await reloaded.initialize();
      expect(reloaded.getCard(1)?.lemma, equals('water'));
      expect(reloaded.getCard(1)?.reps, equals(1));
    });

    test('getDueCards returns cards scheduled before or at current time', () async {
      final now = DateTime(2026, 9, 20, 12, 0);
      final dueCard = FSRSCard(
        id: 1,
        lemma: 'water',
        difficulty: 5.0,
        stability: 1.0,
        retrievability: 0.9,
        reps: 1,
        lapses: 0,
        lastReviewDate: now.subtract(const Duration(days: 2)),
        nextDueDate: now.subtract(const Duration(hours: 1)),
        scheduledDays: 1,
        state: FSRSCardState.review,
      );
      final futureCard = FSRSCard(
        id: 2,
        lemma: 'apple',
        difficulty: 5.0,
        stability: 10.0,
        retrievability: 0.95,
        reps: 2,
        lapses: 0,
        lastReviewDate: now,
        nextDueDate: now.add(const Duration(days: 10)),
        scheduledDays: 10,
        state: FSRSCardState.review,
      );

      await service.saveCard(dueCard);
      await service.saveCard(futureCard);

      final dueCards = service.getDueCards(now: now);
      expect(dueCards.length, equals(1));
      expect(dueCards.first.lemma, equals('water'));

      final allCards = service.getAllCards();
      expect(allCards.length, equals(2));
    });

    test('toggleSound toggles and persists audio settings', () async {
      expect(service.soundEnabled, isTrue);
      await service.toggleSound();
      expect(service.soundEnabled, isFalse);

      final reloaded = ProgressService(overrideDirectory: tempDir.path);
      await reloaded.initialize();
      expect(reloaded.soundEnabled, isFalse);
    });

    test('resetProgress clears all data and resets state', () async {
      await service.addXp(500);
      await service.recordAssemblyCompleted('asamblea_1');
      await service.recordCapsulaCompleted('capsula_1');
      expect(service.xp, equals(580));

      await service.resetProgress();
      expect(service.xp, equals(0));
      expect(service.currentStreak, equals(0));
      expect(service.asambleasCompletadas, isEmpty);
      expect(service.capsulasCompletadas, isEmpty);

      final reloaded = ProgressService(overrideDirectory: tempDir.path);
      await reloaded.initialize();
      expect(reloaded.xp, equals(0));
    });
  });
}
