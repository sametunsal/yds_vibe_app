import 'package:flutter/material.dart';
import '../models/card.dart' as model;
import '../services/srs_service.dart';
import '../data/card_loader.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  // All cards from mock data
  List<model.VocabularyCard> _allCards = [];
  // Cards due for review (current session)
  List<model.VocabularyCard> _reviewQueue = [];
  // Current card being shown
  model.VocabularyCard? _currentCard;
  // Is meaning revealed?
  bool _isRevealed = false;
  // Review-only mode (no new cards)
  bool _reviewOnlyMode = false;
  // New cards shown today
  int _newCardsToday = 0;
  // Max new cards per day
  static const int maxNewCardsPerDay = 15;
  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
    });

    _allCards = await CardLoader.loadCards();
    _buildReviewQueue();
    _loadNextCard();

    setState(() {
      _isLoading = false;
    });
  }

  void _buildReviewQueue() {
    final dueCards = SRSService.getDueCards(_allCards);
    final newCards = SRSService.getNewCards(_allCards);

    if (_reviewOnlyMode) {
      // Only due cards (review mode)
      _reviewQueue = dueCards;
    } else {
      // Mix of due cards + new cards (up to max)
      final availableNewCards = newCards.take(maxNewCardsPerDay - _newCardsToday).toList();
      _reviewQueue = [...dueCards, ...availableNewCards];
    }
  }

  void _loadNextCard() {
    if (_reviewQueue.isEmpty) {
      setState(() {
        _currentCard = null;
        _isRevealed = false;
      });
      return;
    }

    setState(() {
      _currentCard = _reviewQueue.first;
      _isRevealed = false;
    });
  }

  void _revealMeaning() {
    setState(() {
      _isRevealed = true;
    });
  }

  void _submitRating(model.Rating rating) {
    if (_currentCard == null) return;

    // Process the rating and update card
    final updatedCard = SRSService.processReview(_currentCard!, rating);

    // Update the card in the all cards list
    final index = _allCards.indexWhere((c) => c.id == _currentCard!.id);
    if (index != -1) {
      _allCards[index] = updatedCard;
    }

    // Track new cards
    if (_currentCard!.intervalDays == 0 && rating != model.Rating.again) {
      _newCardsToday++;
    }

    // Remove current card from queue
    _reviewQueue.removeAt(0);

    // Load next card
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
        title: const Text('Review'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text('Review-only'),
                Switch(
                  value: _reviewOnlyMode,
                  onChanged: _toggleReviewOnlyMode,
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildBody(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildBody() {
    if (_currentCard == null) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Remaining: ${_reviewQueue.length}'),
              Text('New today: $_newCardsToday/$maxNewCardsPerDay'),
            ],
          ),
          const SizedBox(height: 20),

          // Card type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _currentCard!.pos.toUpperCase(),
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Card content
          Expanded(
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lemma (word/phrase)
                    Text(
                      _currentCard!.lemma,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Meaning (hidden until revealed)
                    if (_isRevealed) ...[
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        _currentCard!.meaningTr,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.deepPurple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      if (_currentCard!.synonyms.isNotEmpty) ...[
                        Text(
                          'Synonyms: ${_currentCard!.synonyms.join(", ")}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                      ],
                      Text(
                        _currentCard!.example.text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_currentCard!.example.translation != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _currentCard!.example.translation!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text(
                        'SRS: EF=${_currentCard!.easeFactor.toStringAsFixed(2)}, Interval=${_currentCard!.intervalDays}d',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],

                    // Show button
                    if (!_isRevealed) ...[
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _revealMeaning,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Show',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Rating buttons (only show when revealed)
          if (_isRevealed) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _submitRating(model.Rating.again),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Again', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _submitRating(model.Rating.struggled),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Struggled', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _submitRating(model.Rating.good),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.lightGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Good', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _submitRating(model.Rating.easy),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Easy', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasCards = _allCards.isNotEmpty;
    final newCardsCount = SRSService.getNewCards(_allCards).length;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          const Text(
            'All done!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_reviewOnlyMode && newCardsCount > 0)
            Text(
              '$newCardsCount new cards available (review-only mode)',
              style: const TextStyle(color: Colors.grey),
            )
          else if (!hasCards)
            const Text(
              'No cards available',
              style: TextStyle(color: Colors.grey),
            )
          else
            const Text(
              'No cards due for review',
              style: TextStyle(color: Colors.grey),
            ),
          const SizedBox(height: 24),
          if (_reviewOnlyMode && newCardsCount > 0)
            ElevatedButton(
              onPressed: () => _toggleReviewOnlyMode(false),
              child: const Text('Disable Review-only Mode'),
            )
          else
            ElevatedButton(
              onPressed: _loadCards,
              child: const Text('Refresh'),
            ),
        ],
      ),
    );
  }
}
