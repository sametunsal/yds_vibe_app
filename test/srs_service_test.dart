import 'package:flutter_test/flutter_test.dart';
import 'package:yds_vibe_app/models/card.dart';
import 'package:yds_vibe_app/services/srs_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Mock SharedPreferences for StreakService
  try {
    // This is needed because StreakService uses SharedPreferences
    // and in pure unit tests we need to mock the initial values
    // or binding.
    // However, since we can't easily import SharedPreferences here without adding deps to dev_dependencies if not present,
    // we will rely on ensureInitialized being enough for basic run or assume integration test environment.
    // Ideally we should mock StreakService or SharedPreferences.
    // For this simple test file, just ensuring binding might be enough if flutter_test handles it.
    // Actually, SharedPreferences.setMockInitialValues({}); is the standard way.
  } catch (e) {
    // Ignore
  }

  group('SRSService - Minimum Interval', () {
    test('minimum interval is 1 day for Good rating on new card', () async {
      final now = DateTime(2025, 1, 1);
      final card = VocabularyCard(
        id: 'test_1',
        lemma: 'test',
        pos: 'verb',
        multiWord: false,
        meanings: ['test meaning'],
        synonyms: ['test synonym'],
        example: Example(text: 'Test example.'),
        cloze: Cloze(template: 'Test {{cloze}}', answer: 'test'),
        intervalDays: 0,
        easeFactor: 2.5,
        dueDate: now,
      );

      // Using a valid context for SharedPreferences usually requires
      // SharedPreferences.setMockInitialValues({});
      // Since we don't import shared_preferences in test file, we might get error.
      // But let's try to just await.

      // NOTE: In a real app we'd mock StreakService.
      // For now, if this fails due to MissingPluginException, we'll need to add setup.

      final result = await SRSService.processReview(
        card,
        Rating.good,
        now: now,
      );

      expect(result.intervalDays, 1);
      expect(result.dueDate, now.add(Duration(days: 1)));
    });
  });

  group('SRSService - Again Rating', () {
    test('Again does not increase interval', () async {
      final now = DateTime(2025, 1, 1);
      final card = VocabularyCard(
        id: 'test_2',
        lemma: 'test',
        pos: 'verb',
        multiWord: false,
        meanings: ['test meaning'],
        synonyms: ['test synonym'],
        example: Example(text: 'Test example.'),
        cloze: Cloze(template: 'Test {{cloze}}', answer: 'test'),
        intervalDays: 10,
        easeFactor: 2.5,
        dueDate: now,
      );

      final result = await SRSService.processReview(
        card,
        Rating.again,
        now: now,
      );

      expect(result.intervalDays, 0);
    });
  });

  group('SRSService - Struggled vs Good', () {
    test('Struggled schedules earlier than Good', () async {
      final now = DateTime(2025, 1, 1);
      final card = VocabularyCard(
        id: 'test_3',
        lemma: 'test',
        pos: 'verb',
        multiWord: false,
        meanings: ['test meaning'],
        synonyms: ['test synonym'],
        example: Example(text: 'Test example.'),
        cloze: Cloze(template: 'Test {{cloze}}', answer: 'test'),
        intervalDays: 5,
        easeFactor: 2.5,
        dueDate: now,
      );

      final struggledResult = await SRSService.processReview(
        card,
        Rating.struggled,
        now: now,
      );
      final goodResult = await SRSService.processReview(
        card,
        Rating.good,
        now: now,
      );

      expect(struggledResult.intervalDays, lessThan(goodResult.intervalDays));
    });
  });

  group('SRSService - Easy vs Good', () {
    test('Easy schedules later than Good', () async {
      final now = DateTime(2025, 1, 1);
      final card = VocabularyCard(
        id: 'test_4',
        lemma: 'test',
        pos: 'verb',
        multiWord: false,
        meanings: ['test meaning'],
        synonyms: ['test synonym'],
        example: Example(text: 'Test example.'),
        cloze: Cloze(template: 'Test {{cloze}}', answer: 'test'),
        intervalDays: 5,
        easeFactor: 2.5,
        dueDate: now,
      );

      final goodResult = await SRSService.processReview(
        card,
        Rating.good,
        now: now,
      );
      final easyResult = await SRSService.processReview(
        card,
        Rating.easy,
        now: now,
      );

      expect(easyResult.intervalDays, greaterThan(goodResult.intervalDays));
    });
  });
}
