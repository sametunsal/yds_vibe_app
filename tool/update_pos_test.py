import json

file_path = 'assets/cards.json'

updates = {
    'access': 'verb',
    'account': 'noun',
    'achievement': 'noun',
    'addition': 'noun',
    'admission': 'noun',
    'adult': 'adjective',
    'advance': 'verb',
    'advantage': 'noun',
    'advertising': 'noun',
    'advice': 'noun',
    'affair': 'noun',
    'age': 'noun',
    'agency': 'noun',
    'agent': 'noun',
    'aim': 'verb',
    'allowance': 'noun',
    'ambition': 'noun',
    'amount': 'noun',
    'animal': 'noun',
    'apology': 'noun',
    'appearance': 'noun',
    'application': 'noun',
    'appointment': 'noun',
    'approach': 'verb',
    'approval': 'noun',
    'area': 'noun',
    'arrangement': 'noun',
    'arrival': 'noun'
}

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    updated_count = 0
    for card in data:
        lemma = card.get('lemma')
        if lemma in updates:
            card['pos'] = updates[lemma]
            updated_count += 1
            print(f"Updated {lemma} to {updates[lemma]}")

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"Successfully updated {updated_count} cards.")

except Exception as e:
    print(f"Error: {e}")
