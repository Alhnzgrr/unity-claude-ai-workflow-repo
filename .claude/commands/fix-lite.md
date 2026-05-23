# /fix-lite

Hızlı yol: NullRef, typo, obvious tek satır fix.

## Kullanım

```
/fix-lite <kısa hata açıklaması>
```

## Uygun Durumlar

- NullReferenceException (bariz sebep)
- Yazım hatası (typo)
- Off-by-one
- Yanlış operator (= yerine ==)

## Uygun Olmayan Durumlar

Root cause belirsizse → `/fix` veya `/fix-deep` kullan.

## Workflow

### Adım 1 — unity-fixer-lite

`unity-fixer-lite` spawn et:
- İlgili dosyayı oku (gateguard için)
- Tek satır fix uygula

### Adım 2 — unity-verifier

Compile + test kontrolü.

### Adım 3 — committer (COMMIT_GATE olmadan)

Otomatik commit: `fix([scope]): [kısa açıklama]`

## Output

```
✅ FIX-LITE COMPLETE
   [dosya:satır] düzeltildi
   Commit: [hash]
```
