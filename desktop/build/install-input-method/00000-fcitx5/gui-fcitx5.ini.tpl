[program:gui-fcitx5]
command = /usr/local/bin/gui-fcitx5-session.sh
user = @@SESSION_USER@@
autostart = true
autorestart = true
priority = 30
stopasgroup = true
killasgroup = true
environment = HOME="@@SESSION_HOME@@",XDG_RUNTIME_DIR="/tmp/runtime-agent",DBUS_SESSION_BUS_ADDRESS="unix:path=/tmp/runtime-agent/bus",WAYLAND_DISPLAY="wayland-0",DISPLAY=":0",QT_IM_MODULE="fcitx",XMODIFIERS="@im=fcitx"
stdout_logfile=/var/log/supervisor/gui-fcitx5/stdout.log
stderr_logfile=/var/log/supervisor/gui-fcitx5/stderr.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
stderr_logfile_maxbytes=50MB
stderr_logfile_backups=10
