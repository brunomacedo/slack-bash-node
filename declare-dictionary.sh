#!/bin/bash

declare -A __OBJECT_ITEMS=(
  [token]="T5BP32JL9"
  [slack_hook]="https://hooks.slack.com/"
  [input]="download.json"
  [output]="catalogo.json"
)

declare -A __MESSAGES_SLACK=(
  [200]="Download success."
  [404]="Page not found."
  [500]="Internal server error."
  [default]="Error when download file."
)

# echo "${__OBJECT_ITEMS[500]}"
echo ${__OBJECT_ITEMS[slack_hook]} # slack_hook's __OBJECT_ITEMS
echo ${__OBJECT_ITEMS[@]}   # All values
echo ${!__OBJECT_ITEMS[@]}  # All keys
echo ${#__OBJECT_ITEMS[@]}  # Number of elements

unset __OBJECT_ITEMS[slack_hook]   # Delete slack_hook
echo ${__OBJECT_ITEMS[slack_hook]} # slack_hook's __OBJECT_ITEMS
