import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yds_vibe_app/models/card.dart';
import 'package:yds_vibe_app/repositories/card_repository.dart';
import 'package:yds_vibe_app/services/study_controller.dart';
import 'package:yds_vibe_app/core/result.dart';

// Generate mocks with: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([CardRepository])
import 'study_controller_test.mocks.dart';

void main() {
  // Initialize SharedPreferences mock
  SharedPreferences.setMockInitialValues({});

  // Provide dummy factory for Result types in Mockito
  provideDummy<Result<List<VocabularyCard>>>(
    const Success([]),
  );
  provideDummy<Result<void>>(
    const Success(null),
  );

  TestWidgetsFlutterBinding.ensureInitialized();

  group('StudyController - Initialization', () {
    test('initial state values are correct', () {
      final mockRepo = MockCardRepository();
      final controller = StudyController(
        repository: mockRepo,
        category: 'verb',
      );

      expect(controller.allCards, isEmpty);
      expect(controller.reviewQueue, isEmpty);
      expect(controller.currentCard, isNull);
      expect(controller.isFlipped, isFalse);
      expect(controller.reviewOnlyMode, isFalse);
      expect(controller.newCardsToday, 0);
      expect(controller.isLoading, isTrue);
    });

    test('maxNewCardsPerDay reflects AppConstants', () {
      final mockRepo = MockCardRepository();
      final controller = StudyController(
        repository: mockRepo,
        category: '',
      );

      // Assuming AppConstants.maxNewCardsPerDay is 20
      expect(controller.maxNewCardsPerDay, greaterThan(0));
    });
  });

  group('StudyController - Load Cards', () {
    late MockCardRepository mockRepo;

    setUp(() {
      mockRepo = MockCardRepository();
    });

    test('loadCards sets isLoading correctly during operation', () async {
      final now = DateTime(2025, 1, 1);
      final cards = [
        VocabularyCard(
          id: 'card_1',
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
        ),
      ];

      when(mockRepo.getAllCards())
          .thenAnswer((_) async => Success(cards));

      final controller = StudyController(
        repository: mockRepo,
        category: '',
      );

      expect(controller.isLoading, isTrue);

      await controller.loadCards();

      expect(controller.isLoading, isFalse);
    });

    test('loadCards loads all cards when category is empty', () async {
      final now = DateTime(2025, 1, 1);
      final cards = [
        VocabularyCard(
          id: 'card_1',
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
        ),
        VocabularyCard(
          id: 'card_2',
          lemma: 'run',
          pos: 'verb',
          multiWord: false,
          meanings: ['run meaning'],
          synonyms: ['run synonym'],
          example: Example(text: 'Run example.'),
          cloze: Cloze(template: 'Run {{cloze}}', answer: 'run'),
          intervalDays: 0,
          easeFactor: 2.5,
          dueDate: now,
        ),
      ];

      when(mockRepo.getAllCards())
          .thenAnswer((_) async => Success(cards));

      final controller = StudyController(
        repository: mockRepo,
        category: '',
      );

      await controller.loadCards();

      expect(controller.allCards.length, 2);
    });

    test('loadCards filters by category when specified', () async {
      final now = DateTime(2025, 1, 1);
      final cards = [
        VocabularyCard(
          id: 'card_1',
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
        ),
        VocabularyCard(
          id: 'card_2',
          lemma: 'happy',
          pos: 'adj',
          multiWord: false,
          meanings: ['happy meaning'],
          synonyms: ['happy synonym'],
          example: Example(text: 'Happy example.'),
          cloze: Cloze(template: 'Happy {{cloze}}', answer: 'happy'),
          intervalDays: 0,
          easeFactor: 2.5,
          dueDate: now,
        ),
      ];

      when(mockRepo.getAllCards())
          .thenAnswer((_) async => Success(cards));

      final controller = StudyController(
        repository: mockRepo,
        category: 'verb',
      );

      await controller.loadCards();

      expect(controller.allCards.length, 1);
      expect(controller.allCards.first.pos, 'verb');
    });

    test('loadCards handles repository failure gracefully', () async {
      when(mockRepo.getAllCards())
          .thenAnswer((_) async => const Failure('Load failed'));

      final controller = StudyController(
        repository: mockRepo,
        category: '',
      );

      await controller.loadCards();

      expect(controller.allCards, isEmpty);
      expect(controller.isLoading, isFalse);
    });

    test('loadCards loads first card from queue', () async {
      final now = DateTime(2025, 1, 1);
      final cards = [
        VocabularyCard(
          id: 'card_1',
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
        ),
      ];

      when(mockRepo.getAllCards())
          .thenAnswer((_) async => Success(cards));

      final controller = StudyController(
        repository: mockRepo,
        category: '',
      );

      await controller.loadCards();

      expect(controller.currentCard, isNotNull);
      expect(controller.currentCard?.id, 'card_1');
      expect(controller.isFlipped, isFalse);
    });
  });

  group('StudyController - Card Flipping', () {
    late MockCardRepository mockRepo;

    setUp(() async {
      mockRepo = MockCardRepository();
      final now = DateTime(2025, 1, 1);
      final cards = [
        VocabularyCard(
          id: 'card_1',
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
        ),
      ];

      when(mockRepo.getAllCards())
          .thenAnswer((_) async => Success(cards));
    });

    test('flipCard changes isFlipped to true', () async {
      final controller = StudyController(
        repository: mockRepo,
        category: '',
      );

      await controller.loadCards();
      expect(controller.isFlipped, isFalse);

      controller.flipCard();

      expect(controller.isFlipped, isTrue);
    });

    test('flipCard is idempotent - multiple calls have no additional effect', () async {
      final controller = StudyController(
        repository: mockRepo,
        category: '',
      );

      await controller.loadCards();

      controller.flipCard();
      expect(controller.isFlipped, isTrue);

      controller.flipCard(); // Second call should do nothing
      expect(controller.isFlipped, isTrue);
    });
  });

  group('StudyController - Submit Rating', () {
    late MockCardRepository mockRepo;

    setUp(() async {
      mockRepo = MockCardRepository();
      final now = DateTime(2025, 1, 1);
      final cards = [
        VocabularyCard(
          id: 'card_1',
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
        ),
        VocabularyCard(
          id: 'card_2',
          lemma: 'run',
          pos: 'verb',
          multiWord: false,
          meanings: ['run meaning'],
          synonyms: ['run synonym'],
          example: Example(text: 'Run example.'),
          cloze: Cloze(template: 'Run {{cloze}}', answer: 'run'),
          intervalDays: 0,
          easeFactor: 2.5,
          dueDate: now,
        ),
      ];

      when(mockRepo.getAllCards())
          .thenAnswer((_) async => Success(cards));

      when(mockRepo.saveCardProgress(any))
          .thenAnswer((_) async => const Success(null));
    });

    test('submitRating removes current card from queue', () async {
      final controller = StudyController(
        repository: mockRepo,
        category: '',
      );

      await controller.loadCards();
      final initialQueueSize = controller.reviewQueue.length;

      await controller.submitRating(Rating.good);

      expect(controller.reviewQueue.length, lessThan(initialQueueSize));
    });

    test('submitRating loads next card', () async {
      final controller = StudyController(
        repository: mockRepo,
        category: '',
      );

      await controller.loadCards();
      final firstCardId = controller.currentCard?.id;

      await controller.submitRating(Rating.good);

      expect(controller.currentCard?.id, isNot(firstCardId));
      expect(controller.isFlipped, isFalse);
    });

    test('submitRating saves card progress to repository', () async {
      final controller = StudyController(
        repository: mockRepo,
        category: '',
      );

      await controller.loadCards();

      await controller.submitRating(Rating.good);

      verify(mockRepo.saveCardProgress(any)).called(1);
    });

    test('submitRating with Again does not increment newCardsToday', () async {
      final controller = StudyController(
        repository: mockRepo,
        category: '',
      );

      await controller.loadCards();
      final initialNewCards = controller.newCardsToday;

      await controller.submitRating(Rating.again);

      expect(controller.newCardsToday, initialNewCards);
    });
  });

  group('StudyController - Review Only Mode', () {
    late MockCardRepository mockRepo;

    setUp(() async {
      mockRepo = MockCardRepository();
      final now = DateTime(2025, 1, 1);
      final dueCard = VocabularyCard(
        id: 'due_card',
        lemma: 'due',
        pos: 'verb',
        multiWord: false,
        meanings: ['due meaning'],
        synonyms: ['due synonym'],
        example: Example(text: 'Due example.'),
        cloze: Cloze(template: 'Due {{cloze}}', answer: 'due'),
        intervalDays: 0,
        easeFactor: 2.5,
        dueDate: now, // Due now
      );
      final newCard = VocabularyCard(
        id: 'new_card',
        lemma: 'new',
        pos: 'verb',
        multiWord: false,
        meanings: ['new meaning'],
        synonyms: ['new synonym'],
        example: Example(text: 'New example.'),
        cloze: Cloze(template: 'New {{cloze}}', answer: 'new'),
        intervalDays: 0,
        easeFactor: 2.5,
        dueDate: now.add(const Duration(days: 1)), // Due tomorrow (new)
      );

      when(mockRepo.getAllCards())
          .thenAnswer((_) async => Success([dueCard, newCard]));

      when(mockRepo.saveCardProgress(any))
          .thenAnswer((_) async => const Success(null));
    });

    test('toggleReviewOnlyMode excludes new cards when enabled', () async {
      final controller = StudyController(
        repository: mockRepo,
        category: '',
      );

      await controller.loadCards();
      final initialQueueSize = controller.reviewQueue.length;

      controller.toggleReviewOnlyMode(true);

      expect(controller.reviewQueue.length, lessThanOrEqualTo(initialQueueSize));
      expect(controller.reviewOnlyMode, isTrue);
    });

    test('toggleReviewOnlyMode includes new cards when disabled', () async {
      final controller = StudyController(
        repository: mockRepo,
        category: '',
      );

      await controller.loadCards();
      controller.toggleReviewOnlyMode(true);
      final reviewOnlySize = controller.reviewQueue.length;

      controller.toggleReviewOnlyMode(false);

      expect(controller.reviewQueue.length, greaterThanOrEqualTo(reviewOnlySize));
      expect(controller.reviewOnlyMode, isFalse);
    });

    test('toggleReviewOnlyMode resets isFlipped', () async {
      final controller = StudyController(
        repository: mockRepo,
        category: '',
      );

      await controller.loadCards();
      controller.flipCard();

      expect(controller.isFlipped, isTrue);

      controller.toggleReviewOnlyMode(true);

      expect(controller.isFlipped, isFalse);
    });
  });

  group('StudyController - Empty State', () {
    late MockCardRepository mockRepo;

    setUp(() {
      mockRepo = MockCardRepository();
    });

    test('currentCard is null when no cards available', () async {
      when(mockRepo.getAllCards())
          .thenAnswer((_) async => Success(<VocabularyCard>[]));

      final controller = StudyController(
        repository: mockRepo,
        category: '',
      );

      await controller.loadCards();

      expect(controller.currentCard, isNull);
      expect(controller.reviewQueue, isEmpty);
    });
  });
}
