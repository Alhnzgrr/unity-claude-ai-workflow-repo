#!/bin/bash
# Blocks static singleton patterns
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# Test dosyalarını atla
if [[ "$FILE_PATH" =~ [Tt]est || "$FILE_PATH" =~ [Ee]ditor ]]; then exit 0; fi

# Static Instance property veya field
if echo "$CONTENT" | grep -qE "static\s+\w+\s+Instance|private\s+static\s+\w+\s+_instance|public\s+static\s+\w+\s+Instance"; then
    echo "HOOK BLOCK [check-singleton]: Static singleton pattern tespit edildi." >&2
    echo "VContainer veya Zenject kullanarak dependency injection ile inject edin." >&2
    echo "Dosya: $FILE_PATH" >&2
    exit 2
fi

exit 0
