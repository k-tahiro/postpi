#!/bin/bash
set -Eu

readonly SRC_DIR="$(cd $(dirname "$0") && pwd)"
readonly LOG_FILE="${SRC_DIR}/run.log"

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
  source "${SRC_DIR}/functions"

  echo "Updating witty settings..."
  witty::schedule
  witty::parameter_from_file "${SRC_DIR}/witty.conf"

  PYTHONPATH="${SRC_DIR}/examples/lite/examples/object_detection/raspberry_pi" python3 "${SRC_DIR}/detect.py" --model "${SRC_DIR}/detect.tflite"
  if [[ $? == 0 ]]; then
    slack::post "k-tahiro is detected!"
  else
    slack::post "k-tahiro is not detected..."
  fi

  echo "Using camera and uploading..."
  slack::upload_file "$(rpi::camera)"
}

trap shell::exit EXIT
trap shell::ng ERR

main "$@" |& tee -a "${LOG_FILE}"
