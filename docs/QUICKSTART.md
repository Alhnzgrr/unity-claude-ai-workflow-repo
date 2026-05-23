# Hızlı Başlangıç

## Yeni Proje Başlatma

```
/game-idea        → Ham fikri GDD'ye dönüştür
/architect        → GDD'den TDD üret
/plan-workflow    → TDD'yi fazlara böl → WORKFLOW.md
/orchestrate      → WORKFLOW.md'yi execute et
```

## Mevcut Projeye Özellik Ekleme

```
/implement "AudioService implement et"
```

Pipeline otomatik çalışır:
1. Testler yazılır (başarısız)
2. Implementasyon yapılır (testleri geçer)
3. Verify edilir
4. Review yapılır
5. Commit atılır

## Bug Düzeltme

```
/fix "PlayerController NullReferenceException fırlatıyor"
/fix-lite "typo: PlayerControler → PlayerController"
/fix-deep "FixedUpdate arada kayıp frame atıyor, sebebi belirsiz"
```

## Kalite Kontrolü

```
/qa               → Tam kalite pipeline
/review-code      → Belirli dosyaları review et
/performance-audit → Hot path denetimi
```

## Review Modunu Değiştir

`production/review-mode.txt` dosyasını düzenle:
- `solo` — Jam/prototip için hızlı mod
- `lean` — Normal geliştirme (default)
- `full` — Takım review modu

## Director Gates (İnsan Checkpoint'leri)

Sistem kritik noktalarda durur ve senin onayını bekler:

| Gate | Ne zaman | Ne sorar |
|---|---|---|
| SCOPE_GATE | Pipeline başında | "go" yaz veya yönlendir |
| BREAKING_GATE | 3+ dosya değişince | Geniş kapsam onayı |
| QUALITY_GATE | Review "CHANGES NEEDED" dönünce | fix / skip / stop |
| COMMIT_GATE | Verification sonrası | Final onay |
