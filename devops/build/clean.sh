#! /bin/bash
# Central cleanup for the builder stage. Runs as the final step right
# before `COPY --from=builder / /` snapshots the filesystem, so anything
# deleted here never reaches the final single-layer image.
set -euo pipefail

uv cache clean
pip cache purge
npm cache clean --force
pnpm store prune

sudo -u "${BUILD_USER_NAME}" uv cache clean
sudo -u "${BUILD_USER_NAME}" pip cache purge
sudo -u "${BUILD_USER_NAME}" npm cache clean --force
sudo -u "${BUILD_USER_NAME}" pnpm store prune

apt clean
rm -rf /var/lib/apt/lists/*
rm -rf /root/.cache
rm -rf /home/*/.cache
rm -rf /home/*/.sudo_as_admin_successful
rm -rf "${BUILD_USER_HOME}/.cache"
rm -rf "${BUILD_USER_HOME}/.sudo_as_admin_successful"
rm -rf /tmp/*
