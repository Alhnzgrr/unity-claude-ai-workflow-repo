# Unity Lifecycle Rules

## Lifecycle Discipline

| Method | Usage |
|---|---|
| `Awake()` | Local reference init, GetComponent (self only) |
| `OnEnable()` | Event subscribe, listener registration |
| `OnDisable()` | Event unsubscribe, listener cancellation |
| `Start()` | Simple initialization ONLY — NOT setup recovery |

```csharp
// CORRECT
void Awake() => _rb = GetComponent<Rigidbody>();
void OnEnable() => _eventBus.Subscribe<PlayerDiedEvent>(OnPlayerDied);
void OnDisable() => _eventBus.Unsubscribe<PlayerDiedEvent>(OnPlayerDied);

// WRONG — searching for dependency in Start
void Start() { _service = FindObjectOfType<AudioService>(); }
```

## UnityEditor Guard

Using the `UnityEditor` namespace in runtime code is blocked by the hook.
If required:

```csharp
#if UNITY_EDITOR
using UnityEditor;
// editor-only code
#endif
```

## Threading Rules

- Unity API is called from the main thread only
- UI updates from a background thread → `UniTask.SwitchToMainThread()`

```csharp
await UniTask.SwitchToThreadPool();
var data = await LoadHeavyDataAsync();
await UniTask.SwitchToMainThread();
_textComponent.text = data.ToString(); // safe on main thread
```

## Time Rules

- `Time.timeScale` assignment is forbidden (hook blocks it) — publish an event instead
- `Time.deltaTime` can be cached each frame in hot paths

## Platform Defines

```csharp
#if UNITY_ANDROID || UNITY_IOS
    // mobile code
#elif UNITY_STANDALONE
    // PC code
#endif
```
