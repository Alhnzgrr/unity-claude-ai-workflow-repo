---
name: timeline
description: Use when implementing cutscenes, tutorial sequences, boss intros, scripted events, or any time-sequenced gameplay using Unity Timeline and the Playables API.
---

# Unity Timeline & Playables API Skill

## Core Concepts

### PlayableGraph, PlayableAsset, PlayableDirector

```
PlayableDirector (MonoBehaviour)
  └── PlayableAsset (.timeline file)
        └── PlayableGraph (runtime graph, created on Play)
              ├── AnimationTrack → AnimationPlayable
              ├── AudioTrack → AudioClipPlayable
              ├── ActivationTrack → ActivationControlPlayable
              └── Custom Track → ScriptPlayable<TBehaviour>
```

- `PlayableDirector` drives the timeline; it owns the `PlayableGraph`.
- `PlayableAsset` is a `ScriptableObject` (.timeline) serialized to disk — never text-edit it.
- `PlayableGraph` is a runtime-only structure created when `Play()` is called and destroyed when the director stops.

---

## Built-in Tracks

| Track | When to Use |
|---|---|
| `AnimationTrack` | Animate a character or object via Animator. Requires a binding to an `Animator` component. |
| `AudioTrack` | Play audio clips at precise moments. Bind to an `AudioSource`. |
| `ActivationTrack` | Enable/disable a `GameObject` at specific time ranges. |
| `ControlTrack` | Nest other `PlayableDirector` timelines or control Particle Systems. |

### SetGenericBinding by Stream Name (DI Pattern)

Never hard-wire bindings in the Inspector when objects are runtime-instantiated. Use `SetGenericBinding`:

```csharp
// CutsceneService.cs
public sealed class CutsceneService : ICutsceneService, IDisposable
{
    private readonly PlayableDirector _director;
    private readonly CancellationTokenSource _cts = new();

    public CutsceneService(PlayableDirector director)
    {
        _director = director ?? throw new ArgumentNullException(nameof(director));
    }

    /// Bind a runtime object to a named track before Play().
    public void BindTrack(string trackName, Object binding)
    {
        foreach (var output in _director.playableAsset.outputs)
        {
            if (output.streamName == trackName)
            {
                _director.SetGenericBinding(output.sourceObject, binding);
                return;
            }
        }
        throw new InvalidOperationException($"Timeline track '{trackName}' not found.");
    }

    public void Dispose() => _cts.Cancel();
}
```

---

## Custom Track + Custom Clip

### Step 1 — PlayableBehaviour (runtime data + logic)

```csharp
// FlashScreenBehaviour.cs
using Cysharp.Threading.Tasks;
using UnityEngine;
using UnityEngine.Playables;

namespace MyGame.Cutscene
{
    public sealed class FlashScreenBehaviour : PlayableBehaviour
    {
        public Color FlashColor = Color.white;
        public float Intensity = 1f;

        // Called every frame this clip is active
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            if (playerData is not IScreenFlashService flashService) return;

            float weight = info.weight; // blend weight [0..1] from ease-in/out
            flashService.SetFlash(FlashColor, Intensity * weight);
        }

        public override void OnBehaviourPause(Playable playable, FrameData info)
        {
            // called when clip ends or timeline stops — clean up
            if (info.effectivePlayState == PlayState.Paused)
            {
                // access playerData not available here; handle cleanup in OnGraphStop if needed
            }
        }
    }
}
```

### Step 2 — PlayableAsset (clip serialized in .timeline)

```csharp
// FlashScreenClip.cs
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace MyGame.Cutscene
{
    [System.Serializable]
    public sealed class FlashScreenClip : PlayableAsset, ITimelineClipAsset
    {
        public Color FlashColor = Color.white;
        [Range(0f, 1f)] public float Intensity = 1f;

        public ClipCaps clipCaps => ClipCaps.Blending; // enables ease-in/out blending

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = ScriptPlayable<FlashScreenBehaviour>.Create(graph);
            var behaviour = playable.GetBehaviour();
            behaviour.FlashColor = FlashColor;
            behaviour.Intensity = Intensity;
            return playable;
        }
    }
}
```

### Step 3 — TrackAsset + TrackMixer

```csharp
// FlashScreenTrack.cs
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace MyGame.Cutscene
{
    [TrackColor(1f, 0.8f, 0.2f)]
    [TrackClipType(typeof(FlashScreenClip))]
    [TrackBindingType(typeof(MonoBehaviour))] // binds IScreenFlashService provider
    public sealed class FlashScreenTrack : TrackAsset
    {
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            return ScriptPlayable<FlashScreenMixerBehaviour>.Create(graph, inputCount);
        }
    }
}
```

### Step 4 — MixerBehaviour (blends multiple clips on same track)

```csharp
// FlashScreenMixerBehaviour.cs
using UnityEngine;
using UnityEngine.Playables;

namespace MyGame.Cutscene
{
    public sealed class FlashScreenMixerBehaviour : PlayableBehaviour
    {
        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            if (playerData is not IScreenFlashService flashService) return;

            var totalWeight = 0f;
            var blendedColor = Color.black;
            var blendedIntensity = 0f;

            int inputCount = playable.GetInputCount();
            for (int i = 0; i < inputCount; i++)
            {
                float weight = playable.GetInputWeight(i);
                if (weight <= 0f) continue;

                var input = (ScriptPlayable<FlashScreenBehaviour>)playable.GetInput(i);
                var b = input.GetBehaviour();
                blendedColor += b.FlashColor * weight;
                blendedIntensity += b.Intensity * weight;
                totalWeight += weight;
            }

            if (totalWeight > 0f)
                flashService.SetFlash(blendedColor / totalWeight, blendedIntensity);
            else
                flashService.ClearFlash();
        }
    }
}
```

---

## Signal Emitter → IEventBus Pipeline (No UnityEvent)

Unity's built-in `SignalEmitter` fires signals at precise timeline times. Instead of wiring `UnityEvent` receivers, bridge to `IEventBus`.

### Step 1 — Define signal asset

```csharp
// BossIntroSignal.cs
using UnityEngine.Timeline;

namespace MyGame.Cutscene
{
    // ScriptableObject placed in project — created via Timeline signal emitter UI
    public sealed class BossIntroSignal : SignalAsset { }

    public sealed class CutsceneEndSignal : SignalAsset { }
}
```

### Step 2 — INotificationReceiver bridges to IEventBus

```csharp
// TimelineSignalBridge.cs
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using VContainer;

namespace MyGame.Cutscene
{
    /// Attach to the same GameObject as PlayableDirector.
    /// Receives timeline signals and publishes to IEventBus — no UnityEvent.
    public sealed class TimelineSignalBridge : MonoBehaviour, INotificationReceiver
    {
        private IEventBus _eventBus;

        [Inject]
        public void Construct(IEventBus eventBus) => _eventBus = eventBus;

        public void OnNotify(Playable origin, INotification notification, object context)
        {
            switch (notification)
            {
                case SignalEmitter emitter when emitter.asset is BossIntroSignal:
                    _eventBus.Publish(new BossIntroStartedEvent());
                    break;

                case SignalEmitter emitter when emitter.asset is CutsceneEndSignal:
                    _eventBus.Publish(new CutsceneEndedEvent());
                    break;
            }
        }
    }
}
```

### Step 3 — Register receiver with director

```csharp
// In CutsceneService or installer
_director.playableGraph.GetRootPlayable(0); // ensure graph exists
// PlayableDirector.played fires before graph builds; register in Awake/Inject
```

The `INotificationReceiver` on the same `GameObject` is automatically picked up by `PlayableDirector` — no manual registration needed as long as the component is present before `Play()`.

---

## Async Await with UniTaskCompletionSource (No Polling)

```csharp
// CutsceneService.cs (continued)
public sealed class CutsceneService : ICutsceneService, IDisposable
{
    private readonly PlayableDirector _director;
    private readonly CancellationTokenSource _cts = new();
    private UniTaskCompletionSource _completionSource;

    public CutsceneService(PlayableDirector director)
    {
        _director = director ?? throw new ArgumentNullException(nameof(director));
        _director.stopped += OnDirectorStopped;
    }

    /// Plays the timeline and awaits completion — no coroutines, no polling.
    public async UniTask PlayAsync(CancellationToken ct)
    {
        var linked = CancellationTokenSource.CreateLinkedTokenSource(_cts.Token, ct);

        _completionSource = new UniTaskCompletionSource();
        _director.Play();

        // Cancel director if token fires
        linked.Token.Register(() =>
        {
            _director.Stop();
            _completionSource.TrySetCanceled();
        });

        await _completionSource.Task;
    }

    private void OnDirectorStopped(PlayableDirector director)
    {
        _completionSource?.TrySetResult();
    }

    public void Dispose()
    {
        _director.stopped -= OnDirectorStopped;
        _cts.Cancel();
    }
}
```

### Usage from a presenter / view

```csharp
public sealed class BossIntroPresenter : IDisposable
{
    private readonly ICutsceneService _cutscene;

    public BossIntroPresenter(ICutsceneService cutscene) => _cutscene = cutscene;

    public async UniTask ShowBossIntroAsync(CancellationToken ct)
    {
        await _cutscene.PlayAsync(ct);
        // Continues only after director.stopped — no polling
    }
}
```

---

## Addressables — Loading Timeline Assets

```csharp
// TimelineLoader.cs
using Cysharp.Threading.Tasks;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;
using UnityEngine.Timeline;

namespace MyGame.Cutscene
{
    public sealed class TimelineLoader : ITimelineLoader, IDisposable
    {
        private readonly List<AsyncOperationHandle> _handles = new();

        public async UniTask<TimelineAsset> LoadAsync(string key, CancellationToken ct)
        {
            var handle = Addressables.LoadAssetAsync<TimelineAsset>(key);
            _handles.Add(handle);

            await handle.WithCancellation(ct);

            if (handle.Status != AsyncOperationStatus.Succeeded)
                throw new Exception($"Timeline load failed for key: {key}");

            return handle.Result;
        }

        /// Assign loaded asset to director at runtime
        public async UniTask PlayFromAddressAsync(
            PlayableDirector director,
            string key,
            CancellationToken ct)
        {
            var asset = await LoadAsync(key, ct);
            director.playableAsset = asset;
            director.Play();
        }

        public void Dispose()
        {
            foreach (var h in _handles)
                Addressables.Release(h);
            _handles.Clear();
        }
    }
}
```

---

## DI Installer Examples

### VContainer

```csharp
// CutsceneInstaller.cs (VContainer)
using UnityEngine;
using UnityEngine.Playables;
using VContainer;
using VContainer.Unity;

namespace MyGame.Cutscene
{
    public sealed class CutsceneInstaller : IInstaller
    {
        private readonly PlayableDirector _director;

        public CutsceneInstaller(PlayableDirector director) => _director = director;

        public void Install(IContainerBuilder builder)
        {
            builder.RegisterInstance(_director);
            builder.Register<CutsceneService>(Lifetime.Scoped)
                   .As<ICutsceneService>()
                   .As<IDisposable>();
            builder.Register<TimelineLoader>(Lifetime.Scoped)
                   .As<ITimelineLoader>()
                   .As<IDisposable>();
            builder.RegisterComponentInHierarchy<TimelineSignalBridge>();
        }
    }
}

// GameScope.cs
public class GameScope : LifetimeScope
{
    [SerializeField] private PlayableDirector _bossIntroDirector;

    protected override void Configure(IContainerBuilder builder)
    {
        builder.Install(new CutsceneInstaller(_bossIntroDirector));
    }
}
```

### Zenject

```csharp
// CutsceneInstaller.cs (Zenject)
using UnityEngine;
using UnityEngine.Playables;
using Zenject;

namespace MyGame.Cutscene
{
    public sealed class CutsceneInstaller : MonoInstaller
    {
        [SerializeField] private PlayableDirector _bossIntroDirector;

        public override void InstallBindings()
        {
            Container.BindInstance(_bossIntroDirector).AsSingle();
            Container.Bind<ICutsceneService>()
                     .To<CutsceneService>()
                     .AsSingle()
                     .NonLazy();
            Container.Bind<ITimelineLoader>()
                     .To<TimelineLoader>()
                     .AsSingle();
        }
    }
}
```

---

## PlayMode Test Pattern

```csharp
// CutscenePlayTests.cs
using System.Collections;
using Cysharp.Threading.Tasks;
using NUnit.Framework;
using NSubstitute;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.TestTools;

namespace MyGame.Cutscene.Tests
{
    public class CutscenePlayTests
    {
        private PlayableDirector _director;
        private CutsceneService _sut;
        private IEventBus _eventBus;

        [SetUp]
        public void SetUp()
        {
            var go = new GameObject("Director");
            _director = go.AddComponent<PlayableDirector>();
            _eventBus = Substitute.For<IEventBus>();
            _sut = new CutsceneService(_director);
        }

        [TearDown]
        public void TearDown()
        {
            _sut.Dispose();
            Object.Destroy(_director.gameObject);
        }

        [UnityTest]
        public IEnumerator PlayAsync_CompletesWhenDirectorStops() =>
            UniTask.ToCoroutine(async () =>
            {
                // Arrange — create a minimal empty timeline
                var asset = ScriptableObject.CreateInstance<TimelineAsset>();
                _director.playableAsset = asset;
                _director.extrapolationMode = DirectorWrapMode.None;

                // Act
                var cts = new System.Threading.CancellationTokenSource(timeout: System.TimeSpan.FromSeconds(5));
                await _sut.PlayAsync(cts.Token);

                // Assert — no exception means completed
                Assert.IsFalse(_director.state == PlayState.Playing);
            });

        [UnityTest]
        public IEnumerator PlayAsync_CancellationToken_StopsDirector() =>
            UniTask.ToCoroutine(async () =>
            {
                var asset = ScriptableObject.CreateInstance<TimelineAsset>();
                _director.playableAsset = asset;

                var cts = new System.Threading.CancellationTokenSource();
                var playTask = _sut.PlayAsync(cts.Token);

                await UniTask.Yield(); // let director start
                cts.Cancel();

                bool cancelled = false;
                try { await playTask; }
                catch (System.OperationCanceledException) { cancelled = true; }

                Assert.IsTrue(cancelled);
            });
    }
}
```

---

## Common Mistakes

### 1. PlayableDirector Reference Lost After Scene Reload

`PlayableDirector` is a `MonoBehaviour`. If the scene unloads, the reference becomes a destroyed Unity object. Always guard:

```csharp
// WRONG — silent null-ref after scene reload
_director.Play();

// CORRECT
if (_director == null)
    throw new ObjectDisposedException(nameof(PlayableDirector), "Director was destroyed.");
_director.Play();
```

Prefer scoped DI lifetimes (Scoped, not Singleton) so the director is re-injected with each scene load.

### 2. Signal Receiver Not Connected — Silent Fail

`INotificationReceiver` is only invoked if the component is on the **same `GameObject`** as `PlayableDirector`, or manually registered via `director.playableGraph`. If the signal fires but nothing happens, verify:

```csharp
// Diagnostic: list all notification receivers
var graph = _director.playableGraph;
// Ensure TimelineSignalBridge component is on same GO as PlayableDirector
Assert.IsNotNull(_director.GetComponent<TimelineSignalBridge>());
```

### 3. Pause/Resume State Mismatch

`director.Pause()` keeps the `PlayableGraph` alive but stops evaluation. `director.Stop()` destroys the graph. Resuming after `Stop()` calls `Play()` which rebuilds the graph and resets bindings:

```csharp
// WRONG — bindings lost after Stop + Play
_director.Stop();
// ... later ...
_director.Play(); // bindings are gone

// CORRECT — use Pause/Resume for temporary halts
_director.Pause();
// ... later ...
_director.Resume();

// If Stop is required, re-bind before Play
_cutsceneService.BindTrack("Character", _playerAnimator);
_director.Play();
```

### 4. Editing .timeline / .playable Files as Text

`.timeline` and `.playable` files are binary-serialized `ScriptableObject` assets. Never write or patch them as text. All track/clip configuration happens through:
- Unity Editor Timeline window
- `PlayableAsset` `CreatePlayable()` — runtime only
- `SetGenericBinding()` for component bindings

### 5. Using UnityEvent in Signal Receivers

```csharp
// WRONG — UnityEvent in receiver
public void OnNotify(Playable origin, INotification n, object ctx)
{
    onSignalFired.Invoke(); // UnityEvent — forbidden
}

// CORRECT — publish to IEventBus
public void OnNotify(Playable origin, INotification n, object ctx)
{
    if (n is SignalEmitter e && e.asset is BossIntroSignal)
        _eventBus.Publish(new BossIntroStartedEvent());
}
```

### 6. Polling director.state Instead of Awaiting

```csharp
// WRONG — polling every frame
while (_director.state == PlayState.Playing)
    await UniTask.Yield();

// CORRECT — event-driven UniTaskCompletionSource
_completionSource = new UniTaskCompletionSource();
_director.stopped += _ => _completionSource.TrySetResult();
await _completionSource.Task;
```

---

## Quick Reference

```
PlayableDirector.Play()          → builds graph, starts evaluation
PlayableDirector.Pause()         → halts evaluation, keeps graph
PlayableDirector.Resume()        → resumes after Pause
PlayableDirector.Stop()          → destroys graph, resets time to 0
PlayableDirector.time            → get/set playback position (seconds)
PlayableDirector.duration        → total length of asset
PlayableDirector.extrapolationMode = DirectorWrapMode.None → stop at end
SetGenericBinding(track, obj)    → bind runtime object before Play()
playableAsset.outputs            → enumerate tracks by streamName
director.stopped (event)         → fires when playback ends or Stop() called
INotificationReceiver.OnNotify   → receives SignalEmitter firings
```
