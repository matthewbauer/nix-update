#!/bin/sh

NIXPKGS=$PWD

emacs2nix=$(mktemp -d)
git clone https://github.com/matthewbauer/emacs2nix $emacs2nix

cd $emacs2nix
git checkout origin/patch-1
git submodule update --init hnix

rm -rf nixpkgs
ln -s $NIXPKGS nixpkgs

./elpa-packages.sh -o $NIXPKGS/pkgs/applications/editors/emacs-modes/elpa-generated.nix

cd $NIXPKGS
git add pkgs/applications/editors/emacs-modes/elpa-generated.nix

git commit -am "elpa-packages $(date -Idate)"

rm -rf $emacs2nix

pull-request "elpa-packages $(date -Idate)"
