# /learn

Proje-spesifik pattern'leri keşfeder ve skills/learned/ altına kaydeder.

## Kullanım

```
/learn [opsiyonel: konu]
```

## Ne Zaman Kullan

- Bir pattern projede 3+ kez tekrarlandığında
- Bir hata birden fazla kez yapıldığında
- Projeye özgü bir convention ortaya çıktığında

## Workflow

### Adım 1 — Pattern Tespit

Şunlardan birini sor veya gözlemle:
- "Bu pattern nerede daha kullanılmış?"
- "Bu hata başka yerde de var mı?"

`unity-scout` ile codebase'de tara.

### Adım 2 — Skill Oluştur

`skills/learned/<pattern-adı>.md`:

```markdown
---
name: [pattern-adı]
description: [ne zaman kullan — tek cümle]
project-specific: true
---

# [Pattern Adı]

## Ne Zaman

[Bu pattern ne zaman uygulanır]

## Nasıl

[Kod örneği ile açıklama]

## Dikkat

[Kaçınılacaklar]
```

### Adım 3 — auto-loaded-skills.md Güncelle

`.claude/docs/auto-loaded-skills.md`'e ekle:
```
@.claude/skills/learned/[pattern-adı].md
```

### Adım 4 — Commit

```bash
git add .claude/skills/learned/ .claude/docs/auto-loaded-skills.md
git commit -m "docs: learn [pattern-adı] pattern"
```
