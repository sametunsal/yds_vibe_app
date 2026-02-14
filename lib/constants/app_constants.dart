class AppConstants {
  AppConstants._();

  // SRS thresholds
  static const int learningThresholdDays = 21;
  static const int masteredThresholdDays = 21;

  // SRS algorithm
  static const double defaultEaseFactor = 2.5;
  static const double minEaseFactor = 1.3;
  static const double easyMultiplier = 1.3;

  // Review
  static const int maxNewCardsPerDay = 15;

  // Quiz
  static const int maxQuizQuestions = 10;

  // Quiz fallback options
  static const List<String> genericSynonymFallbacks = [
    'select',
    'choose',
    'pick',
    'decide',
  ];
  static const List<String> genericClozeFallbacks = [
    'put',
    'get',
    'make',
    'take',
  ];
}
