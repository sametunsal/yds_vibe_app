import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/card.dart';

class CardLoader {
  static const String cardsPath = 'assets/cards.json';

  static Future<List<VocabularyCard>> loadCards() async {
    try {
      final jsonString = await rootBundle.loadString(cardsPath);
      final List<dynamic> jsonList = json.decode(jsonString);

      final cards = <VocabularyCard>[];
      int skippedCount = 0;

      for (final item in jsonList) {
        if (item is! Map<String, dynamic>) {
          _logError('Skipped: Invalid card format (not an object)', item);
          skippedCount++;
          continue;
        }

        final validationError = _validateCard(item);
        if (validationError != null) {
          _logError('Skipped: $validationError', item);
          skippedCount++;
          continue;
        }

        try {
          final card = VocabularyCard.fromAssetJson(item);
          cards.add(card);
        } catch (e) {
          _logError('Skipped: Parse error - $e', item);
          skippedCount++;
        }
      }

      if (skippedCount > 0) {
        print('[CardLoader] Loaded ${cards.length} cards, skipped $skippedCount invalid cards');
      } else {
        print('[CardLoader] Loaded ${cards.length} cards successfully');
      }

      // Check for synonym collisions (same primary synonym)
      _checkSynonymCollisions(cards);

      return cards;
    } catch (e) {
      print('[CardLoader] Error loading cards: $e');
      return [];
    }
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
      print('[CardLoader] WARNING: Synonym collisions detected (same primary synonym for multiple cards):');
      for (final entry in collisions.entries) {
        print('[CardLoader]   - "${entry.key}": cards [${entry.value.join(', ')}]');
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
    if (synonyms.isEmpty) {
      return 'synonyms must have at least 1 element';
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

    // Validate cloze.template contains {{cloze}} exactly once
    final clozeCount = '{{cloze}}'.allMatches(template).length;
    if (clozeCount != 1) {
      return 'cloze.template must contain {{cloze}} exactly once, found $clozeCount times';
    }

    // Validate cloze.answer is non-empty
    if (answer.trim().isEmpty) {
      return 'cloze.answer must be non-empty';
    }

    return null; // Valid
  }

  static void _logError(String message, dynamic item) {
    final id = item is Map<String, dynamic> ? item['id'] : 'unknown';
    print('[CardLoader] ERROR (Card $id): $message');
  }
}
