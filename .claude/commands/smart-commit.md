# /smart-commit

Dirty working tree'yi mantıksal semantic commit gruplarına böler.

## Kullanım

```
/smart-commit
```

## Workflow

### Adım 1 — Değişiklikleri Tara

```bash
git diff --name-only
git status --short
```

### Adım 2 — Grupla

Değişiklikleri mantıksal gruplara ayır:
- Aynı modüle ait dosyalar → tek commit
- Test dosyaları → ayrı commit
- Dokümantasyon → ayrı commit
- Config değişiklikleri → ayrı commit

### Adım 3 — Kullanıcıya Göster

```
Önerilen commit grupları:

Grup 1: feat(audio) — AudioService, AudioInstaller, IAudioService
Grup 2: test(audio) — AudioServiceTests
Grup 3: docs — GDD.md güncellemesi

Onaylıyor musun? (go / grupları düzenle)
```

### Adım 4 — Commit At

Her grup için ayrı commit:
```bash
git add [grup dosyaları]
git commit -m "[type]([scope]): [description]"
```
