readonly SLACK_FILE_UPLOAD_URL="https://slack.com/api/files.upload"
source "$(cd $(dirname "$0") && pwd)/variables.conf"

function slack::upload_file() {
  local file="$1"
  local unix_time="$(date '+%s')"
  local response="$(curl -fsL \
                         -F "token=${SLACK_OAUTH_TOKEN}" \
                         -F "channels=${SLACK_CHANNEL_ID}" \
                         -F "file=@${file}" \
                         -F "filename=${unix_time}.jpg" \
                         "${SLACK_FILE_UPLOAD_URL}")"
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