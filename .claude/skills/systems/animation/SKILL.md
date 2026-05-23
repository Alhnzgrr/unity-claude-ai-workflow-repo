---
name: animation
description: Use when implementing or reviewing Animator Controllers, animation parameters, Animation Events, StateMachineBehaviour, root motion, animation-driven gameplay events, or animation provider code.
---

# Animation System

## Purpose

Help agents use Unity animation as a presentation and timing layer without letting Animator graphs become hidden gameplay logic.

## Source Notes

Unity Animator Controllers organize clips into states, transitions, blend trees, layers, and parameters. `StateMachineBehaviour` is a ScriptableObject-based hook attached to animator states and receives messages such as `OnStateEnter`, `OnStateExit`, `OnStateUpdate`, `OnStateMove`, and `OnStateIK`.

## Core Idea

Animation should visualize state and emit timing signals. Gameplay services should own rules, legality, damage, score, and state mutation.

## Use When

Use this skill for:

- Animator parameter updates
- blend tree driving
- animation events
- state enter/exit callbacks
- root motion review
- Animation Rigging or IK integration
- combat timing from animation clips
- view-provider animation bridges

## Recommended Boundary

```text
Gameplay Service -> publishes state/events
Animation Provider -> sets Animator parameters
Animator Controller -> blends visual states
Animation Event or StateMachineBehaviour -> reports timing facts
Gameplay Service -> validates and applies effects
```

## Animator Provider Pattern

```csharp
public sealed class PlayerAnimationProvider : MonoBehaviour
{
    private static readonly int IsMovingHash = Animator.StringToHash("IsMoving");
    private static readonly int AttackTriggerHash = Animator.StringToHash("Attack");
    private static readonly int SpeedHash = Animator.StringToHash("Speed");

    [SerializeField] private Animator _animator;

    public void SetMoving(bool isMoving)
    {
        _animator.SetBool(IsMovingHash, isMoving);
    }

    public void SetSpeed(float speed)
    {
        _animator.SetFloat(SpeedHash, speed);
    }

    public void TriggerAttack()
    {
        _animator.SetTrigger(AttackTriggerHash);
    }
}
```

Cache parameter hashes with `Animator.StringToHash`. Avoid string parameter lookups in frequently called paths.

## Parameter Ownership

Use Animator parameters for visual state:

- movement speed
- grounded state
- attack trigger
- weapon state
- hit reaction

Do not use Animator parameters as the authoritative gameplay state.

## Animation Events

Animation Events are acceptable for timing facts, not rule decisions.

```csharp
public sealed class AttackAnimationEvents : MonoBehaviour
{
    private ICombatService _combatService;

    [Inject]
    private void Construct(ICombatService combatService)
    {
        _combatService = combatService;
    }

    public void OnAttackHitFrame()
    {
        _combatService.ReportAttackHitFrame();
    }
}
```

The service should still validate whether the attack can hit.

## StateMachineBehaviour Guidance

Use `StateMachineBehaviour` sparingly for state-level animation callbacks.

```csharp
public sealed class AttackStateBehaviour : StateMachineBehaviour
{
    public override void OnStateEnter(
        Animator animator,
        AnimatorStateInfo stateInfo,
        int layerIndex)
    {
        AttackAnimationBridge bridge =
            animator.GetComponent<AttackAnimationBridge>();

        bridge.ReportAttackStateEntered(layerIndex);
    }
}
```

Avoid heavy logic in `OnStateUpdate`. These messages can run often and can run for current, interrupted, or next states depending on transitions.

## Root Motion

Use root motion only when movement is intentionally animation-authored. Otherwise, gameplay movement should drive animation, not the reverse.

If root motion is enabled:

- document who owns final position
- keep physics interactions clear
- avoid competing Rigidbody and Animator movement
- test transitions and interruptions

## Animation Rigging and IK

Keep IK and rig constraints in presentation/provider code. Services should request intent such as "aim at target"; rig code should solve the visual result.

## Good Pattern

```text
PlayerService computes movement state
PlayerAnimationProvider sets Animator parameters
Animation Event reports hit timing
CombatService validates and applies hit
```

## Bad Pattern

```text
Animator state callback decides damage, changes score, updates UI, spawns VFX, and mutates inventory.
```

## Common Mistakes

- using Animator as the authoritative gameplay state machine
- string parameter names in hot paths
- heavy logic in `StateMachineBehaviour.OnStateUpdate`
- Animation Events applying damage directly
- root motion fighting Rigidbody movement
- no unsubscribe or cleanup for animation-driven callbacks
- relying on animation timing without service-side validation

## AI Review Guidance

When reviewing animation code, check:

- Are Animator parameters cached?
- Is animation a view/provider concern rather than the gameplay brain?
- Do Animation Events report timing instead of applying rules?
- Is root motion ownership explicit?
- Are state machine callbacks lightweight?
- Are interrupted transitions handled safely?
