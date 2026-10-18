#! /bin/bash
set -euo pipefail

# Single-layer exit: dnf and pip caches would otherwise ship in the image.

dnf clean all
rm -rf /var/cache/dnf /var/cache/libdnf5
rm -rf /var/lib/dnf/history* /var/log/dnf5.log* /var/log/dnf.log*
pip cache purge 2>/dev/null || true
rm -rf /root/.cache "${BUILD_USER_HOME}/.cache"
rm -rf /tmp/*
