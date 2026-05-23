# /orchestrate

WORKFLOW.md'yi faz faz execute eder. Tam otomatik pipeline.

## Kullanım

```
/orchestrate
```

## Ön Koşul

`docs/WORKFLOW.md` mevcut olmalı. Yoksa `/plan-workflow` çalıştır.

## Workflow

### Adım 0 — Başlatma

1. `docs/WORKFLOW.md` oku
2. `Assets/_Framework/` ve `Assets/_GameFolders/` tara — mevcut kodu tespit et
3. Pre-Scan raporu göster (hangi kodlar zaten var)

### ▶ SCOPE_GATE

```
WORKFLOW.md yüklendi.
Fazlar: [N]
Toplam task: [M]

Pre-Scan: [zaten var olan sistemler]

Başlamak için "go" yaz.
```

### Adım 1 — Faz Döngüsü

Her faz için:

```
=== FAZ [N]: [Faz Adı] ===
```

**Paralel task tespiti:**
Aynı `parallel_group`'taki task'lar → aynı anda spawn et
Çakışan output dosyaları → sıralı çalıştır

**Task execution:**
→ tester → coder/unity-coder → verifier → reviewer → committer

**Faz sonu otomatik kalite:**
→ `/ralph` (verify-fix loop)
→ `silent-failure-hunter`
→ `/validate`

**Faz Kapısı (manual):**
```
Faz [N] tamamlandı.
Sonraki faza geç? (yes / no / stop)
```

### Adım 2 — Tamamlanma

`docs/EVENTS.jsonl`'e append et:
```json
{"event":"ORCHESTRATION_COMPLETED","timestamp":"...","phases":[N],"tasks":[M]}
```

`.claude/state/gate-cleared` sil.

```
✅ ORCHESTRATION COMPLETE
   Fazlar: [N]
   Task'lar: [M]
   Commit'ler: [K]
```
