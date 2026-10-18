[program:gui-dbus]
command = /usr/local/bin/gui-dbus-session.sh
user = root
autostart = true
autorestart = true
priority = 5
stopasgroup = true
killasgroup = true
environment = SESSION_USER="@@SESSION_USER@@",XDG_RUNTIME_DIR="/tmp/runtime-agent"
stdout_logfile=/var/log/supervisor/gui-dbus/stdout.log
stderr_logfile=/var/log/supervisor/gui-dbus/stderr.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
stderr_logfile_maxbytes=50MB
stderr_logfile_backups=10
