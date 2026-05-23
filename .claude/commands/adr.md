# /adr

Architecture Decision Record oluşturur.

## Kullanım

```
/adr <karar başlığı>
```

Örnek: `/adr VContainer yerine Zenject kullanma kararı`

## Workflow

### Adım 1 — ADR Numarası Belirle

`docs/decisions/` klasörünü tara, son numarayı bul, +1 ekle.

### Adım 2 — ADR Dosyası Oluştur

`docs/decisions/[NNN]-[slug].md`:

```markdown
# [NNN] — [Başlık]

**Tarih:** [YYYY-MM-DD]
**Durum:** Kabul Edildi

## Bağlam

[Neden bu karar alındı? Hangi sorunu çözüyor?]

## Karar

[Ne yapılacağına karar verildi]

## Sonuçlar

**Olumlu:**
- [avantajlar]

**Olumsuz / Trade-off:**
- [dezavantajlar]

## Alternatifler

[Değerlendirilen ama seçilmeyen seçenekler]
```

### Adım 3 — Commit

```bash
git add docs/decisions/
git commit -m "docs: add ADR [NNN] - [slug]"
```
