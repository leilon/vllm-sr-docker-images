# NEWEST / 最新：dashboard image 存在，但没有 dashboard container

这个判断用于这种情况：

- `docker images` 能看到 `ghcr.io/vllm-project/semantic-router/dashboard:latest`。
- `vllm-sr serve` 卡在 `Waiting for Dashboard to become healthy`。
- 但 `docker ps -a` 里找不到 `vllm-sr-dashboard-container`，或者找不到任何 dashboard 容器。

结论先放前面：**image 存在只说明镜像已经导入；container 只有在 `vllm-sr serve` 成功执行到 dashboard 的 `docker run` 阶段时才会创建。**

## 先跑这组命令

在服务器上执行：

```bash
docker context show
echo "$DOCKER_HOST"
env | grep -E '^VLLM_SR_|^DASHBOARD_|^DISABLE_DASHBOARD|^DOCKER_HOST' || true

docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}' \
  | grep -E 'vllm-sr|semantic-router|dashboard|envoy|vllm-sr-sim|jaeger|prometheus|grafana' || true

docker ps -a --no-trunc --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' \
  | grep -Ei 'vllm|semantic|dashboard|envoy|grafana|prometheus|jaeger' || true

grep -Ein 'Starting .*container|dashboard|Failed to start|Waiting for Dashboard|port is already allocated|Image not found|permission denied|exec format error|no such container' \
  vllm-sr-serve.log || true
```

如果启动日志不在当前目录，先用实际路径替换 `vllm-sr-serve.log`。

## 怎么判断

### 1. 日志里没有 `Starting dashboard container`

如果没有类似这一行：

```text
Starting dashboard container: vllm-sr-dashboard-container
```

说明 `vllm-sr serve` 在创建 dashboard 之前就失败或退出了。往前看这些组件的报错：

- `Jaeger`
- `Prometheus`
- `Grafana`
- `vllm-sr-sim`
- `router`
- `envoy`
- `Image not found locally`
- `port is already allocated`
- `permission denied`
- `exec format error`

这时 dashboard image 存在也没有用，因为程序还没有走到创建 dashboard container 的步骤。

### 2. 日志里有 `Starting dashboard container`，但 `docker ps -a` 找不到

这时优先怀疑 **Docker context / Docker 用户不一致**。

常见情况：

- `vllm-sr serve` 是用 `sudo` 启动的，但你用普通用户 `docker ps -a` 查看。
- 当前 shell 的 `DOCKER_HOST` 不同。
- Docker rootless / rootful 混用。
- `docker context` 不是同一个。

检查：

```bash
docker context ls
docker info --format 'Name={{.Name}} ServerVersion={{.ServerVersion}} DockerRootDir={{.DockerRootDir}}'

sudo docker ps -a --no-trunc --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' \
  | grep -Ei 'vllm|semantic|dashboard|envoy|grafana|prometheus|jaeger' || true
```

如果 `sudo docker ps -a` 能看到 dashboard，而普通 `docker ps -a` 看不到，就说明不是 vllm-sr 没创建，而是你看的是另一个 Docker daemon / socket。

### 3. 名字不是默认名

如果设置了 `VLLM_SR_STACK_NAME`，dashboard 名字会变成：

```text
<stack-name>-vllm-sr-dashboard-container
```

直接找：

```bash
docker ps -a --format '{{.Names}}' | grep dashboard
```

找到后看日志：

```bash
DASHBOARD_CONTAINER="$(docker ps -a --format '{{.Names}}' | grep dashboard | head -n1)"
echo "$DASHBOARD_CONTAINER"
docker logs --tail 200 "$DASHBOARD_CONTAINER"
```

### 4. 容器创建后立刻退出

如果 `docker ps -a` 能看到 dashboard，但状态是 `Exited`，看退出原因：

```bash
DASHBOARD_CONTAINER="$(docker ps -a --format '{{.Names}}' | grep dashboard | head -n1)"
docker inspect "$DASHBOARD_CONTAINER" \
  --format 'status={{.State.Status}} exit={{.State.ExitCode}} error={{.State.Error}}'
docker logs --tail 200 "$DASHBOARD_CONTAINER"
```

常见原因：

- 端口 8700 被占用。
- 服务器架构和镜像架构不一致。
- 挂载目录权限异常。
- dashboard 启动脚本或配置读取失败。

## 最短结论

如果 **image 有、container 完全没有**，优先级是：

1. 看 `vllm-sr-serve.log` 有没有 `Starting dashboard container`。
2. 没有这行：dashboard 之前就失败了。
3. 有这行但 `docker ps -a` 找不到：大概率是 Docker context / sudo 用户不一致。
4. 能看到但 `Exited`：看 `docker logs` 和 `docker inspect`。
