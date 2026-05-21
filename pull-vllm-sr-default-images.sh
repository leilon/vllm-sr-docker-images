#!/usr/bin/env bash
set -euo pipefail

PLATFORM="${PLATFORM:-linux/amd64}"
OUT="${OUT:-vllm-sr-default-images.tar}"

IMAGES=(
  "ghcr.io/vllm-project/semantic-router/vllm-sr:latest"
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

docker save "${IMAGES[@]}" -o "${OUT}"
sha256sum "${OUT}" > "${OUT}.sha256"

echo "Wrote ${OUT}"
echo "Wrote ${OUT}.sha256"
echo
echo "Copy both files to the server, then run:"
echo "  sha256sum -c ${OUT}.sha256"
echo "  docker load -i ${OUT}"
echo "  vllm-sr serve --image-pull-policy never"
