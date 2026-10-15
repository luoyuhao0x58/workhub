#! /bin/bash
# Mirror env vars for ruby (ruby-build). Sourced by install.sh.
# The lang id is the file name (ruby); the target bashrc file is
# discovered at runtime via ~/.bashrc.d/*-ruby.sh.

MIRROR_CONTENT='export RUBY_BUILD_MIRROR_URL=${RUBY_BUILD_MIRROR_URL:-https://mirrors.ustc.edu.cn/ruby/}'
