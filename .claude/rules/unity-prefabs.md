# Unity Prefab Rules

## Every Scene Object Must Be a Prefab

Every GameObject in the scene must be a prefab instance.
Creating scene objects directly is forbidden:

```csharp
// WRONG
var go = new GameObject("Enemy");
var enemy = go.AddComponent<EnemyView>();

// CORRECT — instantiate from prefab
var enemy = Instantiate(_enemyPrefab, position, rotation);
```

`check-pure-csharp.sh` and hooks catch the `new GameObject()` pattern.

## Prefab Structure

```
EnemyPrefab (root)
├── EnemyView.cs         ← logic component here
└── Body (child)
    └── MeshRenderer     ← visuals on child
```

Root → logic components
Body child → visual components (MeshRenderer, Animator)

## Destroy Rules

```csharp
// Pooled objects — calling Destroy is forbidden, return to pool
_pool.Release(bulletView);

// Non-pooled, to be removed from scene
Destroy(gameObject);

// In Editor (testing)
DestroyImmediate(gameObject);
```

## BaseCanvas Pattern

Every Canvas → separate prefab, derived from `BaseCanvas` base class:

```csharp
public abstract class BaseCanvas : MonoBehaviour
{
    [SerializeField] private CanvasGroup _canvasGroup;
    public void Show() => _canvasGroup.alpha = 1f;
    public void Hide() => _canvasGroup.alpha = 0f;
}
```

## Prefab Variant

Use base prefab + Prefab Variant for similar prefabs:
`EnemyBase.prefab` → `EnemyFast.prefab (variant)`, `EnemyTank.prefab (variant)`
