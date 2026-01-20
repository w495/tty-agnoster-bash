#!/usr/bin/env bash
# shellcheck enable=all

__tty_ag_cursor_row() {
  local row col
  IFS=';' read -p $'\e[6n' -d R -rs row col ||
  __tty_ag_cursor_row="failed with error: $? ; ${row} ${col} "
  row="${row:2}"
  __tty_ag_cursor_row="${row}"
}

__tty_ag_right_window() {
  tput init
  tput sc

  local prompt="${1}"
  prompt_flat=$(
    printf '%b' "${prompt}" | ansi2txt | sed -re 's/\o001|\o002//g'
  )
  local -i line_len=$((COLUMNS - ${#prompt_flat}))

  local __tty_ag_cursor_row
  __tty_ag_cursor_row
  row="${__tty_ag_cursor_row}"

  # Create a virtual window that is two lines smaller at the bottom.
  tput csr "${line_len}" $((row - 1))
  # Move cursor to last line in your screen
  tput cup $((row - 1)) $((line_len))
  printf '%b' "${prompt}"
  # Move cursor to home position, back in virtual window
  tput rc
}
