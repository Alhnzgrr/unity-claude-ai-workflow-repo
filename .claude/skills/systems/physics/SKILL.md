---
name: physics
description: Use when implementing or reviewing Unity Physics or Physics2D interactions, Rigidbody movement, collisions, raycasts, triggers, layers, or mobile-sensitive physics code.
---

# Physics System

## Purpose

Help agents use Unity physics predictably, efficiently, and with clear separation between physics callbacks and game rules.

## Core Idea

Physics detects and moves. Game services decide what those detections mean.

## Use When

Use this skill for:

- Rigidbody movement
- trigger and collision handling
- raycasts and overlap checks
- layer masks
- hit detection
- projectile physics
- character physics adapters

## Configuration Pattern

```csharp
[CreateAssetMenu(menuName = "Config/Physics")]
public sealed class PhysicsConfiguration : ScriptableObject
{
    [SerializeField] private LayerMask _playerLayer;
    [SerializeField] private LayerMask _enemyLayer;
    [SerializeField] private LayerMask _groundLayer;

    public LayerMask PlayerLayer => _playerLayer;
    public LayerMask EnemyLayer => _enemyLayer;
    public LayerMask GroundLayer => _groundLayer;
}
```

Layer masks should be config-driven when they are part of system policy.

## Rigidbody Movement

Use `FixedUpdate` for physics movement.

```csharp
private Rigidbody _rigidbody;
private Vector3 _velocity;

private void Awake()
{
    _rigidbody = GetComponent<Rigidbody>();
}

private void FixedUpdate()
{
    Vector3 nextPosition = _rigidbody.position + _velocity * Time.fixedDeltaTime;
    _rigidbody.MovePosition(nextPosition);
}
```

Avoid setting `transform.position` for physics-driven objects because it bypasses expected Rigidbody behavior.

## Trigger and Collision Ownership

MonoBehaviours may receive Unity callbacks:

```csharp
private void OnTriggerEnter(Collider other)
{
    _hitService.ReportTriggerEnter(gameObject, other.gameObject);
}
```

The callback should forward facts. The service should decide whether a hit is valid, what damage applies, and which events are published.

## Raycast Optimization

Avoid allocation-heavy physics APIs in hot paths.

Bad:

```csharp
RaycastHit[] hits = Physics.RaycastAll(origin, direction);
```

Good:

```csharp
private readonly RaycastHit[] _hitBuffer = new RaycastHit[16];

private int Raycast(Vector3 origin, Vector3 direction, float distance, LayerMask mask)
{
    return Physics.RaycastNonAlloc(origin, direction, _hitBuffer, distance, mask);
}
```

## 2D vs 3D Rule

Do not mix 2D and 3D physics concepts in one system without an explicit adapter boundary.

Examples:

- `Rigidbody` and `Collider` are 3D.
- `Rigidbody2D` and `Collider2D` are 2D.
- `Physics` and `Physics2D` queries are separate APIs.

## Events

Useful events:

- `TriggerEnteredEvent`
- `CollisionStartedEvent`
- `GroundedChangedEvent`
- `HitDetectedEvent`

Events should carry stable domain information, not raw callback-only state when avoidable.

## Testing Guidance

Use EditMode tests for pure policy:

- layer matching
- damage validation
- hit filtering
- state transitions after reported contacts

Use PlayMode tests for actual Rigidbody, Collider, and physics-scene behavior.

## Good Pattern

```text
PhysicsView receives OnTriggerEnter
PhysicsView reports contact to HitService
HitService validates layers and state
HitService publishes HitDetectedEvent
```

## Bad Pattern

```text
OnTriggerEnter computes damage, changes score, updates UI, plays sound, and destroys objects.
```

## Common Mistakes

- using `RaycastAll` every frame
- forgetting layer masks
- deciding game rules inside physics callbacks
- using `transform.position` for Rigidbody movement
- mixing 2D and 3D physics APIs
- relying on string tags instead of explicit layer or component checks

## AI Review Guidance

When reviewing physics code, check:

- Is movement done in the correct update loop?
- Are physics callbacks thin?
- Are allocations avoided in hot physics queries?
- Are layer masks explicit?
- Are game rules handled by services instead of callbacks?
- Are 2D and 3D APIs kept separate?
