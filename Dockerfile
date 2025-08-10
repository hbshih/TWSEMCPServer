FROM python:3.13-slim

# Install Node 20
RUN apt-get update && apt-get install -y curl ca-certificates gnupg \
  && mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
  && apt-get update && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && ln -s /root/.local/bin/uv /usr/local/bin/uv

WORKDIR /app
COPY . /app

# Python deps
RUN uv sync

# MCP HTTP bridge
RUN npm i -g @modelcontextprotocol/bridge@latest

EXPOSE 8080
CMD ["bash","-lc","npx -y @modelcontextprotocol/bridge serve --command 'uv run fastmcp run server.py' --port ${PORT:-8080} --verbose"]
