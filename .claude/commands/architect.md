# /architect

GDD'den Technical Design Document (TDD) üretir. unity-critic ile adversarial review.

## Kullanım

```
/architect
```

## Ön Koşul

`docs/GDD.md` mevcut olmalı. Yoksa önce `/game-idea` çalıştır.

## Workflow

### Adım 1 — GDD Oku

`docs/GDD.md` oku. Core loop ve mekanikleri anla.

### Adım 2 — unity-architect Spawn Et

`unity-architect` agent ile teknik tasarım yap:
- Sistemleri belirle (AudioSystem, PlayerSystem, EnemySystem...)
- Her sistem için modül yapısı: Interface + Service + Config + Installer + Events
- Bağımlılık grafiği çiz
- Veri akışını tanımla

### Adım 3 — unity-critic ile Adversarial Review

`unity-critic` agent'ı spawn et:
- Tasarımın en zayıf noktasını bul
- Tek keskin soru sor
- unity-architect cevap ver, tasarımı güçlendir
- En fazla 3 round

### Adım 4 — TDD Oluştur

`docs/TDD.md` dosyasına yaz:

```markdown
# Technical Design Document — [Oyun Adı]

## Sistemler

### [SystemAdı]
**Sorumluluk:** [tek cümle]
**Interface:** I[SystemAdı]Service
**Bağımlılıklar:** [diğer interface'ler]
**Events:** [yayınladığı ve dinlediği]

## Modül Yapısı
[Her modül için 5 dosya listesi]

## Bağımlılık Grafiği
[Metin veya diagram]

## Veri Akışı
[Önemli senaryolar için sequence]

## Riskler
[Tespit edilen riskler ve önlemler]
```

### Adım 5 — Commit

```bash
git add docs/TDD.md
git commit -m "docs: add Technical Design Document"
```

## Sonraki Adım

TDD hazırsa: `/plan-workflow` ile implementasyon planını oluştur.
