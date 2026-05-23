# Unity Claude AI Workflow — Phase 2: Rules

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 12 zorunlu + 2 opsiyonel mimari kural dosyasını oluştur.

**Architecture:** Her kural dosyası `.claude/rules/` altında tek bir `.md`. CLAUDE.md bunları session başında otomatik yükler. Her dosya: kural adı, ne enforce ettiği, somut yasak/zorunluluk listesi ve örnekler.

**Tech Stack:** Markdown

---

## Dosya Haritası

| Dosya | Zorunlu mu |
|---|---|
| `.claude/rules/architecture.md` | Evet |
| `.claude/rules/dependency-injection.md` | Evet |
| `.claude/rules/async.md` | Evet |
| `.claude/rules/unity-lifecycle.md` | Evet |
| `.claude/rules/unity-input.md` | Evet |
| `.claude/rules/performance.md` | Evet |
| `.claude/rules/serialization.md` | Evet |
| `.claude/rules/testing.md` | Evet |
| `.claude/rules/event-patterns.md` | Evet |
| `.claude/rules/unity-prefabs.md` | Evet |
| `.claude/rules/scene-hierarchy.md` | Evet |
| `.claude/rules/csharp-unity.md` | Evet |
| `.claude/rules/ecs-dots.md` | Opsiyonel (ecs: true) |
| `.claude/rules/addressables.md` | Opsiyonel (addressables: true) |

---

### Task 1: architecture.md + dependency-injection.md

**Files:**
- Create: `.claude/rules/architecture.md`
- Create: `.claude/rules/dependency-injection.md`

- [ ] **Step 1: architecture.md yaz**

```markdown
# Architecture Rules

## Klasör Yapısı (Zorunlu)

```
Assets/
├── _Framework/          ← Pure C# altyapı, SIFIR oyun bağımlılığı
│   ├── Events/
│   ├── Logging/
│   └── SaveLoad/
└── _GameFolders/
    └── Scripts/
        ├── Games/
        │   ├── Abstracts/   ← SADECE interface'ler, domain bazlı klasörler
        │   └── Concretes/   ← Tüm concrete sınıflar
        ├── Tests/
        │   ├── EditMode/
        │   └── PlayMode/
        └── Editors/         ← Editor-only araçlar
```

## Katman Kuralları

- `_Framework/` hiçbir zaman `_GameFolders/` veya oyun koduna referans vermez
- `Games/Abstracts/` → sadece interface dosyaları
- `Games/Concretes/` alt klasör adları domain/feature adı olur: `Audio/`, `Players/`, `Enemies/`
- `Services/`, `Views/`, `Providers/` gibi teknik katman adları yasak alt klasör adı olarak

## Modül Yapısı (Her modül 5 dosya)

```
Games/Abstracts/[Domain]/
└── I[Domain]Service.cs        ← Tek public API

Games/Concretes/[Domain]/
├── [Domain]Service.cs          ← sealed implementasyon
├── [Domain]Configuration.cs    ← ScriptableObject config
├── [Domain]Installer.cs        ← VContainer/Zenject registration
├── [Domain]Events.cs           ← IEvent struct'ları
└── [Domain]Provider.cs         ← MonoBehaviour (Unity API buraya)
```

## Yasak Patternler

- `FindObjectOfType`, `FindAnyObjectByType` — DI kullan
- `GetComponentInChildren` fallback olarak — inject et
- God object / ServiceLocator — yasak
- Static erişim noktaları — yasak
- `_Framework/` içinde `using UnityEngine` — hook engeller

## IEventBus Kuralı

Sistemler arası iletişim için `IEventBus` kullan.
Doğrudan servis referansı yerine event yayınla:

```csharp
// DOĞRU
_eventBus.Publish(new PlayerDiedEvent(playerId));

// YANLIŞ
_enemyService.OnPlayerDied(playerId);
```
```

- [ ] **Step 2: dependency-injection.md yaz**

```markdown
# Dependency Injection Rules

## Zorunlu Container

`project-config.json`'daki `di` değerine göre:
- `"vcontainer"` → VContainer kullan
- `"zenject"` → Zenject kullan
- İkisi aynı projede birlikte kullanılamaz

## Scope Yapısı (VContainer)

```csharp
// AppScope.cs — DontDestroyOnLoad, global servisler
public class AppScope : LifetimeScope
{
    protected override void Configure(IContainerBuilder builder)
    {
        builder.Register<AudioService>(Lifetime.Singleton).As<IAudioService>();
        builder.RegisterComponentInHierarchy<AudioProvider>();
    }
}

// GameScope.cs — Sahneye özel servisler
public class GameScope : LifetimeScope { ... }
```

## Scope Yapısı (Zenject)

```csharp
public class AppInstaller : MonoInstaller
{
    public override void InstallBindings()
    {
        Container.Bind<IAudioService>().To<AudioService>().AsSingle();
    }
}
```

## Inject Etme

```csharp
// Constructor injection (pure C#)
public sealed class AudioService : IAudioService
{
    private readonly IEventBus _eventBus;
    public AudioService(IEventBus eventBus) => _eventBus = eventBus;
}

// [Inject] method (MonoBehaviour)
public class AudioProvider : MonoBehaviour
{
    private IAudioService _audioService;
    [Inject] void Construct(IAudioService audioService) => _audioService = audioService;
}
```

## Yasak Patternler

```csharp
// YASAK — Singleton
public static AudioService Instance { get; private set; }

// YASAK — FindObjectOfType
var svc = FindObjectOfType<AudioService>();

// YASAK — GetComponent fallback
void Start() { _service = GetComponent<AudioService>(); }

// YASAK — ServiceLocator
ServiceLocator.Get<IAudioService>();
```

## Fail-Fast Prensibi

Eksik dependency → hemen exception fırlat, sessizce arama yapma.

```csharp
// DOĞRU
public AudioService(IEventBus eventBus)
{
    _eventBus = eventBus ?? throw new ArgumentNullException(nameof(eventBus));
}
```
```

- [ ] **Step 3: Verify**

```powershell
Get-Content .claude/rules/architecture.md | Measure-Object -Line
Get-Content .claude/rules/dependency-injection.md | Measure-Object -Line
```

Beklenen: Her iki dosya da 0 satırdan fazla, hata yok.

- [ ] **Step 4: Commit**

```bash
git add .claude/rules/architecture.md .claude/rules/dependency-injection.md
git commit -m "feat: add architecture and dependency-injection rules"
```

---

### Task 2: async.md + unity-lifecycle.md

**Files:**
- Create: `.claude/rules/async.md`
- Create: `.claude/rules/unity-lifecycle.md`

- [ ] **Step 1: async.md yaz**

```markdown
# Async Rules

## Zorunlu: UniTask

Tüm async işlemler UniTask kullanır. `System.Threading.Tasks.Task` ve coroutine yasak.

```csharp
// DOĞRU
public async UniTask LoadAsync(CancellationToken ct)
{
    await UniTask.Delay(1000, cancellationToken: ct);
}

// YANLIŞ — coroutine
IEnumerator LoadCoroutine() { yield return new WaitForSeconds(1f); }

// YANLIŞ — Task
async Task LoadAsync() { await Task.Delay(1000); }
```

## CancellationToken Zorunluluğu

Her public async metot `CancellationToken` parametresi alır:

```csharp
// DOĞRU
public async UniTask PlayAsync(string clipName, CancellationToken ct)

// YANLIŞ — token yok
public async UniTask PlayAsync(string clipName)
```

## async void Yasak

```csharp
// YASAK
async void OnButtonClick() { await DoSomethingAsync(); }

// DOĞRU — UniTask döndür veya .Forget() kullan
void OnButtonClick() { DoSomethingAsync(destroyCancellationToken).Forget(); }
```

## Ownership Modeli

- View'lar `destroyCancellationToken` kullanır (MonoBehaviour yok olunca iptal)
- Servisler kendi `CancellationTokenSource`'larını oluşturur ve dispose eder

```csharp
public class AudioService : IAudioService, IDisposable
{
    private readonly CancellationTokenSource _cts = new();

    public void Dispose() => _cts.Cancel();

    public async UniTask PlayAsync(string clip, CancellationToken ct)
    {
        var linked = CancellationTokenSource.CreateLinkedTokenSource(_cts.Token, ct);
        await _audioClip.ToUniTask(cancellationToken: linked.Token);
    }
}
```

## UniTask.WhenAll Kullanımı

```csharp
// Paralel async işlemler
await UniTask.WhenAll(
    LoadAudioAsync(ct),
    LoadTextureAsync(ct)
);
```
```

- [ ] **Step 2: unity-lifecycle.md yaz**

```markdown
# Unity Lifecycle Rules

## Lifecycle Disiplini

| Method | Kullanım |
|---|---|
| `Awake()` | Lokal referans init, GetComponent (sadece self) |
| `OnEnable()` | Event subscribe, listener kayıt |
| `OnDisable()` | Event unsubscribe, listener iptal |
| `Start()` | SADECE basit başlangıç — kurulum recovery DEĞİL |

```csharp
// DOĞRU
void Awake() => _rb = GetComponent<Rigidbody>();
void OnEnable() => _eventBus.Subscribe<PlayerDiedEvent>(OnPlayerDied);
void OnDisable() => _eventBus.Unsubscribe<PlayerDiedEvent>(OnPlayerDied);

// YANLIŞ — Start'ta bağımlılık arama
void Start() { _service = FindObjectOfType<AudioService>(); }
```

## UnityEditor Guard

Runtime kodda `UnityEditor` namespace kullanmak hook tarafından engellenir.
Gerekiyorsa:

```csharp
#if UNITY_EDITOR
using UnityEditor;
// editor-only kod
#endif
```

## Threading Kuralları

- Unity API yalnızca main thread'den çağrılır
- Background thread'den UI güncelleme → `UniTask.SwitchToMainThread()`

```csharp
await UniTask.SwitchToThreadPool();
var data = await LoadHeavyDataAsync();
await UniTask.SwitchToMainThread();
_textComponent.text = data.ToString(); // main thread'de güvenli
```

## Time Kuralları

- `Time.timeScale` assignment yasak (hook engeller) — event yayınla
- `Time.deltaTime` hot path'te her frame cachelenebilir

## Platform Define'ları

```csharp
#if UNITY_ANDROID || UNITY_IOS
    // mobil kod
#elif UNITY_STANDALONE
    // PC kod
#endif
```
```

- [ ] **Step 3: Verify**

```powershell
Select-String -Path ".claude/rules/async.md" -Pattern "CancellationToken"
Select-String -Path ".claude/rules/unity-lifecycle.md" -Pattern "Awake|OnEnable|OnDisable"
```

Beklenen: Her iki dosyada da ilgili keyword'ler bulunur.

- [ ] **Step 4: Commit**

```bash
git add .claude/rules/async.md .claude/rules/unity-lifecycle.md
git commit -m "feat: add async and unity-lifecycle rules"
```

---

### Task 3: performance.md + serialization.md + unity-input.md

**Files:**
- Create: `.claude/rules/performance.md`
- Create: `.claude/rules/serialization.md`
- Create: `.claude/rules/unity-input.md`

- [ ] **Step 1: performance.md yaz**

```markdown
# Performance Rules

## Hot Path Tanımı

`Update()`, `FixedUpdate()`, `LateUpdate()` ve bunlardan çağrılan her metot hot path'tir.

## Allocation Yasağı

Hot path'te GC allocation sıfır olmalı:

```csharp
// YANLIŞ — her frame allocation
void Update()
{
    var enemies = new List<Enemy>(); // allocation!
    var name = $"Enemy_{id}";       // string allocation!
}

// DOĞRU — önceden alloc edilmiş
private readonly List<Enemy> _enemies = new(32);
private readonly StringBuilder _sb = new();
```

## LINQ Yasağı (Hot Path)

```csharp
// YANLIŞ — Update içinde
void Update()
{
    var alive = _enemies.Where(e => e.IsAlive).ToList();
}

// DOĞRU — for loop
void Update()
{
    for (int i = 0; i < _enemies.Count; i++)
        if (_enemies[i].IsAlive) Process(_enemies[i]);
}
```

## GetComponent Cache Zorunlu

```csharp
// YANLIŞ
void Update() { GetComponent<Rigidbody>().AddForce(Vector3.up); }

// DOĞRU
private Rigidbody _rb;
void Awake() => _rb = GetComponent<Rigidbody>();
void Update() => _rb.AddForce(Vector3.up);
```

## Find* Yasağı (Hot Path)

`Camera.main`, `FindObjectOfType`, `FindAnyObjectByType` → inject et veya cache'le.

## Object Pooling

Sık oluşturulan/yok edilen objeler için `ObjectPool<T>` kullan:

```csharp
private IObjectPool<BulletView> _pool;

void Awake()
{
    _pool = new ObjectPool<BulletView>(
        createFunc: () => Instantiate(_bulletPrefab),
        actionOnGet: b => b.gameObject.SetActive(true),
        actionOnRelease: b => b.gameObject.SetActive(false),
        actionOnDestroy: b => Destroy(b.gameObject),
        defaultCapacity: 32,
        maxSize: 128
    );
}
```

## Draw Call Disiplini

- Static objeler → Static Batching işaretle
- Aynı material kullanan dinamik objeler → GPU Instancing
- UI Canvas'ları ayrı tut (World Space / Screen Space)
```

- [ ] **Step 2: serialization.md yaz**

```markdown
# Serialization Rules

## FormerlySerializedAs Zorunlu

[SerializeField] alan adı değişince veri kaybı olur. Her rename'de zorunlu:

```csharp
// Alan adı _speed → _moveSpeed olarak değişti
[SerializeField]
[FormerlySerializedAs("_speed")]
private float _moveSpeed = 5f;
```

## [SerializeField] Tercihi

```csharp
// DOĞRU — private, inspector'da görünür
[SerializeField] private float _speed = 5f;

// YANLIŞ — gereksiz public
public float speed = 5f;
```

## Runtime State Serialize Edilmez

ScriptableObject veya serialized field'lar sadece konfigürasyon için.
Runtime'da değişen state → plain C# field.

```csharp
// YANLIŞ — runtime state serialize
[SerializeField] private int _currentHealth;

// DOĞRU — config serialize, state ayrı
[SerializeField] private int _maxHealth = 100;
private int _currentHealth; // runtime, serialize etme
```

## Unity Null Check

Unity object'lerde `?.` ve `is null` operator'leri gerçek null değil
Unity'nin override ettiği == karşılaştırmasını atlatır:

```csharp
// YANLIŞ — Unity'nin destroyed check'ini atlatır
if (_component?.DoSomething() != null) { }
if (_go is null) { }

// DOĞRU
if (_component != null) _component.DoSomething();
if (_go == null) { }
```

## SerializeReference

Polymorphic serialization için:

```csharp
[SerializeReference] private IAbility _ability;
```
```

- [ ] **Step 3: unity-input.md yaz**

```markdown
# Unity Input Rules

## Input Sistemi Seçimi

`project-config.json`'daki `input` değerine göre:
- `"new"` → New Input System (Input System paketi)
- `"legacy"` → Legacy Input Manager

`check-input-system.sh` hook'u: `input: "new"` ise `Input.GetKey/Axis` kullanımını engeller.

## New Input System Pattern

Input logic View katmanında kalır, Core/Service'e sızmaz:

```csharp
// InputView.cs — MonoBehaviour, View katmanı
public class PlayerInputView : MonoBehaviour
{
    [SerializeField] private InputActionAsset _inputActions;
    private InputAction _moveAction;
    private InputAction _jumpAction;

    private IPlayerService _playerService;
    [Inject] void Construct(IPlayerService ps) => _playerService = ps;

    void Awake()
    {
        _moveAction = _inputActions["Player/Move"];
        _jumpAction = _inputActions["Player/Jump"];
    }

    void OnEnable()
    {
        _moveAction.Enable();
        _jumpAction.Enable();
        _jumpAction.performed += OnJump;
    }

    void OnDisable()
    {
        _moveAction.Disable();
        _jumpAction.Disable();
        _jumpAction.performed -= OnJump;
    }

    void Update() => _playerService.SetMoveInput(_moveAction.ReadValue<Vector2>());

    private void OnJump(InputAction.CallbackContext ctx) => _playerService.Jump();
}
```

## Legacy Input Pattern

```csharp
// SADECE legacy seçiliyse geçerli
void Update()
{
    var move = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));
    _playerService.SetMoveInput(move);

    if (Input.GetButtonDown("Jump")) _playerService.Jump();
}
```

## Yasak Patternler

```csharp
// YANLIŞ — input logic service/environment'ta
public class PlayerService : IPlayerService
{
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space)) Jump(); // input buraya girmez
    }
}
```
```

- [ ] **Step 4: Verify**

```powershell
@("performance.md","serialization.md","unity-input.md") | ForEach-Object {
    $lines = (Get-Content ".claude/rules/$_" | Measure-Object -Line).Lines
    Write-Host "$_ — $lines satır"
}
```

Beklenen: Her dosya 30+ satır.

- [ ] **Step 5: Commit**

```bash
git add .claude/rules/performance.md .claude/rules/serialization.md .claude/rules/unity-input.md
git commit -m "feat: add performance, serialization and unity-input rules"
```

---

### Task 4: testing.md + event-patterns.md + unity-prefabs.md + scene-hierarchy.md + csharp-unity.md

**Files:**
- Create: `.claude/rules/testing.md`
- Create: `.claude/rules/event-patterns.md`
- Create: `.claude/rules/unity-prefabs.md`
- Create: `.claude/rules/scene-hierarchy.md`
- Create: `.claude/rules/csharp-unity.md`

- [ ] **Step 1: testing.md yaz**

```markdown
# Testing Rules

## Test Tipi Karar Ağacı

```
Unity API var mı?
├── Hayır → EditMode Test (NUnit, hızlı)
└── Evet → Scene gerekiyor mu?
    ├── Hayır → PlayMode Programmatic (MonoBehaviour olmadan)
    └── Evet → PlayMode Scene Test
```

## EditMode Test (Pure C#)

```csharp
[TestFixture]
public class AudioServiceTests
{
    private AudioService _sut;
    private IEventBus _eventBus;

    [SetUp]
    public void SetUp()
    {
        _eventBus = Substitute.For<IEventBus>();
        _sut = new AudioService(_eventBus);
    }

    [Test]
    public void Play_PublishesAudioStartedEvent()
    {
        // Arrange
        const string clipName = "explosion";

        // Act
        _sut.Play(clipName);

        // Assert
        _eventBus.Received(1).Publish(Arg.Is<AudioStartedEvent>(e => e.ClipName == clipName));
    }
}
```

## PlayMode Test (MonoBehaviour)

```csharp
[UnityTest]
public IEnumerator PlayerView_ReceivesInput_MovesCharacter()
{
    var go = new GameObject();
    var view = go.AddComponent<PlayerView>();
    yield return null; // Awake/Start çalışsın

    view.SimulateInput(Vector2.right);
    yield return new WaitForSeconds(0.1f);

    Assert.Greater(go.transform.position.x, 0f);

    Object.Destroy(go);
}
```

## NSubstitute Kuralları

```csharp
// Mock oluştur
var mock = Substitute.For<IService>();

// Davranış tanımla
mock.GetValue().Returns(42);

// Çağrı doğrula
mock.Received(1).Process(Arg.Any<string>());
mock.DidNotReceive().Process("forbidden");
```

## AAA Pattern Zorunlu

Her test: Arrange / Act / Assert bölümleriyle.
Tek test → tek assertion konusu (birden fazla Assert kabul edilebilir ama tek davranışı test eder).

## Test Dosya Konumu

```
Scripts/Tests/
├── [Project]EditModeTest/
│   └── [Domain]/[Class]Tests.cs
└── [Project]PlayModeTest/
    └── [Feature]/[Feature]PlayTests.cs
```
```

- [ ] **Step 2: event-patterns.md yaz**

```markdown
# Event Pattern Rules

## UnityEvent Yasak

```csharp
// YANLIŞ
[SerializeField] private UnityEvent<int> onScoreChanged;
[SerializeField] private UnityEvent onPlayerDied;
```

`check-unity-event.sh` hook'u bunu engeller.

## IEventBus — Sistemler Arası İletişim

Farklı sistemler (servisler) arası iletişim için:

```csharp
// Event tanımı
public readonly struct PlayerDiedEvent : IEvent
{
    public readonly int PlayerId;
    public PlayerDiedEvent(int id) => PlayerId = id;
}

// Yayınla
_eventBus.Publish(new PlayerDiedEvent(_playerId));

// Dinle (OnEnable/OnDisable ile eşleştir)
void OnEnable() => _eventBus.Subscribe<PlayerDiedEvent>(OnPlayerDied);
void OnDisable() => _eventBus.Unsubscribe<PlayerDiedEvent>(OnPlayerDied);
private void OnPlayerDied(PlayerDiedEvent e) { ... }
```

## C# Event — Aynı Modül İçi

Aynı modül içindeki bileşenler arası sıkı bağlı iletişim için:

```csharp
public class AudioService : IAudioService
{
    public event Action<string> OnClipStarted;
    private void Play(string name) => OnClipStarted?.Invoke(name);
}
```

## Action/Func — Callback

Tek seferlik callback veya delegate iletimi için:

```csharp
public void LoadAsync(Action<AudioClip> onComplete, CancellationToken ct) { }
```

## Karar Ağacı

```
Farklı sistemler arası mı?     → IEventBus
Aynı modül içinde mi?          → C# event
Tek seferlik callback mi?      → Action/Func
Inspector'dan atanacak mı?     → [SerializeField] Action (UnityEvent değil)
```
```

- [ ] **Step 3: unity-prefabs.md yaz**

```markdown
# Unity Prefab Rules

## Her Scene Object Prefab Olmalı

Sahnedeki her GameObject bir prefab instance'ı olmalı.
Doğrudan sahne objesi oluşturma yasak:

```csharp
// YANLIŞ
var go = new GameObject("Enemy");
var enemy = go.AddComponent<EnemyView>();

// DOĞRU — prefab'dan instantiate
var enemy = Instantiate(_enemyPrefab, position, rotation);
```

`check-pure-csharp.sh` ve hook'lar `new GameObject()` pattern'ini yakalar.

## Prefab Yapısı

```
EnemyPrefab (root)
├── EnemyView.cs         ← logic component burada
└── Body (child)
    └── MeshRenderer     ← görseller child'da
```

Root → logic bileşenleri
Body child → görsel bileşenler (MeshRenderer, Animator)

## Destroy Kuralları

```csharp
// Pooled objeler — Destroy çağırmak yasak, pool'a iade et
_pool.Release(bulletView);

// Non-pooled, sahneden kaldırılacak
Destroy(gameObject);

// Editor'da (test)
DestroyImmediate(gameObject);
```

## BaseCanvas Pattern

Her Canvas → ayrı prefab, `BaseCanvas` base class'tan türer:

```csharp
public abstract class BaseCanvas : MonoBehaviour
{
    [SerializeField] private CanvasGroup _canvasGroup;
    public void Show() => _canvasGroup.alpha = 1f;
    public void Hide() => _canvasGroup.alpha = 0f;
}
```

## Prefab Variant

Benzer prefablar için base prefab + Prefab Variant kullan:
`EnemyBase.prefab` → `EnemyFast.prefab (variant)`, `EnemyTank.prefab (variant)`
```

- [ ] **Step 4: scene-hierarchy.md yaz**

```markdown
# Scene Hierarchy Rules

## 6 Container Standardı

Her sahne bu 6 root container'ı içerir, bu sırayla:

```
[Setup]           ← LifetimeScope, Installer'lar, bootstrap
[Services]        ← Service Provider MonoBehaviour'ları
[UI]              ← Canvas'lar, HUD, popup'lar
[Environment]     ← Zemin, duvarlar, ışık, kamera
[Characters]      ← Player, NPC, Enemy prefab instance'ları
[VFX]             ← Particle system'ler, efektler
```

## Container İsimlendirme

Köşeli parantez zorunlu: `[Setup]`, `[Services]`, `[UI]`...
Bu pattern ile hızlı Inspector gezintisi sağlanır.

## [Setup] İçeriği

```
[Setup]
└── GameScope (LifetimeScope component'li)
    ├── GameInstaller
    └── [diğer installer'lar]
```

## [Services] İçeriği

```
[Services]
├── AudioProvider
├── InputProvider
└── [diğer provider MonoBehaviour'ları]
```

## Kural

- Her prefab kendi container'ına yerleşir
- Container'lar arası parent-child yasak (prefab → doğru container'ına)
- EventSystem → [UI] altında
- MainCamera → [Environment] altında
```

- [ ] **Step 5: csharp-unity.md yaz**

```markdown
# C# & Unity Coding Rules

## İsimlendirme

| Tür | Format | Örnek |
|---|---|---|
| Class, Interface, Enum | PascalCase | `AudioService`, `IAudioService` |
| Method, Property | PascalCase | `PlayClip()`, `IsPlaying` |
| Private field | _camelCase | `_audioSource` |
| Const | UPPER_SNAKE | `MAX_POOL_SIZE` |
| Local variable | camelCase | `clipName` |

## Namespace Zorunlu

Her dosya namespace içinde:

```csharp
namespace MyGame.Audio
{
    public sealed class AudioService : IAudioService { }
}
```

## #region Yapısı

```csharp
public class PlayerView : MonoBehaviour
{
    #region Serialized Fields
    [SerializeField] private float _speed;
    #endregion

    #region Private Fields
    private Rigidbody _rb;
    #endregion

    #region Unity Lifecycle
    void Awake() { }
    void OnEnable() { }
    void OnDisable() { }
    void Update() { }
    #endregion

    #region Public API
    public void SetMoveInput(Vector2 input) { }
    #endregion

    #region Private Methods
    private void ApplyMovement() { }
    #endregion
}
```

## sealed Kullanımı

Inheritance amaçlanmıyorsa `sealed` ekle:

```csharp
public sealed class AudioService : IAudioService { }
```

## Interface İsimlendirme

Her interface `I` prefix'iyle başlar:

```csharp
public interface IAudioService { }
public interface IEventBus { }
```

## Dosya = Sınıf

Her `.cs` dosyası tek bir public tip içerir.
Dosya adı = sınıf adı: `AudioService.cs` → `AudioService`.
```

- [ ] **Step 6: Verify — Tüm rule dosyaları var mı?**

```powershell
Get-ChildItem .claude/rules/ -Filter "*.md" | Select-Object Name
```

Beklenen: architecture.md, dependency-injection.md, async.md, unity-lifecycle.md, performance.md, serialization.md, unity-input.md, testing.md, event-patterns.md, unity-prefabs.md, scene-hierarchy.md, csharp-unity.md

- [ ] **Step 7: Commit**

```bash
git add .claude/rules/testing.md .claude/rules/event-patterns.md .claude/rules/unity-prefabs.md .claude/rules/scene-hierarchy.md .claude/rules/csharp-unity.md
git commit -m "feat: add testing, event-patterns, prefabs, scene-hierarchy and csharp rules"
```

---

### Task 5: ecs-dots.md + addressables.md (Opsiyonel)

**Files:**
- Create: `.claude/rules/ecs-dots.md`
- Create: `.claude/rules/addressables.md`

- [ ] **Step 1: ecs-dots.md yaz**

```markdown
# ECS / DOTS Rules

> Aktif koşul: `project-config.json` → `"ecs": true`

## Temel Yapı

```csharp
// Component — pure data
public struct HealthComponent : IComponentData
{
    public float Value;
    public float Max;
}

// System — logic
public partial struct HealthSystem : ISystem
{
    public void OnUpdate(ref SystemState state)
    {
        foreach (var (health, entity) in
            SystemAPI.Query<RefRW<HealthComponent>>().WithEntityAccess())
        {
            if (health.ValueRO.Value <= 0)
                state.EntityManager.DestroyEntity(entity);
        }
    }
}
```

## Authoring / Baker

```csharp
public class HealthAuthoring : MonoBehaviour
{
    public float MaxHealth = 100f;

    public class Baker : Baker<HealthAuthoring>
    {
        public override void Bake(HealthAuthoring authoring)
        {
            var entity = GetEntity(TransformUsageFlags.Dynamic);
            AddComponent(entity, new HealthComponent
            {
                Value = authoring.MaxHealth,
                Max = authoring.MaxHealth
            });
        }
    }
}
```

## IJobEntity — Paralel İşlem

```csharp
[BurstCompile]
public partial struct MoveJob : IJobEntity
{
    public float DeltaTime;

    void Execute(ref LocalTransform transform, in VelocityComponent velocity)
    {
        transform.Position += velocity.Value * DeltaTime;
    }
}
```

## EntityCommandBuffer

Structural change'ler (add/remove component, destroy) ECB ile yapılır:

```csharp
var ecb = new EntityCommandBuffer(Allocator.TempJob);
ecb.DestroyEntity(entity);
ecb.Playback(state.EntityManager);
ecb.Dispose();
```

## Hybrid Linking

MonoBehaviour ↔ Entity iletişimi için `EntityReference` component veya
`CompanionComponentSystemGroup` kullan.

## IEvent'lerde byte Base

```csharp
// ECS event enum'ları byte base kullanır (cache line optimizasyonu)
public enum EnemyState : byte { Idle, Moving, Attacking, Dead }
```
```

- [ ] **Step 2: addressables.md yaz**

```markdown
# Addressables Rules

> Aktif koşul: `project-config.json` → `"addressables": true`

## Resources.Load Yasak

```csharp
// YANLIŞ
var clip = Resources.Load<AudioClip>("Sounds/explosion");

// DOĞRU
var handle = Addressables.LoadAssetAsync<AudioClip>("Sounds/explosion");
var clip = await handle.Task;
```

## Async Yükleme

```csharp
public async UniTask<AudioClip> LoadClipAsync(string key, CancellationToken ct)
{
    var handle = Addressables.LoadAssetAsync<AudioClip>(key);
    await handle.WithCancellation(ct);

    if (handle.Status != AsyncOperationStatus.Succeeded)
        throw new Exception($"Addressables load failed: {key}");

    return handle.Result;
}
```

## Handle Lifecycle

Yüklenen her asset'in handle'ı takip edilir ve Release edilir:

```csharp
private readonly List<AsyncOperationHandle> _handles = new();

public async UniTask<T> LoadAsync<T>(string key, CancellationToken ct)
{
    var handle = Addressables.LoadAssetAsync<T>(key);
    _handles.Add(handle);
    return await handle.WithCancellation(ct);
}

public void Dispose()
{
    foreach (var h in _handles)
        Addressables.Release(h);
    _handles.Clear();
}
```

## Label ile Batch Yükleme

```csharp
var handle = Addressables.LoadAssetsAsync<Sprite>("ui-icons", null);
var sprites = await handle.WithCancellation(ct);
```
```

- [ ] **Step 3: Verify — Tüm rule dosyaları**

```powershell
Get-ChildItem .claude/rules/ -Filter "*.md" | Select-Object Name | Sort-Object Name
```

Beklenen: 14 dosya — 12 zorunlu + ecs-dots.md + addressables.md

- [ ] **Step 4: Commit**

```bash
git add .claude/rules/ecs-dots.md .claude/rules/addressables.md
git commit -m "feat: add optional ecs-dots and addressables rules"
```

---

**Phase 2 tamamlandı.** Sonraki: Phase 3 — Hooks (15 shell script).
