---
name: addressables
description: Use when implementing or reviewing Addressables loading, instantiation, preloading, catalogs, handle ownership, release behavior, or async asset flows.
---

# Addressables

## Purpose

Help agents load and release assets safely with Addressables while preserving cancellation, ownership, and memory discipline.

## Core Idea

Every Addressables load creates ownership responsibility. Handles must be tracked and released by the system that owns them.

## Use When

Use this skill for:

- loading assets by key or label
- instantiating Addressable prefabs
- preloading groups
- remote/local catalog decisions
- memory cleanup
- replacing `Resources.Load`
- async loading with UniTask

## Main Rules

- Do not use `Resources.Load` for Addressable assets.
- Track every handle that must be released.
- Use `Addressables.Release` for loaded assets.
- Use `Addressables.ReleaseInstance` for instantiated Addressable instances.
- Pass cancellation tokens through async loading flows.
- Fail clearly when a key is missing or loading fails.

## Loader Pattern

```csharp
public sealed class AssetLoader : IAssetLoader, IDisposable
{
    private readonly List<AsyncOperationHandle> _handles = new();

    public async UniTask<T> LoadAsync<T>(string key, CancellationToken ct)
        where T : UnityEngine.Object
    {
        AsyncOperationHandle<T> handle = Addressables.LoadAssetAsync<T>(key);
        _handles.Add(handle);

        await handle.WithCancellation(ct);

        if (handle.Status != AsyncOperationStatus.Succeeded)
            throw new InvalidOperationException($"Addressables load failed: {key}");

        return handle.Result;
    }

    public void Dispose()
    {
        for (int i = 0; i < _handles.Count; i++)
        {
            if (_handles[i].IsValid())
                Addressables.Release(_handles[i]);
        }

        _handles.Clear();
    }
}
```

## Instantiate Pattern

```csharp
public async UniTask<GameObject> InstantiateAsync(
    string key,
    Transform parent,
    CancellationToken ct)
{
    AsyncOperationHandle<GameObject> handle =
        Addressables.InstantiateAsync(key, parent);

    await handle.WithCancellation(ct);

    if (handle.Status != AsyncOperationStatus.Succeeded)
        throw new InvalidOperationException($"Addressables instantiate failed: {key}");

    return handle.Result;
}

public void ReleaseInstance(GameObject instance)
{
    Addressables.ReleaseInstance(instance);
}
```

Do not call `Destroy` for Addressables-created instances unless ownership is explicitly not Addressables-based.

## Preload with Labels

```csharp
public async UniTask<IReadOnlyList<T>> LoadLabelAsync<T>(string label, CancellationToken ct)
    where T : UnityEngine.Object
{
    AsyncOperationHandle<IList<T>> handle =
        Addressables.LoadAssetsAsync<T>(label, null);

    _handles.Add(handle);
    await handle.WithCancellation(ct);

    if (handle.Status != AsyncOperationStatus.Succeeded)
        throw new InvalidOperationException($"Addressables label load failed: {label}");

    return handle.Result as IReadOnlyList<T>;
}
```

## Ownership Patterns

Choose one:

- Loader owns all handles and releases them on dispose.
- Feature/module owns handles and releases them when the feature unloads.
- Caller owns a returned handle and must release it explicitly.

Do not mix ownership styles without documentation.

## Catalog and Build Guidance

- Keep local and remote groups intentional.
- Remote catalog changes should be tested before release.
- Large assets should load asynchronously before they are needed.
- Addressables build steps should be documented for the target platform.

## Good Pattern

```text
Feature starts -> preload label -> use assets -> feature ends -> release handles
```

## Bad Pattern

```text
LoadAssetAsync every time UI opens, never store handle, never release.
```

## Common Mistakes

- forgetting to release handles
- calling `Destroy` instead of `ReleaseInstance`
- swallowing failed load status
- loading by string keys scattered across gameplay code
- treating cancellation as release
- using Addressables without a clear owner

## AI Review Guidance

When reviewing Addressables code, check:

- Who owns each handle?
- Is release behavior explicit?
- Are failed loads handled clearly?
- Are cancellation tokens passed through?
- Are keys centralized or validated?
- Does instantiated object cleanup use `ReleaseInstance`?
