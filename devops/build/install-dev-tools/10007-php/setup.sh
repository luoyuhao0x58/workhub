#! /bin/bash
set -uexo pipefail

curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
apt-get update -y

get_latest_php_stable_branch() {
    local pkg ver pkgs
    pkgs=$(apt-cache pkgnames | grep -E '^php[0-9]+\.[0-9]+-cli$' | sort -V -r)

    for pkg in $pkgs; do
        ver=$(apt-cache madison "$pkg" 2>/dev/null \
            | awk -F'|' '$2 !~ /~rc/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' \
            | sort -V \
            | tail -n 1)

        if [ -n "$ver" ]; then
            echo "$pkg" | sed -E 's/^php([0-9]+\.[0-9]+)-cli$/\1/'
            return 0
        fi
    done

    return 1
}
version="$(get_latest_php_stable_branch)"

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
