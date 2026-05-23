# Unity Prefab Rules

## Every Scene Object Must Be a Prefab

Every persistent GameObject in a scene should be a prefab instance.

Creating runtime scene objects directly is forbidden in production gameplay code:

```csharp
// WRONG in production gameplay code
var go = new GameObject("Enemy");
var enemy = go.AddComponent<EnemyView>();

// CORRECT
var enemy = Instantiate(_enemyPrefab, position, rotation);
```

## Test Exception

Programmatic PlayMode tests may create temporary `GameObject` instances to verify MonoBehaviour behavior.

This exception is limited to test code. Temporary objects must be destroyed by the test.

## Editor and MCP Exception

Scene, prefab, and asset setup should be performed through Unity Editor, Unity MCP tools, or documented manual steps.

Do not edit `.unity`, `.prefab`, or `.asset` files directly through text edits.

## Prefab Structure

```text
EnemyPrefab
  EnemyView.cs
  Body
    MeshRenderer
```

Root object:

- logic components
- dependency injection bridge components
- identity components

Child objects:

- renderers
- animators
- particle systems
- visual-only components

## Destroy Rules

```csharp
// Pooled object
_pool.Release(bulletView);

// Non-pooled runtime object
Destroy(gameObject);

// Editor/test-only cleanup
DestroyImmediate(gameObject);
```

Do not call `Destroy` on pooled objects except through pool destroy callbacks.

## BaseCanvas Pattern

Every Canvas should be a separate prefab when practical.

```csharp
public abstract class BaseCanvas : MonoBehaviour
{
    [SerializeField] private CanvasGroup _canvasGroup;

    public void Show()
    {
        _canvasGroup.alpha = 1f;
    }

    public void Hide()
    {
        _canvasGroup.alpha = 0f;
    }
}
```

## Prefab Variants

Use a base prefab plus Prefab Variants for similar objects.

```text
EnemyBase.prefab
  EnemyFast.prefab
  EnemyTank.prefab
```

## Common Mistakes

- creating persistent scene objects from code instead of prefabs
- treating test-only `new GameObject` setup as runtime approval
- putting visual components and logic into one unstructured root
- destroying pooled objects instead of releasing them
- directly editing prefab files as text
