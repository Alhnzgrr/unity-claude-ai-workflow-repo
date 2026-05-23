---
name: shader-graph
description: Use when implementing or reviewing Shader Graph shaders, Sub Graphs, Custom Function nodes, exposed properties, material property control, URP compatibility, or HLSL integration.
---

# Shader Graph

## Purpose

Help agents build Shader Graph assets that are reusable, performant, URP-compatible, and safe to control from runtime code.

## Source Notes

Shader Graph is Unity's visual shader authoring tool. Custom Function nodes let graphs inject HLSL through inline string code or external HLSL include files. Sub Graphs are reusable graph assets; their Blackboard properties define input ports when referenced by other graphs.

## Core Idea

Use Shader Graph for authorable visual shader logic. Use HLSL Custom Function nodes or hand-written shaders when the graph becomes too complex, too slow, or needs low-level control.

## Use When

Use this skill for:

- URP Shader Graph shaders
- dissolve, fresnel, outline, hit flash, force field, or stylized effects
- shared Sub Graph logic
- material properties controlled by code
- Custom Function node HLSL
- shader performance review

## When Shader Graph, When HLSL

| Situation | Prefer |
|---|---|
| simple or artist-authored effect | Shader Graph |
| repeated graph logic | Sub Graph |
| custom math or optimization | Custom Function node |
| render pass, stencil, or pipeline-level behavior | URP renderer feature or HLSL |
| compute shader | HLSL/compute shader |

## Recommended Structure

```text
Assets/Art/Shaders/
  Characters/
    Player.shadergraph
    Enemy.shadergraph
  Environment/
    Ground.shadergraph
  SubGraphs/
    Fresnel.shadersubgraph
    Dissolve.shadersubgraph
  Includes/
    CustomLighting.hlsl
```

## Sub Graph Guidance

Use Sub Graphs for reusable node groups.

Rules:

- Keep inputs explicit through Blackboard properties.
- Avoid hidden global assumptions.
- Watch shader stage restrictions. A Sub Graph containing fragment-only nodes can become fragment-stage constrained.
- Reuse Sub Graphs for common effects such as fresnel, dissolve masks, and UV distortion.

## Custom Function Node

Use external HLSL files for nontrivial custom functions.

```hlsl
// Assets/Art/Shaders/Includes/NoiseFunctions.hlsl
#ifndef NOISE_FUNCTIONS_INCLUDED
#define NOISE_FUNCTIONS_INCLUDED

void Remap01_float(float value, float minValue, float maxValue, out float result)
{
    result = saturate((value - minValue) / max(maxValue - minValue, 0.0001));
}

#endif
```

Custom Function node setup:

- Type: File
- Source: HLSL include file
- Name: function name without precision suffix when appropriate
- Ports: define all inputs and outputs explicitly

## Property Control from C#

Cache property IDs.

```csharp
private static readonly int DissolveAmountId =
    Shader.PropertyToID("_DissolveAmount");

private readonly MaterialPropertyBlock _propertyBlock = new();

public void SetDissolveAmount(float amount)
{
    _renderer.GetPropertyBlock(_propertyBlock);
    _propertyBlock.SetFloat(DissolveAmountId, amount);
    _renderer.SetPropertyBlock(_propertyBlock);
}
```

Prefer `MaterialPropertyBlock` for per-renderer changes. Avoid `renderer.material` in hot paths because it can instantiate materials.

## Exposed Properties

Expose only properties designers need to author. Keep runtime-only properties documented and controlled by provider code.

Property naming rules:

- shader property names use stable IDs such as `_DissolveAmount`
- C# property IDs are cached statically
- avoid renaming shader properties casually because materials depend on them

## Performance Guidance

- Avoid excessive texture samples.
- Avoid branching-heavy graphs on mobile.
- Keep transparent shaders and overdraw under control.
- Use lower-cost variants for low quality tiers.
- Profile shader cost on target hardware.
- Keep keyword and variant count bounded.

## Good Pattern

```text
Reusable effect in Sub Graph
Runtime values set through MaterialPropertyBlock
Shader property IDs cached
URP target verified
```

## Bad Pattern

```text
Large duplicated node graphs, runtime code calls renderer.material every frame, property names are renamed without material migration.
```

## Common Mistakes

- duplicating complex node groups instead of using Sub Graphs
- using Custom Function string mode for large HLSL
- changing shader property names without migration
- using `renderer.material` for per-instance hot-path updates
- too many shader keywords and variants
- building effects that only work in Editor and fail on target platforms

## AI Review Guidance

When reviewing Shader Graph work, check:

- Is the shader URP-compatible?
- Should repeated graph logic be a Sub Graph?
- Is custom HLSL in an include file when nontrivial?
- Are runtime property IDs cached?
- Are per-instance values using `MaterialPropertyBlock`?
- Are mobile/VR shader costs considered?
