#! /usr/bin/env bash
set -euxo pipefail

LOG_FILE=~/.nix-update/ups.log
mkdir -p $(dirname $LOG_FILE)
touch $LOG_FILE

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ARGUMENTS=$(for f in $SCRIPT_DIR/package-finders/*.sh
	    do
		$f
	    done)

echo "

$(date -Iseconds) New run of ups.sh" >> $LOG_FILE

if [ -z "${NIXPKGS+}" ]
then
    NIXPKGS=$HOME/Projects/nixpkgs
fi

cd $NIXPKGS

if ! [ -f default.nix ]
then
    NIXPKGS=$(mktemp -d)
    git clone https://github.com/NixOS/nixpkgs $NIXPKGS
    cd $NIXPKGS
    git remote add upstream https://github.com/NixOS/nixpkgs-channels
    git fetch upstream
fi

IFS=$'\n'
for a in $ARGUMENTS
do
    unset IFS
    echo "$(date -Iseconds) $a" >> $LOG_FILE
    if eval "$SCRIPT_DIR/up.sh $a 3>>$LOG_FILE"
    then
        echo "$(date -Iseconds) SUCCESS" >> $LOG_FILE
        sleep 900
    else
        echo "$(date -Iseconds) FAIL" >> $LOG_FILE
    fi
done
