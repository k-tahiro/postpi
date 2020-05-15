#!/bin/bash

readonly SRC_DIR="$(cd $(dirname "$0") && pwd)"

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

function main() {
  git::pull
  "${SRC_DIR}/witty.sh"
  "${SRC_DIR}/camera.sh"
}

main "$@"
