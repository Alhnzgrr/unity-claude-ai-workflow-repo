# Unity Input Rules

## Input Sistemi Seçimi

`project-config.json`'daki `input` değerine göre:
- `"new"` → New Input System (Input System paketi)
- `"legacy"` → Legacy Input Manager

`check-input-system.sh` hook'u: `input: "new"` ise `Input.GetKey/Axis` kullanımını engeller.

## New Input System Pattern

Input logic View katmanında kalır, Core/Service'e sızmaz:

```csharp
// InputView.cs — MonoBehaviour, View katmanı
public class PlayerInputView : MonoBehaviour
{
    [SerializeField] private InputActionAsset _inputActions;
    private InputAction _moveAction;
    private InputAction _jumpAction;

    private IPlayerService _playerService;
    [Inject] void Construct(IPlayerService ps) => _playerService = ps;

    void Awake()
    {
        _moveAction = _inputActions["Player/Move"];
        _jumpAction = _inputActions["Player/Jump"];
    }

    void OnEnable()
    {
        _moveAction.Enable();
        _jumpAction.Enable();
        _jumpAction.performed += OnJump;
    }

    void OnDisable()
    {
        _moveAction.Disable();
        _jumpAction.Disable();
        _jumpAction.performed -= OnJump;
    }

    void Update() => _playerService.SetMoveInput(_moveAction.ReadValue<Vector2>());

    private void OnJump(InputAction.CallbackContext ctx) => _playerService.Jump();
}
```

## Legacy Input Pattern

```csharp
// SADECE legacy seçiliyse geçerli
void Update()
{
    var move = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));
    _playerService.SetMoveInput(move);

    if (Input.GetButtonDown("Jump")) _playerService.Jump();
}
```

## Yasak Patternler

```csharp
// YANLIŞ — input logic service/environment'ta
public class PlayerService : IPlayerService
{
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space)) Jump(); // input buraya girmez
    }
}
```
