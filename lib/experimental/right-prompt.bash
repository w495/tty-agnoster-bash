#!/usr/bin/env bash
# shellcheck enable=all

source "$(dirname "${BASH_SOURCE[0]}")/../utils/format.bash"

__tty_ag_show_right_prompt() {

  # ----------------------------------------------------------------
  # |> echo 'Some text'                             <right_prompt> |
  # |Some text                                                     |
  # |>                                                             |
  # |                                                              |
  # |                                                              |
  # |                                                              |
  # ----------------------------------------------------------------

  local text="${1}"
  local __tty_ag_format_delta
  __tty_ag_format_delta "${text}"
  local -i text_width=$(("${COLUMNS}" + "${__tty_ag_format_delta}"))

  tput sc
  printf "%*s" "${text_width}" "${text}"
  tput rc
}
