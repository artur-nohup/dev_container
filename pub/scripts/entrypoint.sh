#!/bin/bash
# Entrypoint script for Claude Code container

# Fix permissions for claude user's directories
if [ -d /home/claude/.claude ]; then
    sudo chown -R claude:claude /home/claude/.claude 2>/dev/null || true
fi
sudo chown -R claude:claude /workspace 2>/dev/null || true

# Check if this is first run (no MCP servers configured)
if ! claude mcp list 2>/dev/null | grep -q -E "puppeteer|filesystem|github|sqlite|postgres|brave-search|slack"; then
    echo "🔧 First run detected - configuring MCP servers..."
    /usr/local/bin/setup-mcp-auto
fi

# Show startup message
echo "🚀 Claude Code Development Container"
echo ""
echo "📋 Quick Start:"
echo "1. claude auth          # Authenticate (if needed)"
echo "2. claude               # Start Claude Code (with prompts)"
echo "   claude-auto          # Start Claude Code (auto-accept all)"
echo "   claude-session       # Start persistent tmux session"
echo ""
echo "💾 Persistent Sessions:"
echo "   - Use 'claude-session' to start/attach tmux session"
echo "   - Detach with Ctrl+B, then D"
echo "   - Sessions survive disconnection!"
echo ""
echo "🔧 MCP servers: $MCP_SERVERS"
echo ""

# Execute the command passed to docker run
exec "$@"