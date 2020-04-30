#!/bin/bash

__API_REQUEST="https://www.mocky.io/v2/5185415ba171ea3a00704eed"
__DOWNLOAD_FILE="src/download.json"
__SAVED_FILE="src/file.json"
__SLACK_HOOK_URL="https://hooks.slack.com/services/..."
__CARD_ICON="https://brunomacedo.com.br/public/images/favicon.png"
__MSG_ERROR="Oops... We found an error on download file"
__MSG_SUCCESS="Uhuu... File download completed successfully"
__STATUS_CODE_API=""

forceCreateFile() {
  mkdir -p "$(dirname "$1")" || return; touch "$1"
}

printCurrentTime() {
  local CURRENT_TIME_K8S="$(date +'%d/%m/%Y at %Hh%M')"
  echo "${CURRENT_TIME_K8S}"
}

createSlackMessageBlock() {
  cat <<EOF
    {
      "blocks": [
        {
          "type": "section",
          "block_id": "section567",
          "text": {
            "type": "mrkdwn",
            "text": "*$1* \n*Location*: production \n*Response:*  $__STATUS_CODE_API \n*Service IP*: 100.0.0.560 \n*Pod*: ${HOSTNAME} \n<https://brunomacedo.com.br|View>"
          },
          "accessory": {
            "type": "image",
            "image_url": "$__CARD_ICON",
            "alt_text": "Icon"
          }
        },
        {
          "type": "context",
          "elements": [
            {
              "type": "mrkdwn",
              "text": "Last updated: $(printCurrentTime)"
            }
          ]
        },
        {
          "type": "divider"
        }
      ]
    }
EOF
}

slack() {
  curl -X POST -H 'Content-type: application/json' \
    --data "$(createSlackMessageBlock "$2")" \
    "$1" \
    &>/dev/null
}

request() {
  rm $__DOWNLOAD_FILE 2>/dev/null
  forceCreateFile $__DOWNLOAD_FILE

  __HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" $__API_REQUEST)
  __HTTP_BODY=$(echo $__HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
  __HTTP_STATUS=$(echo $__HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
  __STATUS_CODE_API="$__HTTP_STATUS"

  if [ ! $__HTTP_STATUS -eq 200  ]; then
    slack "$__SLACK_HOOK_URL" "$__MSG_ERROR"
    return
  fi

  echo "$__HTTP_BODY" > $__DOWNLOAD_FILE

  __IS_EMPTY=$(cat $__DOWNLOAD_FILE 2>/dev/null)
  if test -z "$__IS_EMPTY" || ! jq . $__DOWNLOAD_FILE &>/dev/null; then
    slack "$__SLACK_HOOK_URL" "$__MSG_ERROR"
    return
  fi

  mv $__DOWNLOAD_FILE $__SAVED_FILE
  slack "$__SLACK_HOOK_URL" "$__MSG_SUCCESS"
}

endless() {
  while true
  do
    request &
    sleep 600
  done
}

endless &
