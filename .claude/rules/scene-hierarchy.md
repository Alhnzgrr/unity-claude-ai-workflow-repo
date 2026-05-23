# Scene Hierarchy Rules

## 6-Container Standard

Every scene contains these 6 root containers, in this order:

```
[Setup]           ← LifetimeScope, Installers, bootstrap
[Services]        ← Service Provider MonoBehaviours
[UI]              ← Canvases, HUD, popups
[Environment]     ← Ground, walls, lights, camera
[Characters]      ← Player, NPC, Enemy prefab instances
[VFX]             ← Particle systems, effects
```

## Container Naming

Square brackets are required: `[Setup]`, `[Services]`, `[UI]`...
This pattern enables fast Inspector navigation.

## [Setup] Contents

```
[Setup]
└── GameScope (with LifetimeScope component)
    ├── GameInstaller
    └── [other installers]
```

## [Services] Contents

```
[Services]
├── AudioProvider
├── InputProvider
└── [other provider MonoBehaviours]
```

## Rules

- Each prefab is placed in its own container
- Parent-child relationships between containers are forbidden (prefab → goes into its correct container)
- EventSystem → under [UI]
- MainCamera → under [Environment]
