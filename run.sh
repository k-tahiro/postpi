#!/bin/bash
set -e

readonly SRC_DIR="$(cd $(dirname "$0") && pwd)"

function git::pull() {
  pushd "${SRC_DIR}"
  sudo -u pi git pull
  popd
}

function witty::update() {
  expect -c "
  spawn \"${HOME}/wittypi/wittyPi.sh\"
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
  witty::update
  "${SRC_DIR}/camera.sh"
}

main "$@"


