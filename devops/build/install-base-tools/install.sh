#! /bin/bash
set -uexo pipefail

# enable contrib non-free components
sed -i 's/Components: main/Components: main contrib non-free/g' /etc/apt/sources.list.d/debian.sources

# ensure https transport + CA trust BEFORE switching the stock sources to https
# (apt on trixie has https built-in; only ca-certificates is required)
apt-get update -y
apt-get install -y ca-certificates
sed -i 's|^URIs: http://|URIs: https://|g' /etc/apt/sources.list.d/debian.sources
apt-get update -y
apt-get install -y tzdata locales
apt-get upgrade -y

# change sh
ln -sf /bin/bash /bin/sh
echo '[ -f /etc/shell.rc ] && source /etc/shell.rc' >> /etc/bash.bashrc

# locale setting
echo "C.UTF-8 UTF-8
$BUILD_LANG UTF-8" > /etc/locale.gen
dpkg-reconfigure locales
update-locale "LANG=C.UTF-8"
echo '
export LANG=C.UTF-8' >> /etc/shell.rc

# timezone setting
ln -fs /usr/share/zoneinfo/$BUILD_TZ /etc/localtime
dpkg-reconfigure tzdata

# history setting
sed -r -i -e '/^[[:space:]]*(HISTFILESIZE|HISTCONTROL|HISTSIZE|HISTTIMEFORMAT)=/d' /etc/skel/.bashrc
echo 'export HISTFILESIZE=100000
export HISTCONTROL=ignoredups
export HISTSIZE=10000
export HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S]  "' > /etc/profile.d/history.sh

# limits setting
# NOTE: inside a container /etc/security/limits.conf only applies via PAM
# login; supervisor/su-exec processes bypass PAM. Real limits must be set
# with `docker run --ulimit nofile=...` or compose `ulimits:` - this file
# is the documented baseline.
echo '*               soft    nofile          1048576
*               hard    nofile          1048576
root            soft    nofile          1048576
root            hard    nofile          1048576
root            soft    core            unlimited
root            hard    core            unlimited' > /etc/security/limits.conf

apt-get install -y \
  sudo dpkg-dev lsb-release man-db \
  psmisc inotify-tools sysstat lsof \
  htop iftop ncdu atop iperf3 nload \
  netcat-openbsd net-tools iproute2 iputils-ping dnsutils telnet \
  nmap tcpdump traceroute mtr \
  curl wget rsync \
  zip unzip unrar-free p7zip-full xz-utils \
  file tree jq yq less source-highlight acl fd-find ripgrep \
  subversion \
  screen

# user setting
groupadd -g $BUILD_GID $BUILD_GROUP_NAME
useradd -c 'agent' -d $BUILD_USER_HOME -s /bin/bash -N -m -u $BUILD_UID -g $BUILD_GROUP_NAME -G sudo $BUILD_USER_NAME
sed -i 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers
echo "umask 0002" >> "$BUILD_USER_HOME"/.bashrc

sudo -u "$BUILD_USER_NAME" bash -c 'mkdir -p $HOME/.bashrc.d/'
echo '
for filename in $(ls $HOME/.bashrc.d/*.sh 2>/dev/null | sort); do
  source "$filename"
done
' | sudo -u "$BUILD_USER_NAME" tee -a "$BUILD_USER_HOME/.bashrc"

for filename in $(ls ./*-*/setup.sh | sort); do
  cd $(dirname $filename)
  ./setup.sh
  cd -
done

rsync -a --ignore-times ./rootfs/ /
