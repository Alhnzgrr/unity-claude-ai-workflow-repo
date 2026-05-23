---
name: physics
description: Unity Physics ve Physics2D pattern'leri. Rigidbody, Collider, Layer yönetimi.
---

# Physics System

## Layer Tabanlı Collision

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

## Rigidbody Kullanımı

```csharp
// Physics'i FixedUpdate'te uygula
void FixedUpdate()
{
    _rb.MovePosition(_rb.position + _velocity * Time.fixedDeltaTime);
}

// Asla Transform.position = ... (fizik hesabını bozar)
```

## Raycast Optimizasyonu

```csharp
// YANLIŞ — her frame allocation
void Update()
{
    var hits = Physics.RaycastAll(origin, direction);
}

// DOĞRU — pre-allocated buffer
private readonly RaycastHit[] _hitBuffer = new RaycastHit[10];

void Update()
{
    int count = Physics.RaycastNonAlloc(origin, direction, _hitBuffer);
    for (int i = 0; i < count; i++) { ... }
}
```

## Trigger vs Collision

- Trigger: `OnTriggerEnter/Exit` — fiziksel tepki yok, sadece tespit
- Collision: `OnCollisionEnter/Exit` — fiziksel tepki var

Her ikisi de View'da işlenir, event ile servise bildirilir.
