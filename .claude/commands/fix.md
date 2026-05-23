# /fix

Bug fix pipeline: scout → fixer → test → reviewer → committer.

## Kullanım

```
/fix <hata açıklaması veya stack trace>
```

## Workflow

### Adım 0 — Complexity Hesapla

- Stack trace var mı? → root cause açık mı?
- Kaç dosya etkileniyor?
- Complexity < 0.2 → `/fix-lite` öneri
- Complexity belirsiz → `/fix-deep` öneri

### ▶ SCOPE_GATE

```
Bug: [açıklama]
Tahmini etkilenen dosyalar: [liste]
Complexity: [0.0–1.0]

Devam için "go" yaz.
```

### Adım 1 — unity-scout + unity-fixer (paralel, complexity ≥ 0.4)

- `unity-scout`: bağımlılık haritası, etkilenen dosyalar
- `unity-fixer`: root cause analizi

**▶ BREAKING_GATE** (3+ dosya etkileniyorsa):
```
Bu fix [N] dosyayı etkiliyor. Geniş kapsamlı değişiklik.
Devam için "go" yaz.
```

### Adım 2 — tester

`tester` agent: regression test yaz (bug'ı reproduce eden test).

### Adım 3 — unity-coder veya unity-fixer

Fix uygula. Regression test geçmeli.

### Adım 4 — unity-verifier

Compile + tüm testler çalıştır.

### Adım 5 — Reviewer (lean/full modda)

`unity-reviewer` spawn et.

**▶ QUALITY_GATE** (CHANGES NEEDED ise).

### Adım 6 — committer

**▶ COMMIT_GATE** → `committer` commit atar.
