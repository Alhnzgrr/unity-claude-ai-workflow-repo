# Addressables Rules

> Active condition: `project-config.json` → `"addressables": true`

## Resources.Load Forbidden

```csharp
// WRONG
var clip = Resources.Load<AudioClip>("Sounds/explosion");

// CORRECT
var handle = Addressables.LoadAssetAsync<AudioClip>("Sounds/explosion");
var clip = await handle.Task;
```

## Async Loading

```csharp
public async UniTask<AudioClip> LoadClipAsync(string key, CancellationToken ct)
{
    var handle = Addressables.LoadAssetAsync<AudioClip>(key);
    await handle.WithCancellation(ct);

    if (handle.Status != AsyncOperationStatus.Succeeded)
        throw new Exception($"Addressables load failed: {key}");

    return handle.Result;
}
```

## Handle Lifecycle

Every loaded asset's handle is tracked and Released:

```csharp
private readonly List<AsyncOperationHandle> _handles = new();

public async UniTask<T> LoadAsync<T>(string key, CancellationToken ct)
{
    var handle = Addressables.LoadAssetAsync<T>(key);
    _handles.Add(handle);
    return await handle.WithCancellation(ct);
}

public void Dispose()
{
    foreach (var h in _handles)
        Addressables.Release(h);
    _handles.Clear();
}
```

## Batch Loading with Label

```csharp
var handle = Addressables.LoadAssetsAsync<Sprite>("ui-icons", null);
var sprites = await handle.WithCancellation(ct);
```
