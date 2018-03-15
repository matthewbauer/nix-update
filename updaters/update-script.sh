PACKAGE_NAME=$1

$(nix eval -f . --raw "pkgs.${PACKAGE_NAME}.updateScript")

git add .

git commit -am "$PACKAGE_NAME: update"

pull-request "$PACKAGE_NAME: update"
