#!/usr/bin/env bash
# shellcheck enable=all

__tty_ag_cursor_row() {
  local row col
  IFS=';' read -p $'\e[6n' -d R -rs row col \
  || echo "failed with error: $? ; ${row} ${col} "
  row="${row:2}"
  echo "${row}"
}

__tty_ag_right_window() {
  tput init
  tput sc

  local value="${1}"
  value_flat=$(echo -en "${value}" | ansi2txt)
  local -i line_len=$((COLUMNS - ${#value_flat}))

  row=$(__tty_ag_cursor_row)
  # Create a virtual window that is two lines smaller at the bottom.
  tput csr "${line_len}" $((row - 1))
  # Move cursor to last line in your screen
  tput cup $((row - 1)) $((line_len))
  echo -en "${value}\r\n"
  # Move cursor to home position, back in virtual window
  tput rc
}
