---
name: unitask
description: UniTask async/await patterns. Basic usage, CancellationToken, PlayerLoop integration.
---

# UniTask

> Auto-loaded when `project-config.json` → `"async": "unitask"` (always).

## Basic Usage

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

## Coroutine Equivalents

```
yield return null                    → await UniTask.Yield()
yield return new WaitForSeconds(t)   → await UniTask.Delay(TimeSpan.FromSeconds(t), ct)
yield return new WaitForFixedUpdate()→ await UniTask.WaitForFixedUpdate()
yield return new WaitUntil(pred)     → await UniTask.WaitUntil(pred, ct: ct)
yield return asyncOp                 → await asyncOp.WithCancellation(ct)
```

## Fire-and-Forget

```csharp
// CORRECT — exception is handled
DoAsync(ct).Forget(e => Debug.LogException(e));

// WRONG — exception is swallowed
DoAsync(ct).Forget();
```

## CancellationToken Sources

```csharp
// Cancel when MonoBehaviour is destroyed
await LoadAsync(destroyCancellationToken);

// Manual cancel
private CancellationTokenSource _cts = new();
await LoadAsync(_cts.Token);
// Cancel: _cts.Cancel();

// Linked token
var linked = CancellationTokenSource.CreateLinkedTokenSource(
    destroyCancellationToken, externalCt);
await LoadAsync(linked.Token);
```

## Parallel Operations

```csharp
await UniTask.WhenAll(
    LoadAudioAsync(ct),
    LoadTextureAsync(ct),
    LoadDataAsync(ct)
);
```
