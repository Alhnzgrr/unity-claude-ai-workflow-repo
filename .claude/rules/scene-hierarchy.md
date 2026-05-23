# Scene Hierarchy Rules

## 6 Container Standardı

Her sahne bu 6 root container'ı içerir, bu sırayla:

```
[Setup]           ← LifetimeScope, Installer'lar, bootstrap
[Services]        ← Service Provider MonoBehaviour'ları
[UI]              ← Canvas'lar, HUD, popup'lar
[Environment]     ← Zemin, duvarlar, ışık, kamera
[Characters]      ← Player, NPC, Enemy prefab instance'ları
[VFX]             ← Particle system'ler, efektler
```

## Container İsimlendirme

Köşeli parantez zorunlu: `[Setup]`, `[Services]`, `[UI]`...
Bu pattern ile hızlı Inspector gezintisi sağlanır.

## [Setup] İçeriği

```
[Setup]
└── GameScope (LifetimeScope component'li)
    ├── GameInstaller
    └── [diğer installer'lar]
```

## [Services] İçeriği

```
[Services]
├── AudioProvider
├── InputProvider
└── [diğer provider MonoBehaviour'ları]
```

## Kural

- Her prefab kendi container'ına yerleşir
- Container'lar arası parent-child yasak (prefab → doğru container'ına)
- EventSystem → [UI] altında
- MainCamera → [Environment] altında
