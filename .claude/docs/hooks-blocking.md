# Blocking Hooks

Bu hook'lar exit 2 ile dönünce yazma işlemi durur.

| Hook | Engellediği |
|---|---|
| `block-scene-edit.sh` | `.unity`/`.prefab`/`.asset` direkt edit |
| `guard-editor-runtime.sh` | Runtime'da `UnityEditor` namespace (guard'sız) |
| `check-pure-csharp.sh` | `_Framework/` içinde `using UnityEngine` |
| `check-input-system.sh` | `Input.GetKey/Axis` (New Input System seçiliyse) |
| `check-singleton.sh` | Static singleton pattern (`Instance`, `_instance`) |
| `check-unity-event.sh` | `UnityEvent`, `UnityEvent<T>` kullanımı |
| `check-coroutine.sh` | `IEnumerator`, `StartCoroutine` |
| `guard-config-files.sh` | `settings.json`, `.asmdef`, `manifest.json` edit |
| `gateguard.sh` | Session'da okunmamış C# dosyasını edit girişimi |
