#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

fork_spinner() {
  local -r fun="${1}"
  eval "${fun} &2>/dev/null"
  local -r pid=$! # Process Id of the previous running command
  local -ra spin=(
    " - "
    " \ "
    " | "
    " / "
  )
  local i=0
  while kill -0 "${pid}" 2> /dev/null; do
    i=$(((i + 1) % 4))
    echo -en "\r${spin[${i}]}"
    sleep .1
  done
}
