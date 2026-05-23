---
name: vr
description: XR Interaction Toolkit and XR Origin patterns. Controller input, performance, comfort.
---

# VR Development

> This skill is auto-loaded when `project-config.json` → `"xr": true`.

## XR Origin Structure

```
XR Origin
├── Camera Offset
│   └── Main Camera (XR camera)
├── LeftHand Controller
│   └── XR Controller (Left Hand)
└── RightHand Controller
    └── XR Controller (Right Hand)
```

## Controller Input Pattern

```csharp
public sealed class VRInputProvider : MonoBehaviour
{
    [SerializeField] private InputActionReference _gripAction;
    [SerializeField] private InputActionReference _triggerAction;

    private IInteractionService _interactionService;
    [Inject] void Construct(IInteractionService interactionService)
        => _interactionService = interactionService;

    void OnEnable()
    {
        _gripAction.action.Enable();
        _triggerAction.action.Enable();
        _gripAction.action.performed += OnGrip;
        _triggerAction.action.performed += OnTrigger;
    }

    void OnDisable()
    {
        _gripAction.action.Disable();
        _triggerAction.action.Disable();
        _gripAction.action.performed -= OnGrip;
        _triggerAction.action.performed -= OnTrigger;
    }

    private void OnGrip(InputAction.CallbackContext ctx)
        => _interactionService.Grip(ctx.ReadValue<float>());

    private void OnTrigger(InputAction.CallbackContext ctx)
        => _interactionService.Trigger(ctx.ReadValue<float>());
}
```

## VR Performance Rules

- **Target framerate:** 90 FPS (Quest 2), 120 FPS (Quest 3)
- **Draw call limit:** <100 per eye
- **Foveated Rendering:** Enable Oculus Foveated Rendering
- **Single Pass Stereo:** Enable in Player Settings
- **Fixed Foveated Rendering:** Required for Quest

## Comfort (Locomotion)

- Teleport locomotion → reduces dizziness
- Continuous locomotion → add vignette (darken edges during movement)
- Snap turn → use for sudden direction changes

## XR Interaction Toolkit

- XR Grab Interactable → grabbing objects
- XR Socket Interactor → slot placement
- XR Ray Interactor → remote interaction (for UI)
