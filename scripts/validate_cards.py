import json
import glob
import os
import sys

# Load existing cards
existing_lemma_pos = set()
existing_ids = set()
asset_dir = r'd:\proje\yds_vibe_app\assets'

for f in glob.glob(os.path.join(asset_dir, '**', '*.json'), recursive=True):
    if 'core' in f:
        continue  # skip our new files
    try:
        with open(f, 'r', encoding='utf-8') as fh:
            data = json.load(fh)
            if isinstance(data, list):
                for c in data:
                    lemma = c.get('lemma', '').lower()
                    pos = c.get('pos', '')
                    cid = c.get('id', '')
                    if lemma:
                        existing_lemma_pos.add(f"{lemma}|{pos}")
                    if cid:
                        existing_ids.add(cid)
    except:
        pass

# Load new file
new_file = sys.argv[1] if len(sys.argv) > 1 else r'd:\proje\yds_vibe_app\assets\core\starter_50.json'
with open(new_file, 'r', encoding='utf-8') as fh:
    new_cards = json.load(fh)

print(f"New cards: {len(new_cards)}")

# Validate
errors = []
seen_ids = set()
seen_lp = set()
collisions = []

for i, c in enumerate(new_cards):
    cid = c.get('id', '')
    lemma = c.get('lemma', '').lower()
    pos = c.get('pos', '')
    lp = f"{lemma}|{pos}"
    
    # Check required fields
    for field in ['id', 'lemma', 'pos', 'meanings', 'synonyms', 'example', 'cloze']:
        if field not in c:
            errors.append(f"Card {i}: missing {field}")
    
    # Check meanings length
    if len(c.get('meanings', [])) != 1:
        errors.append(f"Card {i} ({cid}): meanings length != 1")
    
    # Check example structure
    ex = c.get('example', {})
    if 'text' not in ex or 'translation' not in ex:
        errors.append(f"Card {i} ({cid}): example missing text/translation")
    
    # Check cloze
    cloze = c.get('cloze', {})
    if 'template' not in cloze or 'answer' not in cloze:
        errors.append(f"Card {i} ({cid}): cloze missing template/answer")
    elif '{{cloze}}' not in cloze.get('template', ''):
        errors.append(f"Card {i} ({cid}): cloze template missing {{{{cloze}}}}")
    
    # Check cloze answer appears in example text
    if cloze.get('answer', '') and ex.get('text', ''):
        if cloze['answer'] not in ex['text']:
            errors.append(f"Card {i} ({cid}): cloze answer '{cloze['answer']}' not in example text")
    
    # Check duplicates within new file
    if cid in seen_ids:
        errors.append(f"Card {i}: duplicate id '{cid}'")
    seen_ids.add(cid)
    
    if lp in seen_lp:
        errors.append(f"Card {i}: duplicate lemma|pos '{lp}'")
    seen_lp.add(lp)
    
    # Check collisions with existing
    if cid in existing_ids:
        collisions.append(f"ID collision: {cid}")
    if lp in existing_lemma_pos:
        collisions.append(f"Lemma|pos collision: {lp}")

print(f"\nErrors: {len(errors)}")
for e in errors:
    print(f"  ❌ {e}")

print(f"\nCollisions with existing: {len(collisions)}")
for c in collisions:
    print(f"  ⚠️ {c}")

if not errors and not collisions:
    print("\n✅ All cards valid, no collisions!")
