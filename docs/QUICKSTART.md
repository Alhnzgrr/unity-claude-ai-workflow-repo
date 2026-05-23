# Quick Start

## Starting a New Project

```
/game-idea        -> Convert a raw idea into a GDD
/architect        -> Generate a TDD from the GDD
/plan-workflow    -> Split the TDD into phases -> WORKFLOW.md
/orchestrate      -> Execute WORKFLOW.md
```

## Adding a Feature to an Existing Project

```
/implement "Implement AudioService"
```

The pipeline runs automatically:
1. Tests are written and expected to fail.
2. Implementation is written and expected to pass the tests.
3. Verification runs.
4. Review runs.
5. A commit is created.

## Bug Fixes

```
/fix "PlayerController throws a NullReferenceException"
/fix-lite "typo: PlayerControler -> PlayerController"
/fix-deep "FixedUpdate occasionally skips a frame and the root cause is unclear"
```

## Quality Control

```
/qa                 -> Full quality pipeline
/review-code        -> Review specific files
/performance-audit  -> Hot path audit
```

## Change Review Mode

Edit `production/review-mode.txt`:
- `solo`: Fast mode for jams and prototypes
- `lean`: Normal development mode (default)
- `full`: Team review mode

## Director Gates

The system stops at critical points and waits for your approval:

| Gate | When | Prompt |
|---|---|---|
| SCOPE_GATE | At the start of a pipeline | Type "go" or redirect the work |
| BREAKING_GATE | When 3+ files change | Approve the wider scope |
| QUALITY_GATE | When review returns "CHANGES NEEDED" | fix / skip / stop |
| COMMIT_GATE | After verification | Final approval |
