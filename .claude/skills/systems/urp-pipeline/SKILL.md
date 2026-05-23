---
name: urp-pipeline
description: Universal Render Pipeline konfigürasyonu. Render Feature, Volume, Shader Graph entegrasyonu.
---

# URP Pipeline

## URP Asset Yapısı

Kalite tiers için ayrı URP Asset'ler:
- `URP-Low.asset` — mobil, düşük detay
- `URP-Medium.asset` — orta segment
- `URP-High.asset` — PC yüksek kalite

## Volume Sistemi

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

## URP Shader Uyumu

Built-in shader'lar URP'de çalışmaz. Her shader URP için yazılmalı veya Shader Graph ile oluşturulmalı.
