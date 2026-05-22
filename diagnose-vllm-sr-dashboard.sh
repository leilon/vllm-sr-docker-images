#!/usr/bin/env bash
set -u

LOG="${LOG:-vllm-sr-diagnose-$(date +%Y%m%d-%H%M%S).log}"

run() {
  echo
  echo "## $*"
  "$@"
}

{
  echo "# vllm-sr dashboard diagnosis"
  echo "time=$(date -Is)"
  echo "user=$(id -un 2>/dev/null || true)"

  run docker version
  run docker context ls
  run docker info --format 'Name={{.Name}} ServerVersion={{.ServerVersion}} DockerRootDir={{.DockerRootDir}}'

  echo
  echo "## vllm-sr command"
  command -v vllm-sr || true
  vllm-sr --version 2>/dev/null || true

  echo
  echo "## relevant environment variables"
  env | grep -E '^VLLM_SR_|^DASHBOARD_|^DISABLE_DASHBOARD|^DOCKER_HOST' || true

  echo
  echo "## relevant images"
  docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}' \
    | grep -E 'vllm-sr|semantic-router|dashboard|envoy|vllm-sr-sim|jaeger|prometheus|grafana' || true

  echo
  echo "## relevant containers"
  docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' \
    | grep -E 'vllm|semantic|dashboard|envoy|grafana|prometheus|jaeger' || true

  echo
  echo "## dashboard container discovery"
  DASHBOARD_CONTAINER="$(docker ps -a --format '{{.Names}}' | grep 'dashboard' | head -n1 || true)"
  echo "DASHBOARD_CONTAINER=${DASHBOARD_CONTAINER}"

  if [ -n "${DASHBOARD_CONTAINER}" ]; then
    run docker inspect "${DASHBOARD_CONTAINER}" \
      --format 'name={{.Name}} status={{.State.Status}} exit={{.State.ExitCode}} error={{.State.Error}}'

    echo
    echo "## dashboard logs"
    docker logs --tail 200 "${DASHBOARD_CONTAINER}" || true
  else
    echo "No dashboard container was found. This usually means vllm-sr did not create it."
  fi

  echo
  echo "## port 8700"
  ss -lntp 2>/dev/null | grep 8700 || true

  echo
  echo "## dashboard health"
  curl -v --max-time 5 http://localhost:8700/healthz 2>&1 || true
} 2>&1 | tee "${LOG}"

echo
echo "Wrote ${LOG}"
