# Save-Load System Skill

## Purpose

Implement a complete, production-ready save/load system for Unity 6 projects following the
architecture rules in this repository. Produces 5-file module structure, uses UniTask,
VContainer/Zenject DI, IEventBus events, and JSON serialization via Newtonsoft.Json.

## Trigger Conditions

Use this skill when the user asks to:
- Implement a save system / load system / persistence
- Add player progress saving
- Save game state, inventory, settings, or any runtime data
- Implement auto-save or checkpoint saving
- Migrate or upgrade save data

## Output Contract

This skill always produces the full 5-file module:

| File | Location |
|---|---|
| `ISaveLoadService.cs` | `Games/Abstracts/SaveLoad/` |
| `SaveLoadService.cs` | `Games/Concretes/SaveLoad/` |
| `SaveLoadConfiguration.cs` | `Games/Concretes/SaveLoad/` |
| `SaveLoadInstaller.cs` | `Games/Concretes/SaveLoad/` |
| `SaveLoadEvents.cs` | `Games/Concretes/SaveLoad/` |

Optional (generated on request):
- `SaveLoadProvider.cs` — MonoBehaviour bridge (auto-save trigger, lifecycle hooks)
- `SaveDataMigrator.cs` — versioned migration pipeline
- `EditMode tests` — `Tests/EditMode/SaveLoad/SaveLoadServiceTests.cs`

## Architecture Constraints (Non-Negotiable)

- `Resources.Load` is forbidden — use `System.IO.File` or Addressables
- `PlayerPrefs` is forbidden for game data — use file-based JSON
- `UnityEvent` is forbidden — use `IEventBus` + `IEvent` structs
- `async Task` is forbidden — use `UniTask` with `CancellationToken`
- `static` save manager / singleton — forbidden, inject via DI
- `public` fields on save data classes — forbidden, use `[JsonProperty]` on private fields or plain public properties on data-only structs

## Step-by-Step Implementation Plan

### Step 1 — Define the Save Data Shape

Before writing any service code, clarify the data to persist:

```
Ask the user (or infer from context):
1. What domains need persistence? (player stats, inventory, settings, level progress...)
2. Should all domains share one file or separate files per domain?
3. Is cloud sync or multiple save slots required?
4. What happens on corrupt/missing save? (reset to defaults vs. error screen)
```

Example save data structure:

```csharp
// SaveData.cs  (pure C#, no MonoBehaviour, no Unity types)
namespace MyGame.SaveLoad
{
    [Serializable]
    public sealed class SaveData
    {
        [JsonProperty("version")]       public int Version { get; set; } = SaveLoadService.CURRENT_VERSION;
        [JsonProperty("playerStats")]   public PlayerStatsData PlayerStats { get; set; } = new();
        [JsonProperty("settings")]      public SettingsData Settings { get; set; } = new();
        [JsonProperty("levelProgress")] public LevelProgressData LevelProgress { get; set; } = new();
    }

    [Serializable]
    public sealed class PlayerStatsData
    {
        [JsonProperty("level")]   public int Level { get; set; } = 1;
        [JsonProperty("xp")]      public float XP { get; set; }
        [JsonProperty("coins")]   public int Coins { get; set; }
    }

    [Serializable]
    public sealed class SettingsData
    {
        [JsonProperty("masterVolume")] public float MasterVolume { get; set; } = 1f;
        [JsonProperty("sfxVolume")]    public float SfxVolume { get; set; } = 1f;
        [JsonProperty("musicVolume")]  public float MusicVolume { get; set; } = 1f;
        [JsonProperty("language")]     public string Language { get; set; } = "en";
    }

    [Serializable]
    public sealed class LevelProgressData
    {
        [JsonProperty("currentLevel")]   public int CurrentLevel { get; set; } = 1;
        [JsonProperty("unlockedLevels")] public List<int> UnlockedLevels { get; set; } = new() { 1 };
        [JsonProperty("completedLevels")]public HashSet<int> CompletedLevels { get; set; } = new();
    }
}
```

### Step 2 — Interface (`ISaveLoadService.cs`)

```csharp
using Cysharp.Threading.Tasks;
using System.Threading;

namespace MyGame.SaveLoad
{
    public interface ISaveLoadService
    {
        /// <summary>Current in-memory save data. Never null after Initialize.</summary>
        SaveData Current { get; }

        /// <summary>Load from disk. Creates default data if file missing.</summary>
        UniTask InitializeAsync(CancellationToken ct);

        /// <summary>Persist current data to disk immediately.</summary>
        UniTask SaveAsync(CancellationToken ct);

        /// <summary>Reset all data to defaults and save.</summary>
        UniTask ResetAsync(CancellationToken ct);

        /// <summary>True if a save file exists on disk.</summary>
        bool HasSaveFile { get; }
    }
}
```

### Step 3 — Events (`SaveLoadEvents.cs`)

```csharp
namespace MyGame.SaveLoad
{
    public readonly struct SaveStartedEvent : IEvent { }

    public readonly struct SaveCompletedEvent : IEvent
    {
        public readonly bool Success;
        public SaveCompletedEvent(bool success) => Success = success;
    }

    public readonly struct LoadStartedEvent : IEvent { }

    public readonly struct LoadCompletedEvent : IEvent
    {
        public readonly bool Success;
        public readonly bool WasDefaultData;
        public LoadCompletedEvent(bool success, bool wasDefault)
        {
            Success = success;
            WasDefaultData = wasDefault;
        }
    }

    public readonly struct SaveResetEvent : IEvent { }
}
```

### Step 4 — Configuration (`SaveLoadConfiguration.cs`)

```csharp
using UnityEngine;

namespace MyGame.SaveLoad
{
    [CreateAssetMenu(menuName = "MyGame/Config/SaveLoad", fileName = "SaveLoadConfiguration")]
    public sealed class SaveLoadConfiguration : ScriptableObject
    {
        [SerializeField] private string _saveFileName = "save.json";
        [SerializeField] private bool _prettyPrint = false;
        [SerializeField] private bool _enableAutoSave = true;
        [SerializeField] private float _autoSaveIntervalSeconds = 60f;
        [SerializeField] private bool _enableBackup = true;

        public string SaveFileName => _saveFileName;
        public bool PrettyPrint => _prettyPrint;
        public bool EnableAutoSave => _enableAutoSave;
        public float AutoSaveIntervalSeconds => _autoSaveIntervalSeconds;
        public bool EnableBackup => _enableBackup;
    }
}
```

### Step 5 — Service (`SaveLoadService.cs`)

```csharp
using System;
using System.IO;
using System.Threading;
using Cysharp.Threading.Tasks;
using Newtonsoft.Json;
using UnityEngine;

namespace MyGame.SaveLoad
{
    public sealed class SaveLoadService : ISaveLoadService, IDisposable
    {
        // ------------------------------------------------------------------ constants
        public const int CURRENT_VERSION = 1;

        // ------------------------------------------------------------------ fields
        private readonly SaveLoadConfiguration _config;
        private readonly IEventBus _eventBus;
        private readonly CancellationTokenSource _cts = new();

        private string _savePath;
        private string _backupPath;

        // ------------------------------------------------------------------ properties
        public SaveData Current { get; private set; }
        public bool HasSaveFile => File.Exists(_savePath);

        // ------------------------------------------------------------------ constructor
        public SaveLoadService(SaveLoadConfiguration config, IEventBus eventBus)
        {
            _config   = config   ?? throw new ArgumentNullException(nameof(config));
            _eventBus = eventBus ?? throw new ArgumentNullException(nameof(eventBus));

            _savePath   = Path.Combine(Application.persistentDataPath, _config.SaveFileName);
            _backupPath = _savePath + ".bak";
        }

        // ------------------------------------------------------------------ public API
        public async UniTask InitializeAsync(CancellationToken ct)
        {
            var linked = CancellationTokenSource.CreateLinkedTokenSource(_cts.Token, ct);
            _eventBus.Publish(new LoadStartedEvent());

            try
            {
                if (File.Exists(_savePath))
                {
                    var json = await ReadFileAsync(_savePath, linked.Token);
                    Current  = Deserialize(json);
                    Current  = Migrate(Current);

                    _eventBus.Publish(new LoadCompletedEvent(true, false));
                }
                else
                {
                    Current = new SaveData();
                    _eventBus.Publish(new LoadCompletedEvent(true, true));
                }
            }
            catch (Exception ex)
            {
                Debug.LogWarning($"[SaveLoad] Load failed: {ex.Message}. Trying backup...");
                Current = await TryLoadBackupAsync(linked.Token);
                _eventBus.Publish(new LoadCompletedEvent(Current != null, Current == null));
                Current ??= new SaveData();
            }
        }

        public async UniTask SaveAsync(CancellationToken ct)
        {
            var linked = CancellationTokenSource.CreateLinkedTokenSource(_cts.Token, ct);
            _eventBus.Publish(new SaveStartedEvent());

            try
            {
                var json = Serialize(Current);

                if (_config.EnableBackup && File.Exists(_savePath))
                    File.Copy(_savePath, _backupPath, overwrite: true);

                await WriteFileAsync(_savePath, json, linked.Token);
                _eventBus.Publish(new SaveCompletedEvent(true));
            }
            catch (Exception ex)
            {
                Debug.LogError($"[SaveLoad] Save failed: {ex.Message}");
                _eventBus.Publish(new SaveCompletedEvent(false));
            }
        }

        public async UniTask ResetAsync(CancellationToken ct)
        {
            Current = new SaveData();
            await SaveAsync(ct);
            _eventBus.Publish(new SaveResetEvent());
        }

        public void Dispose() => _cts.Cancel();

        // ------------------------------------------------------------------ private helpers
        private string Serialize(SaveData data)
        {
            var settings = new JsonSerializerSettings
            {
                Formatting = _config.PrettyPrint ? Formatting.Indented : Formatting.None,
                NullValueHandling = NullValueHandling.Ignore
            };
            return JsonConvert.SerializeObject(data, settings);
        }

        private SaveData Deserialize(string json)
        {
            return JsonConvert.DeserializeObject<SaveData>(json) ?? new SaveData();
        }

        private SaveData Migrate(SaveData data)
        {
            // Version migration chain — extend as CURRENT_VERSION increments
            // if (data.Version < 2) MigrateV1ToV2(data);
            // if (data.Version < 3) MigrateV2ToV3(data);
            data.Version = CURRENT_VERSION;
            return data;
        }

        private async UniTask<SaveData> TryLoadBackupAsync(CancellationToken ct)
        {
            if (!File.Exists(_backupPath)) return null;

            try
            {
                var json = await ReadFileAsync(_backupPath, ct);
                return Deserialize(json);
            }
            catch
            {
                return null;
            }
        }

        private static async UniTask<string> ReadFileAsync(string path, CancellationToken ct)
        {
            await UniTask.SwitchToThreadPool();
            var content = File.ReadAllText(path);
            await UniTask.SwitchToMainThread(cancellationToken: ct);
            return content;
        }

        private static async UniTask WriteFileAsync(string path, string content, CancellationToken ct)
        {
            await UniTask.SwitchToThreadPool();
            File.WriteAllText(path, content);
            await UniTask.SwitchToMainThread(cancellationToken: ct);
        }
    }
}
```

### Step 6 — Installer

#### VContainer Variant (`SaveLoadInstaller.cs`)

```csharp
using VContainer;

namespace MyGame.SaveLoad
{
    public static class SaveLoadInstaller
    {
        public static void Install(IContainerBuilder builder, SaveLoadConfiguration config)
        {
            builder.RegisterInstance(config);
            builder.Register<SaveLoadService>(Lifetime.Singleton).As<ISaveLoadService>();
        }
    }
}
```

Register inside your `AppScope`:

```csharp
protected override void Configure(IContainerBuilder builder)
{
    SaveLoadInstaller.Install(builder, _saveLoadConfig);
}
```

#### Zenject Variant (`SaveLoadInstaller.cs`)

```csharp
using Zenject;
using UnityEngine;

namespace MyGame.SaveLoad
{
    public class SaveLoadInstaller : MonoInstaller
    {
        [SerializeField] private SaveLoadConfiguration _config;

        public override void InstallBindings()
        {
            Container.BindInstance(_config).AsSingle();
            Container.Bind<ISaveLoadService>().To<SaveLoadService>().AsSingle();
        }
    }
}
```

### Step 7 — Provider (Auto-Save, Optional)

```csharp
using System.Threading;
using Cysharp.Threading.Tasks;
using UnityEngine;
using VContainer;

namespace MyGame.SaveLoad
{
    public sealed class SaveLoadProvider : MonoBehaviour
    {
        private ISaveLoadService _saveLoadService;
        private SaveLoadConfiguration _config;

        [Inject]
        void Construct(ISaveLoadService saveLoadService, SaveLoadConfiguration config)
        {
            _saveLoadService = saveLoadService;
            _config          = config;
        }

        private async void Start()
        {
            await _saveLoadService.InitializeAsync(destroyCancellationToken);

            if (_config.EnableAutoSave)
                StartAutoSaveLoop(destroyCancellationToken).Forget();
        }

        private void OnApplicationPause(bool paused)
        {
            if (paused)
                _saveLoadService.SaveAsync(destroyCancellationToken).Forget();
        }

        private void OnApplicationQuit()
        {
            _saveLoadService.SaveAsync(CancellationToken.None).Forget();
        }

        private async UniTaskVoid StartAutoSaveLoop(CancellationToken ct)
        {
            while (!ct.IsCancellationRequested)
            {
                await UniTask.Delay(
                    (int)(_config.AutoSaveIntervalSeconds * 1000),
                    cancellationToken: ct);

                await _saveLoadService.SaveAsync(ct);
            }
        }
    }
}
```

## Testing Template

```csharp
using NUnit.Framework;
using NSubstitute;
using Cysharp.Threading.Tasks;
using System.Threading;

namespace MyGame.SaveLoad.Tests
{
    [TestFixture]
    public class SaveLoadServiceTests
    {
        private SaveLoadService _sut;
        private IEventBus _eventBus;
        private SaveLoadConfiguration _config;

        [SetUp]
        public void SetUp()
        {
            _eventBus = Substitute.For<IEventBus>();
            _config   = ScriptableObject.CreateInstance<SaveLoadConfiguration>();
            _sut      = new SaveLoadService(_config, _eventBus);
        }

        [TearDown]
        public void TearDown() => _sut.Dispose();

        [Test]
        public async Task InitializeAsync_NoFile_CreatesDefaultData()
        {
            // Arrange — ensure no file exists in temp path (test uses unique filename)

            // Act
            await _sut.InitializeAsync(CancellationToken.None);

            // Assert
            Assert.IsNotNull(_sut.Current);
            Assert.AreEqual(SaveLoadService.CURRENT_VERSION, _sut.Current.Version);
            _eventBus.Received(1).Publish(Arg.Any<LoadStartedEvent>());
            _eventBus.Received(1).Publish(Arg.Is<LoadCompletedEvent>(e => e.WasDefaultData));
        }

        [Test]
        public async Task SaveAsync_PublishesSaveEvents()
        {
            // Arrange
            await _sut.InitializeAsync(CancellationToken.None);

            // Act
            await _sut.SaveAsync(CancellationToken.None);

            // Assert
            _eventBus.Received(1).Publish(Arg.Any<SaveStartedEvent>());
            _eventBus.Received(1).Publish(Arg.Is<SaveCompletedEvent>(e => e.Success));
        }

        [Test]
        public async Task ResetAsync_ResetsDataToDefaults()
        {
            // Arrange
            await _sut.InitializeAsync(CancellationToken.None);
            _sut.Current.PlayerStats.Level = 99;

            // Act
            await _sut.ResetAsync(CancellationToken.None);

            // Assert
            Assert.AreEqual(1, _sut.Current.PlayerStats.Level);
            _eventBus.Received(1).Publish(Arg.Any<SaveResetEvent>());
        }
    }
}
```

## Common Patterns & Pitfalls

### Accessing Save Data from Other Services

Other services receive `ISaveLoadService` via constructor injection, then read/write `Current`:

```csharp
public sealed class PlayerService : IPlayerService
{
    private readonly ISaveLoadService _saveLoad;

    public PlayerService(ISaveLoadService saveLoad) => _saveLoad = saveLoad;

    public void AddCoins(int amount)
    {
        _saveLoad.Current.PlayerStats.Coins += amount;
        // Actual persistence happens on SaveAsync call — do not call SaveAsync here every time
    }
}
```

### Save vs. Flush Strategy

Do NOT call `SaveAsync` after every stat change — it hammers disk I/O.
Three valid save triggers:
1. Auto-save loop (interval-based, via `SaveLoadProvider`)
2. Scene transition / level completion event listener
3. `OnApplicationPause` + `OnApplicationQuit` (handled in `SaveLoadProvider`)

### Corrupt File Recovery

The service automatically tries the `.bak` file on deserialization failure.
If both are corrupt, it resets to defaults and logs a warning — never crashes.

### Multiple Save Slots

Extend `SaveLoadConfiguration` with a `_currentSlotIndex` field.
Compute `_savePath` as `save_{slotIndex}.json` inside `SaveLoadService`.
Expose a `SetSlot(int index)` method on the interface.

## Checklist Before Delivery

- [ ] `ISaveLoadService` interface defined with `Current`, `InitializeAsync`, `SaveAsync`, `ResetAsync`, `HasSaveFile`
- [ ] `SaveData` class contains all required domain sub-objects with `[JsonProperty]` attributes
- [ ] Events: `SaveStartedEvent`, `SaveCompletedEvent`, `LoadStartedEvent`, `LoadCompletedEvent`, `SaveResetEvent`
- [ ] `SaveLoadConfiguration` ScriptableObject with fileName, prettyPrint, autoSave, backup flags
- [ ] File I/O runs on ThreadPool (`UniTask.SwitchToThreadPool`), result consumed on MainThread
- [ ] Backup file created before overwrite when `EnableBackup` is true
- [ ] Version field on `SaveData` with `Migrate()` method stub
- [ ] DI installer written for the detected container (VContainer or Zenject)
- [ ] `SaveLoadProvider` included if auto-save or lifecycle hooks are needed
- [ ] EditMode tests cover: default creation, save events, reset behavior
- [ ] No `PlayerPrefs`, no `Resources.Load`, no `UnityEvent`, no `Task`, no `static`
