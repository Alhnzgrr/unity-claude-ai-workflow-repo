---
name: urp-pipeline
description: Universal Render Pipeline configuration. Render Feature, Volume, Shader Graph integration.
---

# URP Pipeline

## URP Asset Structure

Separate URP Assets for quality tiers:
- `URP-Low.asset` — mobile, low detail
- `URP-Medium.asset` — mid-range
- `URP-High.asset` — PC high quality

## Volume System

```csharp
public sealed class PostProcessProvider : MonoBehaviour
{
    [SerializeField] private Volume _globalVolume;
    private Bloom _bloom;
    private ColorAdjustments _colorAdj;

    void Awake()
    {
        _globalVolume.profile.TryGet(out _bloom);
        _globalVolume.profile.TryGet(out _colorAdj);
    }

    public void SetBloomIntensity(float intensity)
    {
        if (_bloom != null) _bloom.intensity.value = intensity;
    }
}
```

## Renderer Feature

```csharp
public class OutlineRendererFeature : ScriptableRendererFeature
{
    private OutlineRenderPass _pass;

    public override void Create()
    {
        _pass = new OutlineRenderPass();
        _pass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData data)
    {
        renderer.EnqueuePass(_pass);
    }
}
```

## URP Shader Compatibility

Built-in shaders do not work in URP. Every shader must be written for URP or created with Shader Graph.
