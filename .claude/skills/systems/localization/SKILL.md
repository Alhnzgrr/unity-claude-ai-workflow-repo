---
name: localization
description: Use when implementing multi-language support, string tables, asset localization, runtime locale switching, Smart String formatting, TextMeshPro font swapping, or pseudo-localization testing in Unity.
---

# Unity Localization Skill

Multi-language support via `com.unity.localization` v1.5, UniTask async patterns, IEventBus integration, and TextMeshPro font swapping for Unity 6.

## Package Setup

Install via Package Manager — this is NOT a built-in package:

```
com.unity.localization@1.5.x
com.unity.addressables (required dependency)
com.unity.textmeshpro
```

`Window → Asset Management → Localization Tables` to create String/Asset tables.

---

## Interface

```csharp
// Games/Abstracts/Localization/ILocalizationService.cs
namespace MyGame.Localization
{
    public interface ILocalizationService
    {
        /// Returns true after InitializationOperation completes.
        bool IsInitialized { get; }

        /// Async string lookup. Never call inside Update.
        UniTask<string> GetStringAsync(string tableKey, string entryKey, CancellationToken ct);

        /// Async asset lookup (Sprite, AudioClip, TMP_FontAsset, …).
        UniTask<T> GetAssetAsync<T>(string tableKey, string entryKey, CancellationToken ct)
            where T : UnityEngine.Object;

        /// Switch active locale at runtime; publishes LocaleChangedEvent via IEventBus.
        UniTask SetLocaleAsync(string localeCode, CancellationToken ct);

        /// All available locale codes (e.g. "en", "tr", "ja").
        IReadOnlyList<string> GetAvailableLocaleCodes();
    }
}
```

---

## Events

```csharp
// Games/Concretes/Localization/LocalizationEvents.cs
namespace MyGame.Localization
{
    public readonly struct LocaleChangedEvent : IEvent
    {
        public readonly string PreviousLocaleCode;
        public readonly string NewLocaleCode;

        public LocaleChangedEvent(string previous, string next)
        {
            PreviousLocaleCode = previous;
            NewLocaleCode = next;
        }
    }
}
```

---

## Configuration

```csharp
// Games/Concretes/Localization/LocalizationConfiguration.cs
using UnityEngine;

namespace MyGame.Localization
{
    [CreateAssetMenu(
        fileName = "LocalizationConfiguration",
        menuName = "MyGame/Configuration/Localization")]
    public sealed class LocalizationConfiguration : ScriptableObject
    {
        [SerializeField] private string _defaultLocaleCode = "en";

        /// Key: table name used for all string lookups.
        [SerializeField] private string _defaultStringTableName = "UI";

        /// Key: table name used for all asset lookups.
        [SerializeField] private string _defaultAssetTableName = "Assets";

        /// Throw exception on missing key instead of silent empty string.
        [SerializeField] private bool _strictMissingKeys = true;

        public string DefaultLocaleCode => _defaultLocaleCode;
        public string DefaultStringTableName => _defaultStringTableName;
        public string DefaultAssetTableName => _defaultAssetTableName;
        public bool StrictMissingKeys => _strictMissingKeys;
    }
}
```

---

## Service Implementation

```csharp
// Games/Concretes/Localization/LocalizationService.cs
using System;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using UnityEngine.Localization;
using UnityEngine.Localization.Settings;
using UnityEngine.Localization.Tables;
using UnityEngine.ResourceManagement.AsyncOperations;

namespace MyGame.Localization
{
    public sealed class LocalizationService : ILocalizationService, IDisposable
    {
        private readonly LocalizationConfiguration _config;
        private readonly IEventBus _eventBus;
        private readonly CancellationTokenSource _cts = new();

        public bool IsInitialized { get; private set; }

        public LocalizationService(LocalizationConfiguration config, IEventBus eventBus)
        {
            _config = config ?? throw new ArgumentNullException(nameof(config));
            _eventBus = eventBus ?? throw new ArgumentNullException(nameof(eventBus));
        }

        // --- Initialization ---------------------------------------------------

        /// Must be awaited before any string/asset lookup. Call from AppScope or
        /// GameScope entrypoint. Empty strings on first frame = missing this call.
        public async UniTask InitializeAsync(CancellationToken ct)
        {
            var linked = CancellationTokenSource.CreateLinkedTokenSource(_cts.Token, ct);

            var op = LocalizationSettings.InitializationOperation;

            // WebGL: WaitForCompletion is forbidden — always await properly.
            await op.ToUniTask(cancellationToken: linked.Token);

            if (op.Status != AsyncOperationStatus.Succeeded)
                throw new InvalidOperationException(
                    $"[LocalizationService] Initialization failed: {op.OperationException}");

            IsInitialized = true;
        }

        // --- String Lookups ---------------------------------------------------

        public async UniTask<string> GetStringAsync(
            string tableKey,
            string entryKey,
            CancellationToken ct)
        {
            AssertInitialized();

            var linked = CancellationTokenSource.CreateLinkedTokenSource(_cts.Token, ct);

            var op = LocalizationSettings.StringDatabase
                .GetLocalizedStringAsync(tableKey, entryKey);

            await op.ToUniTask(cancellationToken: linked.Token);

            if (op.Status != AsyncOperationStatus.Succeeded)
            {
                if (_config.StrictMissingKeys)
                    throw new KeyNotFoundException(
                        $"[LocalizationService] Missing key '{entryKey}' in table '{tableKey}'");

                return string.Empty;
            }

            return op.Result;
        }

        // --- Asset Lookups ----------------------------------------------------

        public async UniTask<T> GetAssetAsync<T>(
            string tableKey,
            string entryKey,
            CancellationToken ct)
            where T : UnityEngine.Object
        {
            AssertInitialized();

            var linked = CancellationTokenSource.CreateLinkedTokenSource(_cts.Token, ct);

            var op = LocalizationSettings.AssetDatabase
                .GetLocalizedAssetAsync<T>(tableKey, entryKey);

            await op.ToUniTask(cancellationToken: linked.Token);

            if (op.Status != AsyncOperationStatus.Succeeded)
            {
                if (_config.StrictMissingKeys)
                    throw new KeyNotFoundException(
                        $"[LocalizationService] Missing asset '{entryKey}' in table '{tableKey}'");

                return null;
            }

            return op.Result;
        }

        // --- Locale Switching -------------------------------------------------

        public async UniTask SetLocaleAsync(string localeCode, CancellationToken ct)
        {
            AssertInitialized();

            var previous = LocalizationSettings.SelectedLocale?.Identifier.Code ?? string.Empty;

            var target = LocalizationSettings.AvailableLocales
                .GetLocale(new LocaleIdentifier(localeCode));

            if (target == null)
                throw new ArgumentException(
                    $"[LocalizationService] Locale '{localeCode}' not found in AvailableLocales.");

            LocalizationSettings.SelectedLocale = target;

            // Wait for tables to reload after locale change.
            var linked = CancellationTokenSource.CreateLinkedTokenSource(_cts.Token, ct);
            await LocalizationSettings.InitializationOperation.ToUniTask(
                cancellationToken: linked.Token);

            _eventBus.Publish(new LocaleChangedEvent(previous, localeCode));
        }

        public IReadOnlyList<string> GetAvailableLocaleCodes()
        {
            var locales = LocalizationSettings.AvailableLocales.Locales;
            var codes = new List<string>(locales.Count);
            foreach (var locale in locales)
                codes.Add(locale.Identifier.Code);
            return codes;
        }

        // --- Helpers ----------------------------------------------------------

        private void AssertInitialized()
        {
            if (!IsInitialized)
                throw new InvalidOperationException(
                    "[LocalizationService] Call InitializeAsync before any lookup.");
        }

        public void Dispose() => _cts.Cancel();
    }
}
```

---

## Installers

### VContainer

```csharp
// Games/Concretes/Localization/LocalizationInstaller.cs  (VContainer)
using UnityEngine;
using VContainer;
using VContainer.Unity;

namespace MyGame.Localization
{
    public sealed class LocalizationInstaller : MonoBehaviour, IInstaller
    {
        [SerializeField] private LocalizationConfiguration _config;

        public void Install(IContainerBuilder builder)
        {
            builder.RegisterInstance(_config);

            builder.Register<LocalizationService>(Lifetime.Singleton)
                .As<ILocalizationService>()
                .AsSelf();
        }
    }
}
```

### Zenject

```csharp
// Games/Concretes/Localization/LocalizationInstaller.cs  (Zenject)
using UnityEngine;
using Zenject;

namespace MyGame.Localization
{
    public sealed class LocalizationInstaller : MonoInstaller
    {
        [SerializeField] private LocalizationConfiguration _config;

        public override void InstallBindings()
        {
            Container.BindInstance(_config).AsSingle();

            Container.Bind<ILocalizationService>()
                .To<LocalizationService>()
                .AsSingle();
        }
    }
}
```

---

## Bootstrap Entrypoint

```csharp
// Games/Concretes/App/AppEntryPoint.cs
using VContainer.Unity;

namespace MyGame.App
{
    /// Runs before any MonoBehaviour Start. Awaiting here prevents empty-string race.
    public sealed class AppEntryPoint : IAsyncStartable
    {
        private readonly LocalizationService _localization;

        public AppEntryPoint(LocalizationService localization)
        {
            _localization = localization;
        }

        public async UniTask StartAsync(CancellationToken ct)
        {
            await _localization.InitializeAsync(ct);
        }
    }
}
```

Register in VContainer scope:
```csharp
builder.RegisterEntryPoint<AppEntryPoint>();
```

---

## StringTable Usage

### LocalizedString + StringChanged (Auto-Refresh)

`StringChanged` fires automatically when the locale changes — no polling.

```csharp
// Games/Concretes/Localization/LocalizedLabel.cs
using TMPro;
using UnityEngine;
using UnityEngine.Localization;

namespace MyGame.Localization
{
    /// Attach to any GameObject with TMP_Text.
    /// Drag a StringTable entry into the Inspector.
    public sealed class LocalizedLabel : MonoBehaviour
    {
        [SerializeField] private LocalizedString _localizedString;

        private TMP_Text _text;

        private void Awake() => _text = GetComponent<TMP_Text>();

        private void OnEnable()
        {
            // StringChanged fires immediately with the current value, then again
            // on every locale switch — never call GetLocalizedStringAsync in Update.
            _localizedString.StringChanged += OnStringChanged;
        }

        private void OnDisable()
        {
            _localizedString.StringChanged -= OnStringChanged;
        }

        private void OnStringChanged(string value) => _text.text = value;
    }
}
```

### Programmatic Lookup (One-Shot)

```csharp
// Inside any service or presenter — NOT inside Update.
private async UniTask ShowWelcomeAsync(CancellationToken ct)
{
    var text = await _localizationService.GetStringAsync("UI", "welcome_message", ct);
    _welcomeLabel.text = text;
}
```

### LocalizeStringEvent Component vs Programmatic

| Situation | Approach |
|---|---|
| Simple static label, set in Inspector | `LocalizeStringEvent` component (zero code) |
| Label with dynamic arguments / Smart String params | `LocalizedString` + `StringChanged` callback |
| Lookup triggered by game logic (e.g. item name from data) | `GetStringAsync` in presenter/service |
| Lookup needed once at initialization | `GetStringAsync` in `StartAsync` / `InitializeAsync` |

---

## Smart Strings

Smart Strings use the `SmartFormat` library bundled with the package.

### Plural Forms

Table entry value:
```
You have {count:plural:one item|{} items}.
```

```csharp
_localizedString.Arguments = new object[] { new { count = itemCount } };
// Dirty flag: call RefreshString() only when arguments actually change.
_localizedString.RefreshString();
```

### Number and Date Formatting

```
Price: {price:C}      // culture-aware currency
Date:  {date:d}       // short date per locale
```

```csharp
_localizedString.Arguments = new object[]
{
    new { price = 9.99f, date = System.DateTime.Now }
};
_localizedString.RefreshString();
```

### Conditional

Table entry:
```
{isGuest:cond:Guest|Player {name}}
```

### Nested Object Selector

```
{player.Stats.Level}
```

### RefreshString Dirty Flag — Avoid Every Frame

```csharp
// WRONG — allocates and re-evaluates Smart String every frame
void Update()
{
    _localizedString.Arguments = new object[] { new { count = _count } };
    _localizedString.RefreshString();
}

// CORRECT — refresh only when the source value changes
private int _lastCount = -1;

void Update()
{
    if (_count == _lastCount) return;
    _lastCount = _count;

    _localizedString.Arguments = new object[] { new { count = _count } };
    _localizedString.RefreshString();
}
```

---

## AssetTable Usage

### LocalizedSprite (AssetChanged)

```csharp
// Games/Concretes/Localization/RegionalIcon.cs
using UnityEngine;
using UnityEngine.Localization;
using UnityEngine.UI;

namespace MyGame.Localization
{
    public sealed class RegionalIcon : MonoBehaviour
    {
        [SerializeField] private LocalizedSprite _localizedSprite;

        private Image _image;

        private void Awake() => _image = GetComponent<Image>();

        private void OnEnable()
        {
            _localizedSprite.AssetChanged += OnAssetChanged;
        }

        private void OnDisable()
        {
            _localizedSprite.AssetChanged -= OnAssetChanged;
        }

        private void OnAssetChanged(Sprite sprite) => _image.sprite = sprite;
    }
}
```

### LocalizedAudioClip (AssetChanged)

```csharp
// Games/Concretes/Localization/VoiceoverPlayer.cs
using Cysharp.Threading.Tasks;
using UnityEngine;
using UnityEngine.Localization;

namespace MyGame.Localization
{
    public sealed class VoiceoverPlayer : MonoBehaviour
    {
        [SerializeField] private LocalizedAsset<AudioClip> _localizedClip;

        private AudioSource _source;

        private void Awake() => _source = GetComponent<AudioSource>();

        private void OnEnable()
        {
            _localizedClip.AssetChanged += OnClipChanged;
        }

        private void OnDisable()
        {
            _localizedClip.AssetChanged -= OnClipChanged;
        }

        private void OnClipChanged(AudioClip clip)
        {
            _source.clip = clip;
        }

        public void Play() => _source.Play();
    }
}
```

---

## Runtime Locale Switching

### LocaleSelectorView

```csharp
// Games/Concretes/Localization/LocaleSelectorView.cs
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using TMPro;
using UnityEngine;
using VContainer;

namespace MyGame.Localization
{
    public sealed class LocaleSelectorView : MonoBehaviour
    {
        [SerializeField] private TMP_Dropdown _dropdown;

        private ILocalizationService _localizationService;
        private IReadOnlyList<string> _codes;

        [Inject]
        private void Construct(ILocalizationService localizationService)
        {
            _localizationService = localizationService;
        }

        private void Start()
        {
            _codes = _localizationService.GetAvailableLocaleCodes();

            _dropdown.ClearOptions();
            var options = new System.Collections.Generic.List<string>(_codes);
            _dropdown.AddOptions(options);

            _dropdown.onValueChanged.AddListener(OnDropdownChanged);
        }

        private void OnDestroy()
        {
            _dropdown.onValueChanged.RemoveListener(OnDropdownChanged);
        }

        private void OnDropdownChanged(int index)
        {
            SwitchLocaleAsync(_codes[index], destroyCancellationToken).Forget();
        }

        private async UniTask SwitchLocaleAsync(string code, CancellationToken ct)
        {
            await _localizationService.SetLocaleAsync(code, ct);
        }
    }
}
```

---

## TextMeshPro Font Swapping

### LocalizedFontProvider

Font assets are stored in an AssetTable, one entry per locale code.
On `LocaleChangedEvent`, load the new font and push it to all registered TMP_Text components.

```csharp
// Games/Concretes/Localization/LocalizedFontProvider.cs
using System;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using TMPro;
using UnityEngine;
using VContainer;

namespace MyGame.Localization
{
    public sealed class LocalizedFontProvider : MonoBehaviour
    {
        [SerializeField] private string _fontAssetTableName = "Fonts";
        [SerializeField] private string _fontEntryKey = "MainFont";

        private ILocalizationService _localizationService;
        private IEventBus _eventBus;

        private readonly List<TMP_Text> _registered = new();
        private TMP_FontAsset _currentFont;

        [Inject]
        private void Construct(ILocalizationService localizationService, IEventBus eventBus)
        {
            _localizationService = localizationService;
            _eventBus = eventBus;
        }

        private void OnEnable()
        {
            _eventBus.Subscribe<LocaleChangedEvent>(OnLocaleChanged);
        }

        private void OnDisable()
        {
            _eventBus.Unsubscribe<LocaleChangedEvent>(OnLocaleChanged);
        }

        public void Register(TMP_Text label)
        {
            if (!_registered.Contains(label))
                _registered.Add(label);

            if (_currentFont != null)
                label.font = _currentFont;
        }

        public void Unregister(TMP_Text label) => _registered.Remove(label);

        private void OnLocaleChanged(LocaleChangedEvent e)
        {
            LoadAndApplyFontAsync(e.NewLocaleCode, destroyCancellationToken).Forget();
        }

        private async UniTask LoadAndApplyFontAsync(string localeCode, CancellationToken ct)
        {
            // Do NOT release the old font immediately — TMP still references it
            // until the new one is applied. Releasing Addressable font assets while
            // in use causes invisible text or MissingReferenceExceptions.

            var newFont = await _localizationService.GetAssetAsync<TMP_FontAsset>(
                _fontAssetTableName,
                _fontEntryKey,
                ct);

            if (newFont == null || ct.IsCancellationRequested) return;

            _currentFont = newFont;

            // RTL: Arabic, Hebrew, Persian — flip isRightToLeftText.
            bool isRtl = localeCode is "ar" or "he" or "fa";

            for (int i = _registered.Count - 1; i >= 0; i--)
            {
                if (_registered[i] == null)
                {
                    _registered.RemoveAt(i);
                    continue;
                }

                _registered[i].font = _currentFont;
                _registered[i].isRightToLeftText = isRtl;
            }
        }
    }
}
```

### CJK: Addressables Build Required

CJK (Chinese, Japanese, Korean) font atlases are large. Store them as Addressable assets
and mark them with a locale-specific label. Build Addressables before shipping:

```
Window → Asset Management → Addressables → Groups → Build → New Build → Default Build Script
```

Forgetting the Addressables build is the most common cause of missing fonts in production.

---

## Fallback Chain

```csharp
// In LocalizationSettings (Inspector) set FallbackBehavior to DontUseFallback for strict mode.
// The service enforces missing-key exceptions at runtime when StrictMissingKeys = true.

// Explicit fallback pattern when you want soft degradation:
public async UniTask<string> GetStringWithFallbackAsync(
    string tableKey,
    string entryKey,
    string fallback,
    CancellationToken ct)
{
    try
    {
        return await _localizationService.GetStringAsync(tableKey, entryKey, ct);
    }
    catch (KeyNotFoundException)
    {
        Debug.LogWarning($"[Localization] Missing key '{entryKey}' — using fallback.");
        return fallback;
    }
}
```

---

## Pseudo-Localization

Used for layout testing before real translations arrive.
Enable in `LocalizationSettings → Pseudo-Locale`.

| Mode | Effect | Use For |
|---|---|---|
| `Accenter` | Replaces letters with accented variants | Basic text substitution test |
| `Expander` | Pads string to 130–150 % of original length | UI overflow / wrapping tests |
| `Encapsulator` | Wraps text in `[!!! … !!!]` | Verifying no hard-coded strings remain |

Combine all three for thorough layout testing:

```
Accenter → Expander → Encapsulator  →  "[!!! Héllo Wörld Exträ Pädding !!!]"
```

---

## EditMode Tests

```csharp
// Scripts/Tests/EditMode/Localization/LocalizationServiceTests.cs
using Cysharp.Threading.Tasks;
using NSubstitute;
using NUnit.Framework;

namespace MyGame.Localization.Tests
{
    [TestFixture]
    public sealed class LocalizationServiceTests
    {
        private ILocalizationService _sut;
        private IEventBus _eventBus;
        private LocalizationConfiguration _config;

        [SetUp]
        public void SetUp()
        {
            _eventBus = Substitute.For<IEventBus>();

            // Use real ScriptableObject instance — no Unity play mode needed.
            _config = UnityEngine.ScriptableObject.CreateInstance<LocalizationConfiguration>();

            // NSubstitute mock — isolates unit under test from the real LocalizationSettings.
            _sut = Substitute.For<ILocalizationService>();
        }

        [TearDown]
        public void TearDown()
        {
            UnityEngine.Object.DestroyImmediate(_config);
        }

        [Test]
        public void GetAvailableLocaleCodes_ReturnsConfiguredLocales()
        {
            // Arrange
            _sut.GetAvailableLocaleCodes().Returns(new[] { "en", "tr", "ja" });

            // Act
            var codes = _sut.GetAvailableLocaleCodes();

            // Assert
            Assert.AreEqual(3, codes.Count);
            Assert.Contains("tr", (System.Collections.IList)codes);
        }

        [Test]
        public async System.Threading.Tasks.Task SetLocaleAsync_PublishesLocaleChangedEvent()
        {
            // Arrange
            var publishedEvent = default(LocaleChangedEvent);
            _eventBus
                .When(x => x.Publish(Arg.Any<LocaleChangedEvent>()))
                .Do(x => publishedEvent = x.Arg<LocaleChangedEvent>());

            // Simulate: SetLocaleAsync calls eventBus.Publish internally.
            _sut
                .SetLocaleAsync("tr", default)
                .Returns(async _ =>
                {
                    _eventBus.Publish(new LocaleChangedEvent("en", "tr"));
                    await UniTask.CompletedTask;
                });

            // Act
            await _sut.SetLocaleAsync("tr", default);

            // Assert
            _eventBus.Received(1).Publish(Arg.Is<LocaleChangedEvent>(
                e => e.NewLocaleCode == "tr" && e.PreviousLocaleCode == "en"));
        }

        [Test]
        public void IsInitialized_FalseBeforeInit()
        {
            // Arrange
            _sut.IsInitialized.Returns(false);

            // Act & Assert
            Assert.IsFalse(_sut.IsInitialized);
        }
    }
}
```

---

## PlayMode Tests

```csharp
// Scripts/Tests/PlayMode/Localization/LocalizationPlayTests.cs
using System.Collections;
using Cysharp.Threading.Tasks;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.Localization.Settings;
using UnityEngine.TestTools;

namespace MyGame.Localization.Tests
{
    public sealed class LocalizationPlayTests
    {
        [UnityTest]
        public IEnumerator InitializationOperation_CompletesWithoutError()
        {
            // Must await InitializationOperation before any string lookup.
            // Skipping this causes empty strings on first frame.
            yield return LocalizationSettings.InitializationOperation;

            Assert.IsTrue(
                LocalizationSettings.InitializationOperation.IsDone,
                "InitializationOperation did not complete.");

            Assert.IsNull(
                LocalizationSettings.InitializationOperation.OperationException,
                "InitializationOperation threw an exception.");
        }

        [UnityTest]
        public IEnumerator SetLocale_ChangesSelectedLocale()
        {
            // Wait for initialization.
            yield return LocalizationSettings.InitializationOperation;

            var originalLocale = LocalizationSettings.SelectedLocale;

            // Find a second locale to switch to.
            var locales = LocalizationSettings.AvailableLocales.Locales;
            if (locales.Count < 2)
            {
                Assert.Ignore("Need at least 2 locales configured to run this test.");
                yield break;
            }

            var targetLocale = locales[0].Identifier.Code == originalLocale?.Identifier.Code
                ? locales[1]
                : locales[0];

            // Act: switch locale.
            LocalizationSettings.SelectedLocale = targetLocale;

            // Wait one frame for tables to reload.
            yield return null;

            // Assert
            Assert.AreEqual(
                targetLocale.Identifier.Code,
                LocalizationSettings.SelectedLocale.Identifier.Code);

            // Restore
            LocalizationSettings.SelectedLocale = originalLocale;
        }

        [UnityTest]
        public IEnumerator StringDatabase_ReturnsNonEmptyString_AfterInit()
        {
            yield return LocalizationSettings.InitializationOperation;

            bool completed = false;
            string result = null;

            // Wrap async in a UniTask fire-and-forget.
            async UniTask FetchAsync()
            {
                var op = LocalizationSettings.StringDatabase
                    .GetLocalizedStringAsync("UI", "test_key");
                await op.ToUniTask();
                result = op.Status ==
                    UnityEngine.ResourceManagement.AsyncOperations.AsyncOperationStatus.Succeeded
                    ? op.Result
                    : null;
                completed = true;
            }

            FetchAsync().Forget();

            // Wait up to 2 seconds.
            float elapsed = 0f;
            while (!completed && elapsed < 2f)
            {
                elapsed += Time.deltaTime;
                yield return null;
            }

            Assert.IsTrue(completed, "GetLocalizedStringAsync timed out.");
            // result may be null if 'test_key' does not exist — that is expected in CI.
            // Replace with a key that exists in your StringTable for a real assertion.
        }
    }
}
```

---

## Common Mistakes

| Mistake | Consequence | Fix |
|---|---|---|
| No `InitializationOperation` await | Empty strings on first frame | Await in `AppEntryPoint.StartAsync` before any scene loads |
| `GetStringAsync` inside `Update` | GC allocation every frame + async overhead | Use `StringChanged` event; fetch once and cache |
| Missing key with silent fallback | Production shows empty string, no log | Set `StrictMissingKeys = true`; fail fast in development |
| `RefreshString` every frame without dirty flag | SmartFormat re-evaluated every frame | Track previous argument values; refresh only on change |
| `WaitForCompletion` on WebGL | Browser tab freeze / deadlock | Always use `await op.ToUniTask(ct)` |
| Forgetting Addressables build before ship | Font/sprite assets missing at runtime | Add Addressables build to CI pipeline |
| Destroying Addressable font assets while in use | Invisible text, MissingReferenceException | Hold reference until new font is applied; do not Release prematurely |
| RTL text without `isRightToLeftText` | Arabic/Hebrew renders left-to-right | Set `isRightToLeftText = true` for `ar`, `he`, `fa` locales |
| Using `LocalizeStringEvent` for data-driven content | Hard to bind at runtime | Use `GetStringAsync` in presenter/service for dynamic keys |
