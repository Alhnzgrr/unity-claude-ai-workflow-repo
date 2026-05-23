---
name: dotween
description: DOTween tween library pattern'leri. Adapter pattern ile DI uyumlu kullanım.
---

# DOTween

## Önemli: DOTween Singleton Problemi

DOTween.Init() global singleton kullanır. Bu singleton, DI container'ın dışında.
Çözüm: Adapter pattern ile sarmalayın.

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

## DOTween Init (AppScope'ta)

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

## Tween Temizleme

```csharp
void OnDisable()
{
    DOTween.Kill(transform);
}
```
