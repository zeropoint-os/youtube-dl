#!/usr/bin/env bash

set -euo pipefail

container_name="${1:-youtube-dl-material-main}"
container_ip="$(docker inspect "$container_name" --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')"

if [[ -z "$container_ip" ]]; then
  echo "Error: $container_name is not connected to a Docker network" >&2
  exit 1
fi

curl --fail --silent --show-error --max-time 10 "http://$container_ip:17442/"
