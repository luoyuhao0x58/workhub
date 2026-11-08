#! /bin/bash
set -uexo pipefail

pipx install --global --system-site-packages --preinstall markitdown-ocr --preinstall openai 'markitdown[all]'
