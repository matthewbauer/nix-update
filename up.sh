#! /usr/bin/env bash
set -euxo pipefail

NIX_PATH=nixpkgs=$(pwd)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PACKAGE_NAME=$1
BRANCH_NAME="auto-update/$PACKAGE_NAME"

function cleanup {
    git reset --hard
    git checkout master
    git reset --hard upstream/nixpkgs-unstable
    git branch -D "$BRANCH_NAME" || true
}

function error_exit {
    cleanup
    echo "$(date -Iseconds) $PACKAGE_NAME" >&3
    exit 1
}

# Package blacklist
case "$PACKAGE_NAME" in
    *jquery*) false;; # this isn't a real package
    *google-cloud-sdk*) false;; # complicated package
    *github-release*) false;; # complicated package
    *fricas*) false;; # gets stuck in emacs
    *libxc*) false;; # currently people don't want to update this
    *) true;;
esac || error_exit "Package on blacklist."

if git branch --remote | grep "origin/auto-update/${PACKAGE_NAME}"
then
    error_exit "Update branch already on origin."
fi

git reset --hard
git checkout master
git reset --hard upstream/nixpkgs-unstable

function error_cleanup {
    cleanup
    exit 1
}
trap error_cleanup ERR

git checkout `git merge-base upstream/nixpkgs-unstable upstream/staging`

git checkout -B "$BRANCH_NAME"

# Try to push it three times
function push() {
    git push --set-upstream origin "$BRANCH_NAME" --force
}

function pull-request() {
    echo "DRY RUN"
    return

    push || push || push

    hub pull-request -m "$1"
}

if [ -x $SCRIPT_DIR/updaters/$PACKAGE_NAME.sh ]
then
    $SCRIPT_DIR/updaters/$PACKAGE_NAME.sh $@
elif [ "$(nix-instantiate --eval -E 'with import ./. {}; builtins.hasAttr \"updateScript\" $PACKAGE_NAME')" ]
then
    $SCRIPT_DIR/updaters/update-script.sh $@
elif ! [ -z "$OLD_VERSION" ] && ! [ -z "$NEW_VERSION" ]
then
    $SCRIPT_DIR/updates/version.sh $@
else
    error_exit "Cannot find update method for $PACKAGE_NAME"
fi

git reset --hard
git checkout master
git reset --hard

exit 0
