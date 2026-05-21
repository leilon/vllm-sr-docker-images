$ErrorActionPreference = "Stop"

$Platform = if ($env:PLATFORM) { $env:PLATFORM } else { "linux/amd64" }

$Images = @(
  "envoyproxy/envoy:v1.34-latest",
  "ghcr.io/vllm-project/semantic-router/dashboard:latest",
  "ghcr.io/vllm-project/semantic-router/vllm-sr-sim:latest",
  "jaegertracing/all-in-one:latest",
  "prom/prometheus:v2.53.0",
  "grafana/grafana:11.5.1"
)

foreach ($Image in $Images) {
  docker pull --platform $Platform $Image
}
