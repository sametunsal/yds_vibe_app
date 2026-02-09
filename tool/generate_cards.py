#!/usr/bin/env python3
"""
generate_cards.py

Generate VocabularyCard JSON files from a raw word list file.
Each line in the input file should contain a single English word.

Usage: python tool/generate_cards.py <dosya_adı.txt> <kelime_türü>
Example: python tool/generate_cards.py verbs.txt verb
"""

import json
import uuid
import datetime
import sys
import os

def generate_cards(input_file, pos_type):
    cards = []

    if not os.path.exists(input_file):
        print(f"Hata: {input_file} dosyası bulunamadı.")
        return

    with open(input_file, 'r', encoding='utf-8') as f:
        words = [line.strip() for line in f if line.strip()]

    print(f"🔄 {len(words)} kelime işleniyor... Tür: {pos_type}")

    for word in words:
        card = {
            "id": str(uuid.uuid4()),
            "lemma": word,
            "pos": pos_type,  # Parameter: verb, adj, noun, adv
            "multiWord": " " in word,
            "meanings": ["TODO: Fill with AI"],
            "synonyms": ["TODO: Fill with AI"],
            "example": {
                "text": "TODO: Fill with AI",
                "translation": "TODO: Fill with AI"
            },
            "cloze": {
                "template": "TODO: Fill with AI",
                "answer": word
            },
            "easeFactor": 2.5,
            "intervalDays": 0,
            "dueDate": datetime.datetime.now().isoformat(),
            "repetitions": 0,
            "lastReviewed": None
        }
        cards.append(card)
        print(f"  [{len(cards)}/{len(words)}] {word} -> {card['id'][:8]}...")

    # Output filename: verbs.json, adjectives.json, etc.
    output_filename = f"assets/mvl/{pos_type}s.json"

    # Create directory if not exists
    os.makedirs(os.path.dirname(output_filename), exist_ok=True)

    with open(output_filename, 'w', encoding='utf-8') as f:
        json.dump(cards, f, ensure_ascii=False, indent=2)

    print(f"✅ {output_filename} dosyası oluşturuldu!")
    print(f"📊 Toplam {len(cards)} kart üretildi.")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Kullanım: python tool/generate_cards.py <kelime_listesi.txt> <kelime_türü>")
        print("Örnekler:")
        print("  python tool/generate_cards.py raw_verbs.txt verb")
        print("  python tool/generate_cards.py raw_adjectives.txt adj")
        print("  python tool/generate_cards.py raw_adverbs.txt adv")
        print("  python tool/generate_cards.py raw_nouns.txt noun")
    else:
        generate_cards(sys.argv[1], sys.argv[2])
