# 本地机器：拉取并打包镜像

在能正常访问 Docker Hub / GHCR 的本地机器执行。

## 拉取 7 个默认镜像

```bash
docker pull --platform linux/amd64 ghcr.io/vllm-project/semantic-router/vllm-sr:latest
docker pull --platform linux/amd64 envoyproxy/envoy:v1.34-latest
docker pull --platform linux/amd64 ghcr.io/vllm-project/semantic-router/dashboard:latest
docker pull --platform linux/amd64 ghcr.io/vllm-project/semantic-router/vllm-sr-sim:latest
docker pull --platform linux/amd64 jaegertracing/all-in-one:latest
docker pull --platform linux/amd64 prom/prometheus:v2.53.0
docker pull --platform linux/amd64 grafana/grafana:11.5.1
```

如果第一个 `vllm-sr:latest` 已经拉好了，只拉剩下 6 个：

```bash
docker pull --platform linux/amd64 envoyproxy/envoy:v1.34-latest && \
docker pull --platform linux/amd64 ghcr.io/vllm-project/semantic-router/dashboard:latest && \
docker pull --platform linux/amd64 ghcr.io/vllm-project/semantic-router/vllm-sr-sim:latest && \
docker pull --platform linux/amd64 jaegertracing/all-in-one:latest && \
docker pull --platform linux/amd64 prom/prometheus:v2.53.0 && \
docker pull --platform linux/amd64 grafana/grafana:11.5.1
```

## 打包成 tar

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

生成校验文件：

```bash
sha256sum vllm-sr-default-images.tar > vllm-sr-default-images.tar.sha256
```

把这两个文件传到服务器：

```text
vllm-sr-default-images.tar
vllm-sr-default-images.tar.sha256
```

## 一键脚本

拉取全部 7 个镜像并打包：

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/pull-vllm-sr-default-images.sh | bash
```

只拉剩下 6 个镜像：

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/pull-vllm-sr-remaining-images.sh | bash
```

如果服务器是 ARM64，把 `linux/amd64` 改成 `linux/arm64` 再拉取。
