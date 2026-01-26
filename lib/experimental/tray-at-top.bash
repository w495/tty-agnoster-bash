#!/usr/bin/env bash
# shellcheck enable=all

source "$(dirname "${BASH_SOURCE[0]}")/../utils/format.bash"

__tty_ag_show_tray_at_top() {

  # ----------------------------------------------------------------
  # |                                                <tray_at_top> |
  # |> echo 'Some text'                                            |
  # |Some text                                                     |
  # |>                                                             |
  # |                                                              |
  # |                                                              |
  # ----------------------------------------------------------------

  local text="${1}"

  local -i chars_number=0
  chars_number=$(__tty_ag_format_chars_number "${text}")
  local -i text_offset=$(("${COLUMNS}" - "${chars_number}"))

  local -i tray_row=0
  local -i text_row=0

  local -i tray_column="$(("${text_offset}" - 1))"
  local -i text_column="${text_offset}"

  tput sc
  tput csr "${tray_column}" "${tray_row}"
  tput cup "${text_row}" "${text_column}"
  printf '%b' "${text}"
  tput rc
}
