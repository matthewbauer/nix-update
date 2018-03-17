#!/bin/sh

# Try to push it three times
function push() {
    git push --set-upstream origin "$BRANCH_NAME" --force
}

function pull_request() {
    echo "DRY RUN"
    return

    push || push || push

    hub pull-request -m "$1"
}

function cleanup {
    git reset --hard
    git checkout master
    git reset --hard upstream/master
    git branch -D "$BRANCH_NAME" || true
}

function error_exit {
    cleanup
    echo "$(date -Iseconds) $ATTR_PATH" >&3
    exit 1
}
