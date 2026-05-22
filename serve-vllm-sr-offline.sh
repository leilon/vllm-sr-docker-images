#!/usr/bin/env bash
set -euo pipefail

LOG="${LOG:-vllm-sr-serve.log}"
EXTRA_ARGS="${EXTRA_ARGS:-}"

export PATH="${HOME}/.local/bin:${PATH}"

if ! command -v vllm-sr >/dev/null 2>&1; then
  echo "vllm-sr CLI not found in PATH."
  echo "Install it first, for example:"
  echo "  curl -fsSL https://vllm-semantic-router.com/install.sh | bash -s -- --runtime skip --no-launch"
  exit 1
fi

echo "Stopping existing vllm-sr stack if present..."
vllm-sr stop || true

echo "Starting vllm-sr with local Docker images only..."
echo "Log file: ${LOG}"

# EXTRA_ARGS can be used for public, non-secret vllm-sr serve flags.
# Example: EXTRA_ARGS="--stack-name test" ./serve-vllm-sr-offline.sh
vllm-sr serve --image-pull-policy never ${EXTRA_ARGS} 2>&1 | tee "${LOG}"
