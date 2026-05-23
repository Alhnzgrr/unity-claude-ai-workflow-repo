# /plan-workflow

TDD'yi implementasyon fazlarına ve task'lara böler. WORKFLOW.md üretir.

## Kullanım

```
/plan-workflow
```

## Ön Koşul

`docs/TDD.md` mevcut olmalı.

## Workflow

### Adım 1 — TDD Oku

`docs/TDD.md` oku. Tüm sistemleri ve bağımlılıkları anla.

### Adım 2 — Fazları Belirle

Bağımlılık sırasına göre fazları belirle:
- Faz 1: Foundation (Framework, EventBus, DI scaffold)
- Faz 2: Core sistemler (bağımlılığı az olanlar önce)
- Faz 3: Feature sistemler
- Faz 4: UI & polish
- Faz 5: Entegrasyon & QA

### Adım 3 — Task'ları Yaz

Her faz için task'lar:
- Bağımsız task'lar → `parallel_group` ile işaretle
- Her task için: açıklama, agent tipi, input/output, acceptance criteria

### Adım 4 — WORKFLOW.md Oluştur

`docs/WORKFLOW.md` dosyasına yaz:

```markdown
# WORKFLOW — [Proje Adı]

## Faz 1: Foundation

### Task 1.1: EventBus Implementasyonu
- **Agent:** coder
- **Input:** IEventBus interface tanımı
- **Output:** EventBus.cs (Assets/_Framework/Events/)
- **Acceptance:** EditMode testleri geçiyor
- **parallel_group:** foundation

### Task 1.2: Logger Implementasyonu
- **Agent:** coder
- **Input:** ILogger interface tanımı
- **Output:** UnityLogger.cs (Assets/_Framework/Logging/)
- **Acceptance:** EditMode testleri geçiyor
- **parallel_group:** foundation

## Faz 2: Core Sistemler
...
```

### Adım 5 — Commit

```bash
git add docs/WORKFLOW.md
git commit -m "docs: add WORKFLOW.md with phased implementation plan"
```

## Sonraki Adım

`/dry-run` ile önizle veya `/orchestrate` ile execute et.
