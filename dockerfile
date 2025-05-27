# Claude Code Development Container - Build-time MCP configuration
FROM node:20-bookworm

# Build arguments for MCP configuration
ARG MCP_SERVERS=puppeteer,github
ARG GITHUB_TOKEN=""
ARG PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Install Chromium and dependencies for web automation
RUN apt-get update && apt-get install -y \
    chromium \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libxcomposite1 \
    libxrandr2 \
    xdg-utils \
    sudo \
    jq \
    tmux \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Create non-root user
RUN useradd -m -s /bin/bash claude || true && \
    usermod -aG sudo claude && \
    echo "claude ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create directories with proper ownership
RUN mkdir -p /home/claude/.claude /home/claude/.config/claude /workspace && \
    chown -R claude:claude /home/claude /workspace

# Configure Claude settings to allow all tools
RUN echo '{"permissions":{"allow":["*"]}}' > /home/claude/.claude/settings.json && \
    chown claude:claude /home/claude/.claude/settings.json

# Copy scripts and configuration
COPY scripts/setup-mcp.sh /usr/local/bin/setup-mcp
COPY scripts/setup-mcp-auto.sh /usr/local/bin/setup-mcp-auto
COPY scripts/mcp-config.json /usr/local/bin/mcp-config.json
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/claude-wrapper.sh /usr/local/bin/claude-auto
COPY scripts/claude-session.sh /usr/local/bin/claude-session
RUN chmod +x /usr/local/bin/setup-mcp /usr/local/bin/setup-mcp-auto /usr/local/bin/entrypoint.sh /usr/local/bin/claude-auto /usr/local/bin/claude-session

# Set environment for web automation
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Store build args as environment variables for runtime
ENV MCP_SERVERS=${MCP_SERVERS}
ENV GITHUB_TOKEN=${GITHUB_TOKEN}

# Create a startup script to fix permissions
RUN echo '#!/bin/bash\n\
if [ -d /home/claude/.claude ]; then\n\
    sudo chown -R claude:claude /home/claude/.claude 2>/dev/null || true\n\
fi\n\
sudo chown -R claude:claude /workspace 2>/dev/null || true\n\
exec "$@"' > /usr/local/bin/fix-permissions.sh && \
    chmod +x /usr/local/bin/fix-permissions.sh

# Switch to non-root user
USER claude
WORKDIR /workspace

# Set entrypoint and default command
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]