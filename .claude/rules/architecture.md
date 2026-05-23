# Architecture Rules

## Folder Structure (Required)

```
Assets/
├── _Framework/          ← Pure C# infrastructure, ZERO game dependencies
│   ├── Events/
│   ├── Logging/
│   └── SaveLoad/
└── _GameFolders/
    └── Scripts/
        ├── Games/
        │   ├── Abstracts/   ← ONLY interfaces, domain-based folders
        │   └── Concretes/   ← All concrete classes
        ├── Tests/
        │   ├── EditMode/
        │   └── PlayMode/
        └── Editors/         ← Editor-only tools
```

## Layer Rules

- `_Framework/` never references `_GameFolders/` or game code
- `Games/Abstracts/` → interface files only
- `Games/Concretes/` subfolder names become domain/feature names: `Audio/`, `Players/`, `Enemies/`
- Technical layer names such as `Services/`, `Views/`, `Providers/` are forbidden as subfolder names

## Module Structure (5 files per module)

```
Games/Abstracts/[Domain]/
└── I[Domain]Service.cs        ← Single public API

Games/Concretes/[Domain]/
├── [Domain]Service.cs          ← sealed implementation
├── [Domain]Configuration.cs    ← ScriptableObject config
├── [Domain]Installer.cs        ← VContainer/Zenject registration
├── [Domain]Events.cs           ← IEvent structs
└── [Domain]Provider.cs         ← MonoBehaviour (Unity API goes here)
```

## Forbidden Patterns

- `FindObjectOfType`, `FindAnyObjectByType` — use DI
- `GetComponentInChildren` as fallback — inject it
- God object / ServiceLocator — forbidden
- Static access points — forbidden
- `using UnityEngine` inside `_Framework/` — hook blocks it

## IEventBus Rule

Use `IEventBus` for cross-system communication.
Publish events instead of holding direct service references:

```csharp
// CORRECT
_eventBus.Publish(new PlayerDiedEvent(playerId));

// WRONG
_enemyService.OnPlayerDied(playerId);
```
