import json, os, sys
from collections import Counter

ASSETS = os.path.join(os.path.dirname(__file__), '..', 'assets')

def load_existing():
    """Load all existing lemma|pos pairs from current card files."""
    files = [
        'cards.json',
        'mvl/verbs.json', 'mvl/adjs.json', 'mvl/advs.json',
        'mvl/phrasal_verbs.json', 'mvl/conjunctions.json',
        'mvl/adjectives.json', 'mvl/adverbs.json',
        'core/core_450.json',
    ]
    existing = set()
    for f in files:
        path = os.path.join(ASSETS, f)
        if os.path.exists(path):
            with open(path, 'r', encoding='utf-8') as fh:
                cards = json.load(fh)
                for c in cards:
                    key = f"{c.get('lemma','').lower()}|{c.get('pos','').lower()}"
                    existing.add(key)
    return existing

def merge_batches(batch_files, output_name, existing):
    all_cards = []
    seen = set()
    skipped = 0
    pos_counts = Counter()

    for bf in batch_files:
        path = os.path.join(ASSETS, 'core', bf)
        with open(path, 'r', encoding='utf-8') as f:
            cards = json.load(f)
        for c in cards:
            key = f"{c.get('lemma','').lower()}|{c.get('pos','').lower()}"
            if key in existing or key in seen:
                print(f"  SKIP collision: {key}")
                skipped += 1
                continue
            seen.add(key)
            pos_counts[c.get('pos','')] += 1
            all_cards.append(c)

    out_path = os.path.join(ASSETS, 'core', output_name)
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(all_cards, f, ensure_ascii=False, indent=2)

    print(f"\n=== {output_name} ===")
    print(f"Total cards: {len(all_cards)}")
    print(f"Skipped duplicates: {skipped}")
    print("POS distribution:")
    for pos, count in sorted(pos_counts.items()):
        print(f"  {pos}: {count}")
    return len(all_cards), skipped

if __name__ == '__main__':
    existing = load_existing()
    print(f"Existing lemma|pos pairs: {len(existing)}")

    # Merge nonverb batches
    nv_batches = ['nv_nouns1.json', 'nv_nouns2.json', 'nv_adverbs.json', 'nv_function.json', 'nv_phrases.json', 'nv_replacements.json', 'nv_replacements2.json', 'nv_replacements3.json']
    merge_batches(nv_batches, 'core_nonverb_200.json', existing)
