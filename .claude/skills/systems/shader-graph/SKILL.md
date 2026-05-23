---
name: shader-graph
description: URP shader writing patterns with Shader Graph. Custom node, SubGraph, and HLSL integration.
---

# Shader Graph

## When Shader Graph, When HLSL?

| Situation | Preference |
|---|---|
| Simple effect (dissolve, outline, fresnel) | Shader Graph |
| Complex math / performance critical | HLSL Custom Node |
| Compute shader | HLSL direct |
| Extending existing shader | HLSL |

## Shader Graph Folder Structure

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

In Shader Graph: Custom Function Node → File option → link the HLSL file.

## Shader Property Control

```csharp
private static readonly int DissolveAmountID = Shader.PropertyToID("_DissolveAmount");

public void SetDissolveAmount(float amount)
{
    _renderer.material.SetFloat(DissolveAmountID, amount);
}
```
