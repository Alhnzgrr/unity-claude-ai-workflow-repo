---
name: dotween
description: DOTween tween library patterns. DI-compatible usage with adapter pattern.
---

# DOTween

## Important: DOTween Singleton Problem

DOTween.Init() uses a global singleton. This singleton is outside the DI container.
Solution: wrap it with an adapter pattern.

## Adapter Pattern

```csharp
public interface ITweenService
{
    Tween MoveTo(Transform target, Vector3 to, float duration);
    Tween FadeTo(CanvasGroup cg, float to, float duration);
    void KillAll(Transform target);
}

public sealed class DOTweenAdapter : ITweenService
{
    public Tween MoveTo(Transform target, Vector3 to, float duration)
        => target.DOMove(to, duration).SetUpdate(true);

    public Tween FadeTo(CanvasGroup cg, float to, float duration)
        => cg.DOFade(to, duration);

    public void KillAll(Transform target)
        => DOTween.Kill(target);
}
```

## DOTween Init (in AppScope)

```csharp
public class AppScope : LifetimeScope
{
    protected override void Configure(IContainerBuilder builder)
    {
        DOTween.Init(recycleAllByDefault: true, useSafeMode: false)
               .SetCapacity(200, 50);

        builder.Register<DOTweenAdapter>(Lifetime.Singleton).As<ITweenService>();
    }
}
```

## Sequence Pattern

```csharp
public async UniTask AnimateEntryAsync(CancellationToken ct)
{
    var tcs = new UniTaskCompletionSource();
    var sequence = DOTween.Sequence()
        .Append(_panel.DOFade(1f, 0.3f))
        .Append(_title.DOScale(1.1f, 0.2f).SetEase(Ease.OutBack))
        .OnComplete(() => tcs.TrySetResult());

    await tcs.Task.AttachExternalCancellation(ct);
}
```

## Tween Cleanup

```csharp
void OnDisable()
{
    DOTween.Kill(transform);
}
```
