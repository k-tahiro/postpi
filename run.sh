#!/bin/bash
set -eu

readonly SRC_DIR="$(cd $(dirname "$0") && pwd)"
readonly LOG_FILE="${SRC_DIR}/run.log"

##################################################
# Git functions
##################################################
function git::pull() {
  local count=0
  pushd "${SRC_DIR}"
  while :; do
    if [[ ${count} > 60 ]]; then
      echo "Could not authenticate" 1>&2
      sudo shutdown -r now
    fi
    set +e
    sudo -u pi git pull
    if [[ $? -eq 0 ]]; then
      break
    fi
    set -e
    sleep 1
    network::adv
    count=$((count+1))
  done
  popd
}

function network::adv() {
  curl -F "JUMPPAGE=ADVERTISE" "http://google.co.jp"
  curl "http://www.freespot.com/"
}

##################################################
# Shellscript functions
##################################################
function shell::ok() {
  shell::finalize
}

function shell::ng() {
  slack::post "Failed to complete..."
  slack::upload_file "${LOG_FILE}"
  shell::finalize
}

function shell::finalize() {
  sudo shutdown -h now
}

function main() {
  ip addr | grep wlan0 || sudo shutdown -r now  # Check network status
  git::pull

  source "${SRC_DIR}/functions"
  source "${SRC_DIR}/witty.conf"
  witty::schedule
  witty::parameter "${WITTY_PULSING_INTERVAL}" "${WITTY_WHITE_LED_DURATION}" "${WITTY_DUMMY_LOAD_DURATION}"
  slack::upload_file "$(rpi::camera)"
}

main "$@" &>"${LOG_FILE}"

trap shell::ok EXIT
trap shell::ng INT PIPE TERM
