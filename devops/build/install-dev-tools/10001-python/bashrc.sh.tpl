#! /usr/bin/bash

# >>> mirrors: python >>>
# <<< mirrors: python <<<

export UV_LINK_MODE=copy
export UV_CACHE_DIR=${UV_CACHE_DIR:-~/.cache/uv}
# isolate uv's persistent data (python installs + tools) under ~/.uv so the
# compose volume only persists what actually needs to survive recreation
# (other tools keep their products in ~/.local without persistence)
export UV_TOOL_DIR=${UV_TOOL_DIR:-$HOME/.uv/tools}
export UV_PYTHON_INSTALL_DIR=${UV_PYTHON_INSTALL_DIR:-$HOME/.uv/python}
export UV_SYSTEM_PYTHON=0
export PATH="$HOME/.local/bin:$PATH"
