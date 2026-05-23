---
name: vr
description: Use when implementing or reviewing XR/VR systems, XR Origin setup, controller input, locomotion, interaction, comfort, or VR performance.
---

# VR Development

## Purpose

Help agents build VR features that respect comfort, performance, input ownership, and XR Interaction Toolkit conventions.

## Core Idea

VR is not just a display mode. Interaction, comfort, frame timing, scale, and input feedback must be designed from the start.

## Use When

Use this skill for:

- XR Origin setup
- controller input
- hand interaction
- grab/socket/ray interaction
- VR UI
- locomotion
- comfort review
- Quest or mobile VR performance

## XR Origin Structure

```text
XR Origin
  Camera Offset
    Main Camera
  LeftHand Controller
    XR Controller
  RightHand Controller
    XR Controller
```

The XR camera should be controlled by XR systems, not by ordinary gameplay camera scripts.

## Input Adapter Pattern

```csharp
public sealed class VRInputProvider : MonoBehaviour
{
    [SerializeField] private InputActionReference _gripAction;
    [SerializeField] private InputActionReference _triggerAction;

    private IInteractionService _interactionService;

    [Inject]
    private void Construct(IInteractionService interactionService)
    {
        _interactionService = interactionService;
    }

    private void OnEnable()
    {
        _gripAction.action.Enable();
        _triggerAction.action.Enable();
        _gripAction.action.performed += OnGrip;
        _triggerAction.action.performed += OnTrigger;
    }

    private void OnDisable()
    {
        _gripAction.action.performed -= OnGrip;
        _triggerAction.action.performed -= OnTrigger;
        _gripAction.action.Disable();
        _triggerAction.action.Disable();
    }

    private void OnGrip(InputAction.CallbackContext context)
    {
        _interactionService.Grip(context.ReadValue<float>());
    }

    private void OnTrigger(InputAction.CallbackContext context)
    {
        _interactionService.Trigger(context.ReadValue<float>());
    }
}
```

Input providers should forward intent. Services decide interaction legality.

## Interaction Toolkit Guidance

Common components:

- `XR Grab Interactable` for grab objects
- `XR Socket Interactor` for slot placement
- `XR Ray Interactor` for distant interaction and UI
- `XR Direct Interactor` for near-hand interaction

Keep interaction layers explicit. Do not rely on broad default layer masks for important interactions.

## Comfort Rules

- Prefer teleport locomotion when comfort is uncertain.
- Use snap turn instead of smooth turn by default.
- Add vignette or other comfort mitigation for continuous movement.
- Avoid forced camera motion.
- Avoid sudden acceleration.
- Keep world scale believable.
- Give immediate feedback for grab, hover, and invalid actions.

## Performance Rules

VR performance budgets are strict:

- Target device frame rate must be explicit.
- Avoid per-frame allocations.
- Keep draw calls and overdraw low.
- Use single-pass stereo where appropriate.
- Use foveated rendering on supported standalone headsets.
- Keep expensive post-processing modest.
- Pool frequent VFX and interaction indicators.

## VR UI Guidance

- Prefer world-space UI that is readable at comfortable distances.
- Use large targets and clear hover states.
- Avoid tiny text and dense panels.
- Support ray-based and direct interaction where appropriate.
- Keep UI feedback immediate.

## Good Pattern

```text
XR controller input -> interaction service command -> validated action -> haptics/audio/visual feedback
```

## Bad Pattern

```text
Controller callback directly mutates object state, plays effects, changes score, and moves the camera.
```

## Common Mistakes

- treating VR like normal first-person camera mode
- forced camera movement
- no comfort strategy for continuous locomotion
- interaction layers too broad
- tiny UI targets
- per-frame allocations in interaction code
- forgetting haptic or visual feedback for important actions

## AI Review Guidance

When reviewing VR code, check:

- Is input isolated from interaction rules?
- Are comfort defaults conservative?
- Are interaction layers explicit?
- Is the frame budget protected?
- Are UI targets readable and usable in headset?
- Is feedback clear for hover, grab, release, valid, and invalid actions?
