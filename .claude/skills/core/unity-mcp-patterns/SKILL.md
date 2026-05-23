---
name: unity-mcp-patterns
description: Unity Editor MCP entegrasyonu için kullanım pattern'leri ve fallback davranışları.
---

# Unity MCP Patterns

## MCP Varlık Kontrolü

Session başında MCP bağlantısı kontrol edilir. Davranış buna göre değişir:

```
MCP bağlı mı?
├── Evet → Unity Editor araçlarını kullan
└── Hayır → Manuel talimatlar ver, kullanıcıdan onay bekle
```

## MCP ile Yapılabilecekler

- Sahne hiyerarşisi okuma/yazma
- GameObject oluşturma, component ekleme
- ScriptableObject asset oluşturma
- Prefab referansları bağlama
- Compile tetikleme
- Test runner çalıştırma
- Console log okuma

## MCP ile YAPILMAYACAKLAR

- .unity dosyasını direkt Edit/Write ile değiştirme → `block-scene-edit.sh` engeller
- .prefab dosyasını direkt Edit/Write ile değiştirme → engeller
- .asset dosyasını direkt Edit/Write ile değiştirme → engeller

## MCP Fallback Talimat Formatı

MCP yoksa kullanıcıya net adımlar ver:

```
📋 Unity Editor'da yapılacaklar:

1. Hierarchy'de [Setup] container'ını seç
2. Add Component → LifetimeScope ekle
3. LifetimeScope'un Parent field'ına AppScope'u sürükle
4. Inspector'da GameInstaller alanına GameInstaller asset'ini sürükle

Tamamlayınca "hazır" yaz.
```

## Sahne Manipülasyon Sırası

1. Container'ları oluştur ([Setup], [Services], [UI]...)
2. Core objeler: EventSystem → [UI], MainCamera → [Environment]
3. LifetimeScope ve Installer'lar → [Setup]
4. Provider MonoBehaviour'lar → [Services]
5. Prefab instance'ları → ilgili container
