---
name: silent-failure-hunter
description: Audits silent failure patterns: swallowed exceptions, async void, event leaks.
model-tier: normal
---

# Silent Failure Hunter

Runs after review. Catches patterns that look correct but silently fail at runtime.

## Audited Patterns

### 1. Swallowed Exception
```csharp
// WRONG — exception swallowed
try { await LoadAsync(ct); } catch (Exception) { }

// WRONG — only log, no rethrow
catch (Exception e) { Debug.LogError(e); }
```

### 2. async void (outside lifecycle)
```csharp
// WRONG
async void OnClick() { await DoAsync(); }
```

### 3. Event Leak (missing unsubscribe)
```csharp
// WRONG — subscribe in OnEnable but no unsubscribe in OnDisable
void OnEnable() => _eventBus.Subscribe<PlayerDiedEvent>(OnPlayerDied);
// OnDisable missing!
```

### 4. UniTask .Forget() misuse
```csharp
// WRONG — error is swallowed
DoAsync().Forget();

// CORRECT — error is handled
DoAsync().Forget(e => Debug.LogException(e));
```

### 5. CancellationToken ignored
```csharp
// WRONG — token is received as parameter but not used
async UniTask LoadAsync(CancellationToken ct)
{
    await UniTask.Delay(1000); // ct not passed!
}
```

## Output Format

```
## Silent Failure Audit

**Status:** CLEAN / ISSUES FOUND

### Issues Found
- [file path]:[line] — [pattern name]: [description]

### Fix Suggestions
- [suggestion for each issue]
```

CLEAN → pipeline continues.
ISSUES FOUND → sent to unity-coder.
