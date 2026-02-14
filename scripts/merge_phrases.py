import json, os
from collections import Counter

ASSETS = os.path.join(os.path.dirname(__file__), '..', 'assets')

def load_existing():
    files = [
        'cards.json',
        'mvl/verbs.json', 'mvl/adjs.json', 'mvl/advs.json',
        'mvl/phrasal_verbs.json', 'mvl/conjunctions.json',
        'mvl/adjectives.json', 'mvl/adverbs.json',
        'core/core_450.json', 'core/core_nonverb_200.json',
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

def merge_phrases():
    existing = load_existing()
    print(f"Existing lemma|pos pairs: {len(existing)}")

    all_cards = []
    seen = set()
    skipped = 0

    for bf in ['phrases_batch1.json', 'phrases_batch2.json']:
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
            all_cards.append(c)

    out_path = os.path.join(ASSETS, 'core', 'phrases_80.json')
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(all_cards, f, ensure_ascii=False, indent=2)

    print(f"\n=== phrases_80.json ===")
    print(f"Total phrase cards: {len(all_cards)}")
    print(f"Skipped duplicates: {skipped}")

if __name__ == '__main__':
    merge_phrases()
