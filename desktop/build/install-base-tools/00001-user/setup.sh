#! /usr/bin/bash
set -uexo pipefail

# Same identity as the devops image: agent/1000 in the devops group, home
# /mnt/workspace. Only the data behind that home differs (separate volume).
groupadd -g "$BUILD_GID" "$BUILD_GROUP_NAME"
useradd \
  -c 'agent' \
  -d "$BUILD_USER_HOME" \
  -s /bin/bash \
  -N \
  -m \
  -u "$BUILD_UID" \
  -g "$BUILD_GROUP_NAME" \
  -G wheel \
  "$BUILD_USER_NAME"

# full passwordless sudo, overriding the default wheel rule that asks
# for a password the container never sets
cat > /etc/sudoers.d/90-agent << 'EOF'
%wheel ALL=(ALL:ALL) NOPASSWD: ALL
EOF
chmod 0440 /etc/sudoers.d/90-agent

echo "umask 0002" >> "$BUILD_USER_HOME/.bashrc"
mkdir -p "$BUILD_USER_HOME/.config"
chown -R "$BUILD_UID:$BUILD_GID" "$BUILD_USER_HOME/.config"
