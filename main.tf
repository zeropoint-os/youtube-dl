terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

variable "zp_module_id" {
  type        = string
  default     = "youtube-dl-material"
  description = "Unique identifier for this module instance (user-defined, freeform)"
}

variable "zp_network_name" {
  type        = string
  description = "Pre-created Docker network name for this module (managed by zeropoint)"
}

variable "zp_arch" {
  type        = string
  default     = "amd64"
  description = "Target architecture provided by Zeropoint"
}

variable "zp_gpu_vendor" {
  type        = string
  default     = ""
  description = "GPU vendor provided by Zeropoint (unused by this module)"
}

variable "zp_module_dir" {
  type        = string
  description = "Agent's working directory for this module (injected by zeropoint)"
}

variable "zp_storage_dir" {
  type        = string
  description = "Isolated data root for this module; persistent bind mounts must live under this path"
}

variable "container_uid" {
  type        = number
  default     = 1000
  description = "UID used by the YoutubeDL-Material container"
}

variable "container_gid" {
  type        = number
  default     = 1000
  description = "GID used by the YoutubeDL-Material container"
}

resource "docker_image" "youtube_dl_material" {
  name         = "tzahi12345/youtubedl-material:latest"
  keep_locally = true
}

resource "docker_container" "youtube_dl_material_main" {
  name  = "${var.zp_module_id}-main"
  image = docker_image.youtube_dl_material.image_id

  networks_advanced {
    name = var.zp_network_name
  }

  restart = "unless-stopped"

  env = [
    "ytdl_use_local_db=true",
    "write_ytdl_config=true",
    "UID=${var.container_uid}",
    "GID=${var.container_gid}",
  ]

  volumes {
    host_path      = "${var.zp_storage_dir}/appdata"
    container_path = "/app/appdata"
  }

  volumes {
    host_path      = "${var.zp_storage_dir}/audio"
    container_path = "/app/audio"
  }

  volumes {
    host_path      = "${var.zp_storage_dir}/video"
    container_path = "/app/video"
  }

  volumes {
    host_path      = "${var.zp_storage_dir}/subscriptions"
    container_path = "/app/subscriptions"
  }

  volumes {
    host_path      = "${var.zp_storage_dir}/users"
    container_path = "/app/users"
  }
}

output "main" {
  value       = docker_container.youtube_dl_material_main
  description = "YoutubeDL-Material application container"
}

output "main_ports" {
  value = {
    web = {
      port        = 17442
      protocol    = "http"
      transport   = "tcp"
      description = "YoutubeDL-Material web interface"
      default     = true
    }
  }
  description = "Service ports for external access"
}

output "youtube_dl_material_url" {
  value       = "http://${docker_container.youtube_dl_material_main.name}:17442"
  description = "YoutubeDL-Material URL accessible via the Docker network"
}