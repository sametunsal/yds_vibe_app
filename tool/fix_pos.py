import json
import os

# Dosya yolu
file_path = 'assets/cards.json'

def fix_pos_tags():
    if not os.path.exists(file_path):
        print(f"Hata: {file_path} bulunamadi!")
        return

    with open(file_path, 'r', encoding='utf-8') as f:
        cards = json.load(f)

    count = 0
    for card in cards:
        # Eğer türü 'word' ise veya belirtilmemişse 'noun' yap
        if card.get('pos') == 'word' or 'pos' not in card:
            card['pos'] = 'noun'
            count += 1

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(cards, f, ensure_ascii=False, indent=2)

    print(f"✅ Toplam {count} kart 'noun' olarak güncellendi.")

if __name__ == "__main__":
    fix_pos_tags()
