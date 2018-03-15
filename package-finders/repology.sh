#!/bin/sh

repology=$(mktemp -d)
git clone https://github.com/ryantm/repology-api.git $repology > /dev/null
nix-shell -p cabal2nix --run "cabal2nix --shell --hpack $repology" > $repology/shell.nix
$(nix-build --no-out-link $repology/shell.nix)/bin/repology-api
rm -rf $repology
