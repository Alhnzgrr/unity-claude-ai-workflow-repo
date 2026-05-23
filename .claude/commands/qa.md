# /qa

Tam kalite pipeline: ralph → silent-failure-hunt → validate.

## Kullanım

```
/qa
```

## Workflow

### Adım 1 — /ralph

Verify-fix loop çalıştır (max 10 iterasyon). Yeşil olana kadar dur.

### Adım 2 — silent-failure-hunter

`silent-failure-hunter` spawn et. Exception yutma, async void, event leak tara.

### Adım 3 — /validate

Faz exit criteria kontrolü yap.

## Output

```
✅ QA PASSED
   Ralph: [N] iterasyon, yeşil
   Silent Failures: temiz
   Validation: geçti

❌ QA FAILED
   [Nerede takıldı ve neden]
```
