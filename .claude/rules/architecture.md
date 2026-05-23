# Architecture Rules

## Klasör Yapısı (Zorunlu)

```
Assets/
├── _Framework/          ← Pure C# altyapı, SIFIR oyun bağımlılığı
│   ├── Events/
│   ├── Logging/
│   └── SaveLoad/
└── _GameFolders/
    └── Scripts/
        ├── Games/
        │   ├── Abstracts/   ← SADECE interface'ler, domain bazlı klasörler
        │   └── Concretes/   ← Tüm concrete sınıflar
        ├── Tests/
        │   ├── EditMode/
        │   └── PlayMode/
        └── Editors/         ← Editor-only araçlar
```

## Katman Kuralları

- `_Framework/` hiçbir zaman `_GameFolders/` veya oyun koduna referans vermez
- `Games/Abstracts/` → sadece interface dosyaları
- `Games/Concretes/` alt klasör adları domain/feature adı olur: `Audio/`, `Players/`, `Enemies/`
- `Services/`, `Views/`, `Providers/` gibi teknik katman adları yasak alt klasör adı olarak

## Modül Yapısı (Her modül 5 dosya)

```
Games/Abstracts/[Domain]/
└── I[Domain]Service.cs        ← Tek public API

Games/Concretes/[Domain]/
├── [Domain]Service.cs          ← sealed implementasyon
├── [Domain]Configuration.cs    ← ScriptableObject config
├── [Domain]Installer.cs        ← VContainer/Zenject registration
├── [Domain]Events.cs           ← IEvent struct'ları
└── [Domain]Provider.cs         ← MonoBehaviour (Unity API buraya)
```

## Yasak Patternler

- `FindObjectOfType`, `FindAnyObjectByType` — DI kullan
- `GetComponentInChildren` fallback olarak — inject et
- God object / ServiceLocator — yasak
- Static erişim noktaları — yasak
- `_Framework/` içinde `using UnityEngine` — hook engeller

## IEventBus Kuralı

Sistemler arası iletişim için `IEventBus` kullan.
Doğrudan servis referansı yerine event yayınla:

```csharp
// DOĞRU
_eventBus.Publish(new PlayerDiedEvent(playerId));

// YANLIŞ
_enemyService.OnPlayerDied(playerId);
```
