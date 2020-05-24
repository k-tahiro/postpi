#!/bin/bash
set -eu

readonly SRC_DIR="$(cd $(dirname "$0") && pwd)"
readonly LOG_FILE="${SRC_DIR}/run.log"

##################################################
# Git functions
##################################################
function git::pull() {
  pushd "${SRC_DIR}"
  while :; do
    sudo -u pi git pull
    if [[ $? -eq 0 ]]; then
      break
    fi
    sleep 1
    network::adv
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
  witty::schedule
  witty::parameter 2 100 255
  slack::upload_file "$(rpi::camera)"
}

main "$@" &>"${LOG_FILE}"

trap shell::ok EXIT
trap shell::ng INT PIPE TERM
