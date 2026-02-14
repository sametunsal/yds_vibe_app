import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/responsive.dart';
import '../models/card.dart' as model;
import '../repositories/card_repository.dart';
import '../services/study_controller.dart';
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
  late final StudyController _controller;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late ConfettiController _confettiController;
  Key _cardKey = UniqueKey();
  final TtsService _ttsService = TtsService();

  @override
  void initState() {
    super.initState();
    _controller = StudyController(
      repository: CardRepositoryImpl(),
      category: widget.category,
    );
    _controller.addListener(_onControllerChanged);

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

    _controller.loadCards();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _flipController.dispose();
    _confettiController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  void _flipCard() {
    if (_controller.isFlipped) return;
    HapticFeedback.mediumImpact();
    _flipController.forward();
    _controller.flipCard();
    if (_controller.currentCard != null) {
      _ttsService.speak(_controller.currentCard!.example.text);
    }
  }

  Future<void> _submitRating(model.Rating rating) async {
    if (rating == model.Rating.easy) {
      HapticFeedback.heavyImpact();
      _confettiController.play();
    } else if (rating == model.Rating.good) {
      HapticFeedback.lightImpact();
    }

    await _controller.submitRating(rating);
    _flipController.reset();
    _cardKey = UniqueKey();

    if (_controller.currentCard != null) {
      _ttsService.speak(_controller.currentCard!.lemma);
    }
  }

  void _toggleReviewMode(bool value) {
    _flipController.reset();
    _cardKey = UniqueKey();
    _controller.toggleReviewOnlyMode(value);
    if (_controller.currentCard != null) {
      _ttsService.speak(_controller.currentCard!.lemma);
    }
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
                const Text(
                  'Sadece Tekrar',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(width: 4),
                Switch(
                  value: _controller.reviewOnlyMode,
                  onChanged: _toggleReviewMode,
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
          _controller.isLoading
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
    if (_controller.currentCard == null) {
      return EmptyReviewState(
        allCards: _controller.allCards,
        reviewOnlyMode: _controller.reviewOnlyMode,
        onToggleReviewMode: () => _toggleReviewMode(false),
        onRefresh: _controller.loadCards,
      );
    }

    final card = _controller.currentCard!;

    return SafeArea(
      child: ResponsiveCenter(
        maxWidth: 500,
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReviewStatsBar(
              remainingCount: _controller.remainingCount,
              newCardsToday: _controller.newCardsToday,
              maxNewCardsPerDay: _controller.maxNewCardsPerDay,
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
                  card.pos.toUpperCase(),
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
                                      card: card,
                                      ttsService: _ttsService,
                                    )
                                  : Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..rotateY(pi),
                                      child: ReviewCardBack(
                                        card: card,
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

            if (_controller.isFlipped)
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
