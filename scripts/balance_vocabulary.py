#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Vocabulary Distribution Analysis & Balancing Script
Analyzes all JSON files in assets/ and generates new cards for under-represented categories.
"""

import json
import sys
from pathlib import Path
from collections import Counter
import uuid

# Fix Windows console encoding
if sys.platform == "win32":
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

# Paths
PROJECT_ROOT = Path(__file__).parent.parent
ASSETS_DIR = PROJECT_ROOT / "assets"
MAIN_CARDS_FILE = ASSETS_DIR / "cards.json"

# Category mappings for POS normalization
POS_MAPPINGS = {
    "noun": ["noun"],
    "verb": ["verb"],
    "adjective": ["adj", "adjective"],
    "adverb": ["adv", "adverb"],
    "phrasal_verb": ["phrasal_verb", "phrasal verbs"],
    "conjunction": ["conjunction", "conj"],
    "phrase": ["phrase", "phrases"],
}

def normalize_pos(pos):
    """Normalize POS tags to standard categories."""
    pos_lower = pos.lower().strip()
    for standard, variants in POS_MAPPINGS.items():
        if pos_lower in [v.lower() for v in variants]:
            return standard
    return pos_lower


def load_all_json_files():
    """Load all JSON files from assets directory."""
    all_cards = []
    json_files = list(ASSETS_DIR.glob("**/*.json"))

    for json_file in json_files:
        try:
            with open(json_file, "r", encoding="utf-8") as f:
                data = json.load(f)
                if isinstance(data, list):
                    all_cards.extend(data)
        except Exception as e:
            print(f"Error loading {json_file}: {e}")

    return all_cards


def analyze_distribution(cards):
    """Analyze card distribution by POS."""
    pos_counts = Counter()

    for card in cards:
        # Handle both 'pos' and 'multiWord' key variations
        pos = card.get("pos") or card.get("multiWord", "")
        if pos:
            normalized = normalize_pos(str(pos))
            pos_counts[normalized] += 1

    return pos_counts


def create_card_template(lemma, pos, meanings, synonyms, example_text, example_translation):
    """Create a card with the standard JSON structure."""
    cloze_template = example_text.replace(lemma, "{{cloze}}")
    # Handle multi-word replacements
    if "{{cloze}}" not in cloze_template:
        # Try to find and replace the first occurrence
        words = lemma.split()
        if len(words) > 1:
            for word in words:
                if word in cloze_template:
                    cloze_template = cloze_template.replace(word, "{{cloze}}", 1)
                    break

    return {
        "id": str(uuid.uuid4()),
        "lemma": lemma,
        "pos": pos,
        "multiWord": len(lemma.split()) > 1,
        "meanings": meanings if isinstance(meanings, list) else [meanings],
        "synonyms": synonyms if isinstance(synonyms, list) else [synonyms],
        "example": {
            "text": example_text,
            "translation": example_translation
        },
        "cloze": {
            "template": cloze_template,
            "answer": lemma
        },
        "easeFactor": 2.5,
        "intervalDays": 0,
        "dueDate": "2026-02-16T00:00:00.000000",
        "repetitions": 0,
        "lastReviewed": None
    }


# NEW VOCABULARY CARDS FOR UNDER-REPRESENTED CATEGORIES
NEW_CARDS = {
    "conjunction": [
        ("after all", "her şeye rağmen, ne de olsa", ["nevertheless", "despite everything"],
         "Don't blame him; after all, he is just a child.", "Onu suçlama; ne de olsa o sadece bir çocuk."),
        ("as a result", "sonuç olarak", ["consequently", "therefore"],
         "It rained heavily; as a result, the match was cancelled.", "Şiddetli yağmur yağdı; sonuç olarak maç iptal edildi."),
        ("as long as", "olduğu sürece", ["provided that", "on condition that"],
         "You can stay as long as you follow the rules.", "Kurallara uyduğu sürece kalabilirsin."),
        ("as soon as", "... ... antmadan", ["immediately when", "once"],
         "Call me as soon as you arrive at the hotel.", "Otele vardığın anda beni ara."),
        ("as though", "sanki, -mış gibi", ["as if", "seeming like"],
         "He acted as though nothing had happened.", "Hiçbir şey olmamış gibi davrandı."),
        ("assuming that", "farz edelim ki", ["supposing that", "if"],
         "Assuming that the weather is good, we'll have a picnic.", "Hava iyi olduğunu varsayarsak, piknik yapacağız."),
        ("at the same time", "aynı zamanda", ["simultaneously", "meanwhile"],
         "The book is entertaining; at the same time, it is educational.", "Kitap eğlenceli; aynı zamanda eğitici."),
        ("because of", "dığı için", ["due to", "owing to"],
         "We canceled the trip because of the bad weather.", "Kötü hava nedeniyle seyahati iptal ettik."),
        ("before", "önce", ["until", "by the time"],
         "Finish your homework before you go out to play.", "Dışarı çıkmadan önce ödevini bitir."),
        ("both... and", "hem ... hem de", ["as well as", "and also"],
         "She speaks both English and French fluently.", "Hem İngilizce hem de Fransızca'yı akıcı konuşur."),
        ("but rather", "bilakis, aksine", ["instead", "on the contrary"],
         "He is not sad but rather relieved that it's over.", "O üzgün değil, aksine bittiği için rahatlamış."),
        ("by the time", "olduğunda", ["when", "at the time that"],
         "By the time we arrived, the party had ended.", "Varacağımızda parti sona ermişti."),
        ("even though", "rağmen", ["although", "despite the fact that"],
         "Even though it was raining, we went for a walk.", "Yağmur yağmasına rağmen yürüyüşe çıktık."),
        ("except that", "dışında", ["but", "only"],
         "I would go except that I have no money.", "Param olmadığı dışına giderdim."),
        ("far from", "uzak, hiç de - değil", ["anything but", "not at all"],
         "Far from being angry, she was actually amused.", "O kızgın değil, aksine eğlenmişti."),
        ("for fear that", "den korkusuyla", ["lest", "in case"],
         "She spoke quietly for fear that someone might hear.", "Biri duyabilir korkusuyla sessizce konuştu."),
        ("for the sake of", "dan ötürü, -in hatırına", ["for the benefit of", "in honor of"],
         "For the sake of our friendship, let's forget this argument.", "Dostluğumuzun hatırına, bu tartışmayı unutalım."),
        ("given that", "dığı göz önüne alındığında", ["considering that", "since"],
         "Given that he's young, he has a promising future ahead.", "O genç olduğu göz önüne alındığında, önünde parlak bir gelecek var."),
        ("granting that", "kabul edelim ki", ["even if", "assuming"],
         "Granting that you are right, we still need more evidence.", "Haklı olduğunu kabul edelim, yine de daha fazla kanıta ihtiyacımız var."),
        ("if only", "keşke", ["I wish that", "hopefully"],
         "If only I had known about the traffic, I would have left earlier.", "Keşke trafiği bilseydim, daha erken çıkarardım."),
        ("in case", "durumunda", ["in the event that", "if"],
         "Take an umbrella in case it rains.", "Yağmur yağma ihtimaline karşı şemsiye al."),
        ("in order that", "olsun diye", ["so that", "in order to"],
         "He left early in order that he might catch the train.", "Treni yakalayabilsin diye erken çıktı."),
        ("in the event that", "durumunda", ["in case", "should"],
         "In the event that the fire alarm rings, leave the building.", "Yangın alarmı çalarsa binayı terk et."),
        ("just as", "tam ... iken", ["just as", "exactly when"],
         "Just as I was leaving, the phone rang.", "Tam çıkıyordum ki telefon çaldı."),
        ("lest", "den korkusuyla, -mesin diye", ["for fear that", "in order to avoid"],
         "He whispered lest anyone should hear.", "Biri duymasın diye fısıldadı."),
        ("no matter", "fark etmez", ["regardless of", "whatever"],
         "No matter how hard you try, you can't please everyone.", "Ne kadar çok çalışırsan çalış, herkesi memnun edemezsin."),
        ("now that", "şimdi ki", ["since", "given that"],
         "Now that you're here, we can start the meeting.", "Şimdi burada olduğuna göre toplantıya başlayabiliriz."),
        ("on condition that", "şartıyla", ["provided that", "if"],
         "You may borrow the car on condition that you return it by midnight.", "Gece yarısına kadar geri getirmek şartıyla arabayı ödünç alabilirsin."),
        ("once", "bir kez ... dığında", ["as soon as", "when"],
         "Once you understand the concept, it becomes easy.", "Kavramı bir kez anladığında, kolaylaşır."),
        ("only if", "sadece ... ise", ["only when", "on condition that"],
         "I will help you only if you promise to study hard.", "Sadece sıkı çalışacağına söz verirsen sana yardım edeceğim."),
        ("or else", "yoksa", ["otherwise", "or"],
         "Hurry up, or else we'll be late.", "Acele et, yoksa geç kalacağız."),
        ("provided that", "şartıyla", ["on condition that", "if"],
         "You can go provided that you finish your homework.", "Ödevini bitirmek şartıyla gidebilirsin."),
        ("seeing that", "dığı için", ["considering that", "since"],
         "Seeing that it's late, we should go home.", "Geç olduğu için eve gitmeliyiz."),
        ("so that", "olsun diye", ["in order that", "in order to"],
         "I studied hard so that I could pass the exam.", "Sınavı geçebileyim diye çok çalıştım."),
        ("supposing", "farz edelim ki", ["assuming that", "if"],
         "Supposing you lost your job, what would you do?", "İşini kaybetseydin ne yapardın?"),
        ("than", "den", ["compared to"],
         "She is taller than her brother.", "O kardeşinden daha uzun."),
        ("that", "ki", ["which", "who"],
         "The book that I read was very interesting.", "Okuduğum kitap çok ilginçti."),
        ("though", "rağmen", ["although", "however"],
         "Though he is young, he is very wise.", "Genç olmasına rağmen çok bilge."),
        ("till", "kadar", ["until"],
         "Wait here till I come back.", "Gelene kadar burada bekle."),
        ("unless", "medikçe", ["if not", "except if"],
         "You won't succeed unless you work hard.", "Sıkı çalışmazsan başarılı olamazsın."),
        ("until", "kadar", ["till", "up to the time"],
         "Keep going until you reach the finish line.", "Bitiş çizgisine kadar gitmeye devam et."),
        ("when", "ken/dığında", ["at the time that", "while"],
         "I was cooking when he arrived.", "O geldiğinde yemek yapıyordum."),
        ("whenever", "her zaman", ["every time that", "no matter when"],
         "Whenever I visit, she bakes cookies.", "Her ziyaret ettiğimde kurabiye yapar."),
        ("where", "nerede", ["in which", "at which"],
         "This is the cafe where we first met.", "Tanıştığımız kafe bu."),
        ("whereas", "oysa, halbuki", ["while", "on the contrary"],
         "He loves sports whereas his brother prefers reading.", "O sporu sever, oysa kardeşi kitap okumayı tercih eder."),
        ("whether", "olup olmadığı", ["if", "either"],
         "I don't know whether he will come.", "Onun gelip gelmeyeceğini bilmiyorum."),
        ("while", "iken", ["whereas", "during the time that"],
         "While I was working, he was sleeping.", "Ben çalışırken o uyuyordu."),
    ],

    "phrase": [
        ("a bit", "biraz", ["a little", "slightly"],
         "I'm a bit tired today.", "Bugün biraz yorgunum."),
        ("a couple of", "birkaç", ["a few", "two or three"],
         "I'll be there in a couple of minutes.", "Birkaç dakika içinde orada olacağım."),
        ("a great deal of", "çok miktarda", ["a lot of", "much"],
         "We have a great deal of work to do.", "Yapacak çok işimiz var."),
        ("a lot of", "çok", ["many", "much"],
         "There are a lot of people waiting.", "Bekleyen çok insan var."),
        ("according to", "göre", ["as stated by", "in accordance with"],
         "According to the news, it will rain tomorrow.", "Haberlere göre yarın yağmur yağacak."),
        ("ahead of", "önünde", ["before", "in front of"],
         "He finished ahead of schedule.", "Programdan önce bitirdi."),
        ("all of a sudden", "ani bir şekilde", ["suddenly", "unexpectedly"],
         "All of a sudden, the lights went out.", "Birdenbire ışıklar söndü."),
        ("all right", "tamam", ["okay", "alright"],
         "Is everything all right?", "Her şey tamam mı?"),
        ("as for", "geldiginde", ["regarding", "concerning"],
         "As for me, I'll stay here.", "Ben gelince, burada kalacağım."),
        ("as well", "de, ayrıca", ["also", "too"],
         "She speaks French and Spanish as well.", "O Fransızca ve İspanyolca da konuşuyor."),
        ("as well as", "hem ... hem de", ["and also", "in addition to"],
         "She plays the piano as well as the guitar.", "Hem piyano hem gitar çalıyor."),
        ("at first", "başlangıçta", ["initially", "in the beginning"],
         "At first, I didn't like him.", "Başlangıçta onu sevmedim."),
        ("at last", "sonunda", ["finally", "eventually"],
         "We arrived at last.", "Sonunda vardık."),
        ("at least", "en azından", ["minimum", "no less than"],
         "It will take at least two hours.", "En az iki saat sürecek."),
        ("at once", "hemen", ["immediately", "right away"],
         "Come here at once!", "Buraya hemen gel!"),
        ("at present", "şu anda", ["currently", "now"],
         "I'm busy at present.", "Şu anda meşgulüm."),
        ("at the moment", "şu anda", ["right now", "currently"],
         "I'm not at the moment.", "Şu anda yokum."),
        ("back and forth", "ileri geri", ["to and fro"],
         "The pendulum swings back and forth.", "Sarkaç ileri geri sallanır."),
        ("because of", "dığı için", ["due to", "owing to"],
         "We cancelled because of the rain.", "Yağmur nedeniyle iptal ettik."),
        ("by far", "büyük ölçüde", ["by a great amount"],
         "This is by far the best option.", "Bu büyük ölçüde en iyi seçenek."),
        ("by means of", "yoluyla", ["through", "using"],
         "He achieved success by means of hard work.", "Sıkı çalışma yoluyla başarıya ulaştı."),
        ("by no means", "hiçbir şekilde", ["not at all", "certainly not"],
         "This is by no means certain.", "Bu hiçbir şekilde kesin değil."),
        ("by the way", "neyse", ["incidentally", "speaking of which"],
         "By the way, did you lock the door?", "Bu arada, kapıyı kilitledin mi?"),
        ("even so", "böyle olsa bile", ["nevertheless", "even though"],
         "It was raining; even so, we went out.", "Yağmur yağıyordu; yine de dışarı çıktık."),
        ("for good", "sonsuza kadar", ["permanently", "forever"],
         "He's leaving for good.", "O sonsuza kadar gidiyor."),
        ("from now on", "bundan sonra", ["from this point forward"],
         "From now on, I'll be more careful.", "Bundan sonra daha dikkatli olacağım."),
        ("from time to time", "bazen", ["occasionally", "sometimes"],
         "We meet from time to time.", "Bazen buluşuyoruz."),
        ("in addition", "buna ek olarak", ["additionally", "also"],
         "In addition, we need more supplies.", "Buna ek olarak, daha fazla malzemeye ihtiyacımız var."),
        ("in case of", "durumunda", ["in the event of"],
         "In case of emergency, call 112.", "Acil durumunda 112'yi ara."),
        ("in common", "ortak", ["shared", "joint"],
         "They have a lot in common.", "Çok ortak noktaları var."),
        ("in conclusion", "sonuç olarak", ["to sum up", "finally"],
         "In conclusion, I'd like to thank everyone.", "Sonuç olarak, herkese teşekkür etmek istiyorum."),
        ("in detail", "detaylı olarak", ["thoroughly", "carefully"],
         "Please explain this in detail.", "Lütfen bunu detaylı açıkla."),
        ("in fact", "aslında", ["actually", "really"],
         "In fact, I knew about it.", "Aslında bundan haberdardım."),
        ("in favor of", "lehinde", ["supporting", "in support of"],
         "The committee voted in favor of the proposal.", "Komite öneri lehinde oy kullandı."),
        ("in general", "genel olarak", ["generally", "usually"],
         "In general, people are kind.", "Genel olarak insanlar naziktir."),
        ("in my opinion", "benim fikrime göre", ["I think", "in my view"],
         "In my opinion, this is wrong.", "Benim fikrime göre bu yanlış."),
        ("in order to", "mak için", ["to", "so as to"],
         "We study in order to learn.", "Öğrenmek için çalışırız."),
        ("in other words", "başka bir deyişle", ["to put it differently"],
         "In other words, we need more time.", "Başka bir deyişle, daha fazla zamana ihtiyacımız var."),
        ("in particular", "özellikle", ["especially", "specifically"],
         "I enjoyed the last song in particular.", "Son şarkıyı özellikle sevdim."),
        ("in reality", "gerçekte", ["in fact", "actually"],
         "In reality, things are different.", "Gerçekte işler farklı."),
        ("in return", "karşılığında", ["in exchange"],
         "I gave him a gift in return.", "Buna karşılık ona bir hediye verdim."),
        ("in short", "kısacası", ["briefly", "to sum up"],
         "In short, we need help.", "Kısacası yardıma ihtiyacımız var."),
        ("in spite of", "rağmen", ["despite", "notwithstanding"],
         "In spite of the rain, we went out.", "Yağmura rağmen dışarı çıktık."),
        ("in the end", "sonunda", ["finally", "eventually"],
         "In the end, everything worked out.", "Sonunda her şey yoluna girdi."),
        ("in the meantime", "bu arada", ["meanwhile", "in the interim"],
         "In the meantime, I'll prepare dinner.", "Bu arada ben akşam yemeğini hazırlayacağım."),
        ("in touch", "iletişimde", ["in contact"],
         "Let's keep in touch.", "İletişimde kalmaya devam edelim."),
        ("instead of", "yerine", ["rather than", "in place of"],
         "Let's walk instead of driving.", "Yürüyelim de arabayla yerine."),
        ("on behalf of", "adına", ["for", "representing"],
         "I accept this award on behalf of my team.", "Bu ödülü ekibim adına kabul ediyorum."),
        ("on purpose", "kasten", ["intentionally", "deliberately"],
         "He did it on purpose.", "O bunu kasten yaptı."),
        ("on the contrary", "aksine", ["on the other hand", "conversely"],
         "On the contrary, I agree with you.", "Aksine, seninle aynı fikirdeyim."),
        ("on the other hand", "diğer yandan", ["however", "alternatively"],
         "On the other hand, it's expensive.", "Diğer yandan, bu pahalı."),
        ("out of order", "arızalı", ["not working", "broken"],
         "The machine is out of order.", "Makine arızalı."),
        ("out of stock", "stokta yok", ["unavailable", "sold out"],
         "Sorry, this item is out of stock.", "Üzgünüm, bu ürün stokta yok."),
        ("right away", "hemen", ["immediately", "at once"],
         "I'll do it right away.", "Bunu hemen yapacağım."),
        ("so far", "şimdiye kadar", ["until now", "thus far"],
         "So far, so good.", "Şimdiye kadar her şey iyi."),
        ("sooner or later", "erken geç", ["eventually", "inevitably"],
         "Sooner or later, you'll understand.", "Erken geç, anlayacaksın."),
        ("to some extent", "bir dereceye kadar", ["partially", "somewhat"],
         "I agree to some extent.", "Bir dereceye kadar katılıyorum."),
        ("up to date", "güncel", ["current", "modern"],
         "Keep your software up to date.", "Yazılımınızı güncel tutun."),
        ("with regard to", "göre", ["regarding", "concerning"],
         "With regard to your request, we'll consider it.", "İsteğinle ilgili olarak, bunu değerlendireceğiz."),
        ("with respect to", "göre", ["regarding", "in relation to"],
         "With respect to quality, this product is excellent.", "Kalite açısından, bu ürün mükemmel."),
        ("without delay", "gecikmeden", ["immediately", "without delay"],
         "Please leave without delay.", "Lütfen gecikmeden ayrılın."),
        ("worth while", "değer", ["worthwhile", "worth doing"],
         "It's worth while visiting this museum.", "Bu müzeyi ziyaret etmek değer."),
    ],

    "phrasal_verb": [
        ("account for", "oluşturmak, açıklamak", ["explain", "constitute"],
         "Oil exports account for 80% of the country's revenue.", "Petrol ihracatı ülke gelirinin %80'ini oluşturur."),
        ("act on", "göre hareket etmek", ["take action on", "follow"],
         "We must act on his advice immediately.", "Onun tavsiyesine göre hemen hareket etmeliyiz."),
        ("add up", "toplamak", ["calculate", "sum"],
         "Add up these numbers for me.", "Bu sayıları benim için topla."),
        ("add up to", "toplamı ... olmak", ["total", "amount to"],
         "The expenses add up to more than expected.", "Giderler beklenenden fazla toplamına ulaşıyor."),
        ("answer for", "sorumlu tutulmak", ["be responsible for"],
         "You'll have to answer for your actions.", "Eylemlerinden sorumlu tutulacaksın."),
        ("ask around", "etrafında sormak", ["inquire", "ask many people"],
         "I'll ask around and see if anyone knows.", "Etrafı sorup birinin bilip bilmediğine bakacağım."),
        ("back away", "geri çekilmek", ["retreat", "withdraw"],
         "The dog backed away when I approached.", "Yaklaştığımda köpek geri çekildi."),
        ("back down", "vazgeçmek", ["withdraw", "retreat"],
         "He refused to back down from his position.", "Konumundan vazgeçmeyi reddetti."),
        ("back up", "desteklemek, yedeklemek", ["support", "reverse"],
         "Can you back up your claims with evidence?", "İddialarını kanıtlarla destekleyebilir misin?"),
        ("bear out", "doğrulamak", ["confirm", "verify"],
         "The evidence bears out his testimony.", "Kanıtlar onun ifadesini doğruluyor."),
        ("blow up", "patlamak", ["explode", "erupt"],
         "The balloon blew up suddenly.", "Balon aniden patladı."),
        ("boil down to", "indirgenmek", ["reduce to", "come down to"],
         "The problem boils down to lack of communication.", "Sorun iletişim eksikliğine indirgeniyor."),
        ("break down", "bozulmak", ["stop working", "collapse"],
         "My car broke down on the highway.", "Arabam otoyolda bozuldu."),
        ("break in", "girmek, alıştırmak", ["enter forcibly", "train"],
         "Someone broke in while we were away.", "Biz yokken biri girmiş."),
        ("break into", "girmek", ["enter forcibly", "burst into"],
         "Thieves broke into the store last night.", "Hırsızlar geçen shopa girdiler."),
        ("break out", "patlak vermek", ["escape", "start suddenly"],
         "Fire broke out in the building.", "Binada yangın patlak verdi."),
        ("break through", "kırmak, aşmak", ["penetrate", "overcome"],
         "The sun finally broke through the clouds.", "Güneş sonunda bulutları aştı."),
        ("bring about", "neden olmak", ["cause", "lead to"],
         "The new policy brought about changes.", "Yeni politika değişikliklere neden oldu."),
        ("bring around", "ikna etmek", ["persuade", "convince"],
         "I'll bring him around to our way of thinking.", "Onu düşünce tarzımıza ikna edeceğim."),
        ("bring back", "getirmek", ["return", "restore"],
         "This song brings back memories.", "Bu şarkı anıları geri getiriyor."),
        ("bring down", "düşürmek", ["reduce", "cause to fall"],
         "We need to bring down costs.", "Maliyetleri düşürmemiz gerekiyor."),
        ("bring forward", "ileri almak", ["postpone", "move to earlier"],
         "The meeting was brought forward to Monday.", "Toplantı Pazartesi'ye alındı."),
        ("bring up", "gündeme getirmek", ["raise", "mention"],
         "She brought up an important point.", "O önemli bir noktayı gündeme getirdi."),
        ("brush aside", "önemsizmek", ["dismiss", "ignore"],
         "He brushed aside my concerns.", "Endişelerimi görmezden geldi."),
        ("build up", "biriktirmek", ["accumulate", "develop"],
         "Tension built up between them.", "Aralarında gerilim birikti."),
        ("burn down", "yıkmak", ["destroy by fire"],
         "The factory burned down last night.", "Fabrika gece yandı."),
        ("burn out", "tükenmek", ["exhaust", "stop working"],
         "He burned out from overwork.", "O çok çalışmaktan tükenmişti."),
        ("burst out", "patlamak", ["break out", "suddenly exclaim"],
         "She burst out laughing.", "O kahkaha patlattı."),
        ("buy out", "satın almak", ["purchase", "acquire"],
         "The company bought out its competitor.", "Şirket rakibini satın aldı."),
        ("call for", "gerektirmek", ["require", "demand"],
         "This situation calls for immediate action.", "Bu durum acil eylem gerektiriyor."),
        ("call off", "iptal etmek", ["cancel", "abort"],
         "They called off the event.", "Etkinliği iptal ettiler."),
        ("call on", "ziyaret etmek", ["visit", "appeal to"],
         "I'll call on you tomorrow.", "Yarın seni ziyaret edeceğim."),
        ("calm down", "sakinleşmek", ["become calm", "relax"],
         "Please calm down and tell me what happened.", "Lütfen sakinleş ve bana ne olduğunu anlat."),
        ("carry on", "devam etmek", ["continue", "proceed"],
         "Let's carry on with our work.", "Çalışmamızla devam edelim."),
        ("carry out", "gerçekleştirmek", ["execute", "perform"],
         "The plan was carried out successfully.", "Plan başarıyla gerçekleştirildi."),
        ("catch on", "popüler olmak", ["become popular", "understand"],
         "The new song caught on quickly.", "Yeni şarkı hızla popüler oldu."),
        ("check in", "giriş yapmak", ["register", "arrive"],
         "We need to check in at the hotel.", "Otelde giriş yapmamız gerekiyor."),
        ("check out", "çıkış yapmak", ["pay and leave", "examine"],
         "We have to check out by noon.", "Öğleye kadar çıkış yapmamız gerekiyor."),
        ("cheer up", "neşelenmek", ["become happy", "encourage"],
         "Cheer up! It's not that bad.", "Neşelen! O kadar da kötü değil."),
        ("clear up", "açıklığa kavuşturmak", ["clarify", "clean"],
         "Let me clear up this misunderstanding.", "Bu yanlış anlaşılmayı açıklığa kavuşturayım."),
        ("come across", "rastlamak", ["find", "encounter"],
         "I came across an old photo.", "Eski bir fotoğrafa rastladım."),
        ("come down", "düşmek", ["descend", "fall"],
         "The price came down significantly.", "Fiyat önemli ölçüde düştü."),
        ("come forward", "ön plana çıkmak", ["volunteer", "step forward"],
         "No one came forward with information.", "Kimse bilgiyle ön plana çıkmadı."),
        ("come up with", "bulmak", ["produce", "suggest"],
         "She came up with a great idea.", "Harika bir fikir buldu."),
        ("cross out", "çizmek", ["eliminate", "remove"],
         "Cross out the wrong answers.", "Yanlış cevapları çiz."),
        ("cut down", "kısmak", ["reduce", "decrease"],
         "You should cut down on sugar.", "Şekerı azaltmalısın."),
        ("cut off", "kesmek", ["disconnect", "sever"],
         "The phone line was cut off.", "Telefon hattı kesildi."),
        ("do away with", "kaldırmak", ["abolish", "eliminate"],
         "We should do away with these rules.", "Bu kuralları kaldırmalıyız."),
        ("do without", "olmaksızın yapmak", ["manage without"],
         "We'll have to do without a car.", "Arabasız yapmamız gerekecek."),
        ("draw up", "hazırlamak", ["prepare", "draft"],
         "Let's draw up a contract.", "Sözleşme hazırlayalım."),
        ("drop off", "bırakmak", ["deliver", "fall asleep"],
         "I can drop you off at the station.", "Seni istasyona bırakabilirim."),
        ("end up", "sonunda olmak", ["finally become", "result"],
         "We ended up going home early.", "Erken eve döndük."),
        ("face up to", "yüzleşmek", ["confront", "accept"],
         "You must face up to reality.", "Gerçekle yüzleşmelisin."),
        ("fall apart", "parçalanmak", ["break", "disintegrate"],
         "The old book fell apart.", "Eski kitap parçalandı."),
        ("fall back on", "güvenmek", ["rely on", "turn to"],
         "I have savings to fall back on.", "Güvenebileceğim birikimlerim var."),
        ("fall behind", "geride kalmak", ["lag", "fail to keep up"],
         "Don't fall behind in your studies.", "Çalışmalarında geride kalma."),
        ("fall through", "başarısız olmak", ["fail", "collapse"],
         "The deal fell through.", "Anlaşma başarısız oldu."),
        ("figure out", "çözmek", ["solve", "understand"],
         "I can't figure out this problem.", "Bu sorunu çözemiyorum."),
        ("fill in", "doldurmak", ["complete", "inform"],
         "Please fill in this form.", "Lütfen bu formu doldurun."),
        ("find out", "öğrenmek", ["discover", "learn"],
         "I'll find out the truth.", "Gerçeği öğreneceğim."),
        ("fit in", "uygun olmak", ["be suitable", "have time for"],
         "I can fit in a meeting tomorrow.", "Yarına bir toplantı sığdırabilirim."),
        ("focus on", "odaklanmak", ["concentrate on"],
         "Let's focus on the main issue.", "Ana soruna odaklanalım."),
        ("get along", "iyi geçinmek", ["have a good relationship"],
         "We get along well with our neighbors.", "Komşularımızla iyi geçiniyoruz."),
        ("get away", "kaçmak", ["escape", "leave"],
         "We need to get away for the weekend.", "Hafta sonu kaçmamız gerekiyor."),
        ("get by", "idare etmek", ["manage", "survive"],
         "We can get by with less money.", "Daha az parayla idare edebiliriz."),
        ("get over", "üstesinden gelmek", ["recover from", "overcome"],
         "She got over the illness quickly.", "Hastalığın üstesinden hızla geldi."),
        ("get through", "bitirmek", ["complete", "finish"],
         "We got through the work early.", "İşi erken bitirdik."),
        ("give away", "dağıtmak", ["donate", "reveal"],
         "They gave away free samples.", "Ücretsiz numuneler dağıttılar."),
        ("give up", "vazgeçmek", ["quit", "surrender"],
         "Don't give up on your dreams.", "Hayallerinden vazgeçme."),
        ("go after", "peşinden gitmek", ["pursue", "chase"],
         "Go after your goals.", "Hedeflerinin peşinden git."),
        ("go against", "karşı çıkmak", ["oppose", "be contrary to"],
         "This goes against my principles.", "Bu ilkelerime aykırı."),
        ("go ahead", "devam et", ["proceed", "begin"],
         "Go ahead with your plan.", "Planınla devam et."),
        ("go back", "geri dönmek", ["return", "go back to"],
         "I need to go home.", "Eve dönmem gerekiyor."),
        ("go on", "devam etmek", ["continue", "proceed"],
         "Let's go on with the meeting.", "Toplantıya devam edelim."),
        ("go out", "çıkmak", ["leave", "extinguish"],
         "The fire went out.", "Yangın söndü."),
        ("go through", "denemek", ["experience", "examine"],
         "We went through difficult times.", "Zor zamanlardan geçtik."),
        ("go with", "uygun olmak", ["match", "complement"],
         "This tie goes well with your shirt.", "Kravatın gömleğinle iyi gider."),
        ("grow up", "büyümek", ["mature", "become adult"],
         "Kids grow up so fast.", "Çocuklar çok hızlı büyüyor."),
        ("hand in", "teslim etmek", ["submit", "give"],
         "Hand in your homework tomorrow.", "Ödevini yarın teslim et."),
        ("hang up", "asmak", ["place on hook", "end call"],
         "Hang up your coat.", "Paltonu as."),
        ("hold on", "beklemek", ["wait", "grip"],
         "Hold on a moment.", "Bir dakika bekle."),
        ("hold up", "geciktirmek", ["delay", "rob"],
         "Traffic held us up.", "Trafik bizi geciktirdi."),
        ("join in", "katılmak", ["participate", "take part"],
         "Feel free to join in the discussion.", "Tartışmaya katılmaktan çekinmeyin."),
        ("keep on", "devam etmek", ["continue", "persist"],
         "Keep on trying!", "Denemeye devam et!"),
        ("keep up", "ayakta kalmak", ["maintain", "continue"],
         "Keep up the good work!", "İyi çalışmaya devam et!"),
        ("let down", "hayal kırıklığına uğratmak", ["disappoint", "fail"],
         "I won't let you down.", "Seni hayal kırıklığına uğratmayacağım."),
        ("look after", "bakmak", ["take care of"],
         "Can you look after my cat?", "Kedime bakabilir misin?"),
        ("look for", "aramak", ["search for", "seek"],
         "I'm looking for my keys.", "Anahtarlarımı arıyorum."),
        ("look forward to", "için beklemek", ["anticipate", "expect with pleasure"],
         "I look forward to seeing you.", "Seni görmek için bekliyorum."),
        ("look into", "incelemek", ["investigate", "examine"],
         "We'll look into the matter.", "Konuyu inceleyeceğiz."),
        ("look up", "bakmak", ["search for", "find"],
         "Look up this word in the dictionary.", "Bu kelimeyi sözlükte ara."),
        ("make out", "görmek", ["discern", "understand"],
         "I can't make out what he's saying.", "Ne söylediğini anlayamıyorum."),
        ("make up", "yapmak", ["invent", "reconcile"],
         "She made up a story.", "O bir hikaye uydurdu."),
        ("mix up", "karıştırmak", ["confuse", "mistake"],
         "Don't mix up the papers.", "Kağıtları karıştırma."),
        ("pass on", "ilet", ["transmit", "give"],
         "Please pass on this message.", "Lütfen bu mesajı ilet."),
        ("pick out", "seçmek", ["choose", "select"],
         "Pick out your favorite dress.", "Favori elbiseni seç."),
        ("point out", "göstermek", ["indicate", "draw attention to"],
         "Let me point out the error.", "Hatayı göstermeme izin ver."),
        ("pull through", "atlatmak", ["survive", "recover"],
         "She pulled through the crisis.", "Krizin üstesinden geldi."),
        ("put off", "ertelemek", ["postpone", "delay"],
         "Don't put off until tomorrow.", "Yarına ertelemeyin."),
        ("put on", "giymek", ["dress in", "activate"],
         "Put on your coat.", "Paltonu giy."),
        ("put out", "söndürmek", ["extinguish", "publish"],
         "Put out the cigarette.", "Sigarayı söndür."),
        ("put up with", "katlanmak", ["tolerate", "endure"],
         "I can't put up with this noise.", "Bu gürültüye katlanamam."),
        ("run into", "rastlamak", ["meet by chance", "encounter"],
         "I ran into an old friend.", "Eski bir arkadaşıma rastladım."),
        ("run out of", "bitmek", ["exhaust", "use up"],
         "We ran out of milk.", "Sütümüz bitti."),
        ("set up", "kurmak", ["establish", "arrange"],
         "Let's set up a meeting.", "Bir toplantı kuralım."),
        ("settle down", "yerleşmek", ["establish residence", "calm down"],
         "I want to settle down in a quiet place.", "Sessiz bir yerde yerleşmek istiyorum."),
        ("show off", "gösteriş yapmak", ["display", "boast"],
         "He likes to show off his wealth.", "Zenginliğini göstermeyi sever."),
        ("shut up", "susmak", ["be quiet", "close"],
         "Shut up and listen!", "Sus ve dinle!"),
        ("slow down", "yavaşlamak", ["decelerate", "reduce speed"],
         "Slow down, you're driving too fast!", "Yavaşla, çok hızlı sürüyorsun!"),
        ("stand for", "temsil etmek", ["represent", "mean"],
         "What does NATO stand for?", "NATO neyi temsil eder?"),
        ("stand out", "ön plana çıkmak", ["be noticeable", "excel"],
         "Her red hair makes her stand out.", "Kırmızı saçları onu öne çıkarıyor."),
        ("take after", "benzemek", ["resemble", "look like"],
         "She takes after her mother.", "O annesine benziyor."),
        ("take back", "geri almak", ["return", "retract"],
         "I take back what I said.", "Söylediklerimi geri alıyorum."),
        ("take down", "not etmek", ["write down", "demolish"],
         "Let me take down your information.", "Bilgilerini not edeyim."),
        ("take off", "kalkmak", ["depart", "remove"],
         "The plane took off on time.", "Uçak zamanında kalktı."),
        ("take over", "devralmak", ["assume control", "acquire"],
         "The new manager took over yesterday.", "Yeni müdür dün devraldı."),
        ("talk into", "ikna etmek", ["persuade"],
         "She talked me into joining the gym.", "Beni spor salonuna katılmaya ikna etti."),
        ("talk out of", "vazgeçirmek", ["dissuade"],
         "He talked me out of buying that car.", "Beni o arabayı almaktan vazgeçirdi."),
        ("tell off", "azarlamak", ["scold", "reprimand"],
         "The teacher told him off for being late.", "Öğretmen geç kaldığı için onu azarladı."),
        ("think over", "düşünmek", ["consider", "contemplate"],
         "I need time to think it over.", "Bunu düşünmek için zamana ihtiyacım var."),
        ("throw away", "atmak", ["discard", "dispose of"],
         "Don't throw away that opportunity.", "O fırsatı atma."),
        ("try on", "denemek", ["test clothing"],
         "Can I try on this dress?", "Bu elbiseyi deneyebilir miyim?"),
        ("turn down", "reddetmek", ["reject", "refuse"],
         "They turned down my offer.", "Teklifimi reddettiler."),
        ("turn into", "dönüşmek", ["become", "transform"],
         "The caterpillar turned into a butterfly.", "Tırtıl kelebeğe dönüştü."),
        ("turn off", "kapatmak", ["switch off", "stop"],
         "Turn off the lights.", "Işıkları kapat."),
        ("turn on", "açmak", ["switch on", "activate"],
         "Turn on the TV.", "Televizyonu aç."),
        ("use up", "tüketmek", ["consume completely", "exhaust"],
         "We used up all the supplies.", "Tüm malzemeleri tükettik."),
        ("watch out", "dikkat etmek", ["be careful", "look out"],
         "Watch out for the dog!", "Köpeğe dikkat et!"),
        ("wear off", "geçmek", ["diminish", "disappear"],
         "The pain will wear off soon.", "Ağrı yakında geçecek."),
        ("wear out", "yıpranmak", ["become unusable", "tire"],
         "These shoes are worn out.", "Bu ayakkabılar yıpranmış."),
        ("wind up", "sonuçlanmak", ["end", "finish"],
         "We wound up leaving early.", "Erken ayrıldık."),
        ("work out", "çalışmak", ["exercise", "solve"],
         "I work out at the gym.", "Spor salonunda çalışıyorum."),
        ("write down", "yazmak", ["record", "note"],
         "Write down this address.", "Bu adresi yaz."),
        ("write up", "yazmak", ["prepare a report"],
         "I need to write up the meeting notes.", "Toplantı notlarını yazmam gerekiyor."),
    ],
}


def main():
    print("=" * 60)
    print("VOCABULARY DISTRIBUTION ANALYSIS")
    print("=" * 60)

    # Load all cards
    print("\n Loading JSON files from assets/...")
    all_cards = load_all_json_files()
    print(f"   Total cards loaded: {len(all_cards)}")

    # Analyze distribution
    print("\n Analyzing distribution by POS...")
    pos_counts = analyze_distribution(all_cards)

    print("\n Current Distribution:")
    print("-" * 40)
    total_cards = sum(pos_counts.values())
    for pos, count in sorted(pos_counts.items(), key=lambda x: x[1], reverse=True):
        percentage = (count / total_cards * 100) if total_cards > 0 else 0
        print(f"   {pos:15}: {count:4d} cards ({percentage:5.1f}%)")

    # Calculate target (average)
    print("\n Calculating targets...")
    num_categories = len(pos_counts) or 1
    target_count = total_cards // num_categories if total_cards > 0 else 200
    print(f"   Target per category: ~{target_count}")

    # Identify gaps
    print("\n Identifying under-represented categories...")
    under_represented = []
    for pos, count in pos_counts.items():
        if count < target_count * 0.85:  # Below 85% of target
            gap = max(0, target_count - count)
            under_represented.append((pos, count, gap))
            print(f"   {pos:15}: {count:4d} (need ~{gap} more)")

    # Sort by gap size
    under_represented.sort(key=lambda x: x[2], reverse=True)

    # Generate new cards
    print("\n Generating new cards for under-represented categories...")
    new_cards = []
    for pos, current_count, gap in under_represented:
        if pos in NEW_CARDS:
            cards_to_add = min(len(NEW_CARDS[pos]), gap)
            print(f"   Adding {cards_to_add} cards for '{pos}'...")

            for lemma, meaning, synonyms, example_text, example_translation in NEW_CARDS[pos][:cards_to_add]:
                card = create_card_template(
                    lemma=lemma,
                    pos=pos,
                    meanings=meaning,
                    synonyms=synonyms,
                    example_text=example_text,
                    example_translation=example_translation
                )
                new_cards.append(card)

    if new_cards:
        print(f"\n   Generated {len(new_cards)} new cards total")

        # Read existing cards.json
        print(f"\n Reading existing cards from {MAIN_CARDS_FILE}...")
        try:
            with open(MAIN_CARDS_FILE, "r", encoding="utf-8") as f:
                existing_cards = json.load(f)
        except Exception as e:
            print(f"   Error reading file: {e}")
            existing_cards = []

        # Get the highest ID number for each POS to avoid conflicts
        max_ids = {}
        for card in existing_cards:
            card_id = card.get("id", "")
            if "_" in str(card_id):
                parts = str(card_id).rsplit("_", 1)
                if len(parts) == 2:
                    prefix, num = parts
                    try:
                        num = int(num)
                        if prefix not in max_ids or num > max_ids[prefix]:
                            max_ids[prefix] = num
                    except ValueError:
                        pass

        # Update new card IDs to avoid conflicts
        # Track next ID for each prefix
        next_ids = {}
        for prefix in max_ids:
            next_ids[prefix] = max_ids[prefix] + 1

        prefix_map = {
            "noun": "noun",
            "verb": "verb",
            "adjective": "adj",
            "adverb": "adv",
            "phrasal_verb": "pv",
            "conjunction": "conj",
            "phrase": "phrase"
        }

        for card in new_cards:
            pos = card["pos"]
            prefix = prefix_map.get(pos, "card")
            if prefix not in next_ids:
                next_ids[prefix] = 1
            card["id"] = f"{prefix}_{next_ids[prefix]:03d}"
            next_ids[prefix] += 1

        # Append new cards
        print(f"\n Appending new cards to {MAIN_CARDS_FILE}...")
        updated_cards = existing_cards + new_cards

        # Write back
        with open(MAIN_CARDS_FILE, "w", encoding="utf-8") as f:
            json.dump(updated_cards, f, indent=2, ensure_ascii=False)

        print(f"   Successfully updated! New total: {len(updated_cards)} cards")

        # Show new distribution
        print("\n New Distribution (after update):")
        print("-" * 40)
        new_pos_counts = analyze_distribution(updated_cards)
        new_total = sum(new_pos_counts.values())
        for pos, count in sorted(new_pos_counts.items(), key=lambda x: x[1], reverse=True):
            percentage = (count / new_total * 100) if new_total > 0 else 0
            print(f"   {pos:15}: {count:4d} cards ({percentage:5.1f}%)")
    else:
        print("\n   No new cards to add. Distribution is already balanced.")

    print("\n" + "=" * 60)
    print("Analysis complete!")
    print("=" * 60)


if __name__ == "__main__":
    main()
