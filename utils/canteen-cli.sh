#!/bin/sh
API_URL="https://users.suse.com/~cwh/mahlzeit/mahlzeit.json"

if [ $# -eq 0 ]; then # No arguments supplied
    MENU_OFFSET=1
else
    case "$1" in
    "tomorrow") MENU_OFFSET=0 ;;
    "yesterday") MENU_OFFSET=2 ;;
    "today") MENU_OFFSET=1 ;;
    *)
        echo "Unknown argument. Try no argument, 'tomorrow', 'yesterday' or 'today'"
        exit
        ;;
    esac
fi

MENU_JSON=$(curl -s $API_URL)

function impl_jq() {
    if command -v jq &>/dev/null; then
        WEEKDAY=$(date +%u)-$MENU_OFFSET
        trap 'printf "\nNo menu available for the given day\n"' ERR
        echo $MENU_JSON | jq -r ".[\"$(date +%GW%V)\"][]" | jq -csr ".[${WEEKDAY}]" | jq -r 'to_entries[] | "\(.key): \(.value)"'
        exit
    fi
}

export MENU_JSON && export MENU_OFFSET # to access in python via os.environ[]

function impl_python() {
    if command -v python3 &>/dev/null; then
        trap 'printf "\nNo menu available for the given day\n"' ERR
        python3 - <<EOF

import sys,json,locale as lc,os,datetime as dt
now=dt.datetime.now() - dt.timedelta(days=int(os.environ["MENU_OFFSET"])-1); 
cw_year="%sW%s" % (now.year, str(now.isocalendar()[1]).zfill(2))
lc.setlocale(lc.LC_ALL,'de_DE'); menu_json=json.loads(os.environ["MENU_JSON"])[cw_year][now.strftime('%A')]
for key in menu_json:print("%s: %s" % (key, menu_json[key]))

EOF
        exit
    fi
}

impl_jq
impl_python

echo "You have neither jq nor Python3 installed. Falling back to printing the whole JSON. Good luck."
sleep 2
echo $MENU_JSON
echo "It's recommended to install either jq or Python3 and then rerun the command."
