FROM ubuntu:24.04

ARG NODE_MAJOR=22

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    gnupg \
    git \
    python3 \
    python3-venv \
    sudo \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
    > /etc/apt/sources.list.d/nodesource.list \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nodejs \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g @openai/codex @anthropic-ai/claude-code \
  && npm cache clean --force

RUN if id -u ubuntu >/dev/null 2>&1; then \
    usermod --shell /bin/bash ubuntu; \
  else \
    useradd --create-home --shell /bin/bash ubuntu; \
  fi \
  && mkdir -p /home/ubuntu \
  && chown ubuntu:ubuntu /home/ubuntu \
  && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu \
  && chmod 0440 /etc/sudoers.d/ubuntu \
  && mkdir -p /workspace \
  && chown ubuntu:ubuntu /workspace

WORKDIR /workspace
USER ubuntu
