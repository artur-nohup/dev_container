# Available MCP Servers

The container now supports automatic configuration of multiple MCP servers. Simply add the server name to `MCP_SERVERS` in your `.env` or docker-compose.yml.

## Supported Servers

### 1. **puppeteer** (Default)
Web automation, screenshots, browser control
```bash
MCP_SERVERS=puppeteer
# No additional config needed
```

### 2. **filesystem**
File operations in /workspace directory
```bash
MCP_SERVERS=filesystem
# No additional config needed
```

### 3. **github**
GitHub API integration
```bash
MCP_SERVERS=github
GITHUB_TOKEN=ghp_your_token_here
```

### 4. **sqlite**
SQLite database operations
```bash
MCP_SERVERS=sqlite
# Databases stored in /workspace/data
```

### 5. **postgres**
PostgreSQL database operations
```bash
MCP_SERVERS=postgres
POSTGRES_URL=postgresql://user:pass@host:5432/dbname
```

### 6. **brave-search**
Brave Search API integration
```bash
MCP_SERVERS=brave-search
BRAVE_API_KEY=your_api_key_here
```

### 7. **slack**
Slack workspace integration
```bash
MCP_SERVERS=slack
SLACK_BOT_TOKEN=xoxb-your-bot-token
SLACK_TEAM_ID=T1234567890
```

## Using Multiple Servers

Combine multiple servers with commas:
```bash
# In .env or docker-compose.yml
MCP_SERVERS=puppeteer,github,sqlite
GITHUB_TOKEN=ghp_your_token_here
```

## Adding New MCP Servers

To add a new MCP server that's not in the list:

1. Edit `scripts/mcp-config.json` and add your server configuration:
```json
"your-server": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-your-server"],
  "env": {
    "YOUR_API_KEY": "${YOUR_API_KEY}"
  },
  "requires": ["YOUR_API_KEY"]
}
```

2. Add the server to MCP_SERVERS:
```bash
MCP_SERVERS=puppeteer,your-server
YOUR_API_KEY=your_key_here
```

3. Rebuild the container:
```bash
docker-compose build claude-dev
```

## How It Works

1. On container startup, `entrypoint.sh` checks if MCP servers are configured
2. If not, it runs `setup-mcp-auto.sh` which:
   - Reads server list from `MCP_SERVERS` environment variable
   - Looks up each server in `mcp-config.json`
   - Checks if required environment variables are set
   - Automatically runs `claude mcp add` with proper configuration

This means you can now add any MCP server just by:
1. Adding its name to MCP_SERVERS
2. Providing required environment variables
3. Starting the container

No code changes needed!