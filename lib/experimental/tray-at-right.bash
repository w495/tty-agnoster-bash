#!/usr/bin/env bash
# shellcheck enable=all

source "$(dirname "${BASH_SOURCE[0]}")/../utils/format.bash"


# ----------------------------------------------------------------
# |> echo 'Some text'                            <tray_at_right> |
# |Some text                                                     |
# |>                                                             |
# |                                                              |
# |                                                              |
# ----------------------------------------------------------------

__tty_ag_show_tray_at_right() {
  tput init
  local prompt="${1}"
  local __tty_ag_format_delta
  __tty_ag_format_delta "${prompt}"
  chars_number=$(__tty_ag_format_chars_number "${prompt}")
  local -i line_len=$(("${COLUMNS}" - "${chars_number}" ))

  local row col
  local -i cursor_row
  IFS=';' read -p $'\e[6n' -d R -rs row col || return 1
  cursor_row="${row:2}"

  local -i win_row="${cursor_row}"
  win_row="$(( "${cursor_row}" - 0 ))"
  local -i cur_row
  cur_row="$(( "${cursor_row}" - 1 ))"

  local -i  win_line
  win_line="$(( "${line_len}" - 1 ))"

  tput sc
  tput csr "${win_line}" "${win_row}"
  tput cup "${cur_row}" "${line_len}"
  printf '%s' "${prompt}"
  tput rc
}

__tty_ag_cursor() {
  local row col
  IFS=';' read -p $'\e[6n' -d R -rs row col || return 1
  row="${row:2}"
  __tty_ag_cursor__row="${row}"
  __tty_ag_cursor__col="${col}"
}
