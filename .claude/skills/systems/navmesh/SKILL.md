---
name: navmesh
description: Use when implementing enemy AI movement, pathfinding, patrol behavior, NPC navigation, dynamic obstacle avoidance, or runtime NavMesh baking in Unity. Covers NavMeshSurface, NavMeshAgent state machines, NavMeshLink, multi-agent scenarios, and async path calculation.
---

# NavMesh Skill

## Package Selection

### Legacy vs AI Navigation Package

| Feature | Legacy (Built-in) | AI Navigation 2.0.x |
|---|---|---|
| Package | Built-in | `com.unity.ai.navigation` |
| Surface bake | Bake Window only | `NavMeshSurface` component |
| Runtime bake | Limited | `NavMeshBuilder.UpdateNavMeshDataAsync` |
| Links | `OffMeshLink` | `NavMeshLink` (bidirectional) |
| Modifiers | None | `NavMeshModifier` + `NavMeshModifierVolume` |
| Multi-surface | No | Yes (per-agent type) |
| Obstacle carving | `NavMeshObstacle` | `NavMeshObstacle` (improved) |
| Unity 6 support | Deprecated path | Recommended |

**Rule:** Always use `com.unity.ai.navigation` 2.0.x in Unity 6 projects. Never mix `OffMeshLink` with the new `NavMeshLink`.

---

## NavMeshSurface Setup

```csharp
// NavMeshSurface component configuration (via Inspector or code)
// Agent Type       → select the agent type this surface is for
// Collect Objects  → All Game Objects (or Volume for bounded area)
// Include Layers   → LayerMask for walkable geometry
// Use Geometry     → Render Meshes or Physics Colliders
// Default Area     → Walkable
// Override Voxel Size → false (auto) or true for fine-grained control
//   Voxel Size: AgentRadius / 3 is a good default
// Override Tile Size → false (auto) or true
//   Tile Size: 256 voxels is Unity default

// Programmatic bake (synchronous — use only in loading screens)
[SerializeField] private NavMeshSurface _surface;

public void BakeSync()
{
    _surface.BuildNavMesh();
}
```

---

## Module Structure (5-File Pattern)

```
Games/Abstracts/Navigation/
├── INavigationService.cs
└── IPathfindingService.cs

Games/Concretes/Navigation/
├── NavigationService.cs
├── PathfindingService.cs
├── NavigationConfiguration.cs
├── NavigationInstaller.cs
├── NavigationEvents.cs
└── NavigationProvider.cs
```

---

## Interfaces

```csharp
// INavigationService.cs
namespace MyGame.Navigation
{
    public interface INavigationService
    {
        void RegisterAgent(int id, NavigationProvider provider);
        void UnregisterAgent(int id);
        void SetDestination(int id, Vector3 destination);
        void StopAgent(int id);
        bool HasReachedDestination(int id);
    }
}
```

```csharp
// IPathfindingService.cs
namespace MyGame.Navigation
{
    public interface IPathfindingService
    {
        UniTask<NavMeshPath> CalculatePathAsync(Vector3 from, Vector3 to, int areaMask, CancellationToken ct);
        bool IsReachable(Vector3 from, Vector3 to, int areaMask);
    }
}
```

---

## NavigationEvents.cs

```csharp
namespace MyGame.Navigation
{
    public readonly struct EnemyReachedDestinationEvent : IEvent
    {
        public readonly int AgentId;
        public EnemyReachedDestinationEvent(int agentId) => AgentId = agentId;
    }

    public readonly struct PatrolPointReachedEvent : IEvent
    {
        public readonly int AgentId;
        public readonly int PointIndex;
        public PatrolPointReachedEvent(int agentId, int pointIndex)
        {
            AgentId = agentId;
            PointIndex = pointIndex;
        }
    }

    public readonly struct EnemyAttackEvent : IEvent
    {
        public readonly int AgentId;
        public readonly int TargetId;
        public EnemyAttackEvent(int agentId, int targetId)
        {
            AgentId = agentId;
            TargetId = targetId;
        }
    }

    public readonly struct NavMeshRebakeCompletedEvent : IEvent
    {
        public readonly float BakeTimestamp;
        public NavMeshRebakeCompletedEvent(float timestamp) => BakeTimestamp = timestamp;
    }
}
```

---

## NavigationConfiguration.cs

```csharp
using UnityEngine;
using UnityEngine.AI;

namespace MyGame.Navigation
{
    [CreateAssetMenu(fileName = "NavigationConfiguration", menuName = "MyGame/Navigation/Configuration")]
    public sealed class NavigationConfiguration : ScriptableObject
    {
        [Header("Agent Defaults")]
        [SerializeField] private float _speed = 3.5f;
        [SerializeField] private float _angularSpeed = 120f;
        [SerializeField] private float _acceleration = 8f;
        [SerializeField] private float _stoppingDistance = 0.5f;
        [SerializeField] private ObstacleAvoidanceType _avoidanceType = ObstacleAvoidanceType.LowQualityObstacleAvoidance;

        [Header("Throttle")]
        [SerializeField] private float _destinationUpdateInterval = 0.2f;
        [SerializeField] private float _reachedCheckInterval = 0.1f;

        [Header("NavMesh Bake")]
        [SerializeField] private float _minRebakeInterval = 0.5f;

        [Header("LOD")]
        [SerializeField] private float _highQualityDistance = 20f;
        [SerializeField] private float _mediumQualityDistance = 40f;

        public float Speed => _speed;
        public float AngularSpeed => _angularSpeed;
        public float Acceleration => _acceleration;
        public float StoppingDistance => _stoppingDistance;
        public ObstacleAvoidanceType AvoidanceType => _avoidanceType;
        public float DestinationUpdateInterval => _destinationUpdateInterval;
        public float ReachedCheckInterval => _reachedCheckInterval;
        public float MinRebakeInterval => _minRebakeInterval;
        public float HighQualityDistance => _highQualityDistance;
        public float MediumQualityDistance => _mediumQualityDistance;
    }
}
```

---

## NavigationProvider.cs (MonoBehaviour)

```csharp
using UnityEngine;
using UnityEngine.AI;
using VContainer;

namespace MyGame.Navigation
{
    [RequireComponent(typeof(NavMeshAgent))]
    public sealed class NavigationProvider : MonoBehaviour
    {
        private NavMeshAgent _agent;
        private INavigationService _navigationService;
        private int _agentId;

        [Inject]
        public void Construct(INavigationService navigationService)
        {
            _navigationService = navigationService
                ?? throw new ArgumentNullException(nameof(navigationService));
        }

        private void Awake()
        {
            _agent = GetComponent<NavMeshAgent>();
            _agentId = gameObject.GetInstanceID();
        }

        private void OnEnable()
        {
            _navigationService.RegisterAgent(_agentId, this);
        }

        private void OnDisable()
        {
            if (_agent != null && _agent.isActiveAndEnabled && _agent.isOnNavMesh)
            {
                _agent.isStopped = true;
                _agent.ResetPath();
            }
            _navigationService.UnregisterAgent(_agentId);
        }

        public int AgentId => _agentId;

        public bool SetDestination(Vector3 destination)
        {
            if (!IsAgentValid()) return false;

            return _agent.SetDestination(destination);
        }

        public void Stop()
        {
            if (!IsAgentValid()) return;

            _agent.isStopped = true;
            _agent.ResetPath();
        }

        public void Resume()
        {
            if (!IsAgentValid()) return;

            _agent.isStopped = false;
        }

        public bool HasReachedDestination()
        {
            if (!IsAgentValid()) return false;
            if (_agent.pathPending) return false;
            if (_agent.pathStatus != NavMeshPathStatus.PathComplete) return false;
            if (_agent.remainingDistance > _agent.stoppingDistance) return false;

            return !_agent.hasPath || _agent.velocity.sqrMagnitude < 0.01f;
        }

        public bool IsPathValid()
        {
            if (!IsAgentValid()) return false;
            return _agent.pathStatus == NavMeshPathStatus.PathComplete;
        }

        public void SetAvoidanceQuality(ObstacleAvoidanceType quality)
        {
            if (_agent != null)
                _agent.obstacleAvoidanceType = quality;
        }

        public void SetAvoidancePriority(int priority)
        {
            if (_agent != null)
                _agent.avoidancePriority = Mathf.Clamp(priority, 0, 99);
        }

        public void ConfigureAgent(NavigationConfiguration config)
        {
            if (_agent == null) return;

            _agent.speed = config.Speed;
            _agent.angularSpeed = config.AngularSpeed;
            _agent.acceleration = config.Acceleration;
            _agent.stoppingDistance = config.StoppingDistance;
            _agent.obstacleAvoidanceType = config.AvoidanceType;
        }

        private bool IsAgentValid()
        {
            return _agent != null
                && _agent.isActiveAndEnabled
                && _agent.isOnNavMesh;
        }
    }
}
```

---

## NavigationService.cs

```csharp
using System;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using UnityEngine;

namespace MyGame.Navigation
{
    public sealed class NavigationService : INavigationService, IDisposable
    {
        private readonly Dictionary<int, NavigationProvider> _agents = new();
        private readonly IEventBus _eventBus;
        private readonly NavigationConfiguration _config;
        private readonly CancellationTokenSource _cts = new();

        public NavigationService(IEventBus eventBus, NavigationConfiguration config)
        {
            _eventBus = eventBus ?? throw new ArgumentNullException(nameof(eventBus));
            _config = config ?? throw new ArgumentNullException(nameof(config));

            TickAsync(_cts.Token).Forget();
        }

        public void RegisterAgent(int id, NavigationProvider provider)
        {
            if (provider == null) throw new ArgumentNullException(nameof(provider));
            _agents[id] = provider;
            provider.ConfigureAgent(_config);
        }

        public void UnregisterAgent(int id)
        {
            _agents.Remove(id);
        }

        public void SetDestination(int id, Vector3 destination)
        {
            if (_agents.TryGetValue(id, out var provider))
                provider.SetDestination(destination);
        }

        public void StopAgent(int id)
        {
            if (_agents.TryGetValue(id, out var provider))
                provider.Stop();
        }

        public bool HasReachedDestination(int id)
        {
            return _agents.TryGetValue(id, out var provider)
                && provider.HasReachedDestination();
        }

        private async UniTaskVoid TickAsync(CancellationToken ct)
        {
            while (!ct.IsCancellationRequested)
            {
                await UniTask.Delay(
                    TimeSpan.FromSeconds(_config.ReachedCheckInterval),
                    cancellationToken: ct);

                foreach (var kvp in _agents)
                {
                    if (kvp.Value.HasReachedDestination())
                        _eventBus.Publish(new EnemyReachedDestinationEvent(kvp.Key));
                }
            }
        }

        public void Dispose() => _cts.Cancel();
    }
}
```

---

## PathfindingService.cs

```csharp
using System;
using Cysharp.Threading.Tasks;
using UnityEngine;
using UnityEngine.AI;

namespace MyGame.Navigation
{
    public sealed class PathfindingService : IPathfindingService
    {
        public async UniTask<NavMeshPath> CalculatePathAsync(
            Vector3 from,
            Vector3 to,
            int areaMask,
            CancellationToken ct)
        {
            ct.ThrowIfCancellationRequested();

            // Move calculation off the main thread
            await UniTask.SwitchToThreadPool();
            ct.ThrowIfCancellationRequested();

            var path = new NavMeshPath();
            NavMesh.CalculatePath(from, to, areaMask, path);

            // NavMesh API results are safe to read on thread pool,
            // but any Unity component access must be back on main thread
            await UniTask.SwitchToMainThread(ct);

            return path;
        }

        public bool IsReachable(Vector3 from, Vector3 to, int areaMask)
        {
            var path = new NavMeshPath();
            NavMesh.CalculatePath(from, to, areaMask, path);
            return path.status == NavMeshPathStatus.PathComplete;
        }
    }
}
```

---

## EnemyAIService — State Machine (Patrol → Chase → Attack → Dead)

```csharp
using System;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using UnityEngine;

namespace MyGame.Navigation
{
    public enum EnemyState { Patrol, Chase, Attack, Dead }

    public sealed class EnemyAIService : IDisposable
    {
        private readonly INavigationService _navigationService;
        private readonly IEventBus _eventBus;
        private readonly NavigationConfiguration _config;

        private readonly int _agentId;
        private readonly Transform _transform;
        private readonly Transform _target;
        private readonly IReadOnlyList<Transform> _patrolPoints;

        private EnemyState _currentState;
        private CancellationTokenSource _stateCts;
        private int _patrolIndex;

        private const float ATTACK_RANGE = 2f;
        private const float CHASE_RANGE = 15f;

        public EnemyAIService(
            INavigationService navigationService,
            IEventBus eventBus,
            NavigationConfiguration config,
            int agentId,
            Transform transform,
            Transform target,
            IReadOnlyList<Transform> patrolPoints)
        {
            _navigationService = navigationService
                ?? throw new ArgumentNullException(nameof(navigationService));
            _eventBus = eventBus
                ?? throw new ArgumentNullException(nameof(eventBus));
            _config = config
                ?? throw new ArgumentNullException(nameof(config));
            _agentId = agentId;
            _transform = transform;
            _target = target;
            _patrolPoints = patrolPoints;

            TransitionTo(EnemyState.Patrol);
        }

        public void TransitionTo(EnemyState newState)
        {
            // Cancel current state loop
            _stateCts?.Cancel();
            _stateCts?.Dispose();
            _stateCts = new CancellationTokenSource();

            _currentState = newState;
            EnterState(newState, _stateCts.Token).Forget();
        }

        private async UniTaskVoid EnterState(EnemyState state, CancellationToken ct)
        {
            switch (state)
            {
                case EnemyState.Patrol:
                    await RunPatrolAsync(ct);
                    break;
                case EnemyState.Chase:
                    await RunChaseAsync(ct);
                    break;
                case EnemyState.Attack:
                    await RunAttackAsync(ct);
                    break;
                case EnemyState.Dead:
                    _navigationService.StopAgent(_agentId);
                    break;
            }
        }

        private async UniTask RunPatrolAsync(CancellationToken ct)
        {
            while (!ct.IsCancellationRequested)
            {
                if (_patrolPoints == null || _patrolPoints.Count == 0)
                {
                    await UniTask.Delay(TimeSpan.FromSeconds(1f), cancellationToken: ct);
                    continue;
                }

                var point = _patrolPoints[_patrolIndex];
                _navigationService.SetDestination(_agentId, point.position);

                // Wait until reached
                await UniTask.WaitUntil(
                    () => _navigationService.HasReachedDestination(_agentId),
                    cancellationToken: ct);

                _eventBus.Publish(new PatrolPointReachedEvent(_agentId, _patrolIndex));

                // Idle at patrol point
                await UniTask.Delay(TimeSpan.FromSeconds(2f), cancellationToken: ct);

                _patrolIndex = (_patrolIndex + 1) % _patrolPoints.Count;

                // Check if target is visible — transition to chase
                if (_target != null)
                {
                    float dist = Vector3.Distance(_transform.position, _target.position);
                    if (dist < CHASE_RANGE)
                    {
                        TransitionTo(EnemyState.Chase);
                        return;
                    }
                }
            }
        }

        private async UniTask RunChaseAsync(CancellationToken ct)
        {
            while (!ct.IsCancellationRequested)
            {
                if (_target == null)
                {
                    TransitionTo(EnemyState.Patrol);
                    return;
                }

                float dist = Vector3.Distance(_transform.position, _target.position);

                if (dist <= ATTACK_RANGE)
                {
                    TransitionTo(EnemyState.Attack);
                    return;
                }

                if (dist > CHASE_RANGE)
                {
                    TransitionTo(EnemyState.Patrol);
                    return;
                }

                // Throttle SetDestination — do NOT call every frame
                _navigationService.SetDestination(_agentId, _target.position);

                await UniTask.Delay(
                    TimeSpan.FromSeconds(_config.DestinationUpdateInterval),
                    cancellationToken: ct);
            }
        }

        private async UniTask RunAttackAsync(CancellationToken ct)
        {
            while (!ct.IsCancellationRequested)
            {
                if (_target == null)
                {
                    TransitionTo(EnemyState.Patrol);
                    return;
                }

                float dist = Vector3.Distance(_transform.position, _target.position);

                if (dist > ATTACK_RANGE)
                {
                    TransitionTo(EnemyState.Chase);
                    return;
                }

                _navigationService.StopAgent(_agentId);
                _eventBus.Publish(new EnemyAttackEvent(_agentId, _target.gameObject.GetInstanceID()));

                await UniTask.Delay(TimeSpan.FromSeconds(1f), cancellationToken: ct);
            }
        }

        public void Dispose()
        {
            _stateCts?.Cancel();
            _stateCts?.Dispose();
        }
    }
}
```

---

## Runtime NavMesh Baking

```csharp
using System;
using Cysharp.Threading.Tasks;
using Unity.AI.Navigation;
using UnityEngine;
using UnityEngine.AI;

namespace MyGame.Navigation
{
    public sealed class NavMeshBakeService : IDisposable
    {
        private readonly NavMeshSurface _surface;
        private readonly IEventBus _eventBus;
        private readonly NavigationConfiguration _config;
        private readonly CancellationTokenSource _cts = new();

        private float _lastBakeTime = float.MinValue;
        private bool _pendingRebake;

        public NavMeshBakeService(
            NavMeshSurface surface,
            IEventBus eventBus,
            NavigationConfiguration config)
        {
            _surface = surface ?? throw new ArgumentNullException(nameof(surface));
            _eventBus = eventBus ?? throw new ArgumentNullException(nameof(eventBus));
            _config = config ?? throw new ArgumentNullException(nameof(config));
        }

        /// <summary>
        /// Synchronous bake — use ONLY during loading screens. Blocks the main thread.
        /// </summary>
        public void BakeSync()
        {
            _surface.BuildNavMesh();
            _lastBakeTime = Time.realtimeSinceStartup;
            _eventBus.Publish(new NavMeshRebakeCompletedEvent(_lastBakeTime));
        }

        /// <summary>
        /// Incremental async bake — safe to call during gameplay.
        /// Throttled: minimum interval enforced via config.
        /// </summary>
        public void RequestRebake()
        {
            _pendingRebake = true;
            if (!_cts.IsCancellationRequested)
                ProcessRebakeAsync(_cts.Token).Forget();
        }

        private async UniTaskVoid ProcessRebakeAsync(CancellationToken ct)
        {
            if (!_pendingRebake) return;

            float elapsed = Time.realtimeSinceStartup - _lastBakeTime;
            if (elapsed < _config.MinRebakeInterval)
            {
                float wait = _config.MinRebakeInterval - elapsed;
                await UniTask.Delay(TimeSpan.FromSeconds(wait), cancellationToken: ct);
            }

            _pendingRebake = false;
            _lastBakeTime = Time.realtimeSinceStartup;

            // Collect all sources — always pass the full set; partial collections cause holes
            var sources = new System.Collections.Generic.List<NavMeshBuildSource>();
            var markups = new System.Collections.Generic.List<NavMeshBuildMarkup>();
            NavMeshBuilder.CollectSources(
                _surface.transform,
                _surface.layerMask,
                _surface.useGeometry,
                _surface.defaultArea,
                markups,
                sources);

            var bounds = new Bounds(
                _surface.transform.position,
                new Vector3(500f, 100f, 500f));

            var data = _surface.navMeshData;
            if (data == null)
            {
                data = new NavMeshData();
                _surface.navMeshData = data;
            }

            var op = NavMeshBuilder.UpdateNavMeshDataAsync(
                data,
                _surface.GetBuildSettings(),
                sources,
                bounds);

            await op.WithCancellation(ct);

            _eventBus.Publish(new NavMeshRebakeCompletedEvent(Time.realtimeSinceStartup));
        }

        public void Dispose() => _cts.Cancel();
    }
}
```

---

## NavMeshLink Runtime Control

```csharp
using Unity.AI.Navigation;
using UnityEngine;

namespace MyGame.Navigation
{
    // NavMeshLink configuration reference:
    // agentTypeID   — which agent type can use this link
    // bidirectional — allow traversal in both directions
    // costOverride  — -1 = use area cost, >0 = override
    // area          — NavMesh area type
    // activated     — runtime enable/disable

    public sealed class NavigationLinkController : MonoBehaviour
    {
        [SerializeField] private NavMeshLink _link;

        public void EnableLink() => _link.activated = true;
        public void DisableLink() => _link.activated = false;

        public void SetCostOverride(float cost)
        {
            // -1 reverts to area default
            _link.costOverride = cost;
            _link.UpdateLink();
        }
    }
}
```

---

## NavMeshObstacle Rules

```csharp
// NavMeshObstacle configuration:
// carving              = true   → punches a hole in the NavMesh
// carvingMoveThreshold = 0.1    → min movement before re-carving
// carvingTimeToStationary = 0.5 → seconds stationary before carving
//
// LIMIT: maximum 20 simultaneous carving obstacles.
// For more than 20 dynamic objects, disable carving and rely on avoidance.

using UnityEngine;
using UnityEngine.AI;

namespace MyGame.Navigation
{
    public sealed class DynamicObstacleController : MonoBehaviour
    {
        [SerializeField] private NavMeshObstacle _obstacle;

        // Call when the object stops moving (e.g., after physics settles)
        public void EnableCarving()
        {
            _obstacle.carving = true;
        }

        // Call when the object starts moving to avoid constant re-carving
        public void DisableCarving()
        {
            _obstacle.carving = false;
        }
    }
}
```

---

## Multi-Agent: Avoidance Priority & LOD

```csharp
using System;
using UnityEngine;
using UnityEngine.AI;

namespace MyGame.Navigation
{
    public sealed class MultiAgentLODService : IDisposable
    {
        private readonly INavigationService _navigationService;
        private readonly NavigationConfiguration _config;
        private readonly Transform _playerTransform;
        private readonly CancellationTokenSource _cts = new();

        private static readonly System.Random _random = new();

        public MultiAgentLODService(
            INavigationService navigationService,
            NavigationConfiguration config,
            Transform playerTransform)
        {
            _navigationService = navigationService
                ?? throw new ArgumentNullException(nameof(navigationService));
            _config = config
                ?? throw new ArgumentNullException(nameof(config));
            _playerTransform = playerTransform
                ?? throw new ArgumentNullException(nameof(playerTransform));
        }

        /// <summary>
        /// Randomize avoidance priority to prevent agents locking up in tight spaces.
        /// Call once when registering a new agent.
        /// </summary>
        public void AssignRandomPriority(NavigationProvider provider)
        {
            // 0 = highest priority, 99 = lowest
            int priority = _random.Next(30, 70);
            provider.SetAvoidancePriority(priority);
        }

        /// <summary>
        /// Adjust avoidance quality based on distance to player.
        /// Call from a throttled tick (not every frame).
        /// </summary>
        public void UpdateLOD(NavigationProvider provider, Vector3 agentPosition)
        {
            float dist = Vector3.Distance(agentPosition, _playerTransform.position);

            ObstacleAvoidanceType quality;
            if (dist <= _config.HighQualityDistance)
                quality = ObstacleAvoidanceType.HighQualityObstacleAvoidance;
            else if (dist <= _config.MediumQualityDistance)
                quality = ObstacleAvoidanceType.MedQualityObstacleAvoidance;
            else
                quality = ObstacleAvoidanceType.NoObstacleAvoidance;

            provider.SetAvoidanceQuality(quality);
        }

        /// <summary>
        /// Formation offset: spread agents so they don't stack on the same destination.
        /// </summary>
        public Vector3 GetFormationOffset(int agentIndex, int totalAgents, float radius = 2f)
        {
            if (totalAgents <= 1) return Vector3.zero;

            float angle = (agentIndex / (float)totalAgents) * Mathf.PI * 2f;
            return new Vector3(
                Mathf.Cos(angle) * radius,
                0f,
                Mathf.Sin(angle) * radius);
        }

        public void Dispose() => _cts.Cancel();
    }
}
```

---

## Performance Reference

| Operation | Cost | Notes |
|---|---|---|
| `agent.SetDestination()` | Medium | Triggers path calculation. Throttle to 0.1–0.2s. Never call every frame. |
| `NavMesh.CalculatePath()` | Medium–High | Synchronous. Move to thread pool via `PathfindingService`. |
| `NavMeshBuilder.UpdateNavMeshDataAsync()` | High | Async. Throttle minimum 0.5s. Always collect all sources. |
| `NavMeshObstacle` carving | Medium per object | Max 20 simultaneous. Disable carving on moving objects. |
| `agent.remainingDistance` | Low | Safe in throttled tick. Avoid raw Update polling. |
| `agent.pathStatus` | Low | Check in throttled tick, not per frame. |
| Agent count (high quality) | — | ≤ 50 agents with `HighQualityObstacleAvoidance`. |
| Agent count (no avoidance) | — | ≤ 300 agents with `NoObstacleAvoidance` + LOD. |

---

## NavMeshInstaller (VContainer)

```csharp
using UnityEngine;
using VContainer;
using VContainer.Unity;

namespace MyGame.Navigation
{
    public sealed class NavigationInstaller : LifetimeScope
    {
        [SerializeField] private NavigationConfiguration _config;
        [SerializeField] private Unity.AI.Navigation.NavMeshSurface _surface;

        protected override void Configure(IContainerBuilder builder)
        {
            // Configuration
            builder.RegisterInstance(_config);

            // Services
            builder.Register<NavigationService>(Lifetime.Singleton)
                   .As<INavigationService>();

            builder.Register<PathfindingService>(Lifetime.Singleton)
                   .As<IPathfindingService>();

            builder.Register<NavMeshBakeService>(Lifetime.Singleton);
            builder.RegisterInstance(_surface);

            // MonoBehaviour providers — registered via hierarchy scan
            builder.RegisterComponentInHierarchy<NavigationProvider>();
        }
    }
}
```

## NavMeshInstaller (Zenject)

```csharp
using UnityEngine;
using Zenject;

namespace MyGame.Navigation
{
    public sealed class NavigationInstaller : MonoInstaller
    {
        [SerializeField] private NavigationConfiguration _config;
        [SerializeField] private Unity.AI.Navigation.NavMeshSurface _surface;

        public override void InstallBindings()
        {
            Container.BindInstance(_config).AsSingle();
            Container.BindInstance(_surface).AsSingle();

            Container.Bind<INavigationService>()
                     .To<NavigationService>()
                     .AsSingle();

            Container.Bind<IPathfindingService>()
                     .To<PathfindingService>()
                     .AsSingle();

            Container.Bind<NavMeshBakeService>().AsSingle();
        }
    }
}
```

---

## EditMode Tests (NSubstitute)

```csharp
using NSubstitute;
using NUnit.Framework;
using UnityEngine;

namespace MyGame.Navigation.Tests.EditMode
{
    [TestFixture]
    public class NavigationServiceTests
    {
        private NavigationService _sut;
        private IEventBus _eventBus;
        private NavigationConfiguration _config;

        [SetUp]
        public void SetUp()
        {
            _eventBus = Substitute.For<IEventBus>();

            _config = ScriptableObject.CreateInstance<NavigationConfiguration>();
            // NavigationConfiguration uses serialized fields; use defaults

            _sut = new NavigationService(_eventBus, _config);
        }

        [TearDown]
        public void TearDown()
        {
            _sut.Dispose();
            ScriptableObject.DestroyImmediate(_config);
        }

        [Test]
        public void RegisterAgent_ThenUnregister_DoesNotThrow()
        {
            // Arrange
            var provider = Substitute.For<NavigationProvider>();

            // Act & Assert
            Assert.DoesNotThrow(() =>
            {
                _sut.RegisterAgent(1, provider);
                _sut.UnregisterAgent(1);
            });
        }

        [Test]
        public void SetDestination_UnknownId_DoesNotThrow()
        {
            // Arrange — no agent registered with id 999

            // Act & Assert
            Assert.DoesNotThrow(() => _sut.SetDestination(999, Vector3.zero));
        }

        [Test]
        public void HasReachedDestination_UnknownId_ReturnsFalse()
        {
            // Act
            bool result = _sut.HasReachedDestination(999);

            // Assert
            Assert.IsFalse(result);
        }

        [Test]
        public void Constructor_NullEventBus_ThrowsArgumentNullException()
        {
            // Act & Assert
            Assert.Throws<ArgumentNullException>(() =>
                new NavigationService(null, _config));
        }
    }
}
```

```csharp
using NUnit.Framework;
using UnityEngine;
using UnityEngine.AI;

namespace MyGame.Navigation.Tests.EditMode
{
    [TestFixture]
    public class PathfindingServiceTests
    {
        private PathfindingService _sut;

        [SetUp]
        public void SetUp()
        {
            _sut = new PathfindingService();
        }

        [Test]
        public void IsReachable_SamePoint_ReturnsTrueOrFalse_DoesNotThrow()
        {
            // NavMesh is not baked in EditMode — result is false, but no exception
            Assert.DoesNotThrow(() =>
                _sut.IsReachable(Vector3.zero, Vector3.one, NavMesh.AllAreas));
        }
    }
}
```

---

## PlayMode Test (NavMesh Baked Scene)

```csharp
using System.Collections;
using Cysharp.Threading.Tasks;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.TestTools;

namespace MyGame.Navigation.Tests.PlayMode
{
    public class NavigationPlayTests
    {
        private GameObject _planeGo;
        private GameObject _agentGo;
        private NavMeshSurface _surface;

        [UnitySetUp]
        public IEnumerator SetUp()
        {
            // Create walkable plane
            _planeGo = GameObject.CreatePrimitive(PrimitiveType.Plane);
            _planeGo.transform.localScale = new Vector3(5f, 1f, 5f);

            // Bake NavMesh
            _surface = _planeGo.AddComponent<NavMeshSurface>();
            _surface.BuildNavMesh();

            // Create agent at center of plane
            _agentGo = new GameObject("TestAgent");
            _agentGo.AddComponent<NavMeshAgent>();
            _agentGo.transform.position = Vector3.zero;

            yield return null; // Wait for agent to be placed on NavMesh
        }

        [UnityTearDown]
        public IEnumerator TearDown()
        {
            Object.Destroy(_agentGo);
            Object.Destroy(_planeGo);
            yield return null;
        }

        [UnityTest]
        public IEnumerator NavMeshAgent_SetDestination_AgentMovesTowardsTarget()
        {
            // Arrange
            var agent = _agentGo.GetComponent<NavMeshAgent>();
            Assert.IsTrue(agent.isOnNavMesh, "Agent must be on NavMesh");

            var destination = new Vector3(3f, 0f, 3f);

            // Act
            agent.SetDestination(destination);
            yield return new WaitForSeconds(0.5f);

            // Assert — agent has moved from origin
            Assert.Greater(_agentGo.transform.position.magnitude, 0.1f,
                "Agent should have moved towards destination");
        }

        [UnityTest]
        public IEnumerator NavMeshAgent_ReachesDestination_RemainingDistanceNearZero()
        {
            // Arrange
            var agent = _agentGo.GetComponent<NavMeshAgent>();
            agent.stoppingDistance = 0.2f;
            var destination = new Vector3(1f, 0f, 1f);

            // Act
            agent.SetDestination(destination);

            // Wait until reached (max 5 seconds)
            float timeout = 5f;
            float elapsed = 0f;
            while (elapsed < timeout)
            {
                elapsed += Time.deltaTime;
                if (!agent.pathPending
                    && agent.pathStatus == NavMeshPathStatus.PathComplete
                    && agent.remainingDistance <= agent.stoppingDistance)
                    break;
                yield return null;
            }

            // Assert
            Assert.LessOrEqual(agent.remainingDistance, agent.stoppingDistance + 0.1f,
                "Agent should have reached destination");
        }
    }
}
```

---

## Common Mistakes (12)

### 1. SetDestination Every Frame — Throttle Required

```csharp
// WRONG — hammers pathfinding system every frame
void Update()
{
    _agent.SetDestination(_target.position);
}

// CORRECT — throttled via UniTask
private async UniTask ChaseAsync(CancellationToken ct)
{
    while (!ct.IsCancellationRequested)
    {
        _navigationService.SetDestination(_agentId, _target.position);
        await UniTask.Delay(TimeSpan.FromSeconds(0.2f), cancellationToken: ct);
    }
}
```

### 2. Missing isOnNavMesh Guard

```csharp
// WRONG — crashes if agent falls off NavMesh
_agent.SetDestination(destination);

// CORRECT — guard in NavigationProvider.IsAgentValid()
if (!_agent.isOnNavMesh) return false;
_agent.SetDestination(destination);
```

### 3. SetDestination When Agent Is Disabled

```csharp
// WRONG
_agent.SetDestination(pos); // agent.isActiveAndEnabled == false → error

// CORRECT
if (_agent.isActiveAndEnabled && _agent.isOnNavMesh)
    _agent.SetDestination(pos);
```

### 4. Spawning Outside NavMesh

```csharp
// WRONG — Instantiate at arbitrary position
Instantiate(_enemyPrefab, somePosition, Quaternion.identity);

// CORRECT — sample nearest valid NavMesh point first
if (NavMesh.SamplePosition(somePosition, out NavMeshHit hit, 2f, NavMesh.AllAreas))
    Instantiate(_enemyPrefab, hit.position, Quaternion.identity);
```

### 5. NavMeshObstacle Carving on 50+ Objects

```csharp
// WRONG — 50 carving obstacles causes severe performance degradation
[SerializeField] private NavMeshObstacle _obstacle;
void Start() { _obstacle.carving = true; } // on every crate/barrel in scene

// CORRECT — use avoidance for large counts; carving only for stationary key objects
void OnObjectSettled() { _obstacle.carving = true; }
void OnObjectStartedMoving() { _obstacle.carving = false; }
```

### 6. FindObjectOfType Instead of DI

```csharp
// WRONG
var navService = FindObjectOfType<NavigationService>();

// CORRECT — inject via constructor or [Inject]
[Inject] void Construct(INavigationService navigationService)
    => _navigationService = navigationService;
```

### 7. Stale NavMeshPath After Rebake

```csharp
// WRONG — using cached path after async rebake completed
var path = _cachedPath; // may reference pre-rebake geometry

// CORRECT — recalculate path after receiving NavMeshRebakeCompletedEvent
void OnEnable() => _eventBus.Subscribe<NavMeshRebakeCompletedEvent>(OnRebakeCompleted);
void OnDisable() => _eventBus.Unsubscribe<NavMeshRebakeCompletedEvent>(OnRebakeCompleted);
private void OnRebakeCompleted(NavMeshRebakeCompletedEvent _)
{
    _cachedPath = null; // invalidate — recalculate on next tick
}
```

### 8. Async Path Not Cancelled on Destroy/Disable

```csharp
// WRONG — UniTask continues after object is destroyed
async UniTask FindPathAsync()
{
    var path = await _pathfindingService.CalculatePathAsync(from, to, areaMask);
    // 'this' might be destroyed by now!
    _agent.SetPath(path);
}

// CORRECT — use destroyCancellationToken (MonoBehaviour) or CTS
private CancellationTokenSource _cts;

void OnEnable() { _cts = new CancellationTokenSource(); FindPathAsync(_cts.Token).Forget(); }
void OnDisable() { _cts?.Cancel(); _cts?.Dispose(); }

async UniTask FindPathAsync(CancellationToken ct)
{
    var path = await _pathfindingService.CalculatePathAsync(from, to, areaMask, ct);
    ct.ThrowIfCancellationRequested();
    _agent.SetPath(path);
}
```

### 9. Polling pathStatus Every Frame

```csharp
// WRONG — pathStatus check every Update is wasteful
void Update()
{
    if (_agent.pathStatus == NavMeshPathStatus.PathComplete)
        DoSomething();
}

// CORRECT — check in throttled tick (NavigationService handles this)
// Subscribe to EnemyReachedDestinationEvent instead
void OnEnable() => _eventBus.Subscribe<EnemyReachedDestinationEvent>(OnReached);
```

### 10. Mixing Legacy OffMeshLink with AI Navigation Package

```csharp
// WRONG — OffMeshLink is incompatible with NavMeshSurface / NavMeshLink
gameObject.AddComponent<OffMeshLink>(); // legacy, not recognized by AI Nav package

// CORRECT — use NavMeshLink from com.unity.ai.navigation
var link = gameObject.AddComponent<Unity.AI.Navigation.NavMeshLink>();
link.bidirectional = true;
```

### 11. Overlapping NavMeshSurfaces Without NavMeshModifier

```csharp
// WRONG — two surfaces overlap; agents use wrong area type
// (e.g., indoor floor bleeds into outdoor surface)

// CORRECT — use NavMeshModifier to override area on the overlap zone
// Add NavMeshModifier component to the boundary object
// Set "Override Area" = true → assign the correct area type
// This forces the correct walkability for that region
```

### 12. Direct Time.timeScale = 0 for Pause (Should Use isStopped)

```csharp
// WRONG
Time.timeScale = 0; // blocked by hook; also freezes NavMeshAgent

// CORRECT — publish pause event; NavigationService handles agent stopping
_eventBus.Publish(new GamePausedEvent());

// In NavigationService — subscribe and stop all agents
void OnGamePaused(GamePausedEvent _)
{
    foreach (var kvp in _agents)
        kvp.Value.Stop();
}
```

---

## NavMeshAgent Key Properties Reference

| Property | Type | Description |
|---|---|---|
| `speed` | float | Maximum movement speed |
| `angularSpeed` | float | Maximum rotation speed (deg/s) |
| `acceleration` | float | Maximum acceleration |
| `stoppingDistance` | float | Stop when within this distance of destination |
| `pathPending` | bool | Path calculation in progress |
| `pathStatus` | NavMeshPathStatus | PathComplete / PathPartial / PathInvalid |
| `remainingDistance` | float | Distance to end of current path |
| `hasPath` | bool | Agent has a valid path |
| `isStopped` | bool | Pause/resume movement (preserves path) |
| `ResetPath()` | method | Clear current path entirely |
| `areaMask` | int | Which area types this agent can traverse |
| `avoidancePriority` | int | 0 = highest, 99 = lowest |
| `obstacleAvoidanceType` | ObstacleAvoidanceType | Quality level for avoidance |
| `isOnNavMesh` | bool | Agent is currently on a valid NavMesh |
| `isActiveAndEnabled` | bool | Component is active and enabled |
