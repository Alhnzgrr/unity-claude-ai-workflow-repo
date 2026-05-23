#!/bin/bash
# Warns about ?. and "is null" on Unity objects (bypasses Unity's == override)
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

ISSUES=()

# ?. operator — dangerous on Unity objects
NULL_CONDITIONAL=$(echo "$CONTENT" | grep -nE "\?\." | grep -vE "//.*\?\.")
if [[ -n "$NULL_CONDITIONAL" ]]; then
    ISSUES+=("'?.' operator bypasses the destroyed check on Unity objects")
fi

# is null — use == null on Unity objects
IS_NULL=$(echo "$CONTENT" | grep -nE "\bis null\b" | grep -vE "//.*is null")
if [[ -n "$IS_NULL" ]]; then
    ISSUES+=("'is null' bypasses Unity's == override, use '== null' instead")
fi

if [[ ${#ISSUES[@]} -gt 0 ]]; then
    echo "HOOK WARN [check-null-propagation]: Unity object null check issues:" >&2
    for issue in "${ISSUES[@]}"; do
        echo "  - $issue" >&2
    done
    echo "File: $FILE_PATH" >&2
fi

exit 0
