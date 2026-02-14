import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/card.dart';

/// Loads card CONTENT from assets (read-only).
/// SRS progress is managed separately by ProgressService.
class CardLoader {
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

  static List<VocabularyCard>? _cache;

  /// Clear in-memory cache (debug only).
  static void clearCache() => _cache = null;

  /// Load all cards from assets. Results are cached in memory.
  static Future<List<VocabularyCard>> loadCards() async {
    if (_cache != null) return _cache!;

    final allCards = <VocabularyCard>[];
    final seenIds = <String>{};

    final filesToLoad = [
      'cards.json',
      'mvl/verbs.json',
      'mvl/adjs.json',
      'mvl/advs.json',
      'mvl/phrasal_verbs.json',
      'mvl/conjunctions.json',
      'mvl/adjectives.json',
      'mvl/adverbs.json',
      'core/core_450.json',
      'core/core_nonverb_200.json',
      'core/phrases_80.json',
      'core/adv_120.json',
      'core/connectors_90.json',
      'core/phrasal_verbs_120.json',
    ];

    for (final filePath in filesToLoad) {
      try {
        final jsonString = await rootBundle.loadString('assets/$filePath');
        final List<dynamic> jsonList = json.decode(jsonString);

        final fileName = filePath.split('/').last;
        final pos = _filePosMapping[fileName];
        final cards = _parseJsonList(jsonList, fileName, pos: pos);

        for (final card in cards) {
          if (seenIds.contains(card.id)) {
            debugPrint('[CardLoader] Duplicate ID ${card.id} in $filePath');
          } else {
            seenIds.add(card.id);
            allCards.add(card);
          }
        }

        debugPrint(
          '[CardLoader] $filePath: ${cards.length} cards${pos != null ? ' (pos: $pos)' : ''}',
        );
      } catch (e) {
        debugPrint('[CardLoader] Error loading $filePath: $e');
      }
    }

    // POS breakdown
    final posCounts = <String, int>{};
    for (final c in allCards) {
      posCounts[c.pos] = (posCounts[c.pos] ?? 0) + 1;
    }
    debugPrint('[CardLoader] Total: ${allCards.length} cards');
    debugPrint('[CardLoader] POS breakdown: $posCounts');
    // List successfully loaded files
    debugPrint('[CardLoader] Files attempted: ${filesToLoad.length}');
    _cache = allCards;
    return allCards;
  }

  static List<VocabularyCard> _parseJsonList(
    List<dynamic> jsonList,
    String source, {
    String? pos,
  }) {
    final cards = <VocabularyCard>[];
    int skipped = 0;

    for (final item in jsonList) {
      if (item is! Map<String, dynamic>) {
        skipped++;
        continue;
      }

      if (pos != null) item['pos'] = pos;

      final error = _validateCard(item);
      if (error != null) {
        _logError(error, item, source);
        skipped++;
        continue;
      }

      try {
        cards.add(VocabularyCard.fromJson(item));
      } catch (e) {
        _logError('Parse error: $e', item, source);
        skipped++;
      }
    }

    if (skipped > 0) {
      debugPrint(
        '[CardLoader] $source: loaded ${cards.length}, skipped $skipped',
      );
    }
    return cards;
  }

  static String? _validateCard(Map<String, dynamic> json) {
    if (json['id'] == null) return 'Missing id';
    if (json['lemma'] == null) return 'Missing lemma';
    if (json['meanings'] == null) return 'Missing meanings';
    if (json['synonyms'] == null) return 'Missing synonyms';
    if (json['example'] == null) return 'Missing example';
    if (json['cloze'] == null) return 'Missing cloze';

    final meanings = json['meanings'];
    if (meanings is! List || meanings.length != 1) {
      return 'meanings must have exactly 1 element';
    }

    final synonyms = json['synonyms'];
    if (synonyms is! List || synonyms.isEmpty) return 'synonyms empty';

    final cloze = json['cloze'];
    if (cloze is! Map<String, dynamic>) return 'cloze not object';
    if (cloze['template'] == null) return 'cloze.template missing';
    if (cloze['answer'] == null) return 'cloze.answer missing';

    final template = cloze['template'] as String;
    if (!template.contains('TODO') && !template.contains('{{cloze}}')) {
      return 'cloze.template must contain {{cloze}}';
    }
    if ((cloze['answer'] as String).trim().isEmpty) {
      return 'cloze.answer empty';
    }

    return null;
  }

  static void _logError(String message, dynamic item, String source) {
    final id = item is Map<String, dynamic> ? item['id'] : '?';
    debugPrint('[CardLoader] $source/$id: $message');
  }
}
