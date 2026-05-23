---
name: textmeshpro
description: TextMeshPro usage patterns. TMP_Text, rich text, font atlas management.
---

# TextMeshPro

## TMP_Text Usage

```csharp
public sealed class ScoreView : MonoBehaviour
{
    [SerializeField] private TMP_Text _scoreText;

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
_label.text = "<color=#FF0000>Red</color> <b>Bold</b> <size=24>Large</size>";
_label.text = "Coins: <sprite name=\"coin\"> 100";
```

## Font Atlas Management

- Each different font → separate Font Asset
- Dynamic Character Set: used characters are added automatically
- Static Character Set: more performant for a specific character set

## Performance

```csharp
// WRONG — string allocation every frame
void Update() { _text.text = "Score: " + _score; }

// CORRECT — update only when changed
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
