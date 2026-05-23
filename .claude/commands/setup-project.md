# /setup-project

Projeyi detect eder, konfigüre eder ve klasör yapısını oluşturur.

## Kullanım

```
/setup-project
```

## Workflow

### Adım 1 — manifest.json Detect

`Packages/manifest.json` oku:

```bash
# VContainer mı Zenject mi?
DI="none"
grep -q "jp.hadashikick.vcontainer" Packages/manifest.json && DI="vcontainer"
grep -q "com.svermeulen.extenject" Packages/manifest.json && DI="zenject"

# UniTask var mı?
grep -q "com.cysharp.unitask" Packages/manifest.json && ASYNC="unitask"

# DOTween var mı?
grep -q "com.demigiant.dotween" Packages/manifest.json && HAS_DOTWEEN=true
```

### Adım 2 — Input Sistemi Detect

`ProjectSettings/ProjectVersion.txt` ve Input Manager'ı kontrol et:
- New Input System paketi var mı? → `"input": "new"`
- Yoksa → `"input": "legacy"`

### Adım 3 — Opsiyonel Feature Seçimi

Kullanıcıya sor (birer birer):
1. ECS/DOTS kullanacak mısın? (ecs: true/false)
2. Addressables kullanacak mısın? (addressables: true/false)
3. XR/VR geliştirme yapacak mısın? (xr: true/false)

### Adım 4 — project-config.json Güncelle

`.claude/project-config.json` güncelle:

```json
{
  "di": "[detect edilen]",
  "async": "unitask",
  "input": "[detect edilen]",
  "ecs": false,
  "addressables": false,
  "xr": false,
  "platform": "general",
  "unity_version": "6000"
}
```

### Adım 5 — Klasör Yapısını Oluştur

```
Assets/
├── _Framework/
│   ├── Events/
│   ├── Logging/
│   └── SaveLoad/
└── _GameFolders/
    └── Scripts/
        ├── Games/
        │   ├── Abstracts/
        │   └── Concretes/
        ├── Tests/
        │   ├── [Proje]EditModeTest/
        │   └── [Proje]PlayModeTest/
        └── Editors/
```

### Adım 6 — Özet Göster

```
✅ Kurulum tamamlandı

DI Container: vcontainer
Async: unitask
Input: new input system
ECS: false
Addressables: false
XR: false

Klasör yapısı oluşturuldu: Assets/_Framework/ + Assets/_GameFolders/

Sonraki adım: /game-idea veya /implement
```
