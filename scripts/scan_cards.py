import json
import glob
import os

cards = []
asset_dir = r'd:\proje\yds_vibe_app\assets'

for f in glob.glob(os.path.join(asset_dir, '**', '*.json'), recursive=True):
    try:
        with open(f, 'r', encoding='utf-8') as fh:
            data = json.load(fh)
            if isinstance(data, list):
                cards.extend(data)
    except Exception as e:
        print(f"Error reading {f}: {e}")

existing = set()
ids = set()
for c in cards:
    lemma = c.get('lemma', '').lower()
    pos = c.get('pos', '')
    cid = c.get('id', '')
    if lemma:
        existing.add(f"{lemma}|{pos}")
    if cid:
        ids.add(cid)

print(f"Total cards: {len(cards)}")
print(f"Unique lemma|pos: {len(existing)}")
print(f"Unique IDs: {len(ids)}")
print("---LEMMA_POS---")
for lp in sorted(existing):
    print(lp)
