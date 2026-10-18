#! /usr/bin/bash
set -uexo pipefail

sudo apt-get install -y \
  labwc \
  xwayland \
  pipewire \
  pipewire-pulse \
  wireplumber \
  dbus \
  libegl1 \
  libgl1-mesa-dri \
  libgbm1 \
  libva2 \
  fonts-noto-cjk

# labwc 配置：启用 XWayland 常驻。
# 默认（xwaylandPersistence 缺省）下 Xwayland 以 `-terminate 10` 启动，
# 无 X 客户端连接 10 秒后自动退出，X11 应用将无法连接。
mkdir -p /etc/xdg/labwc
cat > /etc/xdg/labwc/rc.xml << 'EOF'
<labwc_config>
  <core>
    <xwaylandPersistence>yes</xwaylandPersistence>
  </core>
</labwc_config>
EOF
