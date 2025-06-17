#!/bin/sh
BASE_SCRIPTS_DIR=$(dirname "$0")/../
# shellcheck source=./scripts/common.sh
. "$BASE_SCRIPTS_DIR/common.sh"

image_name="openwrt-lom:latest"
container_name="openwrt-lom"

rootdir > /dev/null

start_docker() {
    # Make sure Docker Engine is running, otherwise, start it
    if ! docker ps >/dev/null ; then
        existing_context_list=$(docker context ls | cut -f1 -d" " | tail -n +2)

        if echo "$existing_context_list" | grep -q "colima" || colima >/dev/null; then
            nproc=$(getconf _NPROCESSORS_ONLN)

            case "$(uname -s)" in
                Linux*)     mem=$(awk '/MemTotal/ {print int($2/(1024^2))}' /proc/meminfo);;
                Darwin*)    mem=$(awk "BEGIN {print int($(sysctl -n hw.memsize)/(1024)^3)}");;
                *)          { errormsg "could not detect platform to start colima\n"; exit 1; }
            esac

            colima start -c "$nproc" -m "$mem" || { errormsg "colima could not start\n"; exit 1; }
            docker context use colima || { errormsg "switching to colima Docker context failed\n"; exit 1; }
        else
            errormsg "Docker Enginer is not running, and could not find Docker Engine to start.\n"
            exit 1
        fi
    fi
}

build() {
    docker build -t "$image_name" . || { errormsg "failed to build Docker image\n"; exit 1; }
}

run() {
    docker run --name "$container_name" -dt "$image_name" bash || { errormsg "failed to run Docker container\n"; exit 1; }
}

rm() {
    docker kill "$container_name" > /dev/null
    docker container rm "$container_name" > /dev/null
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
    pwd=$(docker exec "$container_name" "pwd")
    docker container cp "${container_name}:${pwd}/openwrt/bin" "./bin"
}

case $1 in
    start)      start_docker ;;
    build)      build ;;
    run)        run ;;
    rm)         rm ;;
    patch)      patch "$2";;
    compile)    compile ;;
    copy)       copy ;;
    *)  start_docker
        build
        run
esac
