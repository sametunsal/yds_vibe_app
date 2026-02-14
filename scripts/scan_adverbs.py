import json, os

ASSETS = os.path.join(os.path.dirname(__file__), '..', 'assets')

files = [
    'cards.json',
    'mvl/verbs.json', 'mvl/adjs.json', 'mvl/advs.json',
    'mvl/phrasal_verbs.json', 'mvl/conjunctions.json',
    'mvl/adjectives.json', 'mvl/adverbs.json',
    'core/core_450.json', 'core/core_nonverb_200.json', 'core/phrases_80.json',
]

existing_adverbs = set()
all_existing = set()

for f in files:
    path = os.path.join(ASSETS, f)
    if not os.path.exists(path):
        continue
    with open(path, 'r', encoding='utf-8') as fh:
        cards = json.load(fh)
    for c in cards:
        key = f"{c.get('lemma','').lower()}|{c.get('pos','').lower()}"
        all_existing.add(key)
        if c.get('pos','').lower() == 'adv':
            existing_adverbs.add(c.get('lemma','').lower())

print(f"Total existing lemma|pos pairs: {len(all_existing)}")
print(f"Existing adverbs: {len(existing_adverbs)}")
print("Adverb lemmas:")
for a in sorted(existing_adverbs):
    print(f"  - {a}")
