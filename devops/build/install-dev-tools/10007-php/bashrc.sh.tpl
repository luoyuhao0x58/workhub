export PHPENV_ROOT="$HOME/.phpenv"
export PATH="$PHPENV_ROOT/bin:$PATH"
eval "$(phpenv init -)"
export PHP_BUILD_TMPDIR="$PHPENV_ROOT/build"
# >>> mirrors: php >>>
# <<< mirrors: php <<<
function phpenv-download(){
  local version=$1
  local filename="php-$version.tar.bz2"
  local src_dir="$PHP_BUILD_TMPDIR/source"
  mkdir -p $src_dir
  curl -C - -L "${PHP_MIRROR:-https://www.php.net/distributions}/$filename" -o "$src_dir/$filename"
  (cd $src_dir ; tar xjf $filename ; mv php-$version $version)
}
