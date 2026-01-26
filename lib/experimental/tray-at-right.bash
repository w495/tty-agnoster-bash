#!/usr/bin/env bash
# shellcheck enable=all

source "$(dirname "${BASH_SOURCE[0]}")/../utils/format.bash"

__tty_ag_cursor_position() {
  # It uses global var to avoid subshells.
  local cursor_position
  local -i cursor_row
  stty -echo
  echo -n $'\e[6n'
  # shellcheck disable=SC2162
  read -dR cursor_position
  stty echo
  __tty_ag_cursor_position="${cursor_position#??}"
}

__tty_ag_show_tray_at_right() {

  # ----------------------------------------------------------------
  # |> echo 'Some text'                            <tray_at_right> |
  # |Some text                                                     |
  # |>                                                             |
  # |                                                              |
  # |                                                              |
  # ----------------------------------------------------------------

  local text="${1}"
  local -i chars_number=0
  chars_number=$(__tty_ag_format_chars_number "${text}")
  local -i text_offset=$(("${COLUMNS}" - "${chars_number}"))

  local __tty_ag_cursor_position
  __tty_ag_cursor_position
  local -i cursor_row="${__tty_ag_cursor_position%%;*}"

  local -i tray_row="$(("${cursor_row}" - 1))"
  local -i text_row="$(("${cursor_row}" - 1))"

  local -i tray_column="$(("${text_offset}" - 1))"
  local -i text_column="${text_offset}"

  tput sc
  tput csr "${tray_column}" "${tray_row}"
  tput cup "${text_row}"    "${text_column}"
  printf '%b' "${text}"
  tput rc
}
