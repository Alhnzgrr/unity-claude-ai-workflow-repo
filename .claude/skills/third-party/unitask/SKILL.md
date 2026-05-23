---
name: unitask
description: UniTask async/await pattern'leri. Temel kullanım, CancellationToken, PlayerLoop entegrasyonu.
---

# UniTask

> `project-config.json` → `"async": "unitask"` ise auto-yüklenir (her zaman).

## Temel Kullanım

```csharp
public async UniTask LoadAsync(CancellationToken ct)
{
    await UniTask.Delay(1000, cancellationToken: ct);
    await LoadResourcesAsync(ct);
}

public async UniTask<PlayerData> GetPlayerDataAsync(CancellationToken ct)
{
    var json = await File.ReadAllTextAsync("save.json", ct);
    return JsonUtility.FromJson<PlayerData>(json);
}
```

## Coroutine Karşılıkları

```
yield return null                    → await UniTask.Yield()
yield return new WaitForSeconds(t)   → await UniTask.Delay(TimeSpan.FromSeconds(t), ct)
yield return new WaitForFixedUpdate()→ await UniTask.WaitForFixedUpdate()
yield return new WaitUntil(pred)     → await UniTask.WaitUntil(pred, ct: ct)
yield return asyncOp                 → await asyncOp.WithCancellation(ct)
```

## Fire-and-Forget

```csharp
// DOĞRU — exception işlenir
DoAsync(ct).Forget(e => Debug.LogException(e));

// YANLIŞ — exception yutulur
DoAsync(ct).Forget();
```

## CancellationToken Kaynakları

```csharp
// MonoBehaviour yok olunca iptal
await LoadAsync(destroyCancellationToken);

// Manuel iptal
private CancellationTokenSource _cts = new();
await LoadAsync(_cts.Token);
// İptal et: _cts.Cancel();

// Linked token
var linked = CancellationTokenSource.CreateLinkedTokenSource(
    destroyCancellationToken, externalCt);
await LoadAsync(linked.Token);
```

## Paralel İşlemler

```csharp
await UniTask.WhenAll(
    LoadAudioAsync(ct),
    LoadTextureAsync(ct),
    LoadDataAsync(ct)
);
```
