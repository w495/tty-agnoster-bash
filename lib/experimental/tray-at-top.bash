#!/usr/bin/env bash
# shellcheck enable=all

source "$(dirname "${BASH_SOURCE[0]}")/../utils/format.bash"


# ----------------------------------------------------------------
# |                                                <tray_at_top> |
# |> echo 'Some text'                                            |
# |Some text                                                     |
# |>                                                             |
# |                                                              |
# |                                                              |
# ----------------------------------------------------------------

__tty_ag_show_tray_at_top() {
  tput sc
  local prompt="${1}"

  local prompt="${1}"

  local -i chars_number=0
  chars_number=$(__tty_ag_format_chars_number "${prompt}")
  local -i col_line=$(( "${COLUMNS}" - "${chars_number}" ))


  local -i  win_line
  win_line="$(( "${col_line}" - 1 ))"


  tput csr "${win_line}" 0
  tput cup 0 "${col_line}"
  printf '%b' "${prompt}"
  tput rc
}
