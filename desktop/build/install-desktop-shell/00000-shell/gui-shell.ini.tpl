[program:gui-shell]
command = /usr/local/bin/gui-shell-session.sh
user = @@SESSION_USER@@
autostart = true
autorestart = true
priority = 35
stopasgroup = true
killasgroup = true
environment = SESSION_USER="@@SESSION_USER@@",HOME="@@SESSION_HOME@@",XDG_RUNTIME_DIR="/tmp/runtime-agent",DBUS_SESSION_BUS_ADDRESS="unix:path=/tmp/runtime-agent/bus",WAYLAND_DISPLAY="wayland-0",DISPLAY=":0"
stdout_logfile=/var/log/supervisor/gui-shell/stdout.log
stderr_logfile=/var/log/supervisor/gui-shell/stderr.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
stderr_logfile_maxbytes=50MB
stderr_logfile_backups=10
