#!/bin/bash

# Update packages and install a web server 
sudo apt update -y

# Install Docker

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo groupadd docker
sudo usermod -aG docker ubuntu
newgrp docker
sudo timedatectl set-timezone America/New_York
