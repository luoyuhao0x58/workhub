#! /usr/bin/bash
set -uexo pipefail

# selkies 依赖 pixelflux/pcmflux（C 扩展，cffi），编译需要 gcc/make/libffi。
# workhub 现有工具链（install-dev-tools/10000-cpp）只有 cmake/clang，这里补齐构建依赖。
sudo apt-get install -y build-essential libffi-dev python3-cffi

pipx install --global --system-site-packages selkies
selkies --version
