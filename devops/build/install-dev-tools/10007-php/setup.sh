#! /bin/bash
set -uexo pipefail

curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
apt-get update -y

version=$(apt-cache search php | grep -E '^php[0-9]' | sort | tail -n 1 | cut -d '-' -f 1 | tr -cd '0-9.')
apt-get install -y \
  php${version}-cli \
  php${version}-mbstring \
  php${version}-xml \
  php${version}-curl \
  php${version}-zip \
  php${version}-mysql \
  php${version}-sqlite3 \
  php${version}-pgsql \
  php${version}-intl \
  php${version}-gd

apt install -y \
  libbz2-dev \
  libxml2-dev \
  libcurl4-openssl-dev \
  libpng-dev \
  libjpeg-dev \
  libwebp-dev \
  libonig-dev \
  libsqlite3-dev \
  libssl-dev \
  libzip-dev \
  libpq-dev \
  libreadline-dev \
  zlib1g-dev \
  pkg-config \
  build-essential \
  autoconf \
  libicu-dev \
  libtidy-dev \
  libxslt-dev

( sudo -u $BUILD_USER_NAME ./setup-user.sh )
