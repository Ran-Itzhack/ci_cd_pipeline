#!/bin/bash
#
# install_docker_on_ubuntu_aws_ec2.sh
# Used as EC2 user_data to prepare Ubuntu instances for CD: Docker is installed
# and ready so the deployment pipeline (e.g. SSM/shell) can pull from Docker Hub
# and run containers. Safe to run at first boot; idempotent where possible.
#
# Usage in Terraform:
#   user_data = file("${path.module}/install_docker_on_ubuntu_aws_ec2.sh")
#

set -euo pipefail
LOG="/var/log/install_docker_on_ubuntu_aws_ec2.log"

exec 1> >(tee -a "$LOG") 2>&1
echo "=== $(date -Iseconds) Start Docker install (user_data) ==="

# --- Small helpers for robust boot-time installs ---
retry() {
  # retry <attempts> <sleep_seconds> <cmd...>
  local attempts="$1"; shift
  local sleep_s="$1"; shift
  local n=1
  until "$@"; do
    if [ "$n" -ge "$attempts" ]; then
      echo "ERROR: command failed after ${attempts} attempts: $*"
      return 1
    fi
    echo "WARN: attempt ${n}/${attempts} failed: $* ; retrying in ${sleep_s}s"
    n=$((n + 1))
    sleep "$sleep_s"
  done
}

wait_for_network() {
  # Docker install needs outbound HTTPS + DNS. Wait a bit at boot.
  local max=180
  local n=0
  while [ "$n" -lt "$max" ]; do
    if curl -fsS --max-time 5 https://download.docker.com/ >/dev/null 2>&1; then
      echo "Network ready after ${n}s"
      return 0
    fi
    n=$((n + 5))
    sleep 5
  done
  echo "WARN: Network check timed out after ${max}s; proceeding anyway"
}

# --- Wait for cloud-init and package manager (required when run as user_data at boot) ---
wait_for_apt() {
  local max=300
  local n=0
  while [ "$n" -lt "$max" ]; do
    if ! (fuser -v /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || fuser -v /var/lib/dpkg/lock >/dev/null 2>&1); then
      if ! pgrep -x unattended-upgr >/dev/null 2>&1; then
        echo "Package manager ready after ${n}s"
        return 0
      fi
    fi
    n=$((n + 5))
    sleep 5
  done
  echo "WARN: Proceeding after ${max}s wait; apt may still be in use"
}
wait_for_apt
wait_for_network

# --- Idempotency: skip install if Docker is already present and working ---
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  echo "Docker already installed and running; skipping install"
  systemctl enable docker.service 2>/dev/null || true
  echo "=== $(date -Iseconds) End (no install) ==="
  exit 0
fi

# --- Install prerequisites ---
export DEBIAN_FRONTEND=noninteractive
retry 10 6 apt-get update -qq
retry 10 6 apt-get install -y -qq --no-install-recommends \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

install_docker_from_repo() {
  echo "--- Installing Docker via Docker apt repo ---"
  install -d -m 0755 /etc/apt/keyrings
  local keyring="/etc/apt/keyrings/docker.gpg"
  if [ ! -f "$keyring" ]; then
    retry 10 6 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o "$keyring"
    chmod a+r "$keyring"
  fi

  . /etc/os-release
  local codename="${VERSION_CODENAME:-jammy}"
  # If Docker repo codename isn't available yet on new Ubuntu releases, fall back safely.
  case "$codename" in
    noble) codename="jammy" ;;
  esac

  local repo_file="/etc/apt/sources.list.d/docker.list"
  if [ ! -f "$repo_file" ]; then
    echo "deb [arch=$(dpkg --print-architecture) signed-by=$keyring] https://download.docker.com/linux/ubuntu ${codename} stable" > "$repo_file"
  fi

  retry 10 6 apt-get update -qq
  retry 10 6 apt-get install -y -qq --no-install-recommends \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
}

install_docker_from_get_docker() {
  echo "--- Installing Docker via get.docker.com (fallback) ---"
  retry 10 6 curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sh /tmp/get-docker.sh
}

install_docker_from_ubuntu_repo() {
  echo "--- Installing Docker via Ubuntu docker.io (fallback) ---"
  retry 10 6 apt-get update -qq
  retry 10 6 apt-get install -y -qq --no-install-recommends docker.io
}

if ! install_docker_from_repo; then
  echo "WARN: Docker repo install failed; trying fallback installer"
  if ! install_docker_from_get_docker; then
    echo "WARN: get.docker.com install failed; trying Ubuntu docker.io"
    install_docker_from_ubuntu_repo
  fi
fi

# --- Enable and start Docker ---
systemctl enable docker.service 2>/dev/null || true
systemctl start docker.service 2>/dev/null || true

# --- Allow default user to run Docker without sudo (for CD/SSM runs) ---
for u in ubuntu ec2-user; do
  if id "$u" &>/dev/null; then
    usermod -aG docker "$u" 2>/dev/null || true
    echo "Added user $u to group docker"
  fi
done

# --- Verify ---
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker binary not found after install attempts"
  exit 1
fi

retry 12 5 docker info >/dev/null 2>&1 || true
if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker installed but 'docker info' failed"
  exit 1
fi
echo "Docker version: $(docker version -f '{{.Server.Version}}' 2>/dev/null || docker --version)"

echo "=== $(date -Iseconds) End Docker install ==="