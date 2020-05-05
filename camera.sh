#!/bin/bash
set -e

readonly UNIX_TIME="$(date '+%s')"
readonly TIMESTAMP="$(date -d "@${UNIX_TIME}" '+%F %T')"
readonly TMPFILE="$(mktemp)"
readonly SLACK_FILE_UPLOAD_URL="https://slack.com/api/files.upload"

source "$(cd $(dirname "$0") && pwd)/variables.conf"

function slack::upload_file() {
  local file="$1"
  local response="$(curl -fsL \
                         -F \"token=${SLACK_OAUTH_TOKEN}\" \
                         -F \"channels=${SLACK_CHANNEL_ID}\" \
                         -F \"file=@${file}\" \
                         -F \"filename=${UNIX_TIME}.jpg\" \
                         -F \"initial_comment=${TIMESTAMP}\" \
                         \"${SLACK_FILE_UPLOAD_URL}\")"
  echo "${response}" | python -c 'import sys; import json; sys.exit(0 if json.loads(raw_input())["ok"] else 1)'
}

function slack::create_payload() {
  local text="$1"
  cat <<EOF
{
  "text": "${text}",
  "blocks": []
}
EOF
}

function slack::post() {
  local text="$1"
  local payload="$(slack::create_payload "${text}")"
  curl -fsL -X POST --data "${payload}" "${SLACK_WEBHOOK_URL}" >/dev/null
}

function shell::ok() {
  rm -f "${TMPFILE}"
  echo "camera.sh has successed."

  # sudo shutdown -h now
}

function shell::ng() {
  local text="camera.sh has failed."
  slack::post "${text}"
  echo "${text}" 1>&2
  
  # sudo shutdown -h now
}

function main() {
  raspistill -vf -hf -o "${TMPFILE}" -w 640 -h 480
  slack::upload_file "${TMPFILE}"
}

main "$@"

trap shell::ok EXIT
trap shell::ng INT PIPE TERM
