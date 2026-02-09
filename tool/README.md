# Card Merge Tool

Merges multiple JSON card files into a single `assets/cards.json` file.

## How to Run

From the project root directory:

```bash
dart run tool/merge_cards.dart
```

## What It Does

1. Loads cards from:
   - `assets/mvl/verbs.json`
   - `assets/mvl/adjectives.json`
   - `assets/mvl/phrasal_verbs.json`
   - `assets/mvl/conjunctions.json`

2. Validates each card:
   - Has `id`, `lemma`, `pos`
   - `meanings` array has exactly 1 element
   - `synonyms` array has at least 1 element
   - `example.text` exists
   - `cloze.template` contains `{{cloze}}` exactly once
   - `cloze.answer` is non-empty

3. Checks for duplicate IDs (fails if duplicates found)

4. Writes merged output to `assets/cards.json`

5. Prints a summary with counts per POS and validation results
