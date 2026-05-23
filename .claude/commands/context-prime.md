# /context-prime

Session başında Claude'u proje bağlamına sokar.

## Kullanım

```
/context-prime
```

## Workflow

### Adım 1 — Temel Dosyaları Oku

- `project-config.json` → DI, async, input, feature bayrakları
- `production/review-mode.txt` → review modu
- `docs/TDD.md` (varsa) → teknik tasarım özeti
- `.claude/state/checkpoint.md` (varsa) → son session özeti
- `docs/WORKFLOW.md` (varsa) → hangi fazda/task'ta?

### Adım 2 — Bağlam Özeti

```
## Proje Bağlamı

**DI:** vcontainer | **Async:** UniTask | **Input:** New Input System
**ECS:** false | **Addressables:** false | **XR:** false
**Review Mode:** lean

**TDD Durumu:** [özet]
**WORKFLOW Durumu:** Faz [N], Task [M]
**Son Checkpoint:** [tarih ve özet]

Hazırım. Ne yapmak istersin?
```
