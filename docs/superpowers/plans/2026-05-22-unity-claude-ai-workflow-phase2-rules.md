# Unity Claude AI Workflow - Phase 2: Rules

## Goal

Create the required architecture rule files and optional feature rule files under `.claude/rules/`.

## Required Rule Files

- `.claude/rules/architecture.md`
- `.claude/rules/dependency-injection.md`
- `.claude/rules/async.md`
- `.claude/rules/unity-lifecycle.md`
- `.claude/rules/unity-input.md`
- `.claude/rules/performance.md`
- `.claude/rules/serialization.md`
- `.claude/rules/testing.md`
- `.claude/rules/event-patterns.md`
- `.claude/rules/unity-prefabs.md`
- `.claude/rules/scene-hierarchy.md`
- `.claude/rules/csharp-unity.md`

## Optional Rule Files

- `.claude/rules/ecs-dots.md`
- `.claude/rules/addressables.md`

## Rule Coverage

`architecture.md` defines the project folder boundaries, module shape, framework isolation, and allowed dependency direction.

`dependency-injection.md` defines VContainer and Zenject usage, constructor injection for pure C# classes, method injection for MonoBehaviours, and bans singleton/service-locator patterns.

`async.md` requires UniTask, cancellation tokens for public async methods, clear async ownership, and safe fire-and-forget handling.

`unity-lifecycle.md` defines Awake, OnEnable, OnDisable, and Start responsibilities, plus editor guards and main-thread rules.

`unity-input.md` defines New Input System and Legacy Input Manager patterns and keeps input logic in the view layer.

`performance.md` defines hot paths and bans per-frame allocations, hot-path LINQ, uncached GetComponent calls, and expensive object searches.

`serialization.md` protects serialized data by requiring `FormerlySerializedAs` on serialized renames and separating runtime state from configuration.

`testing.md` defines the EditMode vs PlayMode decision tree and requires clear Arrange/Act/Assert test structure.

`event-patterns.md` bans `UnityEvent` and defines when to use `IEventBus`, C# events, or callbacks.

`unity-prefabs.md` requires prefab-based scene objects and documents prefab, pooling, and canvas conventions.

`scene-hierarchy.md` defines the six root containers: `[Setup]`, `[Services]`, `[UI]`, `[Environment]`, `[Characters]`, and `[VFX]`.

`csharp-unity.md` defines naming, namespace, region, sealed-class, and file-per-type conventions.

`ecs-dots.md` covers ECS components, systems, bakers, jobs, command buffers, and hybrid linking.

`addressables.md` covers Addressables loading, handle lifecycle, release rules, and label-based loading.

## Verification

- All 12 required `.md` files exist.
- Both optional `.md` files exist.
- Each rule file states what it enforces, what it forbids, and at least one concrete example or pattern.
