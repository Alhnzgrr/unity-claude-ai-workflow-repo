---
name: animation
description: Animator Controller, Animation Rigging ve animasyon event pattern'leri.
---

# Animation System

## Animator Pattern

```csharp
public sealed class PlayerAnimationProvider : MonoBehaviour
{
    private static readonly int IsMovingHash = Animator.StringToHash("IsMoving");
    private static readonly int AttackTriggerHash = Animator.StringToHash("Attack");
    private static readonly int SpeedHash = Animator.StringToHash("Speed");

    [SerializeField] private Animator _animator;

    public void SetMoving(bool isMoving)
        => _animator.SetBool(IsMovingHash, isMoving);

    public void SetSpeed(float speed)
        => _animator.SetFloat(SpeedHash, speed);

    public void TriggerAttack()
        => _animator.SetTrigger(AttackTriggerHash);
}
```

## StringToHash Zorunlu

Animator.StringToHash ile hash'leri cache'le — her frame string karşılaştırması pahalı.

## Animation Events

```csharp
// Animator'da animation event bağlanır, MonoBehaviour'da işlenir
public void OnAttackHitFrame()
{
    _eventBus.Publish(new AttackHitEvent(_playerId));
}
```

## State Machine Behaviour

```csharp
public class AttackStateBehaviour : StateMachineBehaviour
{
    public override void OnStateEnter(Animator animator, AnimatorStateInfo info, int layerIndex)
    {
        animator.GetComponent<PlayerView>().OnAttackStateEnter();
    }
}
```
