---
name: vr
description: XR Interaction Toolkit ve XR Origin pattern'leri. Controller input, performance, comfort.
---

# VR Development

> Bu skill `project-config.json` → `"xr": true` ise auto-yüklenir.

## XR Origin Yapısı

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

## VR Performans Kuralları

- **Hedef framerate:** 90 FPS (Quest 2), 120 FPS (Quest 3)
- **Draw call limiti:** <100 per eye
- **Foveated Rendering:** Oculus Foveated Rendering aktif et
- **Single Pass Stereo:** Player Settings'de aktif et
- **Fixed Foveated Rendering:** Quest için zorunlu

## Comfort (Locomotion)

- Teleport locomotion → dizziness'ı azaltır
- Continuous locomotion → vignette ekle (hareket sırasında kenarları karart)
- Snap turn → ani yön değişiminde kullan

## XR Interaction Toolkit

- XR Grab Interactable → obje tutma
- XR Socket Interactor → slot yerleştirme
- XR Ray Interactor → uzak etkileşim (UI için)
