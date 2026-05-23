# /game-idea

Converts a raw game idea into a structured Game Design Document (GDD).

## Usage

```
/game-idea [optional: brief idea description]
```

## Workflow

### Step 1 — Understand the Idea

Ask the user the following (one at a time):
1. What is the core game mechanic? (Core loop)
2. Target platform? (PC, Mobile, VR, Console)
3. Target audience? (Hyper-casual, Core, Hardcore)
4. Reference games? (If any)
5. What is the standout feature? (USP — Unique Selling Point)

### Step 2 — Surface Assumptions

Make everything ambiguous concrete:
- "Multiplayer" → how many players, online or local?
- "RPG system" → which systems? inventory, skill tree, leveling?
- "Mobile" → iOS, Android, or both?

### Step 3 — "We're Not Doing" List

Determine what is out of scope according to the YAGNI principle.
Ask the user: "We won't be doing the following in this version, correct?"

### Step 4 — Create GDD

Write to `docs/GDD.md`:

```markdown
# Game Design Document — [Game Name]

## Summary
[2-3 sentence elevator pitch]

## Core Loop
[Core game loop step by step]

## Mechanics
[For each mechanic: what, why, how]

## Target Audience
[Who it's for, why them]

## Platform
[Target platform and constraints]

## Out of Scope (This Version)
[List of things that won't be built]

## Success Criteria
[How will you know the game is working?]
```

### Step 5 — Commit

```bash
git add docs/GDD.md
git commit -m "docs: add Game Design Document for [game name]"
```

## Next Step

When GDD is ready: proceed to technical design with `/architect`.
