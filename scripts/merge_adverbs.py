import json, os
from collections import Counter

ASSETS = os.path.join(os.path.dirname(__file__), '..', 'assets')

def load_existing():
    files = [
        'cards.json',
        'mvl/verbs.json', 'mvl/adjs.json', 'mvl/advs.json',
        'mvl/phrasal_verbs.json', 'mvl/conjunctions.json',
        'mvl/adjectives.json', 'mvl/adverbs.json',
        'core/core_450.json', 'core/core_nonverb_200.json', 'core/phrases_80.json',
    ]
    existing = set()
    for f in files:
        path = os.path.join(ASSETS, f)
        if not os.path.exists(path):
            continue
        with open(path, 'r', encoding='utf-8') as fh:
            cards = json.load(fh)
            for c in cards:
                key = f"{c.get('lemma','').lower()}|{c.get('pos','').lower()}"
                existing.add(key)
    return existing

def merge():
    existing = load_existing()
    print(f"Existing lemma|pos pairs: {len(existing)}")

    all_cards = []
    seen = set()
    skipped = 0

    for bf in ['adv_batch1.json', 'adv_batch2.json', 'adv_batch3.json', 'adv_replacements.json', 'adv_replacements2.json']:
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

    out_path = os.path.join(ASSETS, 'core', 'adv_120.json')
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(all_cards, f, ensure_ascii=False, indent=2)

    pos_counts = Counter(c.get('pos','?') for c in all_cards)
    print(f"\n=== adv_120.json ===")
    print(f"Total generated: {len(all_cards) + skipped}")
    print(f"Skipped duplicates: {skipped}")
    print(f"Final cards: {len(all_cards)}")
    print(f"POS counts: {dict(pos_counts)}")

if __name__ == '__main__':
    merge()
