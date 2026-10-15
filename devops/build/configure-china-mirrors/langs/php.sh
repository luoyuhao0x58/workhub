#! /bin/bash
# Mirror env vars for php (phpenv-download). Sourced by install.sh.
# The lang id is the file name (php); the target bashrc file is
# discovered at runtime via ~/.bashrc.d/*-php.sh.

MIRROR_CONTENT='export PHP_MIRROR=${PHP_MIRROR:-https://mirrors.ctyun.cn/php}'
