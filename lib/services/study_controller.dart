import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../core/result.dart';
import '../models/card.dart' as model;
import '../repositories/card_repository.dart';
import '../services/srs_service.dart';

/// Pure business logic for study sessions.
/// ReviewScreen delegates all state management here.
class StudyController extends ChangeNotifier {
  final CardRepository _repository;
  final String category;

  List<model.VocabularyCard> _allCards = [];
  List<model.VocabularyCard> _reviewQueue = [];
  model.VocabularyCard? _currentCard;
  bool _isFlipped = false;
  bool _reviewOnlyMode = false;
  int _newCardsToday = 0;
  bool _isLoading = true;

  StudyController({required CardRepository repository, this.category = ''})
    : _repository = repository;

  // --- Getters ---
  List<model.VocabularyCard> get allCards => _allCards;
  List<model.VocabularyCard> get reviewQueue => _reviewQueue;
  model.VocabularyCard? get currentCard => _currentCard;
  bool get isFlipped => _isFlipped;
  bool get reviewOnlyMode => _reviewOnlyMode;
  int get newCardsToday => _newCardsToday;
  bool get isLoading => _isLoading;
  int get remainingCount => _reviewQueue.length;
  int get maxNewCardsPerDay => AppConstants.maxNewCardsPerDay;

  // --- Actions ---

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getAllCards();
    switch (result) {
      case Success(value: final cards):
        if (category.isNotEmpty) {
          _allCards = SRSService.getCardsByCategory(cards, category);
        } else {
          _allCards = cards;
        }
        _buildReviewQueue();
        _loadNextCard();
      case Failure():
        _allCards = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void _buildReviewQueue() {
    final dueCards = SRSService.getDueCards(_allCards);
    final newCards = SRSService.getNewCards(_allCards);

    if (_reviewOnlyMode) {
      _reviewQueue = dueCards;
    } else {
      final available = newCards
          .take(AppConstants.maxNewCardsPerDay - _newCardsToday)
          .toList();
      _reviewQueue = [...dueCards, ...available];
    }
  }

  void _loadNextCard() {
    if (_reviewQueue.isEmpty) {
      _currentCard = null;
      _isFlipped = false;
      notifyListeners();
      return;
    }
    _currentCard = _reviewQueue.first;
    _isFlipped = false;
    notifyListeners();
  }

  void flipCard() {
    if (_isFlipped) return;
    _isFlipped = true;
    notifyListeners();
  }

  /// Returns the rating for haptic/animation decisions.
  Future<model.Rating> submitRating(model.Rating rating) async {
    if (_currentCard == null) return rating;

    final updatedCard = await SRSService.processReview(_currentCard!, rating);

    final index = _allCards.indexWhere((c) => c.id == _currentCard!.id);
    if (index != -1) {
      _allCards[index] = updatedCard;
    }

    await _repository.saveCardProgress(updatedCard);

    if (_currentCard!.intervalDays == 0 && rating != model.Rating.again) {
      _newCardsToday++;
    }

    _reviewQueue.removeAt(0);
    _loadNextCard();
    return rating;
  }

  void toggleReviewOnlyMode(bool value) {
    _reviewOnlyMode = value;
    _buildReviewQueue();
    _loadNextCard();
  }
}
