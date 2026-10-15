#! /bin/bash

git clone --depth=1 https://github.com/jenv/jenv.git ~/.jenv

cp ./bashrc.sh "$HOME/.bashrc.d/$(basename "$(pwd -P)").sh"

( source ./bashrc.sh ; jenv enable-plugin export ; jenv add /usr/lib/jvm/temurin-*-jdk-*/ ; jenv rehash ; jenv global system)
