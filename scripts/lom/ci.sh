#!/bin/sh
# shellcheck source=./scripts/common.sh
BASE_SCRIPTS_DIR=$(dirname "$0")/..
. "$BASE_SCRIPTS_DIR/common.sh"

print_help()
{
    printf "Usage: ci.sh [command]\n"
    printf "This script serves as a helper tool for CI builds.\n\n"

    printf "  --help       Show this help menu\n\n"

    printf "  patch [set]  Apply patchset [set]\n"
    printf "  compile      Build the image\n"
    printf "  copy         Copy output files\n"
}

patch() {
    if [ ! "$1" = "neoplus2" ]; then
        errormsg "patch set \"%s\" does not exist" "$1"
    fi
    docker exec "$container_name" make "$1"
}

compile() {
    docker exec "$container_name" make build
}

copy() {
    docker container cp "${container_name}:${build_dir}/openwrt/bin" "./bin"
}

case $1 in
    patch)    patch "$2";;
    compile)  compile;;
    copy)     copy;;
    *)        print_help
              exit 1;;
esac
