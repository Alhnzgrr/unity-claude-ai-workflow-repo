# /discover

Packages/manifest.json tarar, yüklü paketler için skill taslakları üretir.

## Kullanım

```
/discover [--dry-run | --write]
```

- `--dry-run` → Ne üretileceğini gösterir, dosya yazmaz
- `--write` → Skill dosyalarını yazar
- Argüman yok → `--dry-run` gibi davranır, onay sorar

## Workflow

### Adım 1 — manifest.json Oku

`Packages/manifest.json` oku. Tüm paketleri listele.

### Adım 2 — package-analyzer Spawn Et

`package-analyzer`:
- Bilinen paketleri tanımla (VContainer, UniTask, DOTween...)
- Singleton kullananları tespit et
- Adapter ihtiyacı olanları işaretle

### Adım 3 — Skill Taslakları Üret

Her bilinmeyen paket için `skills/third-party/[paket-adı]/SKILL.md` taslağı:

```markdown
---
name: [paket-adı]
description: [paket amacı]
discovered: true
---

# [Paket Adı]

## Kurulum

[manifest.json'daki paket ID]

## Temel Kullanım

[TODO: Temel pattern'leri doldur]

## DI Uyumu

[Singleton mi? Adapter gerekiyor mu?]
```

### Adım 4 — Kullanıcı Onayı

```
Bulunan paketler: [N]
Yeni skill taslağı: [M]
Adapter önerisi: [K paket]

Yazılsın mı? (yes/no)
```

### Adım 5 — Commit (--write veya onay verilince)

```bash
git add .claude/skills/third-party/
git commit -m "feat: discover and scaffold [N] package skills"
```
