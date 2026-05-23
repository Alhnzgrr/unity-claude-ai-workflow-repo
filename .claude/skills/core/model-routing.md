# Model Routing

Hangi görev için hangi model kullanılır.

## Model Tier'ları

| Tier | Model | Ne Zaman |
|---|---|---|
| light | Haiku | Read-only, formatting, hızlı özet, linting |
| normal | Sonnet | Kod üretimi, review, debugging, implementasyon |
| heavy | Opus | Mimari tasarım, adversarial review, kritik kararlar |

## Agent → Tier Eşlemesi

### light (Haiku)
- `unity-verifier` — compile/test sonuç okuma
- `committer` — commit mesajı üretme
- `unity-scout` — read-only araştırma
- `unity-fixer-lite` — tek satır fix
- `unity-linter` — convention kontrolü
- `package-analyzer` — manifest okuma

### normal (Sonnet)
- `unity-coder`, `coder`, `unity-coder-lite`
- `tester`
- `reviewer`, `unity-reviewer`, `unity-developer`
- `unity-fixer`, `unity-migrator`
- `silent-failure-hunter`
- `unity-setup`, `unity-scene-builder`
- `unity-optimizer`, `unity-build-runner`

### heavy (Opus)
- `unity-architect` — sistem tasarımı
- `unity-critic` — adversarial plan review

## Complexity Score → Model Seçimi

0.0 – 0.3 → light veya normal
0.4 – 0.6 → normal
0.7 – 1.0 → heavy (architect) + normal (coder)

Complexity hesaplama:
- Yeni modül mü? +0.3
- Birden fazla sistem etkiliyor mu? +0.2
- ECS veya Addressables mı? +0.2
- Test gerekiyor mu? +0.1
- Mevcut kodu değiştiriyor mu? +0.1
- Tek dosya tek metod mu? 0.1
