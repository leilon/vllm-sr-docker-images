#!/usr/bin/env bash
set -euo pipefail

PLATFORM="${PLATFORM:-linux/amd64}"
OUT="${OUT:-vllm-sr-storage-images.tar}"

IMAGES=(
  "redis:7-alpine"
  "postgres:16-alpine"
  "milvusdb/milvus:v2.3.3"
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
echo "  docker images | grep -E 'redis|postgres|milvus'"
