#!/bin/sh
# shellcheck source=./scripts/common.sh
. "$(dirname "$0")/common.sh"

vps_root_dir=$(rootdir)

# shellcheck source=./modules
. ./modules

while :; do
    case $1 in
        -one)
            one_tag=1
            ;;
        -?*)
            warnmsg 'Ignored unknown parameter: %s\n' "$1"
            ;;
        *)
            break
    esac
    shift
done

save_patches()
{
    git rev-parse "$including_commit" >/dev/null 2>&1 || { errormsg "\"%s\" is missing from module \"%s\"\n" "$including_commit" "$module_dir"; return 1; }
    git format-patch --zero-commit -k --patience -o "$vps_output_dir" "$before_commit..$including_commit"
}

for module in $MODULES; do
    infomsg "Saving patches for module: %s\n" "$module"
    cd "$vps_root_dir" || { errormsg "cannot enter versioned patch system root directory\n"; exit 1; }
    module_dir="" # SC2154/SC2034
    eval module_dir="\$${module}_DIRECTORY"
    cd "$module_dir" || { warnmsg "cannot enter module directory \"%s\"\n" "$module_dir"; continue; }

    vps_output_dir=$vps_root_dir/patches/$module_dir/
    mkdir -p "$vps_output_dir"

    upstream_commit="" # SC2154/SC2034
    eval upstream_commit="\$${module}_COMMIT"

    # Force committer and dates - allows for (more) consistent commit hashes
    git config --local user.name "vps"
    git config --local user.email "vps@invalid"
    FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch --tag-name-filter cat --env-filter 'export GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE"; export GIT_COMMITTER_NAME="vps"; export GIT_COMMITTER_EMAIL="vps@invalid"' "$upstream_commit..HEAD"
    git config --local --unset user.name
    git config --local --unset user.email

    # Saving commits top to bottom
    # Upstream, Generic, Specific
    # ..U..G....S...
    #       ........ - specific commits
    #    ...         - generic commits
    most_recent_tag=$(git describe --tags --abbrev=0)
    git merge-base --is-ancestor "$upstream_commit" "$most_recent_tag" || { errormsg "The patchset tags for \"%s\" are before upstream commit. Skipping.\n" "$module_dir" ; continue; }
    vps_output_dir=$vps_root_dir/patches/$module_dir/$most_recent_tag
    mkdir -p "$vps_output_dir"
    including_commit=HEAD
    second_most_recent_tag=$(git describe --tags --abbrev=0 "$most_recent_tag^1")
    before_commit=$second_most_recent_tag
    save_patches || continue

    [ -z "$one_tag" ] || continue
    vps_output_dir=$vps_root_dir/patches/$module_dir/$second_most_recent_tag
    mkdir -p "$vps_output_dir"
    including_commit=$before_commit
    before_commit=$upstream_commit
    save_patches || continue
done