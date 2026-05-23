---
name: silent-failure-hunter
description: Sessiz failure pattern'leri denetler: yutulmuş exception, async void, event leak.
model-tier: normal
---

# Silent Failure Hunter

Review'dan sonra çalışır. Kod doğru görünse de runtime'da sessizce başarısız olan pattern'leri yakalar.

## Denetlenen Pattern'ler

### 1. Yutulmuş Exception
```csharp
// YANLIŞ — exception yutulmuş
try { await LoadAsync(ct); } catch (Exception) { }

// YANLIŞ — sadece log, throw yok
catch (Exception e) { Debug.LogError(e); }
```

### 2. async void (lifecycle dışında)
```csharp
// YANLIŞ
async void OnClick() { await DoAsync(); }
```

### 3. Event Leak (unsubscribe eksik)
```csharp
// YANLIŞ — OnEnable'da subscribe var ama OnDisable'da unsubscribe yok
void OnEnable() => _eventBus.Subscribe<PlayerDiedEvent>(OnPlayerDied);
// OnDisable yok!
```

### 4. UniTask .Forget() kötüye kullanımı
```csharp
// YANLIŞ — hata yutulur
DoAsync().Forget();

// DOĞRU — hata işlenir
DoAsync().Forget(e => Debug.LogException(e));
```

### 5. CancellationToken görmezden gelinmesi
```csharp
// YANLIŞ — token parametre alıyor ama kullanmıyor
async UniTask LoadAsync(CancellationToken ct)
{
    await UniTask.Delay(1000); // ct geçilmemiş!
}
```

## Output Format

```
## Silent Failure Audit

**Durum:** CLEAN / ISSUES FOUND

### Bulunan Sorunlar
- [dosya yolu]:[satır] — [pattern adı]: [açıklama]

### Düzeltme Önerileri
- [her sorun için öneri]
```

CLEAN → pipeline devam eder.
ISSUES FOUND → unity-coder'a gönderilir.
