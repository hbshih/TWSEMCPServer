FROM python:3.13-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_PYTHON_VERSION_WARNING=1

# Optional: system deps
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager/runner)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
  && ln -s /root/.local/bin/uv /usr/local/bin/uv

WORKDIR /app
COPY . /app

# Install Python deps declared by the project
RUN uv sync --frozen

EXPOSE 8080

# For Render/Heroku-style platforms, $PORT is provided at runtime.
# Use dev server (hot reload off in containers) or switch to `run` if you prefer.
CMD ["bash","-lc","uv run fastmcp dev --port ${PORT:-8080} server.py"]
# Alternative:
# CMD ["bash","-lc","uv run fastmcp run server.py --host 0.0.0.0 --port ${PORT:-8080}"]
