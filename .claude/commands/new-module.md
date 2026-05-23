# /new-module

Standart 5 dosya modül yapısını scaffold eder.

## Kullanım

```
/new-module <ModulAdı>
```

Örnek: `/new-module Audio`

## Workflow

### Adım 1 — ARCHITECTURE_GATE

Kullanıcıya önerilen modül yapısını göster:

```
Oluşturulacak dosyalar:

Abstracts/[ModulAdı]/
└── I[ModulAdı]Service.cs

Concretes/[ModulAdı]/
├── [ModulAdı]Service.cs
├── [ModulAdı]Configuration.cs
├── [ModulAdı]Installer.cs
├── [ModulAdı]Events.cs
└── [ModulAdı]Provider.cs   (MonoBehaviour gerekiyorsa)

Onaylıyor musun? (go / hayır)
```

### Adım 2 — Interface Oluştur

`Assets/_GameFolders/Scripts/Games/Abstracts/[ModulAdı]/I[ModulAdı]Service.cs`:

```csharp
namespace [Proje].[ModulAdı]
{
    public interface I[ModulAdı]Service
    {
        // TODO: Public API metodlarını buraya ekle
    }
}
```

### Adım 3 — Service Oluştur

`Assets/_GameFolders/Scripts/Games/Concretes/[ModulAdı]/[ModulAdı]Service.cs`:

```csharp
using Cysharp.Threading.Tasks;
using System.Threading;

namespace [Proje].[ModulAdı]
{
    public sealed class [ModulAdı]Service : I[ModulAdı]Service
    {
        private readonly IEventBus _eventBus;

        public [ModulAdı]Service(IEventBus eventBus)
        {
            _eventBus = eventBus;
        }
    }
}
```

### Adım 4 — Configuration Oluştur

`Assets/_GameFolders/Scripts/Games/Concretes/[ModulAdı]/[ModulAdı]Configuration.cs`:

```csharp
using UnityEngine;

namespace [Proje].[ModulAdı]
{
    [CreateAssetMenu(menuName = "Config/[ModulAdı]")]
    public sealed class [ModulAdı]Configuration : ScriptableObject
    {
        // TODO: Konfigürasyon alanlarını ekle
    }
}
```

### Adım 5 — Installer Oluştur (DI'a göre)

**VContainer:**
```csharp
using VContainer;
using VContainer.Unity;

namespace [Proje].[ModulAdı]
{
    public static class [ModulAdı]Installer
    {
        public static void Install(IContainerBuilder builder,
            [ModulAdı]Configuration config)
        {
            builder.RegisterInstance(config);
            builder.Register<[ModulAdı]Service>(Lifetime.Singleton)
                   .As<I[ModulAdı]Service>();
        }
    }
}
```

**Zenject:**
```csharp
using Zenject;

namespace [Proje].[ModulAdı]
{
    public class [ModulAdı]Installer : MonoInstaller
    {
        [SerializeField] private [ModulAdı]Configuration _config;

        public override void InstallBindings()
        {
            Container.BindInstance(_config);
            Container.Bind<I[ModulAdı]Service>()
                     .To<[ModulAdı]Service>().AsSingle();
        }
    }
}
```

### Adım 6 — Events Oluştur

`Assets/_GameFolders/Scripts/Games/Concretes/[ModulAdı]/[ModulAdı]Events.cs`:

```csharp
namespace [Proje].[ModulAdı]
{
    public readonly struct [ModulAdı]StartedEvent : IEvent
    {
        // TODO: Event alanlarını ekle
    }
}
```

### Adım 7 — Commit

```bash
git add Assets/_GameFolders/Scripts/Games/
git commit -m "feat([moduladı]): scaffold [ModulAdı] module (5 files)"
```
