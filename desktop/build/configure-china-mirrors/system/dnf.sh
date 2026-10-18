#! /bin/bash
set -euo pipefail

# Switch dnf to the Aliyun Fedora mirror. Fedora's stock repos are metalink-only,
# so the commented baseurl has to be re-pointed as well.
sed -i \
  -e 's|^metalink=|#metalink=|g' \
  -e 's|^#baseurl=http://download.example/pub/fedora/linux|baseurl=https://mirrors.aliyun.com/fedora|g' \
  /etc/yum.repos.d/fedora*.repo

# Aliyun does not mirror the cisco h264 repo; leaving it enabled makes every
# transaction fail with "No valid source".
sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/fedora-cisco-openh264.repo

dnf clean all
rm -rf /var/cache/dnf /var/cache/libdnf5
