#! /bin/bash
# Mirror env vars for python (uv). Sourced by install.sh.
# The lang id is the file name (python); the target bashrc file is
# discovered at runtime via ~/.bashrc.d/*-python.sh.

MIRROR_CONTENT='export UV_DEFAULT_INDEX=${UV_DEFAULT_INDEX:-https://mirrors.volces.com/pypi/simple/}
export UV_EXTRA_INDEX_URL=${UV_INDEX:-https://mirrors.aliyun.com/pypi/simple/}
export UV_PYTHON_INSTALL_MIRROR=${UV_PYTHON_INSTALL_MIRROR:-https://mirrors.ustc.edu.cn/github-release/astral-sh/python-build-standalone/}'
