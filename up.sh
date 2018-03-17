#! /usr/bin/env bash
set -euxo pipefail

NIX_PATH=nixpkgs=$(pwd)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $SCRIPT_DIR/utils.sh

if [ $# -eq 3 ] # normalize package name to attribute
then
    ATTR_PATH=$(nix-env -qa "$1-$2" -f . --attr-path | head -n1 | cut -d' ' -f1)
else
    ATTR_PATH=$1
fi

shift

if [ -z "$ATTR_PATH" ]
then
    error_exit "No attribute found for $1."
fi

export BRANCH_NAME="auto-update/$ATTR_PATH"

# Package blacklist
case "$ATTR_PATH" in
    google-cloud-sdk) false;; # complicated package
    github-release) false;; # complicated package
    fricas) false;; # gets stuck in emacs
    libxc) false;; # currently people don't want to update this
    *) true;;
esac || error_exit "Package on blacklist."

if git branch --remote | grep "origin/auto-update/$ATTR_PATH"
then
    error_exit "Update branch already on origin."
fi

git reset --hard
git checkout master
git reset --hard upstream/master

function error_cleanup {
    cleanup
    exit 1
}
trap error_cleanup ERR

git checkout `git merge-base upstream/master upstream/staging`

git checkout -B "$BRANCH_NAME"

if [ -x $SCRIPT_DIR/updaters/$ATTR_PATH.sh ]
then
    $SCRIPT_DIR/updaters/$ATTR_PATH.sh $ATTR_PATH $@
elif [ "$(nix-instantiate --eval -E "with import ./. {}; builtins.hasAttr \"updateScript\" $ATTR_PATH")" = true ]
then
    $SCRIPT_DIR/updaters/update-script.sh $ATTR_PATH $@
else
    $SCRIPT_DIR/updaters/version.sh $ATTR_PATH $@
fi

git reset --hard
git checkout master
git reset --hard

exit 0
