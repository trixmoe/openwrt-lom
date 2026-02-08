#!/bin/sh
# shellcheck source=./scripts/common.sh
BASE_SCRIPTS_DIR=$(dirname "$0")/..
. "$BASE_SCRIPTS_DIR/common.sh"

print_help()
{
    printf "Usage: build.sh\n"
    printf "This script builds OpenWrt incl. pre-required commands\n\n"

    printf "  --toolchain  Only build tools and toolchain\n"
    printf "  --rebuild    Dirty but quicker build\n"
    printf "  --help       Show this help menu\n"
}

unset rebuild toolchain_only
while :; do
    case $1 in
        -\?|-help|--help)
            print_help
            exit 0
            ;;
        --toolchain)
            toolchain_only=1
            ;;
        --rebuild)
            rebuild=1
            ;;
        --)
            shift
            break
            ;;
        -?*)
            warnmsg 'Ignored unknown parameter: %s\n' "$1"
            ;;
        *)
            break
    esac
    shift
done

vps_root_dir=$(rootdir)

cd "$vps_root_dir/openwrt" || { errormsg "could not cd into openwrt directory"; exit 1; }

ncpus=$(nproc)

if [ -n "$toolchain_only" ]; then
    make defconfig
    # 'make prepare' builds tools + toolchain + kernel AND creates stampfiles.
    # Using tools/compile + toolchain/compile directly skips stamp creation,
    # causing expensive autoremove re-checks (~17 min) on subsequent builds.
    make prepare "-j$ncpus"
    exit 0
fi

if [ -n "$rebuild" ]; then
    board=$(sed -n 's/^CONFIG_TARGET_BOARD="\(.*\)"/\1/p' .config)
    # If board is missing -> typically means that 'make defconfig' wasn't done
    if [ -z "$board" ]; then
        make defconfig
        board=$(sed -n 's/^CONFIG_TARGET_BOARD="\(.*\)"/\1/p' .config)
    fi
    target=$(sed -n 's/^CONFIG_TARGET_SUBTARGET="\(.*\)"/\1/p' .config)
    rm "bin/targets/$board/$target"/openwrt-*
else
    # Create .config from minimal diffconfig
    make defconfig
    # "good practice (...) to ensure quality builds" https://web.archive.org/web/20250602152152/https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem#cleaning_up
    make clean
fi

make "-j$ncpus"