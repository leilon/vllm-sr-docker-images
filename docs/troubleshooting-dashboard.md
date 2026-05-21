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

如果提示：

```text
No such container: vllm-sr-dashboard-container
```

先列出实际容器名：

```bash
docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' | grep -E 'vllm|semantic|dashboard|envoy|grafana|prometheus|jaeger'
```

如果设置过 `VLLM_SR_STACK_NAME`，容器名会变成：

```text
<stack-name>-vllm-sr-dashboard-container
```

查看当前 stack 名：

```bash
echo "${VLLM_SR_STACK_NAME:-default}"
```

也可以直接找 dashboard 容器：

```bash
docker ps -a --format '{{.Names}}' | grep dashboard
```

如果仍然没有 dashboard 容器，检查是不是 Docker 上下文或执行用户不一致：

```bash
docker context ls
docker info --format 'Name={{.Name}} ServerVersion={{.ServerVersion}} DockerRootDir={{.DockerRootDir}}'
```

如果 `vllm-sr serve` 是用 `sudo` 启动的，也要用 `sudo docker` 查看：

```bash
sudo docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' | grep -E 'vllm|semantic|dashboard|envoy|grafana|prometheus|jaeger'
```

反过来，如果当前是 rootless Docker，确认 Docker socket：

```bash
echo "$DOCKER_HOST"
docker context inspect --format '{{json .Endpoints}}'
```

再确认 `vllm-sr` 没有被环境变量切到 minimal 或自定义 stack：

```bash
env | grep -E '^VLLM_SR_|^DASHBOARD_|^DISABLE_DASHBOARD|^DOCKER_HOST'
```

重新启动时保存完整日志，方便确认 dashboard 有没有被创建：

```bash
vllm-sr stop || true
vllm-sr serve --image-pull-policy never 2>&1 | tee vllm-sr-serve.log
grep -Ei 'dashboard|container|image|failed|error|pull|not found' vllm-sr-serve.log
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
