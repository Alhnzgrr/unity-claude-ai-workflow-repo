# Blocking Hooks

These hooks stop the write operation when they return exit 2.

| Hook | Blocks |
|---|---|
| `block-scene-edit.sh` | Direct edit of `.unity`/`.prefab`/`.asset` files |
| `guard-editor-runtime.sh` | `UnityEditor` namespace in runtime (without guard) |
| `check-pure-csharp.sh` | `using UnityEngine` inside `_Framework/` |
| `check-input-system.sh` | `Input.GetKey/Axis` (when New Input System is selected) |
| `check-singleton.sh` | Static singleton pattern (`Instance`, `_instance`) |
| `check-unity-event.sh` | `UnityEvent`, `UnityEvent<T>` usage |
| `check-coroutine.sh` | `IEnumerator`, `StartCoroutine` |
| `guard-config-files.sh` | Editing `settings.json`, `.asmdef`, `manifest.json` |
| `gateguard.sh` | Attempt to edit a C# file not yet read in the session |
