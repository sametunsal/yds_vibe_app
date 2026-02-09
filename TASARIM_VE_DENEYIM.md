# YDS Vibe - MVP Ürün ve Öğrenme Tasarımı (Kısıtlı Kapsam)

> **DİKKAT:** Bu doküman "Strict MVP" kurallarına göre revize edilmiştir. Sadece Kelime SRS ve Mini Quiz içerir. Okuma, Gramer ve Audio **kapsam dışıdır**.

---

## 1. Temel Öğrenme Döngüsü (Core Learning Loop)

Kullanıcı günde sadece 1 kez uygulamaya girer ve aşağıdaki akışı tamamlar:

1.  **Giriş & Durum Kontrolü:** Uygulama açılır, bugünkü "Due" (Tekrarı gelmiş) kartlar ve "New" (Yeni) kartlar hesaplanır.
2.  **Önceliklendirme:** Eğer çok fazla tekrar varsa, yeni kart gösterimi otomatik olarak azaltılır veya durdurulur (Review First).
3.  **Active Recall Seansı:**
    *   Kullanıcıya kelime gösterilir.
    *   Kullanıcı anlamı hatırlar.
    *   "GÖSTER" butonuna basar.
    *   Kendini 4 seviyeden biriyle puanlar (Again, Struggled, Good, Easy).
    *   Sonraki karta geçilir.
4.  **Günlük Hedef Tamamlama:** Limitlere (Max 15 Yeni + Tekrarlar) ulaşılınca set biter.
5.  **Ödül (Opsiyonel):** Günlük set bitince "Mini Quiz" (Max 10 soru) kilidi açılır.
6.  **Kapanış:** Kullanıcıya "Yarına kadar özgürsün" mesajı verilir ve streak artar.

---

## 2. Ekran Listesi (Screen List)

### A. Ana Ekran (Home / Dashboard)
*   **Odak:** Tek aksiyon. Karmaşa yok.
*   **Durum:**
    *   "Bugünkü Yeni Kelimeler: 0/15"
    *   "Tekrar Edilecekler: X"
*   **Ana Buton:** "BAŞLA" (Dinamik text: Önce "Tekrar", bittiyse "Yeni Kelimeler").
*   **İkincil Aksiyon:** "Sadece Tekrar Modu" (Review Only) toggle'ı.
*   **Mini Quiz Butonu:** Günlük çalışma bitmeden aktif olmaz (Pasif/Gri).

### B. Çalışma Ekranı (Study / Review Interface)
*   **Kart Kart Yapısı:** Ekranı tamamen kaplayan tek bir kart.
*   **Ön Yüz:** Sadece Kelime ve Türü (n/v/adj).
*   **Arka Yüz (Reveal Sonrası):**
    *   Türkçe Anlamı.
    *   Eş Anlamlıları (Synonyms).
    *   1 Adet YDS Çıkmış/Akademik Örnek Cümle.
*   **Aksiyon Barı (Footer):**
    *   **Again (Tekrar):** < 1 dk (Kırmızı)
    *   **Struggled (Zor):** < 10 dk (Turuncu)
    *   **Good (İyi):** 1 gün (Mavi)
    *   **Easy (Kolay):** 4 gün (Yeşil)
    *   *(Süreler SM-2 algoritmasına göre dinamik değişecek, buradakiler ilk gösterim içindir)*

### C. Mini Quiz Ekranı
*   **Sınır:** Maksimum 10 soru.
*   **Format:** 1 soru/ekran. Geri dönülemez.
*   **Sonuç:** 8/10 gibi basit skor. Analiz yok, sadece doğru şıkkı göster.

### D. Profil / Ayarlar (Minimal)
*   **İstatistik:** Toplam Öğrenilen Kelime Sayısı, Current Streak.
*   **Ayarlar:** "İlerlememi Sıfırla" (Reset Progress).

---

## 3. Temel UI Bileşenleri (Key Components)

1.  **Flashcard Container:**
    *   Minimal, gölgesiz, ince border (1px).
    *   Typography odaklı (Serif font for sentences, Sans-serif for UI).
    *   Dikkat dağıtıcı renk yok (Siyah/Beyaz/Gri odaklı).
2.  **Confidence Rating Bar:**
    *   4 Buton yan yana.
    *   Her butonun üzerinde o seçeneğin "Next Review" süresi küçük fontla yazacak (Örn: "4g").
3.  **Progress Header:**
    *   Basit bir çizgi (Linear Progress Indicator).

---

## 4. Kelime Kartı İçerik Şablonu (Vocab Card Template)

**Front:**
```text
[Word]
abandon

[Type]
(v.)
```

**Back:**
```text
[Meaning]
terk etmek, vazgeçmek, bırakmak

[Synonyms]
leave, give up, desert

[Context Sentence]
The government decided to abandon the project due to lack of funds.
```

---

## 5. Mini Quiz Soru Tipleri (YDS Style - Simplified)

MVP için sadece çoktan seçmeli (Multiple Choice):

1.  **Eş Anlamlıyı Bulma (Synonym Matching):**
    *   Soru: "Which of the following is synonymous with **'mitigat'**?"
    *   Şıklar: A) Worsen, B) Alleviate, C) Increase, D) Ignore, E) Predict.
2.  **Cümle Tamamlama (Sentence Completion - Cloze):**
    *   Soru: "Scientists argue that we must _____ our consumption of fossil fuels."
    *   Şıklar: A) curtail, B) expand, C) neglect, D) verify, E) distribute.
3.  **Türkçe -> İngilizce Çeviri (Basit):**
    *   Soru: "Hükümet enflasyonla mücadele etmek için yeni önlemler aldı."
    *   Şıklar: (Cümle varyasyonları).

---

## 6. UX Gerekçeleri (Rationale - Short)

*   **Neden "Review Only" butonu?** Kullanıcının vakti azsa veya yorgunsa, yeni kelime öğrenmek istemeyebilir ama tekrar yapması kritiktir. Zinciri kırmadan devam etmesini sağlar.
*   **Neden Max 15 Yeni Kart?** YDS uzun soluklu bir süreçtir. Günde 50 kelime ezberlemeye çalışmak 3. gün tükenmişlik (burnout) yaratır. Sürdürülebilirlik > Hız.
*   **Neden SM-2 algoritması?** Leitner (Kutu sistemi) çok rijittir. SM-2, kullanıcının "Zorlandım" dediği kartı daha sık, "Kolay" dediğini çok daha seyrek sorarak verimliliği maksimize eder.
