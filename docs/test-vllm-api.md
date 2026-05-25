# 测试 vLLM / vllm-sr OpenAI 兼容接口

这些命令用于确认已有 vLLM 后端或 vllm-sr 新入口是否能正常处理 OpenAI 兼容的 chat completions 请求。

不要把真实 API key 写进命令文件。先在当前 shell 设置环境变量：

```bash
export VLLM_API_KEY='<YOUR_API_KEY>'
```

如果后端没有鉴权，可以把 `Authorization` 这一行删掉。

## 直连已有 vLLM 后端

这个命令直接访问本机 `8000` 端口上的 vLLM 服务：

```bash
curl --noproxy '*' \
  -H "Authorization: Bearer $VLLM_API_KEY" \
  -H "Content-Type: application/json" \
  http://127.0.0.1:8000/v1/chat/completions \
  -d '{
    "model": "qwen3-coder-next-fp8",
    "messages": [
      {"role": "user", "content": "hello"}
    ],
    "max_tokens": 32,
    "temperature": 0
  }'
```

如果想把模型名也变成变量：

```bash
export MODEL_NAME='qwen3-coder-next-fp8'

curl --noproxy '*' \
  -H "Authorization: Bearer $VLLM_API_KEY" \
  -H "Content-Type: application/json" \
  http://127.0.0.1:8000/v1/chat/completions \
  -d "{
    \"model\": \"${MODEL_NAME}\",
    \"messages\": [
      {\"role\": \"user\", \"content\": \"hello\"}
    ],
    \"max_tokens\": 32,
    \"temperature\": 0
  }"
```

## 经过 vllm-sr 入口测试

如果 vllm-sr 正常启动，客户端请求应该打 vllm-sr listener，而不是直接打原来的 vLLM 端口。默认 listener 通常是 `8899`：

```bash
curl --noproxy '*' \
  -H "Authorization: Bearer $VLLM_API_KEY" \
  -H "Content-Type: application/json" \
  http://127.0.0.1:8899/v1/chat/completions \
  -d '{
    "model": "qwen3-coder-next-fp8",
    "messages": [
      {"role": "user", "content": "hello through vllm-sr"}
    ],
    "max_tokens": 32,
    "temperature": 0
  }'
```

如果启动时设置了端口偏移，例如：

```bash
VLLM_SR_PORT_OFFSET=1000 vllm-sr serve --image-pull-policy never
```

那么默认 listener `8899` 会变成 `9899`：

```bash
curl --noproxy '*' \
  -H "Authorization: Bearer $VLLM_API_KEY" \
  -H "Content-Type: application/json" \
  http://127.0.0.1:9899/v1/chat/completions \
  -d '{
    "model": "qwen3-coder-next-fp8",
    "messages": [
      {"role": "user", "content": "hello through shifted vllm-sr"}
    ],
    "max_tokens": 32,
    "temperature": 0
  }'
```

## 快速判断失败位置

先确认端口是否监听：

```bash
sudo ss -lntp | grep -E ':8000|:8899|:9899'
```

直接查 vLLM 后端模型列表：

```bash
curl --noproxy '*' \
  -H "Authorization: Bearer $VLLM_API_KEY" \
  http://127.0.0.1:8000/v1/models
```

查 vllm-sr 入口是否能转发：

```bash
curl --noproxy '*' \
  -H "Authorization: Bearer $VLLM_API_KEY" \
  http://127.0.0.1:8899/v1/models
```

如果直连 `8000` 成功，但 `8899` 失败，优先看 vllm-sr / Envoy / router 日志。

如果 `8000` 也失败，先排查原 vLLM 实例。
