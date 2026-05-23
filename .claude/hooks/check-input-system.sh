#!/bin/bash
# Blocks legacy Input.GetKey/Axis when project-config input == "new"
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

CONFIG=".claude/project-config.json"
if [[ ! -f "$CONFIG" ]]; then exit 0; fi

INPUT_TYPE=$(jq -r '.input // "new"' "$CONFIG")
if [[ "$INPUT_TYPE" != "new" ]]; then exit 0; fi

if echo "$CONTENT" | grep -qE "Input\.(GetKey|GetKeyDown|GetKeyUp|GetAxis|GetButton|GetButtonDown|GetButtonUp|GetMouseButton)"; then
    echo "HOOK BLOCK [check-input-system]: Legacy Input API usage detected." >&2
    echo "Project uses New Input System. Use InputActionAsset and InputAction instead." >&2
    echo "File: $FILE_PATH" >&2
    exit 2
fi

exit 0
