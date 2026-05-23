#!/bin/bash
# Blocks UnityEvent and UnityEvent<T> usage
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# Test ve Editor dosyalarını atla
if [[ "$FILE_PATH" =~ [Tt]est || "$FILE_PATH" =~ [Ee]ditor ]]; then exit 0; fi

if echo "$CONTENT" | grep -qE "UnityEvent(<|;|\s)"; then
    echo "HOOK BLOCK [check-unity-event]: UnityEvent kullanımı yasak." >&2
    echo "Sistemler arası: IEventBus kullanın. Aynı modül içi: C# event kullanın." >&2
    echo "Dosya: $FILE_PATH" >&2
    exit 2
fi

exit 0
