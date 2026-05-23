# /new-module

Scaffolds the standard 5-file module structure.

## Usage

```
/new-module <ModuleName>
```

Example: `/new-module Audio`

## Workflow

### Step 1 — ARCHITECTURE_GATE

Show the user the proposed module structure:

```
Files to be created:

Abstracts/[ModuleName]/
└── I[ModuleName]Service.cs

Concretes/[ModuleName]/
├── [ModuleName]Service.cs
├── [ModuleName]Configuration.cs
├── [ModuleName]Installer.cs
├── [ModuleName]Events.cs
└── [ModuleName]Provider.cs   (if MonoBehaviour is needed)

Do you approve? (go / no)
```

### Step 2 — Create Interface

`Assets/_GameFolders/Scripts/Games/Abstracts/[ModuleName]/I[ModuleName]Service.cs`:

```csharp
namespace [Project].[ModuleName]
{
    public interface I[ModuleName]Service
    {
        // TODO: Add public API methods here
    }
}
```

### Step 3 — Create Service

`Assets/_GameFolders/Scripts/Games/Concretes/[ModuleName]/[ModuleName]Service.cs`:

```csharp
using Cysharp.Threading.Tasks;
using System.Threading;

namespace [Project].[ModuleName]
{
    public sealed class [ModuleName]Service : I[ModuleName]Service
    {
        private readonly IEventBus _eventBus;

        public [ModuleName]Service(IEventBus eventBus)
        {
            _eventBus = eventBus;
        }
    }
}
```

### Step 4 — Create Configuration

`Assets/_GameFolders/Scripts/Games/Concretes/[ModuleName]/[ModuleName]Configuration.cs`:

```csharp
using UnityEngine;

namespace [Project].[ModuleName]
{
    [CreateAssetMenu(menuName = "Config/[ModuleName]")]
    public sealed class [ModuleName]Configuration : ScriptableObject
    {
        // TODO: Add configuration fields
    }
}
```

### Step 5 — Create Installer (based on DI)

**VContainer:**
```csharp
using VContainer;
using VContainer.Unity;

namespace [Project].[ModuleName]
{
    public static class [ModuleName]Installer
    {
        public static void Install(IContainerBuilder builder,
            [ModuleName]Configuration config)
        {
            builder.RegisterInstance(config);
            builder.Register<[ModuleName]Service>(Lifetime.Singleton)
                   .As<I[ModuleName]Service>();
        }
    }
}
```

**Zenject:**
```csharp
using Zenject;

namespace [Project].[ModuleName]
{
    public class [ModuleName]Installer : MonoInstaller
    {
        [SerializeField] private [ModuleName]Configuration _config;

        public override void InstallBindings()
        {
            Container.BindInstance(_config);
            Container.Bind<I[ModuleName]Service>()
                     .To<[ModuleName]Service>().AsSingle();
        }
    }
}
```

### Step 6 — Create Events

`Assets/_GameFolders/Scripts/Games/Concretes/[ModuleName]/[ModuleName]Events.cs`:

```csharp
namespace [Project].[ModuleName]
{
    public readonly struct [ModuleName]StartedEvent : IEvent
    {
        // TODO: Add event fields
    }
}
```

### Step 7 — Commit

```bash
git add Assets/_GameFolders/Scripts/Games/
git commit -m "feat([modulename]): scaffold [ModuleName] module (5 files)"
```
