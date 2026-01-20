#!/usr/bin/env bash
# shellcheck enable=all

__tty_ag_bottom_window() {
  tput sc
  # Create a virtual window that is two lines smaller at the bottom.
  tput csr 0 $((LINES - 2))
  # Move cursor to last line in your screen
  tput cup $((LINES - 1)) 0
  # shellcheck disable=SC2312
  #printf '.%.0s' $(seq 1 "${COLUMNS}")
  printf  '%b' "${1}"
  # Move cursor to home position, back in virtual window
  tput rc
}
