import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../models/card.dart';

class CardLoader {
  static const String cardsPath = 'assets/cards.json';
  static const String mvlPath = 'assets/mvl/';
  static const String localFileName = 'cards.json';

  // File to POS mapping
  static const Map<String, String> _filePosMapping = {
    'verbs.json': 'verb',
    'adjs.json': 'adj',
    'advs.json': 'adv',
    'adjectives.json': 'adj',
    'adverbs.json': 'adv',
    'phrasal_verbs.json': 'phrasal_verb',
    'conjunctions.json': 'conjunction',
    'cards.json': 'noun',
  };

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$localFileName');
  }

  static Future<List<VocabularyCard>> loadCards() async {
    try {
      final file = await _localFile;

      if (await file.exists()) {
        // Load from local file
        print('[CardLoader] Loading cards from local storage: ${file.path}');
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        final cards = _parseJsonList(jsonList, 'local');
        print('[CardLoader] Loaded ${cards.length} cards from local storage');
        return cards;
      } else {
        // First run: Load from all assets
        print('[CardLoader] Local file not found. Loading from assets.');
        final cards = await _loadFromAssets();
        if (cards.isNotEmpty) {
          await saveCards(cards);
        }
        return cards;
      }
    } catch (e) {
      print('[CardLoader] Error loading cards: $e');
      // Fallback to assets if local load fails
      try {
        print('[CardLoader] Attempting fallback to assets...');
        return await _loadFromAssets();
      } catch (e2) {
        print(
          '[CardLoader] Critical error loading cards (fallback failed): $e2',
        );
        return [];
      }
    }
  }

  static Future<List<VocabularyCard>> _loadFromAssets() async {
    final allCards = <VocabularyCard>[];
    final seenIds = <String>{};

    // List of all JSON files to load
    final filesToLoad = [
      'cards.json',
      'mvl/verbs.json',
      'mvl/adjs.json',
      'mvl/advs.json',
      'mvl/phrasal_verbs.json',
      'mvl/conjunctions.json',
      'mvl/adjectives.json',
      'mvl/adverbs.json',
    ];

    for (final filePath in filesToLoad) {
      try {
        print('[CardLoader] Loading from assets/$filePath...');
        final jsonString = await rootBundle.loadString('assets/$filePath');
        final List<dynamic> jsonList = json.decode(jsonString);

        // Get POS from filename
        final fileName = filePath.split('/').last;
        final pos = _filePosMapping[fileName] ?? _extractPosFromFileName(fileName);

        final cards = _parseJsonList(jsonList, fileName, pos: pos);

        // Check for duplicate IDs and filter
        for (final card in cards) {
          if (seenIds.contains(card.id)) {
            print('[CardLoader] WARNING: Duplicate ID ${card.id} in $filePath, skipping');
          } else {
            seenIds.add(card.id);
            allCards.add(card);
          }
        }

        print('[CardLoader] Loaded ${cards.length} cards from $filePath (pos: $pos)');
      } catch (e) {
        print('[CardLoader] Error loading $filePath: $e');
        // Continue with other files
      }
    }

    print('[CardLoader] Total loaded: ${allCards.length} cards');
    _checkSynonymCollisions(allCards);
    return allCards;
  }

  // Extract POS from filename (e.g., 'verbs.json' -> 'verb')
  static String _extractPosFromFileName(String fileName) {
    final nameWithoutExt = fileName.replaceAll('.json', '');
    // Handle plural forms
    if (nameWithoutExt.endsWith('s')) {
      return nameWithoutExt.substring(0, nameWithoutExt.length - 1);
    }
    // Handle specific cases
    switch (nameWithoutExt) {
      case 'adjs':
        return 'adj';
      case 'advs':
        return 'adv';
      default:
        return nameWithoutExt;
    }
  }

  static Future<void> saveCards(List<VocabularyCard> cards) async {
    try {
      final file = await _localFile;
      final jsonList = cards.map((card) => card.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await file.writeAsString(jsonString);
      print('[CardLoader] Saved ${cards.length} cards to local storage.');
    } catch (e) {
      print('[CardLoader] Error saving cards: $e');
    }
  }

  static List<VocabularyCard> _parseJsonList(
    List<dynamic> jsonList,
    String source, {
    String? pos,
  }) {
    final cards = <VocabularyCard>[];
    int skippedCount = 0;

    for (final item in jsonList) {
      if (item is! Map<String, dynamic>) {
        _logError('Skipped: Invalid card format (not an object)', item, source);
        skippedCount++;
        continue;
      }

      // Override POS if provided
      if (pos != null) {
        item['pos'] = pos;
      }

      final validationError = _validateCard(item);
      if (validationError != null) {
        _logError('Skipped: $validationError', item, source);
        skippedCount++;
        continue;
      }

      try {
        final card = VocabularyCard.fromJson(item);
        cards.add(card);
      } catch (e) {
        _logError('Skipped: Parse error - $e', item, source);
        skippedCount++;
      }
    }

    if (skippedCount > 0) {
      print(
        '[CardLoader] From $source: Loaded ${cards.length} cards, skipped $skippedCount invalid cards',
      );
    }
    return cards;
  }

  static void _checkSynonymCollisions(List<VocabularyCard> cards) {
    final Map<String, List<String>> synonymToIds = {};

    for (final card in cards) {
      if (card.synonyms.isEmpty) continue;
      final primarySynonym = card.synonyms[0].toLowerCase();
      synonymToIds.putIfAbsent(primarySynonym, () => []);
      synonymToIds[primarySynonym]!.add(card.id);
    }

    // Find collisions
    final collisions = <String, List<String>>{};
    for (final entry in synonymToIds.entries) {
      if (entry.value.length > 1) {
        collisions[entry.key] = entry.value;
      }
    }

    if (collisions.isNotEmpty) {
      print(
        '[CardLoader] WARNING: Synonym collisions detected (same primary synonym for multiple cards):',
      );
      for (final entry in collisions.entries) {
        print(
          '[CardLoader]   - "${entry.key}": cards [${entry.value.join(', ')}]',
        );
      }
    }
  }

  static String? _validateCard(Map<String, dynamic> json) {
    // Check required fields exist
    if (!json.containsKey('id') || json['id'] == null) {
      return 'Missing required field: id';
    }
    if (!json.containsKey('lemma') || json['lemma'] == null) {
      return 'Missing required field: lemma';
    }
    if (!json.containsKey('meanings') || json['meanings'] == null) {
      return 'Missing required field: meanings';
    }
    if (!json.containsKey('synonyms') || json['synonyms'] == null) {
      return 'Missing required field: synonyms';
    }
    if (!json.containsKey('example') || json['example'] == null) {
      return 'Missing required field: example';
    }
    if (!json.containsKey('cloze') || json['cloze'] == null) {
      return 'Missing required field: cloze';
    }

    // Validate meanings length == 1
    final meanings = json['meanings'];
    if (meanings is! List || meanings.isEmpty) {
      return 'meanings must be a non-empty list';
    }
    if (meanings.length != 1) {
      return 'meanings must have exactly 1 element, got ${meanings.length}';
    }

    // Validate synonyms length >= 1
    final synonyms = json['synonyms'];
    if (synonyms is! List || synonyms.isEmpty) {
      return 'synonyms must be a non-empty list with at least 1 element';
    }

    // Validate cloze
    final cloze = json['cloze'];
    if (cloze is! Map<String, dynamic>) {
      return 'cloze must be an object';
    }
    if (!cloze.containsKey('template') || cloze['template'] == null) {
      return 'cloze missing required field: template';
    }
    if (!cloze.containsKey('answer') || cloze['answer'] == null) {
      return 'cloze missing required field: answer';
    }

    final template = cloze['template'] as String;
    final answer = cloze['answer'] as String;

    // Skip cloze.template validation for TODO placeholders
    if (!template.contains('TODO') && !template.contains('{{cloze}}')) {
      return 'cloze.template must contain {{cloze}} or be a TODO placeholder';
    }

    // Validate cloze.answer is non-empty
    if (answer.trim().isEmpty) {
      return 'cloze.answer must be non-empty';
    }

    return null; // Valid
  }

  static void _logError(String message, dynamic item, String source) {
    final id = item is Map<String, dynamic> ? item['id'] : 'unknown';
    print('[CardLoader] ERROR ($source - Card $id): $message');
  }
}
