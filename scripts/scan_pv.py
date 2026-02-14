import json, os

ASSETS = os.path.join(os.path.dirname(__file__), '..', 'assets')

files = [
    'cards.json',
    'mvl/verbs.json', 'mvl/adjs.json', 'mvl/advs.json',
    'mvl/phrasal_verbs.json', 'mvl/conjunctions.json',
    'mvl/adjectives.json', 'mvl/adverbs.json',
    'core/core_450.json', 'core/core_nonverb_200.json',
    'core/phrases_80.json', 'core/adv_120.json', 'core/connectors_90.json',
]

pv_set = set()
all_existing = set()

for f in files:
    path = os.path.join(ASSETS, f)
    if not os.path.exists(path):
        continue
    with open(path, 'r', encoding='utf-8') as fh:
        for c in json.load(fh):
            key = f"{c.get('lemma','').lower()}|{c.get('pos','').lower()}"
            all_existing.add(key)
            if c.get('pos','').lower() == 'phrasal_verb':
                pv_set.add(c.get('lemma','').lower())

print(f"Total existing lemma|pos pairs: {len(all_existing)}")
print(f"\nExisting phrasal_verbs ({len(pv_set)}):")
for a in sorted(pv_set):
    print(f"  - {a}")
