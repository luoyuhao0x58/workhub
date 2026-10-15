#! /usr/bin/bash
# Install the latest mongosh via MongoDB's official apt repository.
# Debian codename is resolved from /etc/os-release; the MongoDB major
# version is resolved from the repository index so the latest is always
# installed without hardcoding a version.
set -uexo pipefail

# resolve Debian codename (e.g. trixie) from the running system
. /etc/os-release

# resolve the latest MongoDB major version (e.g. 9.0) from the repository index
MONGO_MAJOR=$(curl -fsSL --max-time 20 \
  "https://s3.amazonaws.com/repo.mongodb.org?list-type=2&prefix=apt/debian/dists/${VERSION_CODENAME}/mongodb-org/&delimiter=/" \
  | grep -oE 'mongodb-org/[0-9.]+/' \
  | sed 's|mongodb-org/||; s|/||' \
  | sort -V | tail -1)

# signing key naming changed at 9.0: server-9.asc vs server-8.0.asc.
# probe the new name first, fall back to the legacy one.
KEY_URL="https://pgp.mongodb.com/server-${MONGO_MAJOR%.*}.asc"
if [ "$(curl -sL --max-time 10 -o /dev/null -w '%{http_code}' "$KEY_URL")" != "200" ]; then
  KEY_URL="https://pgp.mongodb.com/server-${MONGO_MAJOR}.asc"
fi

curl -fsSL "$KEY_URL" | sudo gpg --dearmor -o "/etc/apt/keyrings/mongodb-server-${MONGO_MAJOR}.gpg"
echo "deb [signed-by=/etc/apt/keyrings/mongodb-server-${MONGO_MAJOR}.gpg] https://repo.mongodb.org/apt/debian ${VERSION_CODENAME}/mongodb-org/${MONGO_MAJOR} main" | sudo tee "/etc/apt/sources.list.d/mongodb-org-${MONGO_MAJOR}.list"
apt-get update -y
apt-get install -y mongodb-mongosh
