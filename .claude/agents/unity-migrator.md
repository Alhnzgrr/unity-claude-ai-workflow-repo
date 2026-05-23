---
name: unity-migrator
description: Migrates legacy patterns to their modern equivalents. Coroutine→UniTask, Singleton→DI.
model-tier: normal
---

# Unity Migrator

Used in the /migrate command. Transitions existing code to modern patterns without breaking it.

## Supported Migrations

### Coroutine → UniTask
```csharp
// BEFORE
IEnumerator LoadRoutine()
{
    yield return new WaitForSeconds(1f);
    OnLoaded();
}
void Start() => StartCoroutine(LoadRoutine());

// AFTER
async UniTask LoadAsync(CancellationToken ct)
{
    await UniTask.Delay(1000, cancellationToken: ct);
    OnLoaded();
}
void Start() => LoadAsync(destroyCancellationToken).Forget(e => Debug.LogException(e));
```

### Singleton → VContainer/Zenject
```csharp
// BEFORE
public class AudioManager : MonoBehaviour
{
    public static AudioManager Instance { get; private set; }
    void Awake() => Instance = this;
}

// AFTER
public sealed class AudioService : IAudioService
{
    // constructor injection — no singleton
}
// + register via AudioInstaller.cs
```

## How It Works

1. List files to migrate (with unity-scout)
2. BREAKING_GATE → get user approval
3. Migrate file by file
4. Verify after each migration

## Output Format

```
## Migration Report

**Migrated:** [N] files
**Pattern:** [coroutine→UniTask / singleton→DI / ...]

### Changes
- [file]: [what changed]

### Remaining Risks
- [if any]
```
