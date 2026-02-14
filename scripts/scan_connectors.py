import json, os

ASSETS = os.path.join(os.path.dirname(__file__), '..', 'assets')

files = [
    'cards.json',
    'mvl/verbs.json', 'mvl/adjs.json', 'mvl/advs.json',
    'mvl/phrasal_verbs.json', 'mvl/conjunctions.json',
    'mvl/adjectives.json', 'mvl/adverbs.json',
    'core/core_450.json', 'core/core_nonverb_200.json',
    'core/phrases_80.json', 'core/adv_120.json',
]

conj_set = set()
phrase_set = set()
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
        pos = c.get('pos','').lower()
        if pos in ('conj', 'conjunction'):
            conj_set.add(c.get('lemma','').lower())
        elif pos == 'phrase':
            phrase_set.add(c.get('lemma','').lower())

print(f"Total existing lemma|pos pairs: {len(all_existing)}")
print(f"\nExisting conjunctions ({len(conj_set)}):")
for a in sorted(conj_set):
    print(f"  - {a}")
print(f"\nExisting phrases ({len(phrase_set)}):")
for a in sorted(phrase_set):
    print(f"  - {a}")
