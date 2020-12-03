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
    if sudo -u pi git pull; then
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
  if [[ $? != 0 ]]; then
    sudo shutdown -r now
  fi
  exit 1
}

function shell::exit() {
  echo "Exit script..."
}

function main() {
  ip addr | grep wlan0

  git::pull
  source "${SRC_DIR}/functions"

  while :; do
    moonlight stream 192.168.0.70 -app Steam
  done
  exit 0

  echo "Updating witty settings..."
  witty::schedule
  witty::parameter_from_file "${SRC_DIR}/witty.conf"

  # echo "Using camera and uploading..."
  # slack::upload_file "$(rpi::camera)"
}

trap shell::exit EXIT
trap shell::ng ERR

main "$@" |& tee -a "${LOG_FILE}"
