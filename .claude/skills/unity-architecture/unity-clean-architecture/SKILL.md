---
name: unity-clean-architecture
description: Use when designing or reviewing Unity systems that must keep game rules testable and MonoBehaviours thin.
---

# Unity Clean Architecture

## Purpose

Help agents structure Unity projects so core game logic stays testable, explicit, and separate from scene and presentation concerns.

## Core Idea

Unity is the host runtime and visualization layer. Game rules, state transitions, validation, scoring, and system policies should live in plain C# where possible.

MonoBehaviours should coordinate Unity-specific concerns:

- scene references
- rendering and animation bridges
- input adapters
- debug visualization
- inspector wiring

## Recommended Layers

```text
Core/
  Pure C# state, actions, rules, events, and policies

Systems/
  Services that apply rules and coordinate use cases

Views/
  MonoBehaviours, UI, presentation, scene adapters

Data/
  ScriptableObjects, configs, balancing data, scenario definitions

Composition/
  VContainer or Zenject wiring
```

## Dependency Direction

Prefer:

```text
Views -> Systems -> Core
Data -> Systems -> Core
Composition -> everything
```

Rules:

- Core should not know about Views.
- Systems should not depend on scene objects unless through narrow adapters.
- Views may read state and call system APIs, but should not implement rules.
- Composition owns wiring and should make dependencies explicit.

## Good Pattern

```text
PlayerInputView
  Converts InputAction callbacks into player commands.

PlayerService
  Validates and applies player actions.

PlayerState
  Plain C# state model.

PlayerView
  Renders current state and forwards presentation events.
```

## Bad Pattern

```text
PlayerController
  Reads input
  Checks legality
  Applies state transitions
  Computes score
  Updates UI
  Spawns effects
  Saves progress
```

## Architectural Rules

- Keep rule logic testable in plain C#.
- Keep MonoBehaviours thin.
- Separate validation from execution.
- Separate presentation from state mutation.
- Prefer composition over inheritance.
- Use interfaces at meaningful boundaries, not everywhere by default.
- Avoid manager classes that own unrelated responsibilities.

## Unity-Specific Guidance

- Use MonoBehaviours as adapters, not as the game brain.
- Use ScriptableObjects for authorable config, not mutable runtime state.
- Keep debug visualization optional and replaceable.
- If a system can run without a scene, prefer that design.

## When To Refactor

Refactor when:

- a MonoBehaviour starts owning rule logic
- validation and transition logic are mixed together
- UI or input code mutates core state directly
- the system cannot be tested without entering Play Mode
- adding one action requires editing many unrelated files

## When Not To Refactor

Do not split a tiny prototype into many abstractions before the state and action model is clear.

Do not add indirection only to look architectural. Start with clean boundaries, then deepen them where pressure appears.

## Common Mistakes

- creating god MonoBehaviours
- making services depend on scene object lookups
- putting runtime state in ScriptableObjects
- creating interfaces for every class without a boundary
- treating DI as a substitute for clear ownership

## AI Review Guidance

When reviewing architecture, check:

- Is core logic separable from the Unity scene?
- Are rule, state, view, and composition responsibilities distinct?
- Are MonoBehaviours acting as adapters?
- Could the main logic run in EditMode tests?
- Are dependencies explicit rather than discovered with `Find*` calls?
