# Dependency Injection Rules

## Zorunlu Container

`project-config.json`'daki `di` değerine göre:
- `"vcontainer"` → VContainer kullan
- `"zenject"` → Zenject kullan
- İkisi aynı projede birlikte kullanılamaz

## Scope Yapısı (VContainer)

```csharp
// AppScope.cs — DontDestroyOnLoad, global servisler
public class AppScope : LifetimeScope
{
    protected override void Configure(IContainerBuilder builder)
    {
        builder.Register<AudioService>(Lifetime.Singleton).As<IAudioService>();
        builder.RegisterComponentInHierarchy<AudioProvider>();
    }
}

// GameScope.cs — Sahneye özel servisler
public class GameScope : LifetimeScope { ... }
```

## Scope Yapısı (Zenject)

```csharp
public class AppInstaller : MonoInstaller
{
    public override void InstallBindings()
    {
        Container.Bind<IAudioService>().To<AudioService>().AsSingle();
    }
}
```

## Inject Etme

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

## Yasak Patternler

```csharp
// YASAK — Singleton
public static AudioService Instance { get; private set; }

// YASAK — FindObjectOfType
var svc = FindObjectOfType<AudioService>();

// YASAK — GetComponent fallback
void Start() { _service = GetComponent<AudioService>(); }

// YASAK — ServiceLocator
ServiceLocator.Get<IAudioService>();
```

## Fail-Fast Prensibi

Eksik dependency → hemen exception fırlat, sessizce arama yapma.

```csharp
// DOĞRU
public AudioService(IEventBus eventBus)
{
    _eventBus = eventBus ?? throw new ArgumentNullException(nameof(eventBus));
}
```
