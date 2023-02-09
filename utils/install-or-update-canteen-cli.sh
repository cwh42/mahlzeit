#!/bin/sh
GITHUB_URL="https://raw.githubusercontent.com/faeller/mahlzeit/main/utils/canteen-cli.sh"
INSTALL_PATH=".local/bin"
cd && mkdir -p $INSTALL_PATH && curl -o "$INSTALL_PATH/canteen" $GITHUB_URL && chmod +x "$INSTALL_PATH/canteen"

echo "Successfully installed/updated canteen to "~/"$INSTALL_PATH/canteen"