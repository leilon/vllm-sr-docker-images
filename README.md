# vllm-sr 默认 Docker 镜像离线迁移

这个仓库整理 `vllm-sr 0.3.0.dev20260521005044` 默认 `vllm-sr serve` 需要的 Docker 镜像离线迁移命令。

## 快速入口

- [默认镜像清单](docs/images.md)
- [本地机器：拉取并打包镜像](docs/local-packaging.md)
- [服务器：导入镜像并启动 vllm-sr](docs/server-load-and-start.md)
- [排障：卡在 waiting for dashboard to become healthy](docs/troubleshooting-dashboard.md)

## 最短流程

本地机器拉取全部 7 个默认镜像并打包：

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/pull-vllm-sr-default-images.sh | bash
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
vllm-sr serve --image-pull-policy never
```

如果第一个 `vllm-sr:latest` 已经拉好了，只拉剩下 6 个：

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/pull-vllm-sr-remaining-images.sh | bash
```

如果服务器是 ARM64，把脚本里的 `linux/amd64` 改成 `linux/arm64` 后再拉取。
