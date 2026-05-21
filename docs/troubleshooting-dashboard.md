# 排障：卡在 waiting for dashboard to become healthy

如果启动时卡在：

```text
info waiting for dashboard to become healthy
```

先看 `vllm-sr` 相关容器状态：

```bash
docker ps -a | grep -E 'vllm-sr|dashboard'
```

查看 dashboard 容器日志：

```bash
docker logs --tail 200 vllm-sr-dashboard-container
```

测试 dashboard 健康检查接口：

```bash
curl -v http://localhost:8700/healthz
```

如果 dashboard 容器已经退出，查看退出状态：

```bash
docker inspect vllm-sr-dashboard-container \
  --format 'status={{.State.Status}} exit={{.State.ExitCode}} error={{.State.Error}}'
```

检查 8700 端口是否被占用：

```bash
ss -lntp | grep 8700
```

确认相关镜像已经导入：

```bash
docker images | grep -E 'vllm-sr|dashboard|envoy|vllm-sr-sim|jaeger|prometheus|grafana'
```

常见原因：

- dashboard 镜像没有正确导入。
- 服务器架构和本地拉取镜像架构不一致，例如 ARM 服务器导入了 `linux/amd64` 镜像。
- 8700 端口已被占用。
- dashboard 容器启动时报错，需要看 `docker logs`。
