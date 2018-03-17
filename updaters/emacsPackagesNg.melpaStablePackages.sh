#! /usr/bin/env bash
set -euxo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $SCRIPT_DIR/../utils.sh

NIXPKGS=$PWD

melpa=$HOME/.cache/melpa
if ! [ -d $melpa ]
then
    git clone https://github.com/milkypostman/melpa $melpa
else
    cd $melpa
    git pull origin master
fi

emacs2nix=$HOME/.cache/emacs2nix
if ! [ -d $emacs2nix ]
then
    git clone https://github.com/matthewbauer/emacs2nix $emacs2nix
    cd $emacs2nix
    git submodule update --init
fi

cd $emacs2nix

./melpa-stable-packages.sh --melpa $melpa -o $NIXPKGS/pkgs/applications/editors/emacs-modes/melpa-stable-generated.nix

cd $NIXPKGS

git add pkgs/applications/editors/emacs-modes/melpa-stable-generated.nix

git commit -m "melpa-stable-packages $(date -Idate)"

pull_request "melpa-stable-packages $(date -Idate)"
