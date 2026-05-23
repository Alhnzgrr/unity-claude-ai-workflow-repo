# Dependency Injection Rules

## Required Container

Based on the `di` value in `project-config.json`:
- `"vcontainer"` → use VContainer
- `"zenject"` → use Zenject
- Both cannot be used together in the same project

## Scope Structure (VContainer)

```csharp
// AppScope.cs — DontDestroyOnLoad, global services
public class AppScope : LifetimeScope
{
    protected override void Configure(IContainerBuilder builder)
    {
        builder.Register<AudioService>(Lifetime.Singleton).As<IAudioService>();
        builder.RegisterComponentInHierarchy<AudioProvider>();
    }
}

// GameScope.cs — Scene-specific services
public class GameScope : LifetimeScope { ... }
```

## Scope Structure (Zenject)

```csharp
public class AppInstaller : MonoInstaller
{
    public override void InstallBindings()
    {
        Container.Bind<IAudioService>().To<AudioService>().AsSingle();
    }
}
```

## Injecting

```csharp
// Constructor injection (pure C#)
public sealed class AudioService : IAudioService
{
    private readonly IEventBus _eventBus;
    public AudioService(IEventBus eventBus) => _eventBus = eventBus;
}

// [Inject] method (MonoBehaviour)
public class AudioProvider : MonoBehaviour
{
    private IAudioService _audioService;
    [Inject] void Construct(IAudioService audioService) => _audioService = audioService;
}
```

## Forbidden Patterns

```csharp
// FORBIDDEN — Singleton
public static AudioService Instance { get; private set; }

// FORBIDDEN — FindObjectOfType
var svc = FindObjectOfType<AudioService>();

// FORBIDDEN — GetComponent fallback
void Start() { _service = GetComponent<AudioService>(); }

// FORBIDDEN — ServiceLocator
ServiceLocator.Get<IAudioService>();
```

## Fail-Fast Principle

Missing dependency → throw exception immediately, do not search silently.

```csharp
// CORRECT
public AudioService(IEventBus eventBus)
{
    _eventBus = eventBus ?? throw new ArgumentNullException(nameof(eventBus));
}
```
