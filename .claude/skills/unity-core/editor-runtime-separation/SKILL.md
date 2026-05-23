---
name: editor-runtime-separation
description: Use when writing or reviewing UnityEditor usage, custom editor tooling, editor windows, property drawers, or runtime code that may accidentally depend on editor APIs.
---

# Editor Runtime Separation

## Purpose

Prevent runtime builds from depending on UnityEditor APIs and keep editor tooling isolated from player code.

## Core Idea

`UnityEditor` code is not available in player builds. Editor-only logic must live in editor assemblies or be wrapped in compile-time guards.

## Main Rule

Runtime code must not directly depend on `UnityEditor`.

## Good Separation

### Runtime

Contains:

- gameplay code
- runtime services
- MonoBehaviours used in builds
- ScriptableObject data used in builds
- runtime interfaces and adapters

### Editor

Contains:

- custom inspectors
- editor windows
- menu items
- import processors
- validation tools
- asset generation utilities

## Recommended Structure

```text
Assets/_GameFolders/Scripts/Games/Concretes/
  Runtime code

Assets/_GameFolders/Scripts/Editors/
  Editor-only code
```

For assembly definitions, use separate runtime and editor assemblies.

## Guarding Editor Usage

If editor code must be in the same file, guard it:

```csharp
#if UNITY_EDITOR
using UnityEditor;
#endif

public sealed class RuntimeComponent : MonoBehaviour
{
#if UNITY_EDITOR
    private void OnValidate()
    {
        EditorUtility.SetDirty(this);
    }
#endif
}
```

Prefer moving editor code into editor-only files when practical.

## Runtime Safety Rules

- Do not call editor APIs in runtime methods.
- Do not put editor utilities in runtime services.
- Do not use editor-only types in serialized runtime fields.
- Keep asset-generation tools out of player assemblies.

## Common Mistakes

- `using UnityEditor` in runtime folders
- custom editor code in the same assembly as runtime code
- editor-only validation called from runtime methods
- menu items that mutate runtime assets without clear approval
- relying on editor-only APIs during tests that should represent builds

## AI Review Guidance

When reviewing editor/runtime separation, check:

- Would this compile in a player build?
- Is every `UnityEditor` reference guarded or editor-only?
- Are editor tools separated from runtime services?
- Are validation and generation tools explicit and safe?
