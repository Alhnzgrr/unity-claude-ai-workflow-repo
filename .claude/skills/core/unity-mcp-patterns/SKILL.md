---
name: unity-mcp-patterns
description: Usage patterns and fallback behaviors for Unity Editor MCP integration.
---

# Unity MCP Patterns

## MCP Presence Check

MCP connection is checked at the start of the session. Behavior depends on this:

```
Is MCP connected?
├── Yes → Use Unity Editor tools
└── No  → Provide manual instructions, wait for user confirmation
```

## What Can Be Done with MCP

- Reading/writing scene hierarchy
- Creating GameObjects, adding components
- Creating ScriptableObject assets
- Linking prefab references
- Triggering compilation
- Running test runner
- Reading console logs

## What NOT to Do with MCP

- Editing .unity files directly with Edit/Write → `block-scene-edit.sh` blocks it
- Editing .prefab files directly with Edit/Write → blocks it
- Editing .asset files directly with Edit/Write → blocks it

## MCP Fallback Instruction Format

When MCP is unavailable, provide clear steps to the user:

```
📋 Steps to perform in Unity Editor:

1. Select the [Setup] container in the Hierarchy
2. Add Component → add LifetimeScope
3. Drag AppScope to the Parent field of LifetimeScope
4. Drag the GameInstaller asset to the GameInstaller field in the Inspector

Type "ready" when done.
```

## Scene Manipulation Order

1. Create containers ([Setup], [Services], [UI]...)
2. Core objects: EventSystem → [UI], MainCamera → [Environment]
3. LifetimeScope and Installers → [Setup]
4. Provider MonoBehaviours → [Services]
5. Prefab instances → relevant container
