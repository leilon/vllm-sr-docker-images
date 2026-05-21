# vllm-sr default Docker images

Default `vllm-sr serve` images for `vllm-sr 0.3.0.dev20260521005044`.

Raw script links:

```text
https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/pull-vllm-sr-default-images.sh
https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/pull-vllm-sr-default-images.ps1
```

Images:

```text
ghcr.io/vllm-project/semantic-router/vllm-sr:latest
envoyproxy/envoy:v1.34-latest
ghcr.io/vllm-project/semantic-router/dashboard:latest
ghcr.io/vllm-project/semantic-router/vllm-sr-sim:latest
jaegertracing/all-in-one:latest
prom/prometheus:v2.53.0
grafana/grafana:11.5.1
```

On the local machine with working Docker:

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/pull-vllm-sr-default-images.sh | bash
```

Or on Windows PowerShell:

```powershell
iwr -UseBasicParsing https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/pull-vllm-sr-default-images.ps1 | iex
```

Copy these generated files to the server:

```text
vllm-sr-default-images.tar
vllm-sr-default-images.tar.sha256
```

On the server:

```bash
sha256sum -c vllm-sr-default-images.tar.sha256
docker load -i vllm-sr-default-images.tar
vllm-sr serve --image-pull-policy never
```

If the server is ARM64, replace `linux/amd64` with `linux/arm64` before pulling:

```bash
PLATFORM=linux/arm64 bash pull-vllm-sr-default-images.sh
```
