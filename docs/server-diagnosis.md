# 服务器：离线启动和 dashboard 诊断

这些命令在服务器上执行。它们不会上传日志，只会在当前目录生成本地日志文件，方便你自己查看或脱敏后再分享。

## 离线启动并保存启动日志

如果镜像已经 `docker load` 到服务器，用这个命令启动，并把启动过程保存到 `vllm-sr-serve.log`：

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/serve-vllm-sr-offline.sh | bash
```

等价的手动命令是：

```bash
vllm-sr stop || true
vllm-sr serve --image-pull-policy never 2>&1 | tee vllm-sr-serve.log
```

如果你要额外传 `vllm-sr serve` 参数，可以先下载脚本再执行：

```bash
curl -fsSLO https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/serve-vllm-sr-offline.sh
chmod +x serve-vllm-sr-offline.sh
EXTRA_ARGS="--stack-name test" ./serve-vllm-sr-offline.sh
```

## 一键诊断 dashboard

当启动卡在 `info waiting for dashboard to become healthy`，或者 `docker logs vllm-sr-dashboard-container` 提示 `No such container`，先跑：

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/diagnose-vllm-sr-dashboard.sh | bash
```

脚本会检查：

- 当前 Docker daemon、context 和 Docker root。
- `vllm-sr` 命令是否存在。
- 相关环境变量是否改变了 stack 或 dashboard 行为。
- 7 个默认镜像是否已经导入。
- 是否真的创建了 dashboard 容器。
- 如果找到了 dashboard 容器，自动打印最近 200 行日志。
- 8700 端口和 `http://localhost:8700/healthz`。

生成的日志文件类似：

```text
vllm-sr-diagnose-20260522-153000.log
```

如果日志里 `DASHBOARD_CONTAINER=` 后面是空的，说明问题不是容器名字变了，而是 dashboard 容器没有被创建出来。继续看 `vllm-sr-serve.log` 里第一次出现 `dashboard`、`container`、`image`、`failed`、`error`、`pull`、`not found` 的位置。

```bash
grep -Ein 'dashboard|container|image|failed|error|pull|not found|healthy|starting|started' vllm-sr-serve.log
tail -n 120 vllm-sr-serve.log
```
