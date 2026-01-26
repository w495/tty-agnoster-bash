#!/usr/bin/env bash
# shellcheck enable=all

source "$(dirname "${BASH_SOURCE[0]}")/../utils/format.bash"

__tty_ag_show_tray_at_bottom() {

  # ----------------------------------------------------------------
  # |> echo 'Some text'                                            |
  # |Some text                                                     |
  # |>                                                             |
  # |                                                              |
  # |                                                              |
  # |                                             <tray_at_bottom> |
  # ----------------------------------------------------------------

  local text="${1}"

  local -i __tty_ag_format_delta
  __tty_ag_format_delta "${text}"
  local -i text_width=$(("${COLUMNS}" + "${__tty_ag_format_delta}"))

  local -i tray_row=$((LINES - 3))
  local -i text_row=$((LINES - 1))

  local -i tray_column=0
  local -i text_column=0

  # Save cursor position.
  tput sc
  # Create a virtual tray that is two lines smaller at the bottom.
  tput csr "${tray_column}" "${tray_row}"
  # Move cursor to last line in your screen
  tput cup "${text_row}" "${text_column}"
  printf  '%*b' "${text_width}" "${text}"
  # Move cursor to home position, back in virtual tray
  tput rc
}
