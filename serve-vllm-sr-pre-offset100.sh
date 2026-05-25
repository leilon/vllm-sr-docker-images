#!/usr/bin/env bash
set -euo pipefail

LOG="${LOG:-vllm-sr-serve-pre-offset100.log}"
EXTRA_ARGS="${EXTRA_ARGS:-}"

export VLLM_SR_STACK_NAME="${VLLM_SR_STACK_NAME:-pre100}"
export VLLM_SR_PORT_OFFSET="${VLLM_SR_PORT_OFFSET:-100}"
export PATH="${HOME}/.local/bin:${PATH}"

if ! command -v vllm-sr >/dev/null 2>&1; then
  echo "vllm-sr CLI not found in PATH."
  echo "Install the pre-release CLI first:"
  echo "  python -m venv .venv-pre"
  echo "  source .venv-pre/bin/activate"
  echo "  pip install --pre vllm-sr"
  exit 1
fi

echo "vllm-sr version:"
vllm-sr --version || true
echo "Stack name: ${VLLM_SR_STACK_NAME}"
echo "Port offset: ${VLLM_SR_PORT_OFFSET}"
echo "Image pull policy: never"
echo "Log file: ${LOG}"

# EXTRA_ARGS can be used for public, non-secret vllm-sr serve flags.
vllm-sr serve --image-pull-policy never ${EXTRA_ARGS} 2>&1 | tee "${LOG}"
