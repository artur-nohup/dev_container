# Claude Code Development Container

Docker development container with Claude Code CLI and configurable MCP (Model Context Protocol) servers. Built for development workflows with MCP configuration baked in at build time for clean multi-container deployments.

## Repository Structure

```
dev_container/
├── pub/                    # Public container (configurable via environment)
│   ├── dockerfile          # Main dockerfile
│   ├── docker-compose.yml  # Docker compose configuration
│   ├── scripts/            # Setup and utility scripts
│   └── .env.example        # Example environment configuration
│
└── private/                # Private container (embedded secrets)
    ├── dockerfile          # Dockerfile with hardcoded tokens
    ├── entrypoint.sh       # Entrypoint with embedded configuration
    └── build.sh            # Build script with security warnings
```

## Choose Your Version

### Public Container (`pub/`)
- Configuration via environment variables
- Suitable for public repositories
- Requires `.env` file setup
- Safe to share and distribute

### Private Container (`private/`)
- All secrets hardcoded in image
- ⚠️ **NEVER push to public repositories**
- No configuration needed
- For personal/trusted use only

## Quick Start

Choose your deployment option:

### Option 1: Public Container (Configurable)
```bash
cd pub/

# Create .env file
cp .env.example .env
# Edit .env to:
# - Add your GitHub token
# - Customize MCP_SERVERS (default: puppeteer,github)

docker-compose up -d claude-dev
docker exec -it claude-dev bash
```

### Option 2: Private Container (All-in-One)
```bash
cd private/

# Build with embedded secrets (WARNING: Do not push to public repos!)
./build.sh

# Run directly
docker run -it arturrenzenbrink/dev-priv:latest
```

### Option 3: Use Pre-built Images
```bash
# Public image (requires configuration)
docker run -it -e GITHUB_TOKEN=your_token_here arturrenzenbrink/dev:latest

# Private image (everything pre-configured)
docker run -it arturrenzenbrink/dev-priv:latest
```

### Option 4: Direct build with custom args
```bash
cd pub/
docker build --build-arg MCP_SERVERS=puppeteer,filesystem -t my-claude .
docker run -it --cap-add=SYS_ADMIN --security-opt=seccomp:unconfined my-claude
```

Then in any container:
```bash
claude auth    # Authenticate once (if needed)
claude         # Start Claude Code (with permission prompts)
claude-auto    # Start Claude Code (auto-accept all permissions)
# MCP servers are configured automatically on first run
```

## Configuration

### Simple .env Configuration

Just edit your `.env` file:
```bash
# Add any MCP servers you want (default: puppeteer,github)
MCP_SERVERS=puppeteer,github,filesystem,sqlite

# Add required tokens
GITHUB_TOKEN=ghp_your_token_here
# POSTGRES_URL=postgresql://localhost:5432/mydb
# BRAVE_API_KEY=your_api_key
```

Then rebuild: `docker-compose up -d --build claude-dev`

### Pre-configured Services
| Service | MCP Servers | Use Case |
|---------|-------------|----------|
| `claude-dev` | From `MCP_SERVERS` in .env (default: puppeteer,github) | Default service |
| `claude-full` | From `MCP_SERVERS_FULL` in .env | Full stack service |
| `claude-custom` | From `CUSTOM_MCP_SERVERS` in .env | Custom service |

### Custom Builds
```bash
# Web automation + file operations
docker build --build-arg MCP_SERVERS=puppeteer,filesystem -t claude-dev .

# Full stack with GitHub
docker build \
  --build-arg MCP_SERVERS=puppeteer,filesystem,github \
  --build-arg GITHUB_TOKEN=your_token \
  -t claude-full .
```

## MCP Setup

MCP servers are **automatically configured** on container startup based on the `MCP_SERVERS` build argument. No manual setup required!

### Verify Configuration
```bash
# Check configured servers
claude mcp list

# In Claude, use the /mcp command
/mcp
```

### Manual Setup (if needed)
```bash
# Add servers individually
claude mcp add puppeteer --scope user -- npx -y @modelcontextprotocol/server-puppeteer
```

## Usage Examples

### Web Automation with Puppeteer
```
Navigate to https://example.com
Take a screenshot named "homepage"
Click the link with text "More information"
Fill the input field with placeholder "Search" with "test query"
```

### File Operations (with filesystem server)
```
List files in the current directory
Read the contents of package.json
Create a new file called notes.txt with content "Hello World"
```

### GitHub Operations (with github server + token)
```
Search for repositories about machine learning
Create a new repository called "my-project"
Get the contents of README.md from user/repo
```

## Multi-Container Deployment

### Production Deployment
```bash
# Build specific variants
docker build --build-arg MCP_SERVERS=puppeteer -t claude:web .
docker build --build-arg MCP_SERVERS=filesystem -t claude:files .
docker build --build-arg MCP_SERVERS=puppeteer,github --build-arg GITHUB_TOKEN=token -t claude:github .

# Deploy multiple instances
docker run -d --name web-dev --cap-add=SYS_ADMIN claude:web
docker run -d --name file-dev --cap-add=SYS_ADMIN claude:files
docker run -d --name github-dev --cap-add=SYS_ADMIN claude:github
```

### Container Management
```bash
# Default service
docker-compose up -d claude-dev

# Full stack
docker-compose --profile full up -d

# Custom configuration
docker-compose --profile custom up -d

# Stop all
docker-compose down

# Rebuild
docker-compose build --no-cache
```

## File Structure

```
dev_container/
├── dockerfile              # Container with build-time MCP config
├── docker-compose.yml      # Multi-service configuration  
├── .env.example           # Environment variables
├── .gitignore             # Git ignore patterns
├── scripts/               # Container setup scripts
│   ├── claude-session.sh  # Persistent session manager
│   ├── claude-wrapper.sh  # Auto-accept prompts wrapper
│   ├── entrypoint.sh      # Auto-configures MCP on startup
│   ├── mcp-config.json    # MCP server configurations
│   └── setup-mcp-auto.sh  # Automatic MCP setup
└── workspace/             # Your working directory
```

## Available MCP Servers

| Server | Purpose | Requirements |
|--------|---------|-------------|
| `puppeteer` | Web automation, screenshots, form filling | None (default) |
| `filesystem` | File operations in workspace | None |
| `github` | GitHub API integration | `GITHUB_TOKEN` in .env |

## GitHub MCP Server Setup

The GitHub MCP server allows Claude to interact with GitHub repositories, issues, PRs, and more.

### Creating a GitHub Token

1. Go to [GitHub Settings > Tokens](https://github.com/settings/tokens/new)
2. Create a new token with these scopes:
   - **repo** - Full control of private repositories
   - **read:org** - Read org and team membership
   - **read:user** - Read user profile data
   - **gist** - Create gists
3. Copy the token (starts with `ghp_`)
4. Add to `.env` file:
   ```bash
   GITHUB_TOKEN=ghp_your_token_here
   ```

### GitHub MCP Usage Examples

Once configured, you can ask Claude to:
```
# Repository operations
- "Search for React repositories with more than 1000 stars"
- "Create a new repository called my-project"
- "Clone https://github.com/user/repo"

# Issues and PRs
- "List open issues in user/repo"
- "Create an issue titled 'Bug: XYZ not working'"
- "Review PR #123 in user/repo"

# Code search
- "Search for 'useState' in the React repository"
- "Find all TypeScript files in user/repo"

# Gists
- "Create a gist with this code snippet"
- "List my recent gists"
```

## Authentication Persistence

Your Claude login (including Max subscription) is automatically persisted in Docker volumes:
- `claude-dev-auth` - for the default container
- `claude-full-auth` - for the full stack container
- `claude-custom-auth` - for custom configurations

### Authentication Notes
- Authentication is persisted in Docker volumes
- Each service has its own auth volume (claude-dev-auth, claude-full-auth, etc.)
- To share authentication between containers, you can use Docker volume commands

## Troubleshooting

### Authentication Issues
```bash
# Re-authenticate
claude auth

# Check auth status
claude config

# Verify auth persistence
docker volume ls | grep claude
```

### Web Automation Issues
```bash
# Check Chromium installation
chromium --version

# Test with minimal flags
chromium --no-sandbox --headless --dump-dom https://example.com
```

### MCP Configuration
```bash
# View configured servers
claude mcp list

# View server details
claude mcp get puppeteer

# Remove a server
claude mcp remove puppeteer

# Add custom server
claude mcp add myserver -- /path/to/server
```

### Container Resources
Ensure Docker has sufficient resources:
- Memory: 2GB+ recommended
- CPU: 2+ cores for smooth operation

## Security Notes

- Container runs with elevated privileges for web automation
- Auto-accept mode enabled for development workflows
- Keep GitHub tokens secure and use minimal permissions
- Each service has isolated authentication and configuration