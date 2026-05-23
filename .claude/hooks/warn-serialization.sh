#!/bin/bash
# Warns when [SerializeField] fields appear renamed without [FormerlySerializedAs]
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
OLD_CONTENT=$(echo "$INPUT" | jq -r '.tool_input.old_string // ""')
NEW_CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi
if [[ -z "$OLD_CONTENT" || -z "$NEW_CONTENT" ]]; then exit 0; fi

# Find private fields with [SerializeField] in the old content
OLD_FIELDS=$(echo "$OLD_CONTENT" | grep -oE "\[SerializeField\][^;]+private [a-zA-Z<>]+ (_[a-zA-Z]+)" | grep -oE "_[a-zA-Z]+$")

if [[ -z "$OLD_FIELDS" ]]; then exit 0; fi

# Are these fields still present in the new content?
while IFS= read -r field; do
    if [[ -n "$field" ]] && ! echo "$NEW_CONTENT" | grep -q "$field"; then
        # Field was deleted or renamed — is FormerlySerializedAs present?
        if ! echo "$NEW_CONTENT" | grep -q "FormerlySerializedAs"; then
            echo "HOOK WARN [warn-serialization]: '[SerializeField] $field' appears to have been renamed." >&2
            echo "Add [FormerlySerializedAs(\"$field\")] attribute — otherwise scene/prefab data will be lost." >&2
            echo "File: $FILE_PATH" >&2
        fi
    fi
done <<< "$OLD_FIELDS"

exit 0
