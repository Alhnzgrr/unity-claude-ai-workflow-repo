---
name: dotween
description: Use when implementing or reviewing DOTween tweens, Sequences, UI animations, tween lifecycle, recyclable tweens, SetLink cleanup, timeScale behavior, or DI-friendly tween adapters.
---

# DOTween

## Purpose

Help agents use DOTween without leaking tweens, hiding global state, or mixing animation policy into unrelated gameplay code.

## Source Notes

DOTween documentation covers tween creation, Sequences, chained settings and callbacks, `SetUpdate`, `SetLink`, `SetAutoKill`, recyclable tweens, capacity configuration, and kill/cleanup APIs.

## Core Idea

Tween intent should be explicit and cleanup should be tied to object lifetime. DOTween is globally initialized, so project code should wrap or centralize usage when architecture requires testability and DI boundaries.

## Use When

Use this skill for:

- UI transitions
- object movement, scale, rotation, fade, and color tweens
- Sequences
- timeScale-independent UI animations
- tween lifecycle cleanup
- DOTween adapter design
- replacing coroutine animation flows

## Initialization

Initialize DOTween once near app startup.

```csharp
DOTween.Init(recycleAllByDefault: true, useSafeMode: false)
    .SetCapacity(300, 80);
```

Capacity should reflect project scale. Setting capacity avoids DOTween resizing under load.

## Adapter Pattern

DOTween is a static API. Wrap it when services need testability or when code should not depend directly on static calls.

```csharp
public interface ITweenService
{
    Tween MoveTo(Transform target, Vector3 position, float duration);
    Tween FadeTo(CanvasGroup group, float alpha, float duration);
    void Kill(object targetOrId);
}

public sealed class DOTweenAdapter : ITweenService
{
    public Tween MoveTo(Transform target, Vector3 position, float duration)
    {
        return target.DOMove(position, duration)
            .SetTarget(target)
            .SetLink(target.gameObject);
    }

    public Tween FadeTo(CanvasGroup group, float alpha, float duration)
    {
        return group.DOFade(alpha, duration)
            .SetTarget(group)
            .SetLink(group.gameObject);
    }

    public void Kill(object targetOrId)
    {
        DOTween.Kill(targetOrId);
    }
}
```

## Lifecycle Cleanup

Tie tweens to GameObjects when possible.

```csharp
transform.DOMoveX(4f, 0.25f)
    .SetLink(gameObject);
```

Also kill owned tweens in lifecycle methods when ownership is explicit.

```csharp
private Tween _showTween;

private void OnDisable()
{
    _showTween?.Kill();
    _showTween = null;
}
```

## Sequences

Use Sequences for ordered or overlapping animation.

```csharp
private Sequence _sequence;

public void Show()
{
    _sequence?.Kill();

    _sequence = DOTween.Sequence()
        .Append(_panel.DOFade(1f, 0.2f))
        .Join(_panelTransform.DOScale(1f, 0.2f).SetEase(Ease.OutBack))
        .SetLink(gameObject);
}
```

Settings on nested tweens may be overridden by the Sequence where DOTween rules require it. Apply sequence-level settings such as update mode to the Sequence itself.

## SetUpdate and Time Scale

Use `SetUpdate` intentionally.

```csharp
_sequence.SetUpdate(UpdateType.Normal, isIndependentUpdate: true);
```

Use independent update for pause menus and UI that should animate while `Time.timeScale` is 0. Avoid independent `FixedUpdate` tweens unless there is a strong reason.

## AutoKill and Reuse

Default tweens auto-kill on completion. If reusing a tween, disable auto-kill and manage rewind/restart carefully.

```csharp
_cachedTween = transform.DOMoveX(4f, 1f)
    .SetAutoKill(false)
    .Pause();

_cachedTween.Restart();
```

Reused tweens require explicit cleanup and must not hold stale targets.

## Recyclable Tweens

Recyclable tweens reduce allocations, but killed tween references can become invalid or point to recycled instances. Always clear references on kill.

```csharp
_tween = transform.DOMoveX(4f, 1f)
    .SetRecyclable(true)
    .OnKill(() => _tween = null);
```

## Awaiting DOTween with UniTask

When waiting for a tween in async code, cancellation should kill the tween if the owner is gone.

```csharp
public async UniTask PlayAsync(CancellationToken ct)
{
    Tween tween = _canvasGroup.DOFade(1f, 0.2f)
        .SetLink(gameObject);

    await tween.AsyncWaitForCompletion()
        .AsUniTask()
        .AttachExternalCancellation(ct);
}
```

If a project has DOTween async extensions available, prefer the project-standard await wrapper. Always define what cancellation does to the tween.

## Good Pattern

```text
View creates tween -> tween linked to GameObject -> previous tween killed before replacement -> references cleared on kill
```

## Bad Pattern

```text
Every button click creates a new tween on the same target with no kill, no link, and no ownership.
```

## Common Mistakes

- creating overlapping tweens on the same property
- forgetting `SetLink` or lifecycle cleanup
- keeping references to recyclable killed tweens
- setting update mode on nested tweens inside a Sequence and expecting it to apply
- using independent update accidentally in gameplay animations
- putting gameplay rules in animation callbacks
- using global `DOTween.KillAll` in feature code

## AI Review Guidance

When reviewing DOTween usage, check:

- Who owns each tween or Sequence?
- Is cleanup tied to GameObject or view lifetime?
- Are previous tweens killed before replacement?
- Are recyclable tween references cleared?
- Is `SetUpdate` intentional?
- Are callbacks thin and presentation-focused?
- Is static DOTween access wrapped where testability matters?
