#!/usr/bin/env bash
# shellcheck enable=all

source "$(dirname "${BASH_SOURCE[0]}")/../utils/format.bash"

# ---------------------------------------------------------------
# $>                                                            |
#                                                               |
#                                                               |
#                                                        <HERE> |
# ---------------------------------------------------------------

__tty_ag_tray_bottom() {
  local prompt="${1}"

  local -i __tty_ag_format_delta
  __tty_ag_format_delta "${prompt}"
  local -i line_len=$(("${COLUMNS}" + "${__tty_ag_format_delta}"))

  # Save cursor position.
  tput sc
  # Create a virtual tray that is two lines smaller at the bottom.
  tput csr 0 $((LINES - 2))
  # Move cursor to last line in your screen
  tput cup $((LINES - 1)) 0
  printf  '%*b' "${line_len}" "${prompt}"
  # Move cursor to home position, back in virtual tray
  tput rc
}
