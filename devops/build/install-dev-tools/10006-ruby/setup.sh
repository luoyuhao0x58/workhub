#! /bin/bash
set -uexo pipefail

# Distro Ruby as the system-wide toolchain. Keep the ruby-build compile deps
# so user-level `rbenv install` can build other versions.
apt-get install -y build-essential autoconf libssl-dev libyaml-dev zlib1g-dev libffi-dev libgmp-dev \
  ruby ruby-dev

# system-wide gem config: official source, skip docs
cat > /etc/gemrc << EOF
:sources:
  - https://rubygems.org/
gem: "--no-document"
EOF

gem install bundler --no-document -q

( sudo -u $BUILD_USER_NAME ./setup-user.sh )
