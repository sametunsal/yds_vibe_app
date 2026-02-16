import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yds_vibe_app/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressService - CardProgress Model', () {
    test('CardProgress toJson/fromJson serialization is consistent', () {
      final now = DateTime(2025, 1, 1, 12, 0);
      final progress = CardProgress(
        easeFactor: 2.5,
        intervalDays: 5,
        dueDate: now,
        repetitions: 3,
        lastReviewed: now,
      );

      final json = progress.toJson();
      final restored = CardProgress.fromJson(json);

      expect(restored.easeFactor, progress.easeFactor);
      expect(restored.intervalDays, progress.intervalDays);
      expect(restored.repetitions, progress.repetitions);
      expect(restored.dueDate, equals(progress.dueDate));
      expect(restored.lastReviewed, equals(progress.lastReviewed));
    });

    test('CardProgress fromJson handles missing values with defaults', () {
      final json = <String, dynamic>{};
      final progress = CardProgress.fromJson(json);

      expect(progress.easeFactor, 2.5); // default
      expect(progress.intervalDays, 0); // default
      expect(progress.repetitions, 0); // default
      expect(progress.dueDate, isNotNull);
      expect(progress.lastReviewed, isNull);
    });

    test('CardProgress fromJson handles partial data', () {
      final json = <String, dynamic>{
        'easeFactor': 1.8,
        'intervalDays': 10,
      };
      final progress = CardProgress.fromJson(json);

      expect(progress.easeFactor, 1.8);
      expect(progress.intervalDays, 10);
      expect(progress.repetitions, 0);
      expect(progress.lastReviewed, isNull);
    });
  });

  group('ProgressService - Load Operations', () {
    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('progress_json');
    });

    test('loadProgress returns empty map when no data exists', () async {
      final result = await ProgressService.loadProgress();

      expect(result, isEmpty);
      expect(result, isA<Map<String, CardProgress>>());
    });

    test('loadProgress returns saved progress data', () async {
      final now = DateTime(2025, 1, 1);
      final testProgress = {
        'card_1': CardProgress(
          easeFactor: 2.5,
          intervalDays: 1,
          dueDate: now,
          repetitions: 1,
        ),
        'card_2': CardProgress(
          easeFactor: 2.6,
          intervalDays: 3,
          dueDate: now.add(const Duration(days: 3)),
          repetitions: 2,
          lastReviewed: now,
        ),
      };

      await ProgressService.saveProgress(testProgress);
      final loaded = await ProgressService.loadProgress();

      expect(loaded.length, 2);
      expect(loaded['card_1']?.easeFactor, 2.5);
      expect(loaded['card_2']?.intervalDays, 3);
    });

    test('loadProgress handles corrupted JSON gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('progress_json', 'invalid json{{}');

      final result = await ProgressService.loadProgress();

      // Should return empty map on error instead of throwing
      expect(result, isEmpty);
    });

    test('loadProgress handles partially corrupted entries', () async {
      final prefs = await SharedPreferences.getInstance();
      // Construct valid JSON with one corrupted entry
      final jsonStr = '''
      {
        "card_1": {
          "easeFactor": 2.5,
          "intervalDays": 1,
          "dueDate": "2025-01-01T00:00:00.000Z",
          "repetitions": 1
        },
        "card_invalid": {
          "easeFactor": "not a number"
        }
      }
      ''';
      await prefs.setString('progress_json', jsonStr);

      final result = await ProgressService.loadProgress();

      // Should skip invalid entry but keep valid ones
      expect(result, isNotEmpty);
      expect(result.containsKey('card_1'), isTrue);
    });

    test('loadProgress handles empty string storage', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('progress_json', '');

      final result = await ProgressService.loadProgress();

      expect(result, isEmpty);
    });
  });

  group('ProgressService - Save Operations', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('progress_json');
    });

    test('saveProgress persists data correctly', () async {
      final now = DateTime(2025, 1, 1);
      final testProgress = {
        'card_1': CardProgress(
          easeFactor: 2.5,
          intervalDays: 1,
          dueDate: now,
          repetitions: 1,
        ),
      };

      await ProgressService.saveProgress(testProgress);

      final loaded = await ProgressService.loadProgress();
      expect(loaded.length, 1);
      expect(loaded['card_1']?.easeFactor, 2.5);
    });

    test('saveProgress overwrites existing data', () async {
      final now = DateTime(2025, 1, 1);
      final firstProgress = {
        'card_1': CardProgress(
          easeFactor: 2.5,
          intervalDays: 1,
          dueDate: now,
          repetitions: 1,
        ),
        'card_2': CardProgress(
          easeFactor: 2.6,
          intervalDays: 2,
          dueDate: now,
          repetitions: 2,
        ),
      };

      await ProgressService.saveProgress(firstProgress);

      final secondProgress = {
        'card_3': CardProgress(
          easeFactor: 2.7,
          intervalDays: 3,
          dueDate: now,
          repetitions: 3,
        ),
      };

      await ProgressService.saveProgress(secondProgress);

      final loaded = await ProgressService.loadProgress();
      expect(loaded.length, 1);
      expect(loaded.containsKey('card_3'), isTrue);
      expect(loaded.containsKey('card_1'), isFalse);
      expect(loaded.containsKey('card_2'), isFalse);
    });

    test('saveProgress handles empty map', () async {
      await ProgressService.saveProgress({});

      final loaded = await ProgressService.loadProgress();
      expect(loaded, isEmpty);
    });
  });

  group('ProgressService - Update Operations', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('progress_json');
    });

    test('updateCardProgress adds new entry', () async {
      final now = DateTime(2025, 1, 1);
      final allProgress = <String, CardProgress>{};

      final newProgress = CardProgress(
        easeFactor: 2.5,
        intervalDays: 1,
        dueDate: now,
        repetitions: 1,
      );

      await ProgressService.updateCardProgress('card_new', newProgress, allProgress);

      expect(allProgress['card_new'], equals(newProgress));
      expect(allProgress.length, 1);

      // Verify persistence
      final loaded = await ProgressService.loadProgress();
      expect(loaded['card_new']?.easeFactor, 2.5);
    });

    test('updateCardProgress updates existing entry', () async {
      final now = DateTime(2025, 1, 1);
      final allProgress = {
        'card_1': CardProgress(
          easeFactor: 2.5,
          intervalDays: 1,
          dueDate: now,
          repetitions: 1,
        ),
      };

      final updatedProgress = CardProgress(
        easeFactor: 2.6,
        intervalDays: 5,
        dueDate: now.add(const Duration(days: 5)),
        repetitions: 2,
      );

      await ProgressService.updateCardProgress('card_1', updatedProgress, allProgress);

      expect(allProgress['card_1']?.easeFactor, 2.6);
      expect(allProgress['card_1']?.intervalDays, 5);
      expect(allProgress.length, 1); // No new entry added
    });

    test('updateCardProgress persists changes immediately', () async {
      final now = DateTime(2025, 1, 1);
      final allProgress = <String, CardProgress>{};

      final newProgress = CardProgress(
        easeFactor: 2.5,
        intervalDays: 1,
        dueDate: now,
        repetitions: 1,
      );

      await ProgressService.updateCardProgress('card_1', newProgress, allProgress);

      // Clear local map
      allProgress.clear();

      // Load from storage
      final loaded = await ProgressService.loadProgress();
      expect(loaded['card_1']?.easeFactor, 2.5);
    });
  });

  group('ProgressService - DateTime Handling', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('progress_json');
    });

    test('dueDate is stored and restored in local timezone', () async {
      final localDate = DateTime(2025, 1, 1, 0, 0, 0);
      final progress = CardProgress(
        easeFactor: 2.5,
        intervalDays: 1,
        dueDate: localDate,
        repetitions: 1,
      );

      await ProgressService.saveProgress({'card_1': progress});
      final loaded = await ProgressService.loadProgress();

      expect(loaded['card_1']?.dueDate.year, localDate.year);
      expect(loaded['card_1']?.dueDate.month, localDate.month);
      expect(loaded['card_1']?.dueDate.day, localDate.day);
    });

    test('lastReviewed null is preserved', () async {
      final progress = CardProgress(
        easeFactor: 2.5,
        intervalDays: 0,
        dueDate: DateTime(2025, 1, 1),
        repetitions: 0,
        lastReviewed: null,
      );

      await ProgressService.saveProgress({'card_1': progress});
      final loaded = await ProgressService.loadProgress();

      expect(loaded['card_1']?.lastReviewed, isNull);
    });
  });
}
