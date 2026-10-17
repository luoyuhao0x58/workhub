#! /bin/bash
# Central cleanup for the builder stage. Runs as the final step right
# before `COPY --from=builder / /` snapshots the filesystem, so anything
# deleted here never reaches the final single-layer image.
set -euo pipefail

apt clean
rm -rf /var/lib/apt/lists/*
rm -rf /root/.cache
rm -rf /home/*/.cache
rm -rf /home/*/.sudo_as_admin_successful
rm -rf "${BUILD_USER_HOME}/.cache"
rm -rf "${BUILD_USER_HOME}/.sudo_as_admin_successful"
rm -rf /tmp/*
