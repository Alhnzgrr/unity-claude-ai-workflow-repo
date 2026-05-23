---
name: context-management
description: Review mode, context compaction ve checkpoint kullanım rehberi.
---

# Context Management

## Review Mode

`production/review-mode.txt` okunur, pipeline derinliği belirlenir:

| Mode | Test | Review | unity-developer | Kullanım |
|---|---|---|---|---|
| `solo` | ❌ | ❌ | ❌ | Jam, prototip, hızlı deney |
| `lean` | ✅ | ✅ | Opsiyonel | Normal geliştirme (default) |
| `full` | ✅ | ✅ | Her zaman ✅ | Takım, öğrenme, kritik feature |

Review mode okuma:
```bash
cat production/review-mode.txt
```

## Checkpoint Kullanımı

Uzun session'larda context kaybolmadan devam etmek için:

```
/checkpoint
```

→ `.claude/state/checkpoint.md` oluşturur. Yeni session'da:

```
/context-prime
```

→ checkpoint'i yükler, projeyi tanıtır.

## Context Tasarrufu

- Uzun session'larda gereksiz dosya okumaktan kaçın
- Bir session'da okunan dosyaları tekrar okuma
- Skills yalnızca ilgili göreve yükle
- `unity-scout` araştırmayı halleder, ana agent context'ini korur

## Session State Dosyaları

```
.claude/state/
├── session.json      ← aktif branch, faz, değişen dosyalar
├── checkpoint.md     ← /checkpoint ile oluşur
├── gate-cleared      ← Director Gate onayı sonrası oluşur, pipeline biter bitmez silinir
└── read-files.log    ← gateguard için okunan dosyalar listesi
```
