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
        'core/phrases_80.json', 'core/adv_120.json',
    ]
    existing = set()
    for f in files:
        path = os.path.join(ASSETS, f)
        if not os.path.exists(path):
            continue
        with open(path, 'r', encoding='utf-8') as fh:
            for c in json.load(fh):
                key = f"{c.get('lemma','').lower()}|{c.get('pos','').lower()}"
                existing.add(key)
    return existing

def merge():
    existing = load_existing()
    print(f"Existing lemma|pos pairs: {len(existing)}")

    all_cards = []
    seen = set()
    skipped = 0

    for bf in ['conn_batch1.json', 'conn_batch2.json', 'conn_batch3.json']:
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

    out = os.path.join(ASSETS, 'core', 'connectors_90.json')
    with open(out, 'w', encoding='utf-8') as f:
        json.dump(all_cards, f, ensure_ascii=False, indent=2)

    pos_counts = Counter(c.get('pos','?') for c in all_cards)
    print(f"\n=== connectors_90.json ===")
    print(f"Total generated: {len(all_cards) + skipped}")
    print(f"Skipped duplicates: {skipped}")
    print(f"Final cards: {len(all_cards)}")
    print(f"POS counts: {dict(pos_counts)}")

if __name__ == '__main__':
    merge()
