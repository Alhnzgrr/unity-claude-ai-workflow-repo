# Unity Claude AI Workflow - Phase 4: Agents

## Goal

Create 22 agent definition files under `.claude/agents/`. Each file defines a role, responsibilities, constraints, and output format.

## Agent Files

Core pipeline agents:
- `unity-coder.md`
- `coder.md`
- `unity-coder-lite.md`
- `tester.md`
- `unity-verifier.md`
- `reviewer.md`
- `unity-reviewer.md`
- `committer.md`

Specialist agents:
- `unity-fixer.md`
- `unity-fixer-lite.md`
- `unity-scout.md`
- `unity-critic.md`
- `silent-failure-hunter.md`
- `unity-developer.md`

Setup and configuration agents:
- `unity-setup.md`
- `unity-scene-builder.md`
- `unity-migrator.md`
- `package-analyzer.md`

Quality, architecture, and build agents:
- `unity-optimizer.md`
- `unity-linter.md`
- `unity-architect.md`
- `unity-build-runner.md`

## Role Requirements

`unity-coder` writes Unity gameplay and system code while following all project rules.

`coder` writes pure C# code for framework-level modules and must not use Unity APIs.

`unity-coder-lite` handles small isolated changes.

`tester` writes NUnit and NSubstitute tests and does not write implementation code.

`unity-verifier` checks compile and test results, using Unity MCP when available.

`reviewer` checks general code quality, correctness, test coverage, and maintainability.

`unity-reviewer` checks Unity-specific lifecycle, performance, prefab, scene, input, and async risks.

`committer` creates semantic git commits and never pushes.

`unity-fixer` performs root-cause bug fixes with full context.

`unity-fixer-lite` handles obvious low-risk fixes.

`unity-scout` performs read-only codebase research.

`unity-critic` asks adversarial architecture questions during planning.

`silent-failure-hunter` audits swallowed exceptions, event leaks, unsafe fire-and-forget usage, and cancellation issues.

`unity-developer` provides a second senior Unity review in full mode or for high-risk changes.

`unity-setup` configures Unity scenes, prefabs, and ScriptableObjects through MCP or manual instructions.

`unity-scene-builder` builds scene hierarchy and places prefab instances in the required containers.

`unity-migrator` migrates legacy patterns such as coroutine-to-UniTask and singleton-to-DI.

`package-analyzer` reads `manifest.json`, identifies packages, and suggests adapters or skill drafts.

`unity-optimizer` audits runtime performance risks.

`unity-linter` checks naming, regions, namespaces, and other static conventions.

`unity-architect` creates system design, boundaries, data flow, and dependency graphs.

`unity-build-runner` prepares and analyzes Unity batch-mode build workflows.

## Verification

- All 22 agent files exist.
- Each file has frontmatter with name, description, and model tier.
- Each file states responsibilities, constraints, and output format.
