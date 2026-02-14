import json
import glob
import os
import re

# Load existing cards (non-core)
existing_lp = set()
existing_ids = set()
asset_dir = r'd:\proje\yds_vibe_app\assets'

for f in glob.glob(os.path.join(asset_dir, '**', '*.json'), recursive=True):
    if 'core' in f:
        continue
    try:
        with open(f, 'r', encoding='utf-8') as fh:
            data = json.load(fh)
            if isinstance(data, list):
                for c in data:
                    lp = f"{c.get('lemma','').lower()}|{c.get('pos','')}"
                    existing_lp.add(lp)
                    existing_ids.add(c.get('id',''))
    except:
        pass

print(f"Existing cards (non-core): {len(existing_lp)} lemma|pos, {len(existing_ids)} IDs")

# Load all core partial files in order
core_dir = os.path.join(asset_dir, 'core')
partials = sorted(glob.glob(os.path.join(core_dir, '*.json')))
partials = [f for f in partials if 'core_450' not in f]  # exclude previous output

all_cards = []
seen_ids = set()
seen_lp = set()
skipped = []
fixed_ids = 0

for f in partials:
    basename = os.path.basename(f)
    with open(f, 'r', encoding='utf-8') as fh:
        cards = json.load(fh)
    
    for c in cards:
        lemma = c['lemma']
        pos = c['pos']
        
        # Fix mismatched IDs: regenerate ID from lemma_pos_number
        expected_prefix = f"{lemma}_{pos}_"
        cid = c['id']
        if not cid.startswith(expected_prefix):
            # Extract number from current ID
            num_match = re.search(r'_(\d+)$', cid)
            if num_match:
                num = num_match.group(1)
                new_id = f"{lemma}_{pos}_{num}"
                c['id'] = new_id
                fixed_ids += 1
                cid = new_id
        
        lp = f"{lemma.lower()}|{pos}"
        
        # Check collision with existing
        if lp in existing_lp:
            skipped.append(f"EXISTING collision: {lp} (id: {cid}) from {basename}")
            continue
        
        # Check internal duplicates
        if lp in seen_lp:
            skipped.append(f"INTERNAL dup lp: {lp} (id: {cid}) from {basename}")
            continue
        if cid in seen_ids:
            skipped.append(f"INTERNAL dup id: {cid} from {basename}")
            continue
        
        seen_ids.add(cid)
        seen_lp.add(lp)
        all_cards.append(c)

# Write merged output
output_file = os.path.join(core_dir, 'core_450.json')
with open(output_file, 'w', encoding='utf-8') as fh:
    json.dump(all_cards, fh, ensure_ascii=False, indent=2)

print(f"\nFixed IDs: {fixed_ids}")
print(f"Total cards merged: {len(all_cards)}")
print(f"Skipped: {len(skipped)}")
for s in skipped:
    print(f"  ⚠️ {s}")
print(f"\nOutput: {output_file}")

# POS distribution
pos_dist = {}
for c in all_cards:
    pos_dist[c['pos']] = pos_dist.get(c['pos'], 0) + 1
print(f"\nPOS distribution:")
for p, cnt in sorted(pos_dist.items()):
    print(f"  {p}: {cnt}")
