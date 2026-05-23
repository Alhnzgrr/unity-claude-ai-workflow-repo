---
name: environment-view-separation
description: Use when implementing or reviewing boundaries between game/environment logic and Unity presentation code.
---

# Environment View Separation

## Purpose

Keep gameplay, simulation, and rule logic out of presentation code so systems can be tested and reused without a scene.

## Core Idea

The environment owns what is true. The view owns how it looks and how humans interact with it.

## Separation Goal

### Environment

Owns:

- state
- legal actions
- transitions
- scoring or reward
- completion conditions
- deterministic simulation flow

### View

Owns:

- visual state
- scene references
- animation triggers
- UI feedback
- input forwarding
- debug overlays

## Good Pattern

```text
CardGameService
  Knows legal moves and state transitions.

CardGameView
  Renders cards and forwards click/drag events.

CardInputView
  Converts Unity input into service commands.
```

## Bad Pattern

```text
CardView
  Decides whether a move is legal.
  Mutates the deck state.
  Computes score.
  Updates animation and UI.
```

## View Responsibilities

- display state
- collect human interaction
- play animation, sound, and feedback
- expose serialized references
- report user intent to the environment or service

## Environment Responsibilities

- validate actions
- mutate state
- publish domain events
- expose read-only state or snapshots
- decide success, failure, or progression

## Input Guidance

Input should produce environment-facing commands. It should not decide legality, reward, or terminal state.

## ScriptableObject Guidance

ScriptableObjects can hold authorable data for views and systems, but should not hold live mutable runtime state unless there is a deliberate reason.

## Common Mistakes

- rule checks inside button callbacks
- state mutation inside UI components
- separate human and AI code paths
- views caching authoritative state
- service methods returning presentation-specific objects

## AI Review Guidance

When reviewing this boundary, check:

- Can the environment run without rendering?
- Can a test drive the same API that player input drives?
- Does the view only forward intent and render results?
- Are illegal actions rejected by the environment, not by the UI?
