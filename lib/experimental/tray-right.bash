#!/usr/bin/env bash
# shellcheck enable=all

source "$(dirname "${BASH_SOURCE[0]}")/../utils/format.bash"

__tty_ag_cursor_row() {
  local row col
  IFS=';' read -p $'\e[6n' -d R -rs row col ||
    __tty_ag_cursor_row="failed with error: $? ; ${row} ${col} "
  row="${row:2}"
  __tty_ag_cursor_row="${row}"
  echo "${__tty_ag_cursor_row}"
}

__tty_ag_right_tray() {
  tput init

  local prompt="${1}"
  local __tty_ag_format_delta
  __tty_ag_format_delta "${prompt}"
  local -i line_len=$(("${COLUMNS}" + "${__tty_ag_format_delta}"))

  local -i __tty_ag_cursor_row
  __tty_ag_cursor_row

  local -i win_row
  win_row="$(("${__tty_ag_cursor_row}" - 1))"

  tput sc
  tput csr "${line_len}" "${win_row}"
  tput cup "${win_row}" "${line_len}"
  printf '%s' "${prompt}"
  tput rc
}
