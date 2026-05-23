# Model Routing

Which model is used for which task.

## Model Tiers

| Tier | Model | When |
|---|---|---|
| light | Haiku | Read-only, formatting, quick summary, linting |
| normal | Sonnet | Code generation, review, debugging, implementation |
| heavy | Opus | Architecture design, adversarial review, critical decisions |

## Agent → Tier Mapping

### light (Haiku)
- `unity-verifier` — compile/test result reading
- `committer` — commit message generation
- `unity-scout` — read-only research
- `unity-fixer-lite` — single-line fix
- `unity-linter` — convention checking
- `package-analyzer` — manifest reading

### normal (Sonnet)
- `unity-coder`, `coder`, `unity-coder-lite`
- `tester`
- `reviewer`, `unity-reviewer`, `unity-developer`
- `unity-fixer`, `unity-migrator`
- `silent-failure-hunter`
- `unity-setup`, `unity-scene-builder`
- `unity-optimizer`, `unity-build-runner`

### heavy (Opus)
- `unity-architect` — system design
- `unity-critic` — adversarial plan review

## Complexity Score → Model Selection

0.0 – 0.3 → light or normal
0.4 – 0.6 → normal
0.7 – 1.0 → heavy (architect) + normal (coder)

Complexity calculation:
- New module? +0.3
- Affects multiple systems? +0.2
- ECS or Addressables? +0.2
- Requires tests? +0.1
- Modifies existing code? +0.1
- Single file single method? 0.1
