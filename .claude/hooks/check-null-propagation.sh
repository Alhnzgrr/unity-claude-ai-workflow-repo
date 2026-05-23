#!/bin/bash
# Warns about ?. and "is null" on Unity objects (bypasses Unity's == override)
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

ISSUES=()

# ?. operatörü — Unity object'lerde tehlikeli
NULL_CONDITIONAL=$(echo "$CONTENT" | grep -nE "\?\." | grep -vE "//.*\?\.")
if [[ -n "$NULL_CONDITIONAL" ]]; then
    ISSUES+=("'?.' operatörü Unity object'lerde destroyed check'ini atlatır")
fi

# is null — Unity object'lerde == null kullanılmalı
IS_NULL=$(echo "$CONTENT" | grep -nE "\bis null\b" | grep -vE "//.*is null")
if [[ -n "$IS_NULL" ]]; then
    ISSUES+=("'is null' Unity'nin == override'ını atlatır, '== null' kullanın")
fi

if [[ ${#ISSUES[@]} -gt 0 ]]; then
    echo "HOOK WARN [check-null-propagation]: Unity object null check sorunları:" >&2
    for issue in "${ISSUES[@]}"; do
        echo "  - $issue" >&2
    done
    echo "Dosya: $FILE_PATH" >&2
fi

exit 0
