#!/usr/bin/env bash
set -euo pipefail

PLATFORM="${PLATFORM:-linux/amd64}"

IMAGES=(
  "envoyproxy/envoy:v1.34-latest"
  "ghcr.io/vllm-project/semantic-router/dashboard:latest"
  "ghcr.io/vllm-project/semantic-router/vllm-sr-sim:latest"
  "jaegertracing/all-in-one:latest"
  "prom/prometheus:v2.53.0"
  "grafana/grafana:11.5.1"
)

for image in "${IMAGES[@]}"; do
  docker pull --platform "${PLATFORM}" "${image}"
done
