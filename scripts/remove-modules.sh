#!/bin/sh
# shellcheck source=./scripts/common.sh
. "$(dirname "$0")/common.sh"

rootdir >/dev/null

# shellcheck source=./modules
. ./modules

for module in $MODULES; do
    infomsg "Removing module: %s\n" "$module"

    # Get module information
    module_dir="" # SC2154/SC2034
    eval module_dir="\$${module}_DIRECTORY"

    # Remove module
    if [ -d "$module_dir" ]; then
        rm -rf "$module_dir" || { errormsg "failed to remove module directory\n"; exit 1; }
    fi
done