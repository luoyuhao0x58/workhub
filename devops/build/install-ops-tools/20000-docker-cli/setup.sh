#! /usr/bin/bash
set -uexo pipefail

apt-get install -y docker-cli docker-compose docker-buildx
groupadd -g $BUILD_DOCKER_GID docker

usermod -aG docker "$BUILD_USER_NAME"

echo 'alias docker="sudo docker"' | sudo -u "$BUILD_USER_NAME" tee -a "$BUILD_USER_HOME/.bash_aliases"
