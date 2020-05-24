#!/bin/bash
set -eu

readonly SRC_DIR="$(cd $(dirname "$0") && pwd)"
readonly LOG_FILE="${SRC_DIR}/run.log"

source "$(cd $(dirname "$0") && pwd)/slack.sh"

function network::adv() {
  curl -F "JUMPPAGE=ADVERTISE" "http://google.co.jp" >adv.html
  curl "http://www.freespot.com/"
}

function git::pull() {
  pushd "${SRC_DIR}"
  while :; do
    sudo -u pi git pull
    if [ $? -eq 0 ]; then
      break
    fi
    sleep 1
    network::adv
  done
  popd
}

function shell::ok() {
  rm -f "${TMPFILE}"
  echo "Bye!"
}

function shell::ng() {
  slack::post "Failed to complete..."
  slack::upload_file "${LOG_FILE}"
}

function main() {
  git::pull
  "${SRC_DIR}/witty.sh"
  "${SRC_DIR}/camera.sh"
}

main "$@" >"${LOG_FILE}"

trap shell::ok EXIT
trap shell::ng INT PIPE TERM
