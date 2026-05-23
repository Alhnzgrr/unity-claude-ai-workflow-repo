---
name: serialization-safety
description: Use when adding, renaming, removing, or reviewing serialized Unity fields, ScriptableObjects, prefabs, or scene references.
---

# Serialization Safety

## Purpose

Prevent silent data loss in Unity assets, scenes, prefabs, and ScriptableObjects when serialized structures evolve.

## Core Idea

Unity serialization is convenient but fragile. Renaming fields, changing types, changing enum semantics, or mixing runtime state with serialized data can break existing authoring data.

## What Must Be Protected

Protect:

- ScriptableObject config assets
- serialized MonoBehaviour references
- prefab-authored values
- scene-authored references
- tuning values
- replay, scenario, and debug config assets

## Main Rule

If a serialized field may already exist in assets or prefabs, changing it is not free. Treat it as a data migration.

## Safe Field Practices

- Use `[SerializeField] private` for Inspector-facing data.
- Keep serialized field names stable.
- Prefer focused serializable types.
- Avoid serializing runtime-only caches.
- Validate required references early.

## Renaming Serialized Fields

Use `FormerlySerializedAs` when a serialized field is renamed.

```csharp
using UnityEngine;
using UnityEngine.Serialization;

public sealed class PlayerConfiguration : ScriptableObject
{
    [FormerlySerializedAs("_speed")]
    [SerializeField] private float _moveSpeed = 5f;
}
```

## Runtime State Rule

Do not serialize values that only exist during active play:

- current health
- temporary legality cache
- live score accumulator
- pooled instance lists
- runtime references created during play

Use runtime state objects or private nonserialized fields instead.

## Type Change Caution

Be careful when changing:

- field type
- collection type
- nested serializable class layout
- enum values used by assets
- references from concrete types to interfaces

These changes can invalidate or reinterpret existing data.

## ScriptableObject Guidance

- Use ScriptableObjects for authorable config.
- Avoid hidden mutable state in assets.
- Keep config and runtime mutation separate.
- Treat asset schema changes as migration-sensitive.

## MonoBehaviour Guidance

- Serialize scene and prefab references that must be wired in Inspector.
- Do not serialize internal caches for convenience.
- Avoid casual renames of widely used serialized fields.

## Common Mistakes

- renaming serialized fields without migration support
- serializing runtime-only state
- changing enum meaning without considering assets
- putting unrelated data in one serialized type
- assuming missing references will be obvious immediately

## AI Review Guidance

When reviewing serialization changes, check:

- Is the field already present in existing assets or prefabs?
- Was a serialized rename protected with `FormerlySerializedAs`?
- Is this value truly authorable?
- Could this change require asset migration or validation?
- Are missing references handled clearly?
