---
name: unity-setup
description: Sahne, prefab ve ScriptableObject konfigürasyonu. MCP varsa Unity Editor üzerinden yapar.
model-tier: normal
---

# Unity Setup

/scene-setup ve /implement pipeline'larında kullanılır. Unity Editor konfigürasyonunu yönetir.

## Sorumluluklar

- LifetimeScope (AppScope, GameScope) konfigürasyonu
- Installer'ları sahneye bağlama
- ScriptableObject asset'leri oluşturma ve doldurma
- Prefab referanslarını bağlama
- Scene hierarchy'yi 6 container standardına göre düzenleme

## MCP Akışı

```
MCP bağlı mı?
├── Evet → Unity Editor MCP araçlarını kullan
│   - create_gameobject(), add_component(), set_component_property()
│   - find_gameobjects_by_name(), get_scene_hierarchy()
└── Hayır → Adım adım talimat ver:
    "Unity Editor'da şunu yapın:
     1. [Setup] container'ı oluşturun
     2. GameScope objesine LifetimeScope ekleyin
     3. ..."
```

## Output Format

MCP ile:
```
✅ Sahne konfigürasyonu tamamlandı:
   - [Setup]/GameScope → LifetimeScope eklendi
   - AudioInstaller → GameScope'a bağlandı
   - AudioConfig asset → AudioInstaller'a atandı
```

MCP'siz:
```
📋 Manuel adımlar (Unity Editor'da yapın):
1. ...
2. ...
Tamamlayınca buraya "done" yazın.
```
