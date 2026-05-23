# C# & Unity Coding Rules

## Naming

| Type | Format | Example |
|---|---|---|
| Class, Interface, Enum | PascalCase | `AudioService`, `IAudioService` |
| Method, Property | PascalCase | `PlayClip()`, `IsPlaying` |
| Private field | _camelCase | `_audioSource` |
| Const | UPPER_SNAKE | `MAX_POOL_SIZE` |
| Local variable | camelCase | `clipName` |

## Namespace Required

Every file must be inside a namespace:

```csharp
namespace MyGame.Audio
{
    public sealed class AudioService : IAudioService { }
}
```

## #region Structure

```csharp
public class PlayerView : MonoBehaviour
{
    #region Serialized Fields
    [SerializeField] private float _speed;
    #endregion

    #region Private Fields
    private Rigidbody _rb;
    #endregion

    #region Unity Lifecycle
    void Awake() { }
    void OnEnable() { }
    void OnDisable() { }
    void Update() { }
    #endregion

    #region Public API
    public void SetMoveInput(Vector2 input) { }
    #endregion

    #region Private Methods
    private void ApplyMovement() { }
    #endregion
}
```

## sealed Usage

Add `sealed` if inheritance is not intended:

```csharp
public sealed class AudioService : IAudioService { }
```

## Interface Naming

Every interface starts with the `I` prefix:

```csharp
public interface IAudioService { }
public interface IEventBus { }
```

## File = Class

Each `.cs` file contains a single public type.
File name = class name: `AudioService.cs` → `AudioService`.
