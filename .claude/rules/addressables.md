# Addressables Rules

> Aktif koşul: `project-config.json` → `"addressables": true`

## Resources.Load Yasak

```csharp
// YANLIŞ
var clip = Resources.Load<AudioClip>("Sounds/explosion");

// DOĞRU
var handle = Addressables.LoadAssetAsync<AudioClip>("Sounds/explosion");
var clip = await handle.Task;
```

## Async Yükleme

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

Yüklenen her asset'in handle'ı takip edilir ve Release edilir:

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

## Label ile Batch Yükleme

```csharp
var handle = Addressables.LoadAssetsAsync<Sprite>("ui-icons", null);
var sprites = await handle.WithCancellation(ct);
```
