---
name: unity-instincts
description: Project-wide instincts for fast, reliable decisions in Unity development.
---

# Unity Instincts

Pre-determined decisions for frequently recurring situations. Apply these instincts instead of analyzing from scratch each time.

## General Instincts

**Need a new system?**
→ Write the Interface first, then the implementation. Never in reverse order.

**Communication between services?**
→ IEventBus. Not direct references.

**An async operation?**
→ UniTask + CancellationToken. Always. No exceptions.

**Dependency on MonoBehaviour?**
→ [Inject] void Construct(...). Not constructor.

**Need a new GameObject?**
→ Instantiate from Prefab. Not new GameObject().

**Coroutine → UniTask migration?**
→ yield return new WaitForSeconds(t) → await UniTask.Delay(ms, ct)
→ yield return null → await UniTask.Yield()
→ yield return new WaitForEndOfFrame() → await UniTask.WaitForEndOfFrame()

**Event subscribe/unsubscribe?**
→ Subscribe in OnEnable, unsubscribe in OnDisable. Always paired.

**Performance question?**
→ Profiler first. No assumptions. No optimization without measurement.

**Writing a test?**
→ No Unity API required → EditMode. Required → PlayMode. Scene needed → PlayMode Scene.

**Creating a new file?**
→ Interface first, then concrete. Check the folder: Abstracts/ and Concretes/ are separate.
