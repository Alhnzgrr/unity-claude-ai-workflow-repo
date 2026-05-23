---
name: scene-management
description: Use when implementing scene transitions, additive loading, loading screens, or VContainer/Zenject scope setup across scenes in Unity.
---

# Scene Management Skill

## Decision Table: Single vs Additive Loading

| Scenario | Mode | Reason |
|---|---|---|
| Main Menu → Gameplay | Single | Full memory clear, new scope hierarchy |
| Gameplay → Gameplay (level change) | Single | Prevents memory accumulation |
| HUD / UI overlay on top of gameplay | Additive | HUD lives alongside game scene |
| Boss arena loaded mid-level | Additive | Gameplay scene stays active |
| Persistent background environment | Additive | Shared across multiple game scenes |
| Loading screen itself | Additive | Stays visible during target scene load |
| Cutscene overlay | Additive | Music/state preserved in base scene |

**Rule of thumb:** If the previous scene's state must be destroyed → Single. If it must survive → Additive.

---

## Core Files (5-file module structure)

```
Games/Abstracts/SceneManagement/
└── ISceneManagementService.cs

Games/Concretes/SceneManagement/
├── SceneManagementService.cs
├── SceneManagementConfiguration.cs
├── SceneManagementInstaller.cs
├── SceneManagementEvents.cs
└── SceneManagementProvider.cs
```

---

## Events

```csharp
// SceneManagementEvents.cs
namespace MyGame.SceneManagement
{
    public readonly struct SceneLoadStartedEvent : IEvent
    {
        public readonly string SceneName;
        public SceneLoadStartedEvent(string sceneName) => SceneName = sceneName;
    }

    public readonly struct SceneLoadedEvent : IEvent
    {
        public readonly string SceneName;
        public SceneLoadedEvent(string sceneName) => SceneName = sceneName;
    }

    public readonly struct SceneUnloadedEvent : IEvent
    {
        public readonly string SceneName;
        public SceneUnloadedEvent(string sceneName) => SceneName = sceneName;
    }

    public readonly struct SceneLoadProgressEvent : IEvent
    {
        public readonly string SceneName;
        public readonly float Progress; // 0.0 – 1.0
        public SceneLoadProgressEvent(string sceneName, float progress)
        {
            SceneName = sceneName;
            Progress = progress;
        }
    }
}
```

---

## Interface

```csharp
// ISceneManagementService.cs
namespace MyGame.SceneManagement
{
    public interface ISceneManagementService
    {
        UniTask LoadSceneAsync(string sceneName, LoadSceneMode mode, CancellationToken ct);
        UniTask LoadSceneWithProgressAsync(string sceneName, LoadSceneMode mode,
            IProgress<float> progress, CancellationToken ct);
        UniTask UnloadSceneAsync(string sceneName, CancellationToken ct);
        bool IsSceneLoaded(string sceneName);
    }
}
```

---

## UniTask LoadSceneAsync + Progress

```csharp
// SceneManagementService.cs
using Cysharp.Threading.Tasks;
using UnityEngine.SceneManagement;
using System;
using System.Threading;

namespace MyGame.SceneManagement
{
    public sealed class SceneManagementService : ISceneManagementService, IDisposable
    {
        private readonly IEventBus _eventBus;
        private readonly CancellationTokenSource _cts = new();

        public SceneManagementService(IEventBus eventBus)
        {
            _eventBus = eventBus ?? throw new ArgumentNullException(nameof(eventBus));
        }

        public async UniTask LoadSceneAsync(string sceneName, LoadSceneMode mode,
            CancellationToken ct)
        {
            var linked = CancellationTokenSource.CreateLinkedTokenSource(_cts.Token, ct);

            _eventBus.Publish(new SceneLoadStartedEvent(sceneName));

            var op = SceneManager.LoadSceneAsync(sceneName, mode);
            op.allowSceneActivation = false;

            while (op.progress < 0.9f)
            {
                linked.Token.ThrowIfCancellationRequested();
                await UniTask.Yield(PlayerLoopTiming.Update, linked.Token);
            }

            op.allowSceneActivation = true;
            await UniTask.WaitUntil(() => op.isDone, cancellationToken: linked.Token);

            _eventBus.Publish(new SceneLoadedEvent(sceneName));
        }

        public async UniTask LoadSceneWithProgressAsync(string sceneName, LoadSceneMode mode,
            IProgress<float> progress, CancellationToken ct)
        {
            var linked = CancellationTokenSource.CreateLinkedTokenSource(_cts.Token, ct);

            _eventBus.Publish(new SceneLoadStartedEvent(sceneName));

            var op = SceneManager.LoadSceneAsync(sceneName, mode);
            op.allowSceneActivation = false;

            while (op.progress < 0.9f)
            {
                linked.Token.ThrowIfCancellationRequested();
                // progress range 0–0.9 maps to 0–1 before activation
                progress?.Report(op.progress / 0.9f);
                _eventBus.Publish(new SceneLoadProgressEvent(sceneName, op.progress / 0.9f));
                await UniTask.Yield(PlayerLoopTiming.Update, linked.Token);
            }

            progress?.Report(1f);
            op.allowSceneActivation = true;
            await UniTask.WaitUntil(() => op.isDone, cancellationToken: linked.Token);

            _eventBus.Publish(new SceneLoadedEvent(sceneName));
        }

        public async UniTask UnloadSceneAsync(string sceneName, CancellationToken ct)
        {
            var linked = CancellationTokenSource.CreateLinkedTokenSource(_cts.Token, ct);

            var op = SceneManager.UnloadSceneAsync(sceneName);
            await UniTask.WaitUntil(() => op.isDone, cancellationToken: linked.Token);

            // Reclaim unused assets after unload
            await Resources.UnloadUnusedAssets().ToUniTask(cancellationToken: linked.Token);

            _eventBus.Publish(new SceneUnloadedEvent(sceneName));
        }

        public bool IsSceneLoaded(string sceneName)
        {
            var scene = SceneManager.GetSceneByName(sceneName);
            return scene.IsValid() && scene.isLoaded;
        }

        public void Dispose() => _cts.Cancel();
    }
}
```

---

## VContainer Scope Hierarchy

### AppScope → GameScope (EnqueueParent)

```
[DontDestroyOnLoad scene]
└── AppScope (LifetimeScope, Singleton lifetime)
    ├── IEventBus
    ├── ISceneManagementService
    └── IAudioService

[Game scene]
└── GameScope (LifetimeScope, Scoped lifetime)
    ├── EnqueueParent(AppScope)   ← inherits app-level services
    ├── IPlayerService
    └── IEnemyService
```

```csharp
// AppScope.cs — persists via DontDestroyOnLoad
namespace MyGame.Core
{
    public class AppScope : LifetimeScope
    {
        protected override void Configure(IContainerBuilder builder)
        {
            builder.Register<EventBus>(Lifetime.Singleton).As<IEventBus>();
            builder.Register<SceneManagementService>(Lifetime.Singleton)
                   .As<ISceneManagementService>();
            builder.Register<AudioService>(Lifetime.Singleton).As<IAudioService>();
        }
    }
}
```

```csharp
// GameScope.cs — game scene scope, resolves parent automatically
namespace MyGame.Core
{
    public class GameScope : LifetimeScope
    {
        // Assign AppScope prefab in Inspector → Parent field
        // OR use EnqueueParent in code for runtime-created scopes

        protected override void Configure(IContainerBuilder builder)
        {
            builder.Register<PlayerService>(Lifetime.Scoped).As<IPlayerService>();
            builder.Register<EnemyService>(Lifetime.Scoped).As<IEnemyService>();
            builder.RegisterComponentInHierarchy<PlayerProvider>();
        }
    }
}
```

```csharp
// Runtime scope creation with EnqueueParent (when loading additively at runtime)
namespace MyGame.SceneManagement
{
    public sealed class ScopeBootstrapper
    {
        private readonly LifetimeScope _appScope;

        public ScopeBootstrapper(LifetimeScope appScope)
        {
            _appScope = appScope ?? throw new ArgumentNullException(nameof(appScope));
        }

        public LifetimeScope CreateGameScope(GameObject scopePrefab)
        {
            // EnqueueParent ensures the next created LifetimeScope uses AppScope as parent
            using (LifetimeScope.EnqueueParent(_appScope))
            {
                return Object.Instantiate(scopePrefab).GetComponent<LifetimeScope>();
            }
        }
    }
}
```

---

## SceneReference ScriptableObject Pattern

Avoid magic strings. Use typed ScriptableObject references:

```csharp
// SceneReference.cs — _Framework layer, no game dependencies
using UnityEngine;

namespace Framework.SceneManagement
{
    [CreateAssetMenu(fileName = "SceneRef_", menuName = "Framework/Scene Reference")]
    public class SceneReference : ScriptableObject
    {
        [SerializeField] private string _sceneName;
        [SerializeField] private string _scenePath; // set by custom editor

        public string SceneName => _sceneName;
        public string ScenePath => _scenePath;

        public override string ToString() => _sceneName;
    }
}
```

```csharp
// SceneManagementConfiguration.cs
using UnityEngine;
using Framework.SceneManagement;

namespace MyGame.SceneManagement
{
    [CreateAssetMenu(fileName = "SceneManagementConfiguration",
                     menuName = "MyGame/Configuration/Scene Management")]
    public class SceneManagementConfiguration : ScriptableObject
    {
        [SerializeField] private SceneReference _loadingScene;
        [SerializeField] private SceneReference _mainMenuScene;
        [SerializeField] private SceneReference _gameplayScene;
        [SerializeField] private float _minimumLoadingScreenDuration = 1.5f;

        public SceneReference LoadingScene => _loadingScene;
        public SceneReference MainMenuScene => _mainMenuScene;
        public SceneReference GameplayScene => _gameplayScene;
        public float MinimumLoadingScreenDuration => _minimumLoadingScreenDuration;
    }
}
```

---

## Loading Screen — 10-Step Sequence

```
Step 1:  Player triggers scene transition (e.g., button press, trigger collision)
Step 2:  Publish SceneLoadStartedEvent
Step 3:  Load LoadingScene additively (stays on top)
Step 4:  LoadingScreenView subscribes to SceneLoadProgressEvent, shows progress bar
Step 5:  Unload previous scene (or allow Single mode to handle it)
Step 6:  Load target scene additively (allowSceneActivation = false)
Step 7:  Stream progress 0→1 via SceneLoadProgressEvent
Step 8:  Enforce minimum display duration with UniTask.WhenAll
Step 9:  allowSceneActivation = true → scene activates
Step 10: Unload LoadingScene → Publish SceneLoadedEvent
```

```csharp
// LoadingScreenOrchestrator.cs
namespace MyGame.SceneManagement
{
    public sealed class LoadingScreenOrchestrator : IDisposable
    {
        private readonly ISceneManagementService _sceneService;
        private readonly SceneManagementConfiguration _config;
        private readonly IEventBus _eventBus;
        private readonly CancellationTokenSource _cts = new();

        public LoadingScreenOrchestrator(
            ISceneManagementService sceneService,
            SceneManagementConfiguration config,
            IEventBus eventBus)
        {
            _sceneService = sceneService ?? throw new ArgumentNullException(nameof(sceneService));
            _config = config ?? throw new ArgumentNullException(nameof(config));
            _eventBus = eventBus ?? throw new ArgumentNullException(nameof(eventBus));
        }

        public async UniTask TransitionToAsync(SceneReference targetScene, CancellationToken ct)
        {
            var linked = CancellationTokenSource.CreateLinkedTokenSource(_cts.Token, ct);

            // Step 3: load loading screen additively
            await _sceneService.LoadSceneAsync(
                _config.LoadingScene.SceneName,
                LoadSceneMode.Additive,
                linked.Token);

            var progress = new Progress<float>(p =>
                _eventBus.Publish(new SceneLoadProgressEvent(targetScene.SceneName, p)));

            // Step 5–8: load target + enforce minimum duration in parallel
            await UniTask.WhenAll(
                _sceneService.LoadSceneWithProgressAsync(
                    targetScene.SceneName,
                    LoadSceneMode.Additive,
                    progress,
                    linked.Token),
                UniTask.Delay(
                    TimeSpan.FromSeconds(_config.MinimumLoadingScreenDuration),
                    cancellationToken: linked.Token)
            );

            // Step 10: unload loading screen
            await _sceneService.UnloadSceneAsync(
                _config.LoadingScene.SceneName,
                linked.Token);
        }

        public void Dispose() => _cts.Cancel();
    }
}
```

---

## IAsyncStartable Bootstrap (VContainer)

```csharp
// GameBootstrapper.cs
using VContainer.Unity;

namespace MyGame.Core
{
    public sealed class GameBootstrapper : IAsyncStartable
    {
        private readonly ISceneManagementService _sceneService;
        private readonly SceneManagementConfiguration _config;

        public GameBootstrapper(
            ISceneManagementService sceneService,
            SceneManagementConfiguration config)
        {
            _sceneService = sceneService
                ?? throw new ArgumentNullException(nameof(sceneService));
            _config = config
                ?? throw new ArgumentNullException(nameof(config));
        }

        public async UniTask StartAsync(CancellationToken ct)
        {
            // Wait one frame so all Awake/OnEnable calls complete
            await UniTask.Yield(PlayerLoopTiming.Update, ct);

            await _sceneService.LoadSceneAsync(
                _config.MainMenuScene.SceneName,
                LoadSceneMode.Single,
                ct);
        }
    }
}
```

```csharp
// AppScope registration (add to Configure)
builder.Register<GameBootstrapper>(Lifetime.Singleton).As<IAsyncStartable>();
builder.RegisterInstance(_sceneConfig); // SceneManagementConfiguration SO
```

---

## Installer

```csharp
// SceneManagementInstaller.cs
using VContainer;

namespace MyGame.SceneManagement
{
    public static class SceneManagementInstaller
    {
        public static void Install(IContainerBuilder builder,
            SceneManagementConfiguration config)
        {
            builder.RegisterInstance(config);
            builder.Register<SceneManagementService>(Lifetime.Singleton)
                   .As<ISceneManagementService>();
            builder.Register<LoadingScreenOrchestrator>(Lifetime.Singleton);
        }
    }
}
```

---

## Memory Management

### Resources.UnloadUnusedAssets

Called automatically inside `UnloadSceneAsync` after every scene unload:

```csharp
// Already shown in SceneManagementService.UnloadSceneAsync
await Resources.UnloadUnusedAssets().ToUniTask(cancellationToken: linked.Token);
```

### Addressables Handle Tracking per Scene

When scenes load Addressable assets, track handles per scene and release on unload:

```csharp
// AddressableSceneAssetTracker.cs
namespace MyGame.SceneManagement
{
    public sealed class AddressableSceneAssetTracker : IDisposable
    {
        private readonly Dictionary<string, List<AsyncOperationHandle>> _handlesByScene = new();

        public void Track(string sceneName, AsyncOperationHandle handle)
        {
            if (!_handlesByScene.TryGetValue(sceneName, out var list))
            {
                list = new List<AsyncOperationHandle>();
                _handlesByScene[sceneName] = list;
            }
            list.Add(handle);
        }

        public void ReleaseScene(string sceneName)
        {
            if (!_handlesByScene.TryGetValue(sceneName, out var list)) return;

            foreach (var handle in list)
                Addressables.Release(handle);

            list.Clear();
            _handlesByScene.Remove(sceneName);
        }

        public void Dispose()
        {
            foreach (var (_, list) in _handlesByScene)
                foreach (var handle in list)
                    Addressables.Release(handle);

            _handlesByScene.Clear();
        }
    }
}
```

Subscribe to `SceneUnloadedEvent` to trigger `ReleaseScene`:

```csharp
void OnEnable()  => _eventBus.Subscribe<SceneUnloadedEvent>(OnSceneUnloaded);
void OnDisable() => _eventBus.Unsubscribe<SceneUnloadedEvent>(OnSceneUnloaded);

private void OnSceneUnloaded(SceneUnloadedEvent e)
    => _tracker.ReleaseScene(e.SceneName);
```

---

## PlayMode Test Pattern

```csharp
// SceneManagementServiceTests.cs
namespace MyGame.SceneManagement.Tests
{
    public class SceneManagementServiceTests
    {
        private SceneManagementService _sut;
        private IEventBus _eventBus;

        [SetUp]
        public void SetUp()
        {
            _eventBus = Substitute.For<IEventBus>();
            _sut = new SceneManagementService(_eventBus);
        }

        [TearDown]
        public void TearDown() => _sut.Dispose();

        [UnityTest]
        public IEnumerator LoadSceneAsync_PublishesLoadedEvent() =>
            UniTask.ToCoroutine(async () =>
            {
                // Arrange
                const string sceneName = "TestScene"; // must be in Build Settings
                var ct = new CancellationTokenSource(TimeSpan.FromSeconds(10)).Token;

                // Act
                await _sut.LoadSceneAsync(sceneName, LoadSceneMode.Additive, ct);

                // Assert
                _eventBus.Received(1).Publish(
                    Arg.Is<SceneLoadedEvent>(e => e.SceneName == sceneName));

                // Cleanup
                await _sut.UnloadSceneAsync(sceneName, ct);
            });

        [UnityTest]
        public IEnumerator UnloadSceneAsync_PublishesUnloadedEvent() =>
            UniTask.ToCoroutine(async () =>
            {
                // Arrange
                const string sceneName = "TestScene";
                var ct = new CancellationTokenSource(TimeSpan.FromSeconds(10)).Token;
                await _sut.LoadSceneAsync(sceneName, LoadSceneMode.Additive, ct);

                // Act
                await _sut.UnloadSceneAsync(sceneName, ct);

                // Assert
                _eventBus.Received(1).Publish(
                    Arg.Is<SceneUnloadedEvent>(e => e.SceneName == sceneName));
            });

        [UnityTest]
        public IEnumerator LoadSceneWithProgress_ReportsProgressToOne() =>
            UniTask.ToCoroutine(async () =>
            {
                // Arrange
                const string sceneName = "TestScene";
                var ct = new CancellationTokenSource(TimeSpan.FromSeconds(10)).Token;
                float lastProgress = 0f;
                var progress = new Progress<float>(p => lastProgress = p);

                // Act
                await _sut.LoadSceneWithProgressAsync(
                    sceneName, LoadSceneMode.Additive, progress, ct);

                // Assert
                Assert.AreEqual(1f, lastProgress, 0.001f);

                // Cleanup
                await _sut.UnloadSceneAsync(sceneName, ct);
            });
    }
}
```

---

## Common Mistakes

### 1. DontDestroyOnLoad Abuse

```csharp
// WRONG — manual DontDestroyOnLoad creates untracked singletons
void Awake()
{
    DontDestroyOnLoad(gameObject); // bypasses DI, creates hidden global state
    Instance = this;               // static access: forbidden
}

// CORRECT — AppScope handles persistence automatically
// VContainer's LifetimeScope with DontDestroyOnLoad is set via the component Inspector flag
// Services registered as Singleton in AppScope survive scene loads without manual DDOL
```

### 2. Missing Scope Parent → Null Resolve

```csharp
// WRONG — GameScope created without EnqueueParent, cannot resolve IEventBus
var gameScope = Object.Instantiate(gameScopePrefab);
// NullReferenceException when resolving IEventBus (lives in AppScope)

// CORRECT — parent enqueued before instantiation
using (LifetimeScope.EnqueueParent(_appScope))
{
    var gameScope = Object.Instantiate(gameScopePrefab);
}
```

### 3. NullReferenceException After Scene Unload

```csharp
// WRONG — holding a direct reference to a scene-scoped service after unload
public class MenuController
{
    private IPlayerService _playerService; // lives in GameScope

    void OnMenuOpened()
    {
        _playerService.Reset(); // NullReferenceException — GameScope was disposed
    }
}

// CORRECT — communicate via IEventBus events, never hold cross-scope service references
void OnMenuOpened() => _eventBus.Publish(new MenuOpenedEvent());
```

### 4. FindObjectOfType for Cross-Scene Communication

```csharp
// WRONG — forbidden, brittle, breaks with multiple scenes loaded
var hud = FindObjectOfType<HUDView>();
hud.UpdateScore(score);

// CORRECT — publish event, let HUDView subscribe
_eventBus.Publish(new ScoreChangedEvent(score));
```

### 5. Forgetting allowSceneActivation = false

```csharp
// WRONG — scene activates at 0.9, progress bar never reaches 1 visually
var op = SceneManager.LoadSceneAsync(sceneName);
// op jumps directly to isDone, no time to animate progress

// CORRECT — shown in LoadSceneWithProgressAsync above
op.allowSceneActivation = false;
// hold at 0.9 until progress UI is ready, then set true
```

### 6. Scene Name vs Scene Path

```csharp
// WRONG — path includes "Assets/" prefix, breaks at runtime
SceneManager.LoadSceneAsync("Assets/Scenes/Gameplay.unity");

// CORRECT — use scene name only (as registered in Build Settings)
SceneManager.LoadSceneAsync("Gameplay");

// BEST — use SceneReference ScriptableObject to avoid magic strings entirely
await _sceneService.LoadSceneAsync(_config.GameplayScene.SceneName, mode, ct);
```

### 7. CancellationToken Missing on Public Async Methods

```csharp
// WRONG — no cancellation support, cannot be stopped on scene unload
public async UniTask TransitionAsync(string sceneName)
{
    await _sceneService.LoadSceneAsync(sceneName, LoadSceneMode.Single);
}

// CORRECT — always accept and forward CancellationToken
public async UniTask TransitionAsync(string sceneName, CancellationToken ct)
{
    await _sceneService.LoadSceneAsync(sceneName, LoadSceneMode.Single, ct);
}
```
