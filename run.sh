#!/bin/bash

readonly SRC_DIR="$(cd $(dirname "$0") && pwd)"

function git::pull() {
  pushd "${SRC_DIR}"
  while :; do
    sudo -u pi git pull
    if [ $? -eq 0 ]; then
      break
    fi
    sleep 1
  done
  popd
}

function main() {
  git::pull
  "${SRC_DIR}/witty.sh"
  "${SRC_DIR}/camera.sh"
}

main "$@"


