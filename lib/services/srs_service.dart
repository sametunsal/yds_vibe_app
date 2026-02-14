import '../constants/app_constants.dart';
import '../models/card.dart';
import 'streak_service.dart';

class SRSService {
  // SM-2 Algorithm Implementation
  // Returns an updated card with new interval and ease factor
  // Optional `now` parameter for deterministic testing

  static Future<VocabularyCard> processReview(
    VocabularyCard card,
    Rating rating, {
    DateTime? now,
  }) async {
    double newEaseFactor = card.easeFactor;
    int newInterval;
    int newRepetitions = card.repetitions;

    switch (rating) {
      case Rating.again:
        // "Again" - Reset to beginning, don't advance interval
        newEaseFactor = _calculateEaseFactor(card.easeFactor, 0);
        newInterval = 0; // Due immediately
        newRepetitions = 0; // Reset repetitions
        break;

      case Rating.struggled:
        // "Struggled" - Small advance or stay at 1
        newEaseFactor = _calculateEaseFactor(card.easeFactor, 1);
        if (card.intervalDays == 0) {
          newInterval = 1;
        } else {
          newInterval = 1; // Reset to 1 day
        }
        // Don't increment repetitions for struggled
        break;

      case Rating.good:
        // "Good" - Normal interval progression
        newEaseFactor = _calculateEaseFactor(card.easeFactor, 2);
        if (card.intervalDays == 0) {
          newInterval = 1;
        } else {
          newInterval = (card.intervalDays * card.easeFactor).round();
          if (newInterval < 1) newInterval = 1;
        }
        newRepetitions++; // Increment for successful review
        break;

      case Rating.easy:
        // "Easy" - Longer interval
        newEaseFactor = _calculateEaseFactor(card.easeFactor, 3);
        if (card.intervalDays == 0) {
          newInterval = 2;
        } else {
          newInterval =
              (card.intervalDays *
                      card.easeFactor *
                      AppConstants.easyMultiplier)
                  .round();
          if (newInterval < 1) newInterval = 1;
        }
        newRepetitions++; // Increment for successful review
        break;
    }

    // Ensure ease factor doesn't go below 1.3
    if (newEaseFactor < AppConstants.minEaseFactor) {
      newEaseFactor = AppConstants.minEaseFactor;
    }

    // Calculate new due date: local midnight + interval days
    final currentTime = now ?? DateTime.now();
    final localMidnight = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
    );
    final newDueDate = localMidnight.add(Duration(days: newInterval));

    // Save study activity for streak overlap
    await StreakService.saveStudyActivity();

    return card.copyWith(
      easeFactor: newEaseFactor,
      intervalDays: newInterval,
      dueDate: newDueDate,
      repetitions: newRepetitions,
      lastReviewed: currentTime,
    );
  }

  // SM-2 ease factor calculation
  // EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
  // Where q is quality: Again=0, Struggled=1, Good=2, Easy=3 (simplified from original 0-5 scale)
  static double _calculateEaseFactor(double currentEF, int quality) {
    // Map our 0-3 scale to SM-2's approximate 0-5 scale
    // 0 (Again) -> 0, 1 (Struggled) -> 2, 2 (Good) -> 4, 3 (Easy) -> 5
    final int sm2Quality = quality == 0
        ? 0
        : (quality == 1 ? 2 : (quality == 2 ? 4 : 5));

    final newEF =
        currentEF + (0.1 - (5 - sm2Quality) * (0.08 + (5 - sm2Quality) * 0.02));
    return newEF;
  }

  // Get cards that are due for review
  static List<VocabularyCard> getDueCards(List<VocabularyCard> allCards) {
    return allCards.where((card) => card.isDue).toList();
  }

  // Get new cards (never reviewed, interval = 0)
  static List<VocabularyCard> getNewCards(List<VocabularyCard> allCards) {
    return allCards.where((card) => card.intervalDays == 0).toList();
  }

  // Get learning cards (currently in learning, 0 < interval < 21 days)
  static List<VocabularyCard> getLearningCards(List<VocabularyCard> allCards) {
    return allCards
        .where(
          (card) =>
              card.intervalDays > 0 &&
              card.intervalDays < AppConstants.learningThresholdDays,
        )
        .toList();
  }

  // Get reviewed cards (interval >= 21 days - "graduated")
  static List<VocabularyCard> getReviewedCards(List<VocabularyCard> allCards) {
    return allCards
        .where(
          (card) => card.intervalDays >= AppConstants.masteredThresholdDays,
        )
        .toList();
  }

  // Get cards by category (POS)
  // Supports: 'all', 'noun', 'verb', 'adj', 'adv', 'phrasal_verb', 'conjunction'
  static List<VocabularyCard> getCardsByCategory(
    List<VocabularyCard> allCards,
    String category,
  ) {
    if (category.toLowerCase() == 'all' ||
        category.toLowerCase() == 'tümü' ||
        category.isEmpty) {
      return allCards;
    }
    return allCards
        .where((card) => card.pos.toLowerCase() == category.toLowerCase())
        .toList();
  }
}
