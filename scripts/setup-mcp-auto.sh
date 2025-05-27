#!/bin/bash
# Automatic MCP server setup from configuration

CONFIG_FILE="/usr/local/bin/mcp-config.json"
MCP_SERVERS=${MCP_SERVERS:-puppeteer}

echo "🔧 Configuring MCP servers: $MCP_SERVERS"

# Parse MCP servers
IFS=',' read -ra SERVERS <<< "$MCP_SERVERS"

for server in "${SERVERS[@]}"; do
    server=$(echo "$server" | xargs)
    
    # Check if server exists in config
    if ! jq -e ".servers.\"$server\"" "$CONFIG_FILE" >/dev/null 2>&1; then
        echo "⚠️  Unknown MCP server: $server (skipping)"
        continue
    fi
    
    # Get server configuration
    SERVER_CONFIG=$(jq -r ".servers.\"$server\"" "$CONFIG_FILE")
    COMMAND=$(echo "$SERVER_CONFIG" | jq -r '.command')
    ARGS=$(echo "$SERVER_CONFIG" | jq -r '.args | join(" ")')
    
    # Check required environment variables
    REQUIRES=$(echo "$SERVER_CONFIG" | jq -r '.requires[]?' 2>/dev/null)
    SKIP=false
    for req in $REQUIRES; do
        if [ -z "${!req}" ]; then
            echo "⚠️  $server requires $req environment variable (skipping)"
            SKIP=true
            break
        fi
    done
    
    if [ "$SKIP" = true ]; then
        continue
    fi
    
    # Build environment variables
    ENV_ARGS=""
    if echo "$SERVER_CONFIG" | jq -e '.env' >/dev/null 2>&1; then
        while IFS= read -r line; do
            KEY=$(echo "$line" | cut -d'=' -f1)
            VALUE=$(echo "$line" | cut -d'=' -f2-)
            # Substitute environment variables
            VALUE=$(eval echo "$VALUE")
            ENV_ARGS="$ENV_ARGS -e $KEY=\"$VALUE\""
        done < <(echo "$SERVER_CONFIG" | jq -r '.env | to_entries | .[] | "\(.key)=\(.value)"')
    fi
    
    # Add the server
    echo "  Adding $server server..."
    eval "claude mcp add $server --scope user $ENV_ARGS -- $COMMAND $ARGS" || true
done

echo "✅ MCP servers configured!"