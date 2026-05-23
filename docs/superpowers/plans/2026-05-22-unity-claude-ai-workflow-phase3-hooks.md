# Unity Claude AI Workflow - Phase 3: Hooks

## Goal

Create and test 15 Claude Code guardrail hooks: 9 blocking hooks and 6 warning hooks.

## Hook Architecture

Each hook reads Claude Code tool input as JSON from `stdin`.

Expected input shape:

```json
{
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "/path/to/file.cs",
    "old_string": "...",
    "new_string": "..."
  }
}
```

For `Write`, hooks read `tool_input.content`.

Blocking hooks return exit code `2`. Warning hooks return exit code `0` and write diagnostics to `stderr`.

## Blocking Hooks

- `.claude/hooks/block-scene-edit.sh`: blocks direct edits to `.unity`, `.prefab`, and `.asset` files.
- `.claude/hooks/guard-editor-runtime.sh`: blocks unguarded `UnityEditor` usage in runtime code.
- `.claude/hooks/check-pure-csharp.sh`: blocks `UnityEngine` usage in `_Framework/`.
- `.claude/hooks/check-input-system.sh`: blocks legacy input APIs when New Input System is active.
- `.claude/hooks/check-singleton.sh`: blocks static singleton patterns.
- `.claude/hooks/check-unity-event.sh`: blocks `UnityEvent` usage.
- `.claude/hooks/check-coroutine.sh`: blocks coroutine patterns when UniTask is required.
- `.claude/hooks/guard-config-files.sh`: protects settings, assembly definition files, package manifest, and input action files.
- `.claude/hooks/gateguard.sh`: blocks edits to existing C# files that were not read in the current session.

## Warning Hooks

- `.claude/hooks/check-linq-hotpath.sh`: warns about LINQ usage in Update, FixedUpdate, or LateUpdate.
- `.claude/hooks/check-expensive-hotpath.sh`: warns about GetComponent, Camera.main, and Find calls in hot paths.
- `.claude/hooks/check-async-void.sh`: warns about `async void` outside allowed lifecycle contexts.
- `.claude/hooks/check-unitask-cancellation.sh`: warns when UniTask methods lack CancellationToken parameters.
- `.claude/hooks/check-null-propagation.sh`: warns about Unity object null-check pitfalls.
- `.claude/hooks/warn-serialization.sh`: warns when serialized fields appear to be renamed without `FormerlySerializedAs`.

## Verification

1. Confirm all 15 hook scripts exist.
2. Confirm `jq` is installed.
3. Run sample JSON through representative blocking hooks and confirm exit code `2`.
4. Run sample safe JSON through representative hooks and confirm exit code `0`.
5. Confirm warning hooks emit diagnostics but do not block writes.

## Expected Commit Groups

- Scene, editor-runtime, and pure C# blocking hooks
- Input, singleton, UnityEvent, and coroutine blocking hooks
- Config protection and gateguard hooks
- Six warning hooks
- Final hook permission and verification pass
