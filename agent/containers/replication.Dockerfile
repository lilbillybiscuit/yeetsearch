FROM ubuntu:24.04

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    python3 \
    python3-venv \
  && rm -rf /var/lib/apt/lists/*

# Install the Codex CLI here for your local environment, then rebuild the image.
# Keep runtime replication containers network-isolated; preinstall build
# dependencies in this image rather than fetching them during replication.
#
# Example placeholder:
# RUN curl -fsSL <codex-install-url> | bash

WORKDIR /workspace
