---
name: unitask
description: Use when implementing or reviewing UniTask async flows, Unity AsyncOperation awaits, cancellation propagation, progress, timeout, fire-and-forget work, or coroutine migration.
---

# UniTask

## Purpose

Help agents write Unity async code that is allocation-conscious, PlayerLoop-aware, cancellable, and safe across MonoBehaviour lifetimes.

## Source Notes

UniTask is a Unity-focused async/await integration. Its README highlights struct-based `UniTask<T>`, PlayerLoop-based timing APIs, awaitable Unity AsyncOperations, cancellation support, progress helpers, `UniTaskVoid`, TaskTracker, and async LINQ/channel features.

## Core Idea

Async work needs an owner and a cancellation path. In Unity, that owner is usually a MonoBehaviour lifetime, a service lifetime, an application lifetime, or a user action.

## Use When

Use this skill for:

- loading flows
- timers, delays, and frame waits
- UnityWebRequest, scene loading, Resources, Addressables, AssetBundle, or AsyncOperation awaits
- UI click flows and view transitions
- progress reporting
- timeout behavior
- coroutine-to-UniTask migration
- fire-and-forget behavior
- background work with main-thread return

## Main Rules

- Public async methods receive a `CancellationToken`, normally as the last parameter.
- Pass cancellation from the root async method to every awaited operation that accepts it.
- Use `destroyCancellationToken` on Unity 2022.2+ for MonoBehaviour lifetime cancellation.
- Use service-owned `CancellationTokenSource` for service lifetime cancellation and dispose it.
- Use `UniTaskVoid` only for fire-and-forget entry points where exceptions are handled.
- Do not await the same `UniTask` instance twice unless it is explicitly preserved or backed by a source that supports multiple awaits.
- Prefer cancellation-driven timeout over external `.Timeout` when the running operation can be stopped.

## Basic Pattern

```csharp
public async UniTask<PlayerData> LoadPlayerDataAsync(string key, CancellationToken ct)
{
    TextAsset asset = await Resources.LoadAsync<TextAsset>(key)
        .WithCancellation(ct);

    if (asset == null)
        throw new InvalidOperationException($"Player data not found: {key}");

    return JsonUtility.FromJson<PlayerData>(asset.text);
}
```

## Unity AsyncOperation Pattern

UniTask supports awaiting Unity async operations.

```csharp
public async UniTask LoadSceneAsync(string sceneName, CancellationToken ct)
{
    await SceneManager.LoadSceneAsync(sceneName)
        .WithCancellation(ct);
}
```

Use `.WithCancellation(ct)` when you only need cancellation. Use `.ToUniTask(...)` when you need progress, timing, or more options.

## MonoBehaviour Ownership

```csharp
public sealed class LoadingView : MonoBehaviour
{
    private void OnEnable()
    {
        LoadAsync(destroyCancellationToken)
            .Forget(Debug.LogException);
    }

    private async UniTask LoadAsync(CancellationToken ct)
    {
        await UniTask.DelayFrame(2, cancellationToken: ct);
        await UniTask.SwitchToMainThread(ct);
        // Safe Unity API access after returning to the main thread.
    }
}
```

## Service Ownership

```csharp
public sealed class MatchService : IDisposable
{
    private readonly CancellationTokenSource _lifetimeCts = new();

    public async UniTask StartMatchAsync(CancellationToken ct)
    {
        using var linked = CancellationTokenSource.CreateLinkedTokenSource(
            _lifetimeCts.Token,
            ct);

        await InitializeAsync(linked.Token);
    }

    public void Dispose()
    {
        _lifetimeCts.Cancel();
        _lifetimeCts.Dispose();
    }
}
```

## Coroutine Equivalents

```text
yield return null                     -> await UniTask.Yield(ct)
yield return new WaitForSeconds(t)    -> await UniTask.Delay(TimeSpan.FromSeconds(t), cancellationToken: ct)
yield return new WaitForSecondsRealtime(t) -> await UniTask.Delay(TimeSpan.FromSeconds(t), ignoreTimeScale: true, cancellationToken: ct)
yield return new WaitForFixedUpdate() -> await UniTask.WaitForFixedUpdate(ct)
yield return new WaitUntil(pred)      -> await UniTask.WaitUntil(pred, cancellationToken: ct)
yield return asyncOperation           -> await asyncOperation.WithCancellation(ct)
```

Use `PlayerLoopTiming` when timing matters.

```csharp
await UniTask.Yield(PlayerLoopTiming.PreLateUpdate, ct);
```

## Await-Once Rule

Do not cache and await the same `UniTask` value multiple times.

Bad:

```csharp
UniTask task = UniTask.DelayFrame(10);
await task;
await task;
```

Use `UniTask.Lazy`, `.Preserve()`, or `UniTaskCompletionSource` when multiple awaiters or repeated awaits are actually required.

## Fire-and-Forget

Good:

```csharp
SaveAsync(ct).Forget(Debug.LogException);
```

Allowed entry point:

```csharp
private async UniTaskVoid RunAndForgetAsync(CancellationToken ct)
{
    try
    {
        await SaveAsync(ct);
    }
    catch (Exception exception)
    {
        Debug.LogException(exception);
    }
}
```

Bad:

```csharp
SaveAsync(ct).Forget();
```

## Timeout Pattern

Prefer cancellation-based timeout so the running operation can stop.

```csharp
private readonly TimeoutController _timeout = new();

public async UniTask<string> DownloadAsync(string url, CancellationToken ct)
{
    using var linked = CancellationTokenSource.CreateLinkedTokenSource(
        ct,
        _timeout.Timeout(TimeSpan.FromSeconds(5)));

    try
    {
        UnityWebRequest request = UnityWebRequest.Get(url);
        await request.SendWebRequest().WithCancellation(linked.Token);
        _timeout.Reset();
        return request.downloadHandler.text;
    }
    catch (OperationCanceledException) when (_timeout.IsTimeout())
    {
        throw new TimeoutException($"Request timed out: {url}");
    }
}
```

Avoid `.Timeout` when possible because it can ignore the result without stopping the underlying operation.

## Progress Pattern

Use UniTask progress helpers instead of `new System.Progress<T>` in allocation-sensitive paths.

```csharp
IProgress<float> progress = Progress.CreateOnlyValueChanged<float>(
    value => _progressBar.value = value);

await request.SendWebRequest()
    .ToUniTask(progress: progress, cancellationToken: ct);
```

For hot paths, implementing `IProgress<float>` on the receiver can avoid lambda allocation.

## Parallel Work

```csharp
var (audio, texture, saveData) = await UniTask.WhenAll(
    LoadAudioAsync(ct),
    LoadTextureAsync(ct),
    LoadSaveDataAsync(ct));
```

Parallel tasks should share a cancellation token and fail clearly when one branch fails.

## Threading and Main Thread

UniTask runs on Unity's PlayerLoop by default. Use thread switching only when needed.

```csharp
await UniTask.SwitchToThreadPool();
Result result = ComputeHeavyData();
await UniTask.SwitchToMainThread(ct);
ApplyToUnityObjects(result);
```

Never touch Unity objects from a background thread.

## Good Pattern

```text
Owner creates token -> async method propagates token -> operation cancels on owner disposal -> exceptions are logged or surfaced
```

## Bad Pattern

```text
Button callback -> async void -> no cancellation -> exception disappears -> destroyed view is accessed later
```

## Common Mistakes

- public async methods without `CancellationToken`
- not passing tokens into nested awaits
- `.Forget()` without exception handling
- awaiting the same `UniTask` more than once
- using `.Timeout` when internal cancellation is possible
- creating `CancellationTokenSource` without disposing it
- using `async void` for non-Unity event handlers
- touching Unity API after `SwitchToThreadPool`

## AI Review Guidance

When reviewing UniTask usage, check:

- Does each async flow have a clear owner?
- Is cancellation propagated to every awaited operation?
- Are fire-and-forget errors handled?
- Is timeout implemented through cancellation when possible?
- Are progress callbacks allocation-conscious?
- Are Unity APIs only used on the main thread?
- Is the await-once rule respected?
