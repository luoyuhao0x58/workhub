#! /usr/bin/bash
set -uexo pipefail

apt-get install -y cron

# users: /var/spool/cron/crontabs/
# system: /etc/crontab、/etc/cron.d/

rm -rf \
  /etc/cron.daily/* \
  /etc/cron.hourly/* \
  /etc/cron.monthly/* \
  /etc/cron.weekly/* \
  /etc/cron.yearly/* \
  /etc/cron.d/*

mkdir -p /var/log/supervisor/cron
cp ./supervisord.conf /etc/supervisor/conf.d/cron.conf