#!/usr/bin/env bash
# shellcheck enable=all

__tty_ag_top_window() {
  tput sc
  local prompt="${1}"

  prompt_flat=$(echo -en "${prompt}" | ansi2txt)
  local -i line_len=$((COLUMNS - ${#prompt_flat}))

  tput csr "${line_len}" 0
  tput cup 0 "${line_len}"
  echo -en "${prompt}\r\n"

  # Move cursor to home position, back in virtual window
  tput rc
}
