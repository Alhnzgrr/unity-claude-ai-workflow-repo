# Unity Claude AI Workflow — Phase 1: Foundation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Repository iskeletini, ana config dosyalarını ve CLAUDE.md giriş noktasını oluştur.

**Architecture:** Pure `.claude/` template — kullanıcı bu klasörü Unity projesine kopyalar. CLAUDE.md ana giriş noktası, settings.json hook/izin konfigürasyonu, project-config.json proje özellik bayrakları.

**Tech Stack:** Bash (hooks), JSON (config), Markdown (docs)

---

## Dosya Haritası

| Dosya | Açıklama |
|---|---|
| `.claude/CLAUDE.md` | Ana giriş noktası — session başında yüklenir |
| `.claude/settings.json` | Hook'lar ve izinler — Claude tarafından edit edilemez |
| `.claude/project-config.json` | Proje özellik bayrakları (di, async, input, ecs...) |
| `.claude/docs/agents-index.md` | Agent roster özeti |
| `.claude/docs/skills-index.md` | Skills kütüphane özeti |
| `.claude/docs/hooks-blocking.md` | Blocking hook'lar tablosu |
| `.claude/docs/commands.md` | Command referansı |
| `.claude/docs/auto-loaded-skills.md` | @-include ile auto-yüklenen skill'ler |
| `.claude/state/.gitkeep` | state/ klasörünü git'te tutar, içerik ignore'da |
| `production/review-mode.txt` | solo / lean / full |
| `.gitignore` | state/, production/ içindeki runtime dosyaları |
| `README.md` | Kullanıcıya yönelik kurulum kılavuzu |

---

### Task 1: Klasör İskeleti ve .gitignore

**Files:**
- Create: `.claude/commands/.gitkeep`
- Create: `.claude/agents/.gitkeep`
- Create: `.claude/rules/.gitkeep`
- Create: `.claude/skills/core/.gitkeep`
- Create: `.claude/skills/systems/.gitkeep`
- Create: `.claude/skills/third-party/.gitkeep`
- Create: `.claude/skills/learned/.gitkeep`
- Create: `.claude/hooks/.gitkeep`
- Create: `.claude/docs/.gitkeep`
- Create: `.claude/state/.gitkeep`
- Create: `production/.gitkeep`
- Create: `.gitignore`

- [ ] **Step 1: Klasörleri oluştur**

```powershell
$dirs = @(
  ".claude/commands",".claude/agents",".claude/rules",
  ".claude/skills/core",".claude/skills/systems",
  ".claude/skills/third-party",".claude/skills/learned",
  ".claude/hooks",".claude/docs",".claude/state",
  "production","docs/decisions"
)
foreach ($d in $dirs) { New-Item -ItemType Directory -Force $d | Out-Null }
foreach ($d in $dirs) { New-Item -ItemType File -Force "$d/.gitkeep" | Out-Null }
```

- [ ] **Step 2: .gitignore oluştur**

`.gitignore` içeriği:

```
# Claude session state — repoya gitmez
.claude/state/session.json
.claude/state/checkpoint.md
.claude/state/gate-cleared
.claude/state/learnings.jsonl
.claude/state/instincts/

# Runtime üretilen dosyalar
production/session-state/

# OS
.DS_Store
Thumbs.db
```

- [ ] **Step 3: Verify**

```powershell
Get-ChildItem .claude -Recurse -Directory | Select-Object FullName
```

Beklenen: commands, agents, rules, skills/core, skills/systems, skills/third-party, skills/learned, hooks, docs, state görünür.

- [ ] **Step 4: Commit**

```bash
git add .gitignore .claude/ production/
git commit -m "feat: add repository skeleton and .gitignore"
```

---

### Task 2: project-config.json

**Files:**
- Create: `.claude/project-config.json`

- [ ] **Step 1: project-config.json yaz**

```json
{
  "_comment": "Bu dosya /setup-project komutu tarafından doldurulur. Manuel de düzenlenebilir.",
  "di": "vcontainer",
  "async": "unitask",
  "input": "new",
  "ecs": false,
  "addressables": false,
  "xr": false,
  "platform": "general",
  "unity_version": "6000",
  "review_mode": "lean"
}
```

`di` değerleri: `"vcontainer"` | `"zenject"` | `"none"`
`input` değerleri: `"new"` | `"legacy"`

- [ ] **Step 2: Verify**

```powershell
Get-Content .claude/project-config.json | ConvertFrom-Json | Format-List
```

Beklenen: tüm alanlar listelenir, JSON geçerli.

- [ ] **Step 3: Commit**

```bash
git add .claude/project-config.json
git commit -m "feat: add project-config.json with default values"
```

---

### Task 3: production/review-mode.txt

**Files:**
- Create: `production/review-mode.txt`

- [ ] **Step 1: Dosyayı yaz**

`production/review-mode.txt` içeriği:

```
lean
```

Geçerli değerler:
- `solo` → Coder → Committer (prototip/jam, test ve review yok)
- `lean` → Tam pipeline ama `unity-developer` opsiyonel (default)
- `full` → `unity-developer` her zaman aktif (takım review)

- [ ] **Step 2: Commit**

```bash
git add production/review-mode.txt
git commit -m "feat: add review-mode.txt with lean default"
```

---

### Task 4: settings.json

**Files:**
- Create: `.claude/settings.json`

- [ ] **Step 1: settings.json yaz**

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(bash .claude/hooks/*)",
      "Bash(cat *)",
      "Bash(jq *)",
      "Read(*)",
      "Write(*)",
      "Edit(*)",
      "Glob(*)",
      "Grep(*)",
      "Agent(*)",
      "WebSearch(*)",
      "WebFetch(*)"
    ],
    "deny": [
      "Edit(.claude/settings.json)",
      "Write(.claude/settings.json)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/block-scene-edit.sh"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/guard-editor-runtime.sh"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/check-pure-csharp.sh"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/check-input-system.sh"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/check-singleton.sh"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/check-unity-event.sh"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/check-coroutine.sh"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/guard-config-files.sh"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/gateguard.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/check-linq-hotpath.sh"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/check-expensive-hotpath.sh"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/check-async-void.sh"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/check-unitask-cancellation.sh"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/check-null-propagation.sh"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/warn-serialization.sh"
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 2: Verify — JSON geçerlilik**

```powershell
Get-Content .claude/settings.json | ConvertFrom-Json | Format-List
```

Beklenen: hata yok, tüm hook'lar listelenir.

- [ ] **Step 3: Commit**

```bash
git add .claude/settings.json
git commit -m "feat: add settings.json with hook registrations and permissions"
```

---

### Task 5: CLAUDE.md

**Files:**
- Create: `.claude/CLAUDE.md`
- Create: `.claude/docs/hooks-blocking.md`
- Create: `.claude/docs/agents-index.md`
- Create: `.claude/docs/skills-index.md`
- Create: `.claude/docs/commands.md`
- Create: `.claude/docs/auto-loaded-skills.md`

- [ ] **Step 1: .claude/docs/hooks-blocking.md yaz**

```markdown
# Blocking Hooks

Bu hook'lar exit 2 ile dönünce yazma işlemi durur.

| Hook | Engellediği |
|---|---|
| `block-scene-edit.sh` | `.unity`/`.prefab`/`.asset` direkt edit |
| `guard-editor-runtime.sh` | Runtime'da `UnityEditor` namespace (guard'sız) |
| `check-pure-csharp.sh` | `_Framework/` içinde `using UnityEngine` |
| `check-input-system.sh` | `Input.GetKey/Axis` (New Input System seçiliyse) |
| `check-singleton.sh` | Static singleton pattern (`Instance`, `_instance`) |
| `check-unity-event.sh` | `UnityEvent`, `UnityEvent<T>` kullanımı |
| `check-coroutine.sh` | `IEnumerator`, `StartCoroutine` |
| `guard-config-files.sh` | `settings.json`, `.asmdef`, `manifest.json` edit |
| `gateguard.sh` | Session'da okunmamış C# dosyasını edit girişimi |
```

- [ ] **Step 2: .claude/docs/agents-index.md yaz**

```markdown
# Agent Roster

## Core Pipeline
| Agent | Rol | Model |
|---|---|---|
| `unity-coder` | Ana Unity kodlayıcı | Sonnet |
| `coder` | Pure C# / _Framework/ | Sonnet |
| `unity-coder-lite` | Küçük değişiklikler | Sonnet |
| `tester` | NUnit + NSubstitute test yazarı | Sonnet |
| `unity-verifier` | Compile + test (MCP-aware) | Haiku |
| `reviewer` | Genel kod review | Sonnet |
| `unity-reviewer` | Unity-spesifik review | Sonnet |
| `committer` | Semantic git commit | Haiku |

## Uzman
| Agent | Rol | Model |
|---|---|---|
| `unity-fixer` | Tam context'li bug düzeltici | Sonnet |
| `unity-fixer-lite` | NullRef, typo, hızlı fix | Haiku |
| `unity-scout` | Read-only codebase araştırmacısı | Haiku |
| `unity-critic` | Adversarial plan sorgulayıcı | Opus |
| `silent-failure-hunter` | Exception/async void/event leak denetimi | Sonnet |
| `unity-developer` | İkinci reviewer (full mode) | Sonnet |

## Setup & Yapılandırma
| Agent | Rol | Model |
|---|---|---|
| `unity-setup` | Sahne/prefab/ScriptableObject (MCP-aware) | Sonnet |
| `unity-scene-builder` | Sahne kompozisyonu (MCP-aware) | Sonnet |
| `unity-migrator` | Legacy pattern geçişi | Sonnet |
| `package-analyzer` | manifest.json tarama, singleton tespiti | Haiku |

## Kalite & Mimari
| Agent | Rol | Model |
|---|---|---|
| `unity-optimizer` | Runtime performans denetimi | Sonnet |
| `unity-linter` | Static analiz | Haiku |
| `unity-architect` | Sistem tasarımı, sınır tanımı | Opus |
| `unity-build-runner` | CI/build pipeline | Sonnet |
```

- [ ] **Step 3: .claude/docs/skills-index.md yaz**

```markdown
# Skills Kütüphanesi

## core/ (Her zaman yüklü)
- `model-routing.md` — Hangi task'ta hangi model
- `unity-instincts/` — Proje genelinde geçerli hızlı kararlar
- `unity-mcp-patterns/` — MCP kullanım pattern'leri
- `context-management/` — Review mode, compaction, checkpoint

## systems/ (İhtiyaçta yüklenir)
- `audio/` `physics/` `animation/` `ui-toolkit/`
- `urp-pipeline/` `cinemachine/` `shader-graph/`
- `addressables/` (project-config: addressables=true)
- `vr/` (project-config: xr=true)

## third-party/ (manifest.json detect'e göre auto-yüklenir)
- `vcontainer/` `zenject/` `unitask/` `dotween/` `textmeshpro/`

## learned/ (/learn ile üretilir, auto-yüklenir)
- Proje-spesifik keşfedilen pattern'ler
```

- [ ] **Step 4: .claude/docs/commands.md yaz**

```markdown
# Command Referansı

## Tasarım Fazı
| Command | Açıklama |
|---|---|
| `/game-idea` | Ham fikri GDD'ye dönüştürür |
| `/architect` | GDD → TDD, unity-critic ile adversarial review |
| `/plan-workflow` | TDD'yi fazlara böler → WORKFLOW.md |
| `/dry-run` | Orchestration planını önizler |

## Implementasyon Fazı
| Command | Açıklama |
|---|---|
| `/setup-project` | Detect + seçim sihirbazı, klasör yapısını oluşturur |
| `/implement <task>` | TDD pipeline: test→coder→verifier→reviewer→committer |
| `/fix <bug>` | Bug fix pipeline |
| `/fix-lite <bug>` | Hızlı yol: NullRef, typo, tek satır |
| `/fix-deep <bug>` | Evidence-first: root cause kanıtlanmadan fix yok |
| `/orchestrate` | WORKFLOW.md'yi faz faz execute eder |
| `/continue` | Kesilen /orchestrate'i devam ettirir |
| `/new-module` | 5 dosya scaffold (Interface, Service, Config, Installer, Events) |

## Kalite Fazı
| Command | Açıklama |
|---|---|
| `/qa` | Tam kalite pipeline: ralph→silent-failure-hunt→validate |
| `/ralph` | Yeşil olana kadar verify-fix loop (max 10 iterasyon) |
| `/validate` | Faz için exit criteria kontrolü |
| `/review-code` | Belirli dosyaları derinlemesine review eder |
| `/performance-audit` | Hot path allocation & draw call denetimi |

## Dokümantasyon & Öğrenme
| Command | Açıklama |
|---|---|
| `/learn` | Pattern'leri skills/learned/ altına kaydeder |
| `/catch-up` | İnsan-okunabilir codebase kılavuzu → docs/CATCH_UP.md |
| `/adr <karar>` | Architecture Decision Record oluşturur |
| `/smart-commit` | Dirty tree'yi semantic commit'lere böler |

## Session & Bağlam
| Command | Açıklama |
|---|---|
| `/context-prime` | Session başında Claude'u proje bağlamına sokar |
| `/checkpoint` | Konuşma özetini state'e kaydeder |
| `/search <sorgu>` | Codebase araştırması → action router |
| `/discover` | manifest.json tarayıp paket skill'leri üretir |
```

- [ ] **Step 5: .claude/docs/auto-loaded-skills.md yaz**

```markdown
# Auto-Loaded Skills

Bu dosya hooks tarafından otomatik güncellenir.
Aşağıdaki skill'ler her session'da yüklenir:

@.claude/skills/core/model-routing.md
@.claude/skills/core/unity-instincts/SKILL.md
@.claude/skills/core/unity-mcp-patterns/SKILL.md
@.claude/skills/core/context-management/SKILL.md
```

- [ ] **Step 6: .claude/CLAUDE.md yaz**

```markdown
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
```

- [ ] **Step 7: Verify — CLAUDE.md @-include'lar mevcut mu?**

```powershell
Select-String -Path ".claude/CLAUDE.md" -Pattern "@.claude/docs/"
```

Beklenen: 5 satır `@.claude/docs/` ile başlar.

- [ ] **Step 8: Commit**

```bash
git add .claude/CLAUDE.md .claude/docs/
git commit -m "feat: add CLAUDE.md entry point and supporting docs"
```

---

### Task 6: README.md

**Files:**
- Create: `README.md`
- Create: `docs/SETUP.md`
- Create: `docs/QUICKSTART.md`

- [ ] **Step 1: README.md yaz**

```markdown
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
```

- [ ] **Step 2: docs/SETUP.md yaz**

```markdown
# Kurulum Kılavuzu

## 1. .claude/ Klasörünü Kopyala

```bash
cp -r unity-claude-ai-workflow-repo/.claude/ YourUnityProject/.claude/
```

Windows:
```powershell
Copy-Item -Recurse unity-claude-ai-workflow-repo\.claude\ YourUnityProject\.claude\
```

## 2. Git Bash Kurulu Olduğundan Emin Ol

Hook'lar bash script'leri. Windows'ta Git Bash gerekli.

## 3. Hook İzinlerini Ver (Linux/Mac)

```bash
chmod +x YourUnityProject/.claude/hooks/*.sh
```

## 4. Claude Code'u Aç

Unity proje root dizininde Claude Code'u başlat.

## 5. Setup Sihirbazını Çalıştır

```
/setup-project
```

Bu komut:
- `manifest.json` tarayıp VContainer/Zenject, UniTask tespit eder
- Input sistemini tespit eder
- ECS, Addressables, XR opsiyonlarını sorar
- `.claude/project-config.json` doldurur
- Önerilen klasör yapısını oluşturur

## Doğrulama

```
/context-prime
```

Claude projeyi tanımlıyorsa kurulum tamamdır.
```

- [ ] **Step 3: docs/QUICKSTART.md yaz**

```markdown
# Hızlı Başlangıç

## Yeni Proje Başlatma

```
/game-idea        → Ham fikri GDD'ye dönüştür
/architect        → GDD'den TDD üret
/plan-workflow    → TDD'yi fazlara böl → WORKFLOW.md
/orchestrate      → WORKFLOW.md'yi execute et
```

## Mevcut Projeye Özellik Ekleme

```
/implement "AudioService implement et"
```

Pipeline otomatik çalışır:
1. Testler yazılır (başarısız)
2. Implementasyon yapılır (testleri geçer)
3. Verify edilir
4. Review yapılır
5. Commit atılır

## Bug Düzeltme

```
/fix "PlayerController NullReferenceException fırlatıyor"
/fix-lite "typo: PlayerControler → PlayerController"
/fix-deep "FixedUpdate arada kayıp frame atıyor, sebebi belirsiz"
```

## Kalite Kontrolü

```
/qa               → Tam kalite pipeline
/review-code      → Belirli dosyaları review et
/performance-audit → Hot path denetimi
```

## Review Modunu Değiştir

`production/review-mode.txt` dosyasını düzenle:
- `solo` — Jam/prototip için hızlı mod
- `lean` — Normal geliştirme (default)
- `full` — Takım review modu
```

- [ ] **Step 4: Commit**

```bash
git add README.md docs/SETUP.md docs/QUICKSTART.md
git commit -m "feat: add README, SETUP and QUICKSTART docs"
```

---

**Phase 1 tamamlandı.** Sonraki: Phase 2 — Rules (12 kural dosyası).
