#!/bin/bash
# Warns about async void outside Unity lifecycle methods
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# async void bul — Unity lifecycle'ları hariç tut
ASYNC_VOID_LINES=$(echo "$CONTENT" | grep -nE "async void" | grep -vE "async void (Awake|Start|OnEnable|OnDisable|OnDestroy|Update|FixedUpdate|LateUpdate)")

if [[ -n "$ASYNC_VOID_LINES" ]]; then
    echo "HOOK WARN [check-async-void]: 'async void' kullanımı tespit edildi:" >&2
    echo "$ASYNC_VOID_LINES" >&2
    echo "Exception'lar yakalanmaz. 'async UniTask' kullanın veya .Forget() ile fire-and-forget yapın." >&2
    echo "Dosya: $FILE_PATH" >&2
fi

exit 0
