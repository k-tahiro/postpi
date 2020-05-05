#!/bin/bash
set -e

readonly SRC_DIR="$(cd $(dirname "$0") && pwd)"

function git::pull() {
  pushd "${SRC_DIR}"
  git pull
  popd
}

function main() {
  git::pull
  sh "${SRC_DIR}/camera.sh"
}

main "$@"


