[unix_http_server]
file=/run/supervisor/supervisor.sock
chmod=0770
chown=@@UNIX_HTTP_SERVER_UID@@:@@UNIX_HTTP_SERVER_GID@@

[supervisord]
nodaemon=true
logfile=/var/log/supervisor/supervisord.log
loglevel=info
user=root
silent=true
pidfile=/run/supervisor/supervisord.pid
directory=/var/log/supervisor
logfile_maxbytes=50MB
logfile_backups=10
# raise the fd floor for supervised processes
minfds=65535

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///run/supervisor/supervisor.sock

[include]
files = /etc/supervisord.d/*.ini
