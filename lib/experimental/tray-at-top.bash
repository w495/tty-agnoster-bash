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
  local __tty_ag_format_delta
  __tty_ag_format_delta "${prompt}"
  local -i line_len=$(( "${COLUMNS}" - "${__tty_ag_format_delta}"))


  local -i  win_line
  win_line="$(( "${line_len}" - 1 ))"


  tput csr "${win_line}" 0
  tput cup 1 "${line_len}"
  printf '%b' "${prompt}"
  tput rc
}
