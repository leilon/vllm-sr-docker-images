# vllm-sr 默认 Docker 镜像离线迁移

这个仓库整理 `vllm-sr 0.3.0.dev20260521005044` 默认 `vllm-sr serve` 需要的 Docker 镜像离线迁移命令。

## 快速入口

- [默认镜像清单](docs/images.md)
- [本地机器：拉取并打包镜像](docs/local-packaging.md)
- [服务器：导入镜像并启动 vllm-sr](docs/server-load-and-start.md)
- [服务器：离线启动和 dashboard 诊断](docs/server-diagnosis.md)
- [本地访问服务器 dashboard：SSH 端口转发](docs/ssh-port-forwarding.md)
- **NEWEST / 最新**：[`pip install vllm-sr` 稳定版 0.2.0 是单容器流程](docs/newest-pip-install-stable-0.2-single-container.md)
- **NEWEST / 最新**：[dashboard image 存在，但没有 dashboard container](docs/newest-dashboard-image-but-no-container.md)
- [排障：卡在 waiting for dashboard to become healthy](docs/troubleshooting-dashboard.md)

## 最短流程

本地机器拉取全部 7 个默认镜像并打包：

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/pull-vllm-sr-default-images.sh | bash
```

如果配置需要本地存储后端，补拉 `redis/postgres/milvus` 这 3 个镜像：

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/pull-vllm-sr-storage-images.sh | bash
```

如果想一次性打包新版 CLI 可能用到的 10 个镜像：

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/pull-vllm-sr-all-images.sh | bash
```

把生成的文件传到服务器：

```text
vllm-sr-default-images.tar
vllm-sr-default-images.tar.sha256
```

服务器导入并启动：

```bash
sha256sum -c vllm-sr-default-images.tar.sha256
docker load -i vllm-sr-default-images.tar
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/serve-vllm-sr-offline.sh | bash
```

如果第一个 `vllm-sr:latest` 已经拉好了，只拉剩下 6 个：

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/pull-vllm-sr-remaining-images.sh | bash
```

如果服务器是 ARM64，把脚本里的 `linux/amd64` 改成 `linux/arm64` 后再拉取。

dashboard 卡住或找不到容器时，在服务器上跑诊断：

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/diagnose-vllm-sr-dashboard.sh | bash
```

**NEWEST / 最新判断**：如果你是 `pip install vllm-sr` 安装的稳定版，先看单容器说明：

```text
docs/newest-pip-install-stable-0.2-single-container.md
```

如果你是 `pip install --pre vllm-sr` 或安装到 `0.3.0.dev...`，且 dashboard image 已经存在但没有 dashboard container，看这里：

```text
docs/newest-dashboard-image-but-no-container.md
```

如果 dashboard 已经在服务器启动，但本地浏览器无法直接访问，用 SSH 端口转发：

```bash
ssh -v -o ExitOnForwardFailure=yes -N -L 127.0.0.1:18700:127.0.0.1:8700 <USER>@<SERVER_IP>
```

然后本地打开：

```text
http://127.0.0.1:18700
```

完整排障命令见：

```text
docs/ssh-port-forwarding.md
```
