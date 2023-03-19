#!/bin/sh

path=$(dirname "$0")
cd "${path}"
mkdir -p build/
jai -import_dir local_modules -output_path build/ "$@"
