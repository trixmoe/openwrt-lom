#!/bin/sh
BASE_SCRIPTS_DIR=$(dirname "$0")/../
# shellcheck source=./scripts/common.sh
. "$BASE_SCRIPTS_DIR/common.sh"

rootdir > /dev/null

cd openwrt || { errormsg "openwrt directory not found\n"; exit 1; }

nproc=$(getconf _NPROCESSORS_ONLN)
make defconfig
make "-j$nproc"
