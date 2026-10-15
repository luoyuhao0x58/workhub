#! /usr/bin/bash
set -uexo pipefail

apt-get install -y openssh-server

# configure sshd
sudo sed -i "s/^#HostKey \/etc\/ssh\/\(.*\)/HostKey \/etc\/ssh\/hostkey\/\1/g" /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sudo mkdir -p /run/sshd /etc/ssh/hostkey/ && sudo mv /etc/ssh/ssh_host_* /etc/ssh/hostkey/

# high-concurrency / keepalive tuning
cat > /etc/ssh/sshd_config.d/99-tuning.conf << 'EOF'
# more concurrent connections and earlier rejection of idle sessions
MaxStartups 100:30:200
ClientAliveInterval 120
ClientAliveCountMax 3
TCPKeepAlive yes
LoginGraceTime 30
EOF
cp ./supervisord.conf /etc/supervisor/conf.d/sshd.conf
mkdir -p /var/log/supervisor/sshd

sudo -u "$BUILD_USER_NAME" ./setup-user.sh