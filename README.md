# vllm-sr default Docker image commands

Default `vllm-sr serve` images for `vllm-sr 0.3.0.dev20260521005044`.

Pull the default images on a local machine with working Docker:

```bash
docker pull --platform linux/amd64 ghcr.io/vllm-project/semantic-router/vllm-sr:latest
docker pull --platform linux/amd64 envoyproxy/envoy:v1.34-latest
docker pull --platform linux/amd64 ghcr.io/vllm-project/semantic-router/dashboard:latest
docker pull --platform linux/amd64 ghcr.io/vllm-project/semantic-router/vllm-sr-sim:latest
docker pull --platform linux/amd64 jaegertracing/all-in-one:latest
docker pull --platform linux/amd64 prom/prometheus:v2.53.0
docker pull --platform linux/amd64 grafana/grafana:11.5.1
```

If `ghcr.io/vllm-project/semantic-router/vllm-sr:latest` is already pulled, pull only the remaining six images:

```bash
docker pull --platform linux/amd64 envoyproxy/envoy:v1.34-latest && \
docker pull --platform linux/amd64 ghcr.io/vllm-project/semantic-router/dashboard:latest && \
docker pull --platform linux/amd64 ghcr.io/vllm-project/semantic-router/vllm-sr-sim:latest && \
docker pull --platform linux/amd64 jaegertracing/all-in-one:latest && \
docker pull --platform linux/amd64 prom/prometheus:v2.53.0 && \
docker pull --platform linux/amd64 grafana/grafana:11.5.1
```

Save them into one archive:

```bash
docker save \
  ghcr.io/vllm-project/semantic-router/vllm-sr:latest \
  envoyproxy/envoy:v1.34-latest \
  ghcr.io/vllm-project/semantic-router/dashboard:latest \
  ghcr.io/vllm-project/semantic-router/vllm-sr-sim:latest \
  jaegertracing/all-in-one:latest \
  prom/prometheus:v2.53.0 \
  grafana/grafana:11.5.1 \
  -o vllm-sr-default-images.tar
```

Generate a checksum:

```bash
sha256sum vllm-sr-default-images.tar > vllm-sr-default-images.tar.sha256
```

Copy these generated files to the server:

```text
vllm-sr-default-images.tar
vllm-sr-default-images.tar.sha256
```

Load them on the server:

```bash
sha256sum -c vllm-sr-default-images.tar.sha256
docker load -i vllm-sr-default-images.tar
```

Start `vllm-sr` without pulling again:

```bash
vllm-sr serve --image-pull-policy never
```

Optional one-command script:

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/pull-vllm-sr-default-images.sh | bash
```

Pull only the remaining six images:

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/pull-vllm-sr-remaining-images.sh | bash
```

If the server is ARM64, replace `linux/amd64` with `linux/arm64` before pulling.
