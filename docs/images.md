# 默认镜像清单

适用于 `vllm-sr 0.3.0.dev20260521005044` 默认 `vllm-sr serve`。

默认需要 7 个镜像：

```text
ghcr.io/vllm-project/semantic-router/vllm-sr:latest
envoyproxy/envoy:v1.34-latest
ghcr.io/vllm-project/semantic-router/dashboard:latest
ghcr.io/vllm-project/semantic-router/vllm-sr-sim:latest
jaegertracing/all-in-one:latest
prom/prometheus:v2.53.0
grafana/grafana:11.5.1
```

如果配置里额外启用了本地存储后端，可能还需要：

```text
redis:7-alpine
postgres:16-alpine
milvusdb/milvus:v2.3.3
```

只补存储后端时，需要 3 个镜像：

```text
redis:7-alpine
postgres:16-alpine
milvusdb/milvus:v2.3.3
```

最稳的完整离线包是 10 个镜像：

```text
ghcr.io/vllm-project/semantic-router/vllm-sr:latest
envoyproxy/envoy:v1.34-latest
ghcr.io/vllm-project/semantic-router/dashboard:latest
ghcr.io/vllm-project/semantic-router/vllm-sr-sim:latest
jaegertracing/all-in-one:latest
prom/prometheus:v2.53.0
grafana/grafana:11.5.1
redis:7-alpine
postgres:16-alpine
milvusdb/milvus:v2.3.3
```

默认安装和默认启动通常只需要前 7 个；如果配置触发本地存储后端，就补后 3 个。
