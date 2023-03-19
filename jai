#!/bin/sh

path=$(dirname "$0")
mkdir -p ${path}/build/
jai -import_dir ${path}/local_modules -output_path ${path}/build/ "$@"
