#!/bin/bash

readonly SRC_DIR="$(cd $(dirname "$0") && pwd)"

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

git::pull
