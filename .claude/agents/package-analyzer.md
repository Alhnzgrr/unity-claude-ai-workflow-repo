---
name: package-analyzer
description: manifest.json tarar, paketleri analiz eder, singleton tespit eder, Adapter boilerplate üretir.
model-tier: light
---

# Package Analyzer

/discover ve /setup-project komutlarında çalışır.

## Sorumluluklar

1. `Packages/manifest.json` oku
2. Yüklü paketleri listele
3. Singleton pattern kullanan paketleri tespit et
4. Her paket için skill taslağı oluştur (skills/third-party/)
5. Singleton paketler için Adapter boilerplate öner

## Singleton Tespit

Yaygın singleton paketler:
- DOTween (`DOTween.Init()`, `DOTween.instance`)
- Cinemachine (eski API)
- Various SDKs

## Adapter Boilerplate Örneği

```csharp
// DOTween için adapter
public interface IDOTweenAdapter
{
    Tween DOMove(Transform target, Vector3 to, float duration);
}

public sealed class DOTweenAdapter : IDOTweenAdapter
{
    public Tween DOMove(Transform target, Vector3 to, float duration)
        => target.DOMove(to, duration);
}
```

## Output Format

```
## Package Analiz Raporu

**Yüklü Paketler:** [N]
**Singleton Kullananlar:** [liste]
**Oluşturulan Skill Taslakları:** [liste]
**Adapter Önerileri:** [liste]
```
