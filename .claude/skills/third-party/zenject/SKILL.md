---
name: zenject
description: Use when implementing or reviewing Zenject/Extenject installers, SceneContext, ProjectContext, bindings, factories, memory pools, validation, signals, or composition roots.
---

# Zenject

## Purpose

Help agents use Zenject as a Unity composition root and dependency graph tool while keeping gameplay code loosely coupled, testable, and free of service locator patterns.

## Source Notes

Zenject is a Unity-focused dependency injection framework. Its documentation emphasizes loose coupling, single-responsibility classes, composition roots, installers, constructor/method injection, object graph validation, factories, memory pools, signals, and support for Unity test styles.

## Core Idea

Classes should focus on their responsibilities. Installers and contexts decide which concrete implementations are used and how object graphs are created.

## Use When

Use this skill for:

- `ProjectContext` and `SceneContext` setup
- `MonoInstaller` and `ScriptableObjectInstaller`
- constructor and method injection
- `IInitializable`, `ITickable`, `IFixedTickable`, `ILateTickable`, and `IDisposable`
- factories and memory pools
- scene bindings and cross-scene dependencies
- object graph validation
- signal usage
- singleton migration

## Composition Roots

```text
ProjectContext
  Global, cross-scene services only

SceneContext
  Scene-specific services, providers, and entry points

Installers
  Declare bindings and object graph relationships
```

Keep `ProjectContext` small. Most gameplay bindings should live in scene or feature installers.

## Binding Pattern

```csharp
public sealed class GameInstaller : MonoInstaller
{
    [SerializeField] private AudioConfiguration _audioConfiguration;
    [SerializeField] private AudioProvider _audioProvider;

    public override void InstallBindings()
    {
        Container.BindInstance(_audioConfiguration).AsSingle();

        Container.Bind<IAudioService>()
            .To<AudioService>()
            .AsSingle();

        Container.Bind<AudioProvider>()
            .FromInstance(_audioProvider)
            .AsSingle();

        Container.BindInterfacesTo<GameEntryPoint>()
            .AsSingle()
            .NonLazy();
    }
}
```

Use `NonLazy` intentionally for startup-critical services. Do not mark everything NonLazy just to hide ordering issues.

## Injection Recommendations

Prefer constructor injection for normal C# classes.

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

Use method injection for MonoBehaviours, because Unity creates them.

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

Avoid field and property injection unless there is a strong reason. Constructor and method injection make dependencies more visible.

## Initialization and Ticking

Use Zenject lifecycle interfaces when work belongs to the dependency graph rather than a scene callback.

```csharp
public sealed class GameEntryPoint : IInitializable, IDisposable
{
    private readonly IGameService _gameService;

    public GameEntryPoint(IGameService gameService)
    {
        _gameService = gameService;
    }

    public void Initialize()
    {
        _gameService.Initialize();
    }

    public void Dispose()
    {
        _gameService.Dispose();
    }
}
```

Use `ITickable`, `IFixedTickable`, and `ILateTickable` sparingly. Prefer explicit update ownership for gameplay systems when it improves clarity.

## Factories

Use factories for runtime-created objects that need dependencies or runtime parameters.

```csharp
public sealed class EnemyFactory : IFactory<EnemyId, Enemy>
{
    private readonly IEventBus _eventBus;

    public EnemyFactory(IEventBus eventBus)
    {
        _eventBus = eventBus;
    }

    public Enemy Create(EnemyId id)
    {
        return new Enemy(id, _eventBus);
    }
}
```

Binding:

```csharp
Container.BindFactory<EnemyId, Enemy, EnemyFactory>()
    .AsSingle();
```

## Memory Pools

Use Zenject memory pools for frequently created runtime objects when Zenject owns creation.

```csharp
public sealed class BulletPool : MonoMemoryPool<Vector3, BulletView>
{
    protected override void Reinitialize(Vector3 position, BulletView bullet)
    {
        bullet.ResetForSpawn(position);
    }

    protected override void OnDespawned(BulletView bullet)
    {
        bullet.ResetForDespawn();
    }
}
```

Keep pool reset behavior complete. Pooling without reset is a bug source.

## ScriptableObject Installers

Use `ScriptableObjectInstaller` for configurable binding modules when designers need to author settings.

Do not store live runtime state in installer assets.

## Signals

Signals can decouple publishers and subscribers, but this project already favors `IEventBus` for domain events. Use Zenject signals only when the project has explicitly selected them as the event mechanism.

Do not mix multiple event systems casually.

## Validation

Use Zenject validation to catch missing bindings before play when possible.

Reviewers should treat validation errors as architecture issues, not as runtime surprises to work around with scene searches.

## Good Pattern

```text
SceneContext -> Installer -> explicit bindings -> services created -> views injected -> validation catches missing graph entries
```

## Bad Pattern

```text
Container.Resolve<T>() scattered through gameplay code
FindObjectOfType fallback when injection fails
ProjectContext contains every gameplay service
```

## Common Mistakes

- using `Container.Resolve` as a service locator
- field injection hiding required dependencies
- adding interfaces for every class without a boundary
- global bindings for scene-specific services
- ignoring validation
- mixing Zenject with VContainer in one project
- using signals and a separate event bus for the same event category
- binding mutable runtime state as config

## AI Review Guidance

When reviewing Zenject usage, check:

- Is there a clear composition root?
- Are global and scene lifetimes separated?
- Are dependencies constructor or method injected?
- Are runtime-created objects handled through factories or pools?
- Is validation supported or documented?
- Is gameplay code free of `Container.Resolve` and scene-search fallbacks?
- Is the chosen event mechanism consistent?
