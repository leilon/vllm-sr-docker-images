# 本地访问服务器 dashboard：SSH 端口转发

这些命令用于在本地浏览器访问服务器上的 vllm-sr dashboard。命令中的 `<USER>` 和 `<SERVER_IP>` 换成你自己的登录用户名和服务器地址。

## 最常用命令

在本地机器执行，不要在已经 SSH 进去的服务器 shell 里执行：

```bash
ssh -v -o ExitOnForwardFailure=yes -N -L 127.0.0.1:18700:127.0.0.1:8700 <USER>@<SERVER_IP>
```

成功后这个终端会停住，这是正常的。`-N` 表示只做端口转发，不进入远程 shell。

然后在本地浏览器打开：

```text
http://127.0.0.1:18700
```

如果不需要详细日志，也可以用简短版：

```bash
ssh -N -L 18700:127.0.0.1:8700 <USER>@<SERVER_IP>
```

## 第一次连接提示 fingerprint

如果 SSH 提示：

```text
The authenticity of host '<SERVER_IP>' can't be established.
This key is not known by any other names.
Are you sure you want to continue connecting?
```

确认 `<SERVER_IP>` 是目标服务器，并且 fingerprint 和云平台或服务器控制台里的一致后，输入：

```text
yes
```

如果以后出现 `REMOTE HOST IDENTIFICATION HAS CHANGED`，不要直接跳过，先确认服务器是否重装或 IP 是否被复用。

## 输入密码后卡住不动

如果你用了 `ssh -N -L ...`，输入密码后没有命令提示符，通常说明隧道已经连上。保持这个终端不要关闭。

可以在另一个本地终端验证：

```bash
curl -v http://127.0.0.1:18700/
```

或者检查本地端口是否监听：

```bash
ss -lntp | grep 18700
```

如果没有 `ss`，试：

```bash
lsof -iTCP:18700 -sTCP:LISTEN -n -P
```

## address already in use

如果 SSH 提示：

```text
bind 127.0.0.1:18700: Address already in use
```

说明本地 `18700` 已经被占用。最简单是换一个本地端口：

```bash
ssh -v -o ExitOnForwardFailure=yes -N -L 127.0.0.1:18701:127.0.0.1:8700 <USER>@<SERVER_IP>
```

然后打开：

```text
http://127.0.0.1:18701
```

也可以查谁占用了端口：

```bash
ss -lntp | grep 18700
```

或：

```bash
lsof -iTCP:18700 -sTCP:LISTEN -n -P
```

如果看到是旧的 `ssh` 进程，可以结束旧隧道后再重开。

## 端口被 docker-proxy 占用

如果占用端口的是 `docker-proxy`，说明本机或服务器上有 Docker 容器映射了这个端口。

查容器：

```bash
docker ps --format 'table {{.Names}}\t{{.Ports}}' | grep 18700
```

如果之前用的是 `8800`，就查：

```bash
docker ps --format 'table {{.Names}}\t{{.Ports}}' | grep 8800
```

不想动容器时，直接换 SSH 本地端口即可：

```bash
ssh -N -L 18701:127.0.0.1:8700 <USER>@<SERVER_IP>
```

## 浏览器显示 127.0.0.1 拒绝连接

先确认本地转发端口是否真的监听：

```bash
ss -lntp | grep 18700
```

如果没有输出，说明隧道没有建立成功。重新执行带诊断的命令：

```bash
ssh -v -o ExitOnForwardFailure=yes -N -L 127.0.0.1:18700:127.0.0.1:8700 <USER>@<SERVER_IP>
```

成功日志里应该能看到类似：

```text
Local forwarding listening on 127.0.0.1 port 18700
```

如果日志显示的是：

```text
Local forwarding listening on ::1 port 18800
```

说明 SSH 正在监听 IPv6 loopback `::1` 的 `18800`，不是 `127.0.0.1:18700`。这时打开：

```text
http://localhost:18800
```

或：

```text
http://[::1]:18800
```

如果想强制只监听 IPv4 的 `127.0.0.1`，重新执行：

```bash
ssh -v -o ExitOnForwardFailure=yes -N -L 127.0.0.1:18800:127.0.0.1:8700 <USER>@<SERVER_IP>
```

如果本地 `18700` 已经监听，但浏览器仍然拒绝连接，去服务器上查 dashboard 端口：

```bash
ss -lntp | grep -E '8700|8800'
docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep -E '8700|8800|vllm-sr'
```

如果 SSH 窗口里出现：

```text
channel ... open failed: connect failed: Connection refused
```

说明 SSH 隧道已经建立，但服务器自己的 `127.0.0.1:8700` 没有服务在监听，需要先修 dashboard 启动问题。

## 服务器实际监听的不是 8700

如果服务器上 Docker 把 dashboard 映射成了 `8800 -> 8700`，SSH 目标端口要改成服务器实际监听的端口：

```bash
ssh -N -L 18700:127.0.0.1:8800 <USER>@<SERVER_IP>
```

然后本地仍然打开：

```text
http://127.0.0.1:18700
```

## 一次转发多个 vllm-sr 端口

```bash
ssh -N \
  -L 18700:127.0.0.1:8700 \
  -L 18899:127.0.0.1:8899 \
  -L 18080:127.0.0.1:8080 \
  -L 19190:127.0.0.1:9190 \
  <USER>@<SERVER_IP>
```

常用对应关系：

```text
本地 18700 -> 服务器 8700   dashboard
本地 18899 -> 服务器 8899   vllm-sr listener
本地 18080 -> 服务器 8080   router api
本地 19190 -> 服务器 9190   metrics
```
