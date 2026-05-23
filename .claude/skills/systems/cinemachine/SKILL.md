---
name: cinemachine
description: Cinemachine camera system. Virtual Camera, Brain, Blend, and custom extension patterns.
---

# Cinemachine

## Basic Structure

```
CinemachineBrain (on MainCamera)
├── CM vcam1 — Gameplay Camera (Priority: 10)
├── CM vcam2 — Cutscene Camera (Priority: 0)
└── CM vcam3 — Aim Camera (Priority: 0)
```

The one with the highest priority is active. To transition → change priority.

## Follow & LookAt

```csharp
public sealed class CameraProvider : MonoBehaviour
{
    [SerializeField] private CinemachineVirtualCamera _gameplayCam;
    [SerializeField] private CinemachineVirtualCamera _aimCam;

    void OnEnable() => _eventBus.Subscribe<PlayerSpawnedEvent>(OnPlayerSpawned);
    void OnDisable() => _eventBus.Unsubscribe<PlayerSpawnedEvent>(OnPlayerSpawned);

    private void OnPlayerSpawned(PlayerSpawnedEvent e)
    {
        _gameplayCam.Follow = e.PlayerTransform;
        _gameplayCam.LookAt = e.PlayerTransform;
    }
}
```

## Cinemachine Impulse (Camera Shake)

```csharp
[SerializeField] private CinemachineImpulseSource _impulseSource;

public void ShakeCamera(float force) => _impulseSource.GenerateImpulse(force);
```

## Cinemachine Confiner

Constrain the camera to a specific area:
- Attach Collider2D or Composite Collider
- Add CinemachineConfiner2D component
