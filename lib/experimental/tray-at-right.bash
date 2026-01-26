#!/usr/bin/env bash
# shellcheck enable=all

source "$(dirname "${BASH_SOURCE[0]}")/../utils/format.bash"


__tty_ag_cursor_position() {
  local cursor_position
  local -i cursor_row

  stty -echo
  echo -n $'\e[6n';
  # shellcheck disable=SC2162
  read -dR cursor_position
  stty echo;
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
  local prompt="${1}"
  local -i chars_number=0
  chars_number=$(__tty_ag_format_chars_number "${prompt}")
  local -i col_len=$(( "${COLUMNS}" - "${chars_number}" ))


  local __tty_ag_cursor_position
  __tty_ag_cursor_position
  local -i cursor_row="${__tty_ag_cursor_position%%;*}"

  local -i win_row="${cursor_row}"
  win_row="$(( "${cursor_row}" - 1 ))"
  local -i cur_row
  cur_row="$(( "${cursor_row}" - 1 ))"

  local -i  win_col
  win_col="$(( "${col_len}" - 1 ))"

  tput sc
  tput csr "${win_col}" "${win_row}"
  tput cup "${cur_row}" "${col_len}"
  printf '%b' "${prompt}"
  tput rc
}
