#!/bin/sh
API_URL="https://users.suse.com/~cwh/mahlzeit/mahlzeit.json"
MENU_JSON=$(curl -s $API_URL)

case "$1" in
"tomorrow") MENU_OFFSET=0 ;;
"yesterday") MENU_OFFSET=2 ;;
"today") MENU_OFFSET=1 ;;
*) echo "Unknown argument. Try tomorrow, yesterday, today or no argument"; exit
esac

export MENU_JSON && export MENU_OFFSET

function impl_jq() {
    if command -v jq &>/dev/null; then
        WEEKDAY=$(date +%u)-$MENU_OFFSET
        trap 'printf "\nNo menu available for the given day\n"' ERR
        echo $MENU_JSON | jq -r ".[\"$(date +%GW%V)\"][]" | jq -csr ".[${WEEKDAY}]" | jq -r 'to_entries[] | "\(.key): \(.value)"'
        exit
    fi
}

function impl_python() {
    if command -v python3 &>/dev/null; then
        trap 'printf "\nNo menu available for the given day\n"' ERR
        python3 - <<EOF

import sys,json,locale as lc,os,datetime as dt
now=dt.datetime.now() - dt.timedelta(days=int(os.environ["MENU_OFFSET"])-1); cw_year=f"{now.year}W{str(now.isocalendar().week).zfill(2)}"
lc.setlocale(lc.LC_ALL,'de_DE'); menu_json=json.loads(os.environ["MENU_JSON"])[cw_year][now.strftime('%A')]
for key in menu_json:print(f"{key}: {menu_json[key]}")

EOF
        exit
    fi
}

impl_jq
impl_python

echo "You have neither jq nor Python3 installed. Falling back to printing the whole JSON. Good luck."; sleep 2
echo $MENU_JSON;
echo "It's recommended to install either jq or Python3 and then rerun the command."
