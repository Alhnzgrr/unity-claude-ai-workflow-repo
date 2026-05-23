#!/bin/bash
# Blocks direct Edit/Write on .unity .prefab .asset files
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

if [[ "$FILE_PATH" =~ \.(unity|prefab|asset)$ ]]; then
    CONFIG=".claude/project-config.json"
    MCP_HINT=""
    if [[ -f "$CONFIG" ]]; then
        MCP_HINT=" Please edit manually in the Unity Editor."
    fi
    echo "HOOK BLOCK [block-scene-edit]: .unity/.prefab/.asset files cannot be directly edited.${MCP_HINT}" >&2
    echo "File: $FILE_PATH" >&2
    exit 2
fi

exit 0
