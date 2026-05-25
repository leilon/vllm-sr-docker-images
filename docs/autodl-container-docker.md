# AutoDL 容器实例里的 Docker 限制

结论先放前面：普通 AutoDL 容器实例本身就是 Docker 容器，里面即使能 `apt install docker.io`，通常也不能正常 `docker pull`、`docker load`、`docker run`。这不是镜像传输问题，而是容器实例缺少 Docker-in-Docker 需要的内核权限。

AutoDL 官方文档也写明：容器实例内不支持使用 Docker；如果必须使用 Docker，需要租用裸金属服务器。

## 快速诊断

在 AutoDL 实例里执行：

```bash
ps -p 1 -o pid,comm,args
cat /proc/1/cgroup
mount | grep -E 'overlay|docker|containerd' | head
```

如果看到 PID 1 是平台启动脚本，根文件系统是 Docker overlay，说明你当前 SSH 进去的是容器实例，不是裸机宿主机。

再看权限：

```bash
capsh --print | grep -E 'Current:|Bounding'
unshare -Ur true
iptables -t nat -S
```

典型失败是：

```text
unshare: unshare failed: Operation not permitted
iptables ... Permission denied (you must be root)
```

这时 root 只是容器内 root，不是宿主机 root。缺少 `CAP_SYS_ADMIN`、`CAP_NET_ADMIN` 等能力时，Docker daemon 可以被强行启动成半残状态，但导入/解包镜像仍会失败。

## 验证 docker load 是否也会失败

即使不从公网 pull，只导入本地 tar，也要走 Docker daemon 解包层。可以用极小测试验证：

```bash
mkdir -p /tmp/docker-import-test-root
printf 'hello\n' >/tmp/docker-import-test-root/hello.txt
tar -C /tmp/docker-import-test-root -cf /tmp/docker-import-test.tar .

docker import /tmp/docker-import-test.tar local/tiny-import-test:probe
```

如果这里报：

```text
Error response from daemon: unshare: operation not permitted
```

那本地 `docker pull` 后传 `.tar` 到这台 AutoDL 容器实例，再跑 `docker load -i ...` 也大概率会失败。

## 正确的离线迁移路径

这条路径只适用于目标服务器有可用 Docker daemon 的情况，例如裸金属、虚拟机、或明确开放 Docker 的机器。

本地机器拉取并打包：

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/pull-vllm-sr-all-images.sh | bash
```

传到服务器：

```bash
scp -P <SSH_PORT> vllm-sr-all-images.tar vllm-sr-all-images.tar.sha256 <USER>@<SERVER_HOST>:/root/vllm_sr/
```

服务器导入：

```bash
cd /root/vllm_sr
sha256sum -c vllm-sr-all-images.tar.sha256
docker load -i vllm-sr-all-images.tar
docker images | grep -E 'vllm-sr|dashboard|envoy|vllm-sr-sim|jaeger|prometheus|grafana|redis|postgres|milvus'
```

如果这一步仍然出现 `unshare: operation not permitted`，说明目标机器不是可用 Docker 宿主机。

## pre 版 vllm-sr 离线启动，端口偏移 100

安装 pre 版 CLI：

```bash
cd /root/vllm_sr
python -m venv .venv-pre
source .venv-pre/bin/activate
pip install --pre vllm-sr
vllm-sr --version
```

启动时禁止自动拉镜像，并把端口整体偏移 100：

```bash
export VLLM_SR_STACK_NAME=pre100
export VLLM_SR_PORT_OFFSET=100
vllm-sr serve --image-pull-policy never
```

也可以直接用脚本：

```bash
curl -fsSL https://raw.githubusercontent.com/leilon/vllm-sr-docker-images/main/serve-vllm-sr-pre-offset100.sh | bash
```

常见端口偏移结果：

```text
listener: 8899 -> 8999
dashboard: 8700 -> 8800
router API: 8080 -> 8180
metrics: 9190 -> 9290
router gRPC: 50051 -> 50151
```
