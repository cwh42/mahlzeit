#!/bin/bash
shopt -s expand_aliases

# set the $SLACK_* variables
source .secrets
# get the `mahlzeit` alias
source .alias

MENU=$(mahlzeit)
MENU=${MENU//$'\n'/\\n} # escape newlines
MENU=${MENU//$'"'/} # remove any double-quotes

MESSAGE="Heute:\n$MENU"
JSON_MSG=$(echo '{"text": "'$MESSAGE'", "channel": "'$SLACK_CHANNEL_ID'"}')

curl -H "Authorization: Bearer $SLACK_AUTH_TOKEN" --data "$JSON_MSG" "$SLACK_WEBHOOK_URL"
