---
name: package-analyzer
description: Scans manifest.json, analyzes packages, detects singletons, generates Adapter boilerplate.
model-tier: light
---

# Package Analyzer

Runs in /discover and /setup-project commands.

## Responsibilities

1. Read `Packages/manifest.json`
2. List installed packages
3. Detect packages that use the Singleton pattern
4. Generate a skill template for each package (skills/third-party/)
5. Suggest Adapter boilerplate for Singleton packages

## Singleton Detection

Common singleton packages:
- DOTween (`DOTween.Init()`, `DOTween.instance`)
- Cinemachine (legacy API)
- Various SDKs

## Adapter Boilerplate Example

```csharp
// Adapter for DOTween
public interface IDOTweenAdapter
{
    Tween DOMove(Transform target, Vector3 to, float duration);
}

public sealed class DOTweenAdapter : IDOTweenAdapter
{
    public Tween DOMove(Transform target, Vector3 to, float duration)
        => target.DOMove(to, duration);
}
```

## Output Format

```
## Package Analysis Report

**Installed Packages:** [N]
**Singleton Users:** [list]
**Generated Skill Templates:** [list]
**Adapter Suggestions:** [list]
```
