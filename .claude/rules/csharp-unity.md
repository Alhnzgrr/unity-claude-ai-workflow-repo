# C# & Unity Coding Rules

## İsimlendirme

| Tür | Format | Örnek |
|---|---|---|
| Class, Interface, Enum | PascalCase | `AudioService`, `IAudioService` |
| Method, Property | PascalCase | `PlayClip()`, `IsPlaying` |
| Private field | _camelCase | `_audioSource` |
| Const | UPPER_SNAKE | `MAX_POOL_SIZE` |
| Local variable | camelCase | `clipName` |

## Namespace Zorunlu

Her dosya namespace içinde:

```csharp
namespace MyGame.Audio
{
    public sealed class AudioService : IAudioService { }
}
```

## #region Yapısı

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

## sealed Kullanımı

Inheritance amaçlanmıyorsa `sealed` ekle:

```csharp
public sealed class AudioService : IAudioService { }
```

## Interface İsimlendirme

Her interface `I` prefix'iyle başlar:

```csharp
public interface IAudioService { }
public interface IEventBus { }
```

## Dosya = Sınıf

Her `.cs` dosyası tek bir public tip içerir.
Dosya adı = sınıf adı: `AudioService.cs` → `AudioService`.
