---
name: mobile-development
description: Use when implementing or reviewing mobile-sensitive Unity features, touch input, memory usage, thermal risk, rendering, UI, or performance budgets.
---

# Mobile Development

## Purpose

Help agents make Unity features reliable on mobile hardware, where CPU, GPU, memory, battery, and thermal budgets are strict.

## Core Idea

Mobile performance is a design constraint, not a final optimization pass.

## Mobile Priorities

- stable frame rate
- low garbage allocation
- controlled draw calls
- clear touch interaction
- short loading paths
- predictable memory usage
- battery and thermal awareness

## CPU Rules

- Avoid expensive per-frame work.
- Cache component references.
- Avoid LINQ in hot paths.
- Batch repeated work where possible.
- Keep active MonoBehaviour counts under control.

## Memory Rules

- Avoid per-frame allocations.
- Reuse buffers and collections.
- Pool frequently spawned objects.
- Release Addressables handles.
- Avoid loading large assets before they are needed.

## Rendering Rules

- Keep materials and shader variants controlled.
- Use batching and instancing where appropriate.
- Avoid unnecessary transparent overdraw.
- Keep post-processing modest.
- Use platform-appropriate texture compression.

## UI Rules

- Keep touch targets large enough.
- Avoid excessive layout rebuilds.
- Split canvases when frequently updated UI invalidates static UI.
- Update text only when values change.
- Avoid string allocation in frequent UI updates.

## Battery and Thermal Rules

- Avoid needless polling.
- Avoid running heavy logic while paused or hidden.
- Consider reduced update rates for noncritical systems.
- Keep background work cancellable.

## Touch Input Rules

- Make taps, drags, and releases forgiving.
- Provide immediate feedback.
- Avoid critical interactions with tiny hit targets.
- Ensure input maps to the same service API as keyboard, replay, and AI input.

## Profiling Checklist

- CPU frame time
- GC allocations per frame
- draw calls and batches
- texture memory
- UI rebuilds
- loading spikes
- device temperature during long sessions

## Common Mistakes

- optimizing only for desktop editor performance
- allocating strings in UI updates
- too many canvases or one giant invalidated canvas
- unbounded object spawning
- touch targets designed like mouse targets
- ignoring Addressables release behavior

## AI Review Guidance

When reviewing mobile readiness, check:

- Does the feature allocate in hot paths?
- Are spawned objects pooled when needed?
- Is touch interaction clear and forgiving?
- Are rendering and UI costs bounded?
- Is async work cancellable when the view is destroyed?
