#! /bin/bash
set -uexo pipefail

git clone --depth=1 https://github.com/phpenv/phpenv.git ~/.phpenv
cp ./bashrc.sh.tpl "$HOME/.bashrc.d/$(basename "$(pwd -P)").sh"
( source "$HOME/.bashrc.d/$(basename "$(pwd -P)").sh" ; git clone --depth=1 https://github.com/php-build/php-build $(phpenv root)/plugins/php-build )
