#! /bin/bash

cp ./bashrc.sh "$HOME/.bashrc.d/$(basename "$(pwd -P)").sh"
