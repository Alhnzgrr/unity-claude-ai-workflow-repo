#!/bin/bash
# Blocks edits to protected config files: settings.json, .asmdef, manifest.json, .inputactions
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# settings.json — always protect
if [[ "$FILE_PATH" =~ settings\.json$ && "$FILE_PATH" =~ \.claude ]]; then
    echo "HOOK BLOCK [guard-config-files]: .claude/settings.json cannot be edited by Claude." >&2
    echo "To add hooks, edit settings.json manually." >&2
    exit 2
fi

# .asmdef files — protect except test assemblies
if [[ "$FILE_PATH" =~ \.asmdef$ ]]; then
    if [[ ! "$FILE_PATH" =~ [Tt]est ]]; then
        echo "HOOK BLOCK [guard-config-files]: .asmdef files are protected." >&2
        echo "User approval required for assembly definition changes. Edit manually." >&2
        echo "File: $FILE_PATH" >&2
        exit 2
    fi
fi

# manifest.json
if [[ "$FILE_PATH" =~ Packages/manifest\.json$ || "$FILE_PATH" =~ packages/manifest\.json$ ]]; then
    echo "HOOK BLOCK [guard-config-files]: Packages/manifest.json is protected." >&2
    echo "Use Unity Package Manager to add packages." >&2
    exit 2
fi

# .inputactions
if [[ "$FILE_PATH" =~ \.inputactions$ ]]; then
    echo "HOOK BLOCK [guard-config-files]: .inputactions files are protected." >&2
    echo "Input action map changes must be made in the Unity Editor." >&2
    echo "File: $FILE_PATH" >&2
    exit 2
fi

exit 0
