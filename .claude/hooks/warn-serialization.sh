#!/bin/bash
# Warns when [SerializeField] fields appear renamed without [FormerlySerializedAs]
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
OLD_CONTENT=$(echo "$INPUT" | jq -r '.tool_input.old_string // ""')
NEW_CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi
if [[ -z "$OLD_CONTENT" || -z "$NEW_CONTENT" ]]; then exit 0; fi

# Eski içerikte [SerializeField] olan private field'ları bul
OLD_FIELDS=$(echo "$OLD_CONTENT" | grep -oE "\[SerializeField\][^;]+private [a-zA-Z<>]+ (_[a-zA-Z]+)" | grep -oE "_[a-zA-Z]+$")

if [[ -z "$OLD_FIELDS" ]]; then exit 0; fi

# Yeni içerikte bu field'lar hala var mı?
while IFS= read -r field; do
    if [[ -n "$field" ]] && ! echo "$NEW_CONTENT" | grep -q "$field"; then
        # Field silindi veya rename edildi — FormerlySerializedAs var mı?
        if ! echo "$NEW_CONTENT" | grep -q "FormerlySerializedAs"; then
            echo "HOOK WARN [warn-serialization]: '[SerializeField] $field' rename edilmiş görünüyor." >&2
            echo "[FormerlySerializedAs(\"$field\")] attribute'u ekleyin — aksi halde sahne/prefab verisi kaybolur." >&2
            echo "Dosya: $FILE_PATH" >&2
        fi
    fi
done <<< "$OLD_FIELDS"

exit 0
