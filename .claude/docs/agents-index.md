# Agent Roster

## Core Pipeline
| Agent | Rol | Model |
|---|---|---|
| `unity-coder` | Ana Unity kodlayıcı | Sonnet |
| `coder` | Pure C# / _Framework/ | Sonnet |
| `unity-coder-lite` | Küçük değişiklikler | Sonnet |
| `tester` | NUnit + NSubstitute test yazarı | Sonnet |
| `unity-verifier` | Compile + test (MCP-aware) | Haiku |
| `reviewer` | Genel kod review | Sonnet |
| `unity-reviewer` | Unity-spesifik review | Sonnet |
| `committer` | Semantic git commit | Haiku |

## Uzman
| Agent | Rol | Model |
|---|---|---|
| `unity-fixer` | Tam context'li bug düzeltici | Sonnet |
| `unity-fixer-lite` | NullRef, typo, hızlı fix | Haiku |
| `unity-scout` | Read-only codebase araştırmacısı | Haiku |
| `unity-critic` | Adversarial plan sorgulayıcı | Opus |
| `silent-failure-hunter` | Exception/async void/event leak denetimi | Sonnet |
| `unity-developer` | İkinci reviewer (full mode) | Sonnet |

## Setup & Yapılandırma
| Agent | Rol | Model |
|---|---|---|
| `unity-setup` | Sahne/prefab/ScriptableObject (MCP-aware) | Sonnet |
| `unity-scene-builder` | Sahne kompozisyonu (MCP-aware) | Sonnet |
| `unity-migrator` | Legacy pattern geçişi | Sonnet |
| `package-analyzer` | manifest.json tarama, singleton tespiti | Haiku |

## Kalite & Mimari
| Agent | Rol | Model |
|---|---|---|
| `unity-optimizer` | Runtime performans denetimi | Sonnet |
| `unity-linter` | Static analiz | Haiku |
| `unity-architect` | Sistem tasarımı, sınır tanımı | Opus |
| `unity-build-runner` | CI/build pipeline | Sonnet |
