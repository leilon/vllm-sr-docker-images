$ErrorActionPreference = "Stop"

$Platform = if ($env:PLATFORM) { $env:PLATFORM } else { "linux/amd64" }
$Out = if ($env:OUT) { $env:OUT } else { "vllm-sr-default-images.tar" }

$Images = @(
  "ghcr.io/vllm-project/semantic-router/vllm-sr:latest",
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

docker save @Images -o $Out

if (Get-Command sha256sum -ErrorAction SilentlyContinue) {
  sha256sum $Out | Set-Content -NoNewline "$Out.sha256"
} else {
  $Hash = (Get-FileHash -Algorithm SHA256 $Out).Hash.ToLowerInvariant()
  "$Hash  $Out" | Set-Content -NoNewline "$Out.sha256"
}

Write-Host "Wrote $Out"
Write-Host "Wrote $Out.sha256"
Write-Host ""
Write-Host "Copy both files to the server, then run:"
Write-Host "  sha256sum -c $Out.sha256"
Write-Host "  docker load -i $Out"
Write-Host "  vllm-sr serve --image-pull-policy never"
