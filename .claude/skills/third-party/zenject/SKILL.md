---
name: zenject
description: Zenject/Extenject DI framework pattern'leri. MonoInstaller, Bind, Inject, Signals.
---

# Zenject

> `project-config.json` → `"di": "zenject"` ise auto-yüklenir.

## Installer Hiyerarşisi

```
ProjectContext (DontDestroyOnLoad)   ← ProjectInstaller
└── SceneContext (Sahneye özel)      ← GameInstaller
```

## Bind Yöntemleri

```csharp
public class GameInstaller : MonoInstaller
{
    [SerializeField] private AudioProvider _audioProviderPrefab;
    [SerializeField] private AudioConfiguration _audioConfig;

    public override void InstallBindings()
    {
        // Pure C# singleton
        Container.Bind<IAudioService>().To<AudioService>().AsSingle();

        // MonoBehaviour (Hierarchy'de)
        Container.Bind<AudioProvider>().FromComponentInHierarchy().AsSingle();

        // MonoBehaviour (Prefab'dan)
        Container.Bind<AudioProvider>()
            .FromComponentInNewPrefab(_audioProviderPrefab)
            .AsSingle();

        // ScriptableObject
        Container.BindInstance(_audioConfig).AsSingle();
    }
}
```

## Inject Yöntemleri

```csharp
// Constructor injection
public sealed class AudioService : IAudioService
{
    private readonly IEventBus _eventBus;
    public AudioService(IEventBus eventBus) => _eventBus = eventBus;
}

// [Inject] method (MonoBehaviour)
public class PlayerView : MonoBehaviour
{
    [Inject]
    public void Construct(IPlayerService ps) => _playerService = ps;
    private IPlayerService _playerService;
}
```

## IInitializable, ITickable, IDisposable

```csharp
public sealed class GameEntryPoint : IInitializable, IDisposable
{
    private readonly IGameService _gameService;
    public GameEntryPoint(IGameService gs) => _gameService = gs;

    public void Initialize() => _gameService.Initialize();
    public void Dispose() => _gameService.Cleanup();
}

Container.BindInterfacesTo<GameEntryPoint>().AsSingle();
```
