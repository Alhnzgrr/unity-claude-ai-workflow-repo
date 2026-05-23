---
name: shader-graph
description: Shader Graph ile URP shader yazma pattern'leri. Custom node, SubGraph ve HLSL entegrasyonu.
---

# Shader Graph

## Ne Zaman Shader Graph, Ne Zaman HLSL?

| Durum | Tercih |
|---|---|
| Basit efekt (dissolve, outline, fresnel) | Shader Graph |
| Kompleks matematik / performans kritik | HLSL Custom Node |
| Compute shader | HLSL direkt |
| Existing shader'ı genişletme | HLSL |

## Shader Graph Klasör Yapısı

```
Arts/Shaders/
├── Characters/
│   ├── PlayerShader.shadergraph
│   └── EnemyShader.shadergraph
├── Environment/
│   └── GroundShader.shadergraph
└── SubGraphs/
    ├── Fresnel.shadersubgraph
    └── Dissolve.shadersubgraph
```

## Custom HLSL Node

```hlsl
// CustomNode.hlsl
void MyCustomFunction_float(float3 input, out float3 output)
{
    output = normalize(input) * 2.0;
}
```

Shader Graph'ta: Custom Function Node → File seçeneği → HLSL dosyasını bağla.

## Shader Property Kontrolü

```csharp
private static readonly int DissolveAmountID = Shader.PropertyToID("_DissolveAmount");

public void SetDissolveAmount(float amount)
{
    _renderer.material.SetFloat(DissolveAmountID, amount);
}
```
