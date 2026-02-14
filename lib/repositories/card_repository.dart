import '../core/result.dart';
import '../data/card_loader.dart';
import '../models/card.dart';
import '../services/progress_service.dart';
import '../services/srs_service.dart';

abstract class CardRepository {
  Future<Result<List<VocabularyCard>>> getAllCards();
  Future<Result<List<VocabularyCard>>> getCardsByCategory(String category);
  Future<Result<void>> saveCardProgress(VocabularyCard card);
  Future<Result<void>> saveAllProgress(List<VocabularyCard> cards);
}

class CardRepositoryImpl implements CardRepository {
  Map<String, CardProgress>? _progressCache;

  Future<Map<String, CardProgress>> _loadProgress() async {
    _progressCache ??= await ProgressService.loadProgress();
    return _progressCache!;
  }

  List<VocabularyCard> _mergeProgress(
    List<VocabularyCard> cards,
    Map<String, CardProgress> progress,
  ) {
    return cards.map((card) {
      final p = progress[card.id];
      if (p == null) return card;
      return card.copyWith(
        easeFactor: p.easeFactor,
        intervalDays: p.intervalDays,
        dueDate: p.dueDate,
        repetitions: p.repetitions,
        lastReviewed: p.lastReviewed,
      );
    }).toList();
  }

  @override
  Future<Result<List<VocabularyCard>>> getAllCards() async {
    try {
      final cards = await CardLoader.loadCards();
      final progress = await _loadProgress();
      return Success(_mergeProgress(cards, progress));
    } catch (e) {
      return Failure('Kartlar yüklenemedi: $e');
    }
  }

  @override
  Future<Result<List<VocabularyCard>>> getCardsByCategory(
    String category,
  ) async {
    try {
      final result = await getAllCards();
      return switch (result) {
        Success(value: final cards) => Success(
          SRSService.getCardsByCategory(cards, category),
        ),
        Failure() => result,
      };
    } catch (e) {
      return Failure('Kategori kartları yüklenemedi: $e');
    }
  }

  @override
  Future<Result<void>> saveCardProgress(VocabularyCard card) async {
    try {
      final progress = await _loadProgress();
      final cardProgress = CardProgress(
        easeFactor: card.easeFactor,
        intervalDays: card.intervalDays,
        dueDate: card.dueDate,
        repetitions: card.repetitions,
        lastReviewed: card.lastReviewed,
      );
      await ProgressService.updateCardProgress(card.id, cardProgress, progress);
      return const Success(null);
    } catch (e) {
      return Failure('İlerleme kaydedilemedi: $e');
    }
  }

  @override
  Future<Result<void>> saveAllProgress(List<VocabularyCard> cards) async {
    try {
      final progress = <String, CardProgress>{};
      for (final card in cards) {
        if (card.repetitions > 0 || card.lastReviewed != null) {
          progress[card.id] = CardProgress(
            easeFactor: card.easeFactor,
            intervalDays: card.intervalDays,
            dueDate: card.dueDate,
            repetitions: card.repetitions,
            lastReviewed: card.lastReviewed,
          );
        }
      }
      _progressCache = progress;
      await ProgressService.saveProgress(progress);
      return const Success(null);
    } catch (e) {
      return Failure('İlerleme kaydedilemedi: $e');
    }
  }
}
