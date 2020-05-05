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

function witty::schedule() {
  expect -c "
  spawn \"/home/pi/wittypi/wittyPi.sh\"
  expect \"What do you want to do? (1~11)\"
  send \"6\n\"
  expect \"Which schedule script do you want to use? (1~7)\"
  send \"6\n\"
  expect \"What do you want to do? (1~11)\"
  send \"11\n\"
  "
}

function main() {
  git::pull
  witty::schedule
  "${SRC_DIR}/camera.sh"
}

main "$@"


