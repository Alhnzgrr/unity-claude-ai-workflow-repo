# Agent Roster

## Core Pipeline
| Agent | Role | Model |
|---|---|---|
| `unity-coder` | Primary Unity coder | Sonnet |
| `coder` | Pure C# / _Framework/ | Sonnet |
| `unity-coder-lite` | Small changes | Sonnet |
| `tester` | NUnit + NSubstitute test writer | Sonnet |
| `unity-verifier` | Compile + test (MCP-aware) | Haiku |
| `reviewer` | General code review | Sonnet |
| `unity-reviewer` | Unity-specific review | Sonnet |
| `committer` | Semantic git commit | Haiku |

## Specialists
| Agent | Role | Model |
|---|---|---|
| `unity-fixer` | Full-context bug fixer | Sonnet |
| `unity-fixer-lite` | NullRef, typo, quick fix | Haiku |
| `unity-scout` | Read-only codebase researcher | Haiku |
| `unity-critic` | Adversarial plan challenger | Opus |
| `silent-failure-hunter` | Exception/async void/event leak inspector | Sonnet |
| `unity-developer` | Second reviewer (full mode) | Sonnet |

## Setup & Configuration
| Agent | Role | Model |
|---|---|---|
| `unity-setup` | Scene/prefab/ScriptableObject (MCP-aware) | Sonnet |
| `unity-scene-builder` | Scene composition (MCP-aware) | Sonnet |
| `unity-migrator` | Legacy pattern migration | Sonnet |
| `package-analyzer` | manifest.json scan, singleton detection | Haiku |

## Quality & Architecture
| Agent | Role | Model |
|---|---|---|
| `unity-optimizer` | Runtime performance audit | Sonnet |
| `unity-linter` | Static analysis | Haiku |
| `unity-architect` | System design, boundary definition | Opus |
| `unity-build-runner` | CI/build pipeline | Sonnet |
