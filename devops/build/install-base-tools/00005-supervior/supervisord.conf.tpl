[unix_http_server]
file=/var/run/supervisor.sock
chmod=0770
chown=@@UNIX_HTTP_SERVER_USER@@:@@UNIX_HTTP_SERVER_GROUP@@

[supervisord]
nodaemon=true
logfile=/var/log/supervisor/supervisord.log
loglevel=info
user=root
silent=true
pidfile=/var/run/supervisord.pid
directory=/var/log/supervisor/
# log rotation (defaults made explicit)
logfile_maxbytes=50MB
logfile_backups=10
# raise the fd floor for supervised processes
minfds=65535

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///var/run/supervisor.sock

[include]
files = /etc/supervisor/conf.d/*.conf