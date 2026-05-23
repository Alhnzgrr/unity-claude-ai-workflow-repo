---
name: physics
description: Unity Physics and Physics2D patterns. Rigidbody, Collider, Layer management.
---

# Physics System

## Layer-Based Collision

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

## Rigidbody Usage

```csharp
// Apply physics in FixedUpdate
void FixedUpdate()
{
    _rb.MovePosition(_rb.position + _velocity * Time.fixedDeltaTime);
}

// Never Transform.position = ... (breaks physics calculation)
```

## Raycast Optimization

```csharp
// WRONG — allocation every frame
void Update()
{
    var hits = Physics.RaycastAll(origin, direction);
}

// CORRECT — pre-allocated buffer
private readonly RaycastHit[] _hitBuffer = new RaycastHit[10];

void Update()
{
    int count = Physics.RaycastNonAlloc(origin, direction, _hitBuffer);
    for (int i = 0; i < count; i++) { ... }
}
```

## Trigger vs Collision

- Trigger: `OnTriggerEnter/Exit` — no physical response, detection only
- Collision: `OnCollisionEnter/Exit` — physical response present

Both are handled in the View, notified to the service via event.
