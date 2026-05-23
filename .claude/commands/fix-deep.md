# /fix-deep

Evidence-first fix. Root cause kanıtlanmadan fix yapılmaz.

## Kullanım

```
/fix-deep <belirsiz veya intermittent hata açıklaması>
```

## Ne Zaman Kullan

- Root cause belirsiz
- Intermittent (arada bir oluyor)
- Stack trace yetersiz
- "Bazen çalışıyor" sorunları

## Workflow

### Adım 1 — Log Intake

Mevcut log'ları ve hata mesajlarını topla:
- Stack trace
- Unity Console çıktısı
- Reproduce adımları

### Adım 2 — Hipotez Üret

`unity-scout` + `unity-fixer` ile minimum 2 hipotez:
```
Hipotez 1: [sebep] — Kanıt: [ne görmek bekliyoruz]
Hipotez 2: [sebep] — Kanıt: [ne görmek bekliyoruz]
```

### Adım 3 — Debug Injection

Kanıt toplamak için geçici debug log ekle:
```csharp
Debug.Log($"[DEBUG] {nameof(MyMethod)}: value={value}, state={_state}");
```

Kullanıcıya: "Oyunu çalıştır, şu senaryoyu test et, logu buraya yapıştır."

### Adım 4 — Evidence Gate

Log alınınca hipotezleri değerlendir:
- Hipotez doğrulandı mı? → Fix yap
- Doğrulanamadı → Yeni hipotez

**Root cause kanıtlanmadan fix yapılmaz.**

### Adım 5 — Fix (Kanıtlanmış Root Cause ile)

`/fix` pipeline ile devam et (test → coder → verify → review → commit).

### Adım 6 — Debug Kodunu Temizle

```bash
git diff -- "*.cs" | grep "DEBUG"
```

Debug log satırlarını kaldır, commit at.
