#!/bin/sh

scripts_dir=${BASE_SCRIPTS_DIR:-$(dirname "$0")}
# shellcheck source=./scripts/colors
. "$scripts_dir/colors"

# shellcheck disable=SC2034
{
VPS_AUTHOR_NAME=vps
VPS_AUTHOR_EMAIL=vps@invalid
VPS_AUTHOR="$VPS_AUTHOR_NAME <${VPS_AUTHOR_EMAIL}>"
}

# shellcheck disable=SC2059,SC2145
errormsg() {
    printf "$ERR --- Error: $@" >&2
    printf "$RT" >&2
}
# shellcheck disable=SC2059,SC2145
errorf() {
    printf "$ERR$@" >&2
    printf "$RT" >&2
}

# shellcheck disable=SC2059,SC2145
warnmsg() {
    printf "$WARN --- Warning: $@" >&2
    printf "$RT" >&2
}
# shellcheck disable=SC2059,SC2145
warnindent() {
    printf "$WARN              $@" >&2
    printf "$RT" >&2
}
# shellcheck disable=SC2059,SC2145
warnf() {
    printf "$ERR$@" >&2
    printf "$RT" >&2
}

# shellcheck disable=SC2059,SC2145
infomsg() {
    printf " --- $@" >&2
}

rootdir() {
    vps_root_dir=$(realpath "$scripts_dir"/../)
    cd "$vps_root_dir" || { errormsg "cannot enter versioned patch system root directory\n"; exit 1; }
    printf "%s" "$vps_root_dir"
}