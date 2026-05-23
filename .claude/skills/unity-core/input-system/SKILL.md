---
name: input-system
description: Use when implementing or reviewing Unity input adapters, New Input System bindings, replay input, AI input, or mobile touch input.
---

# Input System

## Purpose

Use Unity input in a way that stays compatible with human input, replay input, automated tests, and AI control.

## Core Idea

Input is only one possible source of actions. Game systems should receive commands or actions, not raw Unity input details.

## Main Rule

Unity input belongs in adapter or view code.

## Good Separation

```text
Keyboard / Touch / Replay / AI
    -> Input Adapter
    -> Game Action
    -> Service or Simulation Loop
```

## Recommended Pattern

```csharp
public sealed class PlayerInputView : MonoBehaviour
{
    [SerializeField] private InputActionAsset _actions;

    private InputAction _jumpAction;
    private IPlayerService _playerService;

    [Inject]
    private void Construct(IPlayerService playerService)
    {
        _playerService = playerService;
    }

    private void Awake()
    {
        _jumpAction = _actions["Player/Jump"];
    }

    private void OnEnable()
    {
        _jumpAction.Enable();
        _jumpAction.performed += OnJump;
    }

    private void OnDisable()
    {
        _jumpAction.performed -= OnJump;
        _jumpAction.Disable();
    }

    private void OnJump(InputAction.CallbackContext context)
    {
        _playerService.TryJump();
    }
}
```

## Service Rule

Services should expose methods or commands such as:

- `TryJump()`
- `SetMoveInput(Vector2 input)`
- `TrySubmitAction(GameAction action)`
- `Step(EnvironmentAction action)`

They should not know whether the action came from touch, mouse, keyboard, replay, tests, or AI.

## Continuous vs Discrete Input

Use callbacks for discrete input:

- submit
- cancel
- reset
- confirm
- jump

Use polling when appropriate for continuous input:

- movement vector
- cursor position
- drag position
- analog navigation

Still convert the result into service-friendly input state or actions.

## Mobile Guidance

- Touch targets must be clear and forgiving.
- Taps, drags, and releases should map cleanly to actions.
- Visual confirmation should appear quickly.
- Avoid fragile hit targets for critical interactions.

## Common Mistakes

- putting rule checks in input callbacks
- separate logic paths for player, replay, and AI actions
- letting input adapters mutate state directly
- coupling services to generated `PlayerControls` classes
- forgetting to unsubscribe callbacks in `OnDisable`

## AI Review Guidance

When reviewing input usage, check:

- Is Unity input isolated from rules?
- Can AI, replay, tests, and human input use the same API?
- Are callbacks subscribed and unsubscribed safely?
- Is legality decided by the service or environment, not by the input layer?
