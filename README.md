# Unity Claude AI Workflow

Unity 6 projeleri için Claude Code entegreli multi-agent AI workflow sistemi.

## Özellikler

- **25 slash command** — `/implement`, `/fix`, `/orchestrate`, `/qa` ve daha fazlası
- **22 uzman agent** — coder, tester, reviewer, fixer, scout, critic ve daha fazlası
- **12 mimari kural** — DI, async, lifecycle, performance, serialization...
- **15 guardrail hook** — Singleton, coroutine, UnityEvent, direkt scene edit engeli
- **Skills kütüphanesi** — VContainer, Zenject, UniTask, VR, URP ve daha fazlası
- **Director Gates** — Kritik noktalarda insan onayı checkpoint'leri
- **Auto-detect** — DI container, input sistemi manifest.json'dan otomatik tespit

## Kurulum

1. Bu repoyu klonla
2. `.claude/` klasörünü Unity projenin root dizinine kopyala
3. Claude Code'u Unity proje dizininde aç
4. `/setup-project` komutunu çalıştır

## Gereksinimler

- Unity 6 (6000.x)
- Claude Code CLI
- Git Bash (hook'lar için)
- UniTask (manifest.json'da kayıtlı olmalı)
- VContainer veya Zenject (birini seç)

## Hızlı Başlangıç

```
/context-prime     Projeyi Claude'a tanıt
/game-idea         Yeni oyun fikri → GDD
/architect         GDD → TDD (teknik tasarım)
/plan-workflow     TDD → WORKFLOW.md (fazlar + task'lar)
/orchestrate       WORKFLOW.md'yi execute et
```

## Lisans

MIT