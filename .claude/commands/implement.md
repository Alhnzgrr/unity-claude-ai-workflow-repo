# /implement

TDD pipeline: test → coder → verifier → reviewer → committer.

## Kullanım

```
/implement <görev açıklaması>
```

## Workflow

### Adım 0 — Hazırlık

1. `production/review-mode.txt` oku
2. `project-config.json` oku (DI, async, input tipi)
3. Complexity hesapla (0.0–1.0)
4. Model tier belirle

### ▶ SCOPE_GATE

```
Görev: [görev açıklaması]
Complexity: [0.0–1.0]
Etkilenecek dosyalar: [tahmin]
Review mode: [solo/lean/full]

Devam etmek için "go" yaz.
```

`go` alınınca `.claude/state/gate-cleared` oluştur.

### Adım 1 — tester (izole subagent)

`tester` agent spawn et:
- Test dosyasını yaz
- Testler BAŞARISIZ olmalı (implementasyon yok)
- Test tipi: EditMode / PlayMode (complexity'e göre)

### Adım 2 — unity-coder veya coder

- Complexity ≥ 0.4 veya Unity API gerekiyorsa → `unity-coder`
- Pure C# → `coder`
- Testleri geçirecek minimal implementasyon yaz

### Adım 3 — unity-verifier

`unity-verifier` spawn et:
- Compile kontrolü
- Test çalıştır
- Başarısız → unity-coder'a gönder (max 2 pass)

### Adım 4 — Reviewer

- review-mode == `solo` → bu adımı atla
- review-mode == `lean` veya `full` → `unity-reviewer` spawn et

**▶ QUALITY_GATE** (CHANGES NEEDED ise):
```
Reviewer CHANGES NEEDED döndü.
fix → düzeltmeye devam et
skip → review'u geç
stop → işlemi durdur
```

### Adım 5 — unity-developer (full mode)

- review-mode == `full` → `unity-developer` spawn et
- Aksi halde atla

### Adım 6 — silent-failure-hunter

`silent-failure-hunter` spawn et:
- Exception yutma, async void, event leak kontrol

### Adım 7 — committer

**▶ COMMIT_GATE**:
```
Staged dosyalar:
- [dosya listesi]

Commit atılacak. Onaylıyor musun? (go / hayır)
```

`go` → `committer` agent commit atar.

### Temizlik

`.claude/state/gate-cleared` sil.

## Output

```
✅ IMPLEMENT COMPLETE
   Tests: [N] passed
   Files: [M] files changed
   Commit: [commit hash]
```
