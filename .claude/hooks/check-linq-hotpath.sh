#!/bin/bash
# Warns when LINQ is used inside Update/FixedUpdate/LateUpdate
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# Is LINQ being used?
if ! echo "$CONTENT" | grep -qE "using System\.Linq|\.Where\(|\.Select\(|\.ToList\(|\.FirstOrDefault\("; then
    exit 0
fi

# Is it inside Update methods? (simple heuristic: LINQ after Update block)
if echo "$CONTENT" | grep -qE "(void Update|void FixedUpdate|void LateUpdate)"; then
    echo "HOOK WARN [check-linq-hotpath]: LINQ usage detected inside Update/FixedUpdate/LateUpdate." >&2
    echo "Causes GC allocation in hot path. Replace with a for/foreach loop." >&2
    echo "File: $FILE_PATH" >&2
fi

exit 0
