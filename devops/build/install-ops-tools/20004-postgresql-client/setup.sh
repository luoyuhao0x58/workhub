#! /usr/bin/bash
set -uexo pipefail

install -d /usr/share/postgresql-common/pgdg
curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail \
  https://www.postgresql.org/media/keys/ACCC4CF8.asc
(. /etc/os-release ; echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://mirrors.aliyun.com/postgresql/repos/apt $VERSION_CODENAME-pgdg main" > /etc/apt/sources.list.d/pgdg.list)
apt-get update -y
apt-get install -y postgresql-client
