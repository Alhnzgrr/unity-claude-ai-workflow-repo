---
name: textmeshpro
description: Use when implementing or reviewing TextMeshPro labels, TMP_Text updates, font assets, fallback fonts, rich text, sprite assets, input fields, localization, or UI text performance.
---

# TextMeshPro

## Purpose

Help agents use TextMeshPro for high-quality text while avoiding unnecessary allocations, missing font assets, broken localization, and UI rebuild issues.

## Source Notes

TextMeshPro is Unity's advanced text solution and replacement for legacy UI Text/Text Mesh. It supports rich text tags, custom styles, sprites, font assets, fallback fonts, and improved text layout controls. `TMP_Text.SetText` provides formatted text update overloads intended for efficient runtime updates.

## Core Idea

Text is UI data. Update it only when values change, keep font assets explicit, and treat localization and glyph coverage as production concerns.

## Use When

Use this skill for:

- score, timer, currency, and HUD labels
- localized text
- rich text formatting
- TMP sprite icons
- TMP input fields
- font asset and fallback setup
- high-frequency UI text performance
- mobile UI review

## Basic Pattern

```csharp
public sealed class ScoreView : MonoBehaviour
{
    [SerializeField] private TMP_Text _scoreText;

    private int _lastScore = int.MinValue;

    public void SetScore(int score)
    {
        if (score == _lastScore)
            return;

        _lastScore = score;
        _scoreText.SetText("Score: {0}", score);
    }
}
```

Use `SetText` overloads for formatted values when possible. Avoid string concatenation in frequently updated UI.

## StringBuilder Pattern

Use `StringBuilder` when text shape is complex.

```csharp
private readonly StringBuilder _builder = new(64);

public void SetWave(int wave, int enemiesRemaining)
{
    _builder.Clear();
    _builder.Append("Wave ");
    _builder.Append(wave);
    _builder.Append(" - ");
    _builder.Append(enemiesRemaining);
    _builder.Append(" left");

    _waveText.SetText(_builder);
}
```

## Rich Text

```csharp
_label.text = "<color=#FF0000>Danger</color> <b>Incoming</b>";
_coinLabel.text = "Coins <sprite name=\"coin\"> 100";
```

Keep rich text input controlled. Do not pass unsanitized player/user text into rich text fields when tags could be interpreted.

## Font Asset Guidance

- Use explicit TMP Font Assets.
- Set fallback fonts for localization and unsupported glyphs.
- Prefer static font assets for known character sets.
- Use dynamic font assets when glyph coverage is unknown, but monitor memory growth.
- Include required TMP font and sprite assets in builds and Addressables groups when applicable.

## Localization Guidance

- Verify glyph coverage for all target languages.
- Avoid hardcoded English strings in gameplay UI.
- Keep layout flexible for longer translated strings.
- Test right-to-left or CJK languages if supported.

## Sprite Assets

Use TMP Sprite Assets for inline icons such as currency, buttons, or controller prompts.

Keep sprite names stable if text references them by name.

## TMP_InputField

```csharp
public sealed class NameInputView : MonoBehaviour
{
    [SerializeField] private TMP_InputField _nameInput;

    private IPlayerProfileService _profileService;

    [Inject]
    private void Construct(IPlayerProfileService profileService)
    {
        _profileService = profileService;
    }

    private void OnEnable()
    {
        _nameInput.onEndEdit.AddListener(OnNameSubmitted);
    }

    private void OnDisable()
    {
        _nameInput.onEndEdit.RemoveListener(OnNameSubmitted);
    }

    private void OnNameSubmitted(string value)
    {
        _profileService.SetPlayerName(value);
    }
}
```

Input fields should forward user intent. Validation and persistence belong in services.

## Performance Guidance

- Update text only when values change.
- Avoid per-frame text updates for unchanged values.
- Use `SetText` overloads for numeric values.
- Avoid layout rebuild storms from constantly changing text.
- Keep high-frequency labels in isolated UI areas where possible.
- Profile expensive text-heavy screens on target devices.

## Good Pattern

```text
Service publishes ScoreChangedEvent
ScoreView compares previous value
ScoreView updates TMP_Text with SetText
Font assets and fallbacks are configured
```

## Bad Pattern

```text
Update() sets _text.text = "Score: " + score every frame and font fallback is missing in builds.
```

## Common Mistakes

- string concatenation every frame
- updating text when the value did not change
- missing fallback fonts for localization
- missing TMP resources or font assets in Addressables/build
- unsafely allowing rich text tags in user input
- forgetting to unsubscribe TMP_InputField listeners
- tiny text or poor contrast on mobile

## AI Review Guidance

When reviewing TextMeshPro usage, check:

- Is text updated only when needed?
- Are `SetText` overloads used for formatted values?
- Are font assets and fallbacks explicit?
- Are localization and glyph coverage considered?
- Are input field listeners unsubscribed?
- Are sprite asset references stable?
- Is user-provided rich text handled safely?
