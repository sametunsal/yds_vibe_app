import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_constants.dart';
import '../core/responsive.dart';
import '../core/result.dart';
import '../models/card.dart' as model;
import '../repositories/card_repository.dart';
import '../services/srs_service.dart';
import '../services/tts_service.dart';
import '../widgets/review/review_card_front.dart';
import '../widgets/review/review_card_back.dart';
import '../widgets/review/rating_buttons.dart';
import '../widgets/review/review_stats_bar.dart';
import '../widgets/review/empty_review_state.dart';

class ReviewScreen extends StatefulWidget {
  final String category;
  final String title;

  const ReviewScreen({
    super.key,
    this.category = '',
    this.title = 'Kelime Çalışması',
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with SingleTickerProviderStateMixin {
  final CardRepository _repository = CardRepositoryImpl();
  List<model.VocabularyCard> _allCards = [];
  List<model.VocabularyCard> _reviewQueue = [];
  model.VocabularyCard? _currentCard;
  bool _isFlipped = false;
  bool _reviewOnlyMode = false;
  int _newCardsToday = 0;
  static const int maxNewCardsPerDay = AppConstants.maxNewCardsPerDay;
  bool _isLoading = true;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late ConfettiController _confettiController;
  Key _cardKey = UniqueKey();
  final TtsService _ttsService = TtsService();

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeOutBack),
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _loadCards();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _confettiController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    final result = await _repository.getAllCards();

    switch (result) {
      case Success(value: final cards):
        var loadedCards = cards;
        if (widget.category.isNotEmpty) {
          loadedCards = SRSService.getCardsByCategory(
            loadedCards,
            widget.category,
          );
        }
        _allCards = loadedCards;
        _buildReviewQueue();
        _loadNextCard();
      case Failure():
        _allCards = [];
    }
    setState(() => _isLoading = false);
  }

  void _buildReviewQueue() {
    final dueCards = SRSService.getDueCards(_allCards);
    final newCards = SRSService.getNewCards(_allCards);

    if (_reviewOnlyMode) {
      _reviewQueue = dueCards;
    } else {
      final availableNewCards = newCards
          .take(maxNewCardsPerDay - _newCardsToday)
          .toList();
      _reviewQueue = [...dueCards, ...availableNewCards];
    }
  }

  void _loadNextCard() {
    _flipController.reset();
    if (_reviewQueue.isEmpty) {
      setState(() {
        _currentCard = null;
        _isFlipped = false;
      });
      return;
    }
    setState(() {
      _currentCard = _reviewQueue.first;
      _isFlipped = false;
      _cardKey = UniqueKey();
      _ttsService.speak(_currentCard!.lemma);
    });
  }

  void _flipCard() {
    if (_isFlipped) return;
    HapticFeedback.mediumImpact();
    _flipController.forward();
    setState(() => _isFlipped = true);
    if (_currentCard != null) {
      _ttsService.speak(_currentCard!.example.text);
    }
  }

  Future<void> _submitRating(model.Rating rating) async {
    if (_currentCard == null) return;

    if (rating == model.Rating.easy) {
      HapticFeedback.heavyImpact();
      _confettiController.play();
    } else if (rating == model.Rating.good) {
      HapticFeedback.lightImpact();
    }

    final updatedCard = await SRSService.processReview(_currentCard!, rating);
    final index = _allCards.indexWhere((c) => c.id == _currentCard!.id);
    if (index != -1) {
      _allCards[index] = updatedCard;
    }

    await _repository.saveCards(_allCards);

    if (_currentCard!.intervalDays == 0 && rating != model.Rating.again) {
      _newCardsToday++;
    }
    _reviewQueue.removeAt(0);
    _loadNextCard();
  }

  void _toggleReviewOnlyMode(bool value) {
    setState(() {
      _reviewOnlyMode = value;
      _buildReviewQueue();
      _loadNextCard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Text(
                  'Sadece Tekrar',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(width: 4),
                Switch(
                  value: _reviewOnlyMode,
                  onChanged: _toggleReviewOnlyMode,
                  activeColor: Colors.white,
                  activeTrackColor: Colors.deepPurple.shade200,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.2,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.amber,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_currentCard == null) {
      return EmptyReviewState(
        allCards: _allCards,
        reviewOnlyMode: _reviewOnlyMode,
        onToggleReviewMode: () => _toggleReviewOnlyMode(false),
        onRefresh: _loadCards,
      );
    }

    return SafeArea(
      child: ResponsiveCenter(
        maxWidth: 500,
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReviewStatsBar(
              remainingCount: _reviewQueue.length,
              newCardsToday: _newCardsToday,
              maxNewCardsPerDay: maxNewCardsPerDay,
            ),
            const SizedBox(height: 12),

            // POS badge
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _currentCard!.pos.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1),
            const SizedBox(height: 16),

            // Flip Card
            Expanded(
              child:
                  GestureDetector(
                        onTap: _flipCard,
                        child: AnimatedBuilder(
                          animation: _flipAnimation,
                          builder: (context, child) {
                            final angle = _flipAnimation.value * pi;
                            final isFront = angle < pi / 2;

                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.0015)
                                ..rotateY(angle),
                              child: isFront
                                  ? ReviewCardFront(
                                      card: _currentCard!,
                                      ttsService: _ttsService,
                                    )
                                  : Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..rotateY(pi),
                                      child: ReviewCardBack(
                                        card: _currentCard!,
                                        ttsService: _ttsService,
                                      ),
                                    ),
                            );
                          },
                        ),
                      )
                      .animate(key: _cardKey)
                      .fadeIn(duration: 400.ms)
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        curve: Curves.easeOutBack,
                      ),
            ),

            const SizedBox(height: 16),

            if (_isFlipped)
              RatingButtons(
                onRating: _submitRating,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2)
            else
              _buildTapHint().animate().fadeIn().shimmer(
                delay: 1000.ms,
                duration: 1500.ms,
                color: Colors.deepPurple.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTapHint() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.swipe, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Text(
            'Cevabı görmek için karta dokun',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
