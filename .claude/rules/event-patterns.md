# Event Pattern Rules

## UnityEvent Yasak

```csharp
// YANLIŞ
[SerializeField] private UnityEvent<int> onScoreChanged;
[SerializeField] private UnityEvent onPlayerDied;
```

`check-unity-event.sh` hook'u bunu engeller.

## IEventBus — Sistemler Arası İletişim

Farklı sistemler (servisler) arası iletişim için:

```csharp
// Event tanımı
public readonly struct PlayerDiedEvent : IEvent
{
    public readonly int PlayerId;
    public PlayerDiedEvent(int id) => PlayerId = id;
}

// Yayınla
_eventBus.Publish(new PlayerDiedEvent(_playerId));

// Dinle (OnEnable/OnDisable ile eşleştir)
void OnEnable() => _eventBus.Subscribe<PlayerDiedEvent>(OnPlayerDied);
void OnDisable() => _eventBus.Unsubscribe<PlayerDiedEvent>(OnPlayerDied);
private void OnPlayerDied(PlayerDiedEvent e) { ... }
```

## C# Event — Aynı Modül İçi

Aynı modül içindeki bileşenler arası sıkı bağlı iletişim için:

```csharp
public class AudioService : IAudioService
{
    public event Action<string> OnClipStarted;
    private void Play(string name) => OnClipStarted?.Invoke(name);
}
```

## Action/Func — Callback

Tek seferlik callback veya delegate iletimi için:

```csharp
public void LoadAsync(Action<AudioClip> onComplete, CancellationToken ct) { }
```

## Karar Ağacı

```
Farklı sistemler arası mı?     → IEventBus
Aynı modül içinde mi?          → C# event
Tek seferlik callback mi?      → Action/Func
Inspector'dan atanacak mı?     → [SerializeField] Action (UnityEvent değil)
```
