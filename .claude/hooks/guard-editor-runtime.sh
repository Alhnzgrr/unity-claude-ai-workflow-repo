#!/bin/bash
# Blocks using UnityEditor in runtime code without #if UNITY_EDITOR guard
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // ""')

# Sadece .cs dosyalarını kontrol et
if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# Editor/ klasöründeyse izin ver
if [[ "$FILE_PATH" =~ /[Ee]ditors?/ || "$FILE_PATH" =~ \\[Ee]ditors?\\ ]]; then exit 0; fi

# UnityEditor namespace kullanımı var mı?
if echo "$CONTENT" | grep -q "using UnityEditor"; then
    # #if UNITY_EDITOR guard'ı var mı?
    if ! echo "$CONTENT" | grep -q "#if UNITY_EDITOR"; then
        echo "HOOK BLOCK [guard-editor-runtime]: Runtime kodda 'using UnityEditor' tespit edildi." >&2
        echo "Çözüm: '#if UNITY_EDITOR ... #endif' bloğu içine alın veya dosyayı Editors/ klasörüne taşıyın." >&2
        echo "Dosya: $FILE_PATH" >&2
        exit 2
    fi
fi

exit 0
