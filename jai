#!/bin/sh

path=$(realpath $(dirname "$0"))
mkdir -p ${path}/build/
jai -import_dir ${path}/modules/ -output_path ${path}/build/ -no_backtrace_on_crash "$@"
