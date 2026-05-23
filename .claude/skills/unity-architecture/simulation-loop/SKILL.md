---
name: simulation-loop
description: Use when designing turn loops, step-based environments, deterministic gameplay loops, or replayable systems.
---

# Simulation Loop

## Purpose

Define a clear loop for reset, observe, validate, step, event output, and completion checks.

## Core Idea

A stable simulation loop makes gameplay easier to test, replay, debug, and drive from AI or automated tests.

## Recommended Loop

```text
Reset
Observe
Validate action
Apply step
Publish result/events
Check completion
Render result
```

## Core Responsibilities

### Reset

Creates a clean runtime state from config, seed, save data, or scenario data.

### Observe

Returns the current state or a safe snapshot without exposing mutable internals.

### Validate

Checks whether an action is legal before applying it.

### Step

Applies one valid action and produces the next state.

### Events

Publishes domain events for views, audio, UI, analytics, and effects.

### Completion

Determines whether the loop is done, failed, paused, or waiting for input.

## Example Shape

```csharp
public interface IGameLoop
{
    GameSnapshot Current { get; }
    void Reset(GameSeed seed);
    ActionValidation Validate(GameAction action);
    StepResult Step(GameAction action);
}
```

## Determinism Guidance

- Keep random sources explicit and seedable.
- Do not let views mutate state.
- Avoid reading time directly inside rules unless time is part of the model.
- Avoid hidden global state.

## Good Pattern

```text
InputView -> GameAction -> GameLoop.Step -> Events -> Views
```

## Bad Pattern

```text
Update()
  reads input
  mutates state
  checks win
  updates UI
  starts effects
```

## Common Mistakes

- validation and mutation in the same method without a clear result
- hidden state changes during rendering
- random values that cannot be reproduced
- state transitions spread across unrelated MonoBehaviours
- tests that require scene setup for pure rule behavior

## AI Review Guidance

When reviewing a loop, check:

- Is there one authoritative state transition path?
- Can actions be validated without mutating state?
- Are results explicit enough for UI, audio, tests, and replay?
- Is the loop deterministic where it needs to be?
