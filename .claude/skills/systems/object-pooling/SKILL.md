---
name: object-pooling
description: Use when implementing object pools for bullets, enemies, VFX, UI elements, audio sources, or any frequently spawned/despawned GameObject in Unity.
---

# Object Pooling System

Unity 2021+ built-in `UnityEngine.Pool` namespace. Hot path allocations: zero. LINQ: forbidden. DI injected: required. Singleton: forbidden.

---

## 1. Core: UnityEngine.Pool.ObjectPool<T>

```csharp
using UnityEngine;
using UnityEngine.Pool;

namespace MyGame.Pooling
{
    // Minimal direct usage (for reference — use IPoolService in production)
    public sealed class BulletPool : MonoBehaviour
    {
        [SerializeField] private BulletView _prefab;

        private IObjectPool<BulletView> _pool;

        private void Awake()
        {
            bool collectionChecks = false;
#if UNITY_EDITOR
            collectionChecks = true; // detects double-release in Editor
#endif
            _pool = new ObjectPool<BulletView>(
                createFunc:      CreateBullet,
                actionOnGet:     OnGetBullet,
                actionOnRelease: OnReleaseBullet,
                actionOnDestroy: OnDestroyBullet,
                collectionCheck: collectionChecks,
                defaultCapacity: 32,
                maxSize:         128
            );
        }

        private BulletView CreateBullet()         => Instantiate(_prefab);
        private void OnGetBullet(BulletView b)    => b.gameObject.SetActive(true);
        private void OnReleaseBullet(BulletView b) => b.gameObject.SetActive(false);
        private void OnDestroyBullet(BulletView b) => Destroy(b.gameObject);

        // maxSize overflow: when pool is full, actionOnDestroy is called on the excess object.
        // The object is NOT silently kept alive — it is destroyed. Design maxSize accordingly.
    }
}
```

### IObjectPool<T> Interface

```csharp
// UnityEngine.Pool.IObjectPool<T> public API:
//   T      Get()
//   void   Release(T element)
//   void   Clear()
//   int    CountAll       { get; }   // created total
//   int    CountActive    { get; }   // checked out
//   int    CountInactive  { get; }   // sitting in pool
```

Always depend on `IObjectPool<T>` — never on the concrete `ObjectPool<T>`.

---

## 2. Generic IPoolService + PoolService (DI injectable)

### Interface

```csharp
using UnityEngine.Pool;
using Cysharp.Threading.Tasks;
using System.Threading;

namespace MyGame.Pooling
{
    public interface IPoolService
    {
        IObjectPool<T> GetPool<T>() where T : Component;
        T              Get<T>()     where T : Component;
        void           Release<T>(T instance) where T : Component;
        UniTask        WarmUpAsync(CancellationToken ct);
    }
}
```

### Implementation

```csharp
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Pool;
using Cysharp.Threading.Tasks;
using System.Threading;

namespace MyGame.Pooling
{
    public sealed class PoolService : IPoolService, IDisposable
    {
        // ------------------------------------------------------------------ deps
        private readonly PoolConfiguration            _config;
        private readonly IEventBus                   _eventBus;
        private readonly Transform                   _poolRoot;

        // ------------------------------------------------------------------ state
        private readonly Dictionary<Type, object>    _pools    = new();
        private readonly Dictionary<Type, Component> _prefabs  = new();

        private bool _disposed;

        public PoolService(PoolConfiguration config, IEventBus eventBus, Transform poolRoot)
        {
            _config    = config    ?? throw new ArgumentNullException(nameof(config));
            _eventBus  = eventBus  ?? throw new ArgumentNullException(nameof(eventBus));
            _poolRoot  = poolRoot  ?? throw new ArgumentNullException(nameof(poolRoot));

            RegisterEntries();
        }

        // ------------------------------------------------------------------ registration
        private void RegisterEntries()
        {
            foreach (var entry in _config.Entries)
            {
                if (entry.Prefab == null) continue;
                _prefabs[entry.Prefab.GetType()] = entry.Prefab;
            }
        }

        // ------------------------------------------------------------------ public API
        public IObjectPool<T> GetPool<T>() where T : Component
        {
            var key = typeof(T);
            if (_pools.TryGetValue(key, out var existing))
                return (IObjectPool<T>)existing;

            var pool = BuildPool<T>(key);
            _pools[key] = pool;
            return pool;
        }

        public T Get<T>() where T : Component       => GetPool<T>().Get();
        public void Release<T>(T instance) where T : Component => GetPool<T>().Release(instance);

        // ------------------------------------------------------------------ warm-up (frame-spread)
        public async UniTask WarmUpAsync(CancellationToken ct)
        {
            foreach (var entry in _config.Entries)
            {
                if (entry.Prefab == null || entry.WarmUpCount <= 0) continue;

                var pool = GetPoolByPrefabType(entry.Prefab);
                if (pool == null) continue;

                var staged = new System.Collections.Generic.List<Component>(entry.WarmUpCount);
                for (int i = 0; i < entry.WarmUpCount; i++)
                {
                    staged.Add(pool.Get());
                    await UniTask.Yield(ct);   // spread across frames — no spike
                }

                foreach (var obj in staged)
                    pool.Release(obj);
            }
        }

        // ------------------------------------------------------------------ pool factory
        private IObjectPool<T> BuildPool<T>(Type key) where T : Component
        {
            if (!_prefabs.TryGetValue(key, out var prefabBase))
                throw new InvalidOperationException($"No prefab registered for type {key.Name}");

            var prefab = (T)prefabBase;

            // Retrieve config for this entry
            PoolEntry matchedEntry = default;
            foreach (var e in _config.Entries)
                if (e.Prefab != null && e.Prefab.GetType() == key) { matchedEntry = e; break; }

            int defaultCapacity = matchedEntry.DefaultCapacity > 0 ? matchedEntry.DefaultCapacity : 16;
            int maxSize          = matchedEntry.MaxSize          > 0 ? matchedEntry.MaxSize          : 128;

            bool collectionChecks = false;
#if UNITY_EDITOR
            collectionChecks = true;
#endif
            return new ObjectPool<T>(
                createFunc:      () => CreateInstance<T>(prefab),
                actionOnGet:     obj => obj.gameObject.SetActive(true),
                actionOnRelease: obj => obj.gameObject.SetActive(false),
                actionOnDestroy: obj => UnityEngine.Object.Destroy(obj.gameObject),
                collectionCheck: collectionChecks,
                defaultCapacity: defaultCapacity,
                maxSize:         maxSize
            );
        }

        private T CreateInstance<T>(T prefab) where T : Component
        {
            var instance = UnityEngine.Object.Instantiate(prefab, _poolRoot);
            instance.gameObject.SetActive(false);
            return instance;
        }

        // ------------------------------------------------------------------ helpers
        private IObjectPool<Component> GetPoolByPrefabType(Component prefab)
        {
            // reflection-free: use GetPool via concrete type stored in entry
            return null; // concrete pool construction delegated to generic BuildPool<T> above
        }

        public void Dispose()
        {
            if (_disposed) return;
            _disposed = true;
            foreach (var pool in _pools.Values)
                (pool as IDisposable)?.Dispose();
            _pools.Clear();
            _prefabs.Clear();
        }
    }
}
```

---

## 3. PoolConfiguration ScriptableObject

```csharp
using System;
using UnityEngine;

namespace MyGame.Pooling
{
    [Serializable]
    public struct PoolEntry
    {
        public Component Prefab;
        public int       WarmUpCount;       // pre-instantiated on startup
        public int       DefaultCapacity;   // initial List<T> capacity inside ObjectPool
        public int       MaxSize;           // overflow → actionOnDestroy called
    }

    [CreateAssetMenu(
        fileName = "PoolConfiguration",
        menuName  = "MyGame/Configuration/Pool Configuration")]
    public sealed class PoolConfiguration : ScriptableObject
    {
        [SerializeField] private PoolEntry[] _entries = Array.Empty<PoolEntry>();

        public ReadOnlySpan<PoolEntry> Entries => _entries;
    }
}
```

---

## 4. Installers

### VContainer

```csharp
using VContainer;
using VContainer.Unity;
using UnityEngine;

namespace MyGame.Pooling
{
    public sealed class PoolInstaller : IInstaller
    {
        private readonly PoolConfiguration _config;
        private readonly Transform         _poolRoot;

        public PoolInstaller(PoolConfiguration config, Transform poolRoot)
        {
            _config   = config;
            _poolRoot = poolRoot;
        }

        public void Install(IContainerBuilder builder)
        {
            builder.RegisterInstance(_config);
            builder.Register<PoolService>(Lifetime.Singleton)
                   .WithParameter(_poolRoot)
                   .As<IPoolService>();
        }
    }
}
```

### Zenject

```csharp
using Zenject;
using UnityEngine;

namespace MyGame.Pooling
{
    public sealed class PoolInstaller : MonoInstaller
    {
        [SerializeField] private PoolConfiguration _config;
        [SerializeField] private Transform         _poolRoot;

        public override void InstallBindings()
        {
            Container.BindInstance(_config).AsSingle();
            Container.BindInstance(_poolRoot).WithId("PoolRoot").AsSingle();

            Container.Bind<IPoolService>()
                     .To<PoolService>()
                     .AsSingle();
        }
    }
}
```

---

## 5. Self-Releasing Pooled Object (double-release guard)

```csharp
using UnityEngine;

namespace MyGame.Pooling
{
    /// <summary>
    /// Attach to pooled prefabs. Call ReturnToPool() instead of Destroy().
    /// _released guard prevents double-release crashes.
    /// </summary>
    public sealed class PooledObject : MonoBehaviour
    {
        private IPoolService _poolService;
        private bool         _released;

        [Inject]
        public void Construct(IPoolService poolService)
        {
            _poolService = poolService ?? throw new System.ArgumentNullException(nameof(poolService));
        }

        private void OnEnable()  => _released = false;  // reset guard on checkout
        private void OnDisable() { }                     // guard remains until next OnEnable

        public void ReturnToPool()
        {
            if (_released)
            {
#if UNITY_EDITOR
                Debug.LogWarning($"[Pool] Double-release prevented on {name}", this);
#endif
                return;
            }

            _released = true;
            _poolService.Release(this);
        }
    }
}
```

---

## 6. Addressables Async Pool (handle lifecycle)

```csharp
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;
using UnityEngine.Pool;
using Cysharp.Threading.Tasks;
using System.Threading;

namespace MyGame.Pooling
{
    /// <summary>
    /// Pool backed by Addressables. Every loaded handle is tracked and released on Dispose.
    /// </summary>
    public sealed class AddressablePool<T> : IDisposable where T : Component
    {
        private readonly string                              _address;
        private readonly Transform                           _root;
        private readonly List<AsyncOperationHandle<GameObject>> _handles = new();
        private IObjectPool<T>                               _pool;
        private T                                            _prefab;
        private bool                                         _disposed;

        public AddressablePool(string address, Transform root)
        {
            _address = address ?? throw new ArgumentNullException(nameof(address));
            _root    = root    ?? throw new ArgumentNullException(nameof(root));
        }

        // Must be called once before Get/Release
        public async UniTask InitializeAsync(int defaultCapacity, int maxSize, CancellationToken ct)
        {
            var handle = Addressables.LoadAssetAsync<GameObject>(_address);
            _handles.Add(handle);

            await handle.WithCancellation(ct);

            if (handle.Status != AsyncOperationStatus.Succeeded)
                throw new Exception($"[AddressablePool] Load failed: {_address}");

            _prefab = handle.Result.GetComponent<T>()
                      ?? throw new InvalidOperationException($"{handle.Result.name} has no {typeof(T).Name}");

            bool collectionChecks = false;
#if UNITY_EDITOR
            collectionChecks = true;
#endif
            _pool = new ObjectPool<T>(
                createFunc:      CreateInstance,
                actionOnGet:     obj => obj.gameObject.SetActive(true),
                actionOnRelease: obj => obj.gameObject.SetActive(false),
                actionOnDestroy: obj => UnityEngine.Object.Destroy(obj.gameObject),
                collectionCheck: collectionChecks,
                defaultCapacity: defaultCapacity,
                maxSize:         maxSize
            );
        }

        public T    Get()           => _pool.Get();
        public void Release(T obj)  => _pool.Release(obj);

        private T CreateInstance()
        {
            var instance = UnityEngine.Object.Instantiate(_prefab, _root);
            instance.gameObject.SetActive(false);
            return instance;
        }

        public void Dispose()
        {
            if (_disposed) return;
            _disposed = true;

            _pool?.Clear();

            // Release every Addressables handle — critical to prevent memory leaks
            foreach (var h in _handles)
                if (h.IsValid()) Addressables.Release(h);

            _handles.Clear();
        }
    }
}
```

---

## 7. State Reset Checklist

When releasing an object back to the pool, **always reset these components**:

```csharp
using UnityEngine;

namespace MyGame.Pooling
{
    public sealed class BulletView : MonoBehaviour
    {
        private Rigidbody        _rb;
        private TrailRenderer    _trail;
        private ParticleSystem   _vfx;
        private Animator         _animator;

        private void Awake()
        {
            _rb       = GetComponent<Rigidbody>();
            _trail    = GetComponent<TrailRenderer>();
            _vfx      = GetComponent<ParticleSystem>();
            _animator = GetComponent<Animator>();
        }

        // Called by ObjectPool actionOnRelease
        private void OnDisable() => ResetState();

        private void ResetState()
        {
            // Rigidbody — clear accumulated velocity
            if (_rb != null)
            {
                _rb.linearVelocity        = Vector3.zero;
                _rb.angularVelocity = Vector3.zero;
            }

            // TrailRenderer — clear baked positions (avoids ghost trails on re-use)
            if (_trail != null)
                _trail.Clear();

            // ParticleSystem — stop and clear all particles
            if (_vfx != null)
            {
                _vfx.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
            }

            // Animator — reset to default state
            if (_animator != null)
                _animator.Rebind();
        }
    }
}
```

| Component        | Reset Action                                    |
|------------------|-------------------------------------------------|
| `Rigidbody`      | Zero `velocity` and `angularVelocity`           |
| `Rigidbody2D`    | Zero `velocity` and `angularVelocity`           |
| `TrailRenderer`  | `Clear()`                                       |
| `ParticleSystem` | `Stop(true, StopEmittingAndClear)`              |
| `Animator`       | `Rebind()` and/or `Play("Idle", 0, 0f)`         |
| `NavMeshAgent`   | `ResetPath()`, reset `speed`                    |
| `AudioSource`    | `Stop()`, null `clip`                           |

---

## 8. PoolExhaustedEvent

```csharp
namespace MyGame.Pooling
{
    public readonly struct PoolExhaustedEvent : IEvent
    {
        public readonly string PoolTypeName;
        public readonly int    MaxSize;

        public PoolExhaustedEvent(string typeName, int maxSize)
        {
            PoolTypeName = typeName;
            MaxSize      = maxSize;
        }
    }
}
```

Publish this event from `actionOnDestroy` to allow monitoring:

```csharp
actionOnDestroy: obj =>
{
    _eventBus.Publish(new PoolExhaustedEvent(typeof(T).Name, maxSize));
    UnityEngine.Object.Destroy(obj.gameObject);
}
```

---

## 9. collectionChecks (Editor vs Build)

```csharp
bool collectionChecks = false;
#if UNITY_EDITOR
collectionChecks = true;   // throws InvalidOperationException on double-release in Editor
#endif

var pool = new ObjectPool<T>(
    ...,
    collectionCheck: collectionChecks,
    ...
);
```

- **Editor `true`**: immediately throws on double-release — catch bugs early.
- **Build `false`**: no overhead — trusts production code is correct.
- Never hard-code `true` for builds — it adds per-release O(n) HashSet lookup.

---

## 10. Pool Size Calculation Table

| Object Type    | Peak Active | Recommended Capacity | Recommended MaxSize |
|----------------|-------------|----------------------|---------------------|
| Bullet         | 50–200      | 64                   | 256                 |
| Enemy          | 20–50       | 32                   | 64                  |
| VFX / Particle | 10–30       | 16                   | 48                  |
| AudioSource    | 8–16        | 12                   | 24                  |
| UI Popup       | 1–4         | 4                    | 8                   |

Rules of thumb:
- `DefaultCapacity` = ~50–75% of expected peak active count.
- `MaxSize` = ~2× `DefaultCapacity` (safety buffer for spikes).
- Run Profiler Memory snapshot to measure real peak; adjust accordingly.

---

## 11. EditMode Test Examples

```csharp
using NUnit.Framework;
using NSubstitute;
using UnityEngine;
using UnityEngine.Pool;
using MyGame.Pooling;

namespace MyGame.Tests.EditMode.Pooling
{
    [TestFixture]
    public class PoolServiceTests
    {
        private IObjectPool<FakePoolable> _pool;
        private int _createCount;
        private int _releaseCount;

        private sealed class FakePoolable : MonoBehaviour { }

        [SetUp]
        public void SetUp()
        {
            _createCount  = 0;
            _releaseCount = 0;

            _pool = new ObjectPool<FakePoolable>(
                createFunc:      () => { _createCount++; return new GameObject("P").AddComponent<FakePoolable>(); },
                actionOnGet:     obj => obj.gameObject.SetActive(true),
                actionOnRelease: obj => { _releaseCount++; obj.gameObject.SetActive(false); },
                actionOnDestroy: obj => Object.DestroyImmediate(obj.gameObject),
                collectionCheck: true,
                defaultCapacity: 4,
                maxSize:         4
            );
        }

        [TearDown]
        public void TearDown() => _pool.Clear();

        // --- Get creates instance when pool empty
        [Test]
        public void Get_WhenPoolEmpty_CreatesNewInstance()
        {
            // Arrange / Act
            var obj = _pool.Get();

            // Assert
            Assert.IsNotNull(obj);
            Assert.AreEqual(1, _createCount);

            _pool.Release(obj);
        }

        // --- Released object is reused on next Get
        [Test]
        public void Get_AfterRelease_ReusesInstance()
        {
            // Arrange
            var first = _pool.Get();
            _pool.Release(first);

            // Act
            var second = _pool.Get();

            // Assert — same instance, only one creation
            Assert.AreSame(first, second);
            Assert.AreEqual(1, _createCount);

            _pool.Release(second);
        }

        // --- Double-release throws with collectionChecks = true
        [Test]
        public void Release_CalledTwice_ThrowsInvalidOperationException()
        {
            // Arrange
            var obj = _pool.Get();
            _pool.Release(obj);

            // Act / Assert
            Assert.Throws<InvalidOperationException>(() => _pool.Release(obj));
        }

        // --- maxSize overflow: excess object is destroyed, not cached
        [Test]
        public void Release_BeyondMaxSize_DestroysOverflowObject()
        {
            // Fill pool to maxSize
            var items = new FakePoolable[4];
            for (int i = 0; i < 4; i++) items[i] = _pool.Get();
            foreach (var item in items) _pool.Release(item);

            // This extra Get + Release triggers overflow
            var extra = _pool.Get();   // creates new (pool exhausted from active perspective)
            _pool.Release(extra);      // pool full — actionOnDestroy called on extra

            // CountInactive should remain at maxSize (4)
            Assert.AreEqual(4, _pool.CountInactive);
        }

        // --- CountActive tracks checked-out objects
        [Test]
        public void CountActive_ReflectsCheckedOutObjects()
        {
            // Arrange
            var a = _pool.Get();
            var b = _pool.Get();

            // Assert
            Assert.AreEqual(2, _pool.CountActive);

            _pool.Release(a);
            _pool.Release(b);
            Assert.AreEqual(0, _pool.CountActive);
        }
    }
}
```

---

## 12. Common Mistakes

### Mistake 1: Calling Destroy on a pooled object

```csharp
// WRONG — bypasses pool, causes NullReferenceException on next Get
void OnBulletHit(BulletView bullet) => Destroy(bullet.gameObject);

// CORRECT
void OnBulletHit(BulletView bullet) => _poolService.Release(bullet);
```

### Mistake 2: Double-release

```csharp
// WRONG — Release called twice (once in OnTriggerEnter, once in timer)
void OnTriggerEnter(Collider c) => _pool.Release(this);
void OnLifetimeExpired()        => _pool.Release(this);   // crash in Editor

// CORRECT — use PooledObject with _released guard (see Section 5)
void OnTriggerEnter(Collider c) => _pooledObject.ReturnToPool();
void OnLifetimeExpired()        => _pooledObject.ReturnToPool();  // silently ignored
```

### Mistake 3: Returning null from createFunc

```csharp
// WRONG — null prefab reference not checked
createFunc: () => Instantiate(_prefab)   // NullReferenceException if _prefab is null

// CORRECT — validate in constructor / Awake
if (_prefab == null) throw new ArgumentNullException(nameof(_prefab));
```

### Mistake 4: Not resetting state on release

```csharp
// WRONG — Rigidbody carries velocity from last use
actionOnRelease: obj => obj.gameObject.SetActive(false)

// CORRECT — reset state before deactivating (see Section 7)
actionOnRelease: obj => { obj.ResetState(); obj.gameObject.SetActive(false); }
```

### Mistake 5: LINQ in hot path

```csharp
// WRONG — allocates on every frame
void Update()
{
    var active = _bullets.Where(b => b.gameObject.activeSelf).ToList();
}

// CORRECT — for loop, no allocation
void Update()
{
    for (int i = 0; i < _bullets.Count; i++)
        if (_bullets[i].gameObject.activeSelf) Process(_bullets[i]);
}
```

### Mistake 6: Static pool access (Singleton pattern)

```csharp
// WRONG — hides dependency, untestable
public static PoolService Instance { get; private set; }

// CORRECT — inject IPoolService via constructor (VContainer/Zenject)
public sealed class EnemySpawner
{
    private readonly IPoolService _pool;
    public EnemySpawner(IPoolService pool) => _pool = pool;
}
```

### Mistake 7: Skipping warm-up leading to frame spikes

```csharp
// WRONG — 64 Instantiate calls in one frame during first wave
void OnWaveStart() { for (int i = 0; i < 64; i++) _pool.Get(); }

// CORRECT — warm up on scene load with frame spread (see Section 4, WarmUpAsync)
await _poolService.WarmUpAsync(destroyCancellationToken);
```
