#!/bin/bash
set -eu

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
  set +e
  ip addr | grep wlan0 || sudo shutdown -r now  # Check network status
  git::pull || sudo shutdown -r now
  set -e

  source "${SRC_DIR}/functions"
  witty::schedule
  witty::parameter_from_file "${SRC_DIR}/witty.conf"
  slack::upload_file "$(rpi::camera)"
}

main "$@" &>"${LOG_FILE}"

trap shell::ok EXIT
trap shell::ng INT PIPE TERM
