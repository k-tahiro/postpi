#!/bin/bash

source "$(cd $(dirname "$0") && pwd)/slack.sh"

function witty::schedule() {
  if [ -f schedule.wpi.md5 ]; then
    md5sum -c schedule.wpi.md5
    if [ $? -eq 0 ]; then
      return 0
    fi
  fi
  md5sum schedule.wpi >schedule.wpi.md5
  expect -c "
  spawn \"/home/pi/wittypi/wittyPi.sh\"
  expect \"What do you want to do? (1~11)\"
  send \"6\n\"
  expect \"Which schedule script do you want to use? (1~7)\"
  send \"6\n\"
  expect \"What do you want to do? (1~11)\"
  send \"11\n\"
  "
  if [[ $? == 0 ]]; then
    slack::post "Successed to update schedule."
  else
    slack::post "Failed to update schedule."
  fi
}

function witty::parameter() {
  local interval="${1:-4}"
  local wl_duration="${2:-100}"
  local dm_duration="${3:-10}"

  expect -c "
  spawn \"/home/pi/wittypi/wittyPi.sh\"
  expect \"What do you want to do? (1~11)\"
  send \"9\n\"
  expect \"Which parameter to set? (1~8)\"
  send \"3\n\"
  expect \"Input new interval (1,2,4 or 8: value in seconds):\"
  send \"${interval}\n\"
  expect \"What do you want to do? (1~11)\"
  send \"9\n\"
  expect \"Which parameter to set? (1~8)\"
  send \"4\n\"
  expect \"Input new duration for white LED (0~255):\"
  send \"${wl_duration}\n\"
  expect \"What do you want to do? (1~11)\"
  send \"9\n\"
  expect \"Which parameter to set? (1~8)\"
  send \"5\n\"
  expect \"Input new duration for dummy load (0~255):\"
  send \"${dm_duration}\n\"
  expect \"What do you want to do? (1~11)\"
  send \"11\n\"
  "
}

function main() {
  witty::schedule
  witty::parameter 2 100 200
}

main "$@"


