#!/bin/sh

NIXPKGS=$PWD

emacs2nix=$(mktemp -d)
git clone https://github.com/matthewbauer/emacs2nix $emacs2nix

cd $emacs2nix
git checkout origin/patch-1
git submodule update --init hnix

rm -rf nixpkgs
ln -s $NIXPKGS nixpkgs

./org-packages.sh -o $NIXPKGS/pkgs/applications/editors/emacs-modes/org-generated.nix

git add pkgs/applications/editors/emacs-modes/org-generated.nix

git commit -m "org-packages $(date -Idate)"

rm -rf $emacs2nix

pull-request "melpa-packages $(date -Idate)"
