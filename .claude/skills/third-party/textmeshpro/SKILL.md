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
_label.text = "<color=#FF0000>Kırmızı</color> <b>Kalın</b> <size=24>Büyük</size>";
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
