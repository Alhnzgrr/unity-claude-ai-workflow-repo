#!/bin/bash
# Blocks static singleton patterns
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# Skip Test files
if [[ "$FILE_PATH" =~ [Tt]est || "$FILE_PATH" =~ [Ee]ditor ]]; then exit 0; fi

# Static Instance property or field
if echo "$CONTENT" | grep -qE "static\s+\w+\s+Instance|private\s+static\s+\w+\s+_instance|public\s+static\s+\w+\s+Instance"; then
    echo "HOOK BLOCK [check-singleton]: Static singleton pattern detected." >&2
    echo "Inject it using dependency injection with VContainer or Zenject." >&2
    echo "File: $FILE_PATH" >&2
    exit 2
fi

exit 0
