---
name: unity-instincts
description: Project-wide instincts for fast, reliable Unity development decisions.
---

# Unity Instincts

Use these as default decisions for common Unity development situations. If a rule-specific exception applies, follow the more specific rule and document the reason.

## General Instincts

**Need a new system?**  
Write the interface first, then the implementation.

**Communication between services?**  
Use `IEventBus` for cross-system communication. Avoid direct references unless the dependency is truly part of the same module boundary.

**Async operation?**  
Use UniTask and pass a `CancellationToken`. Test-only Unity coroutine runner usage is the only documented coroutine exception.

**MonoBehaviour dependency?**  
Use `[Inject] void Construct(...)`. Do not use constructors for MonoBehaviours.

**Need a persistent scene object?**  
Instantiate from a prefab or set it up through Unity Editor/MCP. Do not create persistent gameplay objects with `new GameObject`.

**Writing a PlayMode test?**  
Temporary `new GameObject` setup is allowed only inside test code and must be cleaned up by the test.

**Coroutine to UniTask migration?**

```text
yield return new WaitForSeconds(t) -> await UniTask.Delay(TimeSpan.FromSeconds(t), cancellationToken: ct)
yield return null -> await UniTask.Yield(ct)
yield return new WaitForEndOfFrame() -> await UniTask.WaitForEndOfFrame(ct)
```

**Event subscribe/unsubscribe?**  
Subscribe in `OnEnable`, unsubscribe in `OnDisable`, and keep the pair together.

**Performance question?**  
Measure first. Use the profiler or targeted diagnostics before making broad optimizations.

**Writing a test?**

```text
No Unity API required -> EditMode
Unity object behavior required -> PlayMode
Scene integration required -> PlayMode scene test
```

**Creating a new module file set?**  
Create Abstracts and Concretes in the expected module layout. Keep public API in interfaces and Unity bridge code in providers/views.

## Common Mistakes

- treating instincts as exceptions to stricter rules
- copying test-only patterns into runtime code
- using DI to hide unclear ownership
- starting optimization without evidence
- mixing input, rules, state mutation, and presentation in one MonoBehaviour
