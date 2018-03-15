#!/bin/sh

NIXPKGS=$PWD

emacs2nix=$(mktemp -d)
melpa=$(mktemp -d)
git clone https://github.com/matthewbauer/emacs2nix $emacs2nix
git clone https://github.com/milkypostman/melpa $melpa

cd $emacs2nix
git checkout origin/patch-1
git submodule update --init hnix

rm -rf nixpkgs
ln -s $NIXPKGS nixpkgs

./melpa-stable-packages.sh --melpa $melpa -o $NIXPKGS/pkgs/applications/editors/emacs-modes/melpa-stable-generated.nix

cd $NIXPKGS
git add pkgs/applications/editors/emacs-modes/melpa-stable-generated.nix

git commit -m "melpa-stable-packages $(date -Idate)"

rm -rf $emacs2nix
rm -rf $melpa

pull-request "melpa-packages $(date -Idate)"
