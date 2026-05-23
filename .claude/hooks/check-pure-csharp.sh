#!/bin/bash
# Blocks using UnityEngine in _Framework/ (pure C# layer)
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# _Framework/ klasöründe mi?
if [[ "$FILE_PATH" =~ _Framework ]]; then
    if echo "$CONTENT" | grep -qE "^using UnityEngine|^using UnityEngine\."; then
        echo "HOOK BLOCK [check-pure-csharp]: _Framework/ içinde 'using UnityEngine' yasak." >&2
        echo "_Framework/ pure C# katmanıdır. Unity API kullanmak gerekiyorsa _GameFolders/ içine taşıyın." >&2
        echo "Dosya: $FILE_PATH" >&2
        exit 2
    fi
fi

exit 0
