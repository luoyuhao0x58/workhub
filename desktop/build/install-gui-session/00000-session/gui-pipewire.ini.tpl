[program:gui-pipewire]
command = /usr/local/bin/gui-pipewire-session.sh
user = @@SESSION_USER@@
autostart = true
autorestart = true
priority = 10
stopasgroup = true
killasgroup = true
environment = SESSION_USER="@@SESSION_USER@@",HOME="@@SESSION_HOME@@",XDG_RUNTIME_DIR="/tmp/runtime-agent",DBUS_SESSION_BUS_ADDRESS="unix:path=/tmp/runtime-agent/bus"
stdout_logfile=/var/log/supervisor/gui-pipewire/stdout.log
stderr_logfile=/var/log/supervisor/gui-pipewire/stderr.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
stderr_logfile_maxbytes=50MB
stderr_logfile_backups=10
