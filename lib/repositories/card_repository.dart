import '../core/result.dart';
import '../data/card_loader.dart';
import '../models/card.dart';
import '../services/srs_service.dart';

abstract class CardRepository {
  Future<Result<List<VocabularyCard>>> getAllCards();
  Future<Result<List<VocabularyCard>>> getCardsByCategory(String category);
  Future<Result<void>> saveCards(List<VocabularyCard> cards);
}

class CardRepositoryImpl implements CardRepository {
  @override
  Future<Result<List<VocabularyCard>>> getAllCards() async {
    try {
      final cards = await CardLoader.loadCards();
      return Success(cards);
    } catch (e) {
      return Failure('Kartlar yüklenemedi: $e');
    }
  }

  @override
  Future<Result<List<VocabularyCard>>> getCardsByCategory(
    String category,
  ) async {
    try {
      final allCards = await CardLoader.loadCards();
      final filtered = SRSService.getCardsByCategory(allCards, category);
      return Success(filtered);
    } catch (e) {
      return Failure('Kategori kartları yüklenemedi: $e');
    }
  }

  @override
  Future<Result<void>> saveCards(List<VocabularyCard> cards) async {
    try {
      await CardLoader.saveCards(cards);
      return const Success(null);
    } catch (e) {
      return Failure('Kartlar kaydedilemedi: $e');
    }
  }
}
