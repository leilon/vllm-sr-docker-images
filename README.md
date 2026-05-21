# vllm-sr 默认 Docker 镜像离线迁移命令

适用于 `vllm-sr 0.3.0.dev20260521005044` 默认 `vllm-sr serve`。

## 本地机器：拉取默认镜像

如果 7 个镜像都还没拉：

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

## 本地机器：打包成 tar

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

## 服务器：导入镜像

如果传了校验文件，先校验：

```bash
sha256sum -c vllm-sr-default-images.tar.sha256
```

导入镜像：

```bash
docker load -i vllm-sr-default-images.tar
```

确认 7 个镜像都已经在服务器本地：

```bash
docker images | grep -E 'vllm-sr|dashboard|envoy|vllm-sr-sim|jaeger|prometheus|grafana'
```

应该能看到类似这些镜像：

```text
ghcr.io/vllm-project/semantic-router/vllm-sr
envoyproxy/envoy
ghcr.io/vllm-project/semantic-router/dashboard
ghcr.io/vllm-project/semantic-router/vllm-sr-sim
jaegertracing/all-in-one
prom/prometheus
grafana/grafana
```

## 服务器：安装 vllm-sr CLI

如果服务器还没有安装 `vllm-sr`，先安装 CLI，但跳过 Docker 自动启动：

```bash
curl -fsSL https://vllm-semantic-router.com/install.sh | bash -s -- --runtime skip --no-launch
```

让当前 shell 能找到 `vllm-sr`：

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## 服务器：启动 vllm-sr

启动时一定加 `--image-pull-policy never`，避免它再次尝试 `docker pull`：

```bash
vllm-sr serve --image-pull-policy never
```

如果报缺镜像，看报错里的这一行：

```text
Image not found locally: ...
```

缺哪个镜像，就在本地机器补拉、重新 `docker save` 或单独保存那个镜像后再传到服务器 `docker load`。

## 一键脚本

拉取全部 7 个镜像：

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/pull-vllm-sr-default-images.sh | bash
```

只拉剩下 6 个镜像：

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/pull-vllm-sr-remaining-images.sh | bash
```

如果服务器是 ARM64，把 `linux/amd64` 改成 `linux/arm64` 再拉取。
