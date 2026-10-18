#! /bin/bash
set -euo pipefail

gen_pass() {
    local len=${1:-12}
    openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | head -c "$len"
}

user="$(whoami)"
group="$(id -gn)"

echo "root:$(gen_pass)" | sudo chpasswd
echo "$user:$(gen_pass)" | sudo chpasswd

# /run and /tmp are tmpfs: recreate what supervisord and dbus need on each boot
sudo mkdir -p /run/supervisor /run/dbus /var/log/supervisor
sudo chown "$user:$group" /run/supervisor

sudo chmod u+s /usr/local/sbin/su-exec

# GTK4 picks its renderer once per process. Where there is no standard DRM
# device the GPU is only reachable through a translation layer (WSL exposes it
# as /dev/dxg), and building a GL context costs close to a second; the Cairo
# software renderer has no such setup cost. Measured on nautilus, launch to
# first frame: 1046-1093 ms with GL, 270-304 ms with Cairo. On a machine with
# /dev/dri the default GL renderer stays in place, which is what it should be.
if [ ! -d /dev/dri ]; then
    export GSK_RENDERER="${GSK_RENDERER:-cairo}"
fi

EXCLUDE="^HOME=|^USER=|^LOGNAME=|^MAIL=|^SHELL=|^XDG_RUNTIME_DIR=|^XDG_SESSION_ID="
mapfile -t ENV_ARRAY < <(env | grep -Ev "$EXCLUDE")

init_script="$(getent passwd "$user" | cut -d: -f6)/.init"
[ -f "$init_script" ] && sudo -u"$user" env "${ENV_ARRAY[@]}" bash "$init_script"

cd /tmp
exec su-exec root bash -c "chmod u-s /usr/local/sbin/su-exec ; USER=root LOGNAME=root HOME=/root exec supervisord -n -c /etc/supervisord.conf"
