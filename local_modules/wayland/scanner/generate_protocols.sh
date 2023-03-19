#!/bin/sh

set -e
BASE_DIR=$(dirname "$0")

cd "${BASE_DIR}"

[ -e ./wayland-scanner ] || jai -import_dir ../../ wayland-scanner.jai

generate() {
    src="$1"
    dst="$2"
    echo "Generating ${dst} (${src})..."
    ./wayland-scanner ${src} > ${dst} || exit 1
}

mkdir -p ../protocols/core
generate protocols/wayland/wayland.xml ../protocols/core/wayland.jai

for kind in stable staging unstable ; do
    for dir in protocols/wayland-protocols/${kind}/* ; do
        mkdir -p ../protocols/core/${kind}
        for xml in ${dir}/*.xml; do
            name=$(basename -s .xml ${xml})
            generate ${xml} ../protocols/core/${kind}/${name}.jai
        done
    done
done

mkdir -p ../protocols/kde/plasma5
for xml in protocols/kde/plasma5/*.xml ; do
    name=$(basename -s .xml ${xml})
    generate ${xml} ../protocols/kde/plasma5/${name}.jai
done
