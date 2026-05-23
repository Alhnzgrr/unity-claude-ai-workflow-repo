# Unity Input Rules

## Input System Selection

Based on the `input` value in `project-config.json`:
- `"new"` → New Input System (Input System package)
- `"legacy"` → Legacy Input Manager

`check-input-system.sh` hook: if `input: "new"`, blocks usage of `Input.GetKey/Axis`.

## New Input System Pattern

Input logic stays in the View layer and does not leak into Core/Service:

```csharp
// InputView.cs — MonoBehaviour, View layer
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
// Valid ONLY when legacy is selected
void Update()
{
    var move = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));
    _playerService.SetMoveInput(move);

    if (Input.GetButtonDown("Jump")) _playerService.Jump();
}
```

## Forbidden Patterns

```csharp
// WRONG — input logic in service/environment
public class PlayerService : IPlayerService
{
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space)) Jump(); // input does not belong here
    }
}
```
