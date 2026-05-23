---
name: ui-toolkit
description: Use when implementing or reviewing Unity UI Toolkit runtime UI, UXML/USS structure, UI event binding, view-service boundaries, or editor tooling.
---

# UI Toolkit

## Purpose

Help agents build UI Toolkit interfaces that keep UI code as a view layer, avoid event leaks, and stay separate from gameplay rules.

## Core Idea

UI Toolkit views should render state and forward user intent. They should not own gameplay rules, save logic, or state transitions.

## Use When

Use this skill for:

- runtime UI with `UIDocument`
- UXML and USS structure
- button, slider, field, and list callbacks
- UI binding to services
- editor windows with UI Toolkit
- UI performance review

## Runtime View Pattern

```csharp
public sealed class MainMenuView : MonoBehaviour
{
    [SerializeField] private UIDocument _document;

    private Button _playButton;
    private Label _titleLabel;
    private IGameService _gameService;

    [Inject]
    private void Construct(IGameService gameService)
    {
        _gameService = gameService;
    }

    private void OnEnable()
    {
        VisualElement root = _document.rootVisualElement;
        _playButton = root.Q<Button>("play-button");
        _titleLabel = root.Q<Label>("title-label");

        _playButton.clicked += OnPlayClicked;
    }

    private void OnDisable()
    {
        if (_playButton != null)
            _playButton.clicked -= OnPlayClicked;
    }

    private void OnPlayClicked()
    {
        _gameService.StartGame();
    }
}
```

## View-Service Boundary

UI views may:

- display snapshots
- forward user intent
- play UI feedback
- subscribe to UI events
- call service APIs

UI views should not:

- decide action legality
- mutate domain state directly
- load gameplay assets directly
- own save-game policy
- compute rewards, score rules, or progression rules

## UXML and USS Guidance

Use stable names for queried elements:

```xml
<Button name="play-button" text="Play" />
<Label name="title-label" />
```

Use USS classes for style:

```css
.button-primary {
    padding: 12px;
    background-color: #4A90E2;
}
```

Keep layout and style in UXML/USS where possible. Keep behavior in C#.

## Event Binding Rules

- Subscribe in `OnEnable`.
- Unsubscribe in `OnDisable`.
- Null-check queried elements when UI may vary by document.
- Avoid anonymous lambdas when unsubscribe is needed.
- Keep callback bodies short.

## Performance Guidance

- Avoid rebuilding large UI trees frequently.
- Update labels only when values change.
- Avoid string allocation in high-frequency UI updates.
- Use list virtualization for large lists.
- Keep style changes targeted.

## Editor Tools

Editor UI belongs in editor-only assemblies or guarded editor files.

```csharp
public sealed class WorkflowWindow : EditorWindow
{
    [MenuItem("Tools/Workflow")]
    public static void ShowWindow()
    {
        GetWindow<WorkflowWindow>();
    }

    public void CreateGUI()
    {
        rootVisualElement.Add(new Button(RunValidation)
        {
            text = "Run Validation"
        });
    }
}
```

## Good Pattern

```text
Button click -> service command -> service publishes event -> UI updates from snapshot
```

## Bad Pattern

```text
Button click -> UI mutates game state -> UI updates score -> UI saves progress
```

## Common Mistakes

- forgetting to unsubscribe callbacks
- querying elements every frame
- putting gameplay rules in UI callbacks
- mixing editor UI and runtime UI in the same assembly
- updating text every frame even when unchanged
- relying on visual element names that do not exist in UXML

## AI Review Guidance

When reviewing UI Toolkit code, check:

- Are UI callbacks thin?
- Are event subscriptions cleaned up?
- Is gameplay logic outside the view?
- Are queried elements stable and null-safe?
- Are high-frequency UI updates allocation-conscious?
- Is editor-only UI separated from runtime code?
