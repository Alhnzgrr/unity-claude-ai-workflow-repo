#!/bin/bash
# Blocks editing C# files that haven't been Read in the current session.
# Uses a session read-log to track which files Claude has seen.
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# Sadece .cs dosyalarını kontrol et
if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# Yeni dosya oluşturma (Write) her zaman izinli
if [[ "$TOOL_NAME" == "Write" ]]; then
    # Dosya yoksa yeni oluşturuluyor, izin ver
    if [[ ! -f "$FILE_PATH" ]]; then exit 0; fi
fi

SESSION_LOG=".claude/state/read-files.log"
mkdir -p ".claude/state"

# Dosya read-log'da var mı?
if [[ -f "$SESSION_LOG" ]]; then
    NORMALIZED=$(echo "$FILE_PATH" | tr '\\' '/')
    if grep -qF "$NORMALIZED" "$SESSION_LOG" 2>/dev/null; then
        exit 0
    fi
    # Basename ile de kontrol et (path farklılıklarına karşı)
    BASENAME=$(basename "$FILE_PATH")
    if grep -qF "$BASENAME" "$SESSION_LOG" 2>/dev/null; then
        exit 0
    fi
fi

echo "HOOK BLOCK [gateguard]: '$FILE_PATH' bu session'da okunmadan edit edilemez." >&2
echo "Önce dosyayı Read tool ile okuyun, sonra düzenleyin." >&2
exit 2
