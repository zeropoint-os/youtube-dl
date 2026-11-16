# YoutubeDL-Material Zeropoint module

This Terraform module deploys [YoutubeDL-Material](https://github.com/Tzahi12345/YoutubeDL-Material), a self-hosted web interface for downloading videos and audio.

## Resources Created

- **Docker Image**: Pulls the official `tzahi12345/youtubedl-material` image
- **Docker Container**: YoutubeDL-Material web application on the Zeropoint network
- **Persistent data**: Application configuration, downloads, subscriptions, and users under `zp_storage_dir`

## Requirements

- Terraform >= 1.0
- Docker provider ~> 3.0

## Usage

### Via zeropoint API

```bash
curl -X POST http://<zeropoint-node-name>:2370/modules/install \
  -H "Content-Type: application/json" \
  -d '{
    "source": "https://github.com/zeropoint-os/youtube-dl.git",
    "module_id": "youtube-dl-material"
  }'
```

### Manual (for testing)

Use Run task (Shift+Alt+T)
1. Full test - setup and apply
2. Full test - cleanup

The install is performed using Docker-in-Docker.

## Inputs

| Name | Type | Description | Default |
|------|------|-------------|---------|
| `zp_module_id` | string | Unique identifier for this module instance (injected by Zeropoint) | `"youtube-dl-material"` |
| `zp_network_name` | string | Pre-created Docker network name (injected by zeropoint) | (required) |
| `zp_arch` | string | Target architecture supplied by Zeropoint | `"amd64"` |
| `zp_gpu_vendor` | string | GPU vendor supplied by Zeropoint (unused) | `""` |
| `zp_module_dir` | string | Agent's working directory for this module (injected by zeropoint) | (required) |
| `zp_storage_dir` | string | Isolated persistent data root for this module (injected by zeropoint) | (required) |
| `container_uid` | number | UID used by the container | `1000` |
| `container_gid` | number | GID used by the container | `1000` |

## Outputs

| Name | Description |
|------|-------------|
| `main` | YoutubeDL-Material container resource |
| `main_ports` | Web interface port metadata |
| `youtube_dl_material_url` | Web interface URL accessible via the Docker network |

## Data and database

The module uses YoutubeDL-Material's local JSON database, so it does not require a separate MongoDB container. It persists app data, audio, video, subscriptions, and user data in `zp_storage_dir`. Container UID and GID default to `1000` and can be overridden with `container_uid` and `container_gid`.

## Network & Service Discovery

- **Internal Port**: 17442 (web interface)
- **Network**: Uses pre-created network provided by zeropoint via `zp_network_name`
- **No Host Ports**: Service discovery via DNS only
- **Container Name**: `${zp_module_id}-main` (e.g., `youtube-dl-material-main`)

## Accessing YoutubeDL-Material

### From Other Containers (Service Discovery)

Other apps on the same network can access the web interface via its container name:

```bash
curl http://youtube-dl-material-main:17442/
```

### From Host (via Exposure)

External access requires creating an exposure through the Zeropoint API.
