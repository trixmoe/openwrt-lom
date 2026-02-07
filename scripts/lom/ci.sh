#!/bin/sh
# shellcheck source=./scripts/common.sh
BASE_SCRIPTS_DIR=$(dirname "$0")/..
. "$BASE_SCRIPTS_DIR/common.sh"

print_help()
{
    printf "Usage: ci.sh [command]\n"
    printf "This script serves as a helper tool for CI builds.\n\n"

    printf "  --help          Show this help menu\n\n"

    printf "  docker-run      Run container without openwrt volume, only\n"
    printf "                  necessary for commit (volumes are excluded)\n"
    printf "  patch [set]     Apply patchset [set]\n"
    printf "  reset           Reset openwrt to base commit (from modules file)\n"
    printf "  toolchain       Build tools and toolchain\n"
    printf "  compile         Build the image\n"
    printf "  copy            Copy output files\n"
    printf "  commit [image]  Commit container state as [image]\n"
}

docker_run() {
    docker run --name "$container_name" \
        --mount "type=bind,src=./patches,dst=${build_dir}/patches" \
        -dt "$image_name" bash
}

patch() {
    if [ ! "$1" = "neoplus2" ]; then
        errormsg "patch set \"%s\" does not exist" "$1"
    fi
    docker exec "$container_name" make "$1"
}

reset_openwrt() {
    # shellcheck source=./modules
    . "$MODULES_FILE_ROOTDIR"
    docker exec "$container_name" git -C "${build_dir}/openwrt" reset --hard "$OPENWRT_COMMIT"
}

toolchain() {
    docker exec "$container_name" make toolchain
}

compile() {
    docker exec "$container_name" make build
}

copy() {
    docker container cp "${container_name}:${build_dir}/openwrt/bin" "./bin"
}

commit() {
    docker commit "$container_name" "$1"
}

case $1 in
    docker-run) docker_run;;
    patch)      patch "$2";;
    reset)      reset_openwrt;;
    toolchain)  toolchain;;
    compile)    compile;;
    copy)       copy;;
    commit)     commit "$2";;
    *)          print_help
                exit 1;;
esac
