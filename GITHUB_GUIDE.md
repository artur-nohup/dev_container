# GitHub MCP Server Guide

## Quick Setup

1. **Create a GitHub Personal Access Token**:
   - Visit: https://github.com/settings/tokens/new
   - Name: "Claude Code MCP"
   - Select scopes:
     - ✅ **repo** (Full control of private repositories)
     - ✅ **read:org** (Read org and team membership)
     - ✅ **read:user** (Read user profile data)  
     - ✅ **gist** (Create gists)
   - Click "Generate token"
   - Copy token (starts with `ghp_`)

2. **Add to .env file**:
   ```bash
   GITHUB_TOKEN=ghp_your_actual_token_here
   ```

3. **Rebuild and start**:
   ```bash
   docker-compose down
   docker-compose build claude-dev
   docker-compose up -d claude-dev
   ```

## Verify GitHub MCP is Working

```bash
docker exec -it claude-dev bash
claude mcp list
# Should show: github: npx -y @modelcontextprotocol/server-github
```

## Usage Examples in Claude

### Repository Operations
```
"List my GitHub repositories"
"Search for TypeScript repositories with more than 100 stars"
"Create a new repository called test-project with MIT license"
"Get information about facebook/react repository"
```

### Issues and Pull Requests
```
"List open issues in owner/repo"
"Create an issue in owner/repo titled 'Bug: Feature X not working'"
"Show pull requests in owner/repo"
"Get details of PR #123 in owner/repo"
```

### Code Search
```
"Search for 'useState' in the facebook/react repository"
"Find all .py files in django/django"
"Search for 'TODO' comments in my repositories"
```

### Gists
```
"Create a gist with this Python script"
"List my recent gists"
"Get gist with ID abc123"
```

## Token Permissions Explained

- **repo**: Allows full access to public and private repositories
- **read:org**: Needed to see organization repositories
- **read:user**: Required for user profile operations
- **gist**: Enables creating and managing gists

## Security Best Practices

1. **Never commit your token**: The .env file is in .gitignore
2. **Use minimal scopes**: Only select the permissions you need
3. **Rotate regularly**: Create new tokens periodically
4. **Use separate tokens**: Different tokens for different projects

## Troubleshooting

### "GitHub server requested but GITHUB_TOKEN not provided"
- Make sure GITHUB_TOKEN is set in .env file
- Rebuild the container after adding the token

### "Authentication failed"
- Verify your token is valid at https://github.com/settings/tokens
- Check token has required scopes
- Ensure no extra spaces in .env file

### Testing GitHub Integration
```bash
# In Claude, try:
"List my GitHub profile information"
# Should return your GitHub username and profile details
```