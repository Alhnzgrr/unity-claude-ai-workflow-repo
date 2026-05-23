# Unity Claude AI Workflow — Phase 5: Skills

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** core/, systems/ ve third-party/ skill dosyalarını oluştur.

**Architecture:** Skill'ler read-only referans dosyaları. Agent'lar karar verirken bunları okur. core/ her zaman yüklü, systems/ ihtiyaçta, third-party/ manifest.json detect'e göre auto-yüklenir.

**Tech Stack:** Markdown

---

## Dosya Haritası

```
.claude/skills/
├── core/
│   ├── model-routing.md
│   ├── unity-instincts/SKILL.md
│   ├── unity-mcp-patterns/SKILL.md
│   └── context-management/SKILL.md
├── systems/
│   ├── audio/SKILL.md
│   ├── physics/SKILL.md
│   ├── animation/SKILL.md
│   ├── ui-toolkit/SKILL.md
│   ├── urp-pipeline/SKILL.md
│   ├── cinemachine/SKILL.md
│   ├── shader-graph/SKILL.md
│   ├── addressables/SKILL.md
│   └── vr/SKILL.md
└── third-party/
    ├── vcontainer/SKILL.md
    ├── zenject/SKILL.md
    ├── unitask/SKILL.md
    ├── dotween/SKILL.md
    └── textmeshpro/SKILL.md
```

---

### Task 1: Core Skills

**Files:**
- Create: `.claude/skills/core/model-routing.md`
- Create: `.claude/skills/core/unity-instincts/SKILL.md`
- Create: `.claude/skills/core/unity-mcp-patterns/SKILL.md`
- Create: `.claude/skills/core/context-management/SKILL.md`

- [ ] **Step 1: model-routing.md yaz**

```markdown
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
```

- [ ] **Step 2: unity-instincts/SKILL.md yaz**

```markdown
---
name: unity-instincts
description: Unity geliştirmede hızlı, güvenilir kararlar için proje genelinde geçerli instinct'ler.
---

# Unity Instincts

Sık tekrarlanan durumlar için önceden belirlenmiş kararlar. Her seferinde analiz yapmak yerine bu instinct'leri uygula.

## Genel İnstinct'ler

**Yeni bir sistem gerekiyor mu?**
→ Önce Interface yaz, sonra implementasyon. Hiçbir zaman ters sırayla.

**Servisler arası iletişim mi?**
→ IEventBus. Doğrudan referans değil.

**Async bir işlem mi?**
→ UniTask + CancellationToken. Her zaman. İstisna yok.

**MonoBehaviour'a bağımlılık mı?**
→ [Inject] void Construct(...). Constructor değil.

**Yeni GameObject gerekiyor mu?**
→ Prefab'dan Instantiate. new GameObject() değil.

**Coroutine → UniTask geçişi mi?**
→ yield return new WaitForSeconds(t) → await UniTask.Delay(ms, ct)
→ yield return null → await UniTask.Yield()
→ yield return new WaitForEndOfFrame() → await UniTask.WaitForEndOfFrame()

**Event subscribe/unsubscribe mi?**
→ OnEnable'da subscribe, OnDisable'da unsubscribe. Her zaman eşleştirilmiş.

**Performans sorusu mu?**
→ Önce profiler. Varsayım yapma. Ölçümsüz optimizasyon yapma.

**Test yazıyor musun?**
→ Unity API gerektirmiyor → EditMode. Gerektiriyor → PlayMode. Scene lazım → PlayMode Scene.

**Yeni dosya mı oluşturacaksın?**
→ Önce interface, sonra concrete. Klasöre bak: Abstracts/ ve Concretes/ ayrı.
```

- [ ] **Step 3: unity-mcp-patterns/SKILL.md yaz**

```markdown
---
name: unity-mcp-patterns
description: Unity Editor MCP entegrasyonu için kullanım pattern'leri ve fallback davranışları.
---

# Unity MCP Patterns

## MCP Varlık Kontrolü

Session başında MCP bağlantısı kontrol edilir. Davranış buna göre değişir:

```
MCP bağlı mı?
├── Evet → Unity Editor araçlarını kullan
└── Hayır → Manuel talimatlar ver, kullanıcıdan onay bekle
```

## MCP ile Yapılabilecekler

- Sahne hiyerarşisi okuma/yazma
- GameObject oluşturma, component ekleme
- ScriptableObject asset oluşturma
- Prefab referansları bağlama
- Compile tetikleme
- Test runner çalıştırma
- Console log okuma

## MCP ile YAPILMAYACAKLAR

- .unity dosyasını direkt Edit/Write ile değiştirme → `block-scene-edit.sh` engeller
- .prefab dosyasını direkt Edit/Write ile değiştirme → engeller
- .asset dosyasını direkt Edit/Write ile değiştirme → engeller

## MCP Fallback Talimat Formatı

MCP yoksa kullanıcıya net adımlar ver:

```
📋 Unity Editor'da yapılacaklar:

1. Hierarchy'de [Setup] container'ını seç
2. Add Component → LifetimeScope ekle
3. LifetimeScope'un Parent field'ına AppScope'u sürükle
4. Inspector'da GameInstaller alanına GameInstaller asset'ini sürükle

Tamamlayınca "hazır" yaz.
```

## Sahne Manipülasyon Sırası

1. Container'ları oluştur ([Setup], [Services], [UI]...)
2. Core objeler: EventSystem → [UI], MainCamera → [Environment]
3. LifetimeScope ve Installer'lar → [Setup]
4. Provider MonoBehaviour'lar → [Services]
5. Prefab instance'ları → ilgili container
```

- [ ] **Step 4: context-management/SKILL.md yaz**

```markdown
---
name: context-management
description: Review mode, context compaction ve checkpoint kullanım rehberi.
---

# Context Management

## Review Mode

`production/review-mode.txt` okunur, pipeline derinliği belirlenir:

| Mode | Test | Review | unity-developer | Kullanım |
|---|---|---|---|---|
| `solo` | ❌ | ❌ | ❌ | Jam, prototip, hızlı deney |
| `lean` | ✅ | ✅ | Opsiyonel | Normal geliştirme (default) |
| `full` | ✅ | ✅ | Her zaman ✅ | Takım, öğrenme, kritik feature |

Review mode okuma:
```bash
cat production/review-mode.txt
```

## Checkpoint Kullanımı

Uzun session'larda context kaybolmadan devam etmek için:

```
/checkpoint
```

→ `.claude/state/checkpoint.md` oluşturur. Yeni session'da:

```
/context-prime
```

→ checkpoint'i yükler, projeyi tanıtır.

## Context Tasarrufu

- Uzun session'larda gereksiz dosya okumaktan kaçın
- Bir session'da okunan dosyaları tekrar okuma
- Skills yalnızca ilgili göreve yükle
- `unity-scout` araştırmayı halleder, ana agent context'ini korur

## Session State Dosyaları

```
.claude/state/
├── session.json      ← aktif branch, faz, değişen dosyalar
├── checkpoint.md     ← /checkpoint ile oluşur
├── gate-cleared      ← Director Gate onayı sonrası oluşur, pipeline biter bitmez silinir
└── read-files.log    ← gateguard için okunan dosyalar listesi
```
```

- [ ] **Step 5: Commit**

```bash
git add .claude/skills/core/
git commit -m "feat: add core skills (model-routing, instincts, mcp-patterns, context-management)"
```

---

### Task 2: Systems Skills — Bölüm 1

**Files:**
- Create: `.claude/skills/systems/audio/SKILL.md`
- Create: `.claude/skills/systems/physics/SKILL.md`
- Create: `.claude/skills/systems/animation/SKILL.md`
- Create: `.claude/skills/systems/ui-toolkit/SKILL.md`
- Create: `.claude/skills/systems/urp-pipeline/SKILL.md`

- [ ] **Step 1: audio/SKILL.md yaz**

```markdown
---
name: audio
description: Unity Audio sistemi pattern'leri. AudioSource, AudioMixer, modül yapısı.
---

# Audio System

## Modül Yapısı

```
Abstracts/Audio/
└── IAudioService.cs

Concretes/Audio/
├── AudioService.cs          ← sealed, UniTask async
├── AudioConfiguration.cs    ← ScriptableObject (volume, clips dict)
├── AudioInstaller.cs        ← VContainer/Zenject register
├── AudioEvents.cs           ← AudioStartedEvent, AudioStoppedEvent
└── AudioProvider.cs         ← MonoBehaviour, AudioSource wrapper
```

## IAudioService

```csharp
public interface IAudioService
{
    UniTask PlayAsync(string clipKey, CancellationToken ct);
    void Stop(string clipKey);
    void SetVolume(float volume);
}
```

## AudioConfiguration

```csharp
[CreateAssetMenu(menuName = "Config/Audio")]
public sealed class AudioConfiguration : ScriptableObject
{
    [SerializeField] private AudioClip[] _clips;
    [SerializeField] private float _masterVolume = 1f;

    private Dictionary<string, AudioClip> _clipMap;

    public float MasterVolume => _masterVolume;
    public AudioClip GetClip(string key) =>
        _clipMap.TryGetValue(key, out var clip) ? clip : null;

    void OnEnable()
    {
        _clipMap = _clips.ToDictionary(c => c.name, c => c);
    }
}
```

## AudioMixer Kullanımı

Her AudioSource bir AudioMixerGroup'a bağlanır:
- Master → Music, SFX, UI alt grupları
- Mixer parametreleri exposed → runtime volume control

## Pool Kullanımı

Çok sayıda kısa ses efekti → AudioSource pool:
```csharp
private IObjectPool<AudioSource> _sourcePool;
```
```

- [ ] **Step 2: physics/SKILL.md yaz**

```markdown
---
name: physics
description: Unity Physics ve Physics2D pattern'leri. Rigidbody, Collider, Layer yönetimi.
---

# Physics System

## Layer Tabanlı Collision

```csharp
// Collision layer'ları ScriptableObject'te tanımla
[CreateAssetMenu(menuName = "Config/Physics")]
public sealed class PhysicsConfiguration : ScriptableObject
{
    [SerializeField] private LayerMask _playerLayer;
    [SerializeField] private LayerMask _enemyLayer;
    [SerializeField] private LayerMask _groundLayer;

    public LayerMask PlayerLayer => _playerLayer;
    public LayerMask EnemyLayer => _enemyLayer;
    public LayerMask GroundLayer => _groundLayer;
}
```

## Rigidbody Kullanımı

```csharp
// Physics'i FixedUpdate'te uygula
void FixedUpdate()
{
    _rb.MovePosition(_rb.position + _velocity * Time.fixedDeltaTime);
}

// Asla Transform.position = ... (fizik hesabını bozar)
```

## Raycast Optimizasyonu

```csharp
// YANLIŞ — her frame allocation
void Update()
{
    var hits = Physics.RaycastAll(origin, direction);
}

// DOĞRU — pre-allocated buffer
private readonly RaycastHit[] _hitBuffer = new RaycastHit[10];

void Update()
{
    int count = Physics.RaycastNonAlloc(origin, direction, _hitBuffer);
    for (int i = 0; i < count; i++) { ... }
}
```

## Trigger vs Collision

- Trigger: `OnTriggerEnter/Exit` — fiziksel tepki yok, sadece tespit
- Collision: `OnCollisionEnter/Exit` — fiziksel tepki var

Her ikisi de View'da işlenir, event ile servise bildirilir.
```

- [ ] **Step 3: animation/SKILL.md yaz**

```markdown
---
name: animation
description: Animator Controller, Animation Rigging ve animasyon event pattern'leri.
---

# Animation System

## Animator Pattern

```csharp
public sealed class PlayerAnimationProvider : MonoBehaviour
{
    private static readonly int IsMovingHash = Animator.StringToHash("IsMoving");
    private static readonly int AttackTriggerHash = Animator.StringToHash("Attack");
    private static readonly int SpeedHash = Animator.StringToHash("Speed");

    [SerializeField] private Animator _animator;

    public void SetMoving(bool isMoving)
        => _animator.SetBool(IsMovingHash, isMoving);

    public void SetSpeed(float speed)
        => _animator.SetFloat(SpeedHash, speed);

    public void TriggerAttack()
        => _animator.SetTrigger(AttackTriggerHash);
}
```

## StringToHash Zorunlu

Animator.StringToHash ile hash'leri cache'le — her frame string karşılaştırması pahalı.

## Animation Events

```csharp
// Animator'da animation event bağlanır, MonoBehaviour'da işlenir
public void OnAttackHitFrame()
{
    _eventBus.Publish(new AttackHitEvent(_playerId));
}
```

## State Machine Behaviour

AnimatorStateMachineBehaviour ile state giriş/çıkış olayları:

```csharp
public class AttackStateBehaviour : StateMachineBehaviour
{
    public override void OnStateEnter(Animator animator, AnimatorStateInfo info, int layerIndex)
    {
        animator.GetComponent<PlayerView>().OnAttackStateEnter();
    }
}
```
```

- [ ] **Step 4: ui-toolkit/SKILL.md yaz**

```markdown
---
name: ui-toolkit
description: Unity UI Toolkit (UIElements) pattern'leri. UXML, USS, runtime UI ve Editor tools.
---

# UI Toolkit

## Runtime UI Yapısı

```csharp
public sealed class MainMenuView : MonoBehaviour
{
    [SerializeField] private UIDocument _document;
    private Button _playButton;
    private Label _titleLabel;

    private IGameService _gameService;
    [Inject] void Construct(IGameService gs) => _gameService = gs;

    void OnEnable()
    {
        var root = _document.rootVisualElement;
        _playButton = root.Q<Button>("play-button");
        _titleLabel = root.Q<Label>("title-label");

        _playButton.clicked += OnPlayClicked;
    }

    void OnDisable() => _playButton.clicked -= OnPlayClicked;

    private void OnPlayClicked() => _gameService.StartGame();
}
```

## USS Değişkenleri

```css
/* Variables.uss */
:root {
    --color-primary: #4A90E2;
    --color-background: #1A1A2E;
    --font-size-title: 32px;
    --spacing-md: 16px;
}

.button-primary {
    background-color: var(--color-primary);
    padding: var(--spacing-md);
}
```

## Editor Tools (UI Toolkit ile)

```csharp
public class MyEditorWindow : EditorWindow
{
    [MenuItem("Tools/My Window")]
    public static void ShowWindow() => GetWindow<MyEditorWindow>();

    public void CreateGUI()
    {
        var button = new Button(() => Debug.Log("Clicked")) { text = "Click Me" };
        rootVisualElement.Add(button);
    }
}
```
```

- [ ] **Step 5: urp-pipeline/SKILL.md yaz**

```markdown
---
name: urp-pipeline
description: Universal Render Pipeline konfigürasyonu. Render Feature, Volume, Shader Graph entegrasyonu.
---

# URP Pipeline

## URP Asset Yapısı

Kalite tiers için ayrı URP Asset'ler:
- `URP-Low.asset` — mobil, düşük detay
- `URP-Medium.asset` — orta segment
- `URP-High.asset` — PC yüksek kalite

## Volume Sistemi

```csharp
// Runtime post-process kontrolü
public sealed class PostProcessProvider : MonoBehaviour
{
    [SerializeField] private Volume _globalVolume;
    private Bloom _bloom;
    private ColorAdjustments _colorAdj;

    void Awake()
    {
        _globalVolume.profile.TryGet(out _bloom);
        _globalVolume.profile.TryGet(out _colorAdj);
    }

    public void SetBloomIntensity(float intensity)
    {
        if (_bloom != null) _bloom.intensity.value = intensity;
    }
}
```

## Renderer Feature

Custom render pass eklemek için:

```csharp
public class OutlineRendererFeature : ScriptableRendererFeature
{
    private OutlineRenderPass _pass;

    public override void Create()
    {
        _pass = new OutlineRenderPass();
        _pass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData data)
    {
        renderer.EnqueuePass(_pass);
    }
}
```

## URP Shader Uyumu

Built-in shader'lar URP'de çalışmaz. Her shader URP için yazılmalı veya Shader Graph ile oluşturulmalı.
```

- [ ] **Step 6: Commit**

```bash
git add .claude/skills/systems/audio/ .claude/skills/systems/physics/ \
  .claude/skills/systems/animation/ .claude/skills/systems/ui-toolkit/ \
  .claude/skills/systems/urp-pipeline/
git commit -m "feat: add systems skills pt1 (audio, physics, animation, ui-toolkit, urp-pipeline)"
```

---

### Task 3: Systems Skills — Bölüm 2

**Files:**
- Create: `.claude/skills/systems/cinemachine/SKILL.md`
- Create: `.claude/skills/systems/shader-graph/SKILL.md`
- Create: `.claude/skills/systems/addressables/SKILL.md`
- Create: `.claude/skills/systems/vr/SKILL.md`

- [ ] **Step 1: cinemachine/SKILL.md yaz**

```markdown
---
name: cinemachine
description: Cinemachine kamera sistemi. Virtual Camera, Brain, Blend ve custom extension pattern'leri.
---

# Cinemachine

## Temel Yapı

```
CinemachineBrain (MainCamera'da)
├── CM vcam1 — Gameplay Camera (Priority: 10)
├── CM vcam2 — Cutscene Camera (Priority: 0)
└── CM vcam3 — Aim Camera (Priority: 0)
```

Priority yüksek olan aktif olur. Geçiş → priority değiştir.

## Follow & LookAt

```csharp
public sealed class CameraProvider : MonoBehaviour
{
    [SerializeField] private CinemachineVirtualCamera _gameplayCam;
    [SerializeField] private CinemachineVirtualCamera _aimCam;

    private IPlayerService _playerService;
    [Inject] void Construct(IPlayerService ps) => _playerService = ps;

    void OnEnable() => _eventBus.Subscribe<PlayerSpawnedEvent>(OnPlayerSpawned);
    void OnDisable() => _eventBus.Unsubscribe<PlayerSpawnedEvent>(OnPlayerSpawned);

    private void OnPlayerSpawned(PlayerSpawnedEvent e)
    {
        _gameplayCam.Follow = e.PlayerTransform;
        _gameplayCam.LookAt = e.PlayerTransform;
    }
}
```

## Cinemachine Impulse (Kamera Sarsıntısı)

```csharp
[SerializeField] private CinemachineImpulseSource _impulseSource;

public void ShakeCamera(float force) => _impulseSource.GenerateImpulse(force);
```

## Cinemachine Confiner

Kamerayı belirli bir alanla sınırla:
- Collider2D veya Composite Collider bağla
- CinemachineConfiner2D component ekle
```

- [ ] **Step 2: shader-graph/SKILL.md yaz**

```markdown
---
name: shader-graph
description: Shader Graph ile URP shader yazma pattern'leri. Custom node, SubGraph ve HLSL entegrasyonu.
---

# Shader Graph

## Ne Zaman Shader Graph, Ne Zaman HLSL?

| Durum | Tercih |
|---|---|
| Basit efekt (dissolve, outline, fresnel) | Shader Graph |
| Kompleks matematik / performans kritik | HLSL Custom Node |
| Compute shader | HLSL direkt |
| Existing shader'ı genişletme | HLSL |

## Shader Graph Klasör Yapısı

```
Arts/Shaders/
├── Characters/
│   ├── PlayerShader.shadergraph
│   └── EnemyShader.shadergraph
├── Environment/
│   └── GroundShader.shadergraph
└── SubGraphs/           ← Reusable node grupları
    ├── Fresnel.shadersubgraph
    └── Dissolve.shadersubgraph
```

## Custom HLSL Node

```csharp
// CustomNode.hlsl
void MyCustomFunction_float(float3 input, out float3 output)
{
    output = normalize(input) * 2.0;
}
```

Shader Graph'ta: Custom Function Node → File seçeneği → HLSL dosyasını bağla.

## Shader Property Kontrolü

```csharp
// Runtime'da material property değiştir
private static readonly int DissolveAmountID = Shader.PropertyToID("_DissolveAmount");

public void SetDissolveAmount(float amount)
{
    _renderer.material.SetFloat(DissolveAmountID, amount);
}
```

Shader.PropertyToID ile ID'yi cache'le — her frame string lookup pahalı.
```

- [ ] **Step 3: addressables/SKILL.md yaz**

```markdown
---
name: addressables
description: Addressables Asset System pattern'leri. Async yükleme, handle lifecycle, label yönetimi.
---

# Addressables

> Bu skill `project-config.json` → `"addressables": true` ise auto-yüklenir.

## Temel Yükleme Pattern

```csharp
public sealed class AssetLoader : IAssetLoader, IDisposable
{
    private readonly List<AsyncOperationHandle> _handles = new();

    public async UniTask<T> LoadAsync<T>(string key, CancellationToken ct) where T : Object
    {
        var handle = Addressables.LoadAssetAsync<T>(key);
        _handles.Add(handle);

        await handle.WithCancellation(ct);

        if (handle.Status != AsyncOperationStatus.Succeeded)
            throw new AssetLoadException($"Failed to load: {key}");

        return handle.Result;
    }

    public void Dispose()
    {
        foreach (var handle in _handles)
            if (handle.IsValid()) Addressables.Release(handle);
        _handles.Clear();
    }
}
```

## Instantiate Pattern

```csharp
public async UniTask<GameObject> InstantiateAsync(string key, Transform parent, CancellationToken ct)
{
    var handle = Addressables.InstantiateAsync(key, parent);
    _handles.Add(handle);
    await handle.WithCancellation(ct);
    return handle.Result;
}

// Release etmek için Addressables.ReleaseInstance kullan (Destroy değil!)
public void ReleaseInstance(GameObject go) => Addressables.ReleaseInstance(go);
```

## Label ile Preload

```csharp
public async UniTask PreloadAsync(string label, CancellationToken ct)
{
    var handle = Addressables.LoadAssetsAsync<Object>(label, null);
    _handles.Add(handle);
    await handle.WithCancellation(ct);
}
```

## Build ve Catalog

- Addressable Groups → Remote veya Local
- Remote → Content Delivery Network (CDN)
- Build → Window → Asset Management → Addressables → Build → New Build
```

- [ ] **Step 4: vr/SKILL.md yaz**

```markdown
---
name: vr
description: XR Interaction Toolkit ve XR Origin pattern'leri. Controller input, performance, comfort.
---

# VR Development

> Bu skill `project-config.json` → `"xr": true` ise auto-yüklenir.

## XR Origin Yapısı

```
XR Origin
├── Camera Offset
│   └── Main Camera (XR camera)
├── LeftHand Controller
│   └── XR Controller (Left Hand)
└── RightHand Controller
    └── XR Controller (Right Hand)
```

## Controller Input Pattern

```csharp
public sealed class VRInputProvider : MonoBehaviour
{
    [SerializeField] private InputActionReference _gripAction;
    [SerializeField] private InputActionReference _triggerAction;

    private IInteractionService _interactionService;
    [Inject] void Construct(IInteractionService is) => _interactionService = is;

    void OnEnable()
    {
        _gripAction.action.Enable();
        _triggerAction.action.Enable();
        _gripAction.action.performed += OnGrip;
        _triggerAction.action.performed += OnTrigger;
    }

    void OnDisable()
    {
        _gripAction.action.Disable();
        _triggerAction.action.Disable();
        _gripAction.action.performed -= OnGrip;
        _triggerAction.action.performed -= OnTrigger;
    }

    private void OnGrip(InputAction.CallbackContext ctx)
        => _interactionService.Grip(ctx.ReadValue<float>());

    private void OnTrigger(InputAction.CallbackContext ctx)
        => _interactionService.Trigger(ctx.ReadValue<float>());
}
```

## VR Performans Kuralları

- **Hedef framerate:** 90 FPS (Quest 2), 120 FPS (Quest 3)
- **Draw call limiti:** <100 per eye
- **Foveated Rendering:** Oculus Foveated Rendering aktif et
- **Single Pass Stereo:** Player Settings'de aktif et
- **Fixed Foveated Rendering:** Quest için zorunlu

## Comfort (Locomotion)

- Teleport locomotion → dizziness'ı azaltır
- Continuous locomotion → vignette ekle (hareket sırasında kenarları karart)
- Snap turn → ani yön değişiminde kullan

## XR Interaction Toolkit

- XR Grab Interactable → obje tutma
- XR Socket Interactor → slot yerleştirme
- XR Ray Interactor → uzak etkileşim (UI için)
```

- [ ] **Step 5: Commit**

```bash
git add .claude/skills/systems/cinemachine/ .claude/skills/systems/shader-graph/ \
  .claude/skills/systems/addressables/ .claude/skills/systems/vr/
git commit -m "feat: add systems skills pt2 (cinemachine, shader-graph, addressables, vr)"
```

---

### Task 4: Third-Party Skills

**Files:**
- Create: `.claude/skills/third-party/vcontainer/SKILL.md`
- Create: `.claude/skills/third-party/zenject/SKILL.md`
- Create: `.claude/skills/third-party/unitask/SKILL.md`
- Create: `.claude/skills/third-party/dotween/SKILL.md`
- Create: `.claude/skills/third-party/textmeshpro/SKILL.md`

- [ ] **Step 1: vcontainer/SKILL.md yaz**

```markdown
---
name: vcontainer
description: VContainer DI framework pattern'leri. LifetimeScope, Register, Inject, EntryPoint.
---

# VContainer

> `project-config.json` → `"di": "vcontainer"` ise auto-yüklenir.

## LifetimeScope Hiyerarşisi

```
AppScope (DontDestroyOnLoad)        ← Global servisler
└── GameScope (Sahneye özel)        ← Sahne servisleri
    └── SubScope (Opsiyonel)        ← Alt scope'lar
```

## Register Yöntemleri

```csharp
protected override void Configure(IContainerBuilder builder)
{
    // Pure C# servis
    builder.Register<AudioService>(Lifetime.Singleton).As<IAudioService>();

    // MonoBehaviour (Hierarchy'de var)
    builder.RegisterComponentInHierarchy<AudioProvider>();

    // MonoBehaviour (Prefab'dan)
    builder.RegisterComponentInNewPrefab(_audioProviderPrefab, Lifetime.Singleton);

    // Factory
    builder.RegisterFactory<Enemy>(container =>
        () => container.Resolve<Enemy>(), Lifetime.Singleton);

    // ScriptableObject
    builder.RegisterInstance(_audioConfig).As<IAudioConfiguration>();
}
```

## Inject Yöntemleri

```csharp
// Constructor injection (pure C#)
public sealed class AudioService : IAudioService
{
    private readonly IEventBus _eventBus;
    public AudioService(IEventBus eventBus) => _eventBus = eventBus;
}

// Method injection (MonoBehaviour)
public class PlayerView : MonoBehaviour
{
    private IPlayerService _playerService;
    [Inject] void Construct(IPlayerService ps) => _playerService = ps;
}
```

## EntryPoint (IStartable, ITickable)

```csharp
public sealed class GameEntryPoint : IStartable, IDisposable
{
    private readonly IGameService _gameService;
    public GameEntryPoint(IGameService gs) => _gameService = gs;

    public void Start() => _gameService.Initialize();
    public void Dispose() => _gameService.Cleanup();
}

// Register et
builder.RegisterEntryPoint<GameEntryPoint>();
```
```

- [ ] **Step 2: zenject/SKILL.md yaz**

```markdown
---
name: zenject
description: Zenject/Extenject DI framework pattern'leri. MonoInstaller, Bind, Inject, Signals.
---

# Zenject

> `project-config.json` → `"di": "zenject"` ise auto-yüklenir.

## Installer Hiyerarşisi

```
ProjectContext (DontDestroyOnLoad)   ← ProjectInstaller
└── SceneContext (Sahneye özel)      ← GameInstaller
```

## Bind Yöntemleri

```csharp
public class GameInstaller : MonoInstaller
{
    [SerializeField] private AudioProvider _audioProviderPrefab;
    [SerializeField] private AudioConfiguration _audioConfig;

    public override void InstallBindings()
    {
        // Pure C# singleton
        Container.Bind<IAudioService>().To<AudioService>().AsSingle();

        // MonoBehaviour (Hierarchy'de)
        Container.Bind<AudioProvider>().FromComponentInHierarchy().AsSingle();

        // MonoBehaviour (Prefab'dan)
        Container.Bind<AudioProvider>()
            .FromComponentInNewPrefab(_audioProviderPrefab)
            .AsSingle();

        // ScriptableObject
        Container.BindInstance(_audioConfig).AsSingle();
    }
}
```

## Inject Yöntemleri

```csharp
// Constructor injection
public sealed class AudioService : IAudioService
{
    private readonly IEventBus _eventBus;
    public AudioService(IEventBus eventBus) => _eventBus = eventBus;
}

// [Inject] field/method (MonoBehaviour)
public class PlayerView : MonoBehaviour
{
    [Inject] private IPlayerService _playerService;
    // veya
    [Inject]
    public void Construct(IPlayerService ps) => _playerService = ps;
}
```

## IInitializable, ITickable, IDisposable

```csharp
public sealed class GameEntryPoint : IInitializable, IDisposable
{
    private readonly IGameService _gameService;
    public GameEntryPoint(IGameService gs) => _gameService = gs;

    public void Initialize() => _gameService.Initialize();
    public void Dispose() => _gameService.Cleanup();
}

Container.BindInterfacesTo<GameEntryPoint>().AsSingle();
```
```

- [ ] **Step 3: unitask/SKILL.md yaz**

```markdown
---
name: unitask
description: UniTask async/await pattern'leri. Temel kullanım, CancellationToken, PlayerLoop entegrasyonu.
---

# UniTask

> `project-config.json` → `"async": "unitask"` ise auto-yüklenir (her zaman).

## Temel Kullanım

```csharp
// UniTask döndüren async metot
public async UniTask LoadAsync(CancellationToken ct)
{
    await UniTask.Delay(1000, cancellationToken: ct);
    await LoadResourcesAsync(ct);
}

// Değer döndüren
public async UniTask<PlayerData> GetPlayerDataAsync(CancellationToken ct)
{
    var json = await File.ReadAllTextAsync("save.json", ct);
    return JsonUtility.FromJson<PlayerData>(json);
}
```

## Coroutine Karşılıkları

```csharp
yield return null                    → await UniTask.Yield()
yield return new WaitForSeconds(t)   → await UniTask.Delay(TimeSpan.FromSeconds(t), ct)
yield return new WaitForFixedUpdate()→ await UniTask.WaitForFixedUpdate()
yield return new WaitUntil(pred)     → await UniTask.WaitUntil(pred, ct: ct)
yield return asyncOp                 → await asyncOp.WithCancellation(ct)
```

## Fire-and-Forget

```csharp
// DOĞRU — exception işlenir
DoAsync(ct).Forget(e => Debug.LogException(e));

// YANLIŞ — exception yutulur
DoAsync(ct).Forget();
```

## CancellationToken Kaynakları

```csharp
// MonoBehaviour yok olunca iptal
await LoadAsync(destroyCancellationToken);

// Manuel iptal
private CancellationTokenSource _cts = new();
await LoadAsync(_cts.Token);
// İptal et: _cts.Cancel();

// Linked token (ikisi de iptal edebilir)
var linked = CancellationTokenSource.CreateLinkedTokenSource(
    destroyCancellationToken, externalCt);
await LoadAsync(linked.Token);
```

## Paralel İşlemler

```csharp
await UniTask.WhenAll(
    LoadAudioAsync(ct),
    LoadTextureAsync(ct),
    LoadDataAsync(ct)
);
```
```

- [ ] **Step 4: dotween/SKILL.md yaz**

```markdown
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
    // Bu objeye bağlı tüm tween'leri durdur
    DOTween.Kill(transform);
}
```
```

- [ ] **Step 5: textmeshpro/SKILL.md yaz**

```markdown
---
name: textmeshpro
description: TextMeshPro kullanım pattern'leri. TMP_Text, rich text, font atlas yönetimi.
---

# TextMeshPro

## TMP_Text Kullanımı

```csharp
public sealed class ScoreView : MonoBehaviour
{
    [SerializeField] private TMP_Text _scoreText;

    // StringBuilder ile allocation-free güncelleme
    private readonly StringBuilder _sb = new(32);

    public void UpdateScore(int score)
    {
        _sb.Clear();
        _sb.Append("Score: ");
        _sb.Append(score);
        _scoreText.SetText(_sb);
    }
}
```

## Rich Text

```csharp
// Kod içinden rich text
_label.text = $"<color=#FF0000>Kırmızı</color> <b>Kalın</b> <size=24>Büyük</size>";

// Sprite atlas (icon)
_label.text = "Para: <sprite name=\"coin\"> 100";
```

## Font Atlas Yönetimi

- Her farklı font → ayrı Font Asset
- Dynamic Character Set: kullanılan karakterler otomatik eklenir
- Static Character Set: belirli karakter seti için daha performanslı

## Performans

```csharp
// YANLIŞ — her frame string allocation
void Update() { _text.text = "Score: " + _score; }

// DOĞRU — sadece değişince güncelle
public void OnScoreChanged(int score)
{
    _sb.Clear();
    _sb.Append("Score: ");
    _sb.Append(score);
    _text.SetText(_sb);
}
```

## TMP_InputField

```csharp
[SerializeField] private TMP_InputField _nameInput;

void OnEnable() => _nameInput.onEndEdit.AddListener(OnNameSubmitted);
void OnDisable() => _nameInput.onEndEdit.RemoveListener(OnNameSubmitted);

private void OnNameSubmitted(string value)
    => _playerService.SetPlayerName(value);
```
```

- [ ] **Step 6: Verify — Tüm skill dosyaları**

```powershell
$skillFiles = Get-ChildItem .claude/skills -Recurse -Filter "SKILL.md"
$coreFiles = Get-ChildItem .claude/skills/core -Filter "*.md"
Write-Host "Core skills: $($coreFiles.Count + $skillFiles.Where({$_.FullName -match 'core'}).Count)"
Write-Host "Systems skills: $($skillFiles.Where({$_.FullName -match 'systems'}).Count)"
Write-Host "Third-party skills: $($skillFiles.Where({$_.FullName -match 'third-party'}).Count)"
```

Beklenen:
- Core: 4 dosya (model-routing + 3 SKILL.md)
- Systems: 9 SKILL.md
- Third-party: 5 SKILL.md

- [ ] **Step 7: auto-loaded-skills.md güncelle**

`.claude/docs/auto-loaded-skills.md` dosyasını güncelle — third-party'yi ekle:

```markdown
# Auto-Loaded Skills

Bu dosya hooks tarafından otomatik güncellenir.

## Her Zaman Yüklü (core/)
@.claude/skills/core/model-routing.md
@.claude/skills/core/unity-instincts/SKILL.md
@.claude/skills/core/unity-mcp-patterns/SKILL.md
@.claude/skills/core/context-management/SKILL.md

## Proje Konfigürasyonuna Göre (project-config.json)
# di: vcontainer → @.claude/skills/third-party/vcontainer/SKILL.md
# di: zenject    → @.claude/skills/third-party/zenject/SKILL.md
# async: unitask → @.claude/skills/third-party/unitask/SKILL.md (her zaman)
# ecs: true      → @.claude/rules/ecs-dots.md
# addressables: true → @.claude/skills/systems/addressables/SKILL.md
# xr: true       → @.claude/skills/systems/vr/SKILL.md
```

- [ ] **Step 8: Final commit**

```bash
git add .claude/skills/third-party/ .claude/docs/auto-loaded-skills.md
git commit -m "feat: add third-party skills and update auto-loaded-skills index"
```

---

**Phase 5 tamamlandı.** Sonraki: Phase 6 — Commands (~25 slash command dosyası).
