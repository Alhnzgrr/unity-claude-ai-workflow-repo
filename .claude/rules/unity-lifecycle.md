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
