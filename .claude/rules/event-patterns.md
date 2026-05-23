# Event Pattern Rules

## UnityEvent Forbidden

```csharp
// WRONG
[SerializeField] private UnityEvent<int> onScoreChanged;
[SerializeField] private UnityEvent onPlayerDied;
```

`check-unity-event.sh` hook blocks this.

## IEventBus — Cross-System Communication

For communication between different systems (services):

```csharp
// Event definition
public readonly struct PlayerDiedEvent : IEvent
{
    public readonly int PlayerId;
    public PlayerDiedEvent(int id) => PlayerId = id;
}

// Publish
_eventBus.Publish(new PlayerDiedEvent(_playerId));

// Listen (pair with OnEnable/OnDisable)
void OnEnable() => _eventBus.Subscribe<PlayerDiedEvent>(OnPlayerDied);
void OnDisable() => _eventBus.Unsubscribe<PlayerDiedEvent>(OnPlayerDied);
private void OnPlayerDied(PlayerDiedEvent e) { ... }
```

## C# Event — Within the Same Module

For tightly coupled communication between components in the same module:

```csharp
public class AudioService : IAudioService
{
    public event Action<string> OnClipStarted;
    private void Play(string name) => OnClipStarted?.Invoke(name);
}
```

## Action/Func — Callback

For one-time callbacks or delegate passing:

```csharp
public void LoadAsync(Action<AudioClip> onComplete, CancellationToken ct) { }
```

## Decision Tree

```
Between different systems?      → IEventBus
Within the same module?         → C# event
One-time callback?              → Action/Func
Assigned from the Inspector?    → [SerializeField] Action (not UnityEvent)
```
