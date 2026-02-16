# YDS Vibe App - Proje Tanıtımı

## 📋 Özet

**YDS Vibe App**, YDS ve İngilizce kelime öğrenmek için geliştirilmiş bir **Flutter mobil uygulamasıdır**. Bu proje **Vibe Coding** (AI destekli kodlama) ile geliştirilmiştir ve **kodlama bilgisi olmadan** tamamlanmıştır.

---

## 🎯 Proje Hedefi

YDS sınavına hazırlananlar ve İngilizce kelime çalışanlar için:
- Araştırılmış tekrar sistemi (Spaced Repetition - SRS)
- Kategoriye göre kelime çalışması
- Quiz modu
- Günlük seri takibi (streak)

---

## 🏗️ Mimari Yapı

### Teknoloji Stack
- **Framework:** Flutter (Dart)
- **Platformlar:** Android, iOS, Web, Windows
- **Flutter Versiyonu:** 3.38.6 (Stable)
- **Dart SDK:** ^3.10.7

### Ana Paketler
```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.3.4    # Local storage
  path_provider: ^2.1.5          # Dosya sistemi erişimi
  flutter_animate: ^4.5.2        # Animasyonlar
  confetti: ^0.8.0               # Kutlama efektleri
  flutter_tts: ^3.8.3            # Text-to-Speech
```

---

## 📁 Proje Yapısı

```
lib/
├── main.dart                    # Uygulama giriş noktası
├── constants/
│   └── app_constants.dart       # Uygulama sabitleri
├── core/
│   ├── result.dart              # Result type (Success/Failure)
│   └── responsive.dart          # Responsive tasarım yardımcıları
├── models/
│   ├── card.dart                # VocabularyCard modeli
│   └── category.dart            # CategoryData modeli
├── data/
│   └── card_loader.dart         # JSON kart yükleme
├── repositories/
│   └── card_repository.dart     # Kart verisi erişim katmanı
├── services/
│   ├── srs_service.dart         # SM-2 algoritması (tekrar sistemi)
│   ├── progress_service.dart    # İlerleme kaydetme
│   ├── streak_service.dart      # Günlük seri takibi
│   ├── tts_service.dart         # Text-to-speech
│   └── study_controller.dart    # Çalışma session yönetimi
├── screens/
│   ├── home_screen.dart         # Ana ekran
│   ├── review_screen.dart       # Kelime çalışma ekranı
│   ├── quiz_screen.dart         # Quiz ekranı
│   ├── profile_screen.dart      # Profil ekranı
│   └── main_navigation.dart     # Bottom navigation
└── widgets/
    ├── category_card.dart       # Kategori kartı widget
    └── review/                  # Çalışma widget'ları
        ├── review_card_front.dart
        ├── review_card_back.dart
        ├── rating_buttons.dart
        ├── review_stats_bar.dart
        └── empty_review_state.dart
```

---

## 🎓 Özellikler

### 1. Spaced Repetition System (SRS)
- **SM-2 Algoritması** kullanılarak optimize edilmiş tekrar sistemi
- Kullanıcı kartları 4 şekilde değerlendirebilir:
  - **Again** → Kartı başa al
  - **Struggled** → Kısa aralık
  - **Good** → Normal ilerleme
  - **Easy** → Uzun aralık

### 2. Kelime Kategorileri
| Kategori | Açıklama |
|----------|----------|
| Fiiller (verb) | Eylem kelimeleri |
| İsimler (noun) | Varlık kelimeleri |
| Sıfatlar (adj) | Nitelendirici kelimeler |
| Zarflar (adv) | Zarf kelimeleri |
| Phrasal Verbs | Fiil tamlamaları |
| Bağlaçlar (conjunction) | Bağlaç kelimeleri |
| Tümü | Tüm kartlar |

### 3. Quiz Modu
- Çoktan seçmeli sorular
- Yanlış cevaplar görüntüleniyor
- Quiz havuzu öncelik sistemi

### 4. Günlük Seri (Streak)
- Her gün çalışanlar için seri takibi
- Motivasyon için görsel geri bildirim

---

## 💾 Veri Yönetimi

### Kart Verisi
- **Kaynak:** `assets/cards.json` (statik veri)
- **Format:** JSON
- **İçerik:** 610+ akademik kelime kartı

### İlerleme Verisi
- **Kaynak:** Local dosya sistemi
- **Konum:** `progress.json`
- **İçerik:** Kullanıcı'nın SRS ilerlemesi
- **Yedekleme:** Atomic writes + backup recovery

---

## 🎨 UI/UX

### Responsive Tasarım
- Compact (mobil)
- Medium (tablet)
- Expanded (desktop)

### Tema
- **Renk:** Deep Purple
- **Stil:** Material 3
- **Animasyon:** flutter_animate paketi

---

## 🚀 Çalıştırmak İçin

```bash
# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run

# Build (Android)
flutter build apk

# Build (Web)
flutter build web
```

---

## 👨‍💻 Geliştirici Notu

**ÖNEMLİ:** Bu proje **Vibe Coding** (AI ile kodlama) kullanılarak geliştirilmiştir. Ben klasik anlamda kod yazmayı **bilmiyorum**. Bu nedenle:

1. **Basit tutun:** Karmaşık mimari değişiklikleri açıklamadan yapmayın
2. **Adım adım ilerleyin:** Her değişikliği neden yaptığınızı açıklayın
3. **Flutter standartlarına sadık kalın:** Projede var olan pattern'lere uyun
4. **Test edin:** Yaptığınız değişikliklerin çalıştığından emin olun

### Kodlama Tarzı
- State management: StatefulWidget + ChangeNotifier
- Dependeny Injection: Direkt nesne oluşturma (basit)
- Error handling: Result type (Success/Failure)
- Responsive: ResponsiveCenter widget'ı

---

## 📝 TODO / Gelecek Özellikler

- [ ] Kelime ekleme/editleme
- [ ] İstatistik sayfası
- [ ] Sesli telaffuz kaydetme
- [ ] Bulut senkronizasyonu
- [ ] Widget desteği

---

## 📞 İletişim

Bu proje AI ile geliştirilmiştir. Kodlama sorularınız için lütfen adım adım açıklayın.

---

*Son güncelleme: Şubat 2026*
