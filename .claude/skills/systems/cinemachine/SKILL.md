---
name: cinemachine
description: Cinemachine kamera sistemi. Virtual Camera, Brain, Blend ve custom extension pattern'leri.
---

# Cinemachine

## Temel Yapı

```
CinemachineBrain (MainCamera'da)
├── CM vcam1 — Gameplay Camera (Priority: 10)
├── CM vcam2 — Cutscene Camera (Priority: 0)
└── CM vcam3 — Aim Camera (Priority: 0)
```

Priority yüksek olan aktif olur. Geçiş → priority değiştir.

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

## Cinemachine Impulse (Kamera Sarsıntısı)

```csharp
[SerializeField] private CinemachineImpulseSource _impulseSource;

public void ShakeCamera(float force) => _impulseSource.GenerateImpulse(force);
```

## Cinemachine Confiner

Kamerayı belirli bir alanla sınırla:
- Collider2D veya Composite Collider bağla
- CinemachineConfiner2D component ekle
