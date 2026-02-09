import 'package:flutter_test/flutter_test.dart';
import 'package:yds_vibe_app/models/card.dart';
import 'package:yds_vibe_app/services/srs_service.dart';

void main() {
  group('SRSService - Minimum Interval', () {
    test('minimum interval is 1 day for Good rating on new card', () {
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

      final result = SRSService.processReview(card, Rating.good, now: now);

      expect(result.intervalDays, 1);
      expect(result.dueDate, now.add(Duration(days: 1)));
    });
  });

  group('SRSService - Again Rating', () {
    test('Again does not increase interval', () {
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

      final result = SRSService.processReview(card, Rating.again, now: now);

      expect(result.intervalDays, 0);
    });
  });

  group('SRSService - Struggled vs Good', () {
    test('Struggled schedules earlier than Good', () {
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

      final struggledResult = SRSService.processReview(card, Rating.struggled, now: now);
      final goodResult = SRSService.processReview(card, Rating.good, now: now);

      expect(struggledResult.intervalDays, lessThan(goodResult.intervalDays));
    });
  });

  group('SRSService - Easy vs Good', () {
    test('Easy schedules later than Good', () {
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

      final goodResult = SRSService.processReview(card, Rating.good, now: now);
      final easyResult = SRSService.processReview(card, Rating.easy, now: now);

      expect(easyResult.intervalDays, greaterThan(goodResult.intervalDays));
    });
  });
}
