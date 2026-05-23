---
name: unity-mcp-patterns
description: Usage patterns and fallback behaviors for Unity Editor MCP integration.
---

# Unity MCP Patterns

## MCP Presence Check

Check MCP availability at the start of a session or before editor-state work.

```text
MCP connected?
  Yes -> use Unity Editor tools
  No -> provide manual Unity Editor instructions and wait for user confirmation
```

## What Can Be Done with MCP

- read and write scene hierarchy
- create GameObjects
- add and configure components
- create ScriptableObject assets
- link prefab and asset references
- trigger compilation
- run tests
- read console logs

## What Not To Do

Do not edit these files directly with text tools:

- `.unity`
- `.prefab`
- `.asset`

The `block-scene-edit.sh` hook blocks those edits. Use MCP tools or manual Unity Editor steps instead.

## Asset and ScriptableObject Setup

Creating or modifying ScriptableObject assets should happen through one of these paths:

1. Unity MCP asset/editor tools
2. manual Unity Editor steps
3. a deliberate editor utility script reviewed by the user

Do not bypass Unity serialization by editing `.asset` YAML directly.

## MCP Fallback Instruction Format

When MCP is unavailable, provide concrete steps:

```text
Unity Editor steps:

1. Select the [Setup] container in the Hierarchy.
2. Add a LifetimeScope component.
3. Assign AppScope to the Parent field.
4. Assign the GameInstaller asset in the Inspector.

Type "ready" when done.
```

## Scene Manipulation Order

1. Create root containers: `[Setup]`, `[Services]`, `[UI]`, `[Environment]`, `[Characters]`, `[VFX]`.
2. Add core objects: EventSystem under `[UI]`, MainCamera under `[Environment]`.
3. Add LifetimeScope and installers under `[Setup]`.
4. Add provider MonoBehaviours under `[Services]`.
5. Place prefab instances under the relevant containers.

## Review Questions

- Was editor state changed through MCP or explicit manual instructions?
- Were `.unity`, `.prefab`, and `.asset` files left untouched by text edits?
- Are manual steps concrete enough for the user to reproduce?
- Are generated editor utilities clearly scoped and reviewed?
