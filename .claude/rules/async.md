# Async Rules

## Required: UniTask

All async operations use UniTask. `System.Threading.Tasks.Task` and coroutines are forbidden.

```csharp
// CORRECT
public async UniTask LoadAsync(CancellationToken ct)
{
    await UniTask.Delay(1000, cancellationToken: ct);
}

// WRONG — coroutine
IEnumerator LoadCoroutine() { yield return new WaitForSeconds(1f); }

// WRONG — Task
async Task LoadAsync() { await Task.Delay(1000); }
```

## CancellationToken Requirement

Every public async method takes a `CancellationToken` parameter:

```csharp
// CORRECT
public async UniTask PlayAsync(string clipName, CancellationToken ct)

// WRONG — no token
public async UniTask PlayAsync(string clipName)
```

## async void Forbidden

```csharp
// FORBIDDEN
async void OnButtonClick() { await DoSomethingAsync(); }

// CORRECT — return UniTask or use .Forget()
void OnButtonClick() { DoSomethingAsync(destroyCancellationToken).Forget(); }
```

## Ownership Model

- Views use `destroyCancellationToken` (cancelled when MonoBehaviour is destroyed)
- Services create and dispose their own `CancellationTokenSource`

```csharp
public class AudioService : IAudioService, IDisposable
{
    private readonly CancellationTokenSource _cts = new();

    public void Dispose() => _cts.Cancel();

    public async UniTask PlayAsync(string clip, CancellationToken ct)
    {
        var linked = CancellationTokenSource.CreateLinkedTokenSource(_cts.Token, ct);
        await _audioClip.ToUniTask(cancellationToken: linked.Token);
    }
}
```

## UniTask.WhenAll Usage

```csharp
// Parallel async operations
await UniTask.WhenAll(
    LoadAudioAsync(ct),
    LoadTextureAsync(ct)
);
```
