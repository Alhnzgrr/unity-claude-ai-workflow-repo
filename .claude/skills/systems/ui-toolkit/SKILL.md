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
