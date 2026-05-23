# Unity Claude AI Workflow — Phase 6: Commands

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 25 slash command workflow dosyasını oluştur.

**Architecture:** Her command `.claude/commands/<name>.md` dosyası. Kullanıcı `/<name>` yazınca Claude bu dosyayı yükler ve adım adım takip eder. Her dosya: amaç, ön koşullar, adım adım workflow, Director Gate'ler ve output format.

**Tech Stack:** Markdown

---

## Dosya Haritası

```
.claude/commands/
Tasarım:      game-idea.md  architect.md  plan-workflow.md  dry-run.md
Implementasyon: setup-project.md  implement.md  fix.md  fix-lite.md
              fix-deep.md  orchestrate.md  continue.md  new-module.md
Kalite:       qa.md  ralph.md  validate.md  review-code.md  performance-audit.md
Dokümantasyon: learn.md  catch-up.md  adr.md  smart-commit.md
Session:      context-prime.md  checkpoint.md  search.md  discover.md
```

---

### Task 1: Tasarım Fazı Commands

**Files:**
- Create: `.claude/commands/game-idea.md`
- Create: `.claude/commands/architect.md`
- Create: `.claude/commands/plan-workflow.md`
- Create: `.claude/commands/dry-run.md`

- [ ] **Step 1: game-idea.md yaz**

```markdown
# /game-idea

Ham oyun fikrini yapılandırılmış Game Design Document'a (GDD) dönüştürür.

## Kullanım

```
/game-idea [opsiyonel: kısa fikir açıklaması]
```

## Workflow

### Adım 1 — Fikri Anla

Kullanıcıdan şunları öğren (birer birer sor):
1. Temel oyun mekaniği nedir? (Core loop)
2. Hedef platform? (PC, Mobile, VR, Console)
3. Hedef kitle? (Hyper-casual, Core, Hardcore)
4. Referans oyunlar? (Varsa)
5. Öne çıkan özellik nedir? (USP — Unique Selling Point)

### Adım 2 — Varsayımları Yüzey Alt Etme

Belirsiz olan her şeyi somutlaştır:
- "Multiplayer" → kaç oyuncu, online mi local mi?
- "RPG sistemi" → hangi sistemler? inventory, skill tree, leveling?
- "Mobil" → iOS mu Android mu ikisi de mi?

### Adım 3 — "Yapmıyoruz" Listesi

YAGNI prensibine göre kapsam dışına alınacakları belirle.
Kullanıcıya sor: "Bu versiyonda şunları yapmayacağız, doğru mu?"

### Adım 4 — GDD Oluştur

`docs/GDD.md` dosyasına yaz:

```markdown
# Game Design Document — [Oyun Adı]

## Özet
[2-3 cümle elevator pitch]

## Core Loop
[Temel oyun döngüsü adım adım]

## Mekanikler
[Her mekanik için: ne, neden, nasıl]

## Hedef Kitle
[Kim için, neden onlar]

## Platform
[Hedef platform ve kısıtları]

## Kapsam Dışı (Bu Versiyon)
[Yapılmayacaklar listesi]

## Başarı Kriterleri
[Nasıl anlarsın oyun çalışıyor?]
```

### Adım 5 — Commit

```bash
git add docs/GDD.md
git commit -m "docs: add Game Design Document for [oyun adı]"
```

## Sonraki Adım

GDD hazırsa: `/architect` ile teknik tasarıma geç.
```

- [ ] **Step 2: architect.md yaz**

```markdown
# /architect

GDD'den Technical Design Document (TDD) üretir. unity-critic ile adversarial review.

## Kullanım

```
/architect
```

## Ön Koşul

`docs/GDD.md` mevcut olmalı. Yoksa önce `/game-idea` çalıştır.

## Workflow

### Adım 1 — GDD Oku

`docs/GDD.md` oku. Core loop ve mekanikleri anla.

### Adım 2 — unity-architect Spawn Et

`unity-architect` agent ile teknik tasarım yap:
- Sistemleri belirle (AudioSystem, PlayerSystem, EnemySystem...)
- Her sistem için modül yapısı: Interface + Service + Config + Installer + Events
- Bağımlılık grafiği çiz
- Veri akışını tanımla

### Adım 3 — unity-critic ile Adversarial Review

`unity-critic` agent'ı spawn et:
- Tasarımın en zayıf noktasını bul
- Tek keskin soru sor
- unity-architect cevap ver, tasarımı güçlendir
- En fazla 3 round

### Adım 4 — TDD Oluştur

`docs/TDD.md` dosyasına yaz:

```markdown
# Technical Design Document — [Oyun Adı]

## Sistemler

### [SystemAdı]
**Sorumluluk:** [tek cümle]
**Interface:** I[SystemAdı]Service
**Bağımlılıklar:** [diğer interface'ler]
**Events:** [yayınladığı ve dinlediği]

## Modül Yapısı
[Her modül için 5 dosya listesi]

## Bağımlılık Grafiği
[Metin veya diagram]

## Veri Akışı
[Önemli senaryolar için sequence]

## Riskler
[Tespit edilen riskler ve önlemler]
```

### Adım 5 — Commit

```bash
git add docs/TDD.md
git commit -m "docs: add Technical Design Document"
```

## Sonraki Adım

TDD hazırsa: `/plan-workflow` ile implementasyon planını oluştur.
```

- [ ] **Step 3: plan-workflow.md yaz**

```markdown
# /plan-workflow

TDD'yi implementasyon fazlarına ve task'lara böler. WORKFLOW.md üretir.

## Kullanım

```
/plan-workflow
```

## Ön Koşul

`docs/TDD.md` mevcut olmalı.

## Workflow

### Adım 1 — TDD Oku

`docs/TDD.md` oku. Tüm sistemleri ve bağımlılıkları anla.

### Adım 2 — Fazları Belirle

Bağımlılık sırasına göre fazları belirle:
- Faz 1: Foundation (Framework, EventBus, DI scaffold)
- Faz 2: Core sistemler (bağımlılığı az olanlar önce)
- Faz 3: Feature sistemler
- Faz 4: UI & polish
- Faz 5: Entegrasyon & QA

### Adım 3 — Task'ları Yaz

Her faz için task'lar:
- Bağımsız task'lar → `parallel_group` ile işaretle
- Her task için: açıklama, agent tipi, input/output, acceptance criteria

### Adım 4 — WORKFLOW.md Oluştur

`docs/WORKFLOW.md` dosyasına yaz:

```markdown
# WORKFLOW — [Proje Adı]

## Faz 1: Foundation

### Task 1.1: EventBus Implementasyonu
- **Agent:** coder
- **Input:** IEventBus interface tanımı
- **Output:** EventBus.cs (Assets/_Framework/Events/)
- **Acceptance:** EditMode testleri geçiyor
- **parallel_group:** foundation

### Task 1.2: Logger Implementasyonu
- **Agent:** coder
- **Input:** ILogger interface tanımı
- **Output:** UnityLogger.cs (Assets/_Framework/Logging/)
- **Acceptance:** EditMode testleri geçiyor
- **parallel_group:** foundation

## Faz 2: Core Sistemler
...
```

### Adım 5 — Commit

```bash
git add docs/WORKFLOW.md
git commit -m "docs: add WORKFLOW.md with phased implementation plan"
```

## Sonraki Adım

`/dry-run` ile önizle veya `/orchestrate` ile execute et.
```

- [ ] **Step 4: dry-run.md yaz**

```markdown
# /dry-run

WORKFLOW.md'yi execute etmeden önizler. Hangi agent'ların hangi sırayla çalışacağını gösterir.

## Kullanım

```
/dry-run
```

## Workflow

### Adım 1 — WORKFLOW.md Oku

`docs/WORKFLOW.md` oku.

### Adım 2 — Execution Plan Oluştur

Her faz ve task için:
- Hangi agent kullanılacak
- Hangi task'lar paralel çalışacak (parallel_group)
- Tahmini dosya değişiklikleri
- Director Gate'ler nerede tetiklenecek

### Adım 3 — Raporu Göster

```
## Dry Run Raporu — WORKFLOW.md

### Faz 1: Foundation (2 task, paralel)
  [parallel_group: foundation]
  ├── Task 1.1 → coder → EventBus.cs
  └── Task 1.2 → coder → UnityLogger.cs
  Gate: SCOPE_GATE (faz başında)

### Faz 2: Core Sistemler (3 task)
  ├── Task 2.1 → unity-coder → AudioService + tests
  ├── Task 2.2 → unity-coder → PlayerService + tests
  └── Task 2.3 → unity-coder → EnemyService + tests
  Gate: SCOPE_GATE + COMMIT_GATE

Toplam: [N] task, [M] agent spawn, [K] Director Gate

Çalıştırmak için: /orchestrate
```

Değişiklik YAPILMAZ — sadece plan gösterilir.
```

- [ ] **Step 5: Commit**

```bash
git add .claude/commands/game-idea.md .claude/commands/architect.md \
  .claude/commands/plan-workflow.md .claude/commands/dry-run.md
git commit -m "feat: add design phase commands (game-idea, architect, plan-workflow, dry-run)"
```

---

### Task 2: Setup & Scaffold Commands

**Files:**
- Create: `.claude/commands/setup-project.md`
- Create: `.claude/commands/new-module.md`

- [ ] **Step 1: setup-project.md yaz**

```markdown
# /setup-project

Projeyi detect eder, konfigüre eder ve klasör yapısını oluşturur.

## Kullanım

```
/setup-project
```

## Workflow

### Adım 1 — manifest.json Detect

`Packages/manifest.json` oku:

```bash
# VContainer mı Zenject mi?
DI="none"
grep -q "jp.hadashikick.vcontainer" Packages/manifest.json && DI="vcontainer"
grep -q "com.svermeulen.extenject" Packages/manifest.json && DI="zenject"

# UniTask var mı?
grep -q "com.cysharp.unitask" Packages/manifest.json && ASYNC="unitask"

# DOTween var mı?
grep -q "com.demigiant.dotween" Packages/manifest.json && HAS_DOTWEEN=true
```

### Adım 2 — Input Sistemi Detect

`ProjectSettings/ProjectVersion.txt` ve Input Manager'ı kontrol et:
- New Input System paketi var mı? → `"input": "new"`
- Yoksa → `"input": "legacy"`

### Adım 3 — Opsiyonel Feature Seçimi

Kullanıcıya sor (birer birer):
1. ECS/DOTS kullanacak mısın? (ecs: true/false)
2. Addressables kullanacak mısın? (addressables: true/false)
3. XR/VR geliştirme yapacak mısın? (xr: true/false)

### Adım 4 — project-config.json Güncelle

`.claude/project-config.json` güncelle:

```json
{
  "di": "[detect edilen]",
  "async": "unitask",
  "input": "[detect edilen]",
  "ecs": false,
  "addressables": false,
  "xr": false,
  "platform": "general",
  "unity_version": "6000"
}
```

### Adım 5 — Klasör Yapısını Oluştur

```
Assets/
├── _Framework/
│   ├── Events/
│   ├── Logging/
│   └── SaveLoad/
└── _GameFolders/
    └── Scripts/
        ├── Games/
        │   ├── Abstracts/
        │   └── Concretes/
        ├── Tests/
        │   ├── [Proje]EditModeTest/
        │   └── [Proje]PlayModeTest/
        └── Editors/
```

### Adım 6 — Özet Göster

```
✅ Kurulum tamamlandı

DI Container: vcontainer
Async: unitask
Input: new input system
ECS: false
Addressables: false
XR: false

Klasör yapısı oluşturuldu: Assets/_Framework/ + Assets/_GameFolders/

Sonraki adım: /game-idea veya /implement
```
```

- [ ] **Step 2: new-module.md yaz**

```markdown
# /new-module

Standart 5 dosya modül yapısını scaffold eder.

## Kullanım

```
/new-module <ModulAdı>
```

Örnek: `/new-module Audio`

## Workflow

### Adım 1 — ARCHITECTURE_GATE

Kullanıcıya önerilen modül yapısını göster:

```
Oluşturulacak dosyalar:

Abstracts/[ModulAdı]/
└── I[ModulAdı]Service.cs

Concretes/[ModulAdı]/
├── [ModulAdı]Service.cs
├── [ModulAdı]Configuration.cs
├── [ModulAdı]Installer.cs
├── [ModulAdı]Events.cs
└── [ModulAdı]Provider.cs   (MonoBehaviour gerekiyorsa)

Onaylıyor musun? (go / hayır)
```

### Adım 2 — Interface Oluştur

`Assets/_GameFolders/Scripts/Games/Abstracts/[ModulAdı]/I[ModulAdı]Service.cs`:

```csharp
namespace [Proje].[ModulAdı]
{
    public interface I[ModulAdı]Service
    {
        // TODO: Public API metodlarını buraya ekle
    }
}
```

### Adım 3 — Service Oluştur

`Assets/_GameFolders/Scripts/Games/Concretes/[ModulAdı]/[ModulAdı]Service.cs`:

```csharp
using Cysharp.Threading.Tasks;
using System.Threading;

namespace [Proje].[ModulAdı]
{
    public sealed class [ModulAdı]Service : I[ModulAdı]Service
    {
        private readonly IEventBus _eventBus;

        public [ModulAdı]Service(IEventBus eventBus)
        {
            _eventBus = eventBus;
        }
    }
}
```

### Adım 4 — Configuration Oluştur

`Assets/_GameFolders/Scripts/Games/Concretes/[ModulAdı]/[ModulAdı]Configuration.cs`:

```csharp
using UnityEngine;

namespace [Proje].[ModulAdı]
{
    [CreateAssetMenu(menuName = "Config/[ModulAdı]")]
    public sealed class [ModulAdı]Configuration : ScriptableObject
    {
        // TODO: Konfigürasyon alanlarını ekle
    }
}
```

### Adım 5 — Installer Oluştur (DI'a göre)

**VContainer:**
```csharp
using VContainer;
using VContainer.Unity;

namespace [Proje].[ModulAdı]
{
    public static class [ModulAdı]Installer
    {
        public static void Install(IContainerBuilder builder,
            [ModulAdı]Configuration config)
        {
            builder.RegisterInstance(config);
            builder.Register<[ModulAdı]Service>(Lifetime.Singleton)
                   .As<I[ModulAdı]Service>();
        }
    }
}
```

**Zenject:**
```csharp
using Zenject;

namespace [Proje].[ModulAdı]
{
    public class [ModulAdı]Installer : MonoInstaller
    {
        [[SerializeField]] private [ModulAdı]Configuration _config;

        public override void InstallBindings()
        {
            Container.BindInstance(_config);
            Container.Bind<I[ModulAdı]Service>()
                     .To<[ModulAdı]Service>().AsSingle();
        }
    }
}
```

### Adım 6 — Events Oluştur

`Assets/_GameFolders/Scripts/Games/Concretes/[ModulAdı]/[ModulAdı]Events.cs`:

```csharp
namespace [Proje].[ModulAdı]
{
    public readonly struct [ModulAdı]StartedEvent : IEvent
    {
        // TODO: Event alanlarını ekle
    }
}
```

### Adım 7 — Commit

```bash
git add Assets/_GameFolders/Scripts/Games/
git commit -m "feat([moduladı]): scaffold [ModulAdı] module (5 files)"
```
```

- [ ] **Step 3: Commit**

```bash
git add .claude/commands/setup-project.md .claude/commands/new-module.md
git commit -m "feat: add setup-project and new-module commands"
```

---

### Task 3: Implementasyon Pipeline Commands

**Files:**
- Create: `.claude/commands/implement.md`
- Create: `.claude/commands/fix.md`
- Create: `.claude/commands/fix-lite.md`
- Create: `.claude/commands/fix-deep.md`
- Create: `.claude/commands/orchestrate.md`
- Create: `.claude/commands/continue.md`

- [ ] **Step 1: implement.md yaz**

```markdown
# /implement

TDD pipeline: test → coder → verifier → reviewer → committer.

## Kullanım

```
/implement <görev açıklaması>
```

## Workflow

### Adım 0 — Hazırlık

1. `production/review-mode.txt` oku
2. `project-config.json` oku (DI, async, input tipi)
3. Complexity hesapla (0.0–1.0)
4. Model tier belirle

### ▶ SCOPE_GATE

```
Görev: [görev açıklaması]
Complexity: [0.0–1.0]
Etkilenecek dosyalar: [tahmin]
Review mode: [solo/lean/full]

Devam etmek için "go" yaz.
```

`go` alınınca `.claude/state/gate-cleared` oluştur.

### Adım 1 — tester (izole subagent)

`tester` agent spawn et:
- Test dosyasını yaz
- Testler BAŞARISIZ olmalı (implementasyon yok)
- Test tipi: EditMode / PlayMode (complexity'e göre)

### Adım 2 — unity-coder veya coder

- Complexity ≥ 0.4 veya Unity API gerekiyorsa → `unity-coder`
- Pure C# → `coder`
- Testleri geçirecek minimal implementasyon yaz

### Adım 3 — unity-verifier

`unity-verifier` spawn et:
- Compile kontrolü
- Test çalıştır
- Başarısız → unity-coder'a gönder (max 2 pass)

### Adım 4 — Reviewer

- review-mode == `solo` → bu adımı atla
- review-mode == `lean` veya `full` → `unity-reviewer` spawn et

**▶ QUALITY_GATE** (CHANGES NEEDED ise):
```
Reviewer CHANGES NEEDED döndü.
fix → düzeltmeye devam et
skip → review'u geç
stop → işlemi durdur
```

### Adım 5 — unity-developer (full mode)

- review-mode == `full` → `unity-developer` spawn et
- Aksi halde atla

### Adım 6 — silent-failure-hunter

`silent-failure-hunter` spawn et:
- Exception yutma, async void, event leak kontrol

### Adım 7 — committer

**▶ COMMIT_GATE**:
```
Staged dosyalar:
- [dosya listesi]

Commit atılacak. Onaylıyor musun? (go / hayır)
```

`go` → `committer` agent commit atar.

### Temizlik

`.claude/state/gate-cleared` sil.

## Output

```
✅ IMPLEMENT COMPLETE
   Tests: [N] passed
   Files: [M] files changed
   Commit: [commit hash]
```
```

- [ ] **Step 2: fix.md yaz**

```markdown
# /fix

Bug fix pipeline: scout → fixer → test → reviewer → committer.

## Kullanım

```
/fix <hata açıklaması veya stack trace>
```

## Workflow

### Adım 0 — Complexity Hesapla

- Stack trace var mı? → root cause açık mı?
- Kaç dosya etkileniyor?
- Complexity < 0.2 → `/fix-lite` öneri
- Complexity belirsiz → `/fix-deep` öneri

### ▶ SCOPE_GATE

```
Bug: [açıklama]
Tahmini etkilenen dosyalar: [liste]
Complexity: [0.0–1.0]

Devam için "go" yaz.
```

### Adım 1 — unity-scout + unity-fixer (paralel, complexity ≥ 0.4)

- `unity-scout`: bağımlılık haritası, etkilenen dosyalar
- `unity-fixer`: root cause analizi

**▶ BREAKING_GATE** (3+ dosya etkileniyorsa):
```
Bu fix [N] dosyayı etkiliyor. Geniş kapsamlı değişiklik.
Devam için "go" yaz.
```

### Adım 2 — tester

`tester` agent: regression test yaz (bug'ı reproduce eden test).

### Adım 3 — unity-coder veya unity-fixer

Fix uygula. Regression test geçmeli.

### Adım 4 — unity-verifier

Compile + tüm testler çalıştır.

### Adım 5 — Reviewer (lean/full modda)

`unity-reviewer` spawn et.

**▶ QUALITY_GATE** (CHANGES NEEDED ise).

### Adım 6 — committer

**▶ COMMIT_GATE** → `committer` commit atar.
```

- [ ] **Step 3: fix-lite.md yaz**

```markdown
# /fix-lite

Hızlı yol: NullRef, typo, obvious tek satır fix.

## Kullanım

```
/fix-lite <kısa hata açıklaması>
```

## Uygun Durumlar

- NullReferenceException (bariz sebep)
- Yazım hatası (typo)
- Off-by-one
- Yanlış operator (= yerine ==)

## Uygun Olmayan Durumlar

Root cause belirsizse → `/fix` veya `/fix-deep` kullan.

## Workflow

### Adım 1 — unity-fixer-lite

`unity-fixer-lite` spawn et:
- İlgili dosyayı oku (gateguard için)
- Tek satır fix uygula

### Adım 2 — unity-verifier

Compile + test kontrolü.

### Adım 3 — committer (COMMIT_GATE olmadan)

Otomatik commit: `fix([scope]): [kısa açıklama]`

## Output

```
✅ FIX-LITE COMPLETE
   [dosya:satır] düzeltildi
   Commit: [hash]
```
```

- [ ] **Step 4: fix-deep.md yaz**

```markdown
# /fix-deep

Evidence-first fix. Root cause kanıtlanmadan fix yapılmaz.

## Kullanım

```
/fix-deep <belirsiz veya intermittent hata açıklaması>
```

## Ne Zaman Kullan

- Root cause belirsiz
- Intermittent (arada bir oluyor)
- Stack trace yetersiz
- "Bazen çalışıyor" sorunları

## Workflow

### Adım 1 — Log Intake

Mevcut log'ları ve hata mesajlarını topla:
- Stack trace
- Unity Console çıktısı
- Reproduce adımları

### Adım 2 — Hipotez Üret

`unity-scout` + `unity-fixer` ile minimum 2 hipotez:
```
Hipotez 1: [sebep] — Kanıt: [ne görmek bekliyoruz]
Hipotez 2: [sebep] — Kanıt: [ne görmek bekliyoruz]
```

### Adım 3 — Debug Injection

Kanıt toplamak için geçici debug log ekle:
```csharp
Debug.Log($"[DEBUG] {nameof(MyMethod)}: value={value}, state={_state}");
```

Kullanıcıya: "Oyunu çalıştır, şu senaryoyu test et, logu buraya yapıştır."

### Adım 4 — Evidence Gate

Log alınınca hipotezleri değerlendir:
- Hipotez doğrulandı mı? → Fix yap
- Doğrulanamadı → Yeni hipotez

**Root cause kanıtlanmadan fix yapılmaz.**

### Adım 5 — Fix (Kanıtlanmış Root Cause ile)

`/fix` pipeline ile devam et (test → coder → verify → review → commit).

### Adım 6 — Debug Kodunu Temizle

```bash
git diff -- "*.cs" | grep "DEBUG"
```

Debug log satırlarını kaldır, commit at.
```

- [ ] **Step 5: orchestrate.md yaz**

```markdown
# /orchestrate

WORKFLOW.md'yi faz faz execute eder. Tam otomatik pipeline.

## Kullanım

```
/orchestrate
```

## Ön Koşul

`docs/WORKFLOW.md` mevcut olmalı. Yoksa `/plan-workflow` çalıştır.

## Workflow

### Adım 0 — Başlatma

1. `docs/WORKFLOW.md` oku
2. `Assets/_Framework/` ve `Assets/_GameFolders/` tara — mevcut kodu tespit et
3. Pre-Scan raporu göster (hangi kodlar zaten var)

### ▶ SCOPE_GATE

```
WORKFLOW.md yüklendi.
Fazlar: [N]
Toplam task: [M]

Pre-Scan: [zaten var olan sistemler]

Başlamak için "go" yaz.
```

### Adım 1 — Faz Döngüsü

Her faz için:

```
=== FAZ [N]: [Faz Adı] ===
```

**Paralel task tespiti:**
Aynı `parallel_group`'taki task'lar → aynı anda spawn et
Çakışan output dosyaları → sıralı çalıştır

**Task execution:**
→ tester → coder/unity-coder → verifier → reviewer → committer

**Faz sonu otomatik kalite:**
→ `/ralph` (verify-fix loop)
→ `silent-failure-hunter`
→ `/validate`

**Faz Kapısı (manual):**
```
Faz [N] tamamlandı.
Sonraki faza geç? (yes / no / stop)
```

### Adım 2 — Tamamlanma

`docs/EVENTS.jsonl`'e append et:
```json
{"event":"ORCHESTRATION_COMPLETED","timestamp":"...","phases":[N],"tasks":[M]}
```

`.claude/state/gate-cleared` sil.

```
✅ ORCHESTRATION COMPLETE
   Fazlar: [N]
   Task'lar: [M]
   Commit'ler: [K]
```
```

- [ ] **Step 6: continue.md yaz**

```markdown
# /continue

Kesilen /orchestrate'i kaldığı yerden devam ettirir.

## Kullanım

```
/continue
```

## Workflow

### Adım 1 — State Oku

`.claude/state/session.json` oku:
- Hangi fazda kaldık?
- Hangi task tamamlandı?
- Hangi dosyalar değişti?

### Adım 2 — Checkpoint Oku (varsa)

`.claude/state/checkpoint.md` oku — bağlam topla.

### Adım 3 — Devam Et

```
Son durum: Faz [N], Task [M] tamamlanmış.
[Task M+1]'den devam ediliyor...
```

`/orchestrate`'in Adım 1 Faz döngüsüne kalan task'tan gir.

## Session State Format

`.claude/state/session.json`:
```json
{
  "current_phase": 2,
  "current_task": "Task 2.3",
  "completed_tasks": ["Task 1.1", "Task 1.2", "Task 2.1", "Task 2.2"],
  "modified_files": ["Assets/_GameFolders/Scripts/Games/Concretes/Audio/AudioService.cs"]
}
```
```

- [ ] **Step 7: Commit**

```bash
git add .claude/commands/implement.md .claude/commands/fix.md .claude/commands/fix-lite.md \
  .claude/commands/fix-deep.md .claude/commands/orchestrate.md .claude/commands/continue.md
git commit -m "feat: add implementation pipeline commands (implement, fix, fix-lite, fix-deep, orchestrate, continue)"
```

---

### Task 4: Kalite & Dokümantasyon & Session Commands

**Files:**
- Create: `.claude/commands/qa.md`
- Create: `.claude/commands/ralph.md`
- Create: `.claude/commands/validate.md`
- Create: `.claude/commands/review-code.md`
- Create: `.claude/commands/performance-audit.md`
- Create: `.claude/commands/learn.md`
- Create: `.claude/commands/catch-up.md`
- Create: `.claude/commands/adr.md`
- Create: `.claude/commands/smart-commit.md`
- Create: `.claude/commands/context-prime.md`
- Create: `.claude/commands/checkpoint.md`
- Create: `.claude/commands/search.md`
- Create: `.claude/commands/discover.md`

- [ ] **Step 1: qa.md yaz**

```markdown
# /qa

Tam kalite pipeline: ralph → silent-failure-hunt → validate.

## Kullanım

```
/qa
```

## Workflow

### Adım 1 — /ralph

Verify-fix loop çalıştır (max 10 iterasyon). Yeşil olana kadar dur.

### Adım 2 — silent-failure-hunter

`silent-failure-hunter` spawn et. Exception yutma, async void, event leak tara.

### Adım 3 — /validate

Faz exit criteria kontrolü yap.

## Output

```
✅ QA PASSED
   Ralph: [N] iterasyon, yeşil
   Silent Failures: temiz
   Validation: geçti

❌ QA FAILED
   [Nerede takıldı ve neden]
```
```

- [ ] **Step 2: ralph.md yaz**

```markdown
# /ralph

Yeşil olana kadar verify-fix loop. Max 10 iterasyon.

## Kullanım

```
/ralph
```

## Workflow

```
iterasyon = 0

LOOP:
  iterasyon += 1
  unity-verifier → compile + test
  
  PASSED → "Yeşil! [iterasyon] iterasyonda geçti." → DUR
  
  FAILED:
    iterasyon >= 10 → "STUCK: 10 iterasyon sonra hala kırmızı." → DUR
    unity-coder → hatayı düzelt
    LOOP'a dön
```

## Sıkışma Çıkışı

10 iterasyon sonra geçmiyorsa:
```
❌ STUCK after 10 iterations
Son hata: [hata mesajı]
Öneri: /fix-deep ile root cause analizi yap
```
```

- [ ] **Step 3: validate.md yaz**

```markdown
# /validate

Tamamlanan faz için exit criteria kontrolü.

## Kullanım

```
/validate
```

## Kontrol Listesi

- [ ] Compile: hata yok
- [ ] EditMode testler: hepsi geçiyor
- [ ] PlayMode testler (varsa): hepsi geçiyor
- [ ] Console: error ve exception yok (warning kabul edilebilir)
- [ ] Serialization riski: FormerlySerializedAs kontrol edildi
- [ ] Silent failures: temiz
- [ ] Mimari kurallar: ihlal yok (unity-linter çalıştır)

## Output

```
## Validation Raporu

Compile: ✅ OK
EditMode Tests: ✅ [N] passed
PlayMode Tests: ✅ [N] passed
Console Errors: ✅ Temiz
Serialization: ✅ Risk yok
Silent Failures: ✅ Temiz

Sonuç: PASS / PARTIAL / FAIL
```

PARTIAL veya FAIL → hangi madde takıldığını belirt.
```

- [ ] **Step 4: review-code.md yaz**

```markdown
# /review-code

Belirli dosyaları derinlemesine review eder.

## Kullanım

```
/review-code <dosya yolu veya glob pattern>
```

Örnekler:
```
/review-code Assets/_GameFolders/Scripts/Games/Concretes/Audio/AudioService.cs
/review-code Assets/_GameFolders/Scripts/Games/Concretes/Audio/
```

## Workflow

### Adım 1 — Dosyaları Oku

Belirtilen dosyaları Read tool ile oku (gateguard bypass için zorunlu).

### Adım 2 — unity-reviewer

`unity-reviewer` spawn et. Tam review kontrol listesi ile.

### Adım 3 — Raporu Göster

Reviewer output'unu göster:
- Must Fix (blocker)
- Should Improve (öneri)
- Optional (nice-to-have)
- Unity Notes (Unity-spesifik)

### Adım 4 — Kullanıcı Kararı

Must Fix varsa: "Düzeltmemi ister misin? (yes/no)"
```

- [ ] **Step 5: performance-audit.md yaz**

```markdown
# /performance-audit

Hot path allocation ve draw call denetimi.

## Kullanım

```
/performance-audit [opsiyonel: klasör veya dosya]
```

## Workflow

### Adım 1 — Tarama Kapsamı

Belirtilmişse o dosya/klasör, yoksa tüm `Concretes/` klasörü.

### Adım 2 — unity-optimizer

`unity-optimizer` spawn et:
- Update/FixedUpdate metotlarını tara
- Allocation pattern'leri bul
- LINQ kullanımı
- GetComponent/Camera.main/Find* hot path'te mi?

### Adım 3 — unity-developer (full modda)

review-mode == `full` → `unity-developer` ek perspektif sunar.

### Adım 4 — Rapor

```
## Performans Denetim Raporu

### Kritik (hemen düzelt)
- [dosya:satır]: [sorun] → [öneri]

### İzle
- [dosya:satır]: [sorun]

### Temiz
- [N] dosya tarandı, sorun yok
```
```

- [ ] **Step 6: learn.md yaz**

```markdown
# /learn

Proje-spesifik pattern'leri keşfeder ve skills/learned/ altına kaydeder.

## Kullanım

```
/learn [opsiyonel: konu]
```

## Ne Zaman Kullan

- Bir pattern projede 3+ kez tekrarlandığında
- Bir hata birden fazla kez yapıldığında
- Projeye özgü bir convention ortaya çıktığında

## Workflow

### Adım 1 — Pattern Tespit

Şunlardan birini sor veya gözlemle:
- "Bu pattern nerede daha kullanılmış?"
- "Bu hata başka yerde de var mı?"

`unity-scout` ile codebase'de tara.

### Adım 2 — Skill Oluştur

`skills/learned/<pattern-adı>.md`:

```markdown
---
name: [pattern-adı]
description: [ne zaman kullan — tek cümle]
project-specific: true
---

# [Pattern Adı]

## Ne Zaman

[Bu pattern ne zaman uygulanır]

## Nasıl

[Kod örneği ile açıklama]

## Dikkat

[Kaçınılacaklar]
```

### Adım 3 — auto-loaded-skills.md Güncelle

`.claude/docs/auto-loaded-skills.md`'e ekle:
```
@.claude/skills/learned/[pattern-adı].md
```

### Adım 4 — Commit

```bash
git add .claude/skills/learned/ .claude/docs/auto-loaded-skills.md
git commit -m "docs: learn [pattern-adı] pattern"
```
```

- [ ] **Step 7: catch-up.md yaz**

```markdown
# /catch-up

İnsan-okunabilir codebase kılavuzu üretir.

## Kullanım

```
/catch-up
```

## Workflow

### Adım 1 — Codebase Tara

`unity-scout` ile:
- Tüm Interface'leri listele
- Tüm Service'leri listele
- Bağımlılık grafiğini çıkar

### Adım 2 — CATCH_UP.md Üret

`docs/CATCH_UP.md`:

```markdown
# Codebase Kılavuzu — [Tarih]

## Sistemler

| Sistem | Interface | Sorumluluk |
|---|---|---|
| Audio | IAudioService | Ses çalma, durdurma, volume |
| Player | IPlayerService | Hareket, input, state |

## Bağımlılık Grafiği
[Metin diagram]

## DI Wiring
[AppScope / GameScope'ta ne register edilmiş]

## Önemli Pattern'ler
[Projede kullanılan kritik pattern'ler]
```

### Adım 3 — Commit

```bash
git add docs/CATCH_UP.md
git commit -m "docs: update CATCH_UP.md codebase guide"
```
```

- [ ] **Step 8: adr.md yaz**

```markdown
# /adr

Architecture Decision Record oluşturur.

## Kullanım

```
/adr <karar başlığı>
```

Örnek: `/adr VContainer yerine Zenject kullanma kararı`

## Workflow

### Adım 1 — ADR Numarası Belirle

`docs/decisions/` klasörünü tara, son numarayı bul, +1 ekle.

### Adım 2 — ADR Dosyası Oluştur

`docs/decisions/[NNN]-[slug].md`:

```markdown
# [NNN] — [Başlık]

**Tarih:** [YYYY-MM-DD]
**Durum:** Kabul Edildi

## Bağlam

[Neden bu karar alındı? Hangi sorunu çözüyor?]

## Karar

[Ne yapılacağına karar verildi]

## Sonuçlar

**Olumlu:**
- [avantajlar]

**Olumsuz / Trade-off:**
- [dezavantajlar]

## Alternatifler

[Değerlendirilen ama seçilmeyen seçenekler]
```

### Adım 3 — Commit

```bash
git add docs/decisions/
git commit -m "docs: add ADR [NNN] - [slug]"
```
```

- [ ] **Step 9: smart-commit.md yaz**

```markdown
# /smart-commit

Dirty working tree'yi mantıksal semantic commit gruplarına böler.

## Kullanım

```
/smart-commit
```

## Workflow

### Adım 1 — Değişiklikleri Tara

```bash
git diff --name-only
git status --short
```

### Adım 2 — Grupla

Değişiklikleri mantıksal gruplara ayır:
- Aynı modüle ait dosyalar → tek commit
- Test dosyaları → ayrı commit
- Dokümantasyon → ayrı commit
- Config değişiklikleri → ayrı commit

### Adım 3 — Kullanıcıya Göster

```
Önerilen commit grupları:

Grup 1: feat(audio) — AudioService, AudioInstaller, IAudioService
Grup 2: test(audio) — AudioServiceTests
Grup 3: docs — GDD.md güncellemesi

Onaylıyor musun? (go / grupları düzenle)
```

### Adım 4 — Commit At

Her grup için ayrı commit:
```bash
git add [grup dosyaları]
git commit -m "[type]([scope]): [description]"
```
```

- [ ] **Step 10: context-prime.md yaz**

```markdown
# /context-prime

Session başında Claude'u proje bağlamına sokar.

## Kullanım

```
/context-prime
```

## Workflow

### Adım 1 — Temel Dosyaları Oku

- `project-config.json` → DI, async, input, feature bayrakları
- `production/review-mode.txt` → review modu
- `docs/TDD.md` (varsa) → teknik tasarım özeti
- `.claude/state/checkpoint.md` (varsa) → son session özeti
- `docs/WORKFLOW.md` (varsa) → hangi fazda/task'ta?

### Adım 2 — Bağlam Özeti

```
## Proje Bağlamı

**DI:** vcontainer | **Async:** UniTask | **Input:** New Input System
**ECS:** false | **Addressables:** false | **XR:** false
**Review Mode:** lean

**TDD Durumu:** [özet]
**WORKFLOW Durumu:** Faz [N], Task [M]
**Son Checkpoint:** [tarih ve özet]

Hazırım. Ne yapmak istersin?
```
```

- [ ] **Step 11: checkpoint.md yaz**

```markdown
# /checkpoint

Konuşma özetini state'e kaydeder. Uzun session'larda context kaybına karşı.

## Kullanım

```
/checkpoint
```

## Workflow

### Adım 1 — Özet Oluştur

Bu session'da yapılanları özetle:
- Hangi task'lar tamamlandı
- Hangi dosyalar oluşturuldu/değiştirildi
- Hangi kararlar alındı
- Nerede kaldık

### Adım 2 — Kaydet

`.claude/state/checkpoint.md`:

```markdown
# Checkpoint — [Tarih Saat]

## Bu Session'da Yapılanlar
- [tamamlanan task'lar]

## Değiştirilen Dosyalar
- [dosya listesi]

## Alınan Kararlar
- [mimari kararlar, trade-off'lar]

## Devam Noktası
[Bir sonraki session nereye bağlanmalı]
```

### Adım 3 — Onay

```
✅ Checkpoint kaydedildi: .claude/state/checkpoint.md
Yeni session'da /context-prime ile yüklenebilir.
```
```

- [ ] **Step 12: search.md yaz**

```markdown
# /search

Codebase araştırması ve action router.

## Kullanım

```
/search <sorgu>
```

Örnekler:
```
/search IAudioService nerede implement edilmiş?
/search singleton pattern var mı?
/search PlayerService'i kim kullanıyor?
```

## Workflow

### Adım 1 — unity-scout

`unity-scout` spawn et:
- Grep ve Glob ile soru ile ilgili kod bul
- Bağımlılık haritası çıkar
- Bulgular raporla

### Adım 2 — unity-reviewer (analiz gerekiyorsa)

Bulgu review gerektiriyorsa (mimari ihlal vs.) → `unity-reviewer` ekle.

### Adım 3 — Action Router

Sonuca göre öneri:
```
## Arama Sonucu

[Bulgular]

## Önerilen Aksiyon
- Sorun var → /fix ile düzelt
- Refactor gerekiyor → /implement ile yeni yaklaşım
- Sadece bilgi → bilgi verildi, aksiyon gerekmez
```
```

- [ ] **Step 13: discover.md yaz**

```markdown
# /discover

Packages/manifest.json tarar, yüklü paketler için skill taslakları üretir.

## Kullanım

```
/discover [--dry-run | --write]
```

- `--dry-run` → Ne üretileceğini gösterir, dosya yazmaz
- `--write` → Skill dosyalarını yazar
- Argüman yok → `--dry-run` gibi davranır, onay sorar

## Workflow

### Adım 1 — manifest.json Oku

`Packages/manifest.json` oku. Tüm paketleri listele.

### Adım 2 — package-analyzer Spawn Et

`package-analyzer`:
- Bilinen paketleri tanımla (VContainer, UniTask, DOTween...)
- Singleton kullananları tespit et
- Adapter ihtiyacı olanları işaretle

### Adım 3 — Skill Taslakları Üret

Her bilinmeyen paket için `skills/third-party/[paket-adı]/SKILL.md` taslağı:

```markdown
---
name: [paket-adı]
description: [paket amacı]
discovered: true
---

# [Paket Adı]

## Kurulum

[manifest.json'daki paket ID]

## Temel Kullanım

[TODO: Temel pattern'leri doldur]

## DI Uyumu

[Singleton mi? Adapter gerekiyor mu?]
```

### Adım 4 — Kullanıcı Onayı

```
Bulunan paketler: [N]
Yeni skill taslağı: [M]
Adapter önerisi: [K paket]

Yazılsın mı? (yes/no)
```

### Adım 5 — Commit (--write veya onay verilince)

```bash
git add .claude/skills/third-party/
git commit -m "feat: discover and scaffold [N] package skills"
```
```

- [ ] **Step 14: Verify — Tüm command dosyaları**

```powershell
$commands = @(
    "game-idea","architect","plan-workflow","dry-run",
    "setup-project","new-module","implement","fix","fix-lite",
    "fix-deep","orchestrate","continue","qa","ralph","validate",
    "review-code","performance-audit","learn","catch-up","adr",
    "smart-commit","context-prime","checkpoint","search","discover"
)
$commands | ForEach-Object {
    $exists = Test-Path ".claude/commands/$_.md"
    Write-Host "$_.md — $(if($exists){'OK'}else{'EKSIK'})"
}
Write-Host "Toplam: $($commands.Count) command"
```

Beklenen: 25 command, hepsi OK.

- [ ] **Step 15: Commit**

```bash
git add .claude/commands/qa.md .claude/commands/ralph.md .claude/commands/validate.md \
  .claude/commands/review-code.md .claude/commands/performance-audit.md \
  .claude/commands/learn.md .claude/commands/catch-up.md .claude/commands/adr.md \
  .claude/commands/smart-commit.md .claude/commands/context-prime.md \
  .claude/commands/checkpoint.md .claude/commands/search.md .claude/commands/discover.md
git commit -m "feat: add quality, docs and session commands - all 25 commands complete"
```

---

**Phase 6 tamamlandı. Tüm planlar yazıldı.**

Planların özeti:
- Phase 1: Foundation (CLAUDE.md, settings.json, project-config.json, docs)
- Phase 2: Rules (14 kural dosyası)
- Phase 3: Hooks (15 shell script)
- Phase 4: Agents (22 agent tanımı)
- Phase 5: Skills (core + systems + third-party)
- Phase 6: Commands (25 slash command)
