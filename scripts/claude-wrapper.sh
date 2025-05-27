#!/bin/bash
# Wrapper script for Claude Code with dangerous permissions enabled

# Set environment to auto-accept dangerous mode warning
export CLAUDE_DANGEROUS_BYPASS_CONFIRM=true

# Run Claude with dangerous skip permissions flag
exec claude --dangerously-skip-permissions "$@"