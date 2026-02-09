# YDS Vibe - İçerik Üretim Pipeline'ı ve Kuralları

## 1. Veri Şeması (JSON Schema for Cards)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "YDSCard",
  "type": "object",
  "properties": {
    "id": { "type": "string", "pattern": "^[a-z0-9_]+$" },
    "lemma": { "type": "string" },
    "pos": { 
      "type": "string", 
      "enum": ["noun", "verb", "adjective", "adverb", "phrasal_verb", "conjunction", "preposition", "prepositional_phrase"] 
    },
    "meanings": {
      "type": "array",
      "items": { "type": "string" },
      "minItems": 1,
      "maxItems": 2
    },
    "synonyms": {
      "type": "array",
      "items": { "type": "string" },
      "maxItems": 3
    },
    "example": {
      "type": "object",
      "properties": {
        "text": { "type": "string" },
        "translation": { "type": "string" }
      },
      "required": ["text", "translation"]
    },
    "tags": {
      "type": "array",
      "items": { "type": "string" }
    },
    "difficulty": { "type": "integer", "minimum": 1, "maximum": 5 }
  },
  "required": ["id", "lemma", "pos", "meanings", "example"]
}
```

---

## 2. İçerik Yazım Kuralları (Quality Bar checklist)

Her kart oluşturulmadan önce bu kurallardan geçmelidir:

1.  **Tek Anlam Kuralı:** Kelimenin *sadece* YDS'de en sık çıkan akademik anlamı yazılacak. Yan anlamlar veya günlük konuşma anlamları girilmemeli. (Örn: *Address* -> "Sorunu ele almak/çözmek", "Adres" değil).
2.  **Akademik Cümle:** Örnek cümleler "I go to school" tarzı olamaz. Bilimsel, sosyal veya politik bir bağlam içermelidir. (Örn: "The government must **address** the issue of unemployment immediately.")
3.  **Birebir Eş Anlamlılık:** Eş anlamlılar (Synonyms) cümlede asıl kelimenin yerine konduğunda anlamı bozmamalıdır. Yakın anlamlılar yazılmamalı.
4.  **No Spoilers:** Örnek cümle içinde, sorulan kelimenin kökü veya türevi geçmemeli. (Örn: *Improve* soruluyorsa cümlede *improvement* geçmemeli).
5.  **Temiz Çeviri:** Örnek cümlenin çevirisi motamot değil, düzgün Türkçe ile yapılmalı ama kelimenin karşılığı net anlaşılmalı.

---

## 3. Örneklem Planı (500 Kartlık Paket)

### A. Starter Pack (İlk 50 - "Isınma Turu")
YDS'de en garanti çıkan, orta zorlukta kelimeler.

| Kategori | Adet | Örnekler |
| :--- | :--- | :--- |
| **Verbs** | 15 | Enhance, Maintain, Reduce, Assess, Indicate... |
| **Adjectives** | 10 | Significant, Potential, Essential, Initial, Severe... |
| **Adverbs** | 10 | Significantly, Approximately, Ultimately, Merely, Gradually... |
| **Phrasal Verbs** | 5 | Carry out, Make up, Set up, Bring about, Point out... |
| **Conjunctions**| 5 | Although, Whereas, Unless, Provided that, As long as... |
| **Prepositions**| 5 | Despite, In terms of, Due to, As a result of, Regardless of... |
| **TOPLAM** | **50** | |

### B. Core Pack (Kalan 450 - "Ana Gövde")
Daha derin akademik kelimeler ve çeldirici yapılar.

| Kategori | Hedef | Odak Noktası |
| :--- | :--- | :--- |
| **Verbs** | 120 | Bilimsel süreçler (Evolve, Fluctuate), Soyut eylemler (Imply, Infer). |
| **Adjectives** | 100 | Niteleyiciler (Ambiguous, Consistent, Vulnerable, Hostile). |
| **Adverbs** | 80 | Derecelendirme zarfları (Profoundly, Inevitably, Virtually). |
| **Phrasal V.** | 60 | YDS klasik listesi (Account for, Cope with, Abstain from). |
| **Nouns** | 40 | Soyut kavramlar (Reluctance, Tendency, Consensus). |
| **Prep. Phr.** | 30 | Edat öbekleri (In addition to, With a view to). |
| **Conj.** | 20 | Zıtlık ve Sebep-Sonuç bağlaçları. |
| **TOPLAM** | **450** | |

---

## 4. Quiz Üretim Mantığı (Rule-based Generation)

SRS havuzundaki kartlardan otomatik 10 soruluk test üretme kuralları:

### Soru Tipi 1: Eş Anlamlıyı Bul (Synonym Check)
*   **Soru:** "Choose the synonym for: **[Lemma]**"
*   **Doğru Cevap:** `card.synonyms[0]`
*   **Çeldiriciler (Distractors):**
    *   Aynı `pos` (Part of Speech) değerine sahip diğer kartlardan rastgele 3 kelime seç.
    *   Seçilen çeldiricilerin `synonyms` listesi, doğru cevabın listesiyle kesişmemelidir (Çift doğru cevap olmaması için).

### Soru Tipi 2: Cümle Tamamlama (Cloze Test)
*   **Soru:** `card.example.text` içindeki `[Lemma]` kelimesini `_______` ile değiştir.
*   **Doğru Cevap:** `[Lemma]`
*   **Çeldiriciler:**
    *   Aynı `pos` değerine sahip 3 rastgele kelime.
    *   Zorluğu artırmak için: Çeldiricilerin uzunluğu veya başlangıç harfi doğru cevaba yakın seçilebilir (Opsiyonel).
    *   Gramatik doğruluk: Eğer boşluktan sonra "to" geliyorsa, çeldiriciler de "to" ile kullanılabilen fiillerden seçilmelidir (Advanced Logic).

### Soru Tipi 3: Türkçe -> İngilizce (Reverse Translation)
*   **Soru:** "`card.meanings[0]`" anlamı hangisidir?
*   **Doğru Cevap:** `[Lemma]`
*   **Çeldiriciler:**
    *   Rastgele 3 kelime (Farklı `pos` olabilir ama aynı `pos` daha zorlayıcıdır).

**Quiz Dağılımı (10 Soru):**
*   4 x Eş Anlamlı
*   4 x Cümle Tamamlama
*   2 x TR->ENG
