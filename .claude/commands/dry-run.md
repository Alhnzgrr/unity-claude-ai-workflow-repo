# /dry-run

WORKFLOW.md'yi execute etmeden önizler. Hangi agent'ların hangi sırayla çalışacağını gösterir.

## Kullanım

```
/dry-run
```

## Workflow

### Adım 1 — WORKFLOW.md Oku

`docs/WORKFLOW.md` oku.

### Adım 2 — Execution Plan Oluştur

Her faz ve task için:
- Hangi agent kullanılacak
- Hangi task'lar paralel çalışacak (parallel_group)
- Tahmini dosya değişiklikleri
- Director Gate'ler nerede tetiklenecek

### Adım 3 — Raporu Göster

```
## Dry Run Raporu — WORKFLOW.md

### Faz 1: Foundation (2 task, paralel)
  [parallel_group: foundation]
  ├── Task 1.1 → coder → EventBus.cs
  └── Task 1.2 → coder → UnityLogger.cs
  Gate: SCOPE_GATE (faz başında)

### Faz 2: Core Sistemler (3 task)
  ├── Task 2.1 → unity-coder → AudioService + tests
  ├── Task 2.2 → unity-coder → PlayerService + tests
  └── Task 2.3 → unity-coder → EnemyService + tests
  Gate: SCOPE_GATE + COMMIT_GATE

Toplam: [N] task, [M] agent spawn, [K] Director Gate

Çalıştırmak için: /orchestrate
```

Değişiklik YAPILMAZ — sadece plan gösterilir.
