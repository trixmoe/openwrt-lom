#!/bin/sh
# shellcheck source=./scripts/common.sh
BASE_SCRIPTS_DIR=$(dirname "$0")/..
. "$BASE_SCRIPTS_DIR/common.sh"

print_help()
{
    printf "Usage: ci.sh [command]\n"
    printf "This script serves as a helper tool for CI builds.\n\n"

    printf "  --help          Show this help menu\n\n"

    printf "  build           Build the toolchain image (squashed)\n"
    printf "  run             Run a container from the image\n"
    printf "  patch [set]     Apply patchset [set]\n"
    printf "  reset           Reset openwrt to base commit (from modules file)\n"
    printf "  compile         Build the image\n"
    printf "  copy            Copy output files\n"
}

build() {
    [ ! -d patches ] && { echo "Missing patches while trying to build toolchain image in CI" >&2 ; exit 1; }
    buildah bud \
        --build-arg BUILD_USER="$build_user" --build-arg BUILD_ROOTDIR="$root_dir" --build-arg BUILD_PROJDIR="$proj_dir" \
        --target toolchain \
        --squash \
        -t "$image_name" .
}

run() {
    podman run --name "$container_name" \
        --mount "type=volume,src=${cached_volume},dst=${build_dir}/openwrt" \
        -dt "$image_name" bash
}

patch() {
    if [ ! "$1" = "neoplus2" ]; then
        errormsg "patch set \"%s\" does not exist" "$1"
    fi
    podman exec "$container_name" make "$1"
}

reset_openwrt() {
    # shellcheck source=./modules
    . "$MODULES_FILE_ROOTDIR"
    podman exec "$container_name" git -C "${build_dir}/openwrt" reset --hard "$OPENWRT_COMMIT"
}

compile() {
    podman exec "$container_name" make build
}

copy() {
    podman container cp "${container_name}:${build_dir}/openwrt/bin" "./bin"
}

case $1 in
    build)      build;;
    run)        run;;
    patch)      patch "$2";;
    reset)      reset_openwrt;;
    compile)    compile;;
    copy)       copy;;
    *)          print_help
                exit 1;;
esac
