# Unity Claude AI Workflow — Design Spec

**Date:** 2026-05-22  
**Status:** Approved  

---

## 1. Proje Amacı

Unity 6 projeleri için Claude Code entegreli, multi-agent, public dağıtılabilir bir AI workflow sistemi. Kullanıcı `.claude/` klasörünü kendi Unity projesine kopyalayarak sistemi aktive eder. Sistem; slash command pipeline'ları, uzman agent'lar, mimari kurallar, guardrail hook'ları ve akıllı skill kütüphanesi aracılığıyla AI destekli oyun geliştirmeyi disiplinli ve sürdürülebilir kılar.

---

## 2. Dağıtım Stratejisi — Pure `.claude/` Template (Yaklaşım A)

Repo'nun kendisi kullanılabilir bir `.claude/` klasörü içerir. Kurulum: Unity projesine kopyala-yapıştır.

```
unity-claude-ai-workflow-repo/
├── .claude/
│   ├── CLAUDE.md
│   ├── settings.json
│   ├── project-config.json
│   ├── commands/
│   ├── agents/
│   ├── rules/
│   ├── skills/
│   ├── hooks/
│   ├── docs/
│   └── state/              ← .gitignore'da, repoya gitmez
├── docs/
│   ├── SETUP.md
│   ├── QUICKSTART.md
│   └── superpowers/specs/
└── README.md
```

**Temel kısıtlar:**
- `settings.json` Claude tarafından edit edilemez (`guard-config-files.sh` bloğu)
- `state/` klasörü `.gitignore`'da — session verisi repoya gitmez
- `project-config.json` kullanıcı konfigürasyonunun tek source of truth'u

---

## 3. Paket Stack & Auto-Detection

Sistem zorunlu bir stack dayatmaz; projedeki paketi detect eder.

| Kategori | Desteklenen Seçenekler | Detection |
|---|---|---|
| DI Container | VContainer veya Zenject | `manifest.json` tarama |
| Async | UniTask | `manifest.json` tarama |
| Input | New Input System veya Legacy | `ProjectSettings/InputManager.asset` |

`/setup-project` çalışınca detect sonuçları `project-config.json`'a yazılır:

```json
{
  "di": "vcontainer",
  "async": "unitask",
  "input": "new",
  "ecs": false,
  "addressables": false,
  "xr": false,
  "platform": "general"
}
```

**Opsiyonel feature'lar:** `/setup-project` sihirbazında seçilir, `manifest.json` detect ile doğrulanır.

---

## 4. Command Seti (~25 command)

### Tasarım Fazı
| Command | Açıklama |
|---|---|
| `/game-idea` | Ham fikri GDD'ye dönüştürür |
| `/architect` | GDD → TDD, `unity-critic` adversarial review ile |
| `/plan-workflow` | TDD'yi fazlara ve task'lara böler → `WORKFLOW.md` |
| `/dry-run` | Orchestration planını execute etmeden önizler |

### Implementasyon Fazı
| Command | Açıklama |
|---|---|
| `/setup-project` | Detect + seçim sihirbazı, klasör yapısını oluşturur |
| `/implement <task>` | TDD pipeline: test → coder → verifier → reviewer → committer |
| `/fix <bug>` | Bug fix pipeline: scout → fixer → test → reviewer → committer |
| `/fix-lite <bug>` | Hızlı yol: NullRef, typo, tek satır |
| `/fix-deep <bug>` | Evidence-first: root cause kanıtlanmadan fix yok |
| `/orchestrate` | `WORKFLOW.md`'yi faz faz execute eder |
| `/continue` | Kesilen `/orchestrate`'i devam ettirir |
| `/new-module` | 5 dosya scaffold (Interface, Service, Config, Installer, Events) |

### Kalite Fazı
| Command | Açıklama |
|---|---|
| `/qa` | Tam kalite pipeline: ralph → silent-failure-hunt → validate |
| `/ralph` | Yeşil olana kadar verify-fix loop (max 10 iterasyon) |
| `/validate` | Faz için exit criteria kontrolü |
| `/review-code` | Belirli dosyaları derinlemesine review eder |
| `/performance-audit` | Hot path allocation & draw call denetimi |

### Dokümantasyon & Öğrenme
| Command | Açıklama |
|---|---|
| `/learn` | Proje-spesifik pattern'leri `skills/learned/` altına kaydeder |
| `/catch-up` | İnsan-okunabilir codebase kılavuzu → `docs/CATCH_UP.md` |
| `/adr <karar>` | Architecture Decision Record oluşturur |
| `/smart-commit` | Dirty tree'yi semantic commit'lere böler |

### Session & Bağlam
| Command | Açıklama |
|---|---|
| `/context-prime` | Session başında Claude'u proje bağlamına sokar |
| `/checkpoint` | Konuşma özetini state'e kaydeder |
| `/search <sorgu>` | Codebase araştırması → action router |
| `/discover` | `manifest.json` tarayıp paket skill'leri üretir |

---

## 5. Agent Roster (22 agent)

### Core Pipeline
| Agent | Rol | Model Tier |
|---|---|---|
| `unity-coder` | Ana Unity kodlayıcı | normal (Sonnet) |
| `coder` | Pure C# / `_Framework/` | normal (Sonnet) |
| `unity-coder-lite` | Küçük değişiklikler | normal (Sonnet) |
| `tester` | NUnit + NSubstitute test yazarı | normal (Sonnet) |
| `unity-verifier` | Compile + test (MCP-aware) | light (Haiku) |
| `reviewer` | Genel kod review | normal (Sonnet) |
| `unity-reviewer` | Unity-spesifik review | normal (Sonnet) |
| `committer` | Semantic git commit | light (Haiku) |

### Uzman
| Agent | Rol | Model Tier |
|---|---|---|
| `unity-fixer` | Tam context'li bug düzeltici | normal (Sonnet) |
| `unity-fixer-lite` | NullRef, typo, hızlı fix | light (Haiku) |
| `unity-scout` | Read-only codebase araştırmacısı | light (Haiku) |
| `unity-critic` | Adversarial plan sorgulayıcı | heavy (Opus) |
| `silent-failure-hunter` | Exception/async void/event leak denetimi | normal (Sonnet) |
| `unity-developer` | İkinci reviewer (`full` mode) | normal (Sonnet) |

### Setup & Yapılandırma
| Agent | Rol | Model Tier |
|---|---|---|
| `unity-setup` | Sahne/prefab/ScriptableObject (MCP-aware) | normal (Sonnet) |
| `unity-scene-builder` | Sahne kompozisyonu (MCP-aware) | normal (Sonnet) |
| `unity-migrator` | Legacy pattern geçişi | normal (Sonnet) |
| `package-analyzer` | `manifest.json` tarama, singleton tespiti | light (Haiku) |

### Kalite & Performans
| Agent | Rol | Model Tier |
|---|---|---|
| `unity-optimizer` | Runtime performans denetimi | normal (Sonnet) |
| `unity-linter` | Static analiz | light (Haiku) |

### Mimari & Build
| Agent | Rol | Model Tier |
|---|---|---|
| `unity-architect` | Sistem tasarımı, sınır tanımı | heavy (Opus) |
| `unity-build-runner` | CI/build pipeline | normal (Sonnet) |

---

## 6. Rules (12 + 2 opsiyonel)

Her session'da yüklenen zorunlu kurallar:

| Dosya | Enforce Ettiği |
|---|---|
| `architecture.md` | Katman ayrımı, DI zorunluluğu, modül yapısı |
| `dependency-injection.md` | VContainer/Zenject (detect edilen); singleton yasak |
| `async.md` | UniTask zorunlu; coroutine, `async void`, Task yasak |
| `unity-lifecycle.md` | Awake/OnEnable/Start disiplini, Editor guard'lar |
| `unity-input.md` | Detect edilen input sistemi; input logic View'da kalır |
| `performance.md` | Hot path'te sıfır allocation, LINQ yasak, cache zorunlu |
| `serialization.md` | FormerlySerializedAs zorunlu, runtime state serialize edilmez |
| `testing.md` | EditMode/PlayMode karar ağacı, AAA pattern |
| `event-patterns.md` | UnityEvent yasak; IEventBus vs C# event karar ağacı |
| `unity-prefabs.md` | Her scene object prefab; `new GameObject()` yasak |
| `scene-hierarchy.md` | 6 container standardı: [Setup]→[Services]→[UI]→[Environment]→[Characters]→[VFX] |
| `csharp-unity.md` | PascalCase tipler, `_camelCase` field'lar, namespace, #region |

**Opsiyonel (project-config.json'a göre):**
- `ecs-dots.md` — `"ecs": true` ise
- `addressables.md` — `"addressables": true` ise

---

## 7. Hooks

### Blocking (exit 2 — yazma durur)
| Hook | Engellediği |
|---|---|
| `block-scene-edit.sh` | `.unity`/`.prefab`/`.asset` direkt edit |
| `guard-editor-runtime.sh` | Runtime'da `UnityEditor` namespace (guard'sız) |
| `check-pure-csharp.sh` | `_Framework/`'te `using UnityEngine` |
| `check-input-system.sh` | `Input.GetKey/Axis` (New Input System seçiliyse) |
| `check-singleton.sh` | Static singleton pattern |
| `check-unity-event.sh` | `UnityEvent`, `UnityEvent<T>` |
| `check-coroutine.sh` | `IEnumerator`, `StartCoroutine` |
| `guard-config-files.sh` | `settings.json`, `.asmdef`, `manifest.json` edit |
| `gateguard.sh` | Session'da okunmamış C# dosyasını edit |

### Warning (exit 0 — uyarı, devam eder)
| Hook | Uyardığı |
|---|---|
| `check-linq-hotpath.sh` | Update/FixedUpdate içinde LINQ |
| `check-expensive-hotpath.sh` | Hot path'te `GetComponent`, `Camera.main`, `Find*` |
| `check-async-void.sh` | `async void` (lifecycle dışında) |
| `check-unitask-cancellation.sh` | CancellationToken eksik async metodlar |
| `check-null-propagation.sh` | Unity object'lerde `?.` veya `is null` |
| `warn-serialization.sh` | Rename'de FormerlySerializedAs eksik |

**MCP-aware:** `block-scene-edit.sh` — MCP bağlıysa "MCP kullan" yönlendirir, değilse "manuel yap" talimatı verir.

---

## 8. Skills Yapısı

```
.claude/skills/
├── core/                        ← Her zaman yüklü
│   ├── model-routing.md
│   ├── unity-instincts/
│   ├── unity-mcp-patterns/
│   └── context-management/
├── systems/                     ← İhtiyaçta yüklenir
│   ├── audio/
│   ├── physics/
│   ├── animation/
│   ├── ui-toolkit/
│   ├── urp-pipeline/
│   ├── cinemachine/
│   ├── shader-graph/
│   ├── addressables/            ← "addressables": true ise auto-yüklenir
│   └── vr/                      ← "xr": true ise auto-yüklenir
├── third-party/                 ← manifest.json detect'e göre auto-yüklenir
│   ├── vcontainer/
│   ├── zenject/
│   ├── unitask/
│   ├── dotween/
│   └── textmeshpro/
└── learned/                     ← /learn ile üretilir, auto-yüklenir
```

---

## 9. Director Gates

| Gate | Tetikleyen Command'lar | Beklediği |
|---|---|---|
| `SCOPE_GATE` | `/implement`, `/fix`, `/orchestrate` başında | `go` veya yönlendirme |
| `ARCHITECTURE_GATE` | Yeni modül tespit edildiğinde | Modül yapısı onayı |
| `BREAKING_GATE` | 3+ dosya etkileyen değişiklik | Kasıtlı olduğu onayı |
| `QUALITY_GATE` | Reviewer `CHANGES NEEDED` dönünce | `fix` / `skip` / `stop` |
| `COMMIT_GATE` | Tüm verification sonrası | Final staged dosya onayı |

**Mekanik:** Gate onayı → `.claude/state/gate-cleared` oluşur → hook'lar kontrol eder → pipeline devam eder → pipeline biter → dosya silinir.

---

## 10. Review Mode

`production/review-mode.txt` ile kontrol edilir:

| Mode | Davranış |
|---|---|
| `solo` | Coder → Committer (prototip/jam için) |
| `lean` | Standart pipeline — default |
| `full` | `unity-developer` her zaman aktif (takım review) |

---

## 11. Temel Pipeline — `/implement`

```
[SCOPE_GATE]
    ↓
[1] tester        → testler yazar (FAIL beklenir)
    ↓
[2] unity-coder   → testleri geçirecek implementasyon
    ↓
[3] unity-verifier → compile + test çalıştır (max 2 fix pass)
    ↓
[4] reviewer      → APPROVED veya CHANGES NEEDED loop (max 3 pass)
    ↓              [QUALITY_GATE if CHANGES NEEDED]
[5] silent-failure-hunter → exception/async void/event leak denetimi
    ↓
[6] committer     → semantic git commit
    ↓
[COMMIT_GATE]
```

---

## 12. MCP Entegrasyonu

Opsiyonel — sistem MCP varlığını session başında detect eder:

- **MCP bağlı:** `unity-setup`, `unity-scene-builder`, `unity-verifier` tam MCP workflow'u kullanır
- **MCP yok:** Fallback talimatlar verilir (kullanıcıya manuel adımlar), pipeline devam eder

`block-scene-edit.sh` MCP durumuna göre mesaj üretir.

---

## 13. Kapsam Dışı (Bu Versiyon İçin)

- Mobile platform skill'leri
- PC platform skill'leri
- Codex / Cursor adapter'ları
- Install scriptleri (kullanıcı manuel kopyalar)
- CI/CD pipeline entegrasyonu (build runner agent mevcut ama CI kurulumu değil)
