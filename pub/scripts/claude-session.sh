#!/bin/bash
# Convenient script to manage persistent Claude sessions

SESSION_NAME="${1:-claude}"
COMMAND="${2:-claude}"

# Check if tmux session exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "📎 Attaching to existing session: $SESSION_NAME"
    tmux attach-session -t "$SESSION_NAME"
else
    echo "🚀 Creating new session: $SESSION_NAME"
    echo "💡 Detach with Ctrl+B, then D"
    tmux new-session -s "$SESSION_NAME" "$COMMAND"
fi