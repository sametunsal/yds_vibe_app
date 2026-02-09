import 'dart:convert';
import 'dart:io';

void main() {
  // Input files
  final inputFiles = [
    'assets/mvl/verbs.json',
    'assets/mvl/adjectives.json',
    'assets/mvl/phrasal_verbs.json',
    'assets/mvl/conjunctions.json',
  ];

  // Output file
  final outputFile = 'assets/cards.json';

  // Load and merge all cards
  final allCards = <Map<String, dynamic>>[];
  final invalidCards = <Map<String, dynamic>>[];
  final duplicateIds = <String>[];
  final seenIds = <String>{};
  final posCounts = <String, int>{};

  for (final filePath in inputFiles) {
    final file = File(filePath);
    if (!file.existsSync()) {
      print('Error: File not found: $filePath');
      exit(1);
    }

    try {
      final content = file.readAsStringSync();
      final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;

      for (final item in jsonList) {
        if (item is! Map<String, dynamic>) {
          invalidCards.add({'error': 'Not a valid object', 'data': item});
          continue;
        }

        // Check for duplicate ids
        final id = item['id'] as String?;
        if (id == null) {
          invalidCards.add({'error': 'Missing id', 'data': item});
          continue;
        }

        if (seenIds.contains(id)) {
          duplicateIds.add(id);
          continue;
        }
        seenIds.add(id);

        // Validate card
        if (_isValidCard(item)) {
          allCards.add(item);
          final pos = item['pos'] as String? ?? 'unknown';
          posCounts[pos] = (posCounts[pos] ?? 0) + 1;
        } else {
          invalidCards.add(item);
        }
      }
    } catch (e) {
      print('Error reading $filePath: $e');
      exit(1);
    }
  }

  // Check for duplicates and fail if found
  if (duplicateIds.isNotEmpty) {
    print('Error: Duplicate card IDs found:');
    for (final id in duplicateIds) {
      print('  - $id');
    }
    exit(1);
  }

  // MVL_LIMIT: Select exactly 100 cards
  const mvlLimit = 100;
  final categoryLimits = {
    'verb': 40,
    'adjective': 30,
    'phrasal_verb': 20,
    'conjunction': 10,
  };

  // Group cards by POS and sort by id for deterministic selection
  final cardsByPos = <String, List<Map<String, dynamic>>>{};
  for (final card in allCards) {
    final pos = card['pos'] as String? ?? 'unknown';
    cardsByPos.putIfAbsent(pos, () => []);
    cardsByPos[pos]!.add(card);
  }

  // Sort each category by id and select up to the limit
  final selectedCards = <Map<String, dynamic>>[];
  final selectedCounts = <String, int>{};

  for (final entry in categoryLimits.entries) {
    final pos = entry.key;
    final limit = entry.value;
    final cards = cardsByPos[pos] ?? [];

    // Sort by id for deterministic selection
    cards.sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));

    // Take first N cards
    final toSelect = cards.length < limit ? cards.length : limit;
    selectedCards.addAll(cards.sublist(0, toSelect));
    selectedCounts[pos] = toSelect;

    if (cards.length > limit) {
      print('Note: $pos has ${cards.length} cards, selecting first $limit');
    }
  }

  // Verify we got exactly 100 cards
  if (selectedCards.length != mvlLimit) {
    print('Warning: Expected $mvlLimit cards, but selected ${selectedCards.length}');
  }

  // Write output file
  final outputFileObj = File(outputFile);
  outputFileObj.parent.createSync(recursive: true);
  outputFileObj.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(selectedCards),
  );

  // Print summary
  print('\n=== Merge Summary ===');
  print('Input cards by POS:');
  posCounts.forEach((pos, count) {
    print('  $pos: $count');
  });
  print('\nSelected for MVL (total: ${selectedCards.length}):');
  selectedCounts.forEach((pos, count) {
    print('  $pos: $count');
  });
  print('\nTotal valid cards: ${allCards.length}');
  print('Total selected: ${selectedCards.length}');
  print('Total invalid cards: ${invalidCards.length}');
  print('Total skipped (duplicates): ${duplicateIds.length}');
  print('\nOutput written to: $outputFile');

  // Print invalid card details if any
  if (invalidCards.isNotEmpty) {
    print('\n=== Invalid Cards (${invalidCards.length}) ===');
    for (final card in invalidCards) {
      print('  - ${card['id'] ?? 'unknown id'}: ${card['error'] ?? 'validation failed'}');
    }
  }
}

bool _isValidCard(Map<String, dynamic> card) {
  // Check required fields
  if (!card.containsKey('id') || card['id'] is! String) return false;
  if (!card.containsKey('lemma') || card['lemma'] is! String) return false;
  if (!card.containsKey('pos') || card['pos'] is! String) return false;

  // Check meanings: must be a list with exactly 1 element
  if (!card.containsKey('meanings') || card['meanings'] is! List) return false;
  final meanings = card['meanings'] as List;
  if (meanings.length != 1) return false;

  // Check synonyms: must be a list with at least 1 element
  if (!card.containsKey('synonyms') || card['synonyms'] is! List) return false;
  final synonyms = card['synonyms'] as List;
  if (synonyms.isEmpty) return false;

  // Check example.text exists
  if (!card.containsKey('example') || card['example'] is! Map) return false;
  final example = card['example'] as Map;
  if (!example.containsKey('text') || example['text'] is! String) return false;

  // Check cloze.template contains {{cloze}} exactly once
  if (!card.containsKey('cloze') || card['cloze'] is! Map) return false;
  final cloze = card['cloze'] as Map;
  if (!cloze.containsKey('template') || cloze['template'] is! String) return false;
  final template = cloze['template'] as String;
  final clozeCount = '{{cloze}}'.allMatches(template).length;
  if (clozeCount != 1) return false;

  // Check cloze.answer is non-empty
  if (!cloze.containsKey('answer') || cloze['answer'] is! String) return false;
  final answer = cloze['answer'] as String;
  if (answer.isEmpty) return false;

  return true;
}
