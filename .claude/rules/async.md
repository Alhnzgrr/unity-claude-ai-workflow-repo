# Async Rules

## Required: UniTask

Production async operations use UniTask. `System.Threading.Tasks.Task` and runtime coroutines are forbidden unless a rule explicitly states a test-only exception.

```csharp
// CORRECT
public async UniTask LoadAsync(CancellationToken ct)
{
    await UniTask.Delay(1000, cancellationToken: ct);
}

// WRONG in production code
IEnumerator LoadCoroutine()
{
    yield return new WaitForSeconds(1f);
}

// WRONG in Unity gameplay code
async Task LoadAsync()
{
    await Task.Delay(1000);
}
```

## UnityTest Exception

`IEnumerator` is allowed in test code when required by Unity's `[UnityTest]` runner.

This exception does not permit runtime coroutines in production gameplay code.

## CancellationToken Requirement

Every public async method takes a `CancellationToken` parameter, normally as the last parameter.

```csharp
// CORRECT
public async UniTask PlayAsync(string clipName, CancellationToken ct)

// WRONG
public async UniTask PlayAsync(string clipName)
```

## async void Forbidden

```csharp
// FORBIDDEN
async void OnButtonClick()
{
    await DoSomethingAsync();
}

// CORRECT
void OnButtonClick()
{
    DoSomethingAsync(destroyCancellationToken)
        .Forget(Debug.LogException);
}
```

Unity lifecycle methods and event handlers may be `void`, but they should start UniTask flows with explicit cancellation and exception handling.

## Ownership Model

- Views use `destroyCancellationToken`.
- Services create and dispose their own `CancellationTokenSource` when they own long-running work.
- Callers pass external tokens for user actions or feature lifetimes.

```csharp
public sealed class AudioService : IAudioService, IDisposable
{
    private readonly CancellationTokenSource _lifetimeCts = new();

    public async UniTask PlayAsync(string clip, CancellationToken ct)
    {
        using var linked = CancellationTokenSource.CreateLinkedTokenSource(
            _lifetimeCts.Token,
            ct);

        await PlayInternalAsync(clip, linked.Token);
    }

    public void Dispose()
    {
        _lifetimeCts.Cancel();
        _lifetimeCts.Dispose();
    }
}
```

## UniTask.WhenAll Usage

```csharp
await UniTask.WhenAll(
    LoadAudioAsync(ct),
    LoadTextureAsync(ct));
```

Parallel work should share cancellation and fail clearly when one branch fails.

## Common Mistakes

- missing cancellation tokens on public async methods
- `.Forget()` without exception handling
- runtime coroutines copied from UnityTest examples
- creating `CancellationTokenSource` without disposing it
- touching Unity API after switching to a background thread
