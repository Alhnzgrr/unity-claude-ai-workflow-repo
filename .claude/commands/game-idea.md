# /game-idea

Ham oyun fikrini yapılandırılmış Game Design Document'a (GDD) dönüştürür.

## Kullanım

```
/game-idea [opsiyonel: kısa fikir açıklaması]
```

## Workflow

### Adım 1 — Fikri Anla

Kullanıcıdan şunları öğren (birer birer sor):
1. Temel oyun mekaniği nedir? (Core loop)
2. Hedef platform? (PC, Mobile, VR, Console)
3. Hedef kitle? (Hyper-casual, Core, Hardcore)
4. Referans oyunlar? (Varsa)
5. Öne çıkan özellik nedir? (USP — Unique Selling Point)

### Adım 2 — Varsayımları Yüzey Alt Etme

Belirsiz olan her şeyi somutlaştır:
- "Multiplayer" → kaç oyuncu, online mi local mi?
- "RPG sistemi" → hangi sistemler? inventory, skill tree, leveling?
- "Mobil" → iOS mu Android mu ikisi de mi?

### Adım 3 — "Yapmıyoruz" Listesi

YAGNI prensibine göre kapsam dışına alınacakları belirle.
Kullanıcıya sor: "Bu versiyonda şunları yapmayacağız, doğru mu?"

### Adım 4 — GDD Oluştur

`docs/GDD.md` dosyasına yaz:

```markdown
# Game Design Document — [Oyun Adı]

## Özet
[2-3 cümle elevator pitch]

## Core Loop
[Temel oyun döngüsü adım adım]

## Mekanikler
[Her mekanik için: ne, neden, nasıl]

## Hedef Kitle
[Kim için, neden onlar]

## Platform
[Hedef platform ve kısıtları]

## Kapsam Dışı (Bu Versiyon)
[Yapılmayacaklar listesi]

## Başarı Kriterleri
[Nasıl anlarsın oyun çalışıyor?]
```

### Adım 5 — Commit

```bash
git add docs/GDD.md
git commit -m "docs: add Game Design Document for [oyun adı]"
```

## Sonraki Adım

GDD hazırsa: `/architect` ile teknik tasarıma geç.
