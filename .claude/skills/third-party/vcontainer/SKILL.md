---
name: vcontainer
description: VContainer DI framework patterns. LifetimeScope, Register, Inject, EntryPoint.
---

# VContainer

> Auto-loaded when `project-config.json` → `"di": "vcontainer"`.

## LifetimeScope Hierarchy

```
AppScope (DontDestroyOnLoad)        ← Global services
└── GameScope (Scene-specific)      ← Scene services
    └── SubScope (Optional)         ← Sub-scopes
```

## Register Methods

```csharp
protected override void Configure(IContainerBuilder builder)
{
    // Pure C# service
    builder.Register<AudioService>(Lifetime.Singleton).As<IAudioService>();

    // MonoBehaviour (exists in Hierarchy)
    builder.RegisterComponentInHierarchy<AudioProvider>();

    // MonoBehaviour (from Prefab)
    builder.RegisterComponentInNewPrefab(_audioProviderPrefab, Lifetime.Singleton);

    // Factory
    builder.RegisterFactory<Enemy>(container =>
        () => container.Resolve<Enemy>(), Lifetime.Singleton);

    // ScriptableObject
    builder.RegisterInstance(_audioConfig).As<IAudioConfiguration>();
}
```

## Inject Methods

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

// Register it
builder.RegisterEntryPoint<GameEntryPoint>();
```
