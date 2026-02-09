import 'package:flutter/material.dart';
import '../models/card.dart' as model;
import '../data/card_loader.dart';
import '../services/streak_service.dart';

enum QuizType { synonym, cloze }

class QuizQuestion {
  final model.VocabularyCard card;
  final QuizType type;
  final String question;
  final String correctAnswer;
  final List<String> options;

  QuizQuestion({
    required this.card,
    required this.type,
    required this.question,
    required this.correctAnswer,
    required this.options,
  });

  bool isCorrect(String selected) => selected == correctAnswer;
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<model.VocabularyCard> _allCards = [];
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _showResult = false;
  bool _isFinished = false;
  bool _isLoading = true;

  // Max 10 questions per quiz
  static const int maxQuestions = 10;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    setState(() {
      _isLoading = true;
    });

    _allCards = await CardLoader.loadCards();
    _generateQuestions();

    setState(() {
      _isLoading = false;
    });
  }

  void _generateQuestions() {
    if (_allCards.isEmpty) {
      _questions = [];
      return;
    }

    // Shuffle cards and take up to maxQuestions
    final shuffled = List<model.VocabularyCard>.from(_allCards)..shuffle();
    final selectedCards = shuffled.take(maxQuestions).toList();

    _questions = [];

    for (final card in selectedCards) {
      // Generate either synonym or cloze question
      // Use synonym if available, otherwise use cloze
      if (card.synonyms.isNotEmpty && _canGenerateSynonymQuestion(card)) {
        _questions.add(_generateSynonymQuestion(card, selectedCards));
      } else {
        _questions.add(_generateClozeQuestion(card));
      }
    }

    _currentQuestionIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _showResult = false;
    _isFinished = false;
  }

  bool _canGenerateSynonymQuestion(model.VocabularyCard card) {
    return card.synonyms.isNotEmpty;
  }

  QuizQuestion _generateSynonymQuestion(
    model.VocabularyCard card,
    List<model.VocabularyCard> allCards,
  ) {
    final correct = card.synonyms.first;
    final correctLower = correct.toLowerCase();

    // Get wrong options from other cards' synonyms
    final wrongOptions = <String>[];
    final otherCards = allCards.where((c) => c.id != card.id).toList();
    otherCards.shuffle();

    for (final other in otherCards) {
      if (other.synonyms.isNotEmpty) {
        final synonym = other.synonyms.first;
        // Ensure distractor doesn't equal correct answer (case-insensitive)
        if (synonym.toLowerCase() != correctLower) {
          wrongOptions.add(synonym);
        }
      }
      if (wrongOptions.length >= 3) break;
    }

    // If not enough wrong options, add some generic ones
    final generics = ['select', 'choose', 'pick', 'decide'];
    for (final g in generics) {
      if (wrongOptions.length < 3 &&
          !wrongOptions.contains(g) &&
          g.toLowerCase() != correctLower) {
        wrongOptions.add(g);
      }
    }

    // Combine and shuffle
    final allOptions = [correct, ...wrongOptions.take(3)]..shuffle();

    return QuizQuestion(
      card: card,
      type: QuizType.synonym,
      question: 'What is a synonym of "${card.lemma}"?',
      correctAnswer: correct,
      options: allOptions,
    );
  }

  QuizQuestion _generateClozeQuestion(model.VocabularyCard card) {
    final template = card.cloze.template;
    final correct = card.cloze.answer;
    final correctLower = correct.toLowerCase();

    // Get wrong options from other cards' cloze answers
    final wrongOptions = <String>[];
    final otherCards = _allCards.where((c) => c.id != card.id).toList();
    otherCards.shuffle();

    for (final other in otherCards) {
      final answer = other.cloze.answer;
      // Ensure distractor doesn't equal correct answer (case-insensitive)
      if (answer.toLowerCase() != correctLower) {
        wrongOptions.add(answer);
      }
      if (wrongOptions.length >= 3) break;
    }

    // If not enough wrong options, add some generic ones
    final generics = ['put', 'get', 'make', 'take'];
    for (final g in generics) {
      if (wrongOptions.length < 3 &&
          !wrongOptions.contains(g) &&
          g.toLowerCase() != correctLower) {
        wrongOptions.add(g);
      }
    }

    // Combine and shuffle
    final allOptions = [correct, ...wrongOptions.take(3)]..shuffle();

    return QuizQuestion(
      card: card,
      type: QuizType.cloze,
      question: template.replaceAll('{{cloze}}', '_____'),
      correctAnswer: correct,
      options: allOptions,
    );
  }

  void _selectAnswer(String answer) {
    if (_showResult) return;

    setState(() {
      _selectedAnswer = answer;
      _showResult = true;
      if (answer == _questions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showResult = false;
      });
    } else {
      // Quiz completed - save activity for streak
      StreakService.saveStudyActivity();
      setState(() {
        _isFinished = true;
      });
    }
  }

  void _restartQuiz() {
    _generateQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: _isLoading ? _buildLoadingState() : _buildBody(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildBody() {
    if (_allCards.isEmpty) {
      return _buildEmptyState();
    }

    if (_isFinished) {
      return _buildResultScreen();
    }

    if (_questions.isEmpty) {
      return _buildEmptyState();
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              ),
              Text('Score: $_score'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
          ),
          const SizedBox(height: 20),

          // Question type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: currentQuestion.type == QuizType.synonym
                  ? Colors.blue.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              currentQuestion.type == QuizType.synonym ? 'SYNONYM' : 'CLOZE',
              style: TextStyle(
                color: currentQuestion.type == QuizType.synonym
                    ? Colors.blue
                    : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Question
          Expanded(
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentQuestion.question,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Options
          const SizedBox(height: 16),
          ...currentQuestion.options.map((option) {
            final isSelected = _selectedAnswer == option;
            final isCorrect = option == currentQuestion.correctAnswer;
            final showCorrect = _showResult && isCorrect;
            final showWrong = _showResult && isSelected && !isCorrect;

            Color bgColor = Colors.white;
            if (showCorrect) {
              bgColor = Colors.green.withValues(alpha: 0.3);
            } else if (showWrong) {
              bgColor = Colors.red.withValues(alpha: 0.3);
            } else if (isSelected) {
              bgColor = Colors.deepPurple.withValues(alpha: 0.1);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                onPressed: _showResult ? null : () => _selectAnswer(option),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: bgColor,
                  foregroundColor: Colors.black,
                  elevation: isSelected ? 4 : 1,
                ),
                child: Text(option, style: const TextStyle(fontSize: 16)),
              ),
            );
          }),

          // Next button
          if (_showResult) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: Text(
                _currentQuestionIndex < _questions.length - 1
                    ? 'Next Question'
                    : 'See Results',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = (_score / _questions.length * 100).round();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            percentage >= 70 ? Icons.emoji_events : Icons.check_circle,
            size: 80,
            color: percentage >= 70 ? Colors.amber : Colors.green,
          ),
          const SizedBox(height: 16),
          const Text(
            'Quiz Complete!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'You scored $_score out of ${_questions.length}',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: percentage >= 70 ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _restartQuiz,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No cards available',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Add vocabulary cards to take quizzes',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
