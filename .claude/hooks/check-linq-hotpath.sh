#!/bin/bash
# Warns when LINQ is used inside Update/FixedUpdate/LateUpdate
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# LINQ using var mı?
if ! echo "$CONTENT" | grep -qE "using System\.Linq|\.Where\(|\.Select\(|\.ToList\(|\.FirstOrDefault\("; then
    exit 0
fi

# Update metotları içinde mi? (basit heuristic: Update bloğu sonrasında LINQ)
if echo "$CONTENT" | grep -qE "(void Update|void FixedUpdate|void LateUpdate)"; then
    echo "HOOK WARN [check-linq-hotpath]: Update/FixedUpdate/LateUpdate içinde LINQ kullanımı tespit edildi." >&2
    echo "Hot path'te GC allocation oluşturur. for/foreach döngüsüyle değiştirin." >&2
    echo "Dosya: $FILE_PATH" >&2
fi

exit 0
