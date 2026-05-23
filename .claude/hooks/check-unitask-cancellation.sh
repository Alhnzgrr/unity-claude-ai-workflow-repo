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

# Find UniTask methods
UNITASK_METHODS=$(echo "$CONTENT" | grep -nE "async UniTask(<\w+>)?\s+\w+\s*\(")

if [[ -z "$UNITASK_METHODS" ]]; then exit 0; fi

# Find methods without a CancellationToken parameter
MISSING=$(echo "$UNITASK_METHODS" | grep -v "CancellationToken")

if [[ -n "$MISSING" ]]; then
    echo "HOOK WARN [check-unitask-cancellation]: UniTask methods missing CancellationToken parameter:" >&2
    echo "$MISSING" >&2
    echo "Add a 'CancellationToken ct' parameter to every public async method." >&2
    echo "File: $FILE_PATH" >&2
fi

exit 0
