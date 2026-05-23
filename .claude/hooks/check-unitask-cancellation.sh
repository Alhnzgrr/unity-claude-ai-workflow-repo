#!/bin/bash
# Warns when async UniTask methods lack CancellationToken parameter
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

CONFIG=".claude/project-config.json"
if [[ -f "$CONFIG" ]]; then
    ASYNC_LIB=$(jq -r '.async // "unitask"' "$CONFIG")
    if [[ "$ASYNC_LIB" != "unitask" ]]; then exit 0; fi
fi

# UniTask metodları bul
UNITASK_METHODS=$(echo "$CONTENT" | grep -nE "async UniTask(<\w+>)?\s+\w+\s*\(")

if [[ -z "$UNITASK_METHODS" ]]; then exit 0; fi

# CancellationToken parametresi olmayan metodları bul
MISSING=$(echo "$UNITASK_METHODS" | grep -v "CancellationToken")

if [[ -n "$MISSING" ]]; then
    echo "HOOK WARN [check-unitask-cancellation]: CancellationToken parametresi eksik UniTask metodları:" >&2
    echo "$MISSING" >&2
    echo "Her public async metoda 'CancellationToken ct' parametresi ekleyin." >&2
    echo "Dosya: $FILE_PATH" >&2
fi

exit 0
