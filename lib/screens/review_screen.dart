import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/card.dart' as model;
import '../services/srs_service.dart';
import '../data/card_loader.dart';

class ReviewScreen extends StatefulWidget {
  final String category; // '' means 'all'
  final String title;    // Display title for the category

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
  List<model.VocabularyCard> _allCards = [];
  List<model.VocabularyCard> _reviewQueue = [];
  model.VocabularyCard? _currentCard;
  bool _isFlipped = false;
  bool _reviewOnlyMode = false;
  int _newCardsToday = 0;
  static const int maxNewCardsPerDay = 15;
  bool _isLoading = true;

  // Animation controllers
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late ConfettiController _confettiController;

  // Card key for animations
  Key _cardKey = UniqueKey();

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
    super.dispose();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    var loadedCards = await CardLoader.loadCards();

    // Filter by category if specified
    if (widget.category.isNotEmpty) {
      loadedCards = SRSService.getCardsByCategory(
        loadedCards,
        widget.category,
      );
    }

    _allCards = loadedCards;
    _buildReviewQueue();
    _loadNextCard();
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
      _cardKey = UniqueKey(); // Fresh key for entrance animation
    });
  }

  void _flipCard() {
    if (_isFlipped) return;
    HapticFeedback.mediumImpact();
    _flipController.forward();
    setState(() => _isFlipped = true);
  }

  Future<void> _submitRating(model.Rating rating) async {
    if (_currentCard == null) return;

    // Trigger confetti on Easy!
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

    // Save progress due to rating change
    CardLoader.saveCards(_allCards);

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
          _isLoading ? _buildLoadingState() : _buildBody(),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // downward
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

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildBody() {
    if (_currentCard == null) return _buildEmptyState();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stats row with animation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatChip(
                  icon: Icons.layers,
                  label: 'Kalan: ${_reviewQueue.length}',
                ),
                _buildStatChip(
                  icon: Icons.star_outline,
                  label: 'Yeni: $_newCardsToday/$maxNewCardsPerDay',
                ),
              ],
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

            // Flip Card with entrance animation
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
                                ..setEntry(3, 2, 0.0015) // Enhanced perspective
                                ..rotateY(angle),
                              child: isFront
                                  ? _buildFrontCard()
                                  : Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..rotateY(pi),
                                      child: _buildBackCard(),
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

            // Rating buttons with stagger animation
            if (_isFlipped)
              _buildRatingButtons()
                  .animate()
                  .fadeIn(delay: 100.ms)
                  .slideY(begin: 0.2)
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

  Widget _buildStatChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildFrontCard() {
    return Card(
      elevation: 12,
      shadowColor: Colors.deepPurple.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.deepPurple.shade50],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentCard!.lemma,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.touch_app,
                size: 28,
                color: Colors.deepPurple[300],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Çevirmek için dokun',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    return Card(
      elevation: 12,
      shadowColor: Colors.deepPurple.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lemma (smaller on back)
              Text(
                _currentCard!.lemma,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                width: 60,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Meaning with emphasis
              Text(
                _currentCard!.meaningTr,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Synonyms
              if (_currentCard!.synonyms.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _currentCard!.synonyms
                      .map(
                        (s) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.deepPurple[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Example sentence
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      _currentCard!.example.text,
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_currentCard!.example.translation != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _currentCard!.example.translation!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
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

  Widget _buildRatingButtons() {
    return Column(
      children: [
        // Again - full width
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => _submitRating(model.Rating.again),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: Colors.red.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 20),
                SizedBox(width: 8),
                Text(
                  'Tekrar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Struggled, Good, Easy - row
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _submitRating(model.Rating.struggled),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFB8C00),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.orange.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Zor',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _submitRating(model.Rating.good),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7CB342),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.lightGreen.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'İyi',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _submitRating(model.Rating.easy),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047),
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shadowColor: Colors.green.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Kolay',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text('🎉', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final hasCards = _allCards.isNotEmpty;
    final newCardsCount = SRSService.getNewCards(_allCards).length;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.celebration,
                  size: 72,
                  color: Colors.green.shade400,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 800.ms,
              ),
          const SizedBox(height: 28),
          const Text(
            'Bugünlük bitti! 🎉',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ).animate().fadeIn().slideY(begin: 0.3),
          const SizedBox(height: 12),
          if (_reviewOnlyMode && newCardsCount > 0)
            Text(
              '$newCardsCount yeni kart mevcut',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ).animate().fadeIn(delay: 200.ms)
          else if (!hasCards)
            Text(
              'Henüz kart yok',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ).animate().fadeIn(delay: 200.ms)
          else
            Text(
              'Harika iş çıkardın!',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 36),
          if (_reviewOnlyMode && newCardsCount > 0)
            ElevatedButton.icon(
              onPressed: () => _toggleReviewOnlyMode(false),
              icon: const Icon(Icons.add),
              label: const Text('Yeni kartlara geç'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).scale()
          else
            ElevatedButton.icon(
              onPressed: _loadCards,
              icon: const Icon(Icons.refresh),
              label: const Text('Yenile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).scale(),
        ],
      ),
    );
  }
}
