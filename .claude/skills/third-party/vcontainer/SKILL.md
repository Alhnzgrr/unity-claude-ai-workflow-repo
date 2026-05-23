---
name: vcontainer
description: Use when implementing or reviewing VContainer scopes, dependency registration, MonoBehaviour injection, entry points, factories, or composition roots.
---

# VContainer

## Purpose

Help agents wire Unity systems with explicit dependency injection instead of static access, scene searches, or service locators.

## Core Idea

VContainer should make object ownership and dependency direction explicit. It is not a place to hide unclear architecture.

## Use When

Use this skill for:

- `LifetimeScope` design
- service registration
- MonoBehaviour injection
- ScriptableObject config registration
- entry points
- factories
- replacing singleton access

## LifetimeScope Hierarchy

```text
AppScope
  Global services, save system, audio, analytics, cross-scene state

GameScope
  Scene services, gameplay systems, scene-specific providers

Feature/SubScope
  Optional short-lived or feature-specific graph
```

Keep scope ownership simple. Do not create sub-scopes unless object lifetime actually differs.

## Registration Pattern

```csharp
public sealed class GameScope : LifetimeScope
{
    [SerializeField] private AudioConfiguration _audioConfiguration;
    [SerializeField] private AudioProvider _audioProvider;

    protected override void Configure(IContainerBuilder builder)
    {
        builder.RegisterInstance(_audioConfiguration);
        builder.Register<AudioService>(Lifetime.Singleton)
            .As<IAudioService>();
        builder.RegisterComponent(_audioProvider);
        builder.RegisterEntryPoint<GameEntryPoint>();
    }
}
```

## Constructor Injection

Use constructor injection for pure C# services.

```csharp
public sealed class AudioService : IAudioService
{
    private readonly AudioConfiguration _configuration;
    private readonly IEventBus _eventBus;

    public AudioService(AudioConfiguration configuration, IEventBus eventBus)
    {
        _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
        _eventBus = eventBus ?? throw new ArgumentNullException(nameof(eventBus));
    }
}
```

## MonoBehaviour Injection

Use method injection for MonoBehaviours.

```csharp
public sealed class PlayerView : MonoBehaviour
{
    private IPlayerService _playerService;

    [Inject]
    private void Construct(IPlayerService playerService)
    {
        _playerService = playerService;
    }
}
```

## Factories

Use factories when runtime creation needs injected dependencies.

```csharp
builder.RegisterFactory<EnemyId, Enemy>(
    container =>
    {
        IEventBus eventBus = container.Resolve<IEventBus>();
        return id => new Enemy(id, eventBus);
    },
    Lifetime.Singleton);
```

## Entry Points

Use entry points for startup work that does not belong in MonoBehaviour lifecycle methods.

```csharp
public sealed class GameEntryPoint : IStartable, IDisposable
{
    private readonly IGameService _gameService;

    public GameEntryPoint(IGameService gameService)
    {
        _gameService = gameService;
    }

    public void Start()
    {
        _gameService.Initialize();
    }

    public void Dispose()
    {
        _gameService.Dispose();
    }
}
```

## Good Pattern

```text
LifetimeScope registers services and scene providers.
Services depend on interfaces and config.
Views receive services through [Inject].
No service searches the scene.
```

## Bad Pattern

```text
AudioService.Instance.Play()
FindObjectOfType<AudioService>()
ServiceLocator.Get<IAudioService>()
GetComponent fallback when injection failed
```

## Common Mistakes

- registering concrete services without interfaces at meaningful boundaries
- using DI to hide unclear ownership
- injecting into objects not created or registered by the container
- doing scene searches as fallback
- putting too much setup logic in `Start`
- registering runtime mutable state as a ScriptableObject config

## AI Review Guidance

When reviewing VContainer usage, check:

- Is the composition root explicit?
- Are global and scene lifetimes separated?
- Are MonoBehaviours registered or present in hierarchy correctly?
- Are missing dependencies fail-fast?
- Are singleton and service locator patterns absent?
