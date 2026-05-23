---
name: vcontainer
description: VContainer DI framework pattern'leri. LifetimeScope, Register, Inject, EntryPoint.
---

# VContainer

> `project-config.json` → `"di": "vcontainer"` ise auto-yüklenir.

## LifetimeScope Hiyerarşisi

```
AppScope (DontDestroyOnLoad)        ← Global servisler
└── GameScope (Sahneye özel)        ← Sahne servisleri
    └── SubScope (Opsiyonel)        ← Alt scope'lar
```

## Register Yöntemleri

```csharp
protected override void Configure(IContainerBuilder builder)
{
    // Pure C# servis
    builder.Register<AudioService>(Lifetime.Singleton).As<IAudioService>();

    // MonoBehaviour (Hierarchy'de var)
    builder.RegisterComponentInHierarchy<AudioProvider>();

    // MonoBehaviour (Prefab'dan)
    builder.RegisterComponentInNewPrefab(_audioProviderPrefab, Lifetime.Singleton);

    // Factory
    builder.RegisterFactory<Enemy>(container =>
        () => container.Resolve<Enemy>(), Lifetime.Singleton);

    // ScriptableObject
    builder.RegisterInstance(_audioConfig).As<IAudioConfiguration>();
}
```

## Inject Yöntemleri

```csharp
// Constructor injection (pure C#)
public sealed class AudioService : IAudioService
{
    private readonly IEventBus _eventBus;
    public AudioService(IEventBus eventBus) => _eventBus = eventBus;
}

// Method injection (MonoBehaviour)
public class PlayerView : MonoBehaviour
{
    private IPlayerService _playerService;
    [Inject] void Construct(IPlayerService ps) => _playerService = ps;
}
```

## EntryPoint (IStartable, ITickable)

```csharp
public sealed class GameEntryPoint : IStartable, IDisposable
{
    private readonly IGameService _gameService;
    public GameEntryPoint(IGameService gs) => _gameService = gs;

    public void Start() => _gameService.Initialize();
    public void Dispose() => _gameService.Cleanup();
}

// Register et
builder.RegisterEntryPoint<GameEntryPoint>();
```
