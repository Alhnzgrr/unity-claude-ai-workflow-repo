# Unity Claude AI Workflow

Unity 6 projeleri için Claude Code entegreli multi-agent AI workflow sistemi.

## Kurulum

Bu `.claude/` klasörünü Unity projenizin root dizinine kopyalayın.
Ardından `/setup-project` çalıştırın — DI container, input sistemi ve
opsiyonel feature'ları detect edip yapılandırır.

## Hızlı Başlangıç

```
/context-prime    → Projeyi Claude'a tanıt
/setup-project    → DI/Input/async detect + feature seçimi
/game-idea        → Yeni proje: GDD oluştur
/implement <task> → Mevcut proje: TDD pipeline başlat
```

## Mimari Prensipler

- **DI zorunlu:** VContainer veya Zenject (singleton yasak)
- **Async:** UniTask (coroutine yasak)
- **Input:** New Input System veya Legacy (detect edilir)
- **Scene/Prefab:** MCP ile düzenle, direkt edit yasak
- **Modül yapısı:** Interface → Service → Config → Installer → Events

## Review Modları

`production/review-mode.txt` dosyasını düzenle:
- `solo` — Sadece coder → committer (jam/prototip)
- `lean` — Tam pipeline, default
- `full` — unity-developer her zaman aktif

## Belgeler

@.claude/docs/hooks-blocking.md
@.claude/docs/agents-index.md
@.claude/docs/skills-index.md
@.claude/docs/commands.md
@.claude/docs/auto-loaded-skills.md

## Proje Konfigürasyonu

Mevcut ayarlar: `.claude/project-config.json`
Hook'lar ve izinler: `.claude/settings.json` (Claude tarafından edit edilemez)
Session state: `.claude/state/` (.gitignore'da)
