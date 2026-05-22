# 服务器：导入镜像并启动 vllm-sr

在服务器上执行。

## 导入镜像

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

## 安装 vllm-sr CLI

如果服务器还没有安装 `vllm-sr`，先安装 CLI，但跳过 Docker 自动启动：

```bash
curl -fsSL https://vllm-semantic-router.com/install.sh | bash -s -- --runtime skip --no-launch
```

让当前 shell 能找到 `vllm-sr`：

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## 启动 vllm-sr

启动时一定加 `--image-pull-policy never`，避免它再次尝试 `docker pull`：

```bash
vllm-sr serve --image-pull-policy never
```

如果想把启动过程同时保存成日志文件，用仓库里的脚本：

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/serve-vllm-sr-offline.sh | bash
```

如果报缺镜像，看报错里的这一行：

```text
Image not found locally: ...
```

缺哪个镜像，就在本地机器补拉、重新 `docker save` 或单独保存那个镜像后再传到服务器 `docker load`。
