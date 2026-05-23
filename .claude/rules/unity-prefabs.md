# Unity Prefab Rules

## Her Scene Object Prefab Olmalı

Sahnedeki her GameObject bir prefab instance'ı olmalı.
Doğrudan sahne objesi oluşturma yasak:

```csharp
// YANLIŞ
var go = new GameObject("Enemy");
var enemy = go.AddComponent<EnemyView>();

// DOĞRU — prefab'dan instantiate
var enemy = Instantiate(_enemyPrefab, position, rotation);
```

`check-pure-csharp.sh` ve hook'lar `new GameObject()` pattern'ini yakalar.

## Prefab Yapısı

```
EnemyPrefab (root)
├── EnemyView.cs         ← logic component burada
└── Body (child)
    └── MeshRenderer     ← görseller child'da
```

Root → logic bileşenleri
Body child → görsel bileşenler (MeshRenderer, Animator)

## Destroy Kuralları

```csharp
// Pooled objeler — Destroy çağırmak yasak, pool'a iade et
_pool.Release(bulletView);

// Non-pooled, sahneden kaldırılacak
Destroy(gameObject);

// Editor'da (test)
DestroyImmediate(gameObject);
```

## BaseCanvas Pattern

Her Canvas → ayrı prefab, `BaseCanvas` base class'tan türer:

```csharp
public abstract class BaseCanvas : MonoBehaviour
{
    [SerializeField] private CanvasGroup _canvasGroup;
    public void Show() => _canvasGroup.alpha = 1f;
    public void Hide() => _canvasGroup.alpha = 0f;
}
```

## Prefab Variant

Benzer prefablar için base prefab + Prefab Variant kullan:
`EnemyBase.prefab` → `EnemyFast.prefab (variant)`, `EnemyTank.prefab (variant)`
