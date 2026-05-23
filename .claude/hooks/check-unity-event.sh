#!/bin/bash
# Blocks UnityEvent and UnityEvent<T> usage
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# Skip Test and Editor files
if [[ "$FILE_PATH" =~ [Tt]est || "$FILE_PATH" =~ [Ee]ditor ]]; then exit 0; fi

if echo "$CONTENT" | grep -qE "UnityEvent(<|;|\s)"; then
    echo "HOOK BLOCK [check-unity-event]: UnityEvent usage is forbidden." >&2
    echo "Cross-system: use IEventBus. Within the same module: use C# events." >&2
    echo "File: $FILE_PATH" >&2
    exit 2
fi

exit 0
