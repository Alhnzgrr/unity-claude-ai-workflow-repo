#!/bin/bash
# Warns about async void outside Unity lifecycle methods
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# Find async void — exclude Unity lifecycle methods
ASYNC_VOID_LINES=$(echo "$CONTENT" | grep -nE "async void" | grep -vE "async void (Awake|Start|OnEnable|OnDisable|OnDestroy|Update|FixedUpdate|LateUpdate)")

if [[ -n "$ASYNC_VOID_LINES" ]]; then
    echo "HOOK WARN [check-async-void]: 'async void' usage detected:" >&2
    echo "$ASYNC_VOID_LINES" >&2
    echo "Exceptions won't be caught. Use 'async UniTask' or use .Forget() for fire-and-forget." >&2
    echo "File: $FILE_PATH" >&2
fi

exit 0
