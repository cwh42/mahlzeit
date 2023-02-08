#!/bin/sh
GITHUB_URL="https://raw.githubusercontent.com/faeller/mahlzeit/main/utils/canteen-cli.sh"
INSTALL_PATH="~/.canteen-cli"
mkdir -p $INSTALL_PATH && curl $GITHUB_URL > $INSTALL_PATH/canteen-cli.sh

if  grep -q "alias canteen=" ~/.bashrc ; then
         echo 'Update successful. Alias already in bashrc. Not adding it again.' ; 
else
        echo "alias canteen='sh ~/.canteen-cli/canteen-cli.sh'" >> ~/.bashrc
        echo "Successfully added canteen alias. You can now run 'canteen (optional: tomorrow, yesterday, today)'" 
fi