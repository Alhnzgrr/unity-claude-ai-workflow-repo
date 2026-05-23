#!/bin/bash
# Blocks editing C# files that haven't been Read in the current session.
# Uses a session read-log to track which files Claude has seen.
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# Only check .cs files
if [[ ! "$FILE_PATH" =~ \.cs$ ]]; then exit 0; fi

# Creating new files (Write) is always allowed
if [[ "$TOOL_NAME" == "Write" ]]; then
    # File doesn't exist, creating new — allow
    if [[ ! -f "$FILE_PATH" ]]; then exit 0; fi
fi

SESSION_LOG=".claude/state/read-files.log"
mkdir -p ".claude/state"

# Is the file in the read-log?
if [[ -f "$SESSION_LOG" ]]; then
    NORMALIZED=$(echo "$FILE_PATH" | tr '\\' '/')
    if grep -qF "$NORMALIZED" "$SESSION_LOG" 2>/dev/null; then
        exit 0
    fi
    # Also check by basename (for path variations)
    BASENAME=$(basename "$FILE_PATH")
    if grep -qF "$BASENAME" "$SESSION_LOG" 2>/dev/null; then
        exit 0
    fi
fi

echo "HOOK BLOCK [gateguard]: '$FILE_PATH' cannot be edited without first being read in this session." >&2
echo "First read the file with the Read tool, then edit it." >&2
exit 2
