#! /bin/bash

gen_pass() {
    local len=${1:-12}
    openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | head -c "$len"
}

echo "root:$(gen_pass)" | sudo chpasswd
user=$(whoami)
echo "$user:$(gen_pass)" | sudo chpasswd

sudo chmod u+s $(which su-exec)

EXCLUDE="^HOME=|^USER=|^LOGNAME=|^MAIL=|^SHELL=|^XDG_RUNTIME_DIR=|^XDG_SESSION_ID="
mapfile -t ENV_ARRAY < <(env | grep -Ev "$EXCLUDE")

init_script="$(getent passwd "$user" | cut -d: -f6)/.init"
[ -f "$init_script" ] && sudo -u"$user" env "${ENV_ARRAY[@]}" bash "$init_script"

exec su-exec root bash -c "chmod u-s $(which su-exec) ; exec supervisord -n -c /etc/supervisor/supervisord.conf"
