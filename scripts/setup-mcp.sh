#!/bin/bash
# Setup MCP servers for Claude Code CLI

# Parse MCP_SERVERS environment variable
MCP_SERVERS=${MCP_SERVERS:-puppeteer}
GITHUB_TOKEN=${GITHUB_TOKEN:-}

echo "Setting up MCP servers: $MCP_SERVERS"

# Split by comma and add each server
IFS=',' read -ra SERVERS <<< "$MCP_SERVERS"

for server in "${SERVERS[@]}"; do
    server=$(echo "$server" | xargs)
    
    case "$server" in
        "puppeteer")
            echo "Adding Puppeteer MCP server..."
            claude mcp add puppeteer \
                --scope user \
                -e PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
                -- npx -y @modelcontextprotocol/server-puppeteer
            ;;
        "filesystem")
            echo "Adding Filesystem MCP server..."
            claude mcp add filesystem \
                --scope user \
                -- npx -y @modelcontextprotocol/server-filesystem /workspace
            ;;
        "github")
            if [ -n "$GITHUB_TOKEN" ]; then
                echo "Adding GitHub MCP server..."
                claude mcp add github \
                    --scope user \
                    -e GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_TOKEN" \
                    -- npx -y @modelcontextprotocol/server-github
            else
                echo "Warning: GitHub server requested but GITHUB_TOKEN not provided"
            fi
            ;;
        *)
            echo "Warning: Unknown MCP server: $server"
            ;;
    esac
done

echo "MCP setup complete. Run 'claude mcp list' to see configured servers."