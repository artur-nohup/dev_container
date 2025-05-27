# Persistent Claude Sessions Guide

Claude Code is an interactive CLI tool, not a background service. Here's how to maintain persistent sessions:

## Method 1: Using tmux (Recommended)

### Start a persistent session:
```bash
# Enter container
docker exec -it claude-dev bash

# Start tmux session named 'claude'
tmux new -s claude

# Run Claude inside tmux
claude
# or
claude-auto
```

### Detach from session:
- Press `Ctrl+B` then `D`
- You're back at container shell, Claude keeps running

### Reattach to session:
```bash
# From outside container
docker exec -it claude-dev tmux attach -t claude

# Or if already in container
tmux attach -t claude
```

### List active sessions:
```bash
docker exec -it claude-dev tmux ls
```

## Method 2: Using docker attach (Limited)

### Start container with Claude:
```bash
# Start container in background
docker run -d --name claude-session \
  --cap-add=SYS_ADMIN \
  --security-opt=seccomp:unconfined \
  -v ./workspace:/workspace \
  claude-dev:latest \
  bash -c "claude-auto"
```

### Attach to running container:
```bash
docker attach claude-session
```

### Detach without stopping:
- Press `Ctrl+P` then `Ctrl+Q`

**⚠️ Limitation**: This only works if Claude is running non-interactively

## Method 3: Logging Claude Output

### Save session to file:
```bash
# Using script command
script -f claude-session.log
claude

# Or using tee
claude | tee -a claude-session.log
```

### View log from outside:
```bash
docker exec claude-dev tail -f /workspace/claude-session.log
```

## Best Practices

### 1. **Use tmux for long-running tasks**:
```bash
docker exec -it claude-dev bash
tmux new -s claude
claude-auto
# Work with Claude...
# Ctrl+B, D to detach
```

### 2. **Save important outputs**:
- Claude conversations are saved in `~/.claude/projects/`
- Use `/workspace` for persistent file storage
- Copy important code to files

### 3. **Create aliases** (add to .bashrc):
```bash
echo 'alias claude-session="tmux new -s claude -d claude-auto 2>/dev/null || tmux attach -t claude"' >> ~/.bashrc
```

## Quick Commands

### Start persistent Claude session:
```bash
docker exec -it claude-dev bash -c "tmux new -s claude -d 'claude-auto' || tmux attach -t claude"
```

### Check if Claude is running:
```bash
docker exec claude-dev tmux list-sessions 2>/dev/null | grep claude
```

### Kill Claude session:
```bash
docker exec claude-dev tmux kill-session -t claude
```

## Important Notes

1. **Claude Code is interactive** - It expects human input
2. **No daemon mode** - Claude doesn't run in background by itself
3. **Sessions persist** - Your conversation history is saved in the container
4. **Use tmux** - Best solution for detachable sessions
5. **Workspace persists** - All files in `/workspace` are saved

## Example Workflow

```bash
# 1. Start container
docker-compose up -d claude-dev

# 2. Create tmux session with Claude
docker exec -it claude-dev tmux new -s work

# 3. Inside tmux, run Claude
claude-auto

# 4. Work with Claude...
# "Create a Python script that..."

# 5. Detach (Ctrl+B, D)

# 6. Later, reattach
docker exec -it claude-dev tmux attach -t work

# 7. Continue where you left off!
```