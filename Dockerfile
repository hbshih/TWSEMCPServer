FROM python:3.13-slim

ENV PYTHONUNBUFFERED=1 PIP_NO_PYTHON_VERSION_WARNING=1

# System deps + Node 20 (for fastmcp dev UI/SSE)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates gnupg && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
      gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" \
      > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && ln -s /root/.local/bin/uv /usr/local/bin/uv

WORKDIR /app
COPY . /app

# Python deps
RUN uv sync --frozen

EXPOSE 8080
# Serve FastMCP over HTTP/SSE on $PORT
CMD ["bash","-lc","uv run fastmcp dev server.py --ui-port ${PORT:-8080}"]
