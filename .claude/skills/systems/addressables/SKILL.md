---
name: addressables
description: Addressables Asset System pattern'leri. Async yükleme, handle lifecycle, label yönetimi.
---

# Addressables

> Bu skill `project-config.json` → `"addressables": true` ise auto-yüklenir.

## Temel Yükleme Pattern

```csharp
public sealed class AssetLoader : IAssetLoader, IDisposable
{
    private readonly List<AsyncOperationHandle> _handles = new();

    public async UniTask<T> LoadAsync<T>(string key, CancellationToken ct) where T : Object
    {
        var handle = Addressables.LoadAssetAsync<T>(key);
        _handles.Add(handle);

        await handle.WithCancellation(ct);

        if (handle.Status != AsyncOperationStatus.Succeeded)
            throw new AssetLoadException($"Failed to load: {key}");

        return handle.Result;
    }

    public void Dispose()
    {
        foreach (var handle in _handles)
            if (handle.IsValid()) Addressables.Release(handle);
        _handles.Clear();
    }
}
```

## Instantiate Pattern

```csharp
public async UniTask<GameObject> InstantiateAsync(string key, Transform parent, CancellationToken ct)
{
    var handle = Addressables.InstantiateAsync(key, parent);
    _handles.Add(handle);
    await handle.WithCancellation(ct);
    return handle.Result;
}

// Release etmek için Addressables.ReleaseInstance kullan (Destroy değil!)
public void ReleaseInstance(GameObject go) => Addressables.ReleaseInstance(go);
```

## Label ile Preload

```csharp
public async UniTask PreloadAsync(string label, CancellationToken ct)
{
    var handle = Addressables.LoadAssetsAsync<Object>(label, null);
    _handles.Add(handle);
    await handle.WithCancellation(ct);
}
```

## Build ve Catalog

- Addressable Groups → Remote veya Local
- Remote → Content Delivery Network (CDN)
- Build → Window → Asset Management → Addressables → Build → New Build
