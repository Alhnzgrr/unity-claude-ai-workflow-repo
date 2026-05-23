#!/bin/bash
# Blocks using UnityEditor in runtime code without #if UNITY_EDITOR guard
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

# Only check .cs files
if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# Allow if in the Editor/ folder
if [[ "$FILE_PATH" =~ /[Ee]ditors?/ || "$FILE_PATH" =~ \\[Ee]ditors?\\ ]]; then exit 0; fi

# Is UnityEditor namespace being used?
if echo "$CONTENT" | grep -q "using UnityEditor"; then
    # Is there a #if UNITY_EDITOR guard?
    if ! echo "$CONTENT" | grep -q "#if UNITY_EDITOR"; then
        echo "HOOK BLOCK [guard-editor-runtime]: 'using UnityEditor' detected in runtime code." >&2
        echo "Fix: wrap in '#if UNITY_EDITOR ... #endif' or move the file to the Editors/ folder." >&2
        echo "File: $FILE_PATH" >&2
        exit 2
    fi
fi

exit 0
