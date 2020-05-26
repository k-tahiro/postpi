#!/bin/bash
set -Eu

readonly SRC_DIR="$(cd $(dirname "$0") && pwd)"
readonly LOG_FILE="${SRC_DIR}/run.log"

##################################################
# Git functions
##################################################
function git::pull() {
  pushd "${SRC_DIR}"
  for i in $(seq 60); do
    sudo -u pi git pull
    if [[ $? -eq 0 ]]; then
      popd
      return 0
    fi
    sleep 1
    network::adv
  done
  popd
  return 1
}

function network::adv() {
  curl -F "JUMPPAGE=ADVERTISE" "http://google.co.jp"
  curl "http://www.freespot.com/"
}

##################################################
# Shellscript functions
##################################################
function shell::ng() {
  slack::post "Failed to complete..."
  slack::upload_file "${LOG_FILE}"
  exit 1
}

function shell::exit() {
  echo sudo shutdown -h now
  # sudo shutdown -h now
}

function main() {
  ip addr | grep wlan0 || sudo shutdown -r now  # Check network status
  git::pull || sudo shutdown -r now

  source "${SRC_DIR}/functions"
  witty::schedule
  witty::parameter_from_file "${SRC_DIR}/witty.conf"
  slack::upload_file "$(rpi::camera)"
}

trap shell::exit EXIT
trap shell::ng ERR

main "$@" &>"${LOG_FILE}"
