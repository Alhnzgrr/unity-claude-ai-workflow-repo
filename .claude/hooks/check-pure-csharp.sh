#!/bin/bash
# Blocks using UnityEngine in _Framework/ (pure C# layer)
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# Is it in the _Framework/ folder?
if [[ "$FILE_PATH" =~ _Framework ]]; then
    if echo "$CONTENT" | grep -qE "^using UnityEngine|^using UnityEngine\."; then
        echo "HOOK BLOCK [check-pure-csharp]: 'using UnityEngine' is forbidden inside _Framework/." >&2
        echo "_Framework/ is the pure C# layer. If Unity API is needed, move the code to _GameFolders/." >&2
        echo "File: $FILE_PATH" >&2
        exit 2
    fi
fi

exit 0
