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

# --- Idempotency: skip install if Docker is already present and working ---
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  echo "Docker already installed and running; skipping install"
  systemctl enable docker.service 2>/dev/null || true
  echo "=== $(date -Iseconds) End (no install) ==="
  exit 0
fi

# --- Install prerequisites ---
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq --no-install-recommends \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

# --- Add Docker official GPG key and repository ---
install -d -m 0755 /etc/apt/keyrings
keyring="/etc/apt/keyrings/docker.asc"
if [ ! -f "$keyring" ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o "$keyring"
  chmod a+r "$keyring"
fi

. /etc/os-release
repo_file="/etc/apt/sources.list.d/docker.list"
if [ ! -f "$repo_file" ]; then
  echo "deb [arch=$(dpkg --print-architecture) signed-by=$keyring] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME:-jammy} stable" \
    > "$repo_file"
fi

# --- Install Docker Engine ---
apt-get update -qq
apt-get install -y -qq --no-install-recommends \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# --- Enable and start Docker ---
systemctl enable docker.service
systemctl start docker.service

# --- Allow default user to run Docker without sudo (for CD/SSM runs) ---
for u in ubuntu ec2-user; do
  if id "$u" &>/dev/null; then
    usermod -aG docker "$u" 2>/dev/null || true
    echo "Added user $u to group docker"
  fi
done

# --- Verify ---
if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker installed but 'docker info' failed"
  exit 1
fi
echo "Docker version: $(docker version -f '{{.Server.Version}}' 2>/dev/null || docker --version)"

echo "=== $(date -Iseconds) End Docker install ==="
