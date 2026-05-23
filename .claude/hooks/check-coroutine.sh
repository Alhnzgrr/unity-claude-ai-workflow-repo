#!/bin/bash
# Blocks IEnumerator and StartCoroutine (UniTask projelerinde)
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

CONFIG=".claude/project-config.json"
if [[ ! -f "$CONFIG" ]]; then exit 0; fi

ASYNC_LIB=$(jq -r '.async // "unitask"' "$CONFIG")
if [[ "$ASYNC_LIB" != "unitask" ]]; then exit 0; fi

# Test ve Editor dosyalarını atla
if [[ "$FILE_PATH" =~ [Tt]est || "$FILE_PATH" =~ [Ee]ditor ]]; then exit 0; fi

if echo "$CONTENT" | grep -qE "IEnumerator|StartCoroutine|StopCoroutine|yield return"; then
    echo "HOOK BLOCK [check-coroutine]: Coroutine kullanımı yasak." >&2
    echo "Proje UniTask kullanıyor. 'async UniTask' ve 'await' kullanın." >&2
    echo "Dosya: $FILE_PATH" >&2
    exit 2
fi

exit 0
