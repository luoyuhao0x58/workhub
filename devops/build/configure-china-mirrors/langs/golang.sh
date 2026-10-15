#! /bin/bash
# Mirror env vars for golang (go / g). Sourced by install.sh.
# The lang id is the file name (golang); the target bashrc file is
# discovered at runtime via ~/.bashrc.d/*-golang.sh.

MIRROR_CONTENT='export G_MIRROR=${G_MIRROR:-https://golang.google.cn/dl}
export GOPROXY=${GOPROXY:-https://goproxy.cn,direct}'
