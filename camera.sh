#!/bin/bash

readonly TMPFILE="$(mktemp)"
source "$(cd $(dirname "$0") && pwd)/slack.sh"

function main() {
  raspistill -vf -hf -o "${TMPFILE}" -w 640 -h 480
  slack::upload_file "${TMPFILE}"
}

main "$@"
