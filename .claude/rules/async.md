# Async Rules

## Zorunlu: UniTask

Tüm async işlemler UniTask kullanır. `System.Threading.Tasks.Task` ve coroutine yasak.

```csharp
// DOĞRU
public async UniTask LoadAsync(CancellationToken ct)
{
    await UniTask.Delay(1000, cancellationToken: ct);
}

// YANLIŞ — coroutine
IEnumerator LoadCoroutine() { yield return new WaitForSeconds(1f); }

// YANLIŞ — Task
async Task LoadAsync() { await Task.Delay(1000); }
```

## CancellationToken Zorunluluğu

Her public async metot `CancellationToken` parametresi alır:

```csharp
// DOĞRU
public async UniTask PlayAsync(string clipName, CancellationToken ct)

// YANLIŞ — token yok
public async UniTask PlayAsync(string clipName)
```

## async void Yasak

```csharp
// YASAK
async void OnButtonClick() { await DoSomethingAsync(); }

// DOĞRU — UniTask döndür veya .Forget() kullan
void OnButtonClick() { DoSomethingAsync(destroyCancellationToken).Forget(); }
```

## Ownership Modeli

- View'lar `destroyCancellationToken` kullanır (MonoBehaviour yok olunca iptal)
- Servisler kendi `CancellationTokenSource`'larını oluşturur ve dispose eder

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

## UniTask.WhenAll Kullanımı

```csharp
// Paralel async işlemler
await UniTask.WhenAll(
    LoadAudioAsync(ct),
    LoadTextureAsync(ct)
);
```
