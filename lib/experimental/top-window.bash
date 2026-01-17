#!/usr/bin/env bash
# shellcheck enable=all

__tty_ag_top_window() {
  tput sc
  local ps1r="${1}"
  local -i line_len=$((COLUMNS - ${#ps1r}))
  tput csr "${line_len}" 0
  tput cup 0 "${line_len}"
  printf "|%s|" "XXX"
  # Move cursor to home position, back in virtual window
  tput rc
}
