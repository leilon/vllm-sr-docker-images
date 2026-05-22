# NEWEST / 最新：`pip install vllm-sr` 稳定版是单容器流程

如果你是这样安装的：

```bash
pip install vllm-sr
```

当前默认会安装 PyPI 稳定版 `vllm-sr 0.2.0`。这个版本和 `pip install --pre vllm-sr` 安装到的 `0.3.0.dev...` 启动结构不一样。

## 先确认版本

在服务器上执行：

```bash
vllm-sr --version
python -m pip show vllm-sr
```

如果显示的是 `0.2.0`，就按本文判断。

## 关键区别

`0.2.0` 没有独立的：

```text
vllm-sr-dashboard-container
```

它只有一个主容器：

```text
vllm-sr-container
```

dashboard、router、envoy 都在这个主容器内部由镜像自己的启动流程管理。

所以如果日志里没有：

```text
Starting dashboard container
```

这是正常的。这个日志属于 `0.3.0.dev...` 分容器版本，不属于 `0.2.0` 稳定版。

## bootstrap 流程

`0.2.0` 的 setup/bootstrap 大致是：

```text
vllm-sr serve
  -> 如果 config.yaml 不存在，创建 setup.mode=true 的 config.yaml
  -> 打印：Setup mode: starting dashboard-first bootstrap flow without router/envoy
  -> setup mode 下跳过 Jaeger / Prometheus / Grafana
  -> docker run -d --name vllm-sr-container ...
  -> 打印：vLLM Semantic Router container started successfully
  -> docker exec vllm-sr-container curl http://localhost:8700/healthz
  -> 打印：Waiting for Dashboard to become healthy...
```

也就是说，进入 `Waiting for Dashboard to become healthy` 后，应该优先查 `vllm-sr-container`，不是查 `vllm-sr-dashboard-container`。

## 服务器上直接查

```bash
docker ps -a --filter name=vllm-sr-container \
  --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'

docker inspect vllm-sr-container \
  --format 'status={{.State.Status}} exit={{.State.ExitCode}} error={{.State.Error}}'

docker logs --tail 300 vllm-sr-container
```

检查容器内部 dashboard 是否监听 8700：

```bash
docker exec vllm-sr-container sh -lc '
  ps -ef
  ss -lntp 2>/dev/null | grep 8700 || true
  curl -v http://localhost:8700/healthz
'
```

如果容器里有 supervisor 日志，再看 dashboard 相关日志：

```bash
docker exec vllm-sr-container sh -lc '
  ls -lah /var/log/supervisor 2>/dev/null || true
  tail -n 200 /var/log/supervisor/dashboard*.log /var/log/supervisor/*dashboard* 2>/dev/null || true
'
```

## 怎么判断

### 能看到 `vllm-sr-container`

问题在主容器内部 dashboard 服务没有健康起来。继续看：

```bash
docker logs --tail 300 vllm-sr-container
docker exec vllm-sr-container sh -lc 'curl -v http://localhost:8700/healthz'
```

### 看不到 `vllm-sr-container`

如果日志已经出现 `Waiting for Dashboard to become healthy`，但 `docker ps -a` 看不到 `vllm-sr-container`，优先怀疑：

- 你看的不是同一个 Docker context。
- `vllm-sr serve` 用了 `sudo`，但你用普通用户查 Docker。
- `DOCKER_HOST` 或 rootless/rootful Docker 不一致。
- 你看的日志不是这一次启动生成的。

检查：

```bash
docker context ls
docker context show
echo "$DOCKER_HOST"
docker info --format 'Name={{.Name}} ServerVersion={{.ServerVersion}} DockerRootDir={{.DockerRootDir}}'

sudo docker ps -a --filter name=vllm-sr-container \
  --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
```

## 镜像数量也不同

`0.2.0` 稳定版默认主流程使用：

```text
ghcr.io/vllm-project/semantic-router/vllm-sr:latest
```

非 setup mode 且启用观测栈时，还会用：

```text
jaegertracing/all-in-one:latest
prom/prometheus:v2.53.0
grafana/grafana:11.5.1
```

它不会使用独立的：

```text
ghcr.io/vllm-project/semantic-router/dashboard:latest
envoyproxy/envoy:v1.34-latest
ghcr.io/vllm-project/semantic-router/vllm-sr-sim:latest
```

这些是 `0.3.0.dev...` 分容器流程里的镜像。
