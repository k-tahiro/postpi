#!/bin/bash
set -eu

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

  sudo -u pi moonlight stream
  return 0

  set +e
  export PYTHONPATH="${SRC_DIR}/examples/lite/examples/object_detection/raspberry_pi"
  if [[ -f "${SRC_DIR}/begin" ]]; then
    python3 "${SRC_DIR}/detect.py" --model "${SRC_DIR}/detect.tflite" --inverse --timeout 60
  else
    python3 "${SRC_DIR}/detect.py" --model "${SRC_DIR}/detect.tflite" --timeout 60
  fi
  rc=$?
  set -e
  if [[ $rc == 0 ]]; then
    if [[ -f "${SRC_DIR}/begin" ]]; then
      slack::post "Begin: $(cat "${SRC_DIR}/begin")\nFinish: $(date '%H:%M')"
    else
      date '+%H:%M' | tr -d '\n' >"${SRC_DIR}/begin"
    fi
    slack::post "Successed to detect!"
  else
    if [[ -f "${SRC_DIR}/begin" ]]; then
      rm -f "${SRC_DIR}/begin"
    fi
    slack::post "Failed to detect..."
  fi

  echo "Using camera and uploading..."
  slack::upload_file "$(rpi::camera)"
}

trap shell::exit EXIT
trap shell::ng ERR

main "$@" |& tee -a "${LOG_FILE}"
