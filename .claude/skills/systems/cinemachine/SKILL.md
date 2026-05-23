---
name: cinemachine
description: Use when implementing or reviewing Cinemachine cameras, Brain setup, camera priority, blends, follow/look-at targets, impulse, confiners, FreeLook/orbit cameras, or camera provider code.
---

# Cinemachine

## Purpose

Help agents use Cinemachine as a camera composition system while keeping gameplay rules outside camera components.

## Source Notes

Cinemachine 3 is the current package line for Unity 6. Cinemachine uses camera components and a Brain on the Unity Camera to choose and blend active cameras. Camera priority determines which virtual camera becomes active when multiple cameras are live; higher priority wins.

## Core Idea

Cinemachine owns camera behavior and composition. Game systems request camera modes or targets; they do not micromanage camera transforms every frame.

## Use When

Use this skill for:

- follow cameras
- aim cameras
- cutscene cameras
- camera blending
- target assignment
- camera shake through Impulse
- camera bounds through Confiner
- camera collision/framing review
- camera mode services

## Recommended Structure

```text
Main Camera
  Cinemachine Brain

Cinemachine Cameras
  GameplayCamera
  AimCamera
  CutsceneCamera
  InspectCamera

CameraProvider
  owns references and target assignment

CameraService
  owns camera mode policy
```

## Camera Provider Pattern

```csharp
public sealed class CameraProvider : MonoBehaviour
{
    [SerializeField] private CinemachineCamera _gameplayCamera;
    [SerializeField] private CinemachineCamera _aimCamera;

    private IEventBus _eventBus;

    [Inject]
    private void Construct(IEventBus eventBus)
    {
        _eventBus = eventBus;
    }

    private void OnEnable()
    {
        _eventBus.Subscribe<PlayerSpawnedEvent>(OnPlayerSpawned);
    }

    private void OnDisable()
    {
        _eventBus.Unsubscribe<PlayerSpawnedEvent>(OnPlayerSpawned);
    }

    private void OnPlayerSpawned(PlayerSpawnedEvent evt)
    {
        _gameplayCamera.Follow = evt.PlayerTransform;
        _gameplayCamera.LookAt = evt.PlayerTransform;
    }
}
```

For Cinemachine 2 projects, the equivalent type may be `CinemachineVirtualCamera`. Match the installed package version.

## Priority and Blending

Use priority for camera selection.

```csharp
public void SetAimMode(bool enabled)
{
    _aimCamera.Priority = enabled ? 20 : 0;
    _gameplayCamera.Priority = enabled ? 10 : 20;
}
```

Configure blends on the Cinemachine Brain or through project camera policy. Avoid sudden hard cuts unless intentionally designed.

## Follow and LookAt Ownership

Set targets when spawn, respawn, possession, or cutscene state changes. Do not assign targets every frame unless the target itself changes every frame.

## Impulse

Use Cinemachine Impulse for camera shake.

```csharp
public sealed class CameraShakeProvider : MonoBehaviour
{
    [SerializeField] private CinemachineImpulseSource _impulseSource;

    public void Shake(float force)
    {
        _impulseSource.GenerateImpulse(force);
    }
}
```

Gameplay systems should request shake intent; camera providers generate the visual effect.

## Confiner

Use Confiner components to constrain cameras to authored spaces. Keep confiner collider ownership clear and update/recalculate bounds when the level layout changes.

For 2D levels, use the 2D confiner path and appropriate Collider2D or CompositeCollider2D setup.

## FreeLook and Orbit Cameras

Use orbit rigs for third-person camera control when camera motion is player-driven. Keep input mapping in input adapters or camera providers, not in game rule services.

## Good Pattern

```text
Player spawned -> CameraProvider assigns Follow/LookAt
Player enters aim mode -> CameraService requests AimCamera priority
Brain blends cameras
```

## Bad Pattern

```text
Gameplay service sets MainCamera transform every frame and bypasses Cinemachine.
```

## Common Mistakes

- mixing Cinemachine 2 and 3 APIs without checking package version
- assigning Follow/LookAt every frame unnecessarily
- changing camera priority from many unrelated systems
- putting gameplay rules in camera callbacks
- forgetting Brain blend configuration
- using shake without amplitude/frequency policy
- missing confiner recalculation after dynamic level changes

## AI Review Guidance

When reviewing Cinemachine usage, check:

- Does Main Camera have a Brain?
- Is camera mode selection centralized?
- Are camera targets assigned at state changes, not every frame?
- Are package-version API names correct?
- Are blends, shake, and confiners intentional?
- Is gameplay logic outside camera components?
