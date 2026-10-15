#! /bin/bash
set -uexo pipefail

VERSION=$(curl -s https://api.adoptium.net/v3/info/available_releases | jq '.most_recent_lts')
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo tee /etc/apt/keyrings/adoptium.asc
echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
apt-get update -y
apt-get install -y "temurin-$VERSION-jdk"

sudo -u $BUILD_USER_NAME ./setup-user.sh
