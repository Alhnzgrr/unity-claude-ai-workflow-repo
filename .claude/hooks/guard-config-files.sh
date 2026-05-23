#!/bin/bash
# Blocks edits to protected config files: settings.json, .asmdef, manifest.json, .inputactions
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# settings.json — her zaman koru
if [[ "$FILE_PATH" =~ settings\.json$ && "$FILE_PATH" =~ \.claude ]]; then
    echo "HOOK BLOCK [guard-config-files]: .claude/settings.json Claude tarafından edit edilemez." >&2
    echo "Hook eklemek için settings.json'u manuel düzenleyin." >&2
    exit 2
fi

# .asmdef dosyaları — test assembly'leri hariç koru
if [[ "$FILE_PATH" =~ \.asmdef$ ]]; then
    if [[ ! "$FILE_PATH" =~ [Tt]est ]]; then
        echo "HOOK BLOCK [guard-config-files]: .asmdef dosyaları korumalı." >&2
        echo "Assembly definition değişikliği için kullanıcı onayı gerekli. Manuel düzenleyin." >&2
        echo "Dosya: $FILE_PATH" >&2
        exit 2
    fi
fi

# manifest.json
if [[ "$FILE_PATH" =~ Packages/manifest\.json$ || "$FILE_PATH" =~ packages/manifest\.json$ ]]; then
    echo "HOOK BLOCK [guard-config-files]: Packages/manifest.json korumalı." >&2
    echo "Paket eklemek için Unity Package Manager'ı kullanın." >&2
    exit 2
fi

# .inputactions
if [[ "$FILE_PATH" =~ \.inputactions$ ]]; then
    echo "HOOK BLOCK [guard-config-files]: .inputactions dosyaları korumalı." >&2
    echo "Input action map değişiklikleri Unity Editor'da yapılmalı." >&2
    echo "Dosya: $FILE_PATH" >&2
    exit 2
fi

exit 0
