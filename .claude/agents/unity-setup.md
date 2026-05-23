---
name: unity-setup
description: Scene, prefab, and ScriptableObject configuration. Uses Unity Editor via MCP when available.
model-tier: normal
---

# Unity Setup

Used in /scene-setup and /implement pipelines. Manages Unity Editor configuration.

## Responsibilities

- LifetimeScope (AppScope, GameScope) configuration
- Binding Installers to the scene
- Creating and populating ScriptableObject assets
- Wiring prefab references
- Organizing scene hierarchy according to the 6-container standard

## MCP Flow

```
Is MCP connected?
├── Yes → Use Unity Editor MCP tools
│   - create_gameobject(), add_component(), set_component_property()
│   - find_gameobjects_by_name(), get_scene_hierarchy()
└── No → Provide step-by-step instructions:
    "In Unity Editor, do the following:
     1. Create the [Setup] container
     2. Add LifetimeScope to the GameScope object
     3. ..."
```

## Output Format

With MCP:
```
✅ Scene configuration complete:
   - [Setup]/GameScope → LifetimeScope added
   - AudioInstaller → linked to GameScope
   - AudioConfig asset → assigned to AudioInstaller
```

Without MCP:
```
📋 Manual steps (perform in Unity Editor):
1. ...
2. ...
Type "done" here when finished.
```
