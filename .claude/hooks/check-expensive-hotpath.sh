#!/bin/bash
# Warns about GetComponent, Camera.main, Find* in hot paths
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

HAS_HOTPATH=$(echo "$CONTENT" | grep -cE "void Update|void FixedUpdate|void LateUpdate")
if [[ "$HAS_HOTPATH" -eq 0 ]]; then exit 0; fi

ISSUES=()

if echo "$CONTENT" | grep -qE "GetComponent<|GetComponent\("; then
    ISSUES+=("GetComponent — Awake'de cache'le")
fi

if echo "$CONTENT" | grep -q "Camera.main"; then
    ISSUES+=("Camera.main — field'a cache'le")
fi

if echo "$CONTENT" | grep -qE "FindObjectOfType|FindAnyObjectByType|FindObjectsOfType"; then
    ISSUES+=("Find* — Inject et veya Awake'de cache'le")
fi

if [[ ${#ISSUES[@]} -gt 0 ]]; then
    echo "HOOK WARN [check-expensive-hotpath]: Hot path'te pahalı çağrılar tespit edildi:" >&2
    for issue in "${ISSUES[@]}"; do
        echo "  - $issue" >&2
    done
    echo "Dosya: $FILE_PATH" >&2
fi

exit 0
