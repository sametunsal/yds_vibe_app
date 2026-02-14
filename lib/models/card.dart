import '../constants/app_constants.dart';

enum CardType { word, phrase }

enum Rating {
  again, // 0 - Forgot completely
  struggled, // 1 - Barely remembered
  good, // 2 - Remembered correctly
  easy, // 3 - Knew it instantly
}

class Example {
  final String text;
  final String? translation;

  Example({required this.text, this.translation});

  Example copyWith({String? text, String? translation}) {
    return Example(
      text: text ?? this.text,
      translation: translation ?? this.translation,
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, if (translation != null) 'translation': translation};
  }

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      text: json['text'] as String,
      translation: json['translation'] as String?,
    );
  }
}

class Cloze {
  final String template;
  final String answer;

  Cloze({required this.template, required this.answer});

  Cloze copyWith({String? template, String? answer}) {
    return Cloze(
      template: template ?? this.template,
      answer: answer ?? this.answer,
    );
  }

  Map<String, dynamic> toJson() {
    return {'template': template, 'answer': answer};
  }

  factory Cloze.fromJson(Map<String, dynamic> json) {
    return Cloze(
      template: json['template'] as String,
      answer: json['answer'] as String,
    );
  }

  String getFilledTemplate() {
    return template.replaceAll('{{cloze}}', answer);
  }
}

class VocabularyCard {
  final String id;
  final String lemma; // word/phrase itself
  final String pos; // part of speech
  final bool multiWord; // is this a multi-word expression
  final List<String> meanings; // meanings (always length 1 for MVP)
  final List<String> synonyms; // synonyms (1-3 items)
  final Example example;
  final Cloze cloze;
  final double easeFactor;
  final int intervalDays;
  final DateTime dueDate;
  final int repetitions;
  final DateTime? lastReviewed;

  VocabularyCard({
    required this.id,
    required this.lemma,
    required this.pos,
    required this.multiWord,
    required this.meanings,
    required this.synonyms,
    required this.example,
    required this.cloze,
    this.easeFactor = AppConstants.defaultEaseFactor,
    this.intervalDays = 0,
    DateTime? dueDate,
    this.repetitions = 0,
    this.lastReviewed,
  }) : dueDate = dueDate ?? _today();

  String get meaningTr => meanings.isNotEmpty ? meanings.first : '';

  String get primarySynonym => synonyms.isNotEmpty ? synonyms.first : '';

  bool get isPhrase => multiWord;

  VocabularyCard copyWith({
    String? id,
    String? lemma,
    String? pos,
    bool? multiWord,
    List<String>? meanings,
    List<String>? synonyms,
    Example? example,
    Cloze? cloze,
    double? easeFactor,
    int? intervalDays,
    DateTime? dueDate,
    int? repetitions,
    DateTime? lastReviewed,
  }) {
    return VocabularyCard(
      id: id ?? this.id,
      lemma: lemma ?? this.lemma,
      pos: pos ?? this.pos,
      multiWord: multiWord ?? this.multiWord,
      meanings: meanings ?? this.meanings,
      synonyms: synonyms ?? this.synonyms,
      example: example ?? this.example,
      cloze: cloze ?? this.cloze,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      dueDate: dueDate ?? this.dueDate,
      repetitions: repetitions ?? this.repetitions,
      lastReviewed: lastReviewed ?? this.lastReviewed,
    );
  }

  /// Day-boundary comparison: card is due if today >= dueDate (date only).
  bool get isDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return !today.isBefore(due);
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lemma': lemma,
      'pos': pos,
      'multiWord': multiWord,
      'meanings': meanings,
      'synonyms': synonyms,
      'example': example.toJson(),
      'cloze': cloze.toJson(),
      'easeFactor': easeFactor,
      'intervalDays': intervalDays,
      'dueDate': dueDate.toIso8601String(),
      'repetitions': repetitions,
      'lastReviewed': lastReviewed?.toIso8601String(),
    };
  }

  factory VocabularyCard.fromJson(Map<String, dynamic> json) {
    return VocabularyCard(
      id: json['id'] as String,
      lemma: json['lemma'] as String,
      pos: json['pos'] as String? ?? 'word',
      multiWord: json['multiWord'] as bool? ?? false,
      meanings: (json['meanings'] as List<dynamic>).cast<String>(),
      synonyms: (json['synonyms'] as List<dynamic>).cast<String>(),
      example: json['example'] is String
          ? Example(text: json['example'] as String)
          : Example.fromJson(json['example'] as Map<String, dynamic>),
      cloze: Cloze.fromJson(json['cloze'] as Map<String, dynamic>),
      easeFactor:
          (json['easeFactor'] as num?)?.toDouble() ??
          AppConstants.defaultEaseFactor,
      intervalDays: json['intervalDays'] as int? ?? 0,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String).toLocal()
          : _today(),
      repetitions: json['repetitions'] as int? ?? 0,
      lastReviewed: json['lastReviewed'] != null
          ? DateTime.parse(json['lastReviewed'] as String).toLocal()
          : null,
    );
  }
}
