import json

files = ['assets/cards.json', 'tool/assets/new_cards.json']
unique_pos = set()

for file_path in files:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            for item in data:
                if 'pos' in item:
                    unique_pos.add(item['pos'])
    except FileNotFoundError:
        print(f"File not found: {file_path}")

print("Unique POS values:", unique_pos)
