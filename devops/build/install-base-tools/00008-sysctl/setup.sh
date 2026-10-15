#! /usr/bin/bash
set -uexo pipefail

# High-concurrency tuning reference.
# Most knobs here are host-level (net.*, vm.*) and cannot take effect inside
# an unprivileged container: the container shares the host network stack and
# memory. Keep this file as the documented baseline - apply the same values
# on the DOCKER HOST, or via compose `sysctls:` (privileged only).
cat > /etc/sysctl.d/99-devops-tune.conf << 'EOF'
# ---- host-level tuning reference (apply on the Docker host) ----

# TCP
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65536
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216

# BBR congestion control (host kernel only; requires the tcp_bbr module)
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# files / inotify
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 8192

# memory
vm.swappiness = 10
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5
EOF

# apply if the runtime allows it (unprivileged containers silently skip)
sysctl --system > /dev/null 2>&1 || true
