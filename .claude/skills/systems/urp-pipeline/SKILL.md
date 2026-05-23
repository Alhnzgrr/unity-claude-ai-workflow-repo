---
name: urp-pipeline
description: Use when implementing or reviewing Universal Render Pipeline settings, renderer assets, render features, volumes, post-processing, quality tiers, mobile rendering, or Shader Graph integration.
---

# URP Pipeline

## Purpose

Help agents configure URP deliberately across quality tiers, renderer features, volumes, shaders, and runtime performance constraints.

## Source Notes

Unity 6 uses URP 17 documentation in the main Unity Manual. URP uses Volume framework for post-processing and scene property overrides. Renderer Features customize rendering by injecting work into the renderer at specific events. Unity 6 URP also includes newer rendering systems such as Render Graph and GPU Resident Drawer.

## Core Idea

URP configuration is project architecture. Renderer assets, quality tiers, volume profiles, shader targets, and render features should be owned and reviewed like code.

## Use When

Use this skill for:

- URP asset setup
- renderer feature design
- post-processing volumes
- mobile/VR rendering budgets
- shader compatibility
- quality tier setup
- camera renderer selection
- render graph migration review

## Recommended Asset Structure

```text
Assets/Settings/Rendering/
  URP-Renderer.asset
  URP-Low.asset
  URP-Medium.asset
  URP-High.asset
  Volumes/
    GlobalVolumeProfile.asset
    MobileVolumeProfile.asset
```

Quality tiers should be explicit:

- Low: mobile, low-end hardware, aggressive performance limits
- Medium: default gameplay target
- High: PC/high-end target

## Volume System

Use Global Volumes for scene-wide effects and Local Volumes for spatial overrides.

```csharp
public sealed class PostProcessProvider : MonoBehaviour
{
    [SerializeField] private Volume _globalVolume;

    private Bloom _bloom;
    private ColorAdjustments _colorAdjustments;

    private void Awake()
    {
        _globalVolume.profile.TryGet(out _bloom);
        _globalVolume.profile.TryGet(out _colorAdjustments);
    }

    public void SetBloomIntensity(float intensity)
    {
        if (_bloom != null)
            _bloom.intensity.value = intensity;
    }
}
```

Do not mutate shared asset profiles accidentally when the change should be temporary or per-scene. Use cloned runtime profiles when needed.

## Renderer Features

Use Renderer Features for rendering customization such as outlines, custom object passes, masks, depth/stencil behavior, or special layers.

Design questions:

- Which renderer owns the feature?
- Which render event should it run at?
- Which layers or render queues does it affect?
- Does it support camera stacking?
- Does it support target platforms?
- Is it compatible with the active URP version and Render Graph path?

## Render Graph Awareness

URP 17 uses Render Graph in modern rendering paths. When implementing custom render passes, verify whether the current URP version expects Render Graph APIs or compatibility-mode `ScriptableRenderPass` behavior.

Do not copy old renderer feature examples blindly into Unity 6 projects.

## Shader Compatibility

Built-in Render Pipeline shaders do not automatically work in URP. Use URP-compatible shaders or Shader Graph targets.

When migrating materials:

- verify shader compatibility
- check keywords and variants
- test lighting and shadows
- test platform builds

## Mobile and VR Guidance

- Keep post-processing modest.
- Prefer simple materials on low tiers.
- Control render scale per quality tier.
- Avoid expensive transparent overdraw.
- Keep camera stacking intentional.
- Use foveated rendering where supported by XR platforms.

## Good Pattern

```text
Rendering settings live in assets.
Renderer features are documented.
Volumes are explicit.
Quality tiers map to target hardware.
Custom passes are version-checked against URP.
```

## Bad Pattern

```text
Random scene scripts mutate render settings, shared volume assets, and material keywords without ownership.
```

## Common Mistakes

- editing shared volume profiles at runtime unintentionally
- copying outdated custom render pass code into URP 17
- too many renderer features active on mobile
- using built-in pipeline shaders in URP
- no quality-tier ownership
- camera stacking without performance review
- post-processing enabled by default on low-end targets

## AI Review Guidance

When reviewing URP work, check:

- Are renderer and URP assets organized and owned?
- Are volumes global/local intentionally?
- Are runtime volume mutations safe?
- Are renderer features version-compatible?
- Are mobile/VR costs considered?
- Are shaders URP-compatible?
- Are quality tiers documented?
