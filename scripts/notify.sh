#!/bin/bash
# claude-ntfy: Push notification hook for Claude Code
# Sends ntfy.sh notification after DELAY seconds of inactivity
# Includes Remote Control deep-link URL if available

# --- Configuration ---
CONFIG_FILE="$HOME/.claude-ntfy/config"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "claude-ntfy: config not found. Run /setup-ntfy first." >&2
  exit 0
fi

source "$CONFIG_FILE"

TOPIC="${CLAUDE_NTFY_TOPIC:-}"
DELAY="${CLAUDE_NTFY_DELAY:-300}"
NTFY_SERVER="${CLAUDE_NTFY_SERVER:-ntfy.sh}"

if [ -z "$TOPIC" ]; then
  echo "claude-ntfy: CLAUDE_NTFY_TOPIC not set in $CONFIG_FILE" >&2
  exit 0
fi

# --- Read hook input ---
INPUT=$(cat)
MSG=$(echo "$INPUT" | jq -r '.message // "Confirmation needed"' 2>/dev/null | cut -c1-100)
SID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // ""' 2>/dev/null)

# --- Extract Remote Control URL from transcript ---
RC_URL=""
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  RC_URL=$(grep -oP 'https://claude\.ai/code/[a-f0-9-]{36}' "$TRANSCRIPT" 2>/dev/null | tail -1)
  if [ -z "$RC_URL" ]; then
    RC_URL=$(grep -oP 'https://claude\.ai/code\?bridge=[a-f0-9-]{36}' "$TRANSCRIPT" 2>/dev/null | tail -1)
  fi
fi

# --- Create marker file and schedule notification ---
MARKER="/tmp/claude-notify-$SID"
echo "$MSG" > "$MARKER"

(
  sleep "$DELAY"
  if [ -f "$MARKER" ]; then
    if [ -n "$RC_URL" ]; then
      curl -s -H "Click: $RC_URL" -H "Title: Claude Code" -d "$MSG" "$NTFY_SERVER/$TOPIC"
    else
      curl -s -H "Title: Claude Code" -d "$MSG" "$NTFY_SERVER/$TOPIC"
    fi
    rm -f "$MARKER"
  fi
) &
